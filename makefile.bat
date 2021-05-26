bison -d assem.y
flex assem.l
gcc -g lex.yy.c assem.tab.c main.c stack.c
