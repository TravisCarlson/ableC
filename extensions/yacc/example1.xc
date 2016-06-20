/* ===== Definition Section ===== */

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

%union {
  int i;
  int value;
}

%token <i> INT_LIT
%token OP_PLUS
%token OP_MINUS
%token OP_TIMES
%token OP_DIVIDE
%token LPAREN
%token RPAREN

%start program

%left OP_PLUS OP_MINUS
%left OP_TIMES OP_DIVIDE

%type<value> expr

/*%define parse.error verbose*/

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

#define UNUSED(x) ((void)(x))

//#include "lex.yy.h"

int main(int argc, char **argv)
{
  /* squelch compiler warnings */
  UNUSED(yyunput);
  UNUSED(input);

  /* read from argv[1] if given; otherwise stdin */
  if (argc > 1) {
    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
      fprintf(stderr, "%s: error: %s: %s\n", argv[0], argv[1],
        strerror(errno));
      return -1;
    }
    filename = argv[1];
  }

  int status = yyparse();

  if (status == 0 && error_cnt == 0) {
    printf("%d\n", result);
  }

  fclose(yyin);
  yylex_destroy();

  return status;
}

void yyerror(const char *msg)
{
  ++error_cnt;
  fprintf(stderr, "%s:%d: error: %s at ‘%s‘\n", filename, line_no,
      msg, yytext);
}

