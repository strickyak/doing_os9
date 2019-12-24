// +build display

package display

import (
	"image"
	"image/color"
	"log"
	"math"
	"os"
	"runtime"
	"runtime/pprof"
	"time"

	"github.com/tfriedel6/canvas"
	"github.com/tfriedel6/canvas/sdlcanvas"
)

func NewDisplay(mem []byte, numCols, numRows int, cocod <-chan *CocoDisplayParams, inkey chan<- byte) *Display {
	d := &Display{
		Mem:     mem,
		Rows:    make([][]byte, numRows),
		NumRows: numRows,
		NumCols: numCols,
		Cocod:   cocod,
		Inkey:   inkey,
	}
	for i := 0; i < numRows; i++ {
		d.Rows[i] = make([]byte, numCols)
	}
	go d.Loop()
	return d
}

func (d *Display) PutChar(b byte) {
	if b == 9 {
		b = 32
	}
	if b == 10 || b == 13 {
		d.x = d.NumCols // Move to end to force CR.
	} else {
		if b < 32 || b > 127 {
			return
		}

		d.Rows[d.y][d.x] = b
		d.x++
	}

	if d.x == d.NumCols {
		d.x = 0
		d.y++
	}
	if d.y == d.NumRows {
		for i := 0; i < d.NumRows-1; i++ {
			d.Rows[i] = d.Rows[i+1]
		}
		d.Rows[d.NumRows-1] = make([]byte, d.NumCols)
		d.y--
	}
}

func (d *Display) Loop() {
	var coco *CocoDisplayParams
	var ft *canvas.Font
	w, h := float64(WIDTH), float64(HEIGHT) // Used portion of canvas.

	wnd, cv, err := sdlcanvas.CreateWindow(WIDTH, HEIGHT, "GOMAR")
	if err != nil {
		log.Fatalf("cannot selcanvas.CreateWindow: %v", err)
		return
	}
	defer wnd.Destroy()

	wnd.MouseMove = func(x, y int) {
		mx, my := float64(x)/w, float64(y)/h
		MouseMutex.Lock()
		MouseX, MouseY = mx, my
		MouseMutex.Unlock()
	}
	wnd.MouseDown = func(button, x, y int) {
		MouseMutex.Lock()
		MouseDown = true
		MouseMutex.Unlock()
	}
	wnd.MouseUp = func(button, x, y int) {
		MouseMutex.Lock()
		MouseDown = false
		MouseMutex.Unlock()
	}
	wnd.KeyUp = func(scancode int, rn rune, name string) {
		println("KeyUp", scancode, rn, name)
		switch name {
		case "ControlLeft", "ControlRight":
			d.ctrl = false
		}
	}
	wnd.KeyDown = func(scancode int, rn rune, name string) {
		println("KeyDown", scancode, rn, name)
		switch name {
		case "Escape":
			wnd.Close()
			log.Panic("\n*Escape*")
		case "Delete", "Backspace":
			d.Inkey <- 8
			d.PutChar('#')
		case "Enter":
			d.Inkey <- 13
			d.PutChar(13)
		case "ControlLeft", "ControlRight":
			d.ctrl = true
		}
		if d.ctrl && 64 <= rn && rn < 96 {
			x := byte(rn) & 31 // control chars
			d.Inkey <- x
			d.PutChar(x)
		}
	}
	wnd.KeyChar = func(rn rune) {
		println("KeyChar", rn)
		d.Inkey <- byte(rn)
		d.PutChar(byte(rn))
	}

	var z *image.RGBA
	var zxlen, zylen int

	wnd.MainLoop(func() {
		var err error
		time.Sleep(20 * time.Millisecond)

	SelectLoop:
		for {
			select {
			case tmp := <-d.Cocod:
				coco = tmp
				continue
			default:
				break SelectLoop
			}
		}
		if coco == nil {
			log.Printf("DISPLAY: coco: nil")
		} else {
			log.Printf("DISPLAY: coco: %#v", *coco)
		}

		// Clear the screen
		cv.SetFillStyle("#000")
		cv.FillRect(0, 0, float64(WIDTH), float64(HEIGHT))

		// yak: TRY FONTS
		if ft == nil {
			ft, err = cv.LoadFont(*FONT)
			if err != nil {
				log.Fatalf("cannot LoadFont %q: %v", *FONT, err)
			}
			//_ = ft
			log.Printf("LoadFont: %q: (%T) %v", *FONT, ft, ft)
		}
		cv.SetFont(ft, *SIZE)
		cv.SetFillStyle("#F0F")

		if coco != nil && coco.Graphics {
			// Graphics
			const N = 4
			p := coco.VirtOffsetAddr
			bpr := coco.GraphicsBytesPerRow
			colorBits := coco.GraphicsColorBits

			xlen := (8 * bpr) / colorBits
			ylen := coco.LinesPerField
			if z == nil || xlen != zxlen || ylen != zylen {
				z = image.NewRGBA(image.Rect(0, 0, N*xlen, N*ylen))
				zxlen, zylen = xlen, ylen
			}
			// For interpreting mouse position:
			w, h = float64(N*xlen), float64(N*ylen)

			shift := 8 - colorBits
			mask := ^(byte(0xFF) << uint(colorBits))
			for y := 0; y < coco.LinesPerField; y++ {
				endRow := p + bpr
				m := d.Mem[p]
				// for x := 0; x < xlen; x++ ///
				for x := 0; p < endRow; x++ {
					pixel := (m >> uint(shift)) & mask
					// log.Printf("DISPLAY: y=%x x=%x p=%x shift=%x mask=%x pixel=%x", y, x, p, shift, mask, pixel)
					shift -= colorBits
					if shift < 0 {
						shift = 8 - colorBits
						mask = ^(byte(0xFF) << uint(colorBits))
						p++
						m = d.Mem[p]
					}
					clr := coco.ColorMap[pixel]
					r := ((clr & 0x20) >> 4) | ((clr & 0x04) >> 2)
					g := ((clr & 0x10) >> 3) | ((clr & 0x02) >> 1)
					b := ((clr & 0x08) >> 2) | ((clr & 0x01) >> 0)
					// log.Printf("DISPLAY:   clr=%x r=%x g=%x b=%", clr, r, g, b)
					colour := color.RGBA{r << 6, g << 6, b << 6, 255}
					for j := 0; j < N; j++ {
						for i := 0; i < N; i++ {
							z.SetRGBA(x*N+i, y*N+j, colour)
						}
					}
				}
				if p != endRow {
					log.Fatalf("p=%x endRow=%x len=%x,%x %x,%x,%x,%x", p, endRow, xlen, ylen, bpr, colorBits, shift, mask)
				}
			}
			cv.DrawImage(z, 0, 0)
		} else {
			// Alpha
			for y := 0; y < d.NumRows; y++ {
				cv.FillText(string(d.Rows[y]), 10, float64((y+1)*30))
			}
		}

		{ // draw mouse
			if MouseDown {
				cv.SetStrokeStyle("#F33")
			} else {
				cv.SetStrokeStyle("#33F")
			}
			cv.SetLineWidth(3)
			cv.BeginPath()
			cv.Arc(MouseX*w, MouseY*h, 10, 0, math.Pi*2, false)
			cv.Stroke()
		}

		runtime.GC()
	})
}
