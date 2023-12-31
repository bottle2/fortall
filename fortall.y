%{
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "fortall.h"

int yylex(void);

extern int yylineno;

int n_var;

struct var vars[CAPACITY_VAR];

void show_variables(void)
{
    for (int i = 0; i < n_var; i++)
    {
        printf(
            "A %i-esima variavel %s %s de tipo ",
            i, vars[i].name, vars[i].is_initialized ? "inicializada" : "nao inicializada"
        );

        switch(vars[i].value.type)
        {
            case TYPE_CHAR:      printf("caractere value=%c\n", vars[i].value.c); break;
            case TYPE_INT:       printf("inteiro value=%i\n", vars[i].value.i); break;
            case TYPE_REAL:      printf("real value=%f\n", vars[i].value.r); break;
            case TYPE_UNDEFINED: printf("desconhecido value=_\n"); break;
            default:             printf("nao classificado value=?\n"); break;
        }
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
        yyerror("erro interno - Nao pode haver tantas variaveis.\n");
    }

    if (var_i == n_var)
    {
        if (NULL == (vars[var_i].name = malloc(strlen(name) + 1)))
        {
            yyerror("erro interno - Nao ha memoria para o nome da variavel.\n");
        }

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
    struct tree_node node;
    enum   type      type;
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

programa : PUBLICO ESTATICO ABISMO PRINCIPAL '(' ')' '{' declaracao '}' { printf("Fim da execucao.\n"); show_variables(); exit(0); }
	 ;

declaracao : dec_variavel lista_comando { (void)ex(&$2); }
	   ;

dec_variavel : tipo lista_nomes ';' dec_variavel
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

var : VAR_ID { $$ = (struct tree_node){VID, .var_id = $1, yylineno}; }

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
    printf("Na linha %d: %s", force_lineno > 0 ? force_lineno : yylineno, error);
    exit(EXIT_FAILURE);
}

struct tree_node opr(int oper, int nops, ...)
{
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

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        fprintf(stderr, "Usage: fortall <source-code>\n");
        exit(EXIT_FAILURE);
    }

    extern FILE *yyin;

    yyin = fopen(argv[1], "rb");

    if (NULL == yyin)
    {
        perror("Nao posso interpretar arquivo.");
        return EXIT_FAILURE;
    }

    yyparse();
    return 0;
}

