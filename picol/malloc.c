////////////////////  Malloc & Free

unsigned int ram_min;
unsigned int ram_brk;
unsigned int ram_max;
unsigned int param_min;
unsigned int param_max;

#define STACK_MARGIN (4*1024)
#define NBUCKETS 12             // 8B to 16KB.
struct Head *ram_roots[NBUCKETS];

struct Head {
  char barrierA;
  struct Head *next;
  int cap;
  char barrierZ;
};

char *malloc(int n)
{
  //puthex('M', n);
  int i;
  int cap = 8;
  for (i = 0; i < NBUCKETS; i++) {
    //puthex('0'+i, ram_roots[i]);
    if (n <= cap)
      break;
    cap += cap;
  }
  if (i >= 10) {
    puthex('m', n);
    panic("malloc too big");
  }

  // Try an existing unused block.

  struct Head *h = ram_roots[i];
  if (h) {
    if (h->barrierA != 'A') {
      panic("malloc: corrupt barrierA");
    }
    if (h->barrierZ != 'Z') {
      panic("malloc: corrupt barrierZ");
    }
    if (h->cap != cap) {
      panic("corrupt cap");
    }
    ram_roots[i] = h->next;
    bzero((char *) (h + 1), cap);
    //puthex('y', (int)(h+1));
    return (char *) (h + 1);
  }

  // Break fresh memory.
  //puthex('B', ram_min);
  //puthex('B', ram_brk);
  //puthex('B', ram_max);
  char *p = (char *) ram_brk;
  ram_brk += (unsigned int) (cap + sizeof(struct Head));
  if (ram_brk > ram_max - STACK_MARGIN) {
    puthex('n', n);
    puthex('c', cap);
    puthex('u', ram_brk);
    puthex('m', ram_max);
    panic(" *oom* ");
  }
  // If not zero, it isn't fresh.
  for (char *j = p; j < (char *) ram_brk; j++) {
    if (*j) {
      puthex('n', n);
      puthex('c', cap);
      puthex('u', ram_brk);
      puthex('m', ram_max);
      panic("malloc: unzero");
    }
  }
  h = ((struct Head *) p) - 1;
  h->barrierA = 'A';
  h->barrierZ = 'Z';
  h->cap = cap;
  h->next = NULL;
  //puthex('z', (int)(h+1));
  return (char *) (h + 1);
}

void free(void *p)
{
  if (!p)
    return;

  //puthex('F', (int)p);
  struct Head *h = ((struct Head *) p) - 1;
  if (h->barrierA != 'A')
    panic("free: corrupt barrierA");
  if (h->barrierZ != 'Z')
    panic("free: corrupt barrierZ");

  int i;
  int cap = 8;
  for (i = 0; i < 10; i++) {
    if (h->cap == cap)
      break;
    cap += cap;
  }
  if (i >= 10) {
    puthex('c', h->cap);
    panic("corrupt free");
  }

  bzero((char *) p, cap);

  h->next = ram_roots[i];
  ram_roots[i] = h;
}

char *realloc(void *p, int n)
{
  //puthex('R', (int)p);
  //puthex('n', (int)n);
  struct Head *h = ((struct Head *) p) - 1;
  if (n <= h->cap) {
    //puthex('w', (int)p);
    return (char *) p;
  }

  char *z = malloc(n);
  memcpy(z, p, h->cap);
  //puthex('x', (int)z);
  return z;
}
