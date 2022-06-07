// OS9 System Calls, lightly wrapped for calling from C.
// This module contains no global data, including no
// const char* strings.

// TODO: use typedef `byte` and `word` instead of `int`,
// to mark naturally 1-byte and 2-byte values, and generate
// faster code.

#ifndef _OS9CALL_H_
#define _OS9CALL_H_

asm void Os9Exit(int status);

asm int Os9Create(const char* path, int mode, int attrs, int* fd);

asm int Os9Open(const char* path, int mode, int* fd);

asm int Os9Delete(char* path);

asm int Os9ChgDir(char* path, int mode);

asm int Os9MakDir(char* path, int mode);

asm int Os9GetStt(int path, int func, int* dOut, int* xOut, int* uOut);

asm int Os9Read(int path, char* buf, int buflen, int* bytes_read);

asm int Os9ReadLn(int path, char* buf, int buflen, int* bytes_read);

asm int Os9Write(int path, const char* buf, int max, int* bytes_written);

asm int Os9WritLn(int path, const char* buf, int max, int* bytes_written);

asm int Os9Dup(int path, int* new_path);

asm int Os9Close(int path);

asm int Os9Sleep(int secs);

asm int Os9Wait(int* child_id_and_exit_status);

asm int Os9Fork(const char* program, const char* params, int paramlen, int lang_type, int mem_size, int* child_id);

asm int Os9Chain(const char* program, const char* params, int paramlen, int lang_type, int mem_size);

asm int Os9Send(int process_id, int signal_code);

#endif // _OS9CALL_H_
