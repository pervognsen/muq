
/*--   vm.h -- Header for vm.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_VM_H
#define INCLUDED_VM_H


/* Get FILE* declaration: */
#include <stdio.h>

#ifndef   INCLUDED_JOBPASS_H
#include "jobpass.h"
#endif /* INCLUDED_JOBPASS_H */
/* Following definitions let us bootstrap    */
/* past the initial point in which jobpass.h */
/* has not yet been built:                   */
#ifndef JOB_PASS_SIZEOF_SHORT
#define JOB_PASS_SIZEOF_SHORT (2)
#endif
#ifndef JOB_PASS_SIZEOF_INT
#define JOB_PASS_SIZEOF_INT (4)
#endif
#ifndef JOB_PASS_SIZEOF_LONG
#define JOB_PASS_SIZEOF_LONG (8)
#endif
#ifndef JOB_PASS_SIZEOF_LONG_LONG
#define JOB_PASS_SIZEOF_LONG_LONG (0)
#endif
#ifndef JOB_PASS_SIZEOF_FLOAT
#define JOB_PASS_SIZEOF_FLOAT (4)
#endif
#ifndef JOB_PASS_SIZEOF_DOUBLE
#define JOB_PASS_SIZEOF_DOUBLE (8)
#endif

/* We depend on having 8 bits/byte.  I think there are */
/* some C implementations with more (e.g., PDP-10 with */
/* 9 bits/byte), we should run fine on those.  I'm not */
/* inclined to worry about less than 8 bits/byte Cs :) */
/* Our code depends on BYTEBITS being a power of two:  */
#define VM_BYTEBITS      (8)
#define VM_LOG2_BYTEBITS (3)

/* Number of bytes in an int.  We used to use 4 here to */
/* produce a 32-bit server, now we use 8 to produce a   */
/* 64-bit server:                                       */
#ifndef VM_INTBYTES
#define VM_INTBYTES (8) 
#endif
/* Various values derived from the above: */
#if     VM_INTBYTES == 4
#define VM_LOG2_INTBYTES 2
#define VM_INTBITS (32)
#define VM_LOG2_INTBITS 5
#elif   VM_INTBYTES == 8
#define VM_LOG2_INTBYTES 3
#define VM_INTBITS (64)
#define VM_LOG2_INTBITS 6
#else
#error "Unrecognized VM_INTBYTES value."
#endif

/********************************************************************************/
/* Current Vm_Obj layout, starting from bit 0 (lsb) is:				*/
/*    5 bits user tags, used for type info (int vs float vs obj vs...).		*/
/*    0 bits reserved against future needs.					*/
/*    5 bits 'unique', to help catch hanging pointers.				*/
/*    3 bits 'octave', giving rough object size					*/
/*   30 bits 'offset', distinguishing object from others of same octave.	*/
/*   21 bits 'dbfile', distinguishing the db in which the object is stored.	*/
/********************************************************************************/

#define VM_TAGBITS      ((Vm_Unt)(5))
#define VM_TAGBITS_MASK ((1<<VM_TAGBITS)-1)

#define VM_FUTURE_BITS  0

#define VM_UNIQUE_BITS  5
#define VM_UNIQUE_SHIFT (VM_TAGBITS+VM_FUTURE_BITS)
#define VM_UNIQUE_MASK  ((1<<VM_UNIQUE_BITS)-1)

#define VM_OCTAVE_BITS  3
#define VM_OCTAVE_SHIFT (VM_UNIQUE_SHIFT+VM_UNIQUE_BITS)
#define VM_OCTAVE_MASK  ((1<<VM_OCTAVE_BITS)-1)

#define VM_OFFSET_BITS  30
#define VM_OFFSET_SHIFT (VM_OCTAVE_SHIFT+VM_OCTAVE_BITS)
#define VM_OFFSET_MASK  ((1<<VM_OFFSET_BITS)-1)

#define VM_DBFILE_BITS  21
#define VM_DBFILE_SHIFT (VM_OFFSET_SHIFT+VM_OFFSET_BITS)
#define VM_DBFILE_MASK  ((1<<VM_DBFILE_BITS)-1)
#define VM_DBFILE(o) (((o)>>VM_DBFILE_SHIFT)&VM_DBFILE_MASK)


/* Types exported for general use. */
/* Some are here just because this */
/* is a central Muq type bin.      */
/* We try to automatically pick    */
/* the right integer type for the  */
/* desired integer precision.      */
/* Note that, alas, we cannot do   */
/*    #if sizeof(int)==4           */
/* in C:                           */
#if   JOB_PASS_SIZEOF_INT==VM_INTBYTES
typedef unsigned int  Vm_Obj;
typedef unsigned      Vm_Unt;
typedef int           Vm_Int;
#define VM_D "d"
#define VM_X "x"
#define VM_I "i"
#define VM_O "o"
#define VM_U "u"
#elif JOB_PASS_SIZEOF_LONG==VM_INTBYTES
typedef unsigned long Vm_Obj;
typedef unsigned long Vm_Unt;
typedef          long Vm_Int;
#define VM_D "ld"
#define VM_X "lx"
#define VM_I "li"
#define VM_O "lo"
#define VM_U "lu"
#elif JOB_PASS_SIZEOF_LONG_LONG==VM_INTBYTES
typedef unsigned long long Vm_Obj;
typedef unsigned long long Vm_Unt;
typedef          long long Vm_Int;
#ifndef __FreeBSD__
#define VM_D "lld"
#define VM_X "llx"
#define VM_I "lli"
#define VM_O "llo"
#define VM_U "llu"
#else
/* On FreeBSD releases prior to 3.2, using %lld and */
/* such will coredump, but the older nonstandard    */
/* %qd will work ok.  (According to folks on the    */
/* freebsd-bugs@freebsd.org mailing list.)  Simple  */
/* fix is to always use the 'q' forms on FreeBSD:   */
#define VM_D "qd"
#define VM_X "qx"
#define VM_I "qi"
#define VM_O "qo"
#define VM_U "qu"
#endif
#else
error "Unable to find type supporting requested integer size"
#endif
typedef short         Vm_Sht;	/* We think of this as 2 bytes. */
#if   JOB_PASS_SIZEOF_FLOAT==VM_INTBYTES
typedef float         Vm_Flt;
#define VM_E "e"
#define VM_F "f"
#define VM_G "g"
#elif JOB_PASS_SIZEOF_DOUBLE==VM_INTBYTES
typedef double        Vm_Flt;
#define VM_E "le"
#define VM_F "lf"
#define VM_G "lg"
#else
error "Unable to find type supporting requested float size"
#endif

/* Exactly 32-bit integers, for code which needs */
/* them, in particular the Secure Hash Function: */
#if   JOB_PASS_SIZEOF_INT==4
typedef unsigned      Vm_Unt32;
typedef int           Vm_Int32;
#elif JOB_PASS_SIZEOF_LONG==4
typedef unsigned long Vm_Unt32;
typedef          long Vm_Int32;
#elif JOB_PASS_SIZEOF_LONG_LONG==4
typedef unsigned long long Vm_Unt32;
typedef          long long Vm_Int32;
#else
error "Unable to find type supporting 32-bit integer size"
#endif

/* Exactly 16-bit integers, for code which needs them: */
#if   JOB_PASS_SIZEOF_SHORT==2
typedef unsigned short Vm_Unt16;
typedef signed   short Vm_Int16;
#elif JOB_PASS_SIZEOF_INT==2
typedef unsigned      Vm_Unt16;
typedef int           Vm_Int16;
#elif JOB_PASS_SIZEOF_LONG==2
typedef unsigned long Vm_Unt16;
typedef          long Vm_Int16;
#elif JOB_PASS_SIZEOF_LONG_LONG==2
typedef unsigned long long Vm_Unt32;
typedef          long long Vm_Int32;
#else
error "Unable to find type supporting 16-bit integer size"
#endif

/* Exactly 32-bit floats, for code which needs them: */
#if   JOB_PASS_SIZEOF_FLOAT==4
typedef float  Vm_Flt32;
#elif JOB_PASS_SIZEOF_DOUBLE==4
typedef double Vm_Flt32;
#else
error "Unable to find type supporting 32-bit float size"
#endif

/* Exactly 64bit floats, for code which needs them: */
#if   JOB_PASS_SIZEOF_FLOAT==8
typedef float  Vm_Flt64;
#elif JOB_PASS_SIZEOF_DOUBLE==8
typedef double Vm_Flt64;
#else
error "Unable to find type supporting 64-bit float size"
#endif



/* Cute trick from Expert C Programming / Deep C Secrets, */
/* which lets us do    if (STRCMP( x, == ,"abc" )) {...}: */
#undef  STRCMP
#define STRCMP(a,R,b) (strcmp(a,b) R 0) 



typedef char          Vm_Chr;
typedef unsigned char Vm_Uch;
typedef   signed char Vm_Sch;

/************************************************************************/
/* Octave layout stuff.  vm.t:vm_octave_capacity[] gives the slot size  */
/* in bytes for each octave.  During alpha development all of the       */
/* following were tunable parameters, but they are now realistically    */
/* best regarded as fixed architectural constants.                      */
/************************************************************************/
/* Keep vm.t:vm_octave_capacity[] in synch with these! */
#define VM_FIRST_OCTAVE (0)
#define VM_FINAL_OCTAVE (7)
#define VM_LOG2_QUART_BYTES 8	         /* Keep this in synch with previous!   */
/* First octave which requires us to add a word */
/* to the bigbufBlock header to hold length:	*/
#define VM_FIRST_BIG_OCTAVE ((Vm_Unt)6) /* Keep this in synch with FIRST/FINAL! */

/* To allocate slots quickly from a bitmap, we need to    */
/* keep a cache of recently freed slots and a count of    */
/* free slots.  Together, these can keep us from having   */
/* to do an O(N) scan over the bitmap at each allocation, */
/* instead allocating slots in O(1) time for reasonably	  */
/* behaved systems.  Here we select cache size.  It needs */
/* to be large enough to keep us from calling cacheRefill */
/* too often, but small enough to keep the linear search  */
/* in cacheDelete from being a problem:			  */
#ifndef VM_BITMAP_CACHE_SIZE
#define VM_BITMAP_CACHE_SIZE ((Vm_Unt)(32))
#endif


struct Vm_Db_Stats_Rec {

    /* Counters exported mostly to amuse admins: */

    /* Number of db copies to keep. vm0 + vm1 count */
    /* as two, and it is a very bad idea to keep    */
    /* fewer db generations than that:		*/
    Vm_Unt consecutive_backups_to_keep;

    /* Counter used to drive backups.  Changing */
    /* this value will screw up the logarithmic */
    /* backup scheme badly -- don't do it :)    */
    Vm_Unt backups_done;

    Vm_Unt logarithmic_backups;

    /* Counters exported mostly to amuse admins: */
    Vm_Unt object_reads;
    Vm_Unt object_sends;
    Vm_Unt object_creates;
    Vm_Unt object_creates_since_last_gc;
    Vm_Unt garbage_collects_completed;
    Vm_Unt total_gc_steps_done;
    Vm_Unt steps_done_for_this_gc;
    Vm_Unt used_blocks;
    Vm_Unt free_blocks;
    Vm_Unt bytes_in_useful_data;
    Vm_Unt bytes_allocated_since_last_garbage_collection;
    Vm_Unt bytes_lost_in_used_blocks;
    Vm_Unt bytes_in_free_blocks;
    Vm_Unt next_unique_to_issue;


    /* Root object in db, if nonzero.  vm.c doesn't use	*/
    /* this, but does save/restore it with db, for use	*/
    /* by other folks:					*/
    Vm_Obj root;
};
typedef struct Vm_Db_Stats_Rec*  Vm_Db_Stats;

 /***********************************************************************/
 /*-    per-octave records						*/
 /***********************************************************************/

/************************************************/
/* For each octave file, we maintain:		*/
/*						*/
/* a bitmap 'alloc' with one bit per		*/
/* allocated file slot:  0==empty, 1==full. 	*/
/*						*/
/* fileSlots, tracking the number of file slots	*/
/* allocated on disk, while allocSlots tracks	*/
/* the number of bits physically allocated	*/
/* in the alloc bitmap itself.			*/
/*						*/
/* freeSlots, tracking the number of free slots	*/
/* currently in the file/bitmap.		*/
/*						*/
/* freeCache, tracking recently freed slots	*/
/* so we don't have to search for them:         */
/************************************************/

/* See vm.t for the bitmap names ALLOC &tc: */
#define VM_BITMAPS  8

#define VM_BYTMAPS  2

/* Info for one octave file:			*/
struct Octave_rec {
    Vm_Unt  diskSlots;
    Vm_Unt  allocSlots;

    /* Bitmaps: */
    Vm_Unt* bitmap[VM_BITMAPS];

    /* Bytemaps: */
    Vm_Uch* bytmap[VM_BYTMAPS];

    /* Size field: byte if bytesPerSlot <= 256: */
    union {
        Vm_Uch* b;	
        Vm_Unt* i;
    } size;

    Vm_Unt  freeSlots;
    Vm_Unt  freeCacheLen;
    Vm_Unt  freeCache[ VM_BITMAP_CACHE_SIZE ];

    Vm_Unt  bytesOfSize;
    Vm_Unt  bytesPerSlot;
    Vm_Unt  slotsPerQuart;
    Vm_Unt  quarts;	    /* Number of quarts in quartOffset.       */
    Vm_Unt* quartOffset;    /* Byte offset in db file of i'th quart   */
};
typedef struct Octave_rec  An_Octave;
typedef struct Octave_rec*    Octave;

 /***********************************************************************/
 /*-    Per-db records							*/
 /***********************************************************************/

/* Info for all octave files in a complete db:	*/
struct Vm_Db_Rec {
    struct Vm_Db_Rec*hnext;     /* Next database in hashtable chain.                */
    Vm_Unt          dbfile;	/* Database ID number from Vm_Obj 'db' field.       */
    struct Vm_Db_Rec*next;      /* Next database in chain of currently open ones.   */

    struct Vm_Db_Stats_Rec s;
    Vm_Unt    wasCompressed;	/* TRUE iff we had to gunzip the file.		    */
    Vm_Unt    bytesInFile;	/* Next offset to allocate in file.                 */
    Vm_Int    quartAllocSlots;  /* # of quartAlloc slots physically allocated.      */
    Vm_Unt*   quartAlloc;       /* Bitmap of quart allocated/free status.           */
    An_Octave o[ VM_FINAL_OCTAVE+1 ];
    int       fileDescriptor;	/* For I/O to file.                                 */
};
typedef struct Vm_Db_Rec  Vm_A_Db;
typedef struct Vm_Db_Rec*   Vm_Db;

extern void  vm_Preshutdown(void);
extern int   vm_Restartup(void);
extern int   vm_Startup(void);
extern void  vm_Linkup(void);
extern void  vm_Shutdown(void);

extern Vm_Obj   vm_Backup_Continue( void );
extern void     vm_Backup_Start( void (*all_ptrs)(Vm_Obj,void(*fn)(Vm_Obj)), Vm_Obj**);
extern Vm_Obj   vm_Dup( Vm_Obj, Vm_Unt );
extern Vm_Int   vm_Invariants(FILE*,Vm_Uch*);
extern void*    vm_Is_In_Ram(Vm_Obj);
extern Vm_Int   vm_Is_Valid( Vm_Obj);
extern Vm_Unt   vm_Len(Vm_Obj);
extern Vm_Unt   vm_Resize_Bigbuf(Vm_Unt);
extern Vm_Obj   vm_First(Vm_Db);
extern Vm_Obj   vm_Malloc(Vm_Unt,Vm_Unt,Vm_Uch);
extern Vm_Obj   vm_Next(Vm_Obj,Vm_Db);
extern Vm_Obj   vm_Realloc(Vm_Obj,Vm_Unt);
extern void     vm_Dirty(Vm_Obj);
extern void     vm_Free(Vm_Obj);
extern int      vm_Db_Is_Pinned_In_Ram( Vm_Int );
extern void     vm_Flush_Db_From_Cache( Vm_Unt );

extern void     vm_Loc2(void**,void**,Vm_Obj,Vm_Obj);
extern void     vm_Loc3(void**,void**,void**,Vm_Obj,Vm_Obj,Vm_Obj);
extern void     vm_Loc4(void**,void**,void**,void**,Vm_Obj,Vm_Obj,Vm_Obj,Vm_Obj);
extern void     vm_Loc5(void**,void**,void**,void**,void**,Vm_Obj,Vm_Obj,Vm_Obj,Vm_Obj,Vm_Obj);
extern void     vm_Loc6(void**,void**,void**,void**,void**,void**,Vm_Obj,Vm_Obj,Vm_Obj,Vm_Obj,Vm_Obj,Vm_Obj);

extern void     vm_Print_State(FILE*,Vm_Uch*);
extern void     vm_Register_Hard_Pointer(Vm_Obj*,void**);

extern void     vm_Clr_Constbit(Vm_Obj);
extern Vm_Unt   vm_Get_Constbit(Vm_Obj);
extern void     vm_Set_Constbit(Vm_Obj);

extern Vm_Unt   vm_Get_Markbit(Vm_Obj);
extern void     vm_Set_Markbit(Vm_Obj);

extern void     vm_Clear_Markbits(void);

extern Vm_Db    vm_Db( Vm_Unt dbId );

extern Vm_Obj   vm_SizedDup( Vm_Obj, Vm_Unt, Vm_Unt );
extern void     vm_Unregister_Hard_Pointer(void**);
extern void*    vm_Loc(Vm_Obj);

extern Vm_Int   vm_Compress_Files_Asynchronously;
extern Vm_Int   vm_Nuke_Db_At_Startup;
extern Vm_Uch*  vm_Octave_File_Path;
extern Vm_Unt   vm_Initial_Bigbuf_Size;

extern Vm_Unt   vm_Object_Creates_Between_Garbage_Collects;
extern Vm_Unt   vm_Gc_Steps_Per_Malloc;

extern Vm_Unt16 vm_Reverse16( Vm_Unt16 );
extern Vm_Unt32 vm_Reverse32( Vm_Unt32 );
extern Vm_Unt   vm_Reverse64( Vm_Unt   );

extern Vm_Db_Stats vm_Db_Stats(Vm_Obj);

extern Vm_Unt vm_Make_Db(Vm_Unt);
extern Vm_Unt vm_Import_Db(Vm_Unt);
extern Vm_Unt vm_Remove_Db(Vm_Unt);

extern Vm_Unt vm_Consecutive_Backups_To_Keep(		    Vm_Unt db);
extern Vm_Unt vm_Backups_Done(				    Vm_Unt db);
extern Vm_Uch*vm_Export_Db(				    Vm_Unt db);
extern Vm_Unt vm_Logarithmic_Backups(			    Vm_Unt db);
extern Vm_Unt vm_Object_Reads(				    Vm_Unt db);
extern Vm_Unt vm_Object_Sends(				    Vm_Unt db);
extern Vm_Unt vm_Object_Creates(				    Vm_Unt db);
extern Vm_Unt vm_Object_Creates_Since_Last_Gc(		    Vm_Unt db);
extern Vm_Unt vm_Garbage_Collects_Completed(		    Vm_Unt db);
extern Vm_Unt vm_Total_Gc_Steps_Done(			    Vm_Unt db);
extern Vm_Unt vm_Steps_Done_For_This_Gc(			    Vm_Unt db);
extern Vm_Unt vm_Used_Blocks(				    Vm_Unt db);
extern Vm_Unt vm_Free_Blocks(				    Vm_Unt db);
extern Vm_Unt vm_Bytes_In_Useful_Data(			    Vm_Unt db);
extern Vm_Unt vm_Bytes_Allocated_Since_Last_Garbage_Collection( Vm_Unt db);
extern Vm_Unt vm_Bytes_Lost_In_Used_Blocks(		    	    Vm_Unt db);
extern Vm_Unt vm_Bytes_In_Free_Blocks(			    Vm_Unt db);
extern Vm_Obj vm_Root(					    Vm_Unt db);

extern void   vm_Set_Bytes_Allocated_Since_Last_Garbage_Collection( Vm_Unt db, Vm_Unt);
extern void   vm_Set_Logarithmic_Backups( Vm_Unt db, Vm_Unt);
extern void   vm_Set_Consecutive_Backups_To_Keep( Vm_Unt db, Vm_Unt);
extern void   vm_Set_Root( Vm_Unt db, Vm_Obj);
extern Vm_Unt vm_Db_Is_Mounted(Vm_Unt);
#ifdef CURRENTLY_UNUSED
extern Vm_Unt vm_Db_Exists(    Vm_Unt);
#endif

extern Vm_Int vm_Asciz_To_DbId( Vm_Uch*asciz );
extern Vm_Uch*vm_DbId_To_Asciz( Vm_Int id    );

extern Vm_Db  vm_This_Db;
extern Vm_Db  vm_Root_Db;
extern Vm_Unt vm_Total_Bytes_Allocated_Since_Last_Garbage_Collection;

/************************************************************************/
/*-    File variables */
#endif /* INCLUDED_VM_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

