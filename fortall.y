%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "fortall.h"

void yyerror(char *);
int yylex(void);


int n_var;

struct var vars[CAPACITY_VAR];

void show_variables(void)
{
    for (int i = 0; i < n_var; i++)
    {
        char name_char;
        switch(vars[i].value.type)
        {
            case TYPE_CHAR:         name_char = 'C';    break;
            case TYPE_INT:          name_char = 'I';    break;
            case TYPE_REAL:         name_char = 'R';    break;
            case TYPE_UNDEFINED:    name_char = 'U';    break;
            default:                name_char = '?';    break;
        }

        printf("A %i-esima variavel mais cringe do sistema é:\t%s\t%c \n", i, vars[i].name, name_char);
    }
}

int var_find_or_set(char name[static 2])
{
    int var_i = 0;

    while (var_i < n_var && strcmp(name, vars[var_i].name))
    {
        var_i++;
    }

    if (CAPACITY_VAR == var_i)
    {
        fprintf(stderr, "Can't store this much variable.\n");
        exit(EXIT_FAILURE);
    }

    if (var_i == n_var)
    {
        if (NULL == (vars[var_i].name = malloc(strlen(name))))
        {
            fprintf(stderr, "Can't store variable name.\n");
            exit(EXIT_FAILURE);
        }

        printf("Defini uma variável foda de nome %s. \n", name);
        (void)strcpy(vars[var_i].name, name);
        n_var++;
    }

    return var_i;
}

%}

%token PUBLICO ESTATICO ABISMO PRINCIPAL
%token CARACTERE INTEIRO REAL
%token SE ENTAO SENAO
%token ENQUANTO
%token ESCREVER LER

/* Definição de um Token*/
%union {
    char   *string_literal;
    char    char_const;
    int      int_const;
    double  real_const;
    int     var_id;
    enum type type;
}

%token <string_literal> STRING_LITERAL
%token <char_const>     CHAR_CONST
%token  <int_const>      INT_CONST
%token <real_const>     REAL_CONST
%token <var_id>         VAR_ID

%right OR
%right AND
%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/' '%'
%nonassoc UMINUS
%nonassoc UNEG

%nonassoc SEX
%nonassoc SENAO

/* não terminais */
%type <type>         tipo lista_nomes


%%

programa : PUBLICO ESTATICO ABISMO PRINCIPAL '(' ')' '{' declaracao '}' { printf("Reconheci um programa\n"); show_variables(); exit(0); }
	 ;

declaracao : dec_variavel comando lista_comando { printf("Reconheci uma declaracao\n"); }
	   ;

dec_variavel : tipo lista_nomes ';' dec_variavel { printf("Reconheci decl de var\n"); }
             | 
             ;

lista_nomes : lista_nomes ',' VAR_ID {vars[$3].value.type = $<type>0;}  
            | VAR_ID {vars[$1].value.type = $<type>0; } 
	        ;
        
tipo : INTEIRO      {$$ = TYPE_INT;}
     | CARACTERE    {$$ = TYPE_CHAR;}
     | REAL         {$$ = TYPE_REAL;}
     ;

comando : SE       '(' exp ')' ENTAO comando %prec SEX     { printf("Se simples\n");   }
        | SE       '(' exp ')' ENTAO comando SENAO comando { printf("Se com senao\n"); }
        | ENQUANTO '(' exp ')' comando                     { printf("Entao\n"); }
        | VAR_ID '=' exp ';'                  { printf("Atribuicao\n"); }
        | ESCREVER '(' STRING_LITERAL ')' ';' { printf("Escrevi string\n"); }
        | ESCREVER '(' exp            ')' ';' { printf("Escrevi exp\n"); }
        | LER      '(' var            ')' ';' { printf("Li var\n"); } 
        | '{' comando lista_comando '}'       { printf("lista de comando\n"); }
        ;

lista_comando : comando lista_comando
	      |
	      ;

var : VAR_ID { printf("Reconheci variavel\n"); };
    ;

exp : CHAR_CONST   { printf("Reconheci constante de caractere\n"); }
    |  INT_CONST   { printf("Reconheci constante inteira\n"); }
    | REAL_CONST   { printf("Reconheci constante real\n"); }
    | var          { printf("Reconheci variavel\n"); }
    | '(' exp ')'  { printf("Reconheci parentesis\n"); }
    | '-' exp %prec UMINUS { printf("Reconheci uminus\n"); }
    | '!' exp %prec UNEG   { printf("Reconheci uma negacao\n"); }
    | exp '+' exp { printf("Reconheci uma soma\n"); }
    | exp '-' exp { printf("Reconheci uma subtracao\n"); }
    | exp '*' exp { printf("Reconheci uma multiplicacao\n"); }
    | exp '/' exp { printf("Reconheci uma divisao\n"); }
    | exp EQ  exp { printf("Reconheci uma comparacao ==\n"); }
    | exp GE  exp { printf("Reconheci uma comparacao >=\n"); }
    | exp LE  exp { printf("Reconheci uma comparacao <=\n"); }
    | exp '>' exp { printf("Reconheci uma comparacao >\n"); }
    | exp '<' exp { printf("Reconheci uma comparacao <\n"); }
    | exp AND exp { printf("Reconheci um AND\n"); }
    | exp OR  exp { printf("Reconheci um OR\n");  }
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

