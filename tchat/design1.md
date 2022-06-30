# TCHAT Design1

Henry Strickland -- Draft 1 -- Jun 29, 2022

TCHAT is a multi-use protocol designed to make optimal
use of one socket out of the four sockets on a Wiznet W5100S chip.
Although it is designed for Wiznet, nothing prevents it being
prototyped or run on any other UDP/IPv4-capable device.

Two versions are proposed:  

   * Version 1 "TCHAT Transient" (TCHAT/T) is built on simpler mechansims but lacks persistent state for the chat mesh. 

   * Version 2 "TCHAT Persistent" (TCHAT/P) has more features and has persistence, but is more expensive to run, due to its use of disk.

### TCHAT is Peer-to-Peer Mesh.

A TCHAT program is both a client and a server.  Multiple users running
TCHAT on their machines view each other as peers, and the protocol is
described that way.

There are actually many ways to write a TCHAT program.  It may be that it
has a client part and a server part.  Or the User Inferface (be it text
or GUI) could be the part that is split off into a separate process.
But most likely it will start out as one monolithic program that does
everything.

### The Mesh is self-organizing.

As long as you know the adderess of one machine in the active Mesh,
you can join the mesh.

In the beginning, the mesh will be a complete graph:  Each node will
send all its chat traffic to all other nodes.  There probably will not
be very many nodes at first, anyway.

### TCHAT can include TFTPD.

The TCHAT packet format is backwards compatible with TFTP packets.
It would be natural for the TCHAT program to include a TFTP server.

For TCHAT/P, the TFTP server will actually be required,
because that is how the files are copied that hold the persistent
TCHAT state.

### TCHAT packets start with TFTP operation numbers.

A TFTP UDP packet always starts wtih a two-byte operation code,
but TFTP protocol only uses operation codes 1 to 5.  TCHAT packets
also start with a two-byte opcode, but only use opcodes in which
the high byte is $4D (the ascii letter 'M'). 

This way one UDP socket can receive both TFTP and TCHAT packets,
and the TCHAT program can operate as TFTPD.

## TCHAT Transient (TCHAT/T)

Three packet types are used for TCHAT/T:

   * M/Hello, for initiating and continuing Mesh connections

   * M/Chat, for sending chat messages

   * M/Ack, for acknowledging the previous two packet types.

### Logical Nodes

Nodes in the mesh are identified by a three-uppercase-letter code,
so node names look like YAK or SFO or XYZ.

There is an IPv4 address and port number associated with them, too,
but that might change over time.

### Distriuted Lamport Logical Clocks

A core feature of TCHAT is its use of Lamport Clocks.

Timestamps are 8 bytes long.  The first 5 bytes are a 40-bit unsigned integer.
and the final 3 bytes are the three-letter Node Name of the sender.
Timestamps are compared in memcmp() order, with the Node Name being
the least significant bytes.

Every TCHAT packet (except for M/Ack) contains a unique Lamport Timestamp.
An M/Ack packet contains the unique timestamp of the message being acked.

The Lamport Invarient must be maintained: each packet originating from
a node has a timestamp that is higher than any other packet that node
previously sent or received.  The easy way to do this is to remember the
maximum timestamp a node has ever produced or seen, and when a new message
is to be sent, increment the 40-bit number, and use your own Node Name
in the final 3 bytes.

An optional feature is that any node may advance the 40-bit integer
so that its first 32 bits are the current Unix Time, in seconds UTC.
A node may only do this if it is certain it knows the correct time
(like it just got a NTP from a trusted time server) and if it doesn't
violate the Lamport Invarient.  There is no guarantee that this has
ever happened, so don't depend on Lamport Timestamps matching wall time.

### Packet Formats

```
typedef unsigned char byte;  // 1 byte
typedef unsigned int word;   // 2 bytes
typedef unsigned long quad;  // 4 bytes

struct Timestamp {  // for Lamport Logical Clocks
    byte ticks[5];  // counts up
    byte who[3];    // node name
};

struct Location {
    byte who[3];
    quad ip4addr;
    word ip4port;
    byte minutes_ago;
};

struct Header12 {
    word operation_number;  // Overlays TFTP operation number.
    struct Timestamp ts;  // for uniqueness and causality
    byte implementation;  // for debugging
    byte level;           // for versioning
};

struct MHello {
    struct Header12;
    byte flags;           // $01 meaning Location structs follow.  $02 bit requests Locations in the ack.
    byte size;             // number of Location structs that follow (0 or more, but not too many).
};

struct MChat {
    struct Header12;
    byte flags;           // always $10, meaning message bytes follow.
    byte size;            // number of message bytes that follow (up to 255).
};

struct MAck {
    word operation_number;  // Overlays TFTP operation number.
    struct Timestamp ts;    // which message is being ACked.
    byte flags;             // could be $01, meaning Location structs follow.
    byte size;              // number of Location structs that follow (0 or more, but not too many).
};

#define WORD_FROM_HI_AND_LO(HI,LO)   (((word)(HI) << 8) | (word)(LO))

#define OP_M_HELLO   WORD_FROM_HI_AND_LO('M', 'H')
#define OP_M_CHAT    WORD_FROM_HI_AND_LO('M', 'C')
#define OP_M_ACK     WORD_FROM_HI_AND_LO('M', 'A')
```

### Algorithms and Guidelines

TCHAT needs to be configured with its ipv4 address, UDP port number (use
the TFTP port 69 if you can), and 3-uppercase-letter logical Node name.
Unlike Unix TFTPD, all packets will be sent and received with that same
local port number, so only one socket on the Wiznet chip is needed.

It also needs some starting ipaddr:port locations to look for a running
mesh.  It would be good if it remembered past locations that it can
try again.

To find peers, send MHello packets to prior peers or to potential peers
in your configuration.  If you get an MAck, you found an active peer.
Continue to send MHello packets at least every 5 minutes to all your
active peers.  Share your active peers by setting the $01 flag and
appending them to the MHello packet.  Request other node's active peers
by setting the $02 bit, and receive them appended to the MAck packet.

Once you have not heard from a peer in (perhaps) 15 minutes,
it is no longer active.

When a chat message is sent, you send a separate copy of the message
to every active peers, and expect an Ack.  If you don't get the Ack,
after a delay, retry the message, up to (perhaps) 5 times.

When you receive a chat message, Ack it and display it.

To start out, there is only one unnamed chat channel, and no direct messages.
Each chat message should begin with one space, so that other prefixes
can be added (for channels, direct messages, etc.)

A GUI interface and a text interface would both be nice,
similar to IRC chat programs.

## TCHAT Persistent (TCHAT/P)

Fix up the TFTPD functionality:

   * The TFTPD is necessary, at least to READ in "octets" mode (not "netascii").
     Write is not needed in the TFTPD; we will *pull* file transfers.

   * The TFTP option to read a file starting at a certain byte offset in the file

   * TFTP READ a filename ending in a "/" will get a directory listing.
     Could be "netascii".   Or maybe just "octets" with CR line endings.
     Each returned line is "name(/) 12345" where name is a file in the directory,
     / is appended if it is another directory, and 12345 is the file length in bytes.

   * Start with "/" and you can traverse and fetch the entire tree.
     "/" should map to some local directory like "/dd/public" which is the
     only tree fetchable.

   * TCHAT persistence is under logical "/tchat/" (which might be "/dd/public/tchat/").
     All data in those files is immutable, except that a file can be appended by
     the originating node of the file.

   * So under "/tchat", you can build an "rsync" that uses file size to determine
     equivalance, and effeciently fetches newly appended data starting at offset.

Add one more operation, "TUpdate".

Struct and protocol To Be Determined.  It should be a message that is pushed to all
peers, indicating that a file has been appended at certain offset with a line of data
up to 255 bytes.

```
#define OP_M_UPDATE   WORD_FROM_HI_AND_LO('M', 'U')
```

### Database Log Files

What is in these files?  Mostly database log files.

Each line is text, formatted like this:

```
{~timestamp~table~key~value~}
```

The `~` mean TAB characters '\x09'.  The `{` and `}` are literally `{` and `}` characters.
The other four fields contain only printable 7-bit ASCII or spaces:

   * `timestamp` is the Lamport Timestamp, in format "%02x%02x%02x%02x%02x%c%c%c".
     That is, the first 5 bytes are written in hex, and the last 3 bytes are the letters themselves.

   * `table` is the name of the database table, which has two columns, key and value.
   * `key` is the primary key for that row.
   * `value` is the value at the primary key.

The TCHAT program slurps in all database log files, and builds the current view
of the tables.  For rows that have the same table and key, the later timestamp wins.

Example Uses:  Synatx:  table(key) => value
   * nick(YAK) => strick
   * mesh(FRED) => 10.1.1.10:69   (a well known mesh starting point named FRED)
   * chat(#music) => ":YAK I've saved a MIDI file in my tftp dir"  ( spoken by YAK )

The chat table is special -- (recent) old messages are important,
not ignored.  If chat is converted over to this format, instead of the
MChat protocol, then the chat history is persisted and can be found
and displayed.

Disadvantages:  Disk space, slow disk operations, possible need for
Garbage Collection of really old messages.

### Log filename format

Log files are named by Class, Node, and Sequence number, in the format "%c%c%c%c%04d".
That is, one character for class, 3 for node name, and 4 digits.

Most database records are class 'R' for Registry.  Chat messages are class 'C' for chat.

## END for now.  Draft 1.
