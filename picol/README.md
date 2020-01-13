= NCL (NitrOS9 Control Language)

This is a Tcl-like programming langauge for NitrOS9 for the Motorola 6809.
It can be used as an alternative to the various SHELLs, and simple commands
usually work the same.

== Quick Install

Copy `ncl.bin` onto your OS9 disk with the name "ncl".
Put it in the `/DD/CMDS` directory, and give it "x" attrs.

```
os9 copy -r ncl.bin /the/disk/image,cmds/ncl
os9 attr -e -r -w -pe -pr /the/disk/image,cmds/ncl
```

Copy `nclrc.tcl` onto your OS9 disk with the name `nclrc.tcl`.
Put it in the `/DD/SYS` directory.

```
os9 copy -r nclrc.tcl /my/disk/image,sys/nclrc.tcl
```

== Common Snags

On my CoCo keyboard it is hard or impossible to type `[` `]` `{` `}` and `\`.
So the input to NCL makes these substitutions:

```
(( to [
)) to ]
((( to {
))) to }
@@ to \
```

Those were chosen because `(` `)` and `@` are not used in Ncl syntax.

In this example, the second command is actually `glob {[a-z]*}` :

```
 >NCL> glob *
.. . OS9Boot CMDS SYS DEFS ccbkrn sysgo startup NITROS9 IOPAGE.BAS ZDIR COUNT100.BAS Z3 Z4 zsq nclrc.txt
 >NCL> glob (((((a-z))*)))
OS9Boot CMDS SYS DEFS ccbkrn sysgo startup NITROS9 IOPAGE.BAS ZDIR COUNT100.BAS Z3 Z4 zsq nclrc.txt
```

Three commands on my NitrOS9 system conflict with Tcl commands:

*   `error`
*   `list`
*   `proc`

To run the OS9 commands, prefix the commands with `run`:

*   `run error num`
*   `run list filename`
*   `run proc

NCL is currently sloppy about what goes to stdout and what goes to stderr.
It is mostly stdout right now, but should be stderr.

== Differences from Tcl

This implements a subset of old style Tcl.

There is a file `tcl_6.7_man.txt` in this directory that documents an old
version of Tcl.  That's probably a better starting point than newer versions.

Still there are many differences:

*   There is no `expr` command.  Instead there are individual Tcl commands 
for each arithmetic or string operator.  The `if` and `while` commands do
not take an `expr`-style argument, but rather a normal Tcl command.

```
Normal Tcl:
proc fizzbuzz i {
        set z {}
        if {0 ==($i % 3)} {append z "fizz"}
        if {0 ==($i % 5)} {append z "buzz"}
        if {[llength $z]} {set z} else {set i}
}

Ncl:
proc fizzbuzz i {
        set z {}
        if {== 0 [% $i 3]} {append z "fizz"}
        if {== 0 [% $i 5]} {append z "buzz"}
        if {llength $z} {set z} else {set i}
}
```

*   Variables cannot be arrays, and there is no way to declare them global.
Instead there is an `array` command that associates a value to a pair of
names, the first is the array name and the second is the key.
Array values are global, so if you need global data, put it in an array.

```
array $name $key $value    -- set the value at $name and $key.
array $name $key           -- get the value at $name and $key.
array $name                -- list the keys of that name.
array                      -- list the names.
```

*   String commands start with "s" the way list commands start with "l".
    Glob-like pattern matching is done with "smatch".

== Quick Command Reference

```
 != a b -> z (integer compare: returns 0 or 1)
 % a b -> z (integer modulo: a%b)
 * args... -> z (multiply integers; 1 if none)
 + args... -> z (add integers; 0 if none)
 - a b -> z (subtract: a-b)
 / a b -> z (integer division: a/b)
 9chain command args.... (does not return unless error)
 9chgdir filepath which_dir (which_dir: 1=working, 4=execute)
 9close fd
 9create filepath access_mode attrs -> fd (access_mode: 2=write 3=update)
 9dup fd -> new_fd
 9filesize fd -> size (error if 64K or bigger)
 9fork command args.... -> child_id
 9makdir filepath mode
 9open filepath access_mode -> fd (access_mode: 1=read 2=write 3=update)
 9wait child_id_var exit_status_var (name two variables to receive results)
 < a b -> z (integer compare: returns 0 or 1)
 << a b -> z (shift left: a<<b)
 <= a b -> z (integer compare: returns 0 or 1)
 == a b -> z (integer compare: returns 0 or 1)
 > a b -> z (integer compare: returns 0 or 1)
 >= a b -> z (integer compare: returns 0 or 1)
 >> a b -> z (shift right, signed: a>>b)
 >>> a b -> z (shift right, unsigned: a>>b)
 and {cond1} {cond2}... -> first_false_or_one (stop evaluating if one is false)
 append varname ?items...?
 bitand a b -> z (bitwise and: a&b)
 bitor a b -> z (bitwise or: a|b)
 bitxor a b -> z (bitwise xor: x^b)
 catch body ?varname? -> code (result value put in varname; code 0 is no error)
 delete filepath
 eq a b -> z (string compare: a==b; returns 0 or 1)
 eval args... -> result (args are joined with spaces)
 exit ?status? (does not return.  0 is good status, 1..255 are bad)
 explode str -> list_of_numbers (numbers are ascii values)
 foreach var list body (assign each list item to var and execute body)
 ge a b -> z (string compare: a>=b; returns 0 or 1)
 gets fd varname -> num_bytes_read (puts value read in varname)
 gt a b -> z (string compare: a>b; returns 0 or 1)
 if {cond} {body_if_true} ?else {body_if_else}?
 implode list_of_numbers -> str (numbers are ascii values)
 incr varname ?value?
 info   (prints lots of info about interpreter state)
 kill processid ?signal_code?
 lappend varname ?items...?
 le a b -> z (string compare: a<=b; returns 0 or 1)
 lindex list index -> item (return item at that index)
 list ?items...?
 llength list -> length
 lrange list first last -> sublist (return sublit range from first to last inclusive)
 lt a b -> z (string compare: a<b; returns 0 or 1)
 ne a b -> z (string compare: a!=b; returns 0 or 1)
 or {cond1} {cond2}... -> first_true_or_zero (stop evaluating if one is true)
 proc name varlist body (defines a new proc)
 puts ?-nonewline? ?fd? str (write str to fd, default is stdout)
 read fd num_bytes -> list_of_numbers (numbers are byte values)
 return ?value?   (returns from proc with given value or empty)
 set varname ?value? (if value not provided, returns value of variable)
 sindex str index -> substr (return 1-char substring at that index)
 sleep num_ticks
 slength str -> length
 slower str -> newstr (convert str to ASCII lowercase)
 smatch pattern str (`*` for any string, `?` for any char, `[...]` for char range )
 source filepath (read and execute the script; 16K max}
 srange str first last -> substr (return substring range from first to last inclusive)
 supper str -> newstr (convert str to ASCII uppercase)
 while {cond} {body} (cond evaluates to 0 for false, other int for true)
```
