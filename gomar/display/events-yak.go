// +build main

// but first: $ sudo apt-get install libsdl2-dev
package main

import (
	"flag"
	"log"
	"math"
	"time"

	"github.com/tfriedel6/canvas"
	"github.com/tfriedel6/canvas/sdlcanvas"
)

var FONT = flag.String("f", "Go-Mono.ttf", ".ttf font file")
var SIZE = flag.Float64("s", 25, "font size")

type circle struct {
	x, y  float64
	color string
}

func main() {
	flag.Parse()
	// wnd, cv, err := sdlcanvas.CreateWindow(1280, 720, "Canvas Example")
	wnd, cv, err := sdlcanvas.CreateWindow(1230, 770, "Canvas Example")
	if err != nil {
		log.Println(err)
		return
	}
	defer wnd.Destroy()

	var mx, my, action float64
	circles := make([]circle, 0, 100)

	wnd.MouseMove = func(x, y int) {
		mx, my = float64(x), float64(y)
	}
	wnd.MouseDown = func(button, x, y int) {
		action = 1
		circles = append(circles, circle{x: mx, y: my, color: "#F00"})
	}
	wnd.KeyDown = func(scancode int, rn rune, name string) {
		switch name {
		case "Escape":
			wnd.Close()
		case "Space":
			action = 1
			circles = append(circles, circle{x: mx, y: my, color: "#0F0"})
		case "Enter":
			action = 1
			circles = append(circles, circle{x: mx, y: my, color: "#00F"})
		}
	}

	lastTime := time.Now()

	var ft *canvas.Font

	once := true
	wnd.MainLoop(func() {
		var err error
		now := time.Now()
		diff := now.Sub(lastTime)
		lastTime = now
		action -= diff.Seconds() * 3
		action = math.Max(0, action)

		w, h := float64(cv.Width()), float64(cv.Height())

		// Clear the screen
		cv.SetFillStyle("#000")
		cv.FillRect(0, 0, w, h)

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
		// cv.SetFont(*FONT, *SIZE)

		// cv.SetStrokeStyle("#F0F")
		//cv.SetLineWidth(*SIZE)
		// cv.StrokeText("abcdefg", 50, 50)
		cv.SetFillStyle("#F0F")
		line80 := "ABCDEFGHIJabcdeypqij !1+23-|^*67/89 A_C_E_G|I/K\\MNOPQRSTUVWXYZ !@#$%^&*()={}[]PQ"
		for i := 0; i < 25; i++ {
			cv.FillText(line80, 15, (float64(i)+1)*30)
		}
		if once {
			log.Printf("MeasureText: %v\n", cv.MeasureText(line80))
			once = false
		}

		// Draw a circle around the cursor
		cv.SetStrokeStyle("#F00")
		cv.SetLineWidth(6)
		cv.BeginPath()
		cv.Arc(mx, my, 24+action*24, 0, math.Pi*2, false)
		cv.Stroke()

		// Draw circles where the user has clicked
		for _, circle := range circles {
			cv.SetFillStyle(circle.color)
			cv.BeginPath()
			cv.Arc(circle.x, circle.y, 24, 0, math.Pi*2, false)
			cv.Fill()
		}
	})
}
