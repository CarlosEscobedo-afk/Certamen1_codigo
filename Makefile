juego:	juego.l juego.y
	bison -d juego.y
	flex juego.l
	g++ -Wall -o $@ juego.tab.c lex.yy.c 
clean:
	rm *.yy.c juego juego.tab.c juego.tab.h 2>/dev/null
