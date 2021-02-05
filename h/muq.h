
/*--   muq.h -- Header for muq.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_MUQ_H
#define INCLUDED_MUQ_H



/************************************************************************/
/*-    #includes							*/

#include "All.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a muq: */
#define MUQ_P(o) ((Muq_Header)vm_Loc(o))

#define MUQ_RESERVED_SLOTS 40
#define MUQ_RANDOM_STATE_SLOTS 128	/* Must be a power of two.	*/

#define MUQ_NOTE_RANDOM_BITS(x) muq_RandomState.slot[ muq_RandomState.i = (muq_RandomState.i+1) & (MUQ_RANDOM_STATE_SLOTS-1) ] += OBJ_FROM_UNT((Vm_Unt)(x))

/************************************************************************/
/*-    types								*/

/* Buggo? How can we get away with sticking Vm_Unts */
/* in an object state record?  Does the garbage collector */
/* have a special-case hack for muq objects...? */
struct Muq_Random_State_Rec {
    Vm_Unt i;		/* Ranges from 0 to MUQ_RANDOM_STATE_SLOTS-1	*/
    Vm_Unt slot[ MUQ_RANDOM_STATE_SLOTS ];
};
struct Muq_Header_Rec {
    Obj_A_Header	o;

    Vm_Obj banned;
    Vm_Obj next_pid;
    Vm_Obj next_user_rank;
    Vm_Obj next_guest_rank;

    Vm_Obj millisecs_between_backups;
    Vm_Obj date_of_next_backup;
    Vm_Obj date_of_last_backup;
    Vm_Obj millisecs_for_last_backup;

    Vm_Obj bytes_between_garbage_collects;

    Vm_Obj default_user_server_1;
    Vm_Obj default_user_server_2;
    Vm_Obj default_user_server_3;
    Vm_Obj default_user_server_4;

    Vm_Obj server_name;

    Vm_Obj allow_user_logging;
    Vm_Obj log_daemon_stuff;

    Vm_Obj glut_io;
    Vm_Obj glut_menu_status_func;
    Vm_Obj glut_idle_func;
    Vm_Obj glut_timer_func;
    Vm_Obj glut_windows;
    Vm_Obj glut_menus;

    Vm_Obj creation_date;
    Vm_Obj server_restarts;
    Vm_Obj session_start_date;
    Vm_Obj runtime_in_previous_sessions;

    struct Muq_Random_State_Rec randomState;

    Vm_Obj reserved_slot[ MUQ_RESERVED_SLOTS ];
};
typedef struct Muq_Header_Rec Muq_A_Header;
typedef struct Muq_Header_Rec*  Muq_Header;
typedef struct Muq_Header_Rec*  Muq_P;



/************************************************************************/
/*-    externs								*/

extern int        muq_Invariants(FILE*,Vm_Uch*,Vm_Obj	);
extern Vm_Uch*    muq_Sprint(  Vm_Uch*, Vm_Uch*, Vm_Obj );
extern void       muq_Startup( void			);
extern void       muq_Linkup(  void			);
extern void       muq_Shutdown(void			);
extern void       muq_Mark(    void                     );
#ifdef SOON
extern Vm_Obj     muq_Import(   FILE* );
extern void       muq_Export(   FILE*, Vm_Obj );
#endif

extern Vm_Obj     muq_Alloc( Vm_Unt		);
extern Vm_Obj     muq_Dup(       Vm_Obj         );

extern struct Muq_Random_State_Rec muq_RandomState;

extern Obj_A_Hardcoded_Class muq_Hardcoded_Class;
extern Obj_A_Module_Summary  muq_Module_Summary;
extern Vm_Int                muq_Is_In_Daemon_Mode;
extern Vm_Int		     muq_Debug;
extern Vm_Obj		     muq_Glut_Io;



/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_MUQ_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

