%{
#include <stdarg.h>
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
        if (NULL == (vars[var_i].name = malloc(strlen(name) + 1)))
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

struct tree_node opr(int oper, int nops, ...);

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

    enum   type      type;
    struct tree_node node;
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
%type <type> tipo
%type <node> var exp comando lista_comando

%%

programa : PUBLICO ESTATICO ABISMO PRINCIPAL '(' ')' '{' declaracao '}' { printf("Reconheci um programa\n"); show_variables(); exit(0); }
	 ;

declaracao : dec_variavel lista_comando { printf("Reconheci uma declaracao\n"); }
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

comando : SE       '(' exp ')' ENTAO comando %prec SEX     { $$ = opr(SE      , 2, $3, $6);     }
        | SE       '(' exp ')' ENTAO comando SENAO comando { $$ = opr(SE      , 3, $3, $6, $8); }
        | ENQUANTO '(' exp ')' comando                     { $$ = opr(ENQUANTO, 2, $3, $5);     }
        | var '=' exp ';'                                  { $$ = opr('='     , 2, $1, $3);     }
        | ESCREVER '(' STRING_LITERAL ')' ';'              { $$ = opr(ESCREVER, 1, (struct tree_node){STRING, .str = $3}); }
        | ESCREVER '(' exp            ')' ';'              { $$ = opr(ESCREVER, 1, $3); }
        | LER      '(' var            ')' ';'              { $$ = opr(LER     , 1, $3); } 
        | '{' lista_comando '}'                            { $$ = $2; }
        ;

var : VAR_ID { $$ = (struct tree_node){VID, .var_id = $1}; }

lista_comando : lista_comando comando { $$ = opr(';', 2, $1, $2); }
	      | comando               { $$ = $1; }
	      ;

exp : CHAR_CONST  { $$.type = CONST; $$.con.c  = $1; $$.con.type = TYPE_CHAR; }
    |  INT_CONST  { $$.type = CONST; $$.con.i  = $1; $$.con.type = TYPE_INT;  }
    | REAL_CONST  { $$.type = CONST; $$.con.r  = $1; $$.con.type = TYPE_REAL; }
    | var         { $$ = $1; }
    | '(' exp ')' { $$ = $2; }
    | '-' exp %prec UMINUS { $$ = opr(UMINUS, 1, $2);     }
    | '!' exp %prec UNEG   { $$ = opr('!'   , 1, $2);     }
    | exp '+' exp          { $$ = opr('+'   , 2, $1, $3); }
    | exp '-' exp          { $$ = opr('-'   , 2, $1, $3); }
    | exp '*' exp          { $$ = opr('*'   , 2, $1, $3); }
    | exp '/' exp          { $$ = opr('/'   , 2, $1, $3); }
    | exp EQ  exp          { $$ = opr(EQ    , 2, $1, $3); }
    | exp GE  exp          { $$ = opr(GE    , 2, $1, $3); }
    | exp LE  exp          { $$ = opr(LE    , 2, $1, $3); }
    | exp '>' exp          { $$ = opr('>'   , 2, $1, $3); }
    | exp '<' exp          { $$ = opr('<'   , 2, $1, $3); }
    | exp AND exp          { $$ = opr(AND   , 2, $1, $3); }
    | exp OR  exp          { $$ = opr(OR    , 2, $1, $3); }
    ;

%%

void yyerror(char *error)
{
    printf("%s\n", error);
}

struct tree_node opr(int oper, int nops, ...)
{
    printf("op = %d/%c\n", oper, oper);

    struct tree_node *nodes = malloc(sizeof (struct tree_node) * nops);

    if (NULL == nodes)
    {
        yyerror("out of memory");
    }

    va_list ap;

    va_start(ap, nops);
    for (int op_i = 0; op_i < nops; op_i++)
    {
        nodes[op_i] = va_arg(ap, struct tree_node);
    }
    va_end(ap);

    return (struct tree_node){OPR, .opr = {oper, nops, nodes}};
}

int main(void)
{
    yyparse();
    return 0;
}

