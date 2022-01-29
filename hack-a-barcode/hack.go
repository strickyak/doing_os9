// Try to decode the image.
// Write the image with chosen points if --image_out=filename.
//
// Usage:
//   $ go run hack.go -hex_out=out.hex -bin_out=out.bin  < marko-barcode-to-decode-threshold.png > out.txt
//
package main

import (
	"flag"
	. "fmt"
	"image"
	"image/color"
	"image/png"
	// "log"
	"os"
)

var a = flag.Float64("a", 10, "horz start for points")
var b = flag.Float64("b", 21.14285, "horz stride for points")
var c = flag.Float64("c", 10, "vert start for points")
var d = flag.Float64("d", 22.51, "vert stride for points")

var image_out = flag.String("image_out", "", "write image showing points to this PNG file")
var hex_out = flag.String("hex_out", "", "write decoded hex to this text file")
var bin_out = flag.String("bin_out", "", "write decoded binary to this file")
var wHex *os.File
var wBin *os.File

const badByte = 0x00

func main() {
	var err error
	flag.Parse()

	if *hex_out != "" {
		wHex, err = os.Create(*hex_out)
		if err != nil {
			panic(err)
		}
	}

	if *bin_out != "" {
		wBin, err = os.Create(*bin_out)
		if err != nil {
			panic(err)
		}
	}

	img, _, err := image.Decode(os.Stdin)
	if err != nil {
		panic(err)
	}
	// log.Printf("type %T", img)

	w := float64(img.Bounds().Max.X)
	h := float64(img.Bounds().Max.Y)

	countVert := make([]int, 19)

	switch t := img.(type) {
	case *image.NRGBA:
		green := img.ColorModel().Convert(color.RGBA{0, 255, 0, 255})

		for j := *c; j < h; j += *d {
			var row []int
			countZeros := 0
			countOnes := 0
			for i := *a; i < w; i += *b {
				red, _, _, _ := img.At(int(i), int(j)).RGBA()
				if red > 0x8000 {
					Printf("1")
					countOnes++
					row = append(row, 1)
				} else {
					Printf("-")
					countZeros++
					row = append(row, 0)
				}

				for ii := -1; ii <= 1; ii++ {
					for jj := -1; jj <= 1; jj++ {
						t.Set(int(i)+ii, int(j)+jj, green)
					}
				}
			}

			Printf("  %2d,%2d  ", countOnes, countZeros)

			Printf("  ")
			flawed := false
			bits := make([]int, len(row)/2)
			for i := 0; i < len(row); i += 2 {
				switch {
				case row[i] == 1 && row[i+1] != 1:
					Printf("1")
					bits[i/2] = 1
				case row[i] != 1 && row[i+1] == 1:
					Printf("-")
				default:
					Printf("#")
					flawed = true
				}
				switch i {
				case 0, // After the vertical sync
					2,  // After the left parity
					18, // Between the 2 bytes
					34: // Before the right parity
					Printf(" ")
				}
			}
			if flawed {
				output(badByte)
				output(badByte)
				Printf(" <<< FLAWED dibits >>>\n")
				continue
			}

			for i := 0; i < len(row); i += 2 {
				switch {
				case row[i] == 1 && row[i+1] != 1:
					countVert[i/2] += 1
				}
			}

			countOnes = 0
			Printf("  ")

			{
				// Reverse engineering where the bytes are and how the parity works:
				// https://www.insentricity.com/a.cl/265/encoding-software-in-barcodes-the-eight-bit-magazine-way
				leftCheck := bits[1]
				rightCheck := bits[18]
				leftParity, rightParity := 0, 0
				byte0, byte1 := 0, 0
				for i := 0; i < 8; i++ {
					byte0 = (byte0 << 1) | bits[2+i]
					byte1 = (byte1 << 1) | bits[10+i]

					switch i & 1 { // `i` counts L to R; bits are usually counted R to L; so cases are reversed.
					case 0:
						rightParity += bits[2+i] + bits[10+i]
					case 1:
						leftParity += bits[2+i] + bits[10+i]
					}
				}
				Printf("left(%d=%d) right(%d=%d)", leftCheck, leftParity&1, rightCheck, rightParity&1)

				if leftCheck != leftParity&1 || rightCheck != rightParity&1 {
					flawed = true
				}
				if flawed {
					output(badByte)
					output(badByte)
					Printf(" <<< FLAWED parity >>>\n")
					continue
				}
				output(byte0)
				output(byte1)
			}

			Printf("\n")
		}
	}

	Printf("\n")
	for i, e := range countVert {
		Printf("[%2d]: %2d\n", i, e)
	}

	if *image_out != "" {
		w, err := os.Create(*image_out)
		if err != nil {
			panic(err)
		}
		if err = png.Encode(w, img); err != nil {
			panic(err)
		}
		err = w.Close()
		if err != nil {
			panic(err)
		}
	}

	if wHex != nil {
		Fprintf(wHex, "\n")
		wHex.Close()
	}
	if wBin != nil {
		wBin.Close()
	}
}

var countBytes int
var countZeros int

func output(b int) {
	{ // Text output
		char := ' '
		if 32 <= b && b <= 126 {
			char = rune(b)
		}
		Printf(" out: %02x |%c| ", b, char)
	}

	{ // Hex output
		if wHex != nil {
			if countBytes&15 == 15 {
				Fprintf(wHex, "%02x\n", b)
			} else {
				Fprintf(wHex, "%02x ", b)
			}
			countBytes++
		}
	}

	{ // Binary output
		if countZeros >= 3 {
			// If we've seen three zeros already, we have triggered, and can write.
			_, err := wBin.Write([]byte{byte(b)})
			if err != nil {
				panic(err)
			}
		}
		if b == 0 {
			countZeros++
		}
	}
}
