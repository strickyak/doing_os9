# "unknown" calls "run".
proc run args {
	set argv {}

	set in - ; set out -
	set prep {list; }
	set post {list; }
	set bg 0
	set mem_size 0
	foreach a $args {
		if {eq $a "&"} {
			set bg 1
		} else {if {smatch "<*" $a} {
			set in [srange $a 1 999]
			append prep {set dupin [9dup 0] ; 9close 0 ; 9open [set in] 1 ;}
			append post {catch {9close 0} ; 9dup [set dupin]; catch {9close [set dupin]} ;}
		} else {if {smatch ">*" $a} {
			set out [srange $a 1 999]
			append prep {set dupout [9dup 1] ; 9close 1 ; 9create [set out] 2 033 ;}
			append post {catch {9close 1} ; 9dup [set dupout]; catch {9close [set dupout]} ;}
		} else {if {smatch "#*" $a} {
			set mem_size [srange $a 1 999]
		} else {
			lappend argv $a
		}}}}
	}

	if {catch {eval $prep} what} {
		eval $post
		error "Failed to prep for command: $what"
	}
	set cid [eval 9fork -m$mem_size $argv]
	eval $post

	if {+ $bg} {
		return $cid
	} else {
		while * {9wait c e; if {== $c $cid} break}
		if {+ $e} {error "[lindex $args 0]: Exit status $e"}
		return ""
	}
}
proc unknown args {eval run $args}

# Like SHELL builtins.
proc cd d {9chgdir $d 1}
proc chd d {9chgdir $d 1}
proc chx d {9chgdir $d 4}
proc w {} {9wait}

# For file globbing.
proc implode_thru_hi_bit x {
	set z {}
	foreach i $x {if {bitand $i 128} {lappend z [bitand 127 $i]; break} else {lappend z $i}}
	implode $z
}
proc readdir d {
	set z {}
	set fd [9open $d 129]
	while * {
		if {catch {set v [9read $fd 32]}} break
		if {lindex $v 0} {lappend z [implode_thru_hi_bit $v]}
	}
	9close $fd
	return $z
}
# Simple glob in current directory.
proc glob pat {
	set z {}
	foreach f [readdir .] {if {smatch $pat $f} {lappend z $f}}
	set z
}

# Programming demos.
proc not x {== $x 0}
proc fib x {if {< $x 2} {return $x}; + [fib [- $x 1]] [fib [- $x 2]]}
proc tri x {if {< $x 2} {return $x}; + $x [tri [- $x 1]]}
proc iota x {set z {}; set i 0; while {< $i $x} {lappend z [incr i]}; set z}
# fizzbuzz of one number.
proc fizzbuzz i {
	set z {}
	if {not [% $i 3]} {append z "fizz"}
	if {not [% $i 5]} {append z "buzz"}
	if {llength $z} {set z} else {set i}
}
# print fizzbuzzes up through n.
proc fb {n} {
	set i 0
	while {< $i $n} {
		puts -nonewline " [fizzbuzz [incr i]]"
	}
	puts {}
}
