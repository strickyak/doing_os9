// Try to decode the image.
// Write the image with chosen points if --image_out=filename.
//
// Usage:
//   $ go run hack.go -image_out out.chosen_points.png < marko-barcode-to-decode-threshold.png > out.txt
//
package main

import (
	"flag"
	"fmt"
	"image"
	"image/color"
	"image/png"
	// "log"
	"os"
)

var a = flag.Float64("a", 10, "horz start for points")
var b = flag.Float64("b", 21.14285, "horz step for points")
var c = flag.Float64("c", 10, "vert start for points")
var d = flag.Float64("d", 22.51, "vert step for points")

var image_out = flag.String("image_out", "", "write PNG showing points to this file")

func main() {
	flag.Parse()
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
			var row []rune
			countZeros := 0
			countOnes := 0
			for i := *a; i < w; i += *b {
				red, _, _, _ := img.At(int(i), int(j)).RGBA()
				ch := '-'
				if red > 0x8000 {
					ch = '1'
					countOnes++
				} else {
					countZeros++
				}
				fmt.Printf("%c", ch)
				row = append(row, ch)

				for ii := -1; ii <= 1; ii++ {
					for jj := -1; jj <= 1; jj++ {
						t.Set(int(i)+ii, int(j)+jj, green)
					}
				}
			}

			fmt.Printf("  %2d,%2d  ", countOnes, countZeros)
			n := len(row)
			for i := n - 1; i >= 0; i-- {
				fmt.Printf("%c", row[i])
			}

			fmt.Printf("  ")
			flawed := false
			for i := 0; i < n; i += 2 {
				switch {
				case row[i] == '1' && row[i+1] != '1':
					fmt.Printf("1")
				case row[i] != '1' && row[i+1] == '1':
					fmt.Printf("-")
				default:
					fmt.Printf("#")
					flawed = true
				}
				switch i {
				case 0, 18: // Just guessing how they might be split
					fmt.Printf(" ")
				}
			}
			if !flawed {
				for i := 0; i < n; i += 2 {
					switch {
					case row[i] == '1' && row[i+1] != '1':
						countVert[i/2] += 1
					}
				}
			}

			countOnes = 0
			fmt.Printf("  ")
			for i := n - 2; i >= 0; i -= 2 {
				switch {
				case row[i] == '1' && row[i+1] != '1':
					fmt.Printf("1")
					if i > 0 { // Skip [0] which alternates 1/0 like a sync signal.
						countOnes++
					}
				case row[i] != '1' && row[i+1] == '1':
					fmt.Printf("-")
				default:
					fmt.Printf("#")
				}
			}

			fmt.Printf("  %2d  %d\n", countOnes, countOnes&1)
		}
	}

	fmt.Printf("\n")
	for i, e := range countVert {
		fmt.Printf("[%2d]: %2d\n", i, e)
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
}
