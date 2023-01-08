//go:build !trace

package emu

func Dis_len(n Word)            {}
func Dis_len_incr(n Word)       {}
func TraceByte(addr EA, x byte) {}
func TraceWord(addr EA, x Word) {}
func Trace()                    {}
func Finish() {
	DoDumpAllMemoryPhys()
}
func Dis_inst(inst string, reg string, cyclecount int)   {}
func Dis_inst_cat(inst string, cyclecount int)           {}
func Dis_ops(part1 string, part2 string, cyclecount int) {}
func Dis_reg(b byte)                                     {}

func DumpAllMemory()    {}
func DumpPageZero()     {}
func DumpProcesses()    {}
func DumpAllPathDescs() {}

//func LogIO(f string, args ...interface{}) {}

func EarlyAction() bool { return false }
