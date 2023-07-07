fortall:lex.yy.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ lex.yy.c $(LDLIBS)

lex.yy.c:fortall.l
	lex $<

clean:
	rm -f lex.yy.c fortall
