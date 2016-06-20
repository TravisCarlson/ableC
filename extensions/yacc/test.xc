#include <stdio.h>

%%

/* ==== Grammar Section ==== */

program     : expr
            ;

/* Productions */               /* Semantic actions */
/*
program     : expr                  { result = $1; }
            ;

expr        : expr OP_PLUS expr     { $$ = $1 + $3; }
            | expr OP_MINUS expr    { $$ = $1 - $3; }
            | expr OP_TIMES expr    { $$ = $1 * $3; }
            | expr OP_DIVIDE expr   { $$ = $1 / $3; }
            | LPAREN expr RPAREN    { $$ = $2; }
            | INT_LIT               { $$ = $1; }
            ;
*/

%%

int main(void)
{
  int x = 42;
  printf("%d\n", x);
  return 0;
}

