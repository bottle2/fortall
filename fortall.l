%{
#include <stdlib.h>
#include <stdio.h>
#if 0
#include "fortall.h"
#endif
#include "y.tab.h"

char  buf[CAPACITY_STRING];
char *s;

static inline void check_buf(void)
{
    if (s - buf == CAPACITY_STRING - 1)
    {
        fprintf(stderr, "String is too long.\n");
        exit(EXIT_FAILURE);
    }
}

void yyerror(char *);
%}

%x COMMENT
%x STRING

%%

 /* Início. */
"publico"   return PUBLICO;
"estatico"  return ESTATICO;
"abismo"    return ABISMO;
"principal" return PRINCIPAL;

 /* Tipos. */
"caractere" return CARACTERE;
"inteiro"   return INTEIRO;
"real"      return REAL;

 /* Estruturas condicionais. */
"se"    return SE;
"entao" return ENTAO;
"senao" return SENAO;

 /* Estrutura de repetição. */
"enquanto" return ENQUANTO;

 /* Entrada e saída. */
"escrever" return ESCREVER;
"ler"      return LER;

 /* Subtração, soma, multiplicação, divisão, módulo. */
 /* Parêntesis, chaves. */
 /* Maior e menor, negação, atribuição, ponto e vírgula, vírgula. */
[-+*/%(){}<>!=;,] return *yytext;

 /* Operadores relacionais. */
">=" return GE;
"<=" return LE;
"==" return EQ;
"!=" return NE;

 /* Operadores lógicos. */
"&&" return AND;
"||" return OR;

 /* Comentários. */
 /* TODO "/*"  ([^*]|(\*[^/]?))*   "*/" */

"/*"          BEGIN COMMENT;
<COMMENT>.
<COMMENT>"*/" BEGIN 0;

 /* Cadeias de caracteres. */
 /* BUG Does not check `buf` limit */
\"           { BEGIN STRING; s = buf; }
<STRING>\\n  { check_buf(); *s++ = '\n'; }
<STRING>\\t  { check_buf(); *s++ = '\t'; }
<STRING>\\\" { check_buf(); *s++ = '\"'; }
<STRING>\\\\ { check_buf(); *s++ = '\\'; }
<STRING>\n   { fprintf(stderr, "Invalid string\n"); exit(EXIT_FAILURE); }
<STRING>\"   {
                 *s = '\0';
                 BEGIN 0;
                 yylval.string = malloc(strlen(buf));
                 if (NULL == string)
                 {
                     fprintf(stderr, "No memory for string.\n");
                     exit(EXIT_FAILURE);
                 }
                 strcpy(string, buf);
                 return LITERAL;
             }
<STRING>.    { check_buf(); *s++ = *yytext; }

 /* Literal de caractere. */
'\\t'  { yylval.literal_char =    '\t'; return LITERAL_CHAR; }
'\\n'  { yylval.literal_char =    '\n'; return LITERAL_CHAR; }
'\\\"' { yylval.literal_char =    '\\'; return LITERAL_CHAR; }
'\\\\' { yylval.literal_char =    '\"'; return LITERAL_CHAR; }
'.'    { yylval.literal_char = *yytext; return LITERAL_CHAR; }

 /* Números inteiros. */
[0-9]+ { yylval.literal_int = atoi(yytext); return LITERAL_INT; }

 /* Números reais. */
[0-9]*\.[0-9]* { yylval.literal_real = strtod(yytext, NULL); return LITERAL_REAL; }

 /* Variáveis. */
[a-zA-Z_][a-zA-Z0-9_]* {
                           int id = 
                       }

 /* Espaço em branco. */
[ \t\n]+

 /* Caracteres desconhecidos. */
. yyerror("Caractere desconhecido");

%%

int yywrap(void)
{
    return 1;
}
