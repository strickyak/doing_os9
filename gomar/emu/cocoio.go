//go:build cocoio

package emu

import (
    "fmt"
	"log"
	"net"
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
	mode    byte
	status  byte
	conn    *net.UDPConn
}

var sock [4]*socket

var wizMem [1 << 16]byte
var wizAddr Word

const (
    TxFreeSize = 0x20
    TxRd = 0x22
    TxWr = 0x24
    RxRecvSize =  0x26
    RxRd = 0x28
    RxWr = 0x2A
)

func assert_w_gt(a Word, b Word) {
    if (a <= b) {
        log.Printf("*** ASSERT FAILED: %d > %d", a, b)
    }
}

func assert_w_lt(a Word, b Word) {
    if (a >= b) {
        log.Printf("*** ASSERT FAILED: %d < %d", a, b)
    }
}

func wizWord(reg Word) Word {
    hi := wizMem[reg]
    lo := wizMem[reg+1]
    return (Word(hi)<<8) + Word(lo)
}

func wizReset() {
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
        log.Panicf("cannot dialUDP: %v", err)
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
func wizGet(a Word) byte {
	switch a {
    default:
        return wizMem[a]
	}
}
func wizPutCommand(a Word, b byte) {
    base := a-1
    k := a >> 8;
    assert_w_lt(k, 4);
    txRing := 0x4000 + 0x800*k
    rxRing := 0x6000 + 0x800*k
    switch b {
    case 0x01: // open
        if sock[k].conn != nil {
            sock[k].conn.Close()
            sock[k].conn = nil
        }
        hostport := fmt.Sprintf(":%d", wizWord(base+0x04))
        sock[k].conn = listenUDP(hostport)
        
    case 0x10: // close
        if sock[k].conn != nil {
            sock[k].conn.Close()
            sock[k].conn = nil
        }
    case 0x20: { // send
            if wizMem[base] != 2 /*ProtocolModeUDP*/ {
                log.Panicf("sending on socket %d but not in UDP mode: $%x", k, wizMem[base])
            }
            begin := wizWord(base+TxRd)
            end := wizWord(base+TxWr)
            size := end - begin
            size &= 0x7ff      // 2K ring buffers.
            assert_w_gt(size, 2)  // reasonable for now
            assert_w_lt(size, 700)  // reasonable for now

            buf := make([]byte, size)
            p := begin
            for i := Word(0); i < size; i++ {
                p := (begin + i) & 0x7FF
                buf[i] = wizMem[p + txRing]
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
                panic(err);
            }
        }
    case 0x40: {// recv
        buf := make([]byte, 1500)
        size, addr, err := sock[k].conn.ReadFromUDP(buf)
        assert_w_gt(size, 2)  // reasonable for now
        assert_w_lt(size, 700)  // reasonable for now

        begin := wizWord(base+TxRd)
        end := wizWord(base+TxWr)
        gap := end - begin
        gap &= 0x7ff      // 2K ring buffers.
        assert_w_gt(gap, size);

        for i := 0; i < size; i++ {
            p = 0x7ff & (begin + Word(i))
            wizMem[rxRing + p] = buf[i]
        }

        // Set "interrupt" bit for RECV
      }
    }
}
func wizPut(a Word, b byte) {
	switch a {
    case 0x0401,
         0x0501,
         0x0601,
         0x0701:
        wizPutCommand(a, b)
    case 0x0401,
         0x0501,
         0x0601,
         0x0701:
        wizPutInterrupt(a, b)
    default:
        wizMem[a] = b
	}
}
