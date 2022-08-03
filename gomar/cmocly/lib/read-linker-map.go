package lib

import (
	"bufio"
	"log"
	"os"
	"regexp"
    "strings"
)

type LinkerMapRecord struct {
	Section  string
	Symbol   string
	Filename string
	Start    int
	Length   int
}

func BasenamesOfLinkerMap(lmap []*LinkerMapRecord) []string {
	// Dedup with a map.
	names := make(map[string]bool)
	for _, rec := range lmap {
		if rec.Section != "" {
			// names[Basename(rec.Filename)] = true
			names[rec.Filename] = true
            log.Printf("LMAP REC SECTION: %q %q", rec.Filename, rec.Section)
		}
	}
	// Convert to a slice.
	var vec []string
	for name := range names {
		vec = append(vec, name)
	}
	return vec
}

func FixMapName(mapname string) {
    log.Printf("FixMapName: considering %q", mapname);
    trimmed := strings.TrimSuffix(mapname, ".map")
    if strings.Contains(trimmed, ".") {
        // Rename the .map, as from "f.map" to "f.dig.map"
        front := strings.Split(trimmed, ".")[0]
        front_mapname := front + ".map"
        log.Printf("RENAME %q -> %q", front_mapname, mapname);
        err := os.Rename(front_mapname, mapname)
        if err != nil {
            log.Printf("RENAME ERROR: %v", err);
        }
        // Rename the .link, as from "f.link" to "f.dig.link"
        linkname := trimmed + ".link"
        front_linkname := front + ".link"
        log.Printf("RENAME %q -> %q", front_linkname, linkname);
        err = os.Rename(front_linkname, linkname)
        if err != nil {
            log.Printf("RENAME ERROR: %v", err);
        }
    }
}

func ReadLinkerMap(filename string) []*LinkerMapRecord {
	log.Printf("ENTER ReadLinkerMap %q", filename)

    /*
      Here we might do an ugly hack:
      With -o x.sprintf the map gets created at x.map
      instead of at x.sprintf.map.
    */
    FixMapName(filename)

	fd, err := os.Open(filename)
	if err != nil {
		log.Fatalf("ReadLinkerMap: Cannot open %q: %v", filename, err)
	}
	sc := bufio.NewScanner(fd)
	var z []*LinkerMapRecord
	for sc.Scan() {
		line := sc.Text()
		{
			m := matchSection.FindStringSubmatch(line)
			if m != nil {
				z = append(z, &LinkerMapRecord{
					Section:  m[1],
					Filename: m[2],
					Start:    parseHex(m[3]),
					Length:   parseHex(m[4]),
				})
				continue
			}
		}
		{
			m := matchSymbol.FindStringSubmatch(line)
			if m != nil {
				z = append(z, &LinkerMapRecord{
					Symbol:   m[1],
					Filename: m[2],
					Start:    parseHex(m[3]),
				})
				continue
			}
		}
		log.Fatalf("ReadLinkerMap: unknown line: %q", line)
	}
	if err = sc.Err(); err != nil {
		log.Fatalf("ReadLinkerMap: while reading %q: %v", filename, err)
	}
	return z
}

var matchSection = regexp.MustCompile(
	`Section: ([[:word:]]+) [(](.+)[)] load at ([[:xdigit:]]+), length ([[:xdigit:]]+)`)

var matchSymbol = regexp.MustCompile(
	`^Symbol: ([^ ]+) [(](.+)[)] = ([[:xdigit:]]+)`)

/* DEMO input file:
Section: start (temp.o) load at 000D, length 0012
Section: code (crt.os9_o) load at 001F, length 0111
Section: code (negateDWord.os9_o) load at 0130, length 0018
Section: code (sub32.os9_o) load at 0148, length 0021
Section: code (sub32xu.os9_o) load at 0169, length 0012
Section: code (ATOW.os9_o) load at 017B, length 0038
Section: code (dwtoa.os9_o) load at 01B3, length 00BD
Section: code (printf.os9_o) load at 0270, length 0393
Section: code (putchar_a.os9_o) load at 0603, length 0006
Section: code (strlen.os9_o) load at 0609, length 0011
Section: code (temp.o) load at 061A, length 02C3
Section: code (defs.o) load at 08DD, length 021C
Section: code (octet.o) load at 0AF9, length 0BA4
Section: constructors_start (crt.os9_o) load at 169D, length 0000
Section: constructors_end (crt.os9_o) load at 169D, length 0001
Section: destructors_start (crt.os9_o) load at 169E, length 0000
Section: destructors_end (crt.os9_o) load at 169E, length 0001
Section: initgl_start (temp.o) load at 169F, length 0000
Section: initgl (temp.o) load at 169F, length 0000
Section: initgl (defs.o) load at 169F, length 0135
Section: initgl (octet.o) load at 17D4, length 0000
Section: initgl_end (temp.o) load at 17D4, length 0001
Section: rodata (temp.o) load at 17D5, length 015A
Section: rodata (defs.o) load at 192F, length 0171
Section: rodata (octet.o) load at 1AA0, length 033C
Section: rwdata (temp.o) load at 0001, length 0000
Section: rwdata (defs.o) load at 0001, length 0000
Section: rwdata (octet.o) load at 0001, length 0000
Section: bss (crt.os9_o) load at 0001, length 0022
Section: bss (temp.o) load at 0023, length 4E22
Section: bss (defs.o) load at 4E45, length 004E
Section: bss (octet.o) load at 4E93, length 0024
Symbol: \02bss (crt.os9_o) = 0001
Symbol: \02bss (defs.o) = 4E45
Symbol: \02bss (octet.o) = 4E93
Symbol: \02bss (temp.o) = 0023
Symbol: \02code (ATOW.os9_o) = 017B
Symbol: \02code (crt.os9_o) = 001F
Symbol: \02code (defs.o) = 08DD
Symbol: \02code (dwtoa.os9_o) = 01B3
Symbol: \02code (negateDWord.os9_o) = 0130
Symbol: \02code (octet.o) = 0AF9
Symbol: \02code (printf.os9_o) = 0270
Symbol: \02code (putchar_a.os9_o) = 0603
Symbol: \02code (strlen.os9_o) = 0609
Symbol: \02code (sub32.os9_o) = 0148
Symbol: \02code (sub32xu.os9_o) = 0169
Symbol: \02code (temp.o) = 061A
Symbol: \02constructors_end (crt.os9_o) = 169D
Symbol: \02constructors_start (crt.os9_o) = 169D
Symbol: \02destructors_end (crt.os9_o) = 169E
Symbol: \02destructors_start (crt.os9_o) = 169E
Symbol: \02initgl (defs.o) = 169F
Symbol: \02initgl (octet.o) = 17D4
Symbol: \02initgl (temp.o) = 169F
Symbol: \02initgl_end (temp.o) = 17D4
Symbol: \02initgl_start (temp.o) = 169F
Symbol: \02rodata (defs.o) = 192F
Symbol: \02rodata (octet.o) = 1AA0
Symbol: \02rodata (temp.o) = 17D5
Symbol: \02rwdata (defs.o) = 0001
Symbol: \02rwdata (octet.o) = 0001
Symbol: \02rwdata (temp.o) = 0001
Symbol: \02start (temp.o) = 000D
Symbol: @checkPadding\0130 (printf.os9_o) = 0391
Symbol: @countHexDigitsInDWord\0130 (printf.os9_o) = 03B8
Symbol: @decPadPrint\0130 (printf.os9_o) = 0429
Symbol: @decPadding\0130 (printf.os9_o) = 0409
Symbol: @done\0130 (printf.os9_o) = 03D1
Symbol: @done\0139 (crt.os9_o) = 0055
Symbol: @done\0140 (crt.os9_o) = 0060
Symbol: @done\0145 (crt.os9_o) = 00A6
Symbol: @eol\0144 (crt.os9_o) = 0096
Symbol: @findArgEnd\0144 (crt.os9_o) = 0082
Symbol: @findArgStart\0144 (crt.os9_o) = 0071
Symbol: @foundArgEnd\0144 (crt.os9_o) = 008C
Symbol: @hexPad\0130 (printf.os9_o) = 03DC
Symbol: @highNybbleNotNull\0130 (printf.os9_o) = 03CD
Symbol: @highWordZero\0130 (printf.os9_o) = 03FF
Symbol: @longNotNeg\0130 (printf.os9_o) = 036B
Symbol: @loop\0139 (crt.os9_o) = 004D
Symbol: @nextDWordByte\0130 (printf.os9_o) = 03B9
Symbol: @noHexPadding\0130 (printf.os9_o) = 03E8
Symbol: @noMinusNeeded\0130 (printf.os9_o) = 0422
Symbol: @noPadding\0130 (printf.os9_o) = 0434
Symbol: @nonNullByte\0130 (printf.os9_o) = 03C4
Symbol: @oneDigitNeeded\0130 (printf.os9_o) = 03CF
Symbol: @printCond\0130 (printf.os9_o) = 03AB
Symbol: @printLoop\0130 (printf.os9_o) = 03A7
Symbol: @slong\0130 (printf.os9_o) = 035E
Symbol: @ulong\0130 (printf.os9_o) = 036B
Symbol: @xlong\0130 (printf.os9_o) = 03D2
Symbol: @zero\0140 (crt.os9_o) = 005A
Symbol: ATOW (ATOW.os9_o) = 017B
Symbol: ATW100 (ATOW.os9_o) = 017F
Symbol: ATW900 (ATOW.os9_o) = 019E
Symbol: CHROUT (crt.os9_o) = 0005
Symbol: E$MemFul (crt.os9_o) = 00EE
Symbol: HEXDIG (printf.os9_o) = 057E
Symbol: INILIB (crt.os9_o) = 001F
Symbol: INISTK (crt.os9_o) = 0001
Symbol: INITGL (temp.o) = 169F
Symbol: L00074 (octet.o) = 15C0
Symbol: L00077 (octet.o) = 0E45
Symbol: L00080 (octet.o) = 0C3E
Symbol: L00083 (octet.o) = 137F
Symbol: L00089 (octet.o) = 1403
Symbol: L00113 (temp.o) = 0742
Symbol: L00114 (temp.o) = 0740
Symbol: L00123 (temp.o) = 0762
Symbol: L00124 (temp.o) = 0760
Symbol: L00133 (temp.o) = 0786
Symbol: L00134 (octet.o) = 0B2C
Symbol: L00134 (temp.o) = 0784
Symbol: L00137 (octet.o) = 0B52
Symbol: L00140 (octet.o) = 0B7A
Symbol: L00143 (octet.o) = 0C30
Symbol: L00143 (temp.o) = 07A6
Symbol: L00144 (temp.o) = 07A4
Symbol: L00148 (octet.o) = 0C11
Symbol: L00149 (octet.o) = 0C0F
Symbol: L00153 (temp.o) = 07FB
Symbol: L00154 (temp.o) = 07F9
Symbol: L00156 (octet.o) = 0C62
Symbol: L00159 (octet.o) = 0C81
Symbol: L00161 (defs.o) = 09D2
Symbol: L00162 (defs.o) = 09D0
Symbol: L00163 (temp.o) = 081F
Symbol: L00164 (temp.o) = 081D
Symbol: L00165 (octet.o) = 0CCB
Symbol: L00166 (octet.o) = 0CC9
Symbol: L00171 (defs.o) = 0AF1
Symbol: L00172 (defs.o) = 0AEF
Symbol: L00173 (temp.o) = 0843
Symbol: L00174 (temp.o) = 0841
Symbol: L00175 (octet.o) = 0D02
Symbol: L00176 (octet.o) = 0D00
Symbol: L00182 (octet.o) = 0D21
Symbol: L00183 (temp.o) = 0867
Symbol: L00184 (temp.o) = 0865
Symbol: L00185 (octet.o) = 0D31
Symbol: L00188 (octet.o) = 0D3D
Symbol: L00194 (octet.o) = 0D73
Symbol: L00195 (octet.o) = 0D71
Symbol: L00201 (octet.o) = 0DD7
Symbol: L00204 (octet.o) = 0DE5
Symbol: L00210 (octet.o) = 0E80
Symbol: L00211 (octet.o) = 0E7E
Symbol: L00220 (octet.o) = 0EAC
Symbol: L00221 (octet.o) = 0EAA
Symbol: L00230 (octet.o) = 0EDA
Symbol: L00231 (octet.o) = 0ED8
Symbol: L00240 (octet.o) = 0F08
Symbol: L00241 (octet.o) = 0F06
Symbol: L00250 (octet.o) = 0F3D
Symbol: L00251 (octet.o) = 0F3B
Symbol: L00256 (octet.o) = 0F92
Symbol: L00257 (octet.o) = 1022
Symbol: L00260 (octet.o) = 0FF5
Symbol: L00261 (octet.o) = 1019
Symbol: L00263 (octet.o) = 1075
Symbol: L00266 (octet.o) = 107E
Symbol: L00269 (octet.o) = 1087
Symbol: L00272 (octet.o) = 1090
Symbol: L00274 (octet.o) = 112A
Symbol: L00275 (octet.o) = 113E
Symbol: L00278 (octet.o) = 115B
Symbol: L00279 (octet.o) = 11FE
Symbol: L00281 (octet.o) = 1192
Symbol: L00282 (octet.o) = 11DC
Symbol: L00284 (octet.o) = 11F5
Symbol: L00285 (octet.o) = 1276
Symbol: L00286 (octet.o) = 128A
Symbol: L00290 (octet.o) = 12F4
Symbol: L00293 (octet.o) = 130C
Symbol: L00296 (octet.o) = 137F
Symbol: L00297 (octet.o) = 1341
Symbol: L00298 (octet.o) = 1376
Symbol: L00302 (octet.o) = 136F
Symbol: L00304 (octet.o) = 136F
Symbol: L00308 (octet.o) = 1397
Symbol: L00309 (octet.o) = 1399
Symbol: L00310 (octet.o) = 13A0
Symbol: L00311 (octet.o) = 13A2
Symbol: L00312 (octet.o) = 13AA
Symbol: L00313 (octet.o) = 13E3
Symbol: L00317 (octet.o) = 13BD
Symbol: L00320 (octet.o) = 13CF
Symbol: L00323 (octet.o) = 13F6
Symbol: L00326 (octet.o) = 1401
Symbol: L00328 (octet.o) = 1416
Symbol: L00329 (octet.o) = 1430
Symbol: L00333 (octet.o) = 1463
Symbol: L00336 (octet.o) = 1525
Symbol: L00337 (octet.o) = 14F0
Symbol: L00338 (octet.o) = 151B
Symbol: L00341 (octet.o) = 1543
Symbol: L00342 (octet.o) = 1597
Symbol: L00343 (octet.o) = 15AE
Symbol: L00347 (octet.o) = 15AC
Symbol: L00349 (octet.o) = 160B
Symbol: L00350 (octet.o) = 15F5
Symbol: L00351 (octet.o) = 15DD
Symbol: L00352 (octet.o) = 15DF
Symbol: L00353 (octet.o) = 15EE
Symbol: L00354 (octet.o) = 15F0
Symbol: L00355 (octet.o) = 1604
Symbol: L00356 (octet.o) = 1606
Symbol: L00358 (octet.o) = 166A
Symbol: L00363 (octet.o) = 163E
Symbol: L00364 (octet.o) = 163C
Symbol: L00373 (octet.o) = 166A
Symbol: L00374 (octet.o) = 1668
Symbol: L00380 (octet.o) = 1681
Symbol: L00381 (octet.o) = 1692
Symbol: MUL168 (ATOW.os9_o) = 01A2
Symbol: OS9PREP (crt.os9_o) = 003B
Symbol: PADHEX (printf.os9_o) = 04F2
Symbol: PADSTR_050 (printf.os9_o) = 04CF
Symbol: PADSTR_100 (printf.os9_o) = 04D1
Symbol: PADSTR_900 (printf.os9_o) = 04DB
Symbol: PADSTR_POST (printf.os9_o) = 04DF
Symbol: PADSTR_PRE (printf.os9_o) = 04C0
Symbol: PADWRD (printf.os9_o) = 0481
Symbol: PHX020 (printf.os9_o) = 0500
Symbol: PHX030 (printf.os9_o) = 0508
Symbol: PHX050 (printf.os9_o) = 0510
Symbol: PHX060 (printf.os9_o) = 0515
Symbol: PHX900 (printf.os9_o) = 051F
Symbol: PRINTC (printf.os9_o) = 05E5
Symbol: PRINTS (printf.os9_o) = 05EE
Symbol: PRNTWD (printf.os9_o) = 058E
Symbol: PRNTWH (printf.os9_o) = 0529
Symbol: PRS010 (printf.os9_o) = 05F4
Symbol: PRS020 (printf.os9_o) = 05F7
Symbol: PRWD10 (printf.os9_o) = 0592
Symbol: PRWD20 (printf.os9_o) = 059E
Symbol: PRWD30 (printf.os9_o) = 05AA
Symbol: PRWD40 (printf.os9_o) = 05B6
Symbol: PRWD60 (printf.os9_o) = 05C9
Symbol: PRWD70 (printf.os9_o) = 05D7
Symbol: PRWD80 (printf.os9_o) = 05D9
Symbol: PRWD90 (printf.os9_o) = 05E3
Symbol: PRWH10 (printf.os9_o) = 0538
Symbol: PRWH30 (printf.os9_o) = 0568
Symbol: PRWH40 (printf.os9_o) = 0571
Symbol: PRWH99 (printf.os9_o) = 057C
Symbol: PTF010 (printf.os9_o) = 027E
Symbol: PTF020 (printf.os9_o) = 0288
Symbol: PTF490 (printf.os9_o) = 028D
Symbol: PTF500 (printf.os9_o) = 0295
Symbol: PTF510 (printf.os9_o) = 02A2
Symbol: PTF515 (printf.os9_o) = 02B0
Symbol: PTF517 (printf.os9_o) = 02C8
Symbol: PTF518 (printf.os9_o) = 02D7
Symbol: PTF520 (printf.os9_o) = 02DE
Symbol: PTF522 (printf.os9_o) = 02E2
Symbol: PTF525 (printf.os9_o) = 02EC
Symbol: PTF530 (printf.os9_o) = 0305
Symbol: PTF532 (printf.os9_o) = 0312
Symbol: PTF538 (printf.os9_o) = 0320
Symbol: PTF540 (printf.os9_o) = 0325
Symbol: PTF550 (printf.os9_o) = 0333
Symbol: PTF555 (printf.os9_o) = 033F
Symbol: PTF559 (printf.os9_o) = 0436
Symbol: PTF560 (printf.os9_o) = 0441
Symbol: PTF562 (printf.os9_o) = 0453
Symbol: PTF565 (printf.os9_o) = 0463
Symbol: PTF567 (printf.os9_o) = 0465
Symbol: PTF570 (printf.os9_o) = 046D
Symbol: PTF800 (printf.os9_o) = 046D
Symbol: PTF900 (printf.os9_o) = 047D
Symbol: PUTCHR (crt.os9_o) = 0121
Symbol: PWD020 (printf.os9_o) = 048F
Symbol: PWD030 (printf.os9_o) = 0497
Symbol: PWD040 (printf.os9_o) = 049F
Symbol: PWD050 (printf.os9_o) = 04A7
Symbol: PWD060 (printf.os9_o) = 04AC
Symbol: PWD900 (printf.os9_o) = 04B6
Symbol: S00087 (temp.o) = 17D5
Symbol: S00088 (temp.o) = 17E9
Symbol: S00089 (temp.o) = 17F4
Symbol: S00090 (octet.o) = 1AA0
Symbol: S00090 (temp.o) = 1818
Symbol: S00091 (octet.o) = 1ABD
Symbol: S00091 (temp.o) = 1825
Symbol: S00092 (octet.o) = 1AC5
Symbol: S00092 (temp.o) = 182F
Symbol: S00093 (octet.o) = 1ADF
Symbol: S00093 (temp.o) = 1838
Symbol: S00094 (octet.o) = 1AF9
Symbol: S00094 (temp.o) = 183E
Symbol: S00095 (octet.o) = 1B07
Symbol: S00095 (temp.o) = 185B
Symbol: S00096 (octet.o) = 1B0B
Symbol: S00096 (temp.o) = 1862
Symbol: S00097 (octet.o) = 1B23
Symbol: S00097 (temp.o) = 1872
Symbol: S00098 (octet.o) = 1B43
Symbol: S00098 (temp.o) = 1882
Symbol: S00099 (octet.o) = 1B4E
Symbol: S00099 (temp.o) = 1894
Symbol: S00100 (octet.o) = 1B77
Symbol: S00100 (temp.o) = 18A4
Symbol: S00101 (octet.o) = 1B96
Symbol: S00101 (temp.o) = 18B4
Symbol: S00102 (octet.o) = 1BB7
Symbol: S00102 (temp.o) = 18C4
Symbol: S00103 (octet.o) = 1BD1
Symbol: S00103 (temp.o) = 18D6
Symbol: S00104 (octet.o) = 1BF0
Symbol: S00104 (temp.o) = 18E7
Symbol: S00105 (octet.o) = 1C13
Symbol: S00105 (temp.o) = 18F2
Symbol: S00106 (octet.o) = 1C27
Symbol: S00106 (temp.o) = 18FE
Symbol: S00107 (octet.o) = 1C37
Symbol: S00107 (temp.o) = 1914
Symbol: S00108 (octet.o) = 1C4B
Symbol: S00108 (temp.o) = 1928
Symbol: S00109 (octet.o) = 1C5B
Symbol: S00110 (octet.o) = 1C69
Symbol: S00111 (octet.o) = 1C74
Symbol: S00112 (octet.o) = 1C80
Symbol: S00113 (octet.o) = 1C8C
Symbol: S00114 (octet.o) = 1C92
Symbol: S00115 (octet.o) = 1C9E
Symbol: S00116 (defs.o) = 192F
Symbol: S00116 (octet.o) = 1CAA
Symbol: S00117 (defs.o) = 1936
Symbol: S00117 (octet.o) = 1CB7
Symbol: S00118 (defs.o) = 193E
Symbol: S00118 (octet.o) = 1CC5
Symbol: S00119 (defs.o) = 1943
Symbol: S00119 (octet.o) = 1CD5
Symbol: S00120 (defs.o) = 1948
Symbol: S00120 (octet.o) = 1CE5
Symbol: S00121 (defs.o) = 1950
Symbol: S00121 (octet.o) = 1CEF
Symbol: S00122 (defs.o) = 1958
Symbol: S00122 (octet.o) = 1CFB
Symbol: S00123 (defs.o) = 195F
Symbol: S00123 (octet.o) = 1D02
Symbol: S00124 (defs.o) = 1966
Symbol: S00124 (octet.o) = 1D04
Symbol: S00125 (defs.o) = 196C
Symbol: S00125 (octet.o) = 1D18
Symbol: S00126 (defs.o) = 1972
Symbol: S00126 (octet.o) = 1D21
Symbol: S00127 (defs.o) = 197A
Symbol: S00127 (octet.o) = 1D2D
Symbol: S00128 (defs.o) = 1982
Symbol: S00128 (octet.o) = 1D42
Symbol: S00129 (defs.o) = 1989
Symbol: S00129 (octet.o) = 1D5E
Symbol: S00130 (defs.o) = 1993
Symbol: S00130 (octet.o) = 1D70
Symbol: S00131 (defs.o) = 199D
Symbol: S00131 (octet.o) = 1D96
Symbol: S00132 (defs.o) = 19A5
Symbol: S00132 (octet.o) = 1DBC
Symbol: S00133 (defs.o) = 19AE
Symbol: S00134 (defs.o) = 19B7
Symbol: S00135 (defs.o) = 19C0
Symbol: S00136 (defs.o) = 19CA
Symbol: S00137 (defs.o) = 19D3
Symbol: S00138 (defs.o) = 19DC
Symbol: S00139 (defs.o) = 19E5
Symbol: S00140 (defs.o) = 19EE
Symbol: S00141 (defs.o) = 19FC
Symbol: S00142 (defs.o) = 1A09
Symbol: S00143 (defs.o) = 1A16
Symbol: S00144 (defs.o) = 1A20
Symbol: S00145 (defs.o) = 1A31
Symbol: S00146 (defs.o) = 1A3A
Symbol: S00147 (defs.o) = 1A43
Symbol: S00148 (defs.o) = 1A49
Symbol: S00149 (defs.o) = 1A4F
Symbol: S00150 (defs.o) = 1A55
Symbol: S00151 (defs.o) = 1A5B
Symbol: S00152 (defs.o) = 1A61
Symbol: S00153 (defs.o) = 1A67
Symbol: S00154 (defs.o) = 1A84
Symbol: S00155 (defs.o) = 1A8B
Symbol: S00156 (defs.o) = 1A92
Symbol: _Buf_NEW (defs.o) = 08DD
Symbol: _Chain_NEW (defs.o) = 0914
Symbol: _ClassNames (defs.o) = 4E45
Symbol: _ClassNames_SIZE (defs.o) = 4E5B
Symbol: _Class_NEW (defs.o) = 094B
Symbol: _CodeNames (defs.o) = 4E5D
Symbol: _CodeNames_SIZE (defs.o) = 4E91
Symbol: _Dict_NEW (defs.o) = 096A
Symbol: _FROM_INT (defs.o) = 09A1
Symbol: _Free_NEW (defs.o) = 09E3
Symbol: _GCTest1 (temp.o) = 061A
Symbol: _IS_INT (defs.o) = 0A01
Symbol: _IS_INT2 (defs.o) = 0A13
Symbol: _List_NEW (defs.o) = 0A2B
Symbol: _OBucket (octet.o) = 4E9D
Symbol: _OBucketCap (octet.o) = 1DCF
Symbol: _OMarkerFn (octet.o) = 4E9B
Symbol: _ORamBegin (octet.o) = 4E97
Symbol: _ORamEnd (octet.o) = 4E99
Symbol: _ORamFrozen (octet.o) = 4E95
Symbol: _ORamUsed (octet.o) = 4E93
Symbol: _Str_NEW (defs.o) = 0A62
Symbol: _TO_INT (defs.o) = 0AC5
Symbol: __memend (crt.os9_o) = 0009
Symbol: __mtop (crt.os9_o) = 000B
Symbol: __stbot (crt.os9_o) = 000F
Symbol: __sttop (crt.os9_o) = 000D
Symbol: _data (temp.o) = 0023
Symbol: _dwtoa (dwtoa.os9_o) = 01F3
Symbol: _errno (crt.os9_o) = 0007
Symbol: _exit (crt.os9_o) = 0118
Symbol: _fixtop (crt.os9_o) = 00A7
Symbol: _main (temp.o) = 0878
Symbol: _oalloc (octet.o) = 0AF9
Symbol: _oalloc_try (octet.o) = 0B61
Symbol: _oallocforever (octet.o) = 0C42
Symbol: _ocap (octet.o) = 0C98
Symbol: _ocarve (octet.o) = 0D08
Symbol: _ocheckguards (octet.o) = 0E49
Symbol: _ocls (octet.o) = 0F0C
Symbol: _odump (octet.o) = 0F53
Symbol: _ofree (octet.o) = 1094
Symbol: _ogc (octet.o) = 10FF
Symbol: _oinit (octet.o) = 1218
Symbol: _omark (octet.o) = 12DA
Symbol: _omemcmp (octet.o) = 1383
Symbol: _omemcpy (octet.o) = 1407
Symbol: _opanic (temp.o) = 08AF
Symbol: _osay (octet.o) = 143A
Symbol: _osaylabel (octet.o) = 1552
Symbol: _osize2bucket (octet.o) = 1588
Symbol: _ovalidaddr (octet.o) = 15C4
Symbol: _ozero (octet.o) = 1670
Symbol: _printf (printf.os9_o) = 0270
Symbol: _putchar (putchar_a.os9_o) = 0603
Symbol: _root (temp.o) = 4E43
Symbol: _root_marker (temp.o) = 08CC
Symbol: _stkchec (crt.os9_o) = 00BA
Symbol: _stkcheck (crt.os9_o) = 00BA
Symbol: _strlen (strlen.os9_o) = 0609
Symbol: _strlen_010 (strlen.os9_o) = 060D
Symbol: argv (crt.os9_o) = 0011
Symbol: bss_end (defs.o) = 4E93
Symbol: bss_end (octet.o) = 4EB7
Symbol: bss_end (temp.o) = 4E45
Symbol: bss_start (defs.o) = 4E45
Symbol: bss_start (octet.o) = 4E93
Symbol: bss_start (temp.o) = 0023
Symbol: constructors (crt.os9_o) = 169D
Symbol: destructors (crt.os9_o) = 169E
Symbol: doDigit (dwtoa.os9_o) = 01B3
Symbol: doDigit_010 (dwtoa.os9_o) = 01BB
Symbol: doDigit_020 (dwtoa.os9_o) = 01E3
Symbol: doDigit_030 (dwtoa.os9_o) = 01E7
Symbol: dwtoa_010 (dwtoa.os9_o) = 0208
Symbol: dwtoa_020 (dwtoa.os9_o) = 0228
Symbol: dwtoa_030 (dwtoa.os9_o) = 0238
Symbol: dwtoa_040 (dwtoa.os9_o) = 0246
Symbol: erexit (crt.os9_o) = 00F6
Symbol: fixserr (crt.os9_o) = 00D8
Symbol: freemem (crt.os9_o) = 010F
Symbol: fsterr (crt.os9_o) = 00F1
Symbol: funcend_Buf_NEW (defs.o) = 0914
Symbol: funcend_Chain_NEW (defs.o) = 094B
Symbol: funcend_Class_NEW (defs.o) = 096A
Symbol: funcend_Dict_NEW (defs.o) = 09A1
Symbol: funcend_FROM_INT (defs.o) = 09E3
Symbol: funcend_Free_NEW (defs.o) = 0A01
Symbol: funcend_GCTest1 (temp.o) = 0878
Symbol: funcend_IS_INT (defs.o) = 0A13
Symbol: funcend_IS_INT2 (defs.o) = 0A2B
Symbol: funcend_List_NEW (defs.o) = 0A62
Symbol: funcend_Str_NEW (defs.o) = 0AC5
Symbol: funcend_TO_INT (defs.o) = 0AF9
Symbol: funcend_main (temp.o) = 08AF
Symbol: funcend_oalloc (octet.o) = 0B61
Symbol: funcend_oalloc_try (octet.o) = 0C42
Symbol: funcend_oallocforever (octet.o) = 0C98
Symbol: funcend_ocap (octet.o) = 0D08
Symbol: funcend_ocarve (octet.o) = 0E49
Symbol: funcend_ocheckguards (octet.o) = 0F0C
Symbol: funcend_ocls (octet.o) = 0F53
Symbol: funcend_odump (octet.o) = 1094
Symbol: funcend_ofree (octet.o) = 10FF
Symbol: funcend_ogc (octet.o) = 1218
Symbol: funcend_oinit (octet.o) = 12DA
Symbol: funcend_omark (octet.o) = 1383
Symbol: funcend_omemcmp (octet.o) = 1407
Symbol: funcend_omemcpy (octet.o) = 143A
Symbol: funcend_opanic (temp.o) = 08CC
Symbol: funcend_osay (octet.o) = 1552
Symbol: funcend_osaylabel (octet.o) = 1588
Symbol: funcend_osize2bucket (octet.o) = 15C4
Symbol: funcend_ovalidaddr (octet.o) = 1670
Symbol: funcend_ozero (octet.o) = 169D
Symbol: funcend_root_marker (temp.o) = 08DD
Symbol: funcsize_Buf_NEW (defs.o) = 0914
Symbol: funcsize_Chain_NEW (defs.o) = 0914
Symbol: funcsize_Class_NEW (defs.o) = 08FC
Symbol: funcsize_Dict_NEW (defs.o) = 0914
Symbol: funcsize_FROM_INT (defs.o) = 091F
Symbol: funcsize_Free_NEW (defs.o) = 08FB
Symbol: funcsize_GCTest1 (temp.o) = 0878
Symbol: funcsize_IS_INT (defs.o) = 08EF
Symbol: funcsize_IS_INT2 (defs.o) = 08F5
Symbol: funcsize_List_NEW (defs.o) = 0914
Symbol: funcsize_Str_NEW (defs.o) = 0940
Symbol: funcsize_TO_INT (defs.o) = 0911
Symbol: funcsize_main (temp.o) = 0651
Symbol: funcsize_oalloc (octet.o) = 0B61
Symbol: funcsize_oalloc_try (octet.o) = 0BDA
Symbol: funcsize_oallocforever (octet.o) = 0B4F
Symbol: funcsize_ocap (octet.o) = 0B69
Symbol: funcsize_ocarve (octet.o) = 0C3A
Symbol: funcsize_ocheckguards (octet.o) = 0BBC
Symbol: funcsize_ocls (octet.o) = 0B40
Symbol: funcsize_odump (octet.o) = 0C3A
Symbol: funcsize_ofree (octet.o) = 0B64
Symbol: funcsize_ogc (octet.o) = 0C12
Symbol: funcsize_oinit (octet.o) = 0BBB
Symbol: funcsize_omark (octet.o) = 0BA2
Symbol: funcsize_omemcmp (octet.o) = 0B7D
Symbol: funcsize_omemcpy (octet.o) = 0B2C
Symbol: funcsize_opanic (temp.o) = 0637
Symbol: funcsize_osay (octet.o) = 0C11
Symbol: funcsize_osaylabel (octet.o) = 0B2F
Symbol: funcsize_osize2bucket (octet.o) = 0B35
Symbol: funcsize_ovalidaddr (octet.o) = 0BA5
Symbol: funcsize_ozero (octet.o) = 0B26
Symbol: funcsize_root_marker (temp.o) = 062B
Symbol: isArgEndingChar (crt.os9_o) = 00A0
Symbol: l_bss (<synthetic>) = 4EB6
Symbol: l_code (<synthetic>) = 167E
Symbol: l_constructors_end (<synthetic>) = 0001
Symbol: l_constructors_start (<synthetic>) = 0000
Symbol: l_destructors_end (<synthetic>) = 0001
Symbol: l_destructors_start (<synthetic>) = 0000
Symbol: l_initgl (<synthetic>) = 0135
Symbol: l_initgl_end (<synthetic>) = 0001
Symbol: l_initgl_start (<synthetic>) = 0000
Symbol: l_rodata (<synthetic>) = 0607
Symbol: l_rwdata (<synthetic>) = 0000
Symbol: l_start (<synthetic>) = 0012
Symbol: negateDWord (negateDWord.os9_o) = 0130
Symbol: nop_handler (crt.os9_o) = 0120
Symbol: null_ptr_handler (crt.os9_o) = 0003
Symbol: parseCmdLine (crt.os9_o) = 0068
Symbol: powersOfTen (dwtoa.os9_o) = 024C
Symbol: printReal (printf.os9_o) = 05FD
Symbol: program_end (temp.o) = 17D5
Symbol: program_start (temp.o) = 000D
Symbol: putchar_a (putchar_a.os9_o) = 0605
Symbol: s_bss (<synthetic>) = 0001
Symbol: s_code (<synthetic>) = 001F
Symbol: s_constructors_end (<synthetic>) = 169D
Symbol: s_constructors_start (<synthetic>) = 169D
Symbol: s_destructors_end (<synthetic>) = 169E
Symbol: s_destructors_start (<synthetic>) = 169E
Symbol: s_initgl (<synthetic>) = 169F
Symbol: s_initgl_end (<synthetic>) = 17D4
Symbol: s_initgl_start (<synthetic>) = 169F
Symbol: s_rodata (<synthetic>) = 17D5
Symbol: s_rwdata (<synthetic>) = 0001
Symbol: s_start (<synthetic>) = 000D
Symbol: stacksiz (crt.os9_o) = 0106
Symbol: stk10 (crt.os9_o) = 00D6
Symbol: string_literals_end (defs.o) = 1AA0
Symbol: string_literals_end (octet.o) = 1DCF
Symbol: string_literals_end (temp.o) = 192F
Symbol: string_literals_start (defs.o) = 192F
Symbol: string_literals_start (octet.o) = 1AA0
Symbol: string_literals_start (temp.o) = 17D5
Symbol: sub32 (sub32.os9_o) = 0148
Symbol: sub32xu (sub32xu.os9_o) = 0169
*/
