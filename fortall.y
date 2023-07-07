%{
#include <stdlib.h>
#include <string.h>

void yyerror(char *);

#define CAPACITY_VAR    4095
#define CAPACITY_STRING 4095

struct variavel
{
    char *name;
    enum  type { TYPE_CHAR, TYPE_INT,   TYPE_REAL };
    union      { char c;    int  i;   double r;   }
};

struct variavel variaveis[CAPACITY_VAR];

static inline int variavel_find(char name[static 2])
{
    while (*current != NULL && !strcmp(name, (*current)->name))
    {
        current = &(*current)->next;
    }
}

%}

%token PUBLICO ESTATICO VACUO PRINCIPAL
%token CARACTERE INTEIRO REAL
%token SE ENTAO SENAO
%token ENQUANTO
%token ESCREVER LER

%union {
    char    literal_char;
    char   *literal_string;
    int     literal_int;
    double  literal_real;
}

%token <literal_char>   LITERAL_CHAR;
%token <literal_string> LITERAL_STRING;
%token <literal_int>    LITERAL_INT;
%token <literal_real>   LITERAL_REAL;

%%

programa : PUBLICO ESTATICO ABISMO PRINCIPAL '(' ')' '{' declaracao '}'
	 ;

declaracao : dec_variavel comando
	   ;

dec_variavel : tipo lista_nomes ';' dec_variavel
             | 
             ;

lista_nomes : ID lista_n
	    ;

lista_n : ',' ID lista_n
        |
        ;

tipo : INTEIRO
     | CARACTERE
     | REAL
     ;

comando : SE       '(' exp ')' ENTAO COMANDO parte_senao
        | ENQUANTO '(' exp ')' comando
        | var '=' exp ';'
        | ESCREVER '(' LITERAL ')' ';'
        | ESCREVER '(' var     ')' ';'
        | LER      '(' var     ')' ';'
        | comando comando
        ;

parte_senao : SENAO comando
            |
            ;

var : ID
    ;

exp : NUMERAL
    | LITERAL
    | var
    | '(' exp ')'
    | exp '+'  exp
    | exp '-'  exp
    | exp '*'  exp
    | exp '/'  exp
    | exp '==' exp
    | exp '>=' exp
    | exp '<=' exp
    | exp '>'  exp
    | exp '<'  exp
    | '!' exp
    | exp '&&' exp
    | exp '||' exp
    ;

%%

void yyerror(char *error)
{
    printf("%s\n", error);
}

int main(void)
{
    yyparse();
    return 0;
}

