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
	/*
		txBegin Word
		txEnd   Word
		txRead  Word
		txWrite Word
		rxBegin Word
		rxEnd   Word
		rxRead  Word
		rxWrite Word
	*/
	mode   byte
	status byte
	conn   *net.UDPConn
}

var sock [4]*socket

func init() {
	for i := 0; i < 4; i++ {
		sock[i] = new(socket)
	}
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

func assert_w_gt(a Word, b Word) {
	if a <= b {
		log.Printf("*** ASSERT FAILED: %d > %d", a, b)
	}
}

func assert_w_lt(a Word, b Word) {
	if a >= b {
		log.Printf("*** ASSERT FAILED: %d < %d", a, b)
	}
}

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
	for _, s := range sock {
		if s.conn != nil {
			s.conn.Close()
			s.conn = nil
		}

		s.mode = 0
		s.status = 0

		/*
			s.txBegin = tx
			s.txRead = tx
			s.txWrite = tx
			tx += 2048 // Only support 2048 bytes/ring
			s.txEnd = tx

			s.rxBegin = rx
			s.rxRead = rx
			s.rxWrite = rx
			rx += 2048 // Only support 2048 bytes/ring
			s.rxEnd = rx
		*/
	}
}

func listenUDP(hostport string) *net.UDPConn {
	addy, err := net.ResolveUDPAddr("udp", hostport)
	if err != nil {
		log.Panicf("cannot ResolveUDPAddr: %v", err)
	}
	conn, err := net.ListenUDP("udp", addy)
	if err != nil {
		log.Panicf("cannot ListenUDP: %v", err)
	}
	return conn
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
		log.Panicf("Not a CocoIO addr: %x", a)
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
		log.Panicf("Not a CocoIO addr: %x", a)
	}
}
func wizPutStatus(a Word, b byte) {
	log.Panicf("Socket Status is a RO register: %x %x", a, b)
}
func wizPutInterrupt(a Word, b byte) {
	x := wizMem[a]
	x &^= b // clear the bits that are set in b.
	wizMem[a] = x
}
func wizPutCommand(a Word, b byte) {
	base := a - 1
	k := (a >> 8) - 4
	log.Printf("wizPutCommand a=%x b=%x base=%x k=%x; sock=%#v", a, b, base, k, sock)
	assert_w_lt(k, 4)
	txRing := 0x4000 + 0x800*k
	rxRing := 0x6000 + 0x800*k
	switch b {
	case 0x01:
		{ // open
			if wizMem[base] != 2 /*ProtocolModeUDP*/ {
				log.Panicf("sending on socket %d but not in UDP mode: $%x", k, wizMem[base])
			}

			if sock[k].conn != nil {
				sock[k].conn.Close()
				sock[k].conn = nil
			}
			hostport := fmt.Sprintf(":%d", wizWord(base+0x04))
			sock[k].conn = listenUDP(hostport)
			wizMem[3+base] = 0x22 // Status is SOCK_UDP.
			Ld("WIZ: UDP OPEN socket %d", k)
		}

	case 0x10:
		{ // close
			if sock[k].conn != nil {
				sock[k].conn.Close()
				sock[k].conn = nil
			}
			wizMem[3+base] = 0x00 // Status is SOCK_CLOSED.
			Ld("WIZ: UDP CLOSE socket %d", k)
		}
	case 0x20:
		{ // send
			if wizMem[base] != 2 /*ProtocolModeUDP*/ {
				log.Panicf("sending on socket %d but not in UDP mode: $%x", k, wizMem[base])
			}
			begin := wizWord(base + TxRd)
			end := wizWord(base + TxWr)
			size := end - begin
			size &= 0x7ff          // 2K ring buffers.
			assert_w_gt(size, 2)   // reasonable for now
			assert_w_lt(size, 700) // reasonable for now

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
			_, err = sock[k].conn.WriteToUDP(buf, addy)
			if err != nil {
				panic(err)
			}
			putWizWord(base+TxRd, end)
			// Set "interrupt" bit for SENDOK
			wizMem[base+2] |= (1 << 4) // SENDOK Interrupt Bit.
			Ld("WIZ: UDP SEND socket %d to %q size $%x", k, hostport, size)
		}
	case 0x40:
		{ // recv
			Ld("WIZ: UDP RECV socket %d", k)
			buf := make([]byte, 1500)
			size, addr, err := sock[k].conn.ReadFromUDP(buf)
			Ld("WIZ: UDP RECV socket %d got size $%x addr %v err $%x", k, size, addr, err)
			if err != nil {
				panic(err)
			}
			_ = addr                     // TODO use addr
			assert_w_gt(Word(size), 2)   // reasonable for now
			assert_w_lt(Word(size), 700) // reasonable for now

			begin := wizWord(base + TxRd)
			end := wizWord(base + TxWr)
			gap := end - begin
			gap &= 0x7ff // 2K ring buffers.
			assert_w_gt(gap, Word(size))

			for i := 0; i < size; i++ {
				p := 0x7ff & (begin + Word(i))
				wizMem[rxRing+p] = buf[i]
			}

			// Set "interrupt" bit for RECV
			wizMem[base+2] |= (1 << 2) // RECV Interrupt Bit.
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
	Ld("WIZ:PUT %04x <- %02x", a, b)
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

	case 0x0420,
		0x0520,
		0x0620,
		0x0720:
		z = 0x04 // Simulate 1K Tx free size (MSB)

	case 0x0421,
		0x0521,
		0x0621,
		0x0721:
		z = 0 // Simulate 1K Tx free size (LSB)

	case 0x0426,
		0x0526,
		0x0626,
		0x0726:
		z = 0x04 // Simulate 1K Rx free size (MSB)

	case 0x0427,
		0x0527,
		0x0627,
		0x0727:
		z = 0 // Simulate 1K Rx free size (LSB)

	default:
		z = wizMem[a]
	}

	Ld("WIZ:GET %04x -> %02x", a, z)
	return z
}
