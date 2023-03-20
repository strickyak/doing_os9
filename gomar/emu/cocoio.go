//go:build cocoio

// This cocoio.go file has enough emulation for doing basic UDP packets.
package emu

import (
	"fmt"
	"log"
	"net"
	"time"
)

type socket struct {
	k      Word // socket number 0..3
	base   Word // base of socket registers, e.g. 0x400, 0x500, ...
	txRing Word
	rxRing Word
	uconn  *net.UDPConn
	tconn  *net.TCPConn
	queue  chan []byte
}

var socks [4]*socket

func init() {
	for i := Word(0); i < 4; i++ {
		socks[i] = &socket{
			k:      i,
			base:   0x400 + i*0x100,
			txRing: 0x4000 + i*0x800,
			rxRing: 0x6000 + i*0x800,
		}
	}
}
func sockOf(a Word) *socket {
	i := (a >> 8) - 4
	AssertLT(i, 4, a)
	return socks[i]
}

var wizMem [1 << 16]byte
var wizAddr Word

const (
	TxFreeSize = 0x20
	TxRd       = 0x22
	TxWr       = 0x24
	RxRecvSize = 0x26
	RxRd       = 0x28
	RxWr       = 0x2A
)

func putWizWord(reg Word, value Word) {
	wizMem[reg] = byte(value >> 8)
	wizMem[reg+1] = byte(value)
}
func wizWord(reg Word) Word {
	hi := wizMem[reg]
	lo := wizMem[reg+1]
	return (Word(hi) << 8) + Word(lo)
}

func wizReset() {
	for i := range wizMem {
		wizMem[i] = 0
	}
	// tx := Word(0x4000)
	// rx := Word(0x6000)
	for _, s := range socks {
		if s.uconn != nil {
			s.uconn.Close()
			s.uconn = nil
		}
		if s.tconn != nil {
			s.tconn.Close()
			s.tconn = nil
		}
	}
}

func OpenTCP(localHostPort string, remoteHostPort string) *net.TCPConn {
	laddy, err := net.ResolveTCPAddr("tcp", localHostPort)
	if err != nil {
		log.Panicf("WIZ: cannot ResolveTCPAddr: %v", err)
	}
	raddy, err := net.ResolveTCPAddr("tcp", remoteHostPort)
	if err != nil {
		log.Panicf("WIZ: cannot ResolveTCPAddr: %v", err)
	}
	tconn, err := net.DialTCP("tcp", laddy, raddy)
	if err != nil {
		log.Panicf("WIZ: cannot ListenUDP: %v", err)
	}
	wizLog("OpenTcp: success: %q %q", localHostPort, remoteHostPort)
	return tconn
}

func OpenUDP(hostport string) *net.UDPConn {
	addy, err := net.ResolveUDPAddr("udp", hostport)
	if err != nil {
		log.Panicf("WIZ: cannot ResolveUDPAddr: %v", err)
	}
	uconn, err := net.ListenUDP("udp", addy)
	if err != nil {
		log.Panicf("WIZ: cannot ListenUDP: %v", err)
	}
	return uconn
}

func localIP() string {
	return fmt.Sprintf("%d.%d.%d.%d",
		wizMem[0x0F], wizMem[0x10],
		wizMem[0x11], wizMem[0x12])
}

func GetCocoIO(a Word) byte {
	switch a {
	case 0xFF68:
		return 3
	case 0xFF69:
		return byte(0xFF & (wizAddr >> 8))
	case 0xFF6a:
		return byte(0xFF & (wizAddr >> 0))
	case 0xFF6b:
		z := wizGet(wizAddr)
		wizAddr++
		return z
	default:
		log.Panicf("WIZ: Not a CocoIO addr: %x", a)
		panic(0)
	}
}
func PutCocoIO(a Word, b byte) {
	switch a {
	case 0xFF68:
		wizReset()
	case 0xFF69:
		// Set hi byte of wizAddr
		wizAddr = (Word(b) << 8) | (wizAddr & 0x00FF)
	case 0xFF6a:
		// Set lo byte of wizAddr
		wizAddr = Word(b) | (wizAddr & 0xFF00)
	case 0xFF6b:
		wizPut(wizAddr, b)
		wizAddr++
	default:
		log.Panicf("WIZ: Not a CocoIO addr: %x", a)
	}
}
func wizPutStatus(a Word, b byte) {
	log.Panicf("WIZ: Socket Status is a RO register: %x %x", a, b)
}
func wizPutInterrupt(a Word, b byte) {
	x := wizMem[a]
	x &^= b // clear the bits that are set in b.
	wizMem[a] = x
}

func wizSendUDP(sock *socket) {
	base := sock.base
	txRing := sock.txRing

	begin := wizWord(base + TxRd)
	end := wizWord(base + TxWr)

	size := end - begin
	size &= 0x7ff       // 2K ring buffers.
	AssertGT(size, 2)   // reasonable for now
	AssertLT(size, 700) // reasonable for now

	buf := make([]byte, size)
	for i := Word(0); i < size; i++ {
		p := (begin + i) & 0x7FF
		buf[i] = wizMem[p+txRing]
	}

	hostport := fmt.Sprintf("%d.%d.%d.%d:%d",
		wizMem[base+0x0c],
		wizMem[base+0x0d],
		wizMem[base+0x0e],
		wizMem[base+0x0f],
		wizWord(base+0x10))
	addy, err := net.ResolveUDPAddr("udp", hostport)
	if err != nil {
		log.Panicf("cannot ResolveUDPAddr: %v", err)
	}
	cc, err := sock.uconn.WriteToUDP(buf, addy)
	if err != nil {
		log.Panicf("Cannot WriteToUDP: len $%x: err %v ", len(buf), err)
	}
	if cc != len(buf) {
		log.Panicf("Short Write: sent $%x wanted $%x bytes", cc, len(buf))
	}
	putWizWord(base+TxRd, end)
	// Set "interrupt" bit for SENDOK
	wizMem[base+2] |= (1 << 4) // SENDOK Interrupt Bit.
	wizLog("UDP SEND socket %x to %q size $%x", sock.k, hostport, size)
}

func wizSendTCP(sock *socket) {
	base := sock.base
	txRing := sock.txRing

	begin := wizWord(base + TxRd)
	end := wizWord(base + TxWr)

	size := end - begin
	size &= 0x7ff       // 2K ring buffers.
	AssertGT(size, 2)   // reasonable for now
	AssertLT(size, 700) // reasonable for now

	buf := make([]byte, size)
	for i := Word(0); i < size; i++ {
		p := (begin + i) & 0x7FF
		buf[i] = wizMem[p+txRing]
	}

	cc, err := sock.tconn.Write(buf)
	if err != nil {
		panic(err)
	}
	if cc != len(buf) {
		log.Panicf("Short Write: sent %x wanted %x bytes", cc, len(buf))
	}
	putWizWord(base+TxRd, end)
	// Set "interrupt" bit for SENDOK
	wizMem[base+2] |= (1 << 4) // SENDOK Interrupt Bit.
	wizLog("TCP SENT: socket %x size $%x", sock.k, size)
}

func wizTryRecvTCP(sock *socket) {
	base := sock.base

	rx_w := wizWord(base + RxWr)
	rx_r := wizWord(base + RxRd)
	avail := (rx_r - rx_w) & 0x7ff
	if avail == 0 {
		avail = 0x7ff
	}
	wizLog("Trying Recv TCP -- w=%x r=%x avail=%x", rx_w, rx_r, avail)
	if avail > RECEIVE_CHUNK_SIZE {
		select {
		case buf := <-sock.queue:
			n := Word(len(buf))
			wizLog("Recv TCP -- GOT %d bytes: %q", n, buf)
			for i := Word(0); i < n; i++ {
				wizMem[sock.rxRing+((rx_w+i)&0x7ff)] = buf[i]
				wizLog("  ( [%x]: saved %02x at wiz addr %04x )", i, buf[i], sock.rxRing+((rx_w+i)&0x7ff))
			}
			rx_w += n
			putWizWord(base+RxWr, rx_w)
			putWizWord(base+0x26, rx_w-rx_r) // Received Size Register
			wizLog("Recv TCP -- Received Size = %x", rx_w-rx_r)
		default:
			wizLog("Recv TCP -- empty queue.")
			// fall out
		}
	} else {
		wizLog("Recv TCP -- no room r=%x w=%x a=%x", rx_r, rx_w, avail)
	}
}

const RECEIVE_CHUNK_SIZE = 95 // arbitrary

func wizUpdateRecvTCP(sock *socket) {
	base := sock.base
	rx_w := wizWord(base + RxWr)
	rx_r := wizWord(base + RxRd)
	diff := rx_w - rx_r // how much received, not read yet.
	AssertLE(diff, 0x800)
	putWizWord(base+0x26 /*RX_RSR*/, diff) // fix received size register.
}

func wizReceiveTcpInBackground(sock *socket) {
	log.Printf("BG Receiver: starting on sock %x", sock.k)
	for {
		buf := make([]byte, RECEIVE_CHUNK_SIZE)
		cc, err := sock.tconn.Read(buf)

		if err != nil {
			log.Printf("BG Receiver: sock %x EXITING", sock.k)
			return
		}

		log.Printf("BG Receiver: enqueue  %x bytes", cc)
		sock.queue <- buf[:cc]
	}
}

func wizRecvUDP(sock *socket) {
	base := sock.base
	rxRing := sock.rxRing

	wizLog("UDP RECV socket %x", sock.k)
	buf := make([]byte, 1500)
	size, peer, err := sock.uconn.ReadFromUDP(buf)
	wizLog("UDP RECV socket %x got size $%x peer %v err %v", sock.k, size, peer, err)
	if err != nil {
		panic(err)
	}
	AssertGT(Word(size), 1)    // reasonable for now
	AssertLT(Word(size), 1500) // reasonable for now

	const UDP_RX_HEADER_SIZE = 8

	begin := wizWord(base + RxWr)
	end := wizWord(base + RxRd)
	gap := end - begin
	gap &= 0x7ff // 2K ring buffers.
	if gap < 1 {
		gap = 0x7ff
	}
	wizLog("UDP RECV: begin=%x end=%x gap=%x ... rxRing=%x", begin, end, gap, rxRing)
	AssertGT(gap, Word(size+UDP_RX_HEADER_SIZE))

	addrPort := peer.AddrPort()
	port := addrPort.Port()
	addr := addrPort.Addr()
	a4 := addr.As4()

	wizMem[rxRing+(0x7ff&(begin+0))] = a4[0]
	wizMem[rxRing+(0x7ff&(begin+1))] = a4[1]
	wizMem[rxRing+(0x7ff&(begin+2))] = a4[2]
	wizMem[rxRing+(0x7ff&(begin+3))] = a4[3]

	wizMem[rxRing+(0x7ff&(begin+4))] = (byte)(port >> 8)
	wizMem[rxRing+(0x7ff&(begin+5))] = (byte)(port >> 0)
	wizMem[rxRing+(0x7ff&(begin+6))] = (byte)(size >> 8)
	wizMem[rxRing+(0x7ff&(begin+7))] = (byte)(size >> 0)

	// Copy bytes into the Rx Ring
	for i := 0; i < size; i++ {
		p := 0x7ff & (begin + UDP_RX_HEADER_SIZE + Word(i))
		wizMem[rxRing+p] = buf[i]
	}
	// Update the pointer for writing into the Rx Ring
	putWizWord(base+RxWr, 0x1ff&(begin+UDP_RX_HEADER_SIZE+Word(size)))

	// Set "interrupt" bit for RECV
	wizMem[base+2] |= (1 << 2) // RECV Interrupt Bit.
}

func wizPutCommand(a Word, b byte) {
	sock := sockOf(a)
	base := sock.base
	txRing := sock.txRing
	rxRing := sock.rxRing
	wizLog("wizPutCommand a=%x b=%x base=%x tx=%x rx=%x sock=%#v", a, b, base, txRing, rxRing, sock)
	switch b {
	case 0x01:
		{ // open
			switch 15 & wizMem[base] {
			case 1: /*TCP*/
				{
					wizMem[3+base] = 0x13 // Status is SOCK_INIT.
					wizLog("TCP OPEN socket %x", sock.k)
				}
			case 2: /*UDP*/
				{
					hostport := fmt.Sprintf(":%d", wizWord(base+0x04))
					sock.uconn = OpenUDP(hostport)
					wizMem[3+base] = 0x22 // Status is SOCK_UDP.
					wizLog("UDP OPEN socket %x", sock.k)
				}
			default:
				log.Panicf("Command OPEN on socket %x but in wrong mode: $%x", sock.k, wizMem[base])
			}

		}

	case 4: /* TCP CONNECT */
		{
			local := fmt.Sprintf(":%d", wizWord(base+0x04 /*SourcePortRegister*/))
			remote := fmt.Sprintf("%d.%d.%d.%d:%d",
				wizMem[base+0x0C],
				wizMem[base+0x0D],
				wizMem[base+0x0E],
				wizMem[base+0x0F],
				wizWord(base+0x10))
			wizLog("TCP CONNECT socket %x local %q remote %q", sock.k, local, remote)
			sock.tconn = OpenTCP(local, remote)

			putWizWord(base+0x22 /*tx rd*/, sock.txRing)
			putWizWord(base+0x24 /*tx wr*/, sock.txRing)

			putWizWord(base+0x28 /*rx rd*/, sock.rxRing)
			putWizWord(base+0x2A /*rx wr*/, sock.rxRing)

			wizMem[3+base] = 0x15 // Status is SOCK_SYNSENT.
			wizMem[3+base] = 0x17 // Status is SOCK_ESTABLISHED.

			wizLog("TCP socket %x ESTABLISHED", sock.k)
			sock.queue = make(chan []byte, 10)
			go wizReceiveTcpInBackground(sock)
		}

	case 0x10:
		{ // close
			if sock.uconn != nil {
				sock.uconn.Close()
				sock.uconn = nil
			}
			if sock.tconn != nil {
				sock.tconn.Close()
				sock.tconn = nil
			}
			wizMem[3+base] = 0x00 // Status is SOCK_CLOSED.
			wizLog("CLOSE socket %x", sock.k)
		}
	case 0x20:
		{ // send
			status := wizMem[base+3]
			switch status {
			case 0x22 /* status SOCK_UDP */ :
				wizSendUDP(sock)
			case 0x17 /* status SOCK_ESTABLISHED */ :
				wizSendTCP(sock)
			default:
				log.Panicf("Command SEND on socket %x with wrong status $%x", sock.k, status)
			}
		}
	case 0x40:
		{ // recv
			status := wizMem[base+3]
			switch status {
			case 0x22 /* status SOCK_UDP */ :
				wizRecvUDP(sock)
			case 0x17 /* status SOCK_ESTABLISHED */ :
				wizUpdateRecvTCP(sock)
			default:
				log.Panicf("Command RECV on socket %x with wrong status $%x", sock.k, status)
			}

		}
	}
}
func wizMode(b byte) {
	if (b & 0x80) != 0 {
		wizReset()
	}
}
func wizSocketlessCommand(b byte) {
	panic("todo")
}
func wizPut(a Word, b byte) {
	wizLog("WIZ:PUT %04x <- %02x", a, b)
	wizMem[a] = b
	switch a {
	case 0:
		wizMode(b)
	case 0x004C:
		wizSocketlessCommand(b)

	case 0x0401,
		0x0501,
		0x0601,
		0x0701:
		wizPutCommand(a, b)
	case 0x0402,
		0x0502,
		0x0602,
		0x0702:
		wizPutInterrupt(a, b)
	case 0x0403,
		0x0503,
		0x0603,
		0x0703:
		wizPutStatus(a, b)
	default:
		wizMem[a] = b
	}
}

func TimerByte(a Word) byte {
	ticks := time.Now().UnixMicro() / 100 // 100us ticks.
	switch a {
	case 0x0082:
		return byte(ticks >> 8)
	case 0x0083:
		return byte(ticks >> 0)
	}
	panic(0)
}
func wizSocketlessInterruptReg() byte {
	return 0x04 // just say it timed out. // p38 3.1.40
}
func wizGet(a Word) byte {
	var z byte
	switch a {
	case 0x005F:
		z = wizSocketlessInterruptReg()

	case 0x0082,
		0x0083:
		z = TimerByte(a)

	case 0x0401,
		0x0501,
		0x0601,
		0x0701:
		z = 0 // Simulate command is finished.

	case 0x0420, // TX FSR: Free size Register
		0x0520,
		0x0620,
		0x0720:
		{
			rp := wizWord(a + 2)
			wp := wizWord(a + 4)
			diff := (wp - rp)
			if diff == 0 {
				diff = 0x7fe
			}
			putWizWord(a, diff)
		}
		z = wizMem[a]

	case 0x0426, // RX RSR: Received size Register
		0x0526,
		0x0626,
		0x0726:
		wizTryRecvTCP(sockOf(a))
		z = wizMem[a]

	case 0x042A, // RX WR internal write pointer
		0x052A,
		0x062A,
		0x072A:
		wizTryRecvTCP(sockOf(a))
		z = wizMem[a]

	default:
		z = wizMem[a]
	}

	wizLog("WIZ:GET %04x -> %02x", a, z)
	return z
}

func wizLog(format string, args ...any) {
	if V['w'] {
		log.Printf("w| "+format, args...)
	}
}
