CFLAGS=-Wpedantic -Wall -Wextra -g3

all:fortall

fortall:lex.yy.c y.tab.c fortall.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ lex.yy.c y.tab.c fortall.c $(LDLIBS)

lex.yy.c:fortall.l y.tab.h fortall.h
	lex $<

y.tab.h y.tab.c:fortall.y fortall.h
	yacc -d -t $<

clean:
	rm -f lex.yy.c y.tab.h y.tab.c fortall
