#include<stdio.h>
#include<string.h>
#include<stdlib.h>

struct node {
	int key;
	struct node *next;
};

typedef struct node Node;

Node *top = NULL;

void push(Node *new_node)
{
	new_node->next = top;
	top = new_node;
}

Node *pop(void)
{
	Node *tmp;
	tmp = top;

	if (top)
		top = top->next;

	return tmp;
}

void push_address(int pc)
{
	Node *new_node = malloc(sizeof(Node));

	if (!new_node) {
		printf("\nError:Malloc call func error!\n");
		exit(1);
	}

	new_node->key = pc;
	push(new_node);
}

int pop_address()
{
	int PC;
	Node *node = pop();

	if (!node) {
		printf("\nError:Stack empty! Control Back to OS\n");
		exit(1);
	}

	PC = node->key;
	free(node);

	return PC;
}