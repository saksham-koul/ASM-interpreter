#include<stdio.h>
#include<fcntl.h>
#include<stdlib.h>
#include<unistd.h>
#include<string.h>
#include<sys/types.h>
#include<sys/stat.h>

#include "assem.tab.h"					//output from compiling assem.y

typedef enum {false = 0, true} bool;

void execute();

int PC = 0;								//program counter
bool FLAGS = false;

void do_execute(const char *);
void init_regs(void);

int isspace(int c);

struct label_node {
	char *label;
	int lineno;
};

size_t maxl = 10;
char **program;
int total_lines = 0, total_labels = 0;

struct label_node *labels;

int get_line_from_label(const char *label)
{
	for (int i = 0; i < total_labels; i++) {
		if (!strcasecmp(label, labels[i].label)) {
			return labels[i].lineno;
		}
	}

	return -1;
}

char *strndup(const char *s, size_t n)
{
	char *p;
	size_t n1;

	for (n1 = 0; n1 < n && s[n1] != '\0'; n1++);

	p = malloc(n + 1);

	if (p != NULL) {
		memcpy(p, s, n1);
		p[n1] = '\0';
	}

	return p;
}

char *addstring(const char *a, const char *b)		//function to add 2 strings a & b
{
	char *c = malloc((strlen(a) + strlen(b) + 2) * sizeof(char));

	if (c == NULL) {
		printf("\nError: malloc error in addstring.");
		exit(1);
	}
	strcpy(c, a);
	strcat(c, b);

	return c;
}

char *trimspaces(char *a)
{
	while (*a != '\0') {
		if (isspace(*a))			//to remove leading spaces
			a++;
		else
			break;
	}

	char *b = a;
	while (*b != '\0') {
		if (!isspace(*b))
			b++;
		else
			break;
	}

	*b = '\0';

	return a;
}

int text_parser(char *filename)
{
	int j;
	char *line = malloc(maxl * sizeof(char));

	if (!line) {
		printf("\nMemory not allocated!!");
		return 1;
	}

	FILE *file = fopen(filename, "r");

	if (!file) {
		perror("File Error\n");
		exit(1);
	}

	char c, prev;
	bool inquote = false;
	int lastlabel_line = -1;

	while (1) {
		c = fgetc(file);

		if (c == '\n' || c == '\r')
			total_lines++;

		else if (c == '\"' && prev != '\\')
			inquote = !inquote;

		else if (c == ':' && !inquote) {					//label found
			if (lastlabel_line == total_lines) {
				printf("\nError: Two Labels on single line!!");
				return 1;
			}
			lastlabel_line = total_lines;
			total_labels++;
		}

		else if (c == EOF) {
			total_lines++;
			break;
		}
		prev = c;
	}

	if (inquote) {
		printf("\nExpected End Quotes!!");
		fclose(file);
		return 1;
	}

	if (total_labels) {
		labels = malloc(sizeof(struct label_node) * total_labels);

		if (!labels) {
			printf("\nError: Malloc labels error!\n");
			fclose(file);
			return 1;
		}

		memset(labels, 0, sizeof(labels));
	}

	program = malloc(sizeof(char*) * total_lines + 1);

	fseek(file, 0, SEEK_SET);

	char *buffer = malloc(sizeof(char));
	buffer[0] = '\0';
	size_t currentsize = 0;
	int current_line = 0, current_label = 0;


	while (fgets(line, maxl, file)) {		//reading from file line by line
		if (line[strlen(line) - 1] == '\n' || line[strlen(line) - 1] == '\r') {
			program[current_line] = addstring(buffer, line);

			if (strcmp(program[current_line], "\n"))
				current_line++;

			else
				total_lines--;

			free(buffer);
			buffer = malloc(sizeof(char));
			buffer[0] = '\0';
		}
		else
			buffer = addstring(buffer, line);
	}

	program[current_line] = addstring(buffer, "");

	free(buffer);
	free(line);
	fclose(file);

	printf("\nLines = %d, Labels = %d", total_lines, total_labels);

	for (int e = 0; e < total_lines; e++) {

		char *colon = strchr(program[e], ':');
		char *quote = strchr(program[e], '\"');

		if (quote && colon) {
			if (quote - colon > 0) {
				labels[current_label].label = trimspaces(strndup(program[e], (colon - program[e])));
				labels[current_label].lineno = e;

				for (j = 0; j < current_label; j++) {
					if (!strcmp(labels[j].label, labels[current_label].label)) {
						printf("\nError: Got repeated label: %s\n", labels[current_label].label);
						return 1;
					}
				}
				current_label++;
			}
		}

		else if (colon) {
			if (!(colon - program[e])) {
				printf("\nError: Label name can't be empty!!");
				return 1;
			}

			labels[current_label].label = trimspaces(strndup(program[e], (colon - program[e])));
			labels[current_label].lineno = e;

			for (j = 0; j < current_label; j++) {
				if (!strcmp(labels[j].label, labels[current_label].label)) {
					printf("\nError: Got repeated label: %s\n", labels[current_label].label);
					return 1;
				}
			}
			current_label++;
		}
	}

	return 0;
}

int main(int argc, char *argv[])
{
	if (argc != 2) {
		printf("\nEnter the command in format: a <inputfilename>");
		return 1;
	}

	if (text_parser(argv[1])) {
		return 1;
	}

	printf("\nExecuting...");

	while (PC < total_lines) {
		execute(program[PC++]);
	}

	free(program);
	free(labels);

	return 0;
}