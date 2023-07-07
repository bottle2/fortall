/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    PUBLICO = 258,                 /* PUBLICO  */
    ESTATICO = 259,                /* ESTATICO  */
    ABISMO = 260,                  /* ABISMO  */
    PRINCIPAL = 261,               /* PRINCIPAL  */
    CARACTERE = 262,               /* CARACTERE  */
    INTEIRO = 263,                 /* INTEIRO  */
    REAL = 264,                    /* REAL  */
    SE = 265,                      /* SE  */
    ENTAO = 266,                   /* ENTAO  */
    SENAO = 267,                   /* SENAO  */
    ENQUANTO = 268,                /* ENQUANTO  */
    ESCREVER = 269,                /* ESCREVER  */
    LER = 270,                     /* LER  */
    STRING_LITERAL = 271,          /* STRING_LITERAL  */
    CHAR_CONST = 272,              /* CHAR_CONST  */
    INT_CONST = 273,               /* INT_CONST  */
    REAL_CONST = 274,              /* REAL_CONST  */
    VAR_ID = 275,                  /* VAR_ID  */
    OR = 276,                      /* OR  */
    AND = 277,                     /* AND  */
    GE = 278,                      /* GE  */
    LE = 279,                      /* LE  */
    EQ = 280,                      /* EQ  */
    NE = 281,                      /* NE  */
    UMINUS = 282,                  /* UMINUS  */
    UNEG = 283,                    /* UNEG  */
    SEX = 284                      /* SEX  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif
/* Token kinds.  */
#define YYEMPTY -2
#define YYEOF 0
#define YYerror 256
#define YYUNDEF 257
#define PUBLICO 258
#define ESTATICO 259
#define ABISMO 260
#define PRINCIPAL 261
#define CARACTERE 262
#define INTEIRO 263
#define REAL 264
#define SE 265
#define ENTAO 266
#define SENAO 267
#define ENQUANTO 268
#define ESCREVER 269
#define LER 270
#define STRING_LITERAL 271
#define CHAR_CONST 272
#define INT_CONST 273
#define REAL_CONST 274
#define VAR_ID 275
#define OR 276
#define AND 277
#define GE 278
#define LE 279
#define EQ 280
#define NE 281
#define UMINUS 282
#define UNEG 283
#define SEX 284

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 58 "fortall.y"

    char   *string_literal;
    char    char_const;
    int      int_const;
    double  real_const;
    int     var_id;

#line 133 "y.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
