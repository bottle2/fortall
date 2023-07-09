#ifndef FORTALL_H

#include <stdbool.h>

#define CAPACITY_VAR    4095
#define CAPACITY_STRING 4095

int var_find_or_set(char name[static 2]);
void yyerror(char *error);
/* constants */
struct generic_value
{
    enum type
    {
        TYPE_UNDEFINED,
        TYPE_CHAR,
        TYPE_INT,
        TYPE_REAL
    } type;

    union
    {
        char   c;
        int    i;
        double r;
    };
};

/* operators */
struct op_tree_node{
    int oper; /* operator */
    int nops; /* number of operands */
    struct tree_node *op; /* operands */
};

// Elemento genérico da Arvore
struct tree_node 
{   
    enum { CONST, VID, OPR, STRING} type;
    union
    {
        struct generic_value  con;
        int                   var_id;
        struct op_tree_node   opr;
        char                 *str;
    };
};

//Definição formal da Variavel
struct var
{
    char *name;
    bool   is_initialized;
    struct generic_value value;
};

extern struct var vars[];
#endif
