package emu

const info = `
F$Alarm x=time6ptr d=alarm_op -> x=same a=pid b=signal
F$AllRAM b=num_blocks -> start_block
F$Chain a=lang_type b=area_size x=name y=param_size_pages u=param_ptr
F$ClrBlk b=num_blocks u=first_addr
F$CmpNam b=len1 x=str1 y=str2
F$CpyMem d=dat x=offset y=byte_count u=dest
F$CRC x=addr y=byte_count u=crc3ptr
F$Debug a=function
F$DelBit d=first_bit_num x=map_addr y=num_bits
F$DelRAM b=num_blocks x=start_block_num
F$Exit b=status
F$Fork a=lang_type b=area_size x=name y=param_size_pages u=param_ptr
F$GBlkMp x=buf1024 -> d=bytes_per_block y=num_blocks



`

type Kern struct {
	a, b, d, x, y, u       string
	ra, rb, rd, rx, ry, ru string
}
