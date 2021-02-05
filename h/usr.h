/* TODO: */
/* Eventually, we would like everything in the system to support */
/* message-passing. Integer, float and stg objects should likely */
/* run methods stored on /msg/int /msg/flt /msg/stg... vectors   */
/* should likely serve as lightweight objects, with the only     */
/* explicit overhead being an 'owner' field.  Non-owner write    */
/* permissions, vector group, and messages supported by vectors  */
/* should likely all be specified on a per-owner basis by fields */
/* stored in the owner. */

/* We probably also want to add lots more soft and hard resource  */
/* limits... jobs, stack, bytes, instructions...                  */


/*--   usr.h -- Header for usr.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_USR_H
#define INCLUDED_USR_H



/************************************************************************/
/*-    #includes							*/

#include <stdio.h>
#include "vm.h"
#include "obj.h"



/************************************************************************/
/*-    #defines								*/

/* Basic macro to locate a user: */
#define USR_P(o) ((Usr_Header)vm_Loc(o))

/* Default object_quota for new user: */
#ifndef USR_USR_OBJECT_QUOTA
#define USR_USR_OBJECT_QUOTA OBJ_FROM_INT(10)
#endif

/* Default byte_quota for new user: */
#ifndef USR_USR_BYTE_QUOTA
#define USR_USR_BYTE_QUOTA OBJ_FROM_INT(10000)
#endif

/* Default object_quota for new root: */
#ifndef USR_ROOT_OBJECT_QUOTA
#define USR_ROOT_OBJECT_QUOTA OBJ_FROM_INT(0x10000000)
#endif

/* Default byte_quota for new root: */
#ifndef USR_ROOT_BYTE_QUOTA
#define USR_ROOT_BYTE_QUOTA OBJ_FROM_INT(0x10000000)
#endif

#define USR_RESERVED_SLOTS 64

#define USR_AVATAR_OPENGL       ((Vm_Int)1)
#define USR_UNRESTRICTED_OPENGL ((Vm_Int)2)

/************************************************************************/
/*-    types								*/

/* Our refinement of Obj_Header_Rec: */
struct Usr_Header_Rec {
    Obj_A_Header	o;

    /* Job queue stuff.  Keep these at top, matching usr.c: */
    /* NOTE: q_* aren't used yet.  Added these fields because */
    /* eventually I'd like to schedule all USERs equal time   */
    /* slices, rather than all JOBS, so greedy users spawning */
    /* lots of tasks mostly slow themselves down, rather than */
    /* everyone else.  By pre-allocating these slots, should  */
    /* be pretty easy to convert over at some point.          */
    /* Cynbe, 93Oct26.					      */
    Vm_Obj	next;		/* Next obj in usr queue we are in.	*/
    Vm_Obj	prev;		/* Prev obj in usr queue we are in.	*/
    Vm_Obj	this;		/*             usr queue we are in.	*/

    Vm_Obj      group;		/* Can modify pubprops, read priprops.	*/

/*  Vm_Obj	run_q[0];	/  High priority running jobs.		*/
/*  Vm_Obj	run_q[1];	/  Normal priority running jobs.	*/
/*  Vm_Obj	run_q[2];	/  Low priority running jobs.		*/
    Vm_Obj      run_q[ JOB_PRIORITY_LEVELS ];
    Vm_Obj      ps_q;
    Vm_Obj      pause_q;
    Vm_Obj      halt_q;
    Vm_Obj      time_slice;	/* Gets monotonically incremented.	*/

    Vm_Obj lib;			/* Packages visible to user.		*/
    Vm_Obj byte_quota;		/* Bytes of store permitted this user.	*/
    Vm_Obj bytes_owned;		/* Bytes of store owned by  this user.	*/
    Vm_Obj object_quota;	/* Object count permitted this user.	*/
    Vm_Obj objects_owned;	/* Count of objects owned by user.	*/
    Vm_Obj default_package;	/* Default package of symbols.		*/
    Vm_Obj do_signal;		/* Default ]do_signal function for jobs.*/
    Vm_Obj debugger;		/* Default ]debugger function for jobs. */
    Vm_Obj do_break;		/* Default break function for jobs.	*/
    Vm_Obj homepage;		/* http://my.com/me.			*/
    Vm_Obj email;		/* me@my.com.				*/
    Vm_Obj shell;		/* Default shell on login.		*/
    Vm_Obj pgp_keyprint;	/* PGP Key fingerprint.			*/
    Vm_Obj telnet_daemon;	/* Default telnet daemon at login.	*/
    Vm_Obj text_editor;		/* Preferred text editor.		*/
    Vm_Obj login_hints;		/* Object with hint strings, or nil.	*/
    Vm_Obj config_fns;		/* Object with config fns, or nil.	*/
    Vm_Obj break_enable;	/* Default @%s/breakEnable on login.	*/
    Vm_Obj break_disable;	/* Default @%s/breakDisable on login.	*/
    Vm_Obj break_on_signal;	/* Default @%s/breakOnSignal on login.*/
    Vm_Obj dbref_convert_errors;

    Vm_Obj encrypted_passphrase;/* For login &tc			*/
    Vm_Obj www;			/* For www home page			*/
    Vm_Obj rank;		/* For conflict resolution		*/
    Vm_Obj gagged;		/* Users/Guests gagged by this user	*/

    Vm_Obj priv_bits;		/* Dis/able OpenGL and such		*/

    Vm_Obj nick_name;		/* Max 16 chars of nickname		*/
    Vm_Obj long_name;		/* Diffie_Hellman public key		*/
    Vm_Obj true_name;		/* Diffie_Hellman private key		*/
    Vm_Obj hash_name;		/* 61-bit hash of long_name		*/
    Vm_Obj shared_secrets;	/* Indexed by hash_name of other user.	*/

    Vm_Obj original_nick_name;	/* Max 16 chars of nickname		*/

    Vm_Obj last_long_name;	/* Last value of long_name		*/
    Vm_Obj last_true_name;	/* Last value of true_name		*/
    Vm_Obj last_hash_name;	/* Last value of hash_name		*/
    Vm_Obj last_shared_secrets;	/* Last value of shared_secrets.	*/
    Vm_Obj date_of_last_name_change;	/* Date of last name rotation.	*/

    Vm_Obj ip0;			/* These give last known IP address of	*/
    Vm_Obj ip1;			/* this user.  Mainly useful for remote	*/
    Vm_Obj ip2;			/* users, but I'm keeping all user recs	*/
    Vm_Obj ip3;			/* identical for simplicity.		*/
    Vm_Obj port;		/* 					*/

    Vm_Obj io_stream;		/* Last known I/O stream on which user	*/
				/* was accepting communications.	*/

				/* Next is non-NIL iff a user_server_*	*/
				/* is absent from /folkBy/hashName:	*/
    Vm_Obj has_unknown_user_server;

    Vm_Obj user_server_0;	/* Muqserver which should know our loc.	*/
    Vm_Obj user_server_1;	/* Muqserver which should know our loc.	*/
    Vm_Obj user_server_2;	/* Muqserver which should know our loc.	*/
    Vm_Obj user_server_3;	/* Muqserver which should know our loc.	*/
    Vm_Obj user_server_4;	/* Muqserver which should know our loc.	*/

    Vm_Obj user_server_1_needs_updating;/* NIL or date of last attempt.	*/
    Vm_Obj user_server_2_needs_updating;/* NIL or date of last attempt.	*/
    Vm_Obj user_server_3_needs_updating;/* NIL or date of last attempt.	*/
    Vm_Obj user_server_4_needs_updating;/* NIL or date of last attempt.	*/

				/* Used to help avoid thrashing servers:*/
    Vm_Obj date_at_which_we_last_queried_user_servers;

    Vm_Obj doing;		/* Short text @doing description.	*/
    Vm_Obj do_not_disturb;	/* Boolean.				*/

    Vm_Obj user_version;	/* Incremented each time ip[0-4],port	*/
				/* changed:  Used to decide which 	*/
				/* location server is most up-to-date,	*/
				/* if they disagree.			*/

    Vm_Obj packet_preprocessor;	/* Currently unused.			*/
    Vm_Obj packet_postprocessor;/* Currently unused.			*/
    Vm_Obj first_used_by_muqnet;
    Vm_Obj last_used_by_muqnet;
    Vm_Obj times_used_by_muqnet;

    Vm_Obj reserved_slot[ USR_RESERVED_SLOTS ];
};
typedef struct Usr_Header_Rec Usr_A_Header;
typedef struct Usr_Header_Rec*  Usr_Header;
typedef struct Usr_Header_Rec*  Usr_P;



/************************************************************************/
/*-    externs								*/

extern int    usr_Invariants(FILE*,char*,Vm_Obj);
extern void   usr_Print(     FILE*,char*,Vm_Obj);
extern void   usr_Startup( void              );
extern void   usr_Linkup(  void              );
extern void   usr_Shutdown(void              );
extern Vm_Obj usr_Import(   FILE* );
extern void   usr_Export(   FILE*, Vm_Obj );

extern Obj_A_Hardcoded_Class usr_Hardcoded_Rot_Class;
extern Obj_A_Hardcoded_Class usr_Hardcoded_Usr_Class;
extern Obj_A_Hardcoded_Class usr_Hardcoded_Gst_Class;
extern Obj_A_Module_Summary  usr_Module_Summary;





/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_USR_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

