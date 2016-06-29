#include <stdio.h>

/*

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void yyerror(const char *msg);
int yylex(void);
static int line_no = 1;
static char *filename = "stdin";
static int error_cnt = 0;
static int result = -1;

%}
*/

/*
%union {
  int i;
  int value;
}

%token <i> INT_LIT
*/

%token OP_PLUS
%token OP_MINUS
%token OP_TIMES
%token OP_DIVIDE
%token LPAREN
%token RPAREN

%start program

%left OP_PLUS OP_MINUS
%left OP_TIMES OP_DIVIDE
/*

%type<value> expr

%define parse.error verbose
*/

%%

/* ==== Grammar Section ==== */

/* Productions */               /* Semantic actions */
program     : expr                  { result = $1; }
            ;

expr        : expr OP_PLUS expr     { $$ = $1 + $3; }
            | expr OP_MINUS expr    { $$ = $1 - $3; }
            | expr OP_TIMES expr    { $$ = $1 * $3; }
            | expr OP_DIVIDE expr   { $$ = $1 / $3; }
            | LPAREN expr RPAREN    { $$ = $2; }
            | INT_LIT               { $$ = $1; }
            ;

%%

int main(void)
{
  int x = 42;
  printf("%d\n", x);
  return 0;
}

