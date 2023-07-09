#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <stdbool.h>
#include "y.tab.h"
#include "fortall.h"

struct generic_value empty;

static bool gvtob (struct generic_value gv)
{ 
    switch (gv.type)
    {
        case     TYPE_INT:  return gv.i;        break;
        case     TYPE_REAL: return gv.r;        break;
        case     TYPE_CHAR: return gv.c;        break;
        default: yyerror("estorou a bagaça.");  break;
    }
    return false;
}

struct generic_value ex(struct tree_node tnd[static 1])
{
    switch (tnd->type)
    {
         //Recebeu uma Constante.
        case CONST:
            return tnd->con;

         //Recebeu uma Variável.
        case VID: 
        {
            struct var* v = &vars[tnd->var_id];

            // TODO: Escrever o nome da variavel.
            if(TYPE_UNDEFINED == v->value.type) 
            {
                yyerror("Erro (interpretador): a variavel nao foi declarada previamente.");
            }
            if(v->is_initialized)
            {
                yyerror("Erro (interpretador): a variavel nao foi inicializada previamente.");
            }
            return vars[tnd->var_id].value;
        }
            

/*comando : SE       '(' exp ')' ENTAO comando %prec SEX    { $$ = opr(SE      , 2, $3, $6);     }
        | SE       '(' exp ')' ENTAO comando SENAO comando  { $$ = opr(SE      , 3, $3, $6, $8); }
        | ENQUANTO '(' exp ')' comando                      { $$ = opr(ENQUANTO, 2, $3, $5);     }
        | var '=' exp ';'                                   { $$ = opr('='     , 2, $1, $3);     }
        | ESCREVER '(' STRING_LITERAL ')' ';'               { $$ = opr(ESCREVER, 1, (struct tree_node){STRING, .str = $3}); }
        | ESCREVER '(' exp            ')' ';'               { $$ = opr(ESCREVER, 1, $3); }
        | LER      '(' var            ')' ';'               { $$ = opr(LER     , 1, $3); } 
        | '{' lista_comando '}'                             { $$ = $2; }
            lista_comando : lista_comando comando           { $$ = opr(';', 2, $1, $2); }
        | '-' exp %prec UMINUS                              { $$ = opr(UMINUS, 1, $2);     }
        | '!' exp %prec UNEG                                { $$ = opr('!'   , 1, $2);     }
        | exp '+' exp                                       { $$ = opr('+'   , 2, $1, $3); }
        | exp '-' exp                                       { $$ = opr('-'   , 2, $1, $3); }
        | exp '*' exp                                       { $$ = opr('*'   , 2, $1, $3); }
        | exp '/' exp                                       { $$ = opr('/'   , 2, $1, $3); }
        | exp EQ  exp                                       { $$ = opr(EQ    , 2, $1, $3); }
        | exp GE  exp                                       { $$ = opr(GE    , 2, $1, $3); }
        | exp LE  exp                                       { $$ = opr(LE    , 2, $1, $3); }
        | exp '>' exp                                       { $$ = opr('>'   , 2, $1, $3); }
        | exp '<' exp                                       { $$ = opr('<'   , 2, $1, $3); }
        | exp AND exp                                       { $$ = opr(AND   , 2, $1, $3); }
        | exp OR  exp                                       { $$ = opr(OR    , 2, $1, $3); }*/
        //Recebeu uma Operação.
        case OPR:
            switch (tnd->opr.oper)
            {
                case SE:
                    //Se condicional é verdadeira, executa.
                    if(gvtob(ex(&tnd->opr.op[0])))
                    {
                        ex(&tnd->opr.op[1]);
                    }           
                    //Senão e se for um senão (der suporte à um else)         
                    else if(tnd->opr.nops == 3)
                    {
                        ex(&tnd->opr.op[2]);
                    }
                    break;
                case ENQUANTO:
                    while(gvtob(ex(&tnd->opr.op[0])))
                    {
                        ex(&tnd->opr.op[1]);           
                    }
                    break;
                case '=':
                {
                    struct generic_value res = ex(&tnd->opr.op[1]);
                    switch (vars[tnd->opr.op[0].var_id].value.type)
                    {
                        case TYPE_INT:
                            switch (res.type)
                            {
                                case TYPE_INT:  vars[tnd->opr.op[0].var_id].value.i = res.i;     break;
                                case TYPE_REAL: vars[tnd->opr.op[0].var_id].value.i = res.r;     break; // Se for um double, o C por padrão vai truncar para converter implicitamente para inteiro;
                                case TYPE_CHAR: vars[tnd->opr.op[0].var_id].value.i = res.c;     break; // Se for um char, o C por padrão vai pegar o valor inteiro que representa o char em ASCII
                                default: yyerror("Erro (Interpretador): Tipo não existente durante atribuição (Origem).");   break;
                            }
                            break;
                        case TYPE_REAL:
                            switch (res.type)
                            {
                                case TYPE_INT:  vars[tnd->opr.op[0].var_id].value.r = res.i;     break; // Se for um inteiro, o C faz a conversão implicita.
                                case TYPE_REAL: vars[tnd->opr.op[0].var_id].value.r = res.r;     break; 
                                case TYPE_CHAR: vars[tnd->opr.op[0].var_id].value.r = res.c;     break; // Se for um char, o C por padrão vai perar o valor inteiro que representa o char em ASCII e depois fazer uma conversão implicita para real
                                default: yyerror("Erro (Interpretador): Tipo não existente durante atribuição (Origem).");   break;
                            }
                            break;
                        case TYPE_CHAR:                             
                            switch (res.type)
                            {
                                case TYPE_INT:  vars[tnd->opr.op[0].var_id].value.c = res.i;     break; // Se for um inteiro, o C faz a conversão implicita (todo char é do tipo inteiro em C, porém com o tamanho menor).
                                case TYPE_REAL: vars[tnd->opr.op[0].var_id].value.c = res.r;     break; // Se for um real, converte para inteiro de maneira implicita e posteriormente o resultado é o mesmo do exemplo acima.
                                case TYPE_CHAR: vars[tnd->opr.op[0].var_id].value.c = res.c;     break; 
                                default: yyerror("Erro (Interpretador): Tipo não existente durante atribuição (Origem).");   break;
                            }
                            break;
                        default: 
                            yyerror("Erro (Interpretador): Tipo não existente durante atribuição (Destino).");   break; 
                            break;
                    }
                    vars[tnd->opr.op[0].var_id].is_initialized = true; 
                }
                    break;
                case ESCREVER:
                    if(STRING == tnd->opr.op[0].type)
                        printf("%s", tnd->opr.op[0].str);
                    else   
                    {        
                        struct generic_value res = ex(&tnd->opr.op[0]);         
                        switch (res.type)
                        {
                            case TYPE_INT:  printf("%i", res.i);     break; // Se for um inteiro, o C faz a conversão implicita (todo char é do tipo inteiro em C, porém com o tamanho menor).
                            case TYPE_REAL: printf("%f", res.r);     break; // Se for um real, converte para inteiro de maneira implicita e posteriormente o resultado é o mesmo do exemplo acima.
                            case TYPE_CHAR: printf("%c", res.c);     break; 
                            default: yyerror("Erro (Interpretador): Tipo não existente durante atribuição (Origem).");   break;
                        }                        
                    }
                    break;
                case LER:
                    switch (vars[tnd->opr.op[0].var_id].value.type)
                    {                      
                        //TODO: Revisar possíveis alterações?  
                        case TYPE_INT:  scanf("%i", &vars[tnd->opr.op[0].var_id].value.i);     break; // Isso é culpa do programador, ele não deveria ler uma variável que não seja do tipo texto (caracter/string)
                        case TYPE_REAL: scanf("%lf", &vars[tnd->opr.op[0].var_id].value.r);     break; // Isso é culpa do programador, ele não deveria ler uma variável que não seja do tipo texto (caracter/string)
                        case TYPE_CHAR: scanf("%c", &vars[tnd->opr.op[0].var_id].value.c);     break; 
                        default: yyerror("Erro (Interpretador): Tipo não existente durante atribuição (Origem).");   break;
                    }   
                    vars[tnd->opr.op[0].var_id].is_initialized = true; 
                    /* code */
                    break;

                case ';':
                    /* code */
                    ex(&tnd->opr.op[0]); 
                    return ex(&tnd->opr.op[1]); 
                    break;
                
                
                default:
                    break;
            }

            break;
        case STRING:
            assert(!"Erro (Interpretador): não foi possível executar uma STRING.\n");
            break;
        default:
            // TODO: Definir mensagem de erro mais clara. 
            yyerror("Erro (Interpretador): não existe esse tipo de tree node.\n");
            break;
    }
    return empty;
}