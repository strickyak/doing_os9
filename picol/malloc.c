////////////////////  Malloc & Free

#define ZERO_MALLOC
#define ZERO_FREE
//#define CHECK_ZERO_FRESH

// Parameter boundaries for main() argv.
unsigned int param_min;
unsigned int param_max;

// Heap boundaries.
unsigned int heap_min;          // Set by start code to bss_end.
unsigned int heap_brk;          // Set by start code to bss_end.
unsigned int heap_max;          // Set by every stkcheck().

// Buckets for malloc/free quanta.
#define STACK_MARGIN 200        // paranoid gap between heap and stack.
#define SMALLEST 8              // smallest mallocation; power of 2.
#define NBUCKETS 12             // 8B to 16KB.
struct Head *buck_roots[NBUCKETS];
int *buck_num_alloc[NBUCKETS];
int *buck_num_free[NBUCKETS];
int *buck_num_brk[NBUCKETS];

struct Head {
  char barrierA;
  struct Head *next;
  int cap;
  char barrierZ;
};

void heap_check_block(struct Head *h, int cap)
{
  if (h->barrierA != 'A' || h->barrierZ != 'Z' || (cap && h->cap != cap)) {
    panic("corrupt heap");
  }
}

byte which_bucket(int n, int *capP)
{
  byte b;
  int cap = SMALLEST;
  for (b = 0; b < NBUCKETS; b++) {
    if (n <= cap)
      break;
    cap += cap;
  }
  if (b >= NBUCKETS) {
    puthex('m', n);
    panic("malloc too big");
  }
  *capP = cap;
  return b;
}

char *malloc(int n)
{
  int cap;
  byte b = which_bucket(n, &cap);
  buck_num_alloc[b]++;

  // Try an existing unused block.

  struct Head *h = buck_roots[b];
  if (h) {
    heap_check_block(h, cap);
    buck_roots[b] = h->next;
#ifdef ZERO_MALLOC
    bzero((char *) (h + 1), cap);
#endif
    return (char *) (h + 1);
  }

  // Break fresh memory.
  char *p = (char *) heap_brk;
  heap_brk += (unsigned int) (cap + sizeof(struct Head));
  if (heap_brk > heap_max - STACK_MARGIN) {
    puthex('n', n);
    puthex('c', cap);
    puthex('u', heap_brk);
    puthex('m', heap_max);
    panic(" *oom* ");
  }
  // If not zero, it isn't fresh.
#ifdef CHECK_ZERO_FRESH
  for (char *j = p; j < (char *) heap_brk; j++) {
    if (*j) {
      puthex('n', n);
      puthex('c', cap);
      puthex('u', heap_brk);
      puthex('m', heap_max);
      panic("heap: unzero");
    }
  }
#endif
  h = ((struct Head *) p) - 1;
  h->barrierA = 'A';
  h->barrierZ = 'Z';
  h->cap = cap;
  h->next = NULL;
#ifdef ZERO_MALLOC
  bzero((char *) (h + 1), cap);
#endif
  return (char *) (h + 1);
}

void free(void *p)
{
  if (!p)
    return;

  struct Head *h = ((struct Head *) p) - 1;
  int cap;
  byte b = which_bucket(h->cap, &cap);
  heap_check_block(h, cap);
  buck_num_free[b]++;

#ifdef ZERO_FREE
  bzero((char *) p, cap);
#endif
  h->next = buck_roots[b];
  buck_roots[b] = h;
}

char *realloc(void *p, int n)
{
  if (!p)
    return malloc(n);
  struct Head *h = ((struct Head *) p) - 1;
  if (n <= h->cap) {
    return (char *) p;
  }

  char *z = malloc(n);
  memcpy(z, p, h->cap);
  free(p);
  return z;
}
