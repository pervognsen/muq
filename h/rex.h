
/*--   rex.h -- Header for rex.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_REX_H
#define INCLUDED_REX_H



/************************************************************************/
/*-    #includes							*/



/************************************************************************/
/*-    #defines								*/

/* Token types returned by the lexer:	*/
#define REX_TYPE_OP		OBJ_FROM_BYT2('o','p')
#define REX_TYPE_BRC		OBJ_FROM_BYT3('b','r','c')
#define REX_TYPE_BRK		OBJ_FROM_BYT3('b','r','k')
#define REX_TYPE_STR		OBJ_FROM_BYT3('s','t','r')



/************************************************************************/
/*-    types								*/

/* Define fields in our state vector: */
#define REX_OFF_ASM	    (0)	/* Our assembler.			*/

    /* Source for tokens to assemble: */
#define REX_OFF_STR	    (1)	/* Str containing source.		*/

    /* State stuff for muf_Fun_Assemble: */
#define REX_OFF_LABELS	    (2)	/* Number of labels generated to date.  */
#define REX_OFF_BEG	    (3)	/* First byte in   current token in stg.*/
#define REX_OFF_END	    (4)	/* First byte past current token in stg.*/
#define REX_OFF_TYP	    (5)	/* Token type (MUF_TYPE_ID etc).	*/
#define REX_OFF_FN_NAME	   ( 6)	/* Name of fn being compiled else OBJ_FROM_INT('a'/'t'/0).*/
#define REX_OFF_FN	   ( 7)	/* Fn being compiled.			*/
#define REX_OFF_FN_BEG	   ( 8)	/* First byte in fn being compiled.	*/
#define REX_OFF_SP	   ( 9)	/* First byte in fn being compiled.	*/
#define REX_OFF_MAX	   (10)	/* Total number of slots.		*/

#define REX_MAX_BUF 	(64)
#define REX_MAX_MATCHES	(32)
struct Rex_Job_Rec {
    /* If string==OBJ_FROM_INT(0), no match is in progress:		*/
    Vm_Obj string;		/* String we're pattern-matching on.	*/
    Vm_Obj stringLen;		/* Count of chars in string above.	*/
    Vm_Obj matchTop[REX_MAX_MATCHES]; /* Absolute offset of 1st char in match	*/
    Vm_Obj matchBot[REX_MAX_MATCHES]; /* Absolute offset of 1st char past match	*/
    Vm_Obj bufTop;		/* Absolute offset of 1st char in buf.	*/
    Vm_Obj bufBot;		/* Absolute offset of 1st char past buf.*/
    Vm_Obj cursor;		/* Current point in match.		*/
    Vm_Obj buf[ REX_MAX_BUF ];
};


/************************************************************************/
/*-    externs								*/

extern void	rex_Startup(  void              );
extern void	rex_Linkup(   void              );
extern void	rex_Shutdown( void              );

extern void     rex_Init( struct Rex_Job_Rec*	);
extern void     rex_Cache(struct Rex_Job_Rec*	);
extern void     rex_Uncache(struct Rex_Job_Rec*	);
extern void     rex_Begin(    Vm_Obj		);
extern void     rex_End(      			);
extern void     rex_Open_Paren(  Vm_Int		);
extern void     rex_Close_Paren( Vm_Int		);
extern void     rex_Cancel_Paren( Vm_Int	);
extern Vm_Obj   rex_Match_Previous_Match( Vm_Int);
extern Vm_Obj   rex_Get_Paren(   Vm_Obj*,Vm_Int	);
extern Vm_Int   rex_Done_P(    void		);

extern Vm_Obj   rex_Match_Char_Class(  Vm_Obj   );
extern Vm_Obj   rex_Match_Dot(                  );
extern Vm_Obj   rex_Match_String(      Vm_Obj   );

extern Vm_Obj   rex_Match_Wordboundary(	    void );
extern Vm_Obj   rex_Match_Wordchar(	    void );
extern Vm_Obj   rex_Match_Whitespace(	    void );
extern Vm_Obj   rex_Match_Digit(	    void );
extern Vm_Obj   rex_Match_Nonwordboundary(  void );
extern Vm_Obj   rex_Match_Nonwordchar(      void );
extern Vm_Obj   rex_Match_Nonwhitespace(    void );
extern Vm_Obj   rex_Match_Nondigit(	    void );

extern Vm_Obj   rex_Get_Cursor(  void           );
extern void     rex_Set_Cursor(  Vm_Obj         );


extern void    rex_Read_Next_Rex_Token(Vm_Int*,Vm_Int*,Vm_Obj*,Vm_Unt,Vm_Obj);
extern void    rex_Reset( Vm_Obj,   Vm_Obj );

extern Obj_A_Module_Summary  rex_Module_Summary;





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_REX_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

