%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>

	int tolower(int c);
	int yyparse();
	FILE *yyin;
	int yyerror(char *s);
	int yylex();
	void execute(char *c);
	int get_index(const char c);
	int convert_to_int(const char *c, int n);
	int get_line_from_label(const char *a);
	char *yytext;
	int yylineno;
	extern int PC;
	typedef enum{false = 0, true} bool;
	typedef struct yy_buffer_state * YY_BUFFER_STATE;
	int yyparse();
	YY_BUFFER_STATE yy_scan_string(char * str);
	void yy_delete_buffer(YY_BUFFER_STATE buffer);
	void push_address(int pc);
	int pop_address();

	int parseit(char *file_name);
	int regs[26];
	bool zf = 0; //zero flag

%}

%union {
	int num;
	char reg;
	char *inst;
	char *label;
	char *str;
}

%token REG INSTRUC LABL
%token NUMBER COMA COLON
%token SBR CBR STR
%type <inst> INSTRUC
%type <num> NUMBER
%type <reg> REG
%type <label> LABL
%type <num> term
%type <str> STR

%%

prog:
| LABL COLON line
| line
| LABL COLON
;

line: INSTRUC REG COMA term {
	int r = get_index($2);

	if (!strcasecmp($1, "add")) {
		printf("Addition of Reg %c and %d\n", $2, $4);
		regs[r] += $4;
	}

	else if (!strcasecmp($1, "sub")) {
		printf("Subtraction of Reg %c and %d\n", $2, $4);
		regs[r] -= $4;
	}

	else if (!strcasecmp($1, "mov")) {
		printf("Moving %d to Reg %c\n", $4, $2);
		regs[r] = $4;
	}

	else if (!strcasecmp($1, "mul")) {
		printf("Multiplying Reg %c and %d\n", $2, $4);
		regs[r] *= $4;
	}

	else if (!strcasecmp($1, "div")) {
		printf("Dividing Reg %c and %d\n", $2, $4);
		regs[r] /= $4;
	}

	else if (!strcasecmp($1, "cmp")) {
		printf("Comparing Reg %c and %d\n", $2, $4);
		if (regs[r] == $4)
			zf = 1;
		else 
			zf = 0;
	}

	else {
		yyerror("\nError:Wrong Instruction or arguments\nError");
		exit(1);
	}

}

| INSTRUC LABL {
	int temp = get_line_from_label($2);
	if (temp < 0) {
		yyerror("\nError:Label not found\nError");
		exit(1);
	}

	if (!strcmp($1, "jmp"))
		PC = temp;

	else if (!strcmp($1, "je")) {
		if (zf == 1)
			PC = temp;
	}

	else if (!strcmp($1, "jne")) {
		if (zf == 0)
			PC = temp;
	}

	else if (!strcmp($1, "call")) {
		push_address(PC);
		PC = temp;
	}

	else {
		yyerror("\nError:Wrong Instruction or Arguments\nError");
		exit(1);
	}

}

| INSTRUC {
	if (!strcmp($1, "ext")) {
		printf("\nExiting..\n");
		exit(0);
	}

	else if (!strcmp($1, "ret")) {
		PC = pop_address();
	}

	else {
		yyerror("\nError: Wrong Instruction or Arguments\nError");
		exit(1);
	}

}

| INSTRUC STR {
	if (!strcmp($1, "print")) {
		int i;
		for (i = 0; i < strlen($2);) {

			if ($2[i] == '\\') {

				if ($2[i + 1] == 'n')
					printf("\n");

				else if ($2[i + 1] == 't')
					printf("\t");

				else if ($2[i + 1] == '\\')
					printf("\\");

				else if ($2[i + 1] == '\"')
					printf("\"");

				else if ($2[i + 1] == '\0') {
					yyerror("\nError:Missing End quote\nError");
					exit(1);
				}

				else
					printf("%c", $2[i + 1]);

				i += 2;
			}

			else if ($2[i] == '\"') {
				yyerror("\nError: Missing End quote\nError");
				exit(1);
			}

			else {
				printf("%c", $2[i]);
				i++;
			}
		}
	}

	else {
		yyerror("\nError: Wrong Instruction or Arguments\nError");
		exit(1);
	}

}

| INSTRUC REG {
	if (!strcmp($1, "print"))
		printf("%d", regs[get_index($2)]);

	else {
		yyerror("\nError:Wrong Instruction or Arguments\nError");
		exit(1);
	}
}

;
	
term : REG {$$ = regs[get_index($1)];}

| NUMBER   { }
;

%%

void execute(char *line)
{
	YY_BUFFER_STATE buffer = yy_scan_string(line);

	if (yyparse())
		exit(1);

	yy_delete_buffer(buffer);
}

int get_index(const char c)
{
	char ch = tolower(c);
	if (ch >= 'a' && ch <= 'z') {
		return ch - 97;
	}

	return -1;
}

int convert_to_int(const char *c, int n)
{
	if (tolower(c[n - 1]) == 'b') {
		for (int i = 0; i < n - 1; i++) {
			if (c[i] != '0' && c[i] != '1') {
				printf("\nError on Line %d: Only 0 or 1 allowed in binary", yylineno);
				exit(1);
			}
		}
		return strtol(c, NULL, 2);
	}

	else if (tolower(c[n - 1]) == 'h') {
		for (int i = 0; i < n - 1; i++) {
			if ((c[i] < '0' || c[i] > '9') && (tolower(c[i]) < 'a' || tolower(c[i]) > 'f')) {
				printf("\nError on Line %d: Only 0-9 and a-f are allowed in hexadecimal", yylineno);
				exit(1);
			}
		}
		return strtol(c, NULL, 16);
	}

	else {
		for (int i = 0; c[i] ; i++) {
			if (c[i] < '0' || c[i] > '9') {
				printf("\nError on Line %d: Only 0-9 digits allowed for number", yylineno);
				exit(1);
			}
		}
		return strtol(c, NULL, 10);
	}
}


int yyerror(char *s)
{
	fprintf(stderr, "%s on line %d: %s token error", s, PC, yytext);
	return 1;
}
