#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <stdbool.h>

#include "fortall.h"
#include "y.tab.h"

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

#define COMB(LHS, RHS) ((1 << (LHS)) | (1 << (4 + (RHS))))

#define MAT_DECL(NAME, OP) \
static inline struct generic_value opr_##NAME(struct tree_node ops[static 2]) \
{ \
    struct generic_value res; \
\
    struct generic_value lhs = ex(ops + 0); \
    struct generic_value rhs = ex(ops + 1); \
\
\
    switch (COMB(lhs.type, rhs.type)) \
    { \
        case COMB(TYPE_CHAR, TYPE_CHAR): res.c = lhs.c OP rhs.c; res.type = TYPE_CHAR; break; \
        case COMB(TYPE_CHAR, TYPE_INT ): res.i = lhs.c OP rhs.i; res.type = TYPE_INT;  break; \
        case COMB(TYPE_CHAR, TYPE_REAL): res.r = lhs.c OP rhs.r; res.type = TYPE_REAL; break; \
        case COMB(TYPE_INT , TYPE_CHAR): res.i = lhs.i OP rhs.c; res.type = TYPE_INT;  break; \
        case COMB(TYPE_INT , TYPE_INT ): res.i = lhs.i OP rhs.i; res.type = TYPE_INT;  break; \
        case COMB(TYPE_INT , TYPE_REAL): res.r = lhs.i OP rhs.r; res.type = TYPE_REAL; break; \
        case COMB(TYPE_REAL, TYPE_CHAR): res.r = lhs.r OP rhs.c; res.type = TYPE_REAL; break; \
        case COMB(TYPE_REAL, TYPE_INT ): res.r = lhs.r OP rhs.i; res.type = TYPE_REAL; break; \
        case COMB(TYPE_REAL, TYPE_REAL): res.r = lhs.r OP rhs.r; res.type = TYPE_REAL; break; \
\
        default: \
            assert(!"Impossible case"); \
        break; \
    } \
\
    return res; \
}

#define LOG_DECL(NAME, OP) \
static inline struct generic_value opr_##NAME(struct tree_node ops[static 2]) \
{ \
    struct generic_value res = {.type = TYPE_INT}; \
\
    struct generic_value lhs = ex(ops + 0); \
    struct generic_value rhs = ex(ops + 1); \
\
\
    switch (COMB(lhs.type, rhs.type)) \
    { \
        case COMB(TYPE_CHAR, TYPE_CHAR): res.i = lhs.c OP rhs.c; break; \
        case COMB(TYPE_CHAR, TYPE_INT ): res.i = lhs.c OP rhs.i; break; \
        case COMB(TYPE_CHAR, TYPE_REAL): res.i = lhs.c OP rhs.r; break; \
        case COMB(TYPE_INT , TYPE_CHAR): res.i = lhs.i OP rhs.c; break; \
        case COMB(TYPE_INT , TYPE_INT ): res.i = lhs.i OP rhs.i; break; \
        case COMB(TYPE_INT , TYPE_REAL): res.i = lhs.i OP rhs.r; break; \
        case COMB(TYPE_REAL, TYPE_CHAR): res.i = lhs.r OP rhs.c; break; \
        case COMB(TYPE_REAL, TYPE_INT ): res.i = lhs.r OP rhs.i; break; \
        case COMB(TYPE_REAL, TYPE_REAL): res.i = lhs.r OP rhs.r; break; \
\
        default: \
            assert(!"Impossible case"); \
        break; \
    } \
\
    return res; \
}

#define MAT_XS(X) \
X(sum, '+', + ) \
X(sub, '-', - ) \
X(mul, '*', * ) \
X(div, '/', / )

#define LOG_XS(X) \
X(eq , EQ , ==) \
X(ge , GE , >=) \
X(le , LE , <=) \
X(grt, '>', > ) \
X(lst, '<', < ) \
X(and, AND, &&) \
X(or , OR , ||)

#define AS_MAT(NAME, SYMB, OP) MAT_DECL(NAME, OP)
#define AS_LOG(NAME, SYMB, OP) LOG_DECL(NAME, OP)
#define AS_CASE(NAME, SYMB, OP) case SYMB: return opr_##NAME(tnd->opr.op); break;

// Faltou mod %

MAT_XS(AS_MAT)
LOG_XS(AS_LOG)

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
                printf("variavel (undef) %s\n", v->name);
                yyerror("Erro (interpretador): a variavel nao foi declarada previamente.");
            }
            if(!v->is_initialized)
            {
                printf("variavel (init) %s\n", v->name);
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
                    vars[tnd->opr.op[0].var_id].is_initialized = true; 
                    switch (vars[tnd->opr.op[0].var_id].value.type)
                    {
                        case TYPE_INT:
                            switch (res.type)
                            {
                                case TYPE_INT:  vars[tnd->opr.op[0].var_id].value.i = res.i;     break;
                                case TYPE_REAL: vars[tnd->opr.op[0].var_id].value.i = res.r;     break; // Se for um double, o C por padrão vai truncar para converter implicitamente para inteiro;
                                case TYPE_CHAR: vars[tnd->opr.op[0].var_id].value.i = res.c;     break; // Se for um char, o C por padrão vai pegar o valor inteiro que representa o char em ASCII
                                default: yyerror("Erro (Interpretador): Tipo não existente durante atribuição (Origem) int <- ?.");   break;
                            }
                            break;
                        case TYPE_REAL:
                            switch (res.type)
                            {
                                case TYPE_INT:  vars[tnd->opr.op[0].var_id].value.r = res.i;     break; // Se for um inteiro, o C faz a conversão implicita.
                                case TYPE_REAL: vars[tnd->opr.op[0].var_id].value.r = res.r;     break; 
                                case TYPE_CHAR: vars[tnd->opr.op[0].var_id].value.r = res.c;     break; // Se for um char, o C por padrão vai perar o valor inteiro que representa o char em ASCII e depois fazer uma conversão implicita para real
                                default: yyerror("Erro (Interpretador): Tipo não existente durante atribuição (Origem). real <- ?");   break;
                            }
                            break;
                        case TYPE_CHAR:                             
                            switch (res.type)
                            {
                                case TYPE_INT:  vars[tnd->opr.op[0].var_id].value.c = res.i;     break; // Se for um inteiro, o C faz a conversão implicita (todo char é do tipo inteiro em C, porém com o tamanho menor).
                                case TYPE_REAL: vars[tnd->opr.op[0].var_id].value.c = res.r;     break; // Se for um real, converte para inteiro de maneira implicita e posteriormente o resultado é o mesmo do exemplo acima.
                                case TYPE_CHAR: vars[tnd->opr.op[0].var_id].value.c = res.c;     break; 
                                default: yyerror("Erro (Interpretador): Tipo não existente durante atribuição (Origem). char <- ?");   break;
                            }
                            break;
                        default: 
                            yyerror("Erro (Interpretador): Tipo não existente durante atribuição (Destino).");   break; 
                            break;
                    }
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
                    vars[tnd->opr.op[0].var_id].is_initialized = true; 
                    switch (vars[tnd->opr.op[0].var_id].value.type)
                    {                      
                        //TODO: Revisar possíveis alterações?  
                        case TYPE_INT:  scanf(" %i", &vars[tnd->opr.op[0].var_id].value.i);     break; // Isso é culpa do programador, ele não deveria ler uma variável que não seja do tipo texto (caracter/string)
                        case TYPE_REAL: scanf(" %lf", &vars[tnd->opr.op[0].var_id].value.r);     break; // Isso é culpa do programador, ele não deveria ler uma variável que não seja do tipo texto (caracter/string)
                        case TYPE_CHAR: scanf(" %c", &vars[tnd->opr.op[0].var_id].value.c);     break; 
                        default: yyerror("Erro (Interpretador): Tipo não existente durante atribuição (Origem).");   break;
                    }   
                    /* code */
                    break;

                case ';':
                    /* code */
                    ex(&tnd->opr.op[0]); 
                    return ex(&tnd->opr.op[1]); 
                    break;
                
                MAT_XS(AS_CASE)
                LOG_XS(AS_CASE)

		case UMINUS:
                {
                    struct generic_value eval = ex(tnd->opr.op + 0);
                    struct generic_value res  = {.type = eval.type};
                    switch (eval.type)
                    {                      
                        case TYPE_INT:  res.i = -eval.i; break;
                        case TYPE_REAL: res.r = -eval.r; break;
                        case TYPE_CHAR: res.c = -eval.c; break;
                        default: assert(!"Tipo não definido para negacao logica."); break;
                    }   
                    return res;
                }
		break;

		case UNEG:
                {
                    struct generic_value eval = ex(tnd->opr.op + 0);
                    struct generic_value res  = {.type = TYPE_INT};
                    switch (eval.type)
                    {                      
                        case TYPE_INT:  res.i = !eval.i; break;
                        case TYPE_REAL: res.i = !eval.r; break;
                        case TYPE_CHAR: res.i = !eval.c; break;
                        default: assert(!"Tipo não definido para negacao logica."); break;
                    }   
                    return res;
                }
		break;
                
                default:
                    assert(!"Operação não definida");
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
