package display

import (
	"flag"
	"sync"
)

var FONT = flag.String("font", "/home/strick/go/src/golang.org/x/image/font/gofont/ttfs/Go-Mono.ttf", ".ttf font file")
var SIZE = flag.Float64("fontsize", 25, "font size")

// Emulator hard window size.
const WIDTH = 1280 + 20
const HEIGHT = 800 + 20

// Global vars describing mouse state.
var MouseX, MouseY float64 // 0 to 1
var MouseDown bool
var MouseMutex sync.Mutex

type CocoDisplayParams struct {
	Gime                bool // else use VDG
	Graphics            bool // else use Alpha
	AttrsIfAlpha        bool // if every other byte is attrs
	VirtOffsetAddr      int  // Start of data.
	HorzOffsetAddr      int
	VirtScroll          int
	LinesPerField       int
	LinesPerCharRow     int
	Monochrome          bool
	HRES                int
	CRES                int
	HVEN                bool
	GraphicsBytesPerRow int
	GraphicsColorBits   int
	AlphaCharsPerRow    int
	AlphaHasAttrs       bool
	ColorMap            [16]byte
}

type Display struct {
	Mem     []byte
	Rows    [][]byte
	NumRows int
	NumCols int
	Cocod   <-chan *CocoDisplayParams
	Inkey   chan<- byte
	x, y    int
	ctrl    bool
}
