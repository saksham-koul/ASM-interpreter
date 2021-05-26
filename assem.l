%option noyywrap
%option yylineno
%option caseless


%{
	#include<stdio.h>
	#include "assem.tab.h"
  	#define MAX 65535
  	#define MIN -65534
  	char *strndup(const char *s,size_t n);
  	int yyerror(char *s);
  	int tolower(int c);
  	int convert_to_int(const char *c,int n);
  	int yyleng;
  	int value;
%}


%%

"ADD"          			{yylval.inst = "add";return INSTRUC;}
"SUB"          			{yylval.inst = "sub";return INSTRUC;}			
"MUL"          			{yylval.inst = "mul";return INSTRUC;}
"DIV"          			{yylval.inst = "div";return INSTRUC;}
"MOV"          			{yylval.inst = "mov";return INSTRUC;}
"CMP"          			{yylval.inst = "cmp";return INSTRUC;}
"JMP"          			{yylval.inst = "jmp";return INSTRUC;}
"JE"           			{yylval.inst = "je"; return INSTRUC;}
"JNE"          			{yylval.inst = "jne";return INSTRUC;}
"EXT"          			{yylval.inst = "ext";return INSTRUC;}
"CAll"         			{yylval.inst = "call";return INSTRUC;}
"RET"          			{yylval.inst = "ret";return INSTRUC;}
"PRINT"        			{yylval.inst = "print";return INSTRUC;}

\"[^\f\v\n\0]*\"  		{yylval.str = strndup(yytext + 1, yyleng - 2);return STR;}

[0-9a-f]+h|[0-9]+b?     { 	
							value = convert_to_int(yytext,yyleng);

                         	if(value >= MIN && value <= MAX)
                         		yylval.num = value;
						 	
						 	else{ 
						 		printf("\nRange of number should be from -65534 to 65535");
						       	exit(1);
							}
							return NUMBER;			
						} 

[a-z]         			{ 	
							if(yyleng==1) {
				    			yylval.reg = yytext[0]; return REG;
							}

							else {
				    			yyerror("\nError:Undefined token\nError");
				    			exit(1);
				  			}
						}

","            			{return COMA;}

":"             		{return COLON;}
                         
[a-z][a-z0-9]* 			{yylval.label = strndup(yytext,yyleng);return LABL;}

"["            			{return SBR;}

"]"            			{return CBR;}

;[^\n\f\r\v]*   ;     

[[:space:]]     ;

.              			{yyerror("\nUndefined token"); exit(1);}

%%
