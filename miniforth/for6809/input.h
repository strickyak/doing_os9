// An identifier for the interactive input source.
// This value is chosen so that it cannot conflict with
// valid system file IDs.
#define TIB_ID -2

#define TIBSIZE 132

// Variables

// SOURCE_ADR is the starting address of the input line buffer
extern char *source_adr;

// SOURCE_LEN is the maximum number of characters than can be stored
// in the input line buffer
extern cell source_len;

// NUM_SOURCE is the number of characters that are currently stored
// in the input line buffer.
extern cell num_source;

// SOURCE_ID identifies the data source that is used to refill the
// input line buffer.  For example, if input is coming from a file,
// it would be the file ID.
extern cell source_id;

// TO_IN is the current index into the source line buffer.
// It is set to 0 when the line is refilled, and advanced as
// words are parsed from the buffer.
extern u_cell to_in;

// TIB is a the Text Input Buffer, a preallocated buffer used to
// collect command lines from the user in interactive mode.  If input
// were coming from a file, a different buffer, dynamically allocated
// for that file, would be used instead.
extern char tib[TIBSIZE];

// Functions

// ACCEPT reads a line of user input into a buffer of maximum
// length "len", returning when either
//  a) The buffer is filled, or
//  b) An end of line character is received.  The end of line
//    character is not stored in the buffer
// The return value is the actual number of characters that
// were stored in the buffer.
u_cell accept(char *adr, cell len);

// SET_INPUT sets the interpreter input to a given buffer and data source
void set_input(char *buffer, u_cell buflen, u_cell source_id);

// REFILL reads a line of input into the input line buffer, setting
// NUM_SOURCE to the number of characters read.  It returns false if
// no more input can be read - for example if the end of file has
// been reached.
cell refill();
