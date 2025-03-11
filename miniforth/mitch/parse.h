// Functions

// PARSE_WORD finds the next blank-delimited sequence of characters
// from the input source array:
//
// Given a line of characters defined by the global variables:
//   char *source_adr;    // The input line array
//   cell num_source;     // The number of valid characters in the array
//   cell to_in;          // The current index into the array
//
// a) Starting at the index to_in, skip blanks and other whitespace
//    characters until either the end of the array is reached or
//    a non-whitespace character is found.
// b) Set *adr to the address of the first character not skipped
//    (which might be the address at the end of the array)
// c) Skip non-white characters until either the end of the array
//    or a whitespace character is found
// d) Update to_in so that its final value refers to the first
//    character that was not skipped.  This implies that, if the end
//    of the array was reached, to_in will be equal to num_source.
// e) Return the number of non-white characters skipped, i.e. the
//    length of the sequence of non-white characters.  If the end
//    of the array was reached before any non-white characters were
//    found, the return value is 0.

cell parse_word(char **adr);

cell safe_parse_word(char **adr);
