%{
#include <stdlib.h>
#include <stdio.h>
#include "fortall.h"
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
                 yylval.string_literal = malloc(strlen(buf) + 1);
                 if (NULL == yylval.string_literal)
                 {
                     fprintf(stderr, "No memory for string.\n");
                     exit(EXIT_FAILURE);
                 }
                 strcpy(yylval.string_literal, buf);
                 return STRING_LITERAL;
             }
<STRING>.    { check_buf(); *s++ = *yytext; }

 /* Literal de caractere. */
'\\t'  { yylval.char_const =    '\t';   return CHAR_CONST; }
'\\n'  { yylval.char_const =    '\n';   return CHAR_CONST; }
'\\\"' { yylval.char_const =    '\\';   return CHAR_CONST; }
'\\\\' { yylval.char_const =    '\"';   return CHAR_CONST; }
'.'    { yylval.char_const = yytext[1]; return CHAR_CONST; }

 /* Números inteiros. */
[0-9]+ { yylval.int_const = atoi(yytext); return INT_CONST; }

 /* Números reais. */
[0-9]*\.[0-9]* { yylval.real_const = strtod(yytext, NULL); return REAL_CONST; }

 /* Variáveis. */
[a-zA-Z_][a-zA-Z0-9_]* {
                           yylval.var_id = var_find_or_set(yytext);
                           return VAR_ID;
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
