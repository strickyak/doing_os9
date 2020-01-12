# "unknown" calls "run".
proc run args {
	set cid [eval 9fork $args]
	while * {9wait c e; if {== $c $cid} break}
	if {+ $e} {error "[lindex $args 0]: Exit status $e"}
	list
}
proc unknown args {eval run $args}

# Like SHELL builtins.
proc cd d {9chgdir $d 1}
proc chd d {9chgdir $d 1}
proc chx d {9chgdir $d 4}
proc w {} {9wait}

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
