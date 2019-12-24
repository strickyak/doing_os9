// +build !display

package display

func NewDisplay(mem []byte, numCols, numRows int, cocod <-chan *CocoDisplayParams, inkey chan<- byte) *Display {
	go func() {
		for {
			<-cocod
		}
	}()
	return nil
}
func (mon *Display) PutChar(b byte) {}
