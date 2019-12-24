package display

import (
	"flag"
)

var FONT = flag.String("font", "/home/strick/go/src/golang.org/x/image/font/gofont/ttfs/Go-Mono.ttf", ".ttf font file")
var SIZE = flag.Float64("fontsize", 25, "font size")

type CocoDisplayParams struct {
	Gime                     bool // else use VDG
	Graphics                 bool // else use Alpha
	AttrsIfAlpha             bool // if every other byte is attrs
	VirtOffsetAddr           int  // Start of data.
	HorzOffsetAddr           int
	VirtScroll               int
	LinesPerField            int
	LinesPerCharRow          int
	Monochrome               bool
	HRES                     int
	CRES                     int
	HVEN                     bool
	GraphicsBytesPerRow      int
	GraphicsColorBitsPerByte int
	AlphaCharsPerRow         int
	AlphaHasAttrs            bool
	ColorMap                 [16]byte
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
