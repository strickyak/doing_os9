#include "forth.h"
#include "string.h"

char *dictionary[MAXDICT];

#define MAXNAMELEN 31

struct word {
    struct word *next;
    char length;  // 0x80 bit is set if immediate
    char name[MAXNAMELEN];
    code_field_t code_field;
};

static int match(struct word *p, char *adr, cell len)
{
    char *this_adr = p->name;

    if ((p->length & MAXNAMELEN) != len) {
	return 0;
    }
    while (len--) {
	if (*this_adr++ != *adr++) {
	    return 0;
	}
    }
    return 1;
}

struct word *last = NULL;

cell lastacf(void)
{
    return (cell)&last->code_field;
}

cell find(char *name_adr, cell name_len, cell *xt)
{
    struct word *p;
    for (p=last; p; p=p->next) {
	if (match(p, name_adr, name_len)) {
	    *xt = (cell)&p->code_field;
	    return (p->length & 0x80) ? 1 : -1;
	}
    }
    return 0;
}

void header(char *name_adr, cell name_len, code_field_t action_adr)
{
    if (name_len > MAXNAMELEN) {
	type(name_adr, name_len);
	ctype(" is too long\n");
	return;
    }
    align();

    struct word *new_word = (struct word *)here;
    allot(sizeof(struct word));
    new_word->next = last;
    last = new_word;

    new_word->length = name_len;
    char *p = new_word->name;
    while(name_len--) {
	*p++ = *name_adr++;
    }

    new_word->code_field = action_adr;
}

void cheader(char *name, code_field_t action_adr)
{
    header(name, strlen(name), action_adr);
}


void immediate(void)
{
    last->length |= 0x80;
}
