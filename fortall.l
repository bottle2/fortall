%{
#include <stdlib.h>
#if 0
#include "fortall.h"
#include "y.tab.h"
#endif

char buf[100];
char *s;
// Educative string tutorial.
// TODO Make dynamic.

void yyerror(char *error) { printf("%s\n", error); }
%}
%x COMMENT
%x STRING

%%

 /* Início. */
"publico"   printf("public\n");
"estatico"  printf("static\n");
"vacuo"     printf("void\n");
"principal" printf("main\n");

 /* Tipos. */
"caractere" printf("Tipo caractere\n"); 
"inteiro"   printf("Tipo inteiro\n");
"real"      printf("Tipo real\n");

 /* Estruturas condicionais. */
"se"    printf("Se\n");
"entao" printf("Então\n");
"senao" printf("senao\n");

 /* Estrutura de repetição. */
"enquanto" printf("Enquanto\n");

 /* Entrada e saída. */
"escrever" printf("Escrever\n");
"ler"      printf("Ler\n");

 /* Subtração, soma, multiplicação, divisão, módulo. */
 /* Parêntesis, chaves. */
 /* Maior e menor, negação, atribuição, ponto e vírgula, vírgula. */
[-+*/%(){}<>!=;,] printf("Achei %c\n", *yytext);

 /* Operadores relacionais. */
">=" printf("Maior ou igual\n");
"<=" printf("Menor ou igual\n");
"==" printf("Igualdade\n");
"!=" printf("Diferente\n");

 /* Operadores lógicos. */
"&&" printf("Operação lógica E\n");
"||" printf("Operação lógica OU\n");

 /* Comentários. */
"/*"          { BEGIN COMMENT; printf("Abre comentário\n");  }      
<COMMENT>.
<COMMENT>"*/" { BEGIN 0;       printf("Fecha comentário\n"); }

 /* Cadeias de caracteres. */
\"           { BEGIN STRING; s = buf; }
<STRING>\\n  { *s++ = '\n';           }
<STRING>\\t  { *s++ = '\t';           }
<STRING>\\\" { *s++ = '\"';           }
<STRING>\\\\ { *s++ = '\\';           }
<STRING>\n   { fprintf(stderr, "Invalid string\n"); exit(EXIT_FAILURE); }
<STRING>\"   {
                 *s = '\0';
                 BEGIN 0;
                 printf("String identificada: %s\n", buf);
             }
<STRING>.    { *s++ = *yytext;        }

 /* Literal de caractere. */
'\\t'  printf("Reconheceu caractere tab\n");
'\\n'  printf("Reconheceu caractere de nova linha\n");
'\\\"' printf("Reconheceu caractere de aspas\n");
'\\\\' printf("Reconheceu caractere barra\n");
'.'    printf("Reconheceu caractere '%c'\n", yytext[1]);

 /* Números inteiros. */
[0-9]+ printf("Reconheci %d\n", atoi(yytext));

 /* Números reais. */
[0-9]*\.[0-9]* printf("Reconheci %f\n", strtod(yytext, NULL));

 /* Variáveis. */
[a-zA-Z_][a-zA-Z0-9_]* printf("Achei uma variável %s\n", yytext);

 /* Espaço em branco. */
[ \t\n]+ printf("Espaço em branco\n");

 /* Caracteres desconhecidos. */
. yyerror("Caractere desconhecido");

%%

int yywrap(void)
{
    return 1;
}

int main(void)
{
    yylex();
    return 0;
}
