@example  @c

/*--   vm.c -- Virtual memory.						*/
/*- This file is formatted for outline-minor-mode in emacs19.		*/
/*-^C^O^A shows All of file.						*/
/* ^C^O^Q Quickfolds entire file. (Leaves only top-level headings.)	*/
/* ^C^O^T hides all Text. (Leaves all headings.)			*/
/* ^C^O^I shows Immediate children of node.				*/
/* ^C^O^S Shows all of a node.						*/
/* ^C^O^D hiDes all of a node.						*/
/* ^HFoutline-mode gives more details.					*/
/* (Or do ^HI and read emacs:outline mode.)				*/

/************************************************************************/
/*-    Dedication and Copyright.					*/
/************************************************************************/

/************************************************************************/
/*									*/
/*  To a little school of Neon Tetras who once had the misfortune to	*/
/*  inhabit my aquarium.  Long dead, the memory of their individual	*/
/*  elegance and effortless synchronization lives yet in fond memory.	*/
/*									*/
/*  May I someday have software tools like that.			*/
/*									*/
/************************************************************************/

/************************************************************************/
/* Author:       Jeff Prothero						*/
/* Created:      92Dec29						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1993-2000, by Jeff Prothero.				*/
/*									*/
/* This program is free software; you may use, distribute and/or modify	*/
/* it under the terms of the GNU Library General Public License as      */
/* published by	the Free Software Foundation; either version 2, or (at  */
/* your option)	any later version FOR NONCOMMERCIAL PURPOSES.		*/
/*									*/
/*  COMMERCIAL operation allowable at $100/CPU/YEAR.			*/
/*  COMMERCIAL distribution (e.g., on CD-ROM) is UNRESTRICTED.		*/
/*  Other commercial arrangements NEGOTIABLE.				*/
/*  Contact cynbe@@eskimo.com for a COMMERCIAL LICENSE.			*/
/*									*/
/*   This program is distributed in the hope that it will be useful,	*/
/*   but WITHOUT ANY WARRANTY; without even the implied warranty of	*/
/*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the	*/
/*   GNU Library General Public License for more details.		*/
/*									*/
/*   You should have received the GNU Library General Public License	*/
/*   along with this program (COPYING.LIB); if not, write to:		*/
/*      Free Software Foundation, Inc.					*/
/*      675 Mass Ave, Cambridge, MA 02139, USA.				*/
/*									*/
/* Jeff Prothero DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,	*/
/* INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN	*/
/* NO EVENT SHALL JEFF PROTHERO BE LIABLE FOR ANY SPECIAL, INDIRECT OR	*/
/* CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS	*/
/* OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,		*/
/* NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION	*/
/* WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.			*/
/*									*/
/* Please send bug reports/fixes etc to bugs@@muq.org.			*/
/************************************************************************/

/************************************************************************/
/*									*/
/*    My work is not a piece of writing designed to meet the taste	*/
/*    of an immediate public, but was done to last for ever.		*/
/*									*/
/*			-- Thucydides, The Peloponnesian War		*/
/*									*/
/************************************************************************/



/************************************************************************/
/*-    Overview								*/
/************************************************************************/

/* See "Virtual Memory" in the manual. */

/*
NOTE:  More documentation on the datastructures may be found in
the *Invariant() functions.
 */

/* See "Garbage Collection" in the manual. */

/************************************************************************/
/*-    Working notes							*/
/************************************************************************/

/* 

Immediate work:

Pending Projects:

*  Object resizing

 */

/************************************************************************/
/*-    mmap() working notes						*/
/************************************************************************/

/* One mud-dev writer pointed out that on 32-bit OSes, using mmap()	*/
/* effectively limits one to about a 1Gig db.  hlp/coldstore.critique   */
/* has the full comments.						*/
/*									*/
/* Another -- Hans-Henrik Staerfeldt hhs@cbs.dtu.dk -- commented that   */
/* new versions of Irix are 64 bit, but one must call a separate        */
/* mmap64() to mmap more than 1Gb.					*/


/************************************************************************/
/*-    Random notes to myself, mostly historical interest		*/
/************************************************************************/


/*-Contemplated changes:

97Dec28 Can copy the entire db disk-to-disk in 5 sec on
the laptop, but saving ram to disk takes much longer :(.
Writing the objects to their db files sorted by offset
instead of in random order helps, but the saves are still
perhaps 10x slower than disk-to-disk copy:  Appears that
lseek()s are pretty expensive, at least on Linux.  Might
want to think about just dumping the working set to a
separate file at db shutdown, and restoring from that
same file at next start-up:  This would speed up both
processes by a factor of ten or so, most likely.

96Dec18 Stevens warns that catching SIGCHLD means that
interrupted system calls are possible.  For Muq, that
prolly mostly means disk I/O here in vm: Might want
to double-check that we will handle that gracefully.
Should double-check that disk-full conditions are
handled somewhat rationally at the same time?

94Nov14: It might make sense to partition the system between
an interpreter muq and various feepservers:

 muqnet:  network I/O, including concentration where needed
 muqdb:   dbase I/O
 muqname: nameserver services
 ...

The feepservers can synchronize via pipes/sockets, and in at
least some cases, communicate via shared memory segments.
I'm thinking of an architecture with a 100K vm bigbuf shared
memory segment per user, plus a large-objects shared memory
segment.

One motivation is to avoid letting nameserver lag, socket
opening lag, disk I/O lag and such from halting the
interpreter process.

A minor motivation is to allow socket concentration to evade
fixed sockets/process limits: muqnet can spawn more
processes as needed.

Another motivation is to allow special functionality to be
provided by separately compiled feepservers.  This is very
popular with developers to avoid having to relink a large
kernel on each pass, and with users to have a lot of
functionality around without having to load it all into
memory at once.

A third motivation is to allow updates without taking the
system down: It should be possible to do this with
feepservers, at least.  If it proved possible to run two
muqdbs per muq process and vice versa, hot updates to the
entire program might be possible.  (If the central server
can be kept stable, it might not need updatng, however.)  If
an indefinite number of muqs could feed at one muqdb trough,
we'd have assymetric multiprocessing: If they could each
feed at several muqdbs, a very high-uptime server
configuration might be achievable.

94Jun30: When reading large records from an octave file (>4K, say),
it would make more sense to read the size info in first, then
read only the valid data.  This avoids possibly allocating a
meg of unneeded ram, and reading a meg of unneeded data from
disk, if we start supporting objects in that size range.

94Jun25: I'm now inclined to just give every (active) online
user a separate bigbuf[], basically, so they don't compete
against each other for ram.  This is simple and guaranteed
to achieve my design goal of keeping one thrashing user from
wrecking system response for everyone else; The other
approaches I've been thinking about seem to be getting
steadily more complex without achieving anything like such a
guarantee.

94Apr08: 94Mar IEEE _Computer_ has a nice article "Caching Strategies
to Improve Disk System Performance", Karedla, Love & Wherry, reporting
that segmented LRU gives the performance of simple LRU in half the
buffer space, with about the same code overhead.  Also, LRU give the
performance of random replacement in a quarter the buffer space.

94Mar08: Keeping multiple file descriptors open is unpopular, and the
multi-file db is both clumsy and an invitation to mismatched db files
due to partial restores or such: It would be nice to combine the
different db files, plus the index, into a single unix file.  The
indices could live at the end of the db file, with a short
fixed-length header block giving their location, as well as containing
a lock byte.  (Hmm.  Or maybe we should just unlink the db file while
it is open?)  We can then maintain for each octave an array of offsets
to where blocks of N objects of that size are found in the unix file.
"One more level of indirection", and allocate in blocks of 32K or so.
Since we already maintain a byte in ram for each addressable,
maintaining these arrays in ram won't add noticable overhead.

Also, it would be nice to make the slot sizes slightly larger than 2^N
in the larger sizes, so arrays and such which need to allocate things
of size 2^N plus a small header block won't waste large amounts of
diskspace.

94Feb21: Should prolly rename old index file rather than delete it.
It's a gross thought, but somebody someday will likely be trying
to fish useful stuff out of a crashed db, and would appreciate it...

Comment from MacGyver:

Also, a function I've added to vm.c called vm_Sync() which just saves the
modified objects by calling bigbufClean() and dbindexSave().  It's useful
when I wanna guarantee that something is saved.  You may wanna add it in.

94Jan21: Can we find a bit combination in the status byte to mean
GARBAGE?  To implement @rec, which is still a desirable ability, it
would be nice if we could change an object to class TRASH, then have
'get' check each pointer returned to see if it is trash, and if so set
that entry to an innocuous value, so that eventually the TRASH gets
recycled.  But we can't afford to hit disk to do this, hence the hope
of making it a fast check on the status byte.  Maybe the dead bit ...
maybe plus some other bits...?

94Jan15: Need to rethink this some more.  In muckstyle
applications, at least, the major gc bandwidth problem is going to be
massive creation of garbage strings which need to be garbage-collected
efficiently.  These will pass through the stacks, mostly: used in
expressions and local variables.  We need to be able to recover them
when doing single-generation garbage collects, in spite of the fact
that stacks will in general be old-generation objects, since they
survive as long as a login, often.  I don't think the current proposed
algorithm does this, but it shouldn't be hard to do.

---> err() should be a #define with a default!!
---> 4096 const should be #defined.

---> Refine buffer management policy.
Problem: 

My impression is that mud processes tend to fall into a
bimodal distribution, with lots of fairly idle processes
responding line by line to user input, while a few db scans
read large portions of the db.

I'm mainly interested in giving fast, lag-free response for
most users.  But a single process scanning through all of the
db can flush all context to disk under a naive buffer
management policy, not only slowing all other processes to
disk speeds, but helping itself not a whit, since it only
looks at each object once.  This is horrible performance, and
quite likely to be the normal operating mode of the mud if one
isn't careful.

Proposed solution:

Divide the ram buffer into two subbuffers, possibly growing in
from opposite ends of a single physical buffer, and attempt to
use one buffer for fairly stable working sets and the other
for transient data used by db scan processes.

We can keep a global variable monitoring the object fault rate
for the current process; if it is above some threshhold,
faulted-in objects are placed in the transient-data buffer,
else they are placed in the stable-working-set buffer.

Note that the threshold needs to kick in quickly, before a
process can flush the main buffer.  The threshhold should
perhaps be measured in interpreted instructions per object
fault?  Absolute milliseconds would be a defensible
alternative.

I don't see an obvious strategy for dynamically adjusting
how much ram is devoted to the transient buffer, and how much
to the stable buffer; since the transient buffer is intended
for processes that won't benefit much from caching, possibly
a small fixed size for the transient buffer would suffice.

Probably all ram-allocations should go in the transient
buffer if from a process which is doing a lot of
ram-allocates: In the mud context, we would really like to
protect the working sets of all stable, well-behaved
interactive processes from all classes of overactive
processes, not just dbscans.


---> Switch from two bitmaps to a single bytemap.

Byte-per-object layout proposed is:
  2 bits:   color: FREE/WHITE/GRAY/BLACK
  2 bits:   gen:   Garbage-collect generation (0-3)
  1 bit:    ref3   TRUE iff some gen-3 object on disk may reference us.
  1 bit:    pure:  TRUE iff we contain no pointers.
  1 bit:    db:    Home DB.
  1 bit:    dead:  TRUE iff we've called destructor fn on obj.

Rationale:
  'color' is needed by Dykstra's 3-color incremental gc algorithm.
  'gen' is needed so we can recover ram without touching disk. I
    want to be able to generate lots of garbage without thrashing the
    disk.  Generation 0 is objects not yet written to disk?
  'ref3' is needed to implement generational garbage collection:  if we
    are collecting garbage only in generations 0-2, all objects in
    generations 0-2 which (might be) referenced by objects in
    generation 3 must be treated as gc roots.
      Whenever we write a gen==3 object to disk, we set 'ref3' on all objects
    it points to;  hence, the in-ram 'ref3' fields plus the in-ram pointers
    tell us everything we need to do an in-ram garbage-collect.
      Whenever we do a full gc, we can clear to zero all ref3 bits.
    Since during this gc we will swap in all (ptr-containing) objects,
    ref3 fields will get set again as these objects swap out again; at the
    end of the gc, the INVARIANT that ref3 bits plus pointers in ram
    provide all needed gc information will be restored.
  'pure' saves us swapping in strings from disk just to do garbage
    collection.  Since most of a mud db consists of strings, this seems
    worth one bit.
  'db' is used during incremental backups to indicate which db from
    which to read the object, if we need to swap it in.  (Objects are
    always written to the new db, not the old one, of course.)
  'dead' is set after we call a destructor fn on an object.  Since we
    can't be sure a user-written destructor didn't pass a pointer to
    itself to someone, we can't recycle such objects until next gc.

Incremental backup algorithm:

  (1) Flush all dirty objects to current db.
  (2) Create new db.
  (3) Set 'db' of all in-ram  objects to NEW.
  (4) Set 'db' of all on-disk objects to OLD.
  (Above four steps should likely be done atomically, although if
  this proves too slow, some incrementality can be worked into the
  process.)
  (5) While the mud continues to run, incrementally do:
      While objects with db==OLD exist {
        Find one, swap it in, set db=NEW on it, mark it dirty.
      }
  (6) Close the old db, make 'new' db 'old' db, change 'db' on
      all objects to NEW.

Incremental garbage collection algorithm:

We modify vm_Loc() and other fns which search the hashtable to check
the secondary hashtable on a miss before checking disk.  All objects
whether from disk or from secondary hashtable, should (if nonWHITE --
meaning GRAY) be vm_Bleach()ed before being entered into the primary
hashtable.

We modify swapout to respect 'db' and to set 'ref3' appropriately on
all objects referenced by a given object before swapping that object
to disk.

  (0) Pick N==2 or N==3.  N==2 is a fast gc, N==3 is a full-db gc.
      At a guess, it may prove reasonable to mostly do N==2 collections,
      with once a day or so an N==3.
  (1) Move all in-ram objects to a second hashtable.
  (2) Set color of all non-FREE objects with gen <= N to BLACK.
  (3) Set color of all roots supplied by user to GRAY.
  (4) If N==2, set all objects with 'ref3' set to GRAY.
  (5) Move all objects referenced by hard pointers
      from secondary to primary hashtable, calling vm_Bleach() on them.
      (Note this requires no disk accesses.)
  (Last five steps should be done atomically.)
  (6) While the mud continues to run:
      While GRAY objects remain, call vm_Bleach(one such);      
  (7) While the mud continues to run:
      While BLACK objects remain, call the user-specified destructor
      fn on those with 'dead'==FALSE.  This gives classes
      a chance to de-allocate resources owned by an object: X
      server data structures, operating system file handles, and such.
      This may result in object turning WHITE again: we can't control
      what user-supplied destructor fns do.  If this is impossible
      we set the BLACK object FREE, else we set it WHITE but set
      'dead'==TRUE and (if gen!=3) 'gen'==0.
  (8) While the mud continues to run:
      Promote all objects to next generation.
      For each object promoted to generation 3, we need to set
      'ref3' bits on all objects referenced by it, of course...

vm_Bleach(o) simply colors GRAY all BLACK objects referenced by 'o',
then colors 'o' WHITE.  Since 'o' is in ram, and the color fields of
all objects are in ram, this requires no disk activity and can be done
quickly in time proportional to the number of pointers in 'o'.

*/
/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"

#ifdef HAVE_FCNTL_H
#include <fcntl.h>
#endif

#include <stdarg.h>

#ifdef HAVE_MALLOC_H
#include <malloc.h>
#endif

/* For lseek():	*/
#ifdef _BSD
#include <sys/file.h>
#else /*SysV*/
#include <sys/types.h>
#endif

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* At present we compress files asychronously during backup */
/* to reduce lag, but synchronously at server shutdown to   */
/* unsure the db is stable before the next server-startup   */
/* takes place.  The parameter passing path would be snarky */
/* enough that we just use a global variable instead.       */
#ifndef VM_COMPRESS_FILES_ASYNCHRONOUSLY
#define VM_COMPRESS_FILES_ASYNCHRONOUSLY (0)
#endif

/************************************************************************/
/* If you are using vm.c strictly as a runtime virtual			*/
/* memory allocator, you'll want to clear out vm/ * on			*/
/* each program run.   If you're using vm.c as a db to			*/
/* preserve program state between runs,  you obviously			*/
/* do NOT want to clear out vm/ * on each run. You may			*/
/* specify the default behavior by setting this define			*/
/* to TRUE or FALSE; You can over-ride this default at			*/
/* runtime by setting the matching variable before you			*/
/* call vm_Startup().							*/
/************************************************************************/
#ifndef VM_NUKE_DB_AT_STARTUP
#define VM_NUKE_DB_AT_STARTUP (1)
#endif



/* Offsets into octave->bitmap[]: */

/************************************************************************/
/* Intended uses:							*/
/* ALLOC    Slot is not free for allocation.				*/
/* RELOC    Slot points to actual slot (object has been resized).	*/
/* CONST    Slot contents should not be modified.			*/
/* WATCHED  Object has watchers wishing change notifies. (Unused.)	*/
/* MARK     For mark-and-sweep garbage collection.			*/
/* OLD_GEN  For multi-gen gc:  Object is old generation. (Unused.)	*/
/* OLD_ROOT For multi-gen gc:  May have ptrs to new objects. (Unused.)	*/
/************************************************************************/

#undef ALLOC
#undef CONST
#undef RELOC
#undef MARK
#undef OLD_GEN
#undef OLD_ROOT
#undef WATCHED

#define ALLOC    0
#define RELOC    1
#define CONST    2
#define WATCHED  3
#define MARK     4
#define OLD_GEN  5
#define OLD_ROOT 6




/* Offsets into octave->bytmap[]: */

#undef UNIQ
#undef TAGS

#define UNIQ 0
#define TAGS 1



/* What to do on fatal error:						*/
#ifndef VM_FATAL
#define VM_FATAL vm_fatal
static void vm_fatal(
    Vm_Uch *format, ...
) {
    /* First, sprintf the error message */
    /* into a temporary buffer:         */
    va_list args;
    Vm_Uch buffer[4096];
    va_start(args,   format);
    vsprintf(buffer, format, args);
    va_end(args);
    strcat(buffer,"\n");
    fputs(buffer,stderr);

    abort();
}
#endif

/* Old 32-bit or new 64-bit layout? */
#undef  VM_OLD_FORMAT

/************************************************************************/
/* Whether to include support for vm_Invariants() and			*/
/* vm_Print_State().  Since these are basically debug			*/
/* tools, bloatophobes may wish to suppress them. I'm			*/
/* inclined to include them in production use myself.			*/
/* Set to TRUE to compile, FALSE to not compile them:			*/
/************************************************************************/
#ifndef VM_DEBUG
#define VM_DEBUG (1)
#endif


/* What to call our octave files:					*/
#ifndef VM_OCTAVE_FILE_PATH
#define VM_OCTAVE_FILE_PATH "vm"
#endif

/************************************************************************/
/* Size of virtual ram buffer to store in-memory objects in.		*/
/* Should be at least four meg these days.				*/
/* Needs to be a power of two currently.				*/
/* Note: Muq sets this in muq/h/Defaults.h, following value is for	*/
/* vm used in other applications:					*/
/************************************************************************/
#ifndef VM_INITIAL_BIGBUF_SIZE
#define VM_INITIAL_BIGBUF_SIZE ((Vm_Unt)(0x400000))
#endif

/* Number of slots in hashTable. 	 				*/
/* I'm inclined to spend 1/16 as much ram on it as on bigbuf:		*/
#ifndef VM_HASHTAB_SIZE
#define VM_HASHTAB_SIZE  ((Vm_Unt)(VM_INITIAL_BIGBUF_SIZE >> 6))
#endif
#define VM_HASHTAB_MASK  ((Vm_Unt)(VM_HASHTAB_SIZE-1))
#define VM_HASHTAB_SHIFT VM_OCTAVE_SHIFT  /* VM_OFFSET_SHIFT */

/* How many hard pointers we allow registering.	*/
/* This is deliberately kept to a small fixed	*/
/* limit, since registering lots of pointers	*/
/* usually indicates stupidity or a bug:	*/
#ifndef VM_MAX_HARD_POINTERS
#define VM_MAX_HARD_POINTERS (30) /* Should be at least 2 spare */
#endif

/************************************************************/
/* To avoid pathology, if we are going to do a compaction   */
/* at all, we want to end with about half of bigbuf free.   */
/* That is, we don't want to get into a situation where	    */
/* we are repeatedly copying megabytes of bigbuf to free    */
/* up a couple hundred bytes of new ram, driving the	    */
/* average computational cost of allocating a byte up	    */
/* through the roof.  Making sure we always free up a	    */
/* fixed fraction of bigbuf when we compact avoids this	    */
/* pathology, and 1/2 seems as good a number as any other.  */
/* If someone wants to generate solid numbers on tuning     */
/* this parameter, that would be exceedingly cool too...    */
/*							    */
/* Min amount of bigbuf to free up during each compaction,  */
/* in range 0.0 -> 1.0:                                     */
/************************************************************/
#ifndef VM_MINFREE_AFTER_COMPACTION
#define VM_MINFREE_AFTER_COMPACTION (0.5)
#endif

/* We allow the user some number of tagbits at the lower */
/* end of the word (which we also use ourself), and use  */
/* the rest for pointer proper, the number of leading    */
/* '1's in the latter giving the octave (-2).  After     */
/* trying 7 tagbits (uncomfortably small address space)  */
/* and 2 tagbits (uncomfortably few tagbits for the rest */
/* of the mud) and 4 tagbits (not _quite_ enough for     */
/* the rest of Muq) I've settled on 5 user tagbits as    */
/* nice for a mud running in 32-bit integers.  I don't   */
/* advise tinkering with this unless you're not running  */
/* a Muq, or not using 32-bit ints.  Anyhow, the current */
/* code isn't guaranteed to work with other values:	 */
#ifndef VM_TAGBITS
#define VM_TAGBITS ((Vm_Unt)(5))
#endif

/* # bits in short sizefield in bigbufBlock->next:	*/
/* We only store values from 0-64 in it, so only 7 of   */
/* the allocated bits are actually in use, and one      */
/* of those seven is barely in use:                     */
#ifndef VM_SMALLSIZE_SHIFT
#define VM_SMALLSIZE_SHIFT ((Vm_Unt)(8))
#endif
#define VM_SMALLSIZE_MASK ((Vm_Unt)~0 >> (VM_INTBITS-VM_SMALLSIZE_SHIFT))

/* Shift used to extract size from long size fields.	*/
/* We need it to be at least 1.  Making it 8 gives us	*/
/* some bits in reserve on large objects, and also	*/
/* lets us store the userbits at the same offset in	*/
/* the ondisk length field in both big and small	*/
/*  octaves:						*/
#ifndef VM_BIGSIZE_SHIFT
#define VM_BIGSIZE_SHIFT ((Vm_Unt)(8))
#endif



/* Minimum size allowed for bigbuf.  vm.c will expand	*/
/* bigbuf whenever it gets in trouble, so this value	*/
/* isn't terribly important.  Setting it small makes	*/
/* the test suite run faster, however:                  */
#ifndef VM_BIGBUF_MIN
#define VM_BIGBUF_MIN ((Vm_Unt)(0x80))
#endif

/* Maximum size allowed for bigbuf.  This is dictated	*/
/* by the size of the bigbufBlock 'next' field:		*/
#ifndef VM_BIGBUF_MAX
#define VM_BIGBUF_MAX   ((Vm_Unt)((Vm_Unt)1 << (VM_INTBITS - VM_SMALLSIZE_SHIFT)))
#else
#if     VM_BIGBUF_MAX > ((Vm_Unt)1 << (VM_INTBITS - VM_SMALLSIZE_SHIFT))
#undef  VM_BIGBUF_MAX
#define VM_BIGBUF_MAX   ((Vm_Unt)((Vm_Unt)1 << (VM_INTBITS - VM_SMALLSIZE_SHIFT)))
#endif
#endif



/* Initial size for our garbage-collection	*/
/* stack.  Shouldn't matter much what value	*/
/* this is set to:				*/
#ifndef VM_MIN_GREY_STACK
#define VM_MIN_GREY_STACK ((Vm_Unt)(1024))
#endif

/* Maximum number of copies of db to maintain.	*/
/* A value of 1 yields one working copy while 	*/
/* actually running as well one stable backup	*/
/* copy.   If the system crashes unexpectedly	*/
/* the current working copy will in general be  */
/* inconsistent on disk, since parts of it were */
/* in memory at crash time, and it is essential */
/* to have at least one stable backup to retreat*/
/* to at such times.)  Two strikes me as a	*/
/* good minimum number, if you have the disk	*/
/* space to spare you may want to keep more:	*/
#ifndef VM_MAX_DB_COPIES_TO_KEEP
#define VM_MAX_DB_COPIES_TO_KEEP (6)
#endif

/* When an incremental backup / garbage-collect */
/* is in progress, we will automatically do     */
/* this many gc steps for each vm_Malloc().  It */
/* is fine to set this to zero if you prefer:   */
#ifndef VM_GC_STEPS_PER_MALLOC
#define VM_GC_STEPS_PER_MALLOC (2)
#endif

/* If this number is non-zero, client should	*/
/* automatically start a new garbage collection	*/
/* cycle every time this many objects have	*/
/* been created.  We don't do this in vm_Malloc	*/
/* because we can't know the db is consistent:	*/
#ifndef VM_OBJECT_CREATES_BETWEEN_GARBAGE_COLLECTS
#define VM_OBJECT_CREATES_BETWEEN_GARBAGE_COLLECTS (8192)
#endif

/* When we are doing an incremental backup /	*/
/* garbage-collect, we do this many garbage	*/
/* collect steps for every object created,	*/
/* to ensure we stay ahead of the game:		*/
#ifndef VM_GC_STEPS_PER_MALLOC
#define VM_GC_STEPS_PER_MALLOC (2)
#endif



/*********************************************************/
/*********************************************************/
/* Remaining #defines shouldn't normally be messed with: */
/*********************************************************/
/*********************************************************/

/* Always-1 bit in bigbufBlock->o.  We need this to */
/* distinguish bigbufBlocks with a leading length   */
/* word from those without when walking through     */
/* bigbuf (e.g., to do compaction):                 */
#define VM_HEADER   ((Vm_Unt)(0x1))

/* Dirty bit in bigbufBlock->o: */
#define VM_DIRTYBIT ((Vm_Unt)(0x2))

/* Macro to step to next block in hashtable chain:	*/
#define VM_NEXT_HASH_BLOCK(p) \
    ((Block) ((Vm_Int*)bigbufBeg + ((p)->next >> VM_SMALLSIZE_SHIFT)))


/* Two random constants for dbfileReadOrWrite() calls */
#define VM_READ (1)
#define VM_SEND (2)

/* Mask of bitrange in Vm_Objs which will be all '1's iff   */
/* Vm_Obj is a BIG_OCTAVE:				    */
#ifdef UNUSED
#define VM_BIG_OCTAVE_MASK					\
    (   (   (Vm_Unt)~0 >>					\
            VM_INTBITS - (VM_FIRST_BIG_OCTAVE-VM_FIRST_OCTAVE)	\
        )							\
        <<							\
	VM_TAGBITS						\
    )
#endif

#define VM_IS_BIG_OCTAVE(o) ((((o) >> VM_OCTAVE_SHIFT) & VM_OCTAVE_MASK) >= VM_FIRST_BIG_OCTAVE)



/* Macro to decide if an object is live -- dead	*/
/* objects have the 'next' field set zero:	*/
#define VM_IS_LIVE(o) ((o)->next & ~VM_SMALLSIZE_MASK)

/* Special ID for our single (virtual)  */
/* length-zero object.  Note we could   */
/* never (otherwise) actually issue     */
/* this ID, it would be in the largest  */
/* possible octave or such:             */
#define VM_LEN0_OBJ ((Vm_Unt)(~0))



/* Byte offset of first segment within a db file.  */
/* We currently have this hacked to be exactly one */
/* segment in size, so as to keep all segments     */
/* segment-aligned within the file, and hence all  */
/* 4K objects 4K-aligned and so forth. My guess is */
/* that this will be a Good Thing when we start    */
/* sharing these files via memory mapping between  */
/* separate host processes:                        */
#define VM_QUART0_OFFSET ((Vm_Unt)(0x100))	/* Must be nonzero. */

/* Size in bytes of a quart: */
#define VM_QUART_BYTES ((Vm_Unt)1 << VM_LOG2_QUART_BYTES)
#define VM_QUART_WORDS (((Vm_Unt)VM_QUART_BYTES) >> VM_LOG2_INTBYTES)


/* Symbolic names for dbpath[12] arguments: */
#define VM_PATH_CURRENT (-2)
#define VM_PATH_RUNNING (-1)


/************************************************************************/
/*-    Globals								*/
/************************************************************************/

 /***********************************************************************/
 /*-    Variables							*/
 /***********************************************************************/

/* Exported tuning parameters other */
/* modules are free to twiddle, see */
/* #define section for comments:    */
Vm_Unt vm_Total_Bytes_Allocated_Since_Last_Garbage_Collection;
Vm_Uch*vm_Octave_File_Path              = VM_OCTAVE_FILE_PATH;
Vm_Int vm_Nuke_Db_At_Startup            = VM_NUKE_DB_AT_STARTUP;
Vm_Int vm_Compress_Files_Asynchronously = VM_COMPRESS_FILES_ASYNCHRONOUSLY;
Vm_Unt vm_Gc_Steps_Per_Malloc           = VM_GC_STEPS_PER_MALLOC;
Vm_Unt vm_Object_Creates_Between_Garbage_Collects = (
         VM_OBJECT_CREATES_BETWEEN_GARBAGE_COLLECTS
);
Vm_Unt vm_Initial_Bigbuf_Size = VM_INITIAL_BIGBUF_SIZE;

/* Style of backups:  1 for logarithmic,    */
/*                    0 for linear.	    */
#ifndef VM_LOGARITHMIC_BACKUPS
#define VM_LOGARITHMIC_BACKUPS (1)
#endif

static struct Vm_Db_Stats_Rec default_stats = {
    VM_MAX_DB_COPIES_TO_KEEP,  
    0,
    VM_LOGARITHMIC_BACKUPS,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
};


 /***********************************************************************/
 /*-    bigbuf								*/
 /***********************************************************************/

struct bigbufBlock {
    Vm_Obj   o ;	/* Key. Low bits 0->3 are 1,LIVE, USR0,USR1.	*/
    Vm_Unt next;	/* Int offset in bigbuf of next hashchain entry.*/
                        /* Low 6 bits are size for short octaves.	*/
};  /* value follows block */

typedef struct bigbufBlock  A_Block;
typedef struct bigbufBlock*   Block;

/* bigbufHashtab is at fixed location and of fixed size */
/* in order to shave a couple of cycles off vm_Loc():	*/
static Block bigbufHashtab[ VM_HASHTAB_SIZE ];

/* Main buffer we store stuff in.  Give us a few meg and we'll		*/
/* swap the world :).							*/
static Block    bigbufBeg;		/* First byte in buffer.	*/
static Block    bigbufEnd;		/* First byte past buffer.	*/
static Block    bigbuffree;		/* First free byte in buffer.	*/
static Block    bigbufFirstMaybeDead;	/* First possibly dead byte.	*/
static Vm_Unt bigbufDeadBytes;	/* Count of dead bytes.		*/

/* Table of hard pointers into bigbuf -- these  */
/* objects may not be swapped out, and pointers */
/* must be updated when object moves.		*/
static Vm_Unt bigbufHardPointerCount;
static struct {
    Vm_Obj*o;
    Vm_Int offset;
    void** p;
} bigbufHardPointers[ VM_MAX_HARD_POINTERS ];




 /***********************************************************************/
 /*-    Tracking all open db files					*/
 /***********************************************************************/

/* 'this_db' is our primary current database.			*/
/* We make it a pointer so we can flip easily			*/
/* from one db to another:					*/
static  Vm_A_Db  db_a;
Vm_Db vm_Root_Db = &db_a;
Vm_Db vm_This_Db = &db_a;

 /***********************************************************************/
 /*-    dbtab -- dbfile hashtable					*/
 /***********************************************************************/


/* log2(size of dbfile): 13 == 8192 entries. */
#ifndef VM_DBTAB_LOG2_MAX_
#define VM_DBTAB_LOG2_MAX (13)
#endif

/* Following must be derived from above: */

#undef  VM_DBTAB_MAX
#define VM_DBTAB_MAX (1 << VM_DBTAB_LOG2_MAX)

#undef  VM_DBTAB_MASK
#define VM_DBTAB_MASK (VM_DBTAB_MAX-1)

#define VM_DBTAB_HASH(i) (((i)+(i>>VM_DBTAB_LOG2_MAX)) & VM_DBTAB_MASK)



static Vm_Db dbtab[ VM_DBTAB_MAX ];



 /***********************************************************************/
 /*-    Exploding a Vm_Obj						*/
 /***********************************************************************/

struct Ex_rec {
    Vm_Unt  octave;
    Vm_Unt  offset;
    Vm_Unt  dbfile;
    Vm_Unt  unique;
};
typedef struct Ex_rec  A_Ex;
typedef struct Ex_rec*   Ex;



 /***********************************************************************/
 /*-    Support for garbage collection and backup			*/
 /***********************************************************************/

#ifdef SOMEDAY
/* A flag to remember if we're in middle of	*/
/* incremental gc/backup.  gc_grey_stack_top	*/
/* goes to zero while we're still processing	*/
/* last grey object, so it's not a good		*/
/* substitute for this flag:			*/
static Vm_Unt gc_in_progress = FALSE;

/* We need to be able to find all pointers in	*/
/* a given object, but this requires knowledge	*/
/* only our client can provide. gc_all_ptrs	*/
/* points to a function provided by our caller	*/
/* which does precisely this for us:		*/
static void (*gc_all_ptrs)(Vm_Obj,void(*fn)(Vm_Obj)) = NULL;

/* In order to initiate garbage collection,  we */
/* need to be able to find all objects directly */
/* accessable by the interpreter. gc_roots is a */
/* null-terminated vector of pointers to all    */
/* Vm_Obj interpreter variables, or at least	*/
/* enough to find all such objects:		*/
static Vm_Obj **gc_roots                             = NULL;


/************************************************/
/* gc_grey_stack holds all existing Grey	*/
/* objects.  My original try used a queue	*/
/* instead of a stack, and let it overflow	*/
/* if it got too big, refilling it by searching	*/
/* our bitmaps, but unfortunately this fails	*/
/* because gc_all_ptrs() will require, in	*/
/* general, a full pointer including the lower	*/
/* five user bits, and we can't reconstitute	*/
/* those missing five bits from the bitmaps.	*/
/* So we have to be careful never to lose	*/
/* a pointer to a Grey object, which means we	*/
/* have to be prepared to make gc_grey_stack	*/
/* arbitrarily large, which is a bit irritating.*/
/* With luck, making it a stack instead of a	*/
/* queue will keep it from growing too large	*/
/* under most circumstances, as well as having	*/
/* the effect of increasing the likelihood that	*/
/* the next Grey object we process is in ram... */
/*						*/
/* gc_grey_stack also serves as a 'backup-in-	*/
/* progress' flag, since it is nonzero iff we	*/
/* are in the middle of a gc/backup:		*/
/************************************************/
static Vm_Obj*  gc_grey_stack      = NULL;
static Vm_Unt gc_grey_stack_top  = 0;	/* Zero means stack empty.	*/
static Vm_Unt gc_grey_stack_size = 0;
#endif



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

#if VM_DEBUG
static void     bigbufPrint( FILE* );
static void     bitmapsPrint( FILE*, Vm_Db );
static void     hshtabPrintChain( FILE*, Vm_Int );
static void     hshtabPrint( FILE* );
static int      bigbufInvariants( FILE*, Vm_Uch*, int );
static int      bitmapInvariants( FILE*, Vm_Uch*, int );
static int      hshtabInvariants( FILE*, Vm_Uch*, int );
#endif

/* Just on the offchance someone has it #defined: */
#undef swap

static void*    alloc(Vm_Int);
static Block    bigbufAlloc(Vm_Unt);
static void     bigbufClean( void );
static void     bigbufCompact( void );
static Block    bigbufFirst( void );
static void     bigbufFlushDb( Vm_Int );
static void     bigbufFree( Block );
static void     bigbufInit( void );
static void 	bigbufResize( Vm_Unt );
static void     bigbufMakeSpace( Vm_Unt );
static Block    bigbufNew(Vm_Unt,Vm_Unt,Vm_Unt,Vm_Unt,Vm_Unt);
static Block    bigbufNext( Block );
static void     bigbufSwapObjOut( Block );
static Vm_Unt   bitget(Vm_Db,Vm_Unt,Vm_Unt,int);
static void     bitset(Vm_Db,Vm_Unt,Vm_Unt,Vm_Int,Vm_Int);
static Vm_Unt   getAllocBit( Vm_Db, Vm_Unt, Vm_Unt );
static void     setAllocBit( Vm_Db, Vm_Unt, Vm_Unt, Vm_Int );
static Vm_Unt   bitmapExpand( Vm_Db, Vm_Unt );
static void     bitmapFree( Vm_Db, Vm_Obj );
static Vm_Unt   bitmapNew( Vm_Db, Vm_Unt, Vm_Unt );
static Vm_Obj   bitmapNext(Vm_Db, Vm_Obj);
static Vm_Int   bytget(Vm_Db,Vm_Unt,Vm_Unt,Vm_Unt);
static void     bytset(Vm_Db,Vm_Unt,Vm_Unt,Vm_Unt,Vm_Int);
static Vm_Int   sizeGet(Vm_Db,Vm_Unt,Vm_Unt);
static void     sizeSet(Vm_Db,Vm_Unt,Vm_Unt,Vm_Int);
static Vm_Int   physicalSize(Vm_Db,Ex);
#ifdef SOMEDAY
static void     bitmapTake(Vm_Db, Vm_Unt, Vm_Unt );
#endif
static void     initialize_object_bitfields_and_bytefields(Vm_Db,Vm_Unt,Vm_Unt,Vm_Unt,Vm_Uch,Vm_Uch);
static void     bitmapSlotValidate(Vm_Db,Vm_Unt,Vm_Unt);
static void     bitmapsNuke( Vm_Db );
static void     bitmapExpandQuartOffsetArray( Vm_Db  db, Vm_Unt octave );
#ifdef SOMEDAY
static void     cacheDelete( Vm_Db, Vm_Unt, Vm_Unt );
#endif
static Vm_Int   cacheFreeslot( Vm_Db, Vm_Unt, Vm_Unt );
static void     cacheRefill( Vm_Db, Vm_Unt );
static Vm_Int*  copy(Vm_Int*,Vm_Int*,Vm_Unt);
static void     dbDuplicate(Vm_Db,Vm_Uch*);
static void     dbfileReadOrWrite(Vm_Db,Vm_Unt,Vm_Uch*,Vm_Unt,Vm_Int);
static void     dbfileSet(Vm_Db,Block);
static void     dbfileZeroAllEmptySlots(Vm_Db);
static Vm_Db       dbfindInRam(Vm_Unt);
static Vm_Unt   dbgetUniqueBits( Vm_Db, Vm_Unt, Vm_Unt );
static Vm_Unt   dbgetTagBits(    Vm_Db, Vm_Unt, Vm_Unt );
static void     dbindexClear( Vm_Db );
static Vm_Int   dbindexCompress( Vm_Db, Vm_Int, Vm_Uch* );
static int      dbfileExists(Vm_Unt,Vm_Uch*);
static Vm_Db    dbfind(Vm_Unt);
static void     dbtrailerLoad( Vm_Db db, int fd, int swap, Vm_Uch* ext );
static void     dbindexLoad( Vm_Db, Vm_Uch*, int* );
static void     dbindexSave( Vm_Db, int, Vm_Uch*, Vm_Unt );
static Vm_Int   dbquartsSave(Vm_Db, int );
static void     dbquartsRead(Vm_Db, int );
static void     dbinit( Vm_Db, Vm_Unt  );
static Vm_Db    dbnew(  Vm_Unt  );
static unsigned char* dbpath1( Vm_Int id, Vm_Int gen, unsigned char* ext );
static unsigned char* dbpath2( Vm_Int id, Vm_Int gen, unsigned char* ext );
static void     quartZero( Vm_Db db, Vm_Unt quartNo );
static Vm_Unt   quartAlloc( Vm_Db );

static Vm_Unt   quartsAlloc(  Vm_Db db,    Vm_Int n);
static Vm_Unt   quartIsInUse( Vm_Db  db, Vm_Unt quartNo );
static Vm_Unt   quartOffsetSlotAlloc( Vm_Db db );
static void     quartsAllocExpand( Vm_Db  db, Vm_Unt n );
static void     quartFree( Vm_Unt quartNo );

static void     db_nuke(Vm_Db,Vm_Int,Vm_Uch*);
static void     db_rename(Vm_Db,Vm_Int,Vm_Int);
static void     db_renaming(Vm_Db);
static void     db_logarithmic_nuke(Vm_Db);
static void     dbtab_clear( void );
#ifdef SOMEDAY
static Block    dbfileGet( Vm_Db, Vm_Obj);
static Vm_Int   gc_color_obj_grey(Vm_Obj);
static void     gc_color_obj_white(Vm_Obj);
static void     gc_grey_stack_init(void);
static Vm_Obj   gc_grey_stack_pop( void);
static void     gc_grey_stack_push(Vm_Obj);
static void     gc_note_roots(Vm_Obj**);
static Vm_Int   gc_obj_is_black(Vm_Obj);
static Vm_Int   gc_obj_is_grey(Vm_Obj);
static Vm_Int   gc_obj_is_white(Vm_Obj);
static Vm_Int   gc_process_grey_object(Vm_Obj);
static void     gc_start(void);
#endif
static void     hshtabFree( Block );
static void     hshtabNoteMotion( Block, Block );
static Vm_Unt   len( Block );
static Block    loc( Vm_Obj );
static void*    locB( Vm_Unt );
static int      lockedInRam( Vm_Obj );
void     objExplode(Ex,Vm_Obj);
static Vm_Obj   objImplode(Vm_Unt,Vm_Unt,Vm_Unt,Vm_Unt);
static void     saveHardPointerOffsets( void );
static void     set_signals(void);
static Vm_Unt   powerOfTwoCeiling(Vm_Unt);
static void     updateHardPointers( void );
static void     vsystem(const Vm_Uch* file,int line,const Vm_Uch* cmd );
#define vmsystem(x) vsystem(__FILE__,__LINE__,x)
static int      vopen(const Vm_Uch* file,int line,const Vm_Uch* name,int mode );
#define vmopen(x,y) vopen(__FILE__,__LINE__,x,y)
static int      vclose(const Vm_Uch* file,int line,int fd );
#define vmclose(x) vclose(__FILE__,__LINE__,x)


/* Buggo: I believe these are now used only by muq.t, */
/* and that muq.t should be returning totals over all */
/* the open db files, rather than the numbers for     */
/* just vm_This_Db.                                   */
Vm_Unt vm_Consecutive_Backups_To_Keep(Vm_Unt db){  return dbfind(db)->s.consecutive_backups_to_keep; }
Vm_Unt vm_Backups_Done(Vm_Unt db){                 return dbfind(db)->s.backups_done; }
Vm_Unt vm_Logarithmic_Backups(Vm_Unt db){          return dbfind(db)->s.logarithmic_backups; }
Vm_Unt vm_Object_Reads(Vm_Unt db){                 return dbfind(db)->s.object_reads; }
Vm_Unt vm_Object_Sends(Vm_Unt db){                 return dbfind(db)->s.object_sends; }
Vm_Unt vm_Object_Creates(Vm_Unt db){               return dbfind(db)->s.object_creates; }
Vm_Unt vm_Object_Creates_Since_Last_Gc(Vm_Unt db){ return dbfind(db)->s.object_creates_since_last_gc; }
Vm_Unt vm_Garbage_Collects_Completed(Vm_Unt db){   return dbfind(db)->s.garbage_collects_completed; }
Vm_Unt vm_Total_Gc_Steps_Done(Vm_Unt db){          return dbfind(db)->s.total_gc_steps_done; }
Vm_Unt vm_Steps_Done_For_This_Gc(Vm_Unt db){       return dbfind(db)->s.steps_done_for_this_gc; }
Vm_Unt vm_Used_Blocks(Vm_Unt db){                  return dbfind(db)->s.used_blocks; }
Vm_Unt vm_Free_Blocks(Vm_Unt db){                  return dbfind(db)->s.free_blocks; }
Vm_Unt vm_Bytes_In_Useful_Data(Vm_Unt db){         return dbfind(db)->s.bytes_in_useful_data; }
Vm_Unt vm_Bytes_Allocated_Since_Last_Garbage_Collection(Vm_Unt db){ return dbfind(db)->s.bytes_allocated_since_last_garbage_collection; }
Vm_Unt vm_Bytes_Lost_In_Used_Blocks(Vm_Unt db){    return dbfind(db)->s.bytes_lost_in_used_blocks; }
Vm_Unt vm_Bytes_In_Free_Blocks(Vm_Unt db){         return dbfind(db)->s.bytes_in_free_blocks; }
Vm_Obj vm_Root(Vm_Unt db){                         return dbfind(db)->s.root; }

void vm_Set_Bytes_Allocated_Since_Last_Garbage_Collection(Vm_Unt db,Vm_Unt u){
     vm_This_Db->s.bytes_allocated_since_last_garbage_collection=u;
}

void vm_Set_Logarithmic_Backups(Vm_Unt db,Vm_Unt u){
     vm_This_Db->s.logarithmic_backups=u;
}

void vm_Set_Consecutive_Backups_To_Keep(Vm_Unt db,Vm_Unt u){
     vm_This_Db->s.consecutive_backups_to_keep=u;
}

void
vm_Set_Root(
    Vm_Unt id,
    Vm_Obj o
){
    Vm_Db db = dbfind(id);
    db->s.root=o;
}

static Vm_Int
vm_octave_capacity[ 8 ] = {
	8,	/*  0 FIRST_OCTAVE		*/
       16,	/*  1				*/
       24,	/*  2				*/
       32,	/*  3				*/
       48,	/*  4				*/
       64,	/*  5				*/
      128,	/*  6				*/
      256	/*  7 FINAL_OCTAVE		*/
};



/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    dbclose -- Close down one dbfile.				*/
/************************************************************************/

static void
dbclose(
    Vm_Db db
) {

    #ifdef MUQ_WARN
    if (!muq_Is_In_Daemon_Mode) {
	fprintf(stderr,
	    "Closing db %s...\n",
	    vm_DbId_To_Asciz( db->dbfile )
	);
    }
    #endif

    if (db->wasCompressed)   dbfileZeroAllEmptySlots(db);

    dbindexSave( db, vm_Root_Db->fileDescriptor, "muqmuq\n\0", (Vm_Unt)db->bytesInFile );

    /* Rename RUNNING to CURRENT and CURRENT to (generation) dbs: */
    db_renaming(db);

    if (db->wasCompressed) {
	dbindexCompress(db,VM_PATH_CURRENT,".muq");
    }

    /* That may give us one more db than */
    /* we're supposed to be keeping:     */
    if (db->s.logarithmic_backups) {
	db_logarithmic_nuke(db);
    } else {
	Vm_Int to_zap = db->s.backups_done - db->s.consecutive_backups_to_keep;
	if (   to_zap >= 0)    db_nuke( db, to_zap, ".muq" );
    }


    bitmapsNuke(db);
}

/************************************************************************/
/*-    db_synch_backup_parameters -- Synch db to root db.		*/
/************************************************************************/

static void
db_synch_backup_parameters(
    Vm_Db db
) {
    db->s.logarithmic_backups         = vm_Root_Db->s.logarithmic_backups;
    db->s.consecutive_backups_to_keep = vm_Root_Db->s.consecutive_backups_to_keep;
    db->s.backups_done                = vm_Root_Db->s.backups_done;
}

/************************************************************************/
/*-    vm_Preshutdown -- Prepare to vm_Reinitialize.			*/
/************************************************************************/

void
vm_Preshutdown(
    void
) {
    Vm_Db db;

    bigbufClean();

    /* Set all mounted dbs to same backup state as */
    /* root db. I dislike overriding local settings*/
    /* with global ones in this fashion, but this  */
    /* ensures that old logarithmic backups sets   */
    /* form consistent images, which otherwise     */
    /* would not be true, making them much less    */
    /* useful in practice:                         */
   /* [This is probably pointless now that all    */
   /* the dbfiles are folded into one.]           */
    for (db = vm_Root_Db->next;   db;   db = db->next) {
       db_synch_backup_parameters(db);
    }

    dbclose(vm_Root_Db);

    free( bigbufBeg );
}



/************************************************************************/
/*-    vm_Restartup -- Redo start of world initialization.		*/
/************************************************************************/

/************************************************************************/
/* Note that vm_Nuke_Db_At_Startup is essentially			*/
/* a parameter to this fn.  We don't make it a true			*/
/* parameter because that would screw up our general			*/
/* convention of having modules initialize modules			*/
/* they depend on by calling xxx_startup() with no			*/
/* parameters -- distributing knowledge of needed			*/
/* startup parameters to all modules who use us				*/
/* would likely be ugly and a poor precedent.				*/
/************************************************************************/

int
vm_Restartup(
    void
) {

    /* Sanity checks on various constants user has selected.         */
    /* Good compilers will optimize some of these completely away :) */
    if ((Vm_Unt)~0 >> VM_INTBITS-1   !=   1) {
	/* Our pointer-construction code isn't going to work: */
	VM_FATAL ("VM_INTBITS is wrong");
    }
    if (((1 << VM_BYTEBITS)-1) != (Vm_Int)(Vm_Uch)((1 << VM_BYTEBITS)-1)) {
	/* Our bitmap code isn't going to work: */
	VM_FATAL ("VM_BYTEBITS is wrong");
    }
    if (VM_INTBYTES != sizeof(Vm_Int)) {
	VM_FATAL ("VM_INTBYTES is wrong");
    }

    vm_Total_Bytes_Allocated_Since_Last_Garbage_Collection = 0;

    /* Decided to stop runtime initializing these,  */
    /* no obvious advantage and it makes x_vm:test4 */
    /* numbers less useful:                         */
    /* vm_This_Db->s.object_reads  = 0; */
    /* vm_This_Db->s.object_sends = 0; */

    /* Arrange to get full core dumps: */
    set_signals();

    /* Establish our bigbuf invariants: */
    bigbufInit();

    /* Clear out hashtable of loaded dbfiles: */
    dbtab_clear();

    /* Establish root dbfile record: */
    dbinit( &db_a, (Vm_Unt)0 );

    /* If we have a vm1, copy it to vm0, */
    /* aborting if vm0 exists already:   */
    dbDuplicate(      vm_Root_Db, ".muq" );

    if (vm_Nuke_Db_At_Startup) {
	dbindexClear( vm_Root_Db );
    }

    {   int swap;
        dbindexLoad(      vm_Root_Db, ".muq", &swap );
	return swap;
    }
}



/************************************************************************/
/*-    vm_Startup -- Start of world initialization.			*/
/************************************************************************/

int
vm_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup) return 0;
    done_startup	       = TRUE;

    return vm_Restartup();
}



/************************************************************************/
/*-    vm_Linkup -- Start of world initialization.			*/
/************************************************************************/

void
vm_Linkup(
    void
) {
    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;

    /* Verify a needed/assumed identity: */
    if (VM_QUART_BYTES != vm_octave_capacity[ VM_FINAL_OCTAVE ]) {
        VM_FATAL("vm_Linkup: VM_QUART_BYTES != vm_octave_capacity[ VM_FINAL_OCTAVE ]");
    }
}



/************************************************************************/
/*-    vm_Shutdown -- Program exit cleanup.				*/
/************************************************************************/

void
vm_Shutdown(
    void
) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown               = TRUE;

    vm_Preshutdown();
}



/************************************************************************/
/*-    vm_Backup_Start -- Initiate incremental backup/garbage collect.	*/
/************************************************************************/

void
vm_Backup_Start(
    void   (*all_ptrs)(Vm_Obj,void(*fn)(Vm_Obj)),
    Vm_Obj** roots
) {
/* CrT note to self: remember skt job pointers */
/* are roots also when setting up gc! */
#ifdef SOMEDAY

    /* Remember object layout conventions: */
    gc_all_ptrs = all_ptrs;
    gc_note_roots( roots );

    gc_start();
#else
VM_FATAL("vm_Backup_Start: This function not checked out yet|N");
#endif
}



/************************************************************************/
/*-    vm_Backup_Continue -- Do increment of backup/garbage-collect.	*/
/************************************************************************/

/* We return TRUE until backup/garbage-collect  */
/* is complete, at which point we return FALSE. */

Vm_Obj
vm_Backup_Continue(
    void
) {
#ifdef SOMEDAY
    /* If there's an object on grey_stack, process it.  */
    /* If it's on the stack, it must not be in ram, and */
    /* if it is on disk, touching it is sufficient to   */
    /* trigger processing of it, so we simply vm_Loc:   */
    Vm_Obj o;
    if    (o = gc_grey_stack_pop())   vm_Loc( o );

    ++ vm_This_Db->s.total_gc_steps_done;
    ++ vm_This_Db->s.steps_done_for_this_gc;

    /* If it was last object on grey_stack,    */
    /* close down last_db, we're done with it: */
    if (o && !gc_grey_stack_top) {
        bitmapsNuke( last_db);
	vm_This_Db->s.garbage_collects_completed  += 1;
	vm_This_Db->s.object_creates_since_last_gc = 0;
        gc_in_progress                  = FALSE;
    }

    return o;
#else
VM_FATAL("vm_Backup_Start: This function not checked out yet|N");
    return 0;
#endif
}



/************************************************************************/
/*-    vm_Clear_Markbits -- Clear all markbits.				*/
/************************************************************************/

void
vm_Clear_Markbits(
    void
){
    Vm_Db db;
    for  (db = vm_Root_Db;   db;   db = db->next) {
	Vm_Unt i;
	for   (i = VM_FIRST_OCTAVE;   i <= VM_FINAL_OCTAVE;  ++i) {
	    Octave o = &db->o[i];
	    Vm_Unt*m = o->bitmap[MARK];
	    Vm_Unt j;
	    for (j = o->allocSlots >> VM_LOG2_INTBITS;   j --> 0;  ) {
		*m++ = (Vm_Unt)0;
	    }
	}
    }
}

/************************************************************************/
/*-    vm_Dirty -- Mark object as changed.				*/
/************************************************************************/

void
vm_Dirty(
    Vm_Obj o
) {
    loc(o)->o |= VM_DIRTYBIT;
}


/************************************************************************/
/*-    vm_Db_Stats -- Return db stats record for dbfile of given 'o'.	*/
/************************************************************************/

Vm_Db_Stats
vm_Db_Stats(
    Vm_Obj   o
) {
    A_Ex  e;
    Vm_Db    db;

    objExplode( &e, o );

    db = dbfindInRam( e.dbfile );
 
    /* Stupid hackt to handle oddball case */
    /* of pointer to unloaded package --   */
    /* should do something saner here:     */
    if (!db)   db=dbfindInRam(0);

    return &db->s;
}


/************************************************************************/
/*-    vm_Dup -- Return byte-for-byte copy of 'obj'.			*/
/************************************************************************/

Vm_Obj
vm_Dup(
    Vm_Obj   obj,
    Vm_Unt   dbfile
) {
    return vm_SizedDup( obj, vm_Len(obj), dbfile );
}



/************************************************************************/
/*-    vm_First -- Return first object in virtual memory.		*/
/************************************************************************/

Vm_Obj
vm_First(
    Vm_Db db
) {

    /* A cheap trick depending on us never allocating octave 2 obj 0: */
    return vm_Next( objImplode( VM_FIRST_OCTAVE, 0, db->dbfile, 0 ), db );
}



/************************************************************************/
/*-    vm_Free -- Recycle an existing virtual memory object.		*/
/************************************************************************/

void
vm_Free(
     Vm_Obj o
) {
#ifdef OLD
    /* Icky special case for length-zero object: */
    if (o >> VM_TAGBITS   ==   VM_LEN0_OBJ >> VM_TAGBITS)   return;
#endif

    {   Vm_Unt  len = vm_Len( o );
        A_Ex    e;
        Vm_Db   db;
	Vm_Int  physicalsize;
	objExplode( &e, o );

        db = dbfind(e.dbfile);
	physicalsize = physicalSize( db, &e );
	db->s.bytes_in_useful_data      -= len;
	db->s.bytes_lost_in_used_blocks -= physicalsize - len;
	db->s.bytes_in_free_blocks      += physicalsize;

	/* Delete object from bigbuf and hashtable, if present: */
	if (vm_Is_In_Ram(o))    bigbufFree( loc(o) );

	bitmapFree( db, o );
    }
}


/************************************************************************/
/*-    vm_Clr_Constbit							*/
/************************************************************************/

void
vm_Clr_Constbit(
    Vm_Obj o
){
    A_Ex e;
    objExplode( &e, o );
    bitset( dbfind(e.dbfile), e.octave, e.offset, CONST, 0 );
}

/************************************************************************/
/*-    vm_Get_Constbit							*/
/************************************************************************/

Vm_Unt
vm_Get_Constbit(
    Vm_Obj o
){
    A_Ex e;
    objExplode( &e, o );
    return bitget( dbfind(e.dbfile), e.octave, e.offset, CONST );
}

/************************************************************************/
/*-    vm_Set_Constbit							*/
/************************************************************************/

void
vm_Set_Constbit(
    Vm_Obj o
){
    A_Ex e;
    objExplode( &e, o );
    bitset( dbfind(e.dbfile), e.octave, e.offset, CONST, 1 );
}


/************************************************************************/
/*-    vm_Get_Markbit							*/
/************************************************************************/

Vm_Unt
vm_Get_Markbit(
    Vm_Obj o
){
    A_Ex e;
    objExplode( &e, o );
    return bitget( dbfind(e.dbfile), e.octave, e.offset, MARK );
}

/************************************************************************/
/*-    vm_Set_Markbit							*/
/************************************************************************/

void
vm_Set_Markbit(
    Vm_Obj o
){
    A_Ex e;
    objExplode( &e, o );
    bitset( dbfind(e.dbfile), e.octave, e.offset, MARK, 1 );
}

/************************************************************************/
/*-    vm_Is_In_Ram -- TRUE iff 'o' is currently in ram.		*/
/************************************************************************/

void*
vm_Is_In_Ram(
    Vm_Obj obj
) {
    /* This is just an unoptimized version of vm_Loc()/locB() */
    /* that doesn't end by swapping object in if not found:   */
    register Vm_Unt o = obj >> VM_HASHTAB_SHIFT;
    register Block    h;
    for (
	h = bigbufHashtab[ o & VM_HASHTAB_MASK ];
	h->next >> VM_SMALLSIZE_SHIFT;
	h = VM_NEXT_HASH_BLOCK(h)
    ) {
        if (h->o >> VM_HASHTAB_SHIFT   ==   o)   return (void*) (h+1);
    }

    return NULL;
}



/************************************************************************/
/*-    vm_Is_Valid -- TRUE iff 'o' is currently a valid vm handle.	*/
/************************************************************************/

Vm_Int
vm_Is_Valid(
    Vm_Obj o
) {
    /* First part is a noncrashing version of objExplode. */
    /* Probably we should avoid the code duplication:     */
    Vm_Unt offset = (o >> VM_OFFSET_SHIFT) & VM_OFFSET_MASK;
    Vm_Unt octave = (o >> VM_OCTAVE_SHIFT) & VM_OCTAVE_MASK;
    Vm_Unt dbfile = VM_DBFILE(o);
/*  Vm_Unt size   = 1 <<  (VM_FIRST_OCTAVE+octave); */

    Vm_Db  db     = dbfindInRam(dbfile);
    if (!db)                        return FALSE;
    if (octave > VM_FINAL_OCTAVE)   return FALSE;

    /* Second part is a noncrashing variant of the setAllocBit logic: */

    if (offset >= db->o[octave].diskSlots)  return FALSE;


    /* Check appopriate 'allocated' bit: */
    if (octave == VM_FINAL_OCTAVE) {
        if (!db->o[octave].quartOffset[offset])   return FALSE;
    } else {
	Vm_Int wordNo = offset >> VM_LOG2_INTBITS;
	Vm_Int bitNo  = offset  & (VM_INTBITS-1);
	Vm_Int word   = db->o[octave].bitmap[ALLOC][ wordNo ];

	if ((word & (((Vm_Unt)1) << bitNo))  ==  0)   return FALSE;
    }

    /* Check the 'unique' guard bits: */
    {   Vm_Unt uniq  = (o >> VM_UNIQUE_SHIFT) & VM_UNIQUE_MASK;
	if    (uniq != bytget(  db, octave, offset, UNIQ ))   return FALSE;
    }

    return TRUE;
}



/************************************************************************/
/*-    vm_Invariants -- Sanity check on datastructures.			*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

Vm_Int
vm_Invariants(
    FILE* errlog,
    Vm_Uch* title
) {
    static int count = 0;
    Vm_Int errs = 0;
    ++count;
return 0;
    if (count & 0xFF)   return 0;
    errs    += bigbufInvariants( errlog, title, count );
    errs    += hshtabInvariants( errlog, title, count );
#if VM_DEBUG
    errs    += bitmapInvariants( errlog, title, count );
#endif
    return errs;
}



/************************************************************************/
/*-    vm_Len -- Return size-in-bytes of obj 'o'.			*/
/************************************************************************/

/* Vm_Unt len = vm_Len( (Vm_Obj)o );				       	*/

/* We return the 'len' value originally supplied to vm_Malloc: */

Vm_Unt
vm_Len(
    Vm_Obj o
) {
    A_Ex e;
    objExplode( &e, o );
    return sizeGet( dbfind(e.dbfile), e.octave, e.offset );
}



/************************************************************************/
/*-    vm_Loc -- Return ram address of obj, loading if need be.		*/
/************************************************************************/

void*
vm_Loc(
    Vm_Obj obj
) {
    /************************************************************/
    /* We try to handle the common case of 'o' being in ram     */
    /* and at head of hashtable chain as quickly as possible,   */
    /* since this is definitely going to be a hotspot in the	*/
    /* system as a whole.  I had this as a macro for awhile,	*/
    /* but that's messy and I'm not sure it's faster.  The	*/
    /* current mainline sequence should look something like	*/
    /*    mov r0, obj     ; pass obj to vm_Loc                	*/
    /*    call    vm_Loc  ; call vm_Loc                       	*/
    /*    mov r1, r0      ; copy obj to o                     	*/
    /*    rsh r1,  4      ; shift o                           	*/
    /*    mov r0,  r1     ; copy  o                           	*/
    /*    and r0, VM_HASHTAB_MASK ; do the hashtable hash    	*/
    /*    add r0, &bigbufHashtab   ; fetch start of            	*/
    /*    mov r0, [r0]    ; hash table chain                 	*/
    /*    mov r2,  r0     ; fetch the                        	*/
    /*    mov r2, [r2]    ; o field in hashtab -- no offset :)	*/
    /*    rsh r2,  4      ; shift away tagbits                	*/
    /*    cmp r2,  r1     ; compare o and ->o                 	*/
    /*    bne somewhere   ; branch not taken (we hope)        	*/
    /*    add r0,   8     ; complete return value             	*/
    /*    ret             ; done                              	*/
    /* Fifteen instructions, two jumps taken (CALL and RET).    */
    /* Call it about 24 clock cycles with a bit of luck.  An    */
    /* index-table implementation of vm might cut this in       */
    /* half, and of course using native-C pointers instead of	*/
    /* software virtual memory would cut that in half or a	*/
    /* quarter again, but above seems fast enough not to	*/
    /* cripple the interpreter or force us to adopt a		*/
    /* different design.					*/
    /*    The above code appears fairly close to optimal.     	*/
    /* The memory fetches are mostly logically required,      	*/
    /* the shifts could be eliminated only by adding a lot    	*/
    /* to the ram overhead, the compare and branch are required	*/
    /* by any hashtable approach.  On the right compiler, we   	*/
    /* might avoid the call/ret by inlining or making vm_Loc a	*/
    /* macro.                                                 	*/
    /*    Unfortunately, most compilers don't have inlining,  	*/
    /* and making vm_Loc a macro using ansi C seems to require	*/
    /* using global variables instead of register ones, which 	*/
    /* would probably lose overall, or else requires us to    	*/
    /* repeat expressions and trust to common subexpression   	*/
    /* elimination, which is risky on today's compilers.  All 	*/
    /* in all, it seems best to leave the code a function, at 	*/
    /* least for now.  Gcc has both good inlining and ways of 	*/
    /* writing such macros nicely, we might at some point     	*/
    /* consider an #if selecting support for it.              	*/
    /*==========================================================*/
    /* Later addendum:					       	*/
    /* For the RS/6000, at least, appears I was I trifle       	*/
    /* too pessimistic:					       	*/
    /*  		  PDEF     vm_Loc		       	*/
    /*  		  PROC     obj,r3		       	*/
    /*  8082 019C    1    L        r4=.vm$$(r2,0)	       	*/
    /*  5465 F73A    1    RN       r5=r3,30,0xC		       	*/
    /*  7C84 282E    1    L        r4=bigbufHashtab(r4,0,r5)   	*/
    /*  5460 E13E    1    SRL      r0=r3,4		       	*/
    /*  80A4 0000    1    L        r5=(int)(r4,0)	       	*/
    /*  3084 0008    1    AI       r4=r4,8		       	*/
    /*  54A5 E13E    1    SRL      r5=r5,4		       	*/
    /*  7C05 0040    1    CL       cr0=r5,r0		       	*/
    /*  4082 000C    3    BF       CL.20,cr0,0x4/eq	       	*/
    /*  6083 0000    1    LR       r3=r4		       	*/
    /*  4E80 0020    2    BA       lr			       	*/
    /*  	      CL.20:				       	*/
    /*  4800 4140    0    CALLF    r3=locB...		       	*/
    /*  	      CL.517:				       	*/
    /*  4E80 0020    0    BA       lr			       	*/
    /*         Straight-line exec time   14		       	*/
    /*							       	*/
    /*==========================================================*/
    /* Later addendum:					       	*/
    /*  gprof reports Muq spends about 5% of its CPU time in    */
    /* vm_Loc and 0.5% of its time in locB(), with about a 99%	*/
    /* cache hit rate.						*/
    /*  Using a bad hash function with only a 75% hit rate has	*/
    /* been observed to result in Muq spending 75% of its time	*/
    /* in locB().						*/
    /*  This would seem to verify both the design expectation	*/
    /* that vm_Loc() would be a hotspot, and that the current   */
    /* implementation is reasonably effective.			*/
    /************************************************************/
    register Vm_Unt o = (obj >> VM_HASHTAB_SHIFT);
    register Block    h = bigbufHashtab[ o & VM_HASHTAB_MASK ];

    if (h->o >> VM_HASHTAB_SHIFT  ==  o)   return (void*)(h+1);

    /*****************************************************/
    /* Put all the rest of the machinery in another fn,  */
    /* mostly to improve the optimization done to the	 */
    /* above code -- compilers seem to prefer small fns. */
    /*****************************************************/
    return locB(obj);
}



/************************************************************************/
/*-    vm_Loc2 -- Return ram addresses for two Vm_Objs.			*/
/************************************************************************/

/* A simple convenience fn: */
void
vm_Loc2(
    void** result_0,
    void** result_1,
    Vm_Obj object_0,
    Vm_Obj object_1
) {
    if (object_0) {
	*result_0 = vm_Loc( object_0  );
        vm_Register_Hard_Pointer( &object_0, result_0 );
    }
    if (object_1) {
        *result_1 = vm_Loc( object_1 );
    }
    if (object_0)   vm_Unregister_Hard_Pointer(          result_0 );
}



/************************************************************************/
/*-    vm_Loc3 -- Return ram addresses for three Vm_Objs.		*/
/************************************************************************/

/* A simple convenience fn: */
void
vm_Loc3(
    void** result_0,
    void** result_1,
    void** result_2,
    Vm_Obj object_0,
    Vm_Obj object_1,
    Vm_Obj object_2
) {
    if (object_0) {
        *result_0 = vm_Loc( object_0  );
        vm_Register_Hard_Pointer( &object_0, result_0 );
    }
    if (object_1) {
        *result_1 = vm_Loc( object_1 );
        vm_Register_Hard_Pointer( &object_1, result_1 );
    }
    if (object_2) {
        *result_2 = vm_Loc( object_2 );
    }

    if (object_1)   vm_Unregister_Hard_Pointer(          result_1 );
    if (object_0)   vm_Unregister_Hard_Pointer(          result_0 );
}

/************************************************************************/
/*-    vm_Loc4 -- Return ram addresses for four Vm_Objs.		*/
/************************************************************************/

/* A simple convenience fn: */
void
vm_Loc4(
    void** result_0,
    void** result_1,
    void** result_2,
    void** result_3,
    Vm_Obj object_0,
    Vm_Obj object_1,
    Vm_Obj object_2,
    Vm_Obj object_3
) {
    if (object_0) {
        *result_0 = vm_Loc( object_0  );
        vm_Register_Hard_Pointer( &object_0, result_0 );
    }
    if (object_1) {
        *result_1 = vm_Loc( object_1 );
        vm_Register_Hard_Pointer( &object_1, result_1 );
    }
    if (object_2) {
        *result_2 = vm_Loc( object_2 );
        vm_Register_Hard_Pointer( &object_2, result_2 );
    }
    if (object_3) {
        *result_3 = vm_Loc( object_3 );
    }

    if (object_2)    vm_Unregister_Hard_Pointer(          result_2 );
    if (object_1)    vm_Unregister_Hard_Pointer(          result_1 );
    if (object_0)    vm_Unregister_Hard_Pointer(          result_0 );
}

/************************************************************************/
/*-    vm_Loc5 -- Return ram addresses for five Vm_Objs.		*/
/************************************************************************/

/* A simple convenience fn: */
void
vm_Loc5(
    void** result_0,
    void** result_1,
    void** result_2,
    void** result_3,
    void** result_4,
    Vm_Obj object_0,
    Vm_Obj object_1,
    Vm_Obj object_2,
    Vm_Obj object_3,
    Vm_Obj object_4
) {
    if (object_0) {
        *result_0 = vm_Loc( object_0  );
        vm_Register_Hard_Pointer( &object_0, result_0 );
    }
    if (object_1) {
        *result_1 = vm_Loc( object_1 );
        vm_Register_Hard_Pointer( &object_1, result_1 );
    }
    if (object_2) {
	*result_2 = vm_Loc( object_2 );
	vm_Register_Hard_Pointer( &object_2, result_2 );
    }
    if (object_3) {
        *result_3 = vm_Loc( object_3 );
	vm_Register_Hard_Pointer( &object_3, result_3 );
    }
    if (object_4) {
        *result_4 = vm_Loc( object_4 );
    }

    if (object_3)    vm_Unregister_Hard_Pointer(          result_3 );
    if (object_2)    vm_Unregister_Hard_Pointer(          result_2 );
    if (object_1)    vm_Unregister_Hard_Pointer(          result_1 );
    if (object_0)    vm_Unregister_Hard_Pointer(          result_0 );
}

/************************************************************************/
/*-    vm_Loc6 -- Return ram addresses for six Vm_Objs.			*/
/************************************************************************/

/* A simple convenience fn: */
void
vm_Loc6(
    void** result_0,
    void** result_1,
    void** result_2,
    void** result_3,
    void** result_4,
    void** result_5,
    Vm_Obj object_0,
    Vm_Obj object_1,
    Vm_Obj object_2,
    Vm_Obj object_3,
    Vm_Obj object_4,
    Vm_Obj object_5
) {
    if (object_0) {
        *result_0 = vm_Loc( object_0  );
        vm_Register_Hard_Pointer( &object_0, result_0 );
    }
    if (object_1) {
        *result_1 = vm_Loc( object_1 );
        vm_Register_Hard_Pointer( &object_1, result_1 );
    }
    if (object_2) {
	*result_2 = vm_Loc( object_2 );
	vm_Register_Hard_Pointer( &object_2, result_2 );
    }
    if (object_3) {
        *result_3 = vm_Loc( object_3 );
	vm_Register_Hard_Pointer( &object_3, result_3 );
    }
    if (object_4) {
	*result_4 = vm_Loc( object_4 );
	vm_Register_Hard_Pointer( &object_4, result_4 );
    }
    if (object_4) {
	*result_5 = vm_Loc( object_5 );
    }

    if (object_4)    vm_Unregister_Hard_Pointer(          result_4 );
    if (object_3)    vm_Unregister_Hard_Pointer(          result_3 );
    if (object_2)    vm_Unregister_Hard_Pointer(          result_2 );
    if (object_1)    vm_Unregister_Hard_Pointer(          result_1 );
    if (object_0)    vm_Unregister_Hard_Pointer(          result_0 );
}



/************************************************************************/
/*-    vm_Make_Db -- Create new database file.				*/
/************************************************************************/

Vm_Unt
vm_Make_Db(
    Vm_Unt dbId
){
    int swap;

    /* Trim given dbId down to available range: */
    dbId &= VM_DBFILE_MASK;

    /* Check open dbs: */
    {   Vm_Db db;
        for (db = vm_Root_Db;   db;   db = db->next) {
	    if (db->dbfile ==dbId)   return FALSE;
    }   }

    if (!dbId) {
        /* Root db is a special case: */
	Vm_Db db   = dbnew(dbId);	/* Make new Vm_A_Db. */

	/* Create empty db file: */
        dbindexClear( db );

	/* Load it into memory: */
        dbindexLoad(  db, ".muq", &swap );

	/* Set it to be compressed when it is closed */
	/* iff the root db is set to be compressed:  */
	db->wasCompressed =  vm_Root_Db->wasCompressed;

        return db->dbfile;

    } else {

        Vm_Db db   = dbnew(dbId);	/* Make new Vm_A_Db. */

        db->bytesInFile    =  0;	/* Should never be used. */
        db->fileDescriptor = -1;	/* Should never be used. */

        db->quartAllocSlots= 0;
        db->quartAlloc     = (Vm_Unt*) alloc( 0 );

	{   int octave;
	    for (octave = VM_FIRST_OCTAVE;   octave <= VM_FINAL_OCTAVE;   ++octave) {

		Octave   p = &db->o[ octave ];

		p->diskSlots      = 0;
		p->allocSlots     = 0;

		p->bytesPerSlot	  = vm_octave_capacity[ octave ];
		p->slotsPerQuart  = VM_QUART_BYTES / p->bytesPerSlot;
		p->quarts         = 0;

		{   int  i;
		    for (i = VM_BITMAPS;   i --> 0;   )    p->bitmap[i]    = NULL;
		    for (i = VM_BYTMAPS;   i --> 0;   )    p->bytmap[i]    = NULL;
		    p->size.b           = NULL;
		}

		p->quartOffset   = NULL;
		p->freeSlots     = 0;
		p->freeCacheLen  = 0;
	    }
	}

	/* Set it to be compressed when it is closed */
	/* iff the root db is set to be compressed:  */
	db->wasCompressed =  vm_Root_Db->wasCompressed;

        return db->dbfile;
    }
}

/************************************************************************/
/*-    vm_Export_Db -- Write db out as a separate file.			*/
/************************************************************************/

Vm_Uch*
vm_Export_Db(
    Vm_Unt dbId
){
    /* Trim given dbId down to available range: */
    dbId &= VM_DBFILE_MASK;

    if (!vm_Db_Is_Mounted( dbId ))   return "Db not in memory";

    /* Flush any bigbuf info to main disk store, */
    /* to ensure db is in a consistent state:    */
    bigbufClean();    
    
    {   /* Find our db record: */
        Vm_Db db = dbfindInRam( dbId );

        /* Open our output file: */
	int       fd;
        Vm_Uch    buf[ 256 ];
        strcpy( buf, dbpath1(db->dbfile,VM_PATH_CURRENT,".db") );

	fd = open( buf, O_WRONLY | O_CREAT, S_IREAD | S_IWRITE );

    	if (fd < 0)   return "Couldn't open file";

        /* Write contents of file, except for header and trailer: */
        lseek( fd, VM_QUART0_OFFSET, SEEK_SET );
        {   Vm_Int bytesInFile = dbquartsSave( db, fd );

	    /* Now write header and trailer: */
            dbindexSave( db, fd, "muq-db\n\0", bytesInFile );
	}

        close(fd);

	dbindexCompress(  db, VM_PATH_CURRENT, ".db" );
    }

    return NULL;
}

/************************************************************************/
/*-    vm_Import_Db -- Creat new db from existing database file.	*/
/************************************************************************/

Vm_Unt
vm_Import_Db(
    Vm_Unt dbId
){
    int swap;

    /* Trim given dbId down to available range: */
    dbId &= VM_DBFILE_MASK;

    if (!dbfileExists( dbId, ".db" )) {
        return (Vm_Unt)FALSE;
    }
    
    {   Vm_Db db   = dbnew(dbId);	/* Make new Vm_A_Db. */

	/* Make a RUNNING copy of the CURRENT */
	/* db and Load it into memory:        */
	dbDuplicate( db, ".db"        );
        dbindexLoad( db, ".db", &swap );

        lseek( db->fileDescriptor, VM_QUART0_OFFSET, SEEK_SET );
	dbquartsRead(db, db->fileDescriptor );

	vmclose( db->fileDescriptor );

	/* Remove the RUNNING copy: */
	db_nuke(     db, VM_PATH_RUNNING, ".db" );

        return db->dbfile;
    }
}

/************************************************************************/
/*-    vm_Remove_Db -- Remove an existing database.			*/
/************************************************************************/

Vm_Unt
vm_Remove_Db(
    Vm_Unt dbId
){
    /* Locate db in hashtable, and remove it: */
    Vm_Db* dbp = &dbtab[ VM_DBTAB_HASH(dbId) ];
    Vm_Db  db;
    if (!dbId) VM_WARN("May not remove root db");
    for   (db = *dbp;   ;   dbp = &db->hnext, db=*dbp) {
        if (!db)   return FALSE;
	if (db->dbfile == dbId) {
	    *dbp = db->hnext;
	    break;
	}
    }

    /* Locate db in master linklist, and remove it: */
    for (dbp = &vm_Root_Db;   ;   dbp = &(*dbp)->next) {
        if (!*dbp)   VM_FATAL("internal err");
	if ((*dbp)->next == db) {
	    (*dbp)->next  = db->next;
	    break;
	}
    }

    /* Mark all quarts used by db as free: */
    {   Vm_Int  octave;
        for (octave = VM_FIRST_OCTAVE;   octave < VM_FINAL_OCTAVE;   ++octave) {
            Vm_Int  slot;
            for (slot = 0;   slot < db->o[octave].quarts;   ++slot) {
		Vm_Int offset = db->o[octave].quartOffset[slot];
		Vm_Int quart  = (offset - VM_QUART0_OFFSET) >> VM_LOG2_QUART_BYTES;
                quartFree( quart );
	    }
	}

	/* Final octave is a special case, because */
	/* it can have multiple quarts per slot:   */
        {   Vm_Int  slot;
            for (slot = 0;   slot < db->o[VM_FINAL_OCTAVE].quarts;   ++slot) {
		/* How many quarts in this object? */
		Vm_Int size_in_bytes = db->o[VM_FINAL_OCTAVE].size.i[slot];
		Vm_Unt quartOffset   = db->o[VM_FINAL_OCTAVE].quartOffset[slot];
		Vm_Int quarts        = (size_in_bytes + (VM_QUART_BYTES-1)) >> VM_LOG2_QUART_BYTES;
		Vm_Unt quart         = (quartOffset   -  VM_QUART0_OFFSET ) >> VM_LOG2_QUART_BYTES;
		Vm_Int i;
		for   (i = 0;   i < quarts;   ++i) {
		    quartFree( quart + i );
		}
	    }
	}
    }

    /* Release db ram used for bitmaps and bytmaps &tc: */
    bitmapsNuke( db );

    /* Release ram for db record proper: */
    free( db );

    return TRUE;
}

/************************************************************************/
/*-    vm_Flush_Db_From_Cache -- Remove all objects in db from cache.	*/
/************************************************************************/

void
vm_Flush_Db_From_Cache(
    Vm_Unt dbId
){
    bigbufFlushDb( dbId );
}

/************************************************************************/
/*-    vm_Db_Is_Mounted -- Check to see if a db is mounted.		*/
/************************************************************************/

Vm_Unt
vm_Db_Is_Mounted(
    Vm_Unt dbId
){
    /* Trim given dbId down to available range: */
    dbId &= VM_DBFILE_MASK;

    return dbfindInRam(dbId) != NULL;
}

/************************************************************************/
/*-    vm_Db -- Check to see if a db is mounted.			*/
/************************************************************************/

Vm_Db				/* Should really try to get rid of this	*/
vm_Db(				/* function sometime, and not export	*/
    Vm_Unt dbId			/* Vm_Db outside of vm.t.		*/
){
    return dbfind(dbId);
}

/************************************************************************/
/*-    vm_Db_Exists -- Check to see if a db is on disk.			*/
/************************************************************************/

#ifdef CURRENTLY_UNUSED
Vm_Unt
vm_Db_Exists(
    Vm_Unt dbId
){
    /* Trim given dbId down to available range: */
    dbId &= VM_DBFILE_MASK;

    return !!dbfileExists( dbId, ".db" );
}
#endif

/************************************************************************/
/*-    vm_Malloc -- Create new virtual memory object.			*/
/************************************************************************/

int vm_Malloc_Calls = 0;

Vm_Obj
vm_Malloc(
    Vm_Unt len,
    Vm_Unt dbfile,
    Vm_Uch tags
) {

    Vm_Db db = dbfind(dbfile);

#ifdef OLD
    /* Icky special case for length-zero object: */
/* buggo, we gotta stop doing this, it means */
/* we lose the ability to resize the object  */
/* nonzero later while maintaining its       */
/* identity.  We may have to change the      */
/* size-field conventions in bigbuf and/or   */
/* the octave stuff to support zero lengths, */
/* however...?                               */
    if (!len) {
        return VM_LEN0_OBJ;
    }
#endif


    ++  db->s.object_creates;
    ++  db->s.object_creates_since_last_gc;

    /* When we are doing an incremental  */
    /* backup / garbage-collect, we do   */
    /* a few garbage collect steps for	 */
    /* every object created, to ensure	 */
    /* we stay ahead of the game:	 */
/*buggo -- let's phase out midprim gc operations, */
/* to simplify prim implementation. */
    #ifdef SOMEDAY
    if (gc_grey_stack_top) {
        Vm_Int  i;
        for (i = vm_Gc_Steps_Per_Malloc;   i --> 0;   ) {
            VM_FATAL("vm attempted internal backup!");
	    if (!vm_Backup_Continue())   break;
    }   }
    #endif

    {   /* Pick size: */
	register Vm_Unt octave;
	for (octave = VM_FIRST_OCTAVE; ; ++octave) {
	    if (vm_octave_capacity[octave] >= len)   break;
	    if (octave == VM_FINAL_OCTAVE) {
	        break;
	    }
	}

	{   /* Find and allocate fileslot to store object in: */
	    Vm_Unt offset   = bitmapNew( db, octave, len );

	    /* Construct a new memory object to hold object:  */
	    Vm_Unt uniqu    = (db->s.next_unique_to_issue++ & VM_UNIQUE_MASK);
	    Block    p      = bigbufNew(octave,offset,uniqu,len,db->dbfile );

            vm_Total_Bytes_Allocated_Since_Last_Garbage_Collection += len;

	    initialize_object_bitfields_and_bytefields( db, octave, offset, len, uniqu, tags );

	    {   A_Ex e;
		objExplode( &e, p->o );
	        {   Vm_Int   sz     = physicalSize( db, &e );

		    db->s.bytes_in_useful_data	 += len;
		    db->s.bytes_allocated_since_last_garbage_collection += len;
		    db->s.bytes_lost_in_used_blocks += sz - len;
		    db->s.bytes_in_free_blocks	 -= sz;
	    }	}

	    /* Return new Vm_Obj: */
	    return   (p->o 
            &        ((Vm_Unt)~0   <<   VM_TAGBITS))
            |        tags
            ;
    }	}
}



/************************************************************************/
/*-    vm_Next  -- Return next object after 'o', else FALSE.		*/
/************************************************************************/

/*******************************************************/
/* At the moment, the only use of this fn outside vm.t */
/* is in two spots in the obj.t garbage collector:     */
/* o One zeroing the userbits of all objects in the db */
/* o One recycling all db objects with zero userbits.  */
/*******************************************************/

Vm_Obj
vm_Next(
    Vm_Obj o,
    Vm_Db  db
) {
    return bitmapNext( db, o );
}



/************************************************************************/
/*-    vm_Print_State -- Summarize in-ram state.			*/
/************************************************************************/

void
vm_Print_State(
    FILE* f,
    Vm_Uch* title
) {
#if VM_DEBUG
    fprintf(f,"\n\n===========================================\n%s:\n",title);
    fprintf(f," bigbuf size x=%08" VM_X "\n", (Vm_Unt)((Vm_Uch*)bigbufEnd  - (Vm_Uch*)bigbufBeg  ));
    fprintf(f," bigbuf used x=%08" VM_X "\n", (Vm_Unt)((Vm_Uch*)bigbuffree - (Vm_Uch*)bigbufBeg  ));
    fprintf(f," bigbuf free x=%08" VM_X "\n", (Vm_Unt)((Vm_Uch*)bigbufEnd  - (Vm_Uch*)bigbuffree ));
    fprintf(f," hashtab siz x=%08" VM_X "\n", VM_HASHTAB_SIZE );
    fprintf(f," bigbuf                x=%p\n", bigbufBeg	     );
    fprintf(f," bigbufFirst()         x=%p\n", bigbufFirst()	     );
    fprintf(f," bigbufFirstMaybeDead  x=%p\n", bigbufFirstMaybeDead);
    fprintf(f," bigbuffree            x=%p\n", bigbuffree          );
    fprintf(f," bigbufEnd             x=%p\n", bigbufEnd           );
    hshtabPrint(f);
    bigbufPrint(f);
    bitmapsPrint(f,vm_This_Db);
    fprintf(f,"\n");
#endif
}



/************************************************************************/
/*-    vm_Realloc -- Do SizedDup plus recycle 'old'.			*/
/************************************************************************/

Vm_Obj
vm_Realloc(
    Vm_Obj   old,
    Vm_Unt newlen
) {
    Vm_Obj   new = vm_SizedDup( old, newlen, VM_DBFILE(old) );
    vm_Free( old );
    return   new  ;
}



/************************************************************************/
/*-    vm_Register_Hard_Pointer -- Note a hard ptr locking obj in ram.	*/
/************************************************************************/

/************************************************************************/
/* This call implements a facility whereby a user may notify us		*/
/* of a hard pointer to an object in bigbuf.  While this pointer	*/
/* remains registered, we must not swap the object to disk, and		*/
/* if we move the object, we must update the hard pointer.		*/
/*									*/
/* This facility is included with some reluctance, since I suspect	*/
/* it will be abused more often than it is used sensibly -- clueless	*/
/* folks will likely lock everything they use often into ram "for	*/
/* speed", wrecking the virtual memory performance by forcing		*/
/* everything else to swap madly.  Used judiciously, however, this	*/
/* facility can be a significant win on occasion.  It is included	*/
/* primarily to allow locking the currently executing process and	*/
/* code segment, to save the interpreter from calling vm_Loc() on	*/
/* every instruction.  (I would consider locking every process, or	*/
/* even every code segment in the current process, abuse of this	*/
/* facility, and suggest anyone contemplating doing such think		*/
/* very carefully about it, and verify that overall system performance	*/
/* improves as substantially as they thought it would.)			*/
/*									*/
/* Note that vm_Loc is rather fast, and that trying to outguess virtual	*/
/* memory managers has a long history of backfiring more often than	*/
/* not, so you really need to have a rather exceptional situation	*/
/* before locking an object wins over calling vm_Loc.  Enough warning,	*/
/* here's more than enough rope to hang yourself with:			*/
/************************************************************************/

void
vm_Register_Hard_Pointer(
    Vm_Obj*o,
    void** p
) {
    /************************************************************/
    /* *'o' will be locked in ram, and *p will be updated	*/
    /* when/if object o is moved in ram.			*/
    /* Making 'o' Vm_Obj* instead of Vm_Obj is an efficiency	*/
    /* hack: the caller can attach *p to another object without */
    /* making an explicit call to us, simply by updating *o.    */
    /* Muq uses this to shave some cycles off call/ret		*/
    /* bytecodes, when the program counter switches allegiance  */
    /* to another cfn object.  (vm_Register_Hard_Pointer	*/
    /* is primarily designed to speed interpreter bytecode	*/
    /* fetches.)						*/
    /************************************************************/

    if (bigbufHardPointerCount == VM_MAX_HARD_POINTERS) {
	VM_FATAL ("vm_Register_Hard_Pointer: too many pointers.");
    }
    if (*o) vm_Loc(*o);	/* Force object to swap in if out. */
    bigbufHardPointers[ bigbufHardPointerCount ].p = p;
    bigbufHardPointers[ bigbufHardPointerCount ].o = o;
    ++                  bigbufHardPointerCount;
}



/************************************************************************/
/*-    vm_Resize_Bigbuf -- Get/Set size-in-bytes of bigbuf.		*/
/************************************************************************/

Vm_Unt
vm_Resize_Bigbuf(
    Vm_Unt requested_size
) {
    /* Actually resize only if requested_size is nonzero: */
    if (requested_size) {
	if (requested_size < VM_BIGBUF_MIN) {
	    requested_size = VM_BIGBUF_MIN;
	}
	if (requested_size > VM_BIGBUF_MAX) {
	    requested_size = VM_BIGBUF_MAX;
	}
	if (requested_size <  (Vm_Uch*)bigbuffree - (Vm_Uch*)bigbufBeg) {
	    bigbufClean();
	    bigbufCompact();
	    if (requested_size <  (Vm_Uch*)bigbuffree - (Vm_Uch*)bigbufBeg) {
	        requested_size =  (Vm_Uch*)bigbuffree - (Vm_Uch*)bigbufBeg;
	}   }

        bigbufResize( requested_size );
    }

    /* Return new size of buffer: */
    return (Vm_Unt) ( (Vm_Uch*)bigbufEnd - (Vm_Uch*)bigbufBeg );
}

/************************************************************************/
/*-    vm_Reverse16 -- byte-reverse a 16-bit value.			*/
/************************************************************************/

Vm_Unt16
vm_Reverse16(
    Vm_Unt16 u
) {
    return (u << 8) | (u >> 8);
}

/************************************************************************/
/*-    vm_Reverse32 -- byte-reverse a 32-bit value.			*/
/************************************************************************/

Vm_Unt32
vm_Reverse32(
    Vm_Unt32 u
) {
    return ((u << 24) & (Vm_Unt32)0xFF000000)
    |      ((u <<  8) & (Vm_Unt32)0x00FF0000)
    |      ((u >>  8) & (Vm_Unt32)0x0000FF00)
    |      ((u >> 24) & (Vm_Unt32)0x000000FF)
    ;
}

/************************************************************************/
/*-    vm_Reverse64 -- byte-reverse a 64-bit value.			*/
/************************************************************************/

Vm_Unt
vm_Reverse64(
    Vm_Unt u
) {
    /* Obviously, we could be cleverer here, and */
    /* perhaps should be should this ever become */
    /* a speed issue:                            */
    return ((u << 56) & (Vm_Unt)0xFF00000000000000)
    |      ((u << 40) & (Vm_Unt)0x00FF000000000000)
    |      ((u << 24) & (Vm_Unt)0x0000FF0000000000)
    |      ((u <<  8) & (Vm_Unt)0x000000FF00000000)
    |      ((u >>  8) & (Vm_Unt)0x00000000FF000000)
    |      ((u >> 24) & (Vm_Unt)0x0000000000FF0000)
    |      ((u >> 40) & (Vm_Unt)0x000000000000FF00)
    |      ((u >> 56) & (Vm_Unt)0x00000000000000FF)
    ;
}



/************************************************************************/
/*-    vm_SizedDup -- Copy 'old' to 'newlen' object, return new Vm_Obj.	*/
/************************************************************************/

Vm_Obj
vm_SizedDup(
    Vm_Obj   old,
    Vm_Unt newlen,
    Vm_Unt dbfile
) {
    /* Allocate a new object: */
    Vm_Obj new = vm_Malloc(   newlen,   dbfile,   (old & VM_TAGBITS_MASK)   );

    /* Get size of old object: */
    Vm_Unt oldlen = vm_Len( old );

    /* Figure number of bytes to copy: */
    Vm_Unt bytesToCopy = oldlen < newlen  ?  oldlen  :  newlen;

    /* Round up to even number of words to copy: */
    Vm_Unt wordsToCopy =  bytesToCopy >> VM_LOG2_INTBYTES;

    /* Get locations of old and new objects: */
    Vm_Uch* oldloc;
    Vm_Uch* newloc;
    vm_Loc2( (void**)&oldloc, (void**)&newloc, old, new );

    /* Do the copy: */
    copy( (Vm_Int*)newloc, (Vm_Int*)oldloc, wordsToCopy );

    return   new  ;
}



/************************************************************************/
/*-    vm_Unregister_Hard_Pointer -- Forget pointer was registered.	*/
/************************************************************************/

void
vm_Unregister_Hard_Pointer(
    void** p
) {
    /* Delete 'p' from our set of registered hard pointers,	*/
    /* filling its slot in our vector with the contents		*/
    /* of the last slot to keep everything contiguous:		*/
    Vm_Int    i = bigbufHardPointerCount;
    while (i --> 0) {
	if (bigbufHardPointers[ i ].p == p) {
	    bigbufHardPointers[ i ] = (
		bigbufHardPointers[ --bigbufHardPointerCount ]
	    );
	    return;
    }   }

    VM_FATAL ("vm_Unregister_Hard_Pointer: Not found.");
}

/************************************************************************/
/*-    vm_Db_Is_Pinned_In_Ram -- Check for registered pointers in db.	*/
/************************************************************************/

int
vm_Db_Is_Pinned_In_Ram(
    Vm_Int dbId
) {
    Vm_Int i;
    for (i = 0;    i < bigbufHardPointerCount;   ++i) {    
	if (VM_DBFILE(*bigbufHardPointers[i].o) == dbId)   return TRUE;
    }
    return FALSE;
}



/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    alloc -- malloc() call plus error handling.			*/
/************************************************************************/

static void*
alloc(
    Vm_Int bytecount
) {
    void*  result = malloc( bytecount );
    if   (!result)   VM_FATAL ("OUT OF RAM\n");
    return result;
}



/************************************************************************/
/*-    bigbufAlloc -- Return pointer to 'len' bytes of new bigbuf ram.	*/
/************************************************************************/

static Block
bigbufAlloc(
    Vm_Unt len  /* Caller guarantees this is a multiple of VM_INTBYTES. */
) {
    /* If there's insufficient space in bigbuf, create some: */
    bigbufMakeSpace( len );

    /* There's now sufficient space left in bigbuf, take some: */
    {   Block  result = bigbuffree;
	bigbuffree    = (Block) (((Vm_Uch*)bigbuffree) + len);
	return result;
    }
}



/************************************************************************/
/*-    bigbufClean -- Write all dirty objects to disk.			*/
/************************************************************************/

/* Following hack to write dirty blocks in  */
/* sorted rather than random order seems to */
/* be maybe 2x faster than random order but */
/* still 10x slower than a sequential file  */
/* write.  Should rewrite to save working   */
/* set in a sequential file, I think but    */
/* that can wait until post-beta...         */
#define BBC_MAX_CACHE 4096
struct bbcRec {
    int   offset;
    Block p;
};
struct bbcCache {
    struct bbcRec slot[ BBC_MAX_CACHE ];
    int firstFree;
};
typedef struct bbcCache *bbc;
static void
bbcCacheReset(
    bbc b
) {
    b->firstFree = 0;
}
static void
bbcCacheInsert(
    bbc b,
    struct bbcRec* c
) {
    struct bbcRec tmp;
    int  i;
    /* This is an insertion sort -- i.e., O(N^2)  */
    /* Switching to (say) HeapSort could speed it */
    /* up a lot, but disk I/O time still seems to */
    /* match or exceed the sort time. Writing our */
    /* workset to a separate sequential file (and */
    /* thus incidentally avoiding the sort) is    */
    /* probably a better way to speed this up     */
    /* than adding a sort: strictly sequential    */
    /* file writes seem to be 10x faster than     */
    /* our current heavily lseek() laden writes.  */
    for (i = 0;    i < BBC_MAX_CACHE;   ++i) {
        if (i == b->firstFree) {
	    b->slot[i] = *c;
	    b->firstFree++;
	    return;
	}
	if (c->offset < b->slot[i].offset) {
	    tmp        = b->slot[i];
	    b->slot[i] = *c;
	    *c         = tmp;
	}
    }
}

static void
bbcOctave(
    Vm_Db db,
    int   oct
) {
    struct bbcCache b;
    struct bbcRec   c;
    Block p;
    int   count = 0;
    for (;;) {
        bbcCacheReset( &b );
	for (
	    p = bigbufFirst();
	    p < bigbuffree   ;
	    p = bigbufNext(p)
	) {
	    A_Ex e;
	    if (p->o & VM_DIRTYBIT) {
		objExplode( &e, p->o );
		if (e.octave == oct
                &&  e.dbfile == db->dbfile
                ){
		    c.offset = e.offset;
		    c.p      = p;
		    bbcCacheInsert( &b, &c );
		}
	    }
	}
	count += b.firstFree;
	if (b.firstFree == 0)   return;
	{   int  i;
	    for (i = 0;   i < b.firstFree;   ++i) {
		dbfileSet( db, b.slot[i].p );
	    }
	}
	if (b.firstFree < BBC_MAX_CACHE)   return;
    }
}

static void
bigbufClean(
    void
) {

#ifdef OLD
    /* This code is (was?) correct but a bit slow: */
    Block p;
    for (
	p = bigbufFirst();
        p < bigbuffree  ;
	p = bigbufNext(p)
    ) {
	dbfileSet( vm_This_Db, p );
    }
#else
    Vm_Db db;
    for (db = vm_Root_Db;   db;   db = db->next) {
	int oct;
	for(oct  = VM_FIRST_OCTAVE;
	    oct <= VM_FINAL_OCTAVE;
	    oct++
	) {
	    bbcOctave( db, oct );
	}
    }
#endif
}



/************************************************************************/
/*-    bigbufCompact -- Move all free space zerofarward of bigbuffree.	*/
/************************************************************************/

static void
bigbufCompact(
    void
) {

    /* The first object copied needs special treatment: */
    Vm_Int first_copy = TRUE;

    /* 'rat' ranges over bigbufBlocks in bigbuf, while */
    /* 'cat' trails, the point we copy live blocks to: */
    Block cat = bigbufFirstMaybeDead;
    Block rat;
    Block nxt;

    saveHardPointerOffsets();

    for (rat = cat;   rat < bigbuffree;   rat = nxt) {

	/* Remember location of start of next block,	*/
	/* since sliding current block back may		*/
	/* obliterate the startOfBlock info this	*/
	/* depends on:					*/
	nxt     = bigbufNext(rat);

	/* If *rat is live, feed it to cat, advancing	*/
	/* both, else just advance rat:			*/
	if (VM_IS_LIVE(rat)) {
	    /* *rat is live;     */
	    /* Feed *rat to cat: */

	    /* Figure out size-in-bytes of object: */
	    Vm_Unt exact_size = len( rat ) + sizeof( A_Block );

	    /* Round exact_size up to integral number of words: */
	    Vm_Unt rounded_up_size  = (
		exact_size + (VM_INTBYTES-1)  &  ~(VM_INTBYTES-1)
	    );

	    /* Figure basic number of words to copy: */
	    Vm_Unt words =  rounded_up_size >> VM_LOG2_INTBYTES;

	    /* Another odd special case due to our optional */
	    /* length word:  If 1st overwritten block has a */
	    /* length word, we need to bump cat back a word */
	    /* to recover the length word:                  */
	    if (first_copy) {
		first_copy = FALSE;
		if (VM_IS_BIG_OCTAVE(cat->o)) {
		    cat = (Block) ((Vm_Unt*)cat -1);
	    }   }

	    if (!VM_IS_BIG_OCTAVE(rat->o)) {

		/* Any hashtable pointer pointing to 'rat' */
		/* needs to be updated to point to 'cat':  */
		hshtabNoteMotion( cat, rat );

		/* No extra length word to worry about: */
		copy(
		    (Vm_Int*)cat   ,
		    (Vm_Int*)rat   ,
		    words
		);
		cat = (Block) ((Vm_Int*)cat + words);

	    } else {

		/* Any hashtable pointer pointing to 'rat'  */
		/* needs to be updated to point to 'cat'+1: */
		hshtabNoteMotion( (Block)((Vm_Int*)cat +1), rat );

		/* Take extra prepended length word into account: */
		copy(
		    (Vm_Int*)cat   ,
		    (Vm_Int*)rat -1,
		    words     +1
		);
		cat = (Block) (((Vm_Int*)cat) + words +1 );
    }   }   }

    /* Same special case decribed with 'first_copy' use above, */
    /* combined with special case of no live blocks in buffer: */

    if (first_copy		/* If we haven't copied a block yet...   */
    &&  cat < bigbuffree        /* and if cat points to a valid block... */
    &&  VM_IS_BIG_OCTAVE(cat->o)/* and if block is preceded by length wd */
    ){
	/* Then we need to slide back cat one word */
        /* to recover space used by length word:   */
	cat = (Block) ((Vm_Unt*)cat -1);
    }

    /* Restore various invariants: */
    bigbuffree           = cat;
    bigbufFirstMaybeDead = cat;
    bigbufDeadBytes      = 0;
    updateHardPointers();
}



/************************************************************************/
/*-    bigbufFirst -- First interesting object in bigbuf.		*/
/************************************************************************/

static Block
bigbufFirst(
    void
) {

    /* Need to skip first word, which is permanently unused  */
    /* so that offset zero in bigbuf can mean DEAD in 'next' */
    /* fields, and also the next two words, which are our    */
    /* nullBlock, terminating all hashtable chains:          */
    Block result = (Block) (
	(Vm_Uch*)bigbufBeg + VM_INTBYTES + sizeof(A_Block)
    );

    /* If low bit of result is 0, first object has an extra  */
    /* length word preceding it, which we need to step over. */
    /* End-of-buffer poses a special case, however:	     */
    if (result < bigbuffree) {
        if (!(result->o & VM_HEADER)) {
	    result = (Block) ((Vm_Unt*)result +1);
    }	}

    return result;
}



/************************************************************************/
/*-    bigbufFlushDb -- 						*/
/************************************************************************/

static void
bigbufFlushDb(
    Vm_Int dbId
) {
    /* We presume called has called vm_Db_Is_Pinned_In_Ram()   */
    /* to verify that we have no hard pointers to worry about. */

    /* 'cat' ranges over bigbufBlocks in bigbuf */
    Block cat = bigbufFirstMaybeDead;
    Block nxt;
    for (;   cat < bigbuffree;   cat = nxt) {

        /* Preserve info clobbed by bigbufFree(): */
	nxt     = bigbufNext(cat);

	if (VM_IS_LIVE(cat)) {
	    if (VM_DBFILE(cat->o) == dbId) bigbufFree(cat);
        }
    }
}



/************************************************************************/
/*-    bigbufFree -- Mark ramobject as dead, delete from hashtab.	*/
/************************************************************************/

static void
bigbufFree(
    Block p
) {
    /* Add object's size to count of dead bytes: */

    /* Find next block: */
    Block  q = (Block) bigbufNext(p);

    /* Figure bytes separating us from next block: */
    Vm_Int b = (Vm_Uch*)q - (Vm_Uch*)p;

    /* Add any extra length word on p: */
    if (                  VM_IS_BIG_OCTAVE(p->o))   b += VM_INTBYTES;

    /* Sub any extra length word on q: */
    if (q < bigbuffree && VM_IS_BIG_OCTAVE(q->o))   b -= VM_INTBYTES;

    bigbufDeadBytes += b;


    /* Delete p from hashtable: */
    hshtabFree( p );

    /* Mark block as free by clearing NEXT field. */
    /* Note that we must preserve the size info:  */
    p->next &= VM_SMALLSIZE_MASK;

    /* Don't want DIRTY bit set on dead objects,  */
    /* some routine will try to swap to disk :)   */
    p->o    &= ~VM_DIRTYBIT;

    /* Maybe update bigbufFirstMaybeDead: */
    if (bigbufFirstMaybeDead > p) {
        bigbufFirstMaybeDead = p;
    }
}

/************************************************************************/
/*-    bigbufInit -- Establish bigbuf and hashtab invariants.		*/
/************************************************************************/

static void
bigbufInit(
    void
) {
    Vm_Unt bigbufSize;

    bigbufSize  = powerOfTwoCeiling( vm_Initial_Bigbuf_Size );
    bigbufBeg   = alloc( bigbufSize );
    bigbufEnd   = (Block) ((Vm_Uch*)bigbufBeg + bigbufSize);

    bigbufDeadBytes	    = 0;
    bigbufHardPointerCount  = 0;



    /* Establish our hashtable invariants: */

    /* Allocate and initialize bigbufNullBlock.			*/
    /* Skip the first word in bigbuf (so that next=0 can	*/
    /* be our DEAD flag) and put nullBlock next in bigbuf,	*/
    /* so we can address it with bigbuf-relative offset.	*/
    {   Block bigbufNullBlock 	    = (Block) ((Vm_Int*)bigbufBeg + 1);
	/* Note next two set size==0, type to BIG_OCTAVE. */
        /* We take advantage of that for LEN0 object:     */
        bigbufNullBlock[ 0].o	    = VM_LEN0_OBJ | VM_HEADER;
        bigbufNullBlock[ 0].next    = 0;
        bigbufNullBlock[-1].next    = 0;

	bigbuffree		    = bigbufNullBlock +1;
	bigbufFirstMaybeDead	    = bigbuffree;

	/* Initialize bigbufHashtab proper: */
	{   Vm_Int  i;
	    for (i = VM_HASHTAB_SIZE;   i --> 0; ) {
		bigbufHashtab[i] = bigbufNullBlock;
}   }   }   }



/************************************************************************/
/*-    bigbufInvariants -- Sanitycheck bigbuf.				*/
/************************************************************************/

/* #if VM_DEBUG */

/************************************************************************/
/*-    mustBeIntAligned -- Check that given pointer is int aligned.	*/
/************************************************************************/

static Vm_Unt mustBeIntAligned(
    FILE* f,
    Vm_Uch* t,
    Block p
) {
    if ( ((Vm_Uch*)p - (Vm_Uch*)bigbufBeg)   &   (VM_INTBYTES-1) ) {
	err(f,t,"Pointer %p isn't int-aligned\n",p);
	return 1;
    }
    return 0;
}



static int
bigbufInvariants(
    FILE* f,
    Vm_Uch* t,
    int     count
) {
    Vm_Unt errsfound = 0;

    /********************************************************************/
    /* INVARIANT:							*/
    /* bigbufBeg points to bigbuf, a malloc()ed buffer in the  	       	*/
    /* megabyte size range, used to hold our in-memory objects.	       	*/
    /********************************************************************/
    if (!bigbufBeg) {
	++errsfound;
	err(f,t,"bigbufBeg is NULL\n");
    }

    /********************************************************************/
    /* INVARIANT:							*/
    /* bigbufEnd points to first byte past end of bigbuf. 	       	*/
    /********************************************************************/
    if (bigbufEnd < bigbufBeg) {
	++errsfound;
	err(f,t,"bigbufEnd < bigbufBed\n");
    }

    /********************************************************************/
    /* INVARIANT:							*/
    /* Bigbuffree points into bigbuf.					*/
    /********************************************************************/
    if (bigbuffree < bigbufBeg
    ||  bigbuffree > bigbufEnd
    ) {
	++errsfound;
	err(f,t,"bigbuffree not in bigbuf\n");
    }

    /********************************************************************/
    /* INVARIANT:							*/
    /* Bigbuffree points into bigbuf.					*/
    /********************************************************************/

    /********************************************************************/
    /* INVARIANT:							*/
    /* Bigbuffree and bigbufEnd are both int-aligned.			*/
    /********************************************************************/
    errsfound += mustBeIntAligned(f,t,  bigbuffree );
    errsfound += mustBeIntAligned(f,t,  bigbufEnd  );

    /********************************************************************/
    /* INVARIANT:							*/
    /* Everything from bigbufBeg to bigbuffree consists of valid	*/
    /* bigbufBlocks, aligned on sizeof(Vm_Int)-byte boundaries,		*/
    /* excepting that the first word in bigbuf is unused (so that	*/
    /* offset 0 in bigbuf can be used as a DEAD flag in bigbufBlocks)	*/
    /* and that the second and third words in bigbuf form nullBlock,    */
    /* a dummy bigbufBlock which ends all hashchains.			*/
    /********************************************************************/
    {   Block p;
	for (
	    p = bigbufFirst();
	    p < bigbuffree;
	    p = bigbufNext(p)
	) {
	    errsfound += mustBeIntAligned(f,t, p );

	    if (!(VM_HEADER & p->o)) {
		++errsfound;
		err(f,t,
		    "Invalid block in bigbuf p p=%p p->o x=%" VM_X "\n",
		    p, p->o
		);
	}   }
	if (p != bigbuffree) {
	    ++errsfound;
	    err(f,t,
		"Last block bigbuf end p=%p instead of p=%p\n",
		p, bigbuffree
	    );
    }	}

    /********************************************************************/
    /* INVARIANT:							*/
    /* All ram from bigbuffree to bigbufEnd is free for allocation --	*/
    /*  we allocate new ram simply by advancing this pointer. 	       	*/
    /********************************************************************/
    /* No obvious and efficient way to check that ram in here isn't	*/
    /* being used...							*/

    /********************************************************************/
    /* INVARIANT:							*/
    /* Dead bigbufBlocks between bigbufBeg and bigbuffree have        	*/
    /* block->next set to zero, and are not reachable from		*/
    /* bigbufHashtab.							*/
    /********************************************************************/
    /* Any blocks reachable from bigbufHashtab with ->next set to zero	*/
    /* will trigger an error in hshtabInvariants().  Not clear what	*/
    /* else to test here.						*/

    /********************************************************************/
    /* INVARIANT:							*/
    /* Live bigbufBlocks have block->next nonNULL and are reachable	*/
    /* from bigbufHashtab by following 'next' pointers.	       	       	*/
    /********************************************************************/
    /* We test this by looking up the location of every live		*/
    /* block in the hashtable:						*/
    {   Block p;
	for (
	    p = bigbufFirst();
	    p < bigbuffree;
	    p = bigbufNext(p)
	) {
	    if (VM_IS_LIVE(p)				/* liveness  test*/
	    &&  vm_Is_In_Ram( p->o ) != (void*)(p+1)	/* reachable test*/
	    ){
		++errsfound;
		err(f,t,
		    "Live block p p=%p p->o x=%" VM_X " not in hshtab exactly once\n",
		    p, p->o
		);
    }	}   }

    /********************************************************************/
    /* INVARIANT:							*/
    /* nullblock+1 <= bigbufFirstMaybeDead <= bigbuffree.		*/
    /********************************************************************/
    if (bigbufFirstMaybeDead < bigbufFirst()
    ||  bigbufFirstMaybeDead > bigbuffree
    ) {
	++errsfound;
	err(f,t,"Need bigbufFirst <= bigbufFirstMaybeDead <= bigbuffree\n");
    }


    /********************************************************************/
    /* INVARIANT:							*/
    /* There are no dead bigbufBlocks between bigbufBeg and    	       	*/
    /* bigbufFirstMaybeDead.  There may or may not be dead bigbufBlocks	*/
    /* between bigbufFirstMaybeDead and bigbuffree.    	       	       	*/
    /********************************************************************/
    {   Block p;
	for (
	    p = bigbufFirst();
	    p < bigbufFirstMaybeDead;
	    p = bigbufNext(p)
	) {
	    if (!VM_IS_LIVE(p)) {
		++errsfound;
		err(f,t,
		    "bigbufFirstMaybeDead (%p) follows dead block %p\n",
		    bigbufFirstMaybeDead, p
		);
	}   }
	if (p != bigbufFirstMaybeDead) {
	    ++errsfound;
	    err(f,t,
		"bigbufFirstMaybeDead (%p) isn't a valid block\n",
		bigbufFirstMaybeDead
	    );
    }	}

    /********************************************************************/
    /* INVARIANT:							*/
    /* For all live blocks b from bigbufBeg to bigbuffree,	       	*/
    /* b->o&VM_DIRTYBIT is TRUE iff the block value is out of sync	*/
    /* with its image on disk. 	      	      	       	       	       	*/
    /********************************************************************/
    /* *blush*.  I don't check this, partly out of pure laziness,	*/
    /* partly to speed up sanity checking, which makes it a more	*/
    /* useful debugging tool...						*/

    /********************************************************************/
    /* INVARIANT:							*/
    /* bigbufDeadBytes is the total number of bytes lost to dead blocks */
    /* between bigbufBeg and bigbuffree.       	       	       	       	*/
    /********************************************************************/
    {   Block p;
	Vm_Unt deadBytes = 0;

	/* Over all valid blocks: */
	for (
	    p = bigbufFirst();
	    p < bigbufFirstMaybeDead;
	    p = bigbufNext(p)
	) {

	    /* If block is dead: */
	    if (!VM_IS_LIVE(p)) {

		/* Add objects size to count of dead bytes: */
		deadBytes	+= (

		    /* Length of object proper... */
		    ((Vm_Uch*)bigbufNext(p) - (Vm_Uch*)p)    +

		    /* ... plus any extra length word: */
		    (VM_IS_BIG_OCTAVE(p->o) ? VM_INTBYTES : 0)
		);

		if (bigbufDeadBytes != deadBytes) {
		    ++errsfound;
		    err(f,t,
		        "bigbufDeadBytes is (%p) not %p\n",
			bigbufDeadBytes, deadBytes
		    );
    }	}   }   }

    /********************************************************************/
    /* INVARIANT:							*/
    /* The first bigbufHardPointerCount pointers in bigbufHardPointers 	*/
    /* point to hard pointers the user has to objects in bigbuf.  We   	*/
    /* may not swap these objects to disk, and must update these	*/
    /* pointers when we move objects around.  	       	       	       	*/
    /********************************************************************/
    /* Check that table hasn't overflowed: */
    if (bigbufHardPointerCount > VM_MAX_HARD_POINTERS) {
	++errsfound;
	err(f,t,
	    "bigbufHardPointerCount (%" VM_X ") > VM_MAX_HARD_POINTERS (%" VM_X ")\n",
	    bigbufHardPointerCount,        VM_MAX_HARD_POINTERS
	);
    }
    /* For all registered pointers: */
    {   Vm_Unt u;
	for     (u = bigbufHardPointerCount;   u --> 0;  ) {
	    Vm_Obj o =*bigbufHardPointers[ u ].o;
	    /* NULL means ignore this one: */
	    if (o) {
		Block  p = (Block) vm_Loc(o);

		/* Check that object is live: */
		if (!VM_IS_LIVE(p-1)) {
		    ++errsfound;
		    err(f,t,"bigbufHardPointers[%d].p points to dead block\n",(int)u);
		}

		/* Check that object id matches that in table: */
		if (p[-1].o >> VM_HASHTAB_SHIFT   !=   o >> VM_HASHTAB_SHIFT) {
		    ++errsfound;
		    err(f,t,"*bigbufHardPointers[%d].o (%" VM_X ") != *.p->o (%" VM_X ")\n",
			(int)u, o, p[-1].o
		    );
    }	}   }   }

    return errsfound;
}
/* #endif */



/************************************************************************/
/*-    bigbufMakeSpace -- Page objects to disk to free up memory.	*/
/************************************************************************/

static void bigbufMakeSpace(
    Vm_Unt min_needed
) {
    /* If enough space exists already, do nothing: */
    Vm_Unt free_bytes = (Vm_Uch*)bigbufEnd - (Vm_Uch*)bigbuffree;
    Vm_Unt minToFree = (Vm_Unt) (
	VM_MINFREE_AFTER_COMPACTION
	*
	(float) ((Vm_Uch*)bigbufEnd - (Vm_Uch*)bigbufBeg)
    );
    if (free_bytes     >=   min_needed)    return;

    /************************************************************/
    /* Swap objects until half of bigbuf is freestuff, or	*/
    /* until we run out of things to kill.  The latter case	*/
    /* may happen if big objects have been locked in ram, in	*/
    /* which case it is time to expand bigbuf -- or shoot the	*/
    /* idiot locking things.  Not that we kill oldest objects	*/
    /* first, which may gives us a minor LRU sort of effect,    */
    /* in that objects which swap out and are needed, won't     */
    /* be swapped out again for awhile.  If they sit in the     */
    /* unix file cache until we swap them back in (not          */
    /* unlikely) this may even be reasonably efficient:         */
    /************************************************************/
    {   Block p = bigbufFirst();
	while (
	    p < bigbuffree   &&
   	    bigbufDeadBytes + free_bytes   <   minToFree
	) {
	    bigbufSwapObjOut( p );
	    p = bigbufNext(   p );
	}
    }

    /* Expand bigbuf if still not enough space: */
    if (bigbufDeadBytes + free_bytes < minToFree
    ||  bigbufDeadBytes + free_bytes < min_needed
    ){
        Vm_Unt current_size = (Vm_Uch*)bigbufEnd - (Vm_Uch*)bigbufBeg;
        Vm_Unt doubled_size = current_size  << 1;

	bigbufResize( doubled_size );

	/* Call recursively in case doubling wasn't enough (!): */
	bigbufMakeSpace( min_needed );
	return;
    }

    /* Compact, yielding enough space: */
    #if !MUQ_IS_PARANOID
    bigbufCompact();
    #else
    /* There's a fair amount of dead reckoning involved in */
    /* tracking dead bytes, doesn't hurt to check it:      */
    {   Vm_Unt expected_free_bytes = bigbufDeadBytes + free_bytes;
        bigbufCompact();
        free_bytes = (Vm_Unt)((Vm_Uch*)bigbufEnd - (Vm_Uch*)bigbuffree);
        if (expected_free_bytes != free_bytes) {
	    VM_FATAL ("bigbufMakeSpace: internal err");
    }   }
    #endif
}



/************************************************************************/
/*-    bigbufNew -- Build a new bigbufBlock for 'o'.			*/
/************************************************************************/

/* We allocate sufficient bigbuf space to hold 'o', */
/* construct a bigbufBlock and enter it into        */
/* bigbufHashtab, and return a pointer to the new   */
/* bigbufBlock.					    */

static Block
bigbufNew(
    Vm_Unt octave,
    Vm_Unt offset,
    Vm_Unt unique,
    Vm_Unt exact_size,
    Vm_Unt dbfile
) {
    /* We always word-align everything, so round exact_size up: */
    Vm_Unt bytes_needed = (exact_size + (VM_INTBYTES-1)) & ~(VM_INTBYTES-1);

    /* We also need to store our header: */
    bytes_needed += sizeof( A_Block );

    /* For large objects, we need an additional */
    /* word to store the exact size:		*/
    if (octave >= VM_FIRST_BIG_OCTAVE)  bytes_needed += VM_INTBYTES;

    {   /* Allocate the bigbufBlock: */
	Vm_Obj   o = objImplode( octave, offset, dbfile, unique );
	Block    p = bigbufAlloc( bytes_needed );
        Block*   f = &bigbufHashtab[ (o>>VM_HASHTAB_SHIFT) & VM_HASHTAB_MASK ];
        Vm_Unt s = exact_size;

	/* Remember to leave room for extended length word if needed: */
        if (octave >= VM_FIRST_BIG_OCTAVE) {
            p = (Block) ((Vm_Int*)p +1);

	    /* As an ugly little special case, if */
	    /* bigbufFirstMaybeDead pointed to p, */
	    /* we need to bump it one word also:  */
	    if (bigbufFirstMaybeDead == (Block)((Vm_Int*)p-1)) {
		bigbufFirstMaybeDead =                p   ;
        }   }

	/* Remember our Vm_Obj, setting the internal bits we care about: */
	p->o       =  o   |   (VM_DIRTYBIT | VM_HEADER);

	/* Figure and save int offset of our 'next' block in bigbuf: */
	p->next	   = ((Vm_Int*)*f - (Vm_Int*)bigbufBeg) << VM_SMALLSIZE_SHIFT;

	/* Remember exact_size of new object.  Small sizes are stored */
        /* offset by one, so we can pack lengths 1 -> 64 in six bits: */
	if (octave < VM_FIRST_BIG_OCTAVE)  p[ 0].next |= s;
        else                               p[-1].next  = s << VM_BIGSIZE_SHIFT;

        /* Thread our bigbufBlock into hashtab: */
	*f         =  p;

	return p;
    }
}



/************************************************************************/
/*-    bigbufNext -- Find next bigbufBlock.				*/
/************************************************************************/

static Block bigbufNext(
    Block p
) {
    Block   result;

    /* Figure out size-in-bytes of object: */
    Vm_Unt exact_size = len( p );

    /* Round exact_size up to integral number of words: */
    exact_size  = exact_size + (VM_INTBYTES-1)  &  ~(VM_INTBYTES-1);

    /* Add in size of standard header block: */
    exact_size += sizeof( A_Block );

    /* Step to location of next block: */
    result = (Block) ((Vm_Uch*)p + exact_size);

    /* If low bit of result is 0, next object has an extra   */
    /* length word preceding it, which we need to step over. */
    /* End-of-buffer poses a special case, however:	     */
    if (result < bigbuffree) {
        if (!(result->o & VM_HEADER)) {
	    result = (Block) ((Vm_Unt*)result +1);
    }	}

    return result;
}



/************************************************************************/
/*-    bigbufPrint -- Print contents of bigbuf.				*/
/************************************************************************/

#if VM_DEBUG
static void bigbufPrint(
    FILE* f
) {

    Block p;
    for (
        p = bigbufFirst();
	p < bigbuffree;
        p = bigbufNext(p)
    ) {
        Vm_Int            i;
        Vm_Int            bytes = len(p);
        Vm_Uch* s     = (Vm_Uch*) (p+1);

	fprintf(f,
	    "%s BLOCK         p x=%p p->o x=%08" VM_X " p->next x=%08" VM_X,
	    VM_IS_LIVE(p) ? "LIVE" : "DEAD",
	    p,
	    (Vm_Unt) p->o,
	    (Vm_Unt) p->next
        );
	if (VM_IS_BIG_OCTAVE(p->o)) fprintf(f," p[-1].next x=%08" VM_X,p[-1].next);
	fprintf(f,"\n");

	{   A_Ex e;
            objExplode( &e, p->o );
            fprintf(f,
		"octave x=%2d offset d=%5d size d=%5d\n",
		(int)e.octave, (int)e.offset, (int)vm_octave_capacity[ e.octave ]
	    );
        }

	for (i = 0;   i < bytes;  ++i)   fprintf(f,"%02x.",(int)s[i]);
	if (bytes)   fprintf(f,"\n");
    }
}
#endif



/************************************************************************/
/*-    bigbufResize -- Change bigbuf to given size.			*/
/************************************************************************/

/* --- Private to this fold ---						*/

/************************************************************************/
/*-    updatePointer -- update a pointer into moved bigbuf.		*/
/************************************************************************/

static void updatePointer(
    Block* p,
    Block  newLoc
) {
    Vm_Int offset = (Vm_Uch*)(newLoc) - (Vm_Uch*)bigbufBeg;
    *p = (Block)   ((Vm_Uch*)*p + offset);
}



/************************************************************************/
/* WARNING!!  We do NOT check that everything will fit in new size,	*/
/* or that new size is sensible -- this is a low-level routine, such	*/
/* checks are for caller to make.					*/
/************************************************************************/

static void bigbufResize(
    Vm_Unt new_size
) {
    /* Resize bigbuf, presumably relocating it also: */
    Block newLoc;
    saveHardPointerOffsets();
    newLoc = realloc( bigbufBeg, new_size );
    if (!newLoc) VM_FATAL ("bigbufResize: couldn't realloc()");

    /* Fix the hashtable pointers into bigbuf: */
    {   Vm_Int offset = (Vm_Uch*)newLoc - (Vm_Uch*)bigbufBeg;
        Vm_Int i;
	for (i = VM_HASHTAB_SIZE;   i --> 0; ) {
	    bigbufHashtab[i] = (Block)( (Vm_Uch*)bigbufHashtab[i] + offset );
    }   }

    /* Fix our own hard pointers into bigbuf: */
    updatePointer( &bigbuffree          , newLoc );
    updatePointer( &bigbufFirstMaybeDead, newLoc );
    bigbufBeg = newLoc;
    bigbufEnd = (Block) ((Vm_Uch*)bigbufBeg + new_size);

    /* Fix any user hard pointers into bigbuf: */
    updateHardPointers();
}



/************************************************************************/
/*-    bigbufSwapObjOut -- Swap 'p' to disk.				*/
/************************************************************************/

static void
bigbufSwapObjOut(
    Block p
) {
    /* We ignore the call if p is dead: */
    if (!VM_IS_LIVE(p))   return;

    /* We ignore the call if p is locked in ram: */
    if (lockedInRam( p->o ))   return;

    /* Write object to disk if dirty: */
    dbfileSet( dbfind(VM_DBFILE(p->o)), p );

    /* Delete object from bigbuf and hashtable: */
    bigbufFree( p );
}



/************************************************************************/
/*-    bitget -- Fetch an entry from given bitmap.			*/
/************************************************************************/

static Vm_Unt
bitget(
    Vm_Db       db,
    Vm_Unt octave,
    Vm_Unt offset,
    int    bitmap
) {
    Vm_Int wordNo = offset >> VM_LOG2_INTBITS;
    Vm_Int bitNo  = offset  & (VM_INTBITS-1);

    if (octave <  VM_FIRST_OCTAVE
    ||  octave >  VM_FINAL_OCTAVE
    ){
	VM_FATAL ("bitget: bad octave");
    }

    /* This should only happen during garbage   */
    /* collection, when we are checking colors: */
    if (offset >= db->o[octave].diskSlots)   return 0;

    return (db->o[octave].bitmap[bitmap][ wordNo ] >> bitNo) & 1;
}

/************************************************************************/
/*-    getAllocBit -- Fetch an entry from alloc bitmap.			*/
/************************************************************************/

static Vm_Unt
getAllocBit(
    Vm_Db      db,
    Vm_Unt octave,
    Vm_Unt offset
) {
    if (octave != VM_FINAL_OCTAVE) {
        return bitget( db, octave, offset, ALLOC );
    }

    /* Large multi-quart objects are a special case. */
    /* They are allocated iff their quart offset     */
    /* base pointer is set:                          */

    #if MUQ_IS_PARANOID
    if (offset >= db->o[octave].quarts)   VM_FATAL ("getAllocBit bad offset");
    #endif

    return db->o[octave].quartOffset[offset] != 0;
}



/************************************************************************/
/*-    bitset -- Store an entry into given bitmap.			*/
/************************************************************************/

static void
bitset(
    Vm_Db  db,
    Vm_Unt octave,
    Vm_Unt offset,
    Vm_Int bitmap,
    Vm_Int value
) {
    Vm_Int wordNo = offset >> VM_LOG2_INTBITS;
    Vm_Int bitNo  = offset  & (VM_INTBITS-1);
    Vm_Int word;

    if (octave <  VM_FIRST_OCTAVE
    ||  octave >  VM_FINAL_OCTAVE
    ){
	VM_FATAL ("bitset: bad octave");
    }
    if (offset >= db->o[octave].diskSlots) {
	VM_FATAL ("bitset: bad offset");
    }

    /* Value needs to be just one bit: */
    value &= 1;

    /* Set given bit: */
    word   = db->o[octave].bitmap[bitmap][ wordNo ];
    word  &= ~(((Vm_Unt)1) << bitNo);
    word  |=  (value << bitNo);
    db->o[octave].bitmap[bitmap][ wordNo ] = word;
}

/************************************************************************/
/*-    setAllocBit -- Store an entry into alloc bitmap.			*/
/************************************************************************/

static void
setAllocBit(
    Vm_Db  db,
    Vm_Unt octave,
    Vm_Unt offset,
    Vm_Int value
) {
    if (octave < VM_FINAL_OCTAVE) {
	bitset( db, octave, offset, ALLOC, value );

	/* Update count of empty slots in that bitmap: */
	db->o[octave].freeSlots -= (value << 1) -1;

	return;
    }

    /* Final octave is a special case, where we have   */
    /* multiple quarts per object, instead of multiple */
    /* object slots per quart.                         */

    /* If 'value' is nonzero, all necessary work has   */
    /* already been done:                              */
    if (value)  return;

    #if MUQ_IS_PARANOID
    if (!db->o[octave].quartOffset[offset]) {
	VM_FATAL("setAllocBit: Duplicate free");
    }
    #endif

    /* We need to clear the global quart allocation    */
    /* bits corresponding to our object and then our   */
    /* quartOffset pointer:                            */
    {   /* How many quarts in this object? */
	Vm_Int size_in_bytes = db->o[octave].size.i[offset];
	Vm_Unt quartOffset   = db->o[octave].quartOffset[offset];
	Vm_Int quarts        = (size_in_bytes + (VM_QUART_BYTES-1)) >> VM_LOG2_QUART_BYTES;
	Vm_Unt quartNo       = (quartOffset   -  VM_QUART0_OFFSET ) >> VM_LOG2_QUART_BYTES;
	Vm_Int i;
	for   (i = 0;   i < quarts;   ++i) {
            quartFree( quartNo+i );
	}
        db->o[octave].quartOffset[offset] = 0;
	db->o[octave].size.i[offset]      = 0;
    }
}



/************************************************************************/
/*-    bytget -- Fetch an entry from a bytmap.				*/
/************************************************************************/

static Vm_Int
bytget(
    Vm_Db  db,
    Vm_Unt octave,
    Vm_Unt offset,
    Vm_Unt bytmap
) {

    if (octave <  VM_FIRST_OCTAVE
    ||  octave >  VM_FINAL_OCTAVE
    ){
	VM_FATAL ("bytget: bad octave");
    }
    if (offset >= db->o[octave].diskSlots) {
	VM_FATAL ("bytget: bad offset");
    }
    return db->o[octave].bytmap[bytmap][offset];
}

/************************************************************************/
/*-    bytset -- Store an entry into bytmap slot.			*/
/************************************************************************/

static void
bytset(
    Vm_Db  db,
    Vm_Unt octave,
    Vm_Unt offset,
    Vm_Unt bytmap,
    Vm_Int value
) {
    if (octave <  VM_FIRST_OCTAVE
    ||  octave >  VM_FINAL_OCTAVE
    ){
	VM_FATAL ("bytset: bad octave");
    }
    if (offset >= db->o[octave].diskSlots) {
	VM_FATAL ("bytset: bad offset");
    }
    db->o[octave].bytmap[bytmap][offset] = value;
}

/************************************************************************/
/*-    sizeGet -- Fetch an entry from size field.			*/
/************************************************************************/

static Vm_Int
sizeGet(
    Vm_Db  db,
    Vm_Unt octave,
    Vm_Unt offset
) {

    if (octave <  VM_FIRST_OCTAVE
    ||  octave >  VM_FINAL_OCTAVE
    ){
	VM_FATAL ("sizeGet: bad octave");
    }
    if (offset >= db->o[octave].diskSlots) {
	VM_FATAL ("sizeGet: bad offset");
    }
    {   Octave o = &db->o[octave];
        if (o->bytesPerSlot <= 128)  return o->size.b[offset];
        else                         return o->size.i[offset];
    }
}

/************************************************************************/
/*-    sizeSet -- Store an entry into size field.			*/
/************************************************************************/

static void
sizeSet(
    Vm_Db  db,
    Vm_Unt octave,
    Vm_Unt offset,
    Vm_Int value
) {
    if (octave <  VM_FIRST_OCTAVE
    ||  octave >  VM_FINAL_OCTAVE
    ){
	VM_FATAL ("sizeSet: bad octave");
    }
    if (offset >= db->o[octave].diskSlots) {
	VM_FATAL ("sizeSet: bad offset");
    }
    {   Octave o = &db->o[octave];
        if (o->bytesPerSlot <= 128)  o->size.b[offset] = value;
        else                         o->size.i[offset] = value;

        #if MUQ_IS_PARANOID
        if (o->bytesPerSlot <= 128 && value && ((value-1) & ~(Vm_Int)0xFF)) {
	    VM_FATAL ("sizeSet: out of range value");
	}
	#endif
    }
}

/************************************************************************/
/*-    physicalSize -- Space actually allocated to object.		*/
/************************************************************************/

static Vm_Int
physicalSize(
    Vm_Db db,
    Ex    e
){
    int oct = e->octave;
    if (oct < VM_FINAL_OCTAVE)    return vm_octave_capacity[ oct ];

    /* Round official size up to round number of quarts: */
    {   Vm_Unt bytes = sizeGet( db, e->octave, e->offset );
	Vm_Int quarts= (bytes + (VM_QUART_BYTES-1)) >> VM_LOG2_QUART_BYTES;
	return quarts << VM_LOG2_QUART_BYTES;
    }
}

/************************************************************************/
/*-    initialize_object_bitfields_and_bytefields.			*/
/************************************************************************/

static void
initialize_object_bitfields_and_bytefields(
    Vm_Db  db,
    Vm_Unt octave,
    Vm_Unt offset,
    Vm_Unt len,
    Vm_Uch unique,
    Vm_Uch tags
) {
    /* Make sure all bitfields and bytefields get initialized: */
    {   Vm_Int map;
        for (map = VM_BYTMAPS;   map --> 0;   )   bytset( db, octave, offset, map, 0 );
        for (map = VM_BITMAPS;   map --> 0;   ) {
	    if (octave != VM_FINAL_OCTAVE
	    ||  map    != ALLOC
	    ){
		bitset( db, octave, offset, map, 0 );
	    }
	}
    }
    /* We could speed up the above with custom logic, should   */
    /* it become an issue (not impossible).                    */

    /* Set known non-zero values: */
    if (octave != VM_FINAL_OCTAVE)   bitset(  db, octave, offset, ALLOC, 1      );
    bytset(  db, octave, offset, UNIQ,  unique );
    bytset(  db, octave, offset, TAGS,  tags   );
    sizeSet( db, octave, offset,        len    );
}

/************************************************************************/
/*-    bitmapExpand -- Add one slot to given bitmap/file.		*/
/************************************************************************/

static Vm_Unt
bitmapExpand(
    Vm_Db      db,
    Vm_Unt octave
) {
    Vm_Unt offset =   db->o[octave].diskSlots;
    bitmapSlotValidate( db, octave, offset    );
    return offset;
}



/************************************************************************/
/*-    bitmapFree -- Delete 'o' from disk bitmap.			*/
/************************************************************************/

static void
bitmapFree(
     Vm_Db  db,
     Vm_Obj o
) {
    A_Ex e;
    objExplode( &e, o );

    /* Mark disk slot as being free by clearing bitmap bit: */
    setAllocBit( db, e.octave, e.offset, 0 );

    if (e.octave < VM_FINAL_OCTAVE) {
	/* Maybe save new free slot so we can allocate it faster: */
	cacheFreeslot( db, e.octave, e.offset );

	-- db->s.used_blocks;
	++ db->s.free_blocks;

    } else {

	Vm_Unt quarts = physicalSize( db, &e ) >> VM_LOG2_QUART_BYTES;

	db->s.used_blocks -= quarts;
	db->s.free_blocks += quarts;
    }
}



/************************************************************************/
/*-    bitmapInvariants -- Sanitycheck bitmaps.				*/
/************************************************************************/

#if VM_DEBUG
static int
bitmapInvariants(
    FILE* f,
    Vm_Uch* t,
    int     count
) {
    Vm_Int errsfound = 0;

    /********************************************************************/
    /* INVARIANT:							*/
    /* o[i].fileSlots gives number of allocated slots in 'i'th     	*/
    /* octave file.  That is, o[i].fileSlots times the number      	*/
    /* of bytes per slot gives the file size.  	       	       	       	*/
    /********************************************************************/
    /* Note one has to account for the 1 (small octave) or 8 (large     */
    /* octave) bytes of size info added to each slot if applying the    */
    /* above invariant exactly.  We don't check this currently.		*/

    /********************************************************************/
    /* INVARIANT:							*/
    /* o[i].alloc points to a bitmap with one bit per			*/
    /* allocated slot, recording the free/used status of the slots	*/
    /* in file i.  Contents of unused bits in last byte in bitmap      	*/
    /* are undefined.	      	      	      	       	       	       	*/
    /********************************************************************/
    /* malloc doesn't let us check length: */
    {   Vm_Unt u;
	for (u = VM_FINAL_OCTAVE  ;   u --> VM_FIRST_OCTAVE;   ) {
	    if (vm_This_Db->o[u].allocSlots) {
		if (!vm_This_Db->o[u].bitmap[ALLOC]) {
		    ++errsfound;
		    err(f,t,"bitmap for octave %d not allocated\n",(int)u);
    }   }   }   }

    /********************************************************************/
    /* INVARIANT:							*/
    /* o[i].allocSlots gives the physical size in bits of the		*/
    /* allocation bitmap for octave/file i.  This is always a power	*/
    /* of two and always >= o[i].fileSlots, the logical size of     	*/
    /* the bitmap.							*/
    /********************************************************************/
#ifdef OLD
    {   Vm_Unt u;
	for (u = VM_FINAL_OCTAVE+1;   u --> VM_FIRST_OCTAVE;   ) {
	    if (vm_This_Db->o[u].allocSlots < vm_This_Db->o[u].fileSlots) {
		++errsfound;
		err(f,t,
		    "o[%d].bmMapSlots (%" VM_X ") < o[%d].fileSlots[%d] (%" VM_X ")\n",
		    (int)u, vm_This_Db->o[u].allocSlots, (int)u, vm_This_Db->o[u].fileSlots
		);
	    }
	    if (                   vm_This_Db->o[u].allocSlots !=
		powerOfTwoCeiling( vm_This_Db->o[u].allocSlots )
	    ){
		++errsfound;
		err(f,t,
		    "o[%d].allocSlots len (%" VM_X ") not a power of two!\n",
		    (int)u, vm_This_Db->o[u].allocSlots
		);
   }   }   }
#endif

    /********************************************************************/
    /* INVARIANT:							*/
    /* o[i].freeSlots gives number of free slots (0 bits) in the	*/
    /* allocation bitmap for octave/file i.                        	*/
    /********************************************************************/
#ifdef OLD
    {   Vm_Unt o;
	for (o = VM_FINAL_OCTAVE+1;   o --> VM_FIRST_OCTAVE;   ) {
	    Vm_Unt free = 0;
	    Vm_Unt slot = vm_This_Db->o[o].fileSlots;
	    /* Much faster if done by bytes, but I'm not */
	    /* optimizing *Invariants() heavily:         */
	    for (slot = vm_This_Db->o[o].fileSlots;   slot --> 0;   ) {
		if (!getAllocBit(vm_This_Db,o,slot))   ++free;
	    }
	    if (free != vm_This_Db->o[o].freeSlots) {
		++errsfound;
		err(f,t,
		    "o[%d].freeSlots is %" VM_X " not %" VM_X "\n",
		    (int)o, vm_This_Db->o[o].freeSlots, free
		);
    }   }   }
#endif

    /********************************************************************/
    /* INVARIANT:							*/
    /* 0 <= o[o].freeCacheLen <= VM_BITMAP_CACHE_SIZE, and gives	*/
    /* the number of valid entries in o[o].freeCache[].			*/
    /* Each such valid entry gives the offset of a zero bit in		*/
    /* o[o].alloc[].							*/
    /********************************************************************/
    {   Vm_Unt o;
	for (o = VM_FINAL_OCTAVE+1;   o --> VM_FIRST_OCTAVE;   ) {
	    Vm_Unt e = vm_This_Db->o[o].freeCacheLen;
	    if (e > VM_BITMAP_CACHE_SIZE) {
		++errsfound;
		err(f,t,
		    "o[%d].freeCacheLen (%" VM_X ") > BITMAP_CACHE_SIZE (%" VM_X ")\n",
		    (int)o, e, VM_BITMAP_CACHE_SIZE
		);
	    }
	    while (e --> 0) {
		Vm_Unt slot = vm_This_Db->o[o].freeCache[e];
		if (getAllocBit(vm_This_Db,o,slot)) {
		    ++errsfound;
		    err(f,t,
			"o[%d].freeCacheLen[%d] (%" VM_X ") isn't free\n",
			(int)o, (int)e, slot
		    );
    }   }   }   }

    /********************************************************************/
    /* INVARIANT:							*/
    /* A Vm_Obj value should exist only if the matching bit is set	*/
    /* in our allocation bitmaps.  This depends partly on cooperation	*/
    /* from the user, who mustn't use a Vm_Obj after calling vm_Free()	*/
    /* on it, of course.						*/
    /********************************************************************/
    /* We don't (yet?) attempt to locate all Vm_Obj values, just those	*/
    /* stored in the hashtable as keys:					*/
    {	Block nullBlock = (Block) ((Vm_Unt*)bigbufBeg +1);
	Vm_Int    i;
	for (i = VM_HASHTAB_SIZE;   i --> 0; ) {
	    Block p = bigbufHashtab[i];
	    for (
		p  = bigbufHashtab[i];
		p != nullBlock;
		p  = VM_NEXT_HASH_BLOCK(p)
	    ) {
		Vm_Db db = dbfind(VM_DBFILE(p->o));
		A_Ex e;
		objExplode( &e, p->o );
		if (!getAllocBit( db, e.octave, e.offset )) {
		    ++errsfound;
		    err(f,t,
			"Live block p (%p) ->o (%" VM_X ") => \n",
			p, p->o
		    );
		    err(f,t,
			"octave %x slot %x isn't in bitmap\n",
			(int)e.octave, (int)e.offset
		    );
    }	}   }   }
    return errsfound;
}
#endif



/************************************************************************/
/*-    bitmapNew -- Allocate offset for object of given octave.		*/
/************************************************************************/

static Vm_Unt
bitmapNew(
    Vm_Db  db,
    Vm_Unt o,	/* octave */
    Vm_Unt len
) {
    Octave   p = &db->o[ o ];

    if (o < VM_FIRST_OCTAVE
    ||  o > VM_FINAL_OCTAVE
    ){
	VM_FATAL ("bitmapNew: bad arg");
    }

    if (o < VM_FINAL_OCTAVE) {
	/* Find/create a free slot: */
        Vm_Unt slot;
	if (p->freeCacheLen) {

	    /* Allocate free slot in O(1) time from our cache: */
	    slot = p->freeCache[ --p->freeCacheLen ];

	} else if (p->freeSlots) {

	    /* Refill cache, then same as above: */
	    cacheRefill( db, o );
	    slot = p->freeCache[ --p->freeCacheLen ];

	} else {

	    /* Create a free slot by expanding file: */
	    slot = bitmapExpand( db, o );
	}

	/* Allocate and return slot: */
	++ db->s.used_blocks;
	-- db->s.free_blocks;
	setAllocBit(db,o,slot,1);
	return slot;
    }

    {   /* Find a slot in which to put object disk offset: */
	Vm_Unt slot   = quartOffsetSlotAlloc( db );

        /* Allocate the actual disk space needed, */
        /* return disk offset of that space:      */
	Vm_Int quarts = (len + (VM_QUART_BYTES-1)) >> VM_LOG2_QUART_BYTES;
        Vm_Unt offset = quartsAlloc( vm_Root_Db, quarts );

        /* Remember object's address. This */
	/* also allocates the slot, by     */
	/* setting it nonzero:             */
        db->o[VM_FINAL_OCTAVE].quartOffset[slot] = offset;

	/* Bookkeeping: */
	db->s.used_blocks += quarts;
	db->s.free_blocks -= quarts;

	return slot;
    }
}



/************************************************************************/
/*-    bitmapNext  -- Return next object after 'o', else FALSE.		*/
/************************************************************************/

/* We return FALSE if there is no next object. */

/**************************************************/
/* A the moment, vm_Next() is the only nontrivial */
/* function calling this function.                */
/**************************************************/

static Vm_Obj
bitmapNext(
    Vm_Db  db,
    Vm_Obj o
) {
    A_Ex e;
    objExplode( &e, o );

    ++e.offset;

    for     ( ;   e.octave <= VM_FINAL_OCTAVE          ;   ++e.octave) {
        for ( ;   e.offset <  db->o[e.octave].diskSlots;   ++e.offset) {

	    /* NB: Will never return reserved value (Vm_Obj)0 here: */
	    if (getAllocBit(db,e.octave,e.offset)) {

		Vm_Unt unique = dbgetUniqueBits( db, e.octave, e.offset                     );
		Vm_Unt tags   = dbgetTagBits(    db, e.octave, e.offset                     );
		Vm_Obj object = objImplode(          e.octave, e.offset, db->dbfile, unique );
		return object | tags;
	}   }
	e.offset = 0;
    }

    return (Vm_Obj) FALSE;
}



/************************************************************************/
/*-    bitmapTake -- Allocate given offset for object of given octave.	*/
/************************************************************************/

#ifdef SOMEDAY
static void
bitmapTake(
    Vm_Db       db,
    Vm_Unt octave,
    Vm_Unt offset
) {
    bitmapSlotValidate( db, octave, offset    );
    if (getAllocBit(         db, octave, offset    ))   VM_FATAL ("bitmapTake");
/* buggo, if this code is needed, some special case coding */
/* may be needed for octave==VM_FINAL_OCTAVE case:         */
    setAllocBit(             db, octave, offset, 1 );
    cacheDelete(        db, octave, offset    );
}
#endif


/************************************************************************/
/*-    bitmapFillQuartOffsetArraySlot					*/
/************************************************************************/

static void
bitmapFillQuartOffsetArraySlot(
    Vm_Db  db,
    Vm_Unt octave,
    Vm_Unt slot
) {
    /* Allocate the new quart: */
    db->o[octave].quartOffset[ slot ] = quartAlloc( vm_Root_Db );

    /* Update accounting info: */
    {	Vm_Unt new_slots            = db->o[octave].slotsPerQuart;
	db->o[octave].diskSlots    += new_slots;
	db->o[octave].freeSlots    += new_slots;
	db->s.free_blocks          += new_slots;
	db->s.bytes_in_free_blocks += new_slots * vm_octave_capacity[ octave ];
    }
/* buggo, should rehack above to expand by bigger steps, likely */
/* buggo, I presume 'octave' must always be FINAL_OCTAVE and    */
/*        hence new_slots must always be 1?  If so, should      */
/*        recode the function to reflect this.                  */
}

/************************************************************************/
/*-    bitmapExpandQuartOffsetArray					*/
/************************************************************************/

static void
bitmapExpandQuartOffsetArray(
    Vm_Db      db,
    Vm_Unt octave
) {
    /* Re/allocate quart offset map: */
    if (db->o[octave].quarts) {
	db->o[octave].quartOffset = (Vm_Unt*) realloc(
	    db->o[octave].quartOffset,
	   (db->o[octave].quarts+1) * sizeof(Vm_Unt)
	);
    } else {
	db->o[octave].quartOffset = (Vm_Unt*) malloc(
	    sizeof(Vm_Unt)
	);
    }
    db->o[octave].quartOffset[ db->o[octave].quarts ++ ] = 0;

/* buggo, should rehack above to expand by bigger steps, likely */
}

/************************************************************************/
/*-    bitmapExpandBitmapProper						*/
/************************************************************************/

static void
bitmapExpandBitmapProper(
    Vm_Db  db,
    Vm_Unt octave,
    Vm_Unt offset
) {
    Vm_Unt  u;
    Vm_Unt  bitmap_words_before = db->o[octave].allocSlots >> VM_LOG2_INTBITS;
    Vm_Unt  bitmap_words_after  = bitmap_words_before;
    Vm_Unt* new_bitmaps[VM_BITMAPS];
    Vm_Uch* new_bytmaps[VM_BYTMAPS];
    Vm_Uch* newSize;

    /* Figure new bitmap size.  Constraints here are:		   */ 
    /* (1) Bitmap size must be an integral number of 64-bit words. */
    /* (2) Bitmap must be at least 'offset'+1 slots long.	   */ 
    /* (3) Bitmap must be at least 'diskSlots' slots long.	   */
    while ((bitmap_words_after << VM_LOG2_INTBITS) <= offset
    ||     (bitmap_words_after << VM_LOG2_INTBITS) <  db->o[octave].diskSlots
    ){
	++  bitmap_words_after;
    }

    /* Re/allocate the bitmap ram: */
    if (bitmap_words_before) {
	int  map;
	for (map = VM_BITMAPS;   map --> 0;   ) {
	    if (octave != VM_FINAL_OCTAVE || map != ALLOC) {
		new_bitmaps[map] = (Vm_Unt*) realloc(
		    db->o[octave].bitmap[map],
		    bitmap_words_after * sizeof(Vm_Unt)
		);
	    }
	}
	for (map = VM_BYTMAPS;   map --> 0;   ) {
	    new_bytmaps[map] = (Vm_Uch*) realloc(
		db->o[octave].bytmap[map],
		(bitmap_words_after << VM_LOG2_INTBITS)
	    );
	}
	newSize      = (Vm_Uch*) realloc(
	    db->o[octave].size.b,
	    (bitmap_words_after << VM_LOG2_INTBITS)
	    * ((db->o[octave].bytesPerSlot <= 128) ? 1 : VM_INTBYTES)
	);
    } else {
	int  map;
	for (map = VM_BITMAPS;   map --> 0;   ) {
	    if (octave != VM_FINAL_OCTAVE   ||   map != ALLOC) {
		new_bitmaps[map] = (Vm_Unt*) malloc(
		    bitmap_words_after * sizeof(Vm_Unt)
		);
	    }
	}
	for (map = VM_BYTMAPS;   map --> 0;   ) {
	    new_bytmaps[map] = (Vm_Uch*) malloc(
		(bitmap_words_after << VM_LOG2_INTBITS)
	    );
	}
	newSize = (Vm_Uch*) malloc(
	    (bitmap_words_after << VM_LOG2_INTBITS)
	    * ((db->o[octave].bytesPerSlot <= 128) ? 1 : VM_INTBYTES)
	);
    }
    {   int  map;
	for (map = VM_BITMAPS;   map --> 0;   ) {
	    if (octave != VM_FINAL_OCTAVE   ||   map != ALLOC) {
	        if (!new_bitmaps[map]) VM_FATAL ("bitmapSlotValidate: couldn't realloc() bitmap");
    }   }   }
    {   int  map;
	for (map = VM_BYTMAPS;   map --> 0;   ) {
	    if (!new_bytmaps[map]) VM_FATAL ("bitmapSlotValidate: couldn't realloc() bytmap");
    }   }
    if (!newSize    ) VM_FATAL ("bitmapSlotValidate: couldn't realloc() size");

    /* Zero out newly allocated bitmap words, keeping (Vm_Obj)0 sacred: */
    {   int  map;
	for (map = VM_BITMAPS;   map --> 0;   ) {
	    if (octave != VM_FINAL_OCTAVE   ||   map != ALLOC) {
	        for (u = bitmap_words_before;   u < bitmap_words_after;   ++u)   new_bitmaps[map][u] = 0;
    }   }   }
    if (!bitmap_words_before && octave==VM_FIRST_OCTAVE)             new_bitmaps[ALLOC][0] = 1;

    /* Zero out rest of newly allocated bytemap words: */
    {   int  map;
	for (map = VM_BYTMAPS;   map --> 0;   ) {
	    for (u = bitmap_words_before << VM_LOG2_INTBITS;   u < (bitmap_words_after << VM_LOG2_INTBITS);   ++u) {
		new_bytmaps[map][u] = 0;
    }   }   }

    /* Zero out newly allocated size info: */
    if (db->o[octave].bytesPerSlot <= 128) {
	Vm_Uch* slot = (Vm_Uch*) newSize;
	for (u = bitmap_words_before << VM_LOG2_INTBITS;   u < (bitmap_words_after << VM_LOG2_INTBITS);   ++u)  slot[u] = 0;
	db->o[octave].size.b = slot;
    } else {
	Vm_Int* slot = (Vm_Int*) newSize;
	for (u = bitmap_words_before << VM_LOG2_INTBITS;   u < (bitmap_words_after << VM_LOG2_INTBITS);   ++u)  slot[u] = 0;
	db->o[octave].size.i = slot;
    }

    {   int  map;
	for (map = VM_BITMAPS;   map --> 0;   ) {
	    if (octave != VM_FINAL_OCTAVE   ||   map != ALLOC) {
	        db->o[octave].bitmap[map] = new_bitmaps[map];
    }   }   }
    {   int  map;
	for (map = VM_BYTMAPS;   map --> 0;   ) {
	    db->o[octave].bytmap[map] = new_bytmaps[map];
    }   }
    db->o[octave].allocSlots       = bitmap_words_after << VM_LOG2_INTBITS;
}

/************************************************************************/
/*-    bitmapSlotValidate -- Ensure slot exists physically & logically.	*/
/************************************************************************/

static void
bitmapSlotValidate(
    Vm_Db  db,
    Vm_Unt octave,
    Vm_Unt offset
) {
    /* Looks to me like we will never be called on FINAL_OCTAVE */
    /* under the new quart scheme, so we don't have to recode   */
    /* specially for it.  Add a paranoid check to be sure:      */
    #if MUQ_IS_PARANOID
    if (octave==VM_FINAL_OCTAVE) VM_FATAL("bitmapSlotValidate() called on VM_FINAL_OCTAVE?!");
    #endif

    /* Maybe need to physically expand diskfile: */
    while (db->o[octave].diskSlots <= offset) {
	Vm_Unt slot =  db->o[octave].quarts;
	bitmapExpandQuartOffsetArray(   db, octave       );
        bitmapFillQuartOffsetArraySlot( db, octave, slot );
    }

    /* Maybe need to physically expand bitmaps and bytmaps: */
    if (db->o[octave].allocSlots <= offset			/* Support requested offset. */
    ||  db->o[octave].allocSlots <  db->o[octave].diskSlots	/* Support all disk slots.   */
    ){
	bitmapExpandBitmapProper( db, octave, offset );
    }
}





/************************************************************************/
/*-    bitmapsNuke -- free()  our bitmaps.				*/
/************************************************************************/

static void
bitmapsNuke(
    Vm_Db db
) {
    Vm_Int  octave;
    if (!db->dbfile)   free( db->quartAlloc );
    for (octave = VM_FIRST_OCTAVE;   octave <= VM_FINAL_OCTAVE;   ++octave) {
        int  map;
	for (map = VM_BITMAPS;   map --> 0;   ) {
	    if (octave != VM_FINAL_OCTAVE   ||   map != ALLOC) {
	        if (db->o[octave].bitmap[map])   free( db->o[octave].bitmap[map] );
	}   }
	for (map = VM_BYTMAPS;   map --> 0;   ) {
	    if (db->o[octave].bytmap[map])   free( db->o[octave].bytmap[map] );
        }
	if (db->o[octave].size.b)   free( db->o[octave].size.b   );

	for (map = VM_BITMAPS;   map --> 0;   )   db->o[octave].bitmap[map] = NULL;
	for (map = VM_BYTMAPS;   map --> 0;   )   db->o[octave].bytmap[map] = NULL;
	db->o[octave].size.b   = NULL;
    }
}



/************************************************************************/
/*-    bitmapsPrint -- Print contents of bitmaps.			*/
/************************************************************************/

#if VM_DEBUG
static void bitmapsPrint(
    FILE* f,
    Vm_Db    db
) {
    Vm_Obj o;
    for (
        o = bitmapNext(   db,   (Vm_Obj) 0   );
        o;
        o = bitmapNext(   db,            o   )
    ) {
        A_Ex e;
	objExplode( &e, o );
	fprintf(f,"BITMAP ENTRY: octave x=%02x offset x=%05x\n",(int)e.octave,(int)e.offset);
    }
}
#endif



/************************************************************************/
/*-    cacheDelete -- Delete 'offset' from cache, if present.		*/
/************************************************************************/

#ifdef SOMEDAY
static void
cacheDelete(
    Vm_Db       db,
    Vm_Unt octave,
    Vm_Unt offset
) {
    Octave   p = &db->o[ octave ];
    Vm_Unt u;
    for (u= p->freeCacheLen;   u --> 0;   ) {
	if (p->freeCache[ u ] == offset) {
	    p->freeCache[ u ] = p->freeCache[ --p->freeCacheLen ];
	    return;
    }	}
}
#endif


/************************************************************************/
/*-    cacheFreeslot -- Save free slot in cache. TRUE unless full.	*/
/************************************************************************/

static Vm_Int
cacheFreeslot(
    Vm_Db  db,
    Vm_Unt octave,
    Vm_Unt slot
) {
    Octave p = &db->o[ octave ];

    /* I think it best to just never call this on FINAL_OCTAVE  */
    /* under the new quart scheme, so we don't have to recode   */
    /* specially for it.  Add a paranoid check to catch errors: */
    #if MUQ_IS_PARANOID
    if (octave==VM_FINAL_OCTAVE) VM_FATAL("cacheFreeslot() called on VM_FINAL_OCTAVE?!");
    #endif

    /* Enter empty slot in cache if cache isn't full: */
    if (p->freeCacheLen < VM_BITMAP_CACHE_SIZE) {
	p->freeCache[ p->freeCacheLen++ ] = slot;
    }
    return (
        p->freeCacheLen < VM_BITMAP_CACHE_SIZE
    );
}



/************************************************************************/
/*-    cacheRefill -- Find free slots in bitmap.			*/
/************************************************************************/

static void
cacheRefill(
    Vm_Db      db,
    Vm_Unt octave
) {
    Octave  p    = &db->o[ octave ];
    Vm_Unt* s    = p->bitmap[ALLOC];
    Vm_Int words = p->diskSlots >> VM_LOG2_INTBITS;

    /* I think it best to just never call this on FINAL_OCTAVE  */
    /* under the new quart scheme, so we don't have to recode   */
    /* specially for it.  Add a paranoid check to catch errors: */
    #if MUQ_IS_PARANOID
    if (octave==VM_FINAL_OCTAVE) VM_FATAL("cacheRefill() called on VM_FINAL_OCTAVE?!");
    #endif

    /* Over all fully allocated bytes *s: */
    while (words --> 0) {

        /* If some bit in word is zero: */
	if (*s != ~(Vm_Unt)0) {

	    /* Find all zero bits in word, */
	    /* and thus the offsets of a   */
	    /* slot on disk:               */
	    Vm_Unt offset = VM_INTBITS * (s - p->bitmap[ALLOC]);
	    Vm_Unt word   = *s;
	    Vm_Int      i;

	    /* Over all bits in word: */
	    for (i = VM_INTBITS;   i --> 0; ) {

		/* If this bit is zero, cache it: */
	        if (!(word & 1)) {

		    /* ... but if cache is full, give up and go home: */
                    if (!cacheFreeslot( db, octave, offset ))   return;
		}
		word  >>= 1;
		offset += 1;
	    }
	}
	++s;
    }

    /* Check any odd slots at end: */
    {   Vm_Unt hi = p->diskSlots;
        Vm_Unt lo = hi & ~(Vm_Unt)(VM_INTBITS-1);
        Vm_Unt offset;
	for (offset = lo;   offset < hi;   ++offset) {
	    if (!getAllocBit( db, octave, offset )) {
                if (!cacheFreeslot( db, octave, offset ))   return;
    }	}   }
}



/************************************************************************/
/*-    copy -- Copy n ints.						*/
/************************************************************************/

/* This fn is prolly faster than lotsa memcpy()s,			*/
/* since it knows everything is word-aligned and			*/
/* an integral number of words long:					*/

static Vm_Int* copy(
   Vm_Int* 	dst,
   Vm_Int* 	src,
   Vm_Unt	len
) {
    /* Avoid trusting compiler with loop vars in argslots: */
    register Vm_Int* d = dst;
    register Vm_Int* s = src;
    register Vm_Unt    i;

    /* Catch no-op copies: */
    if (d == s)   return dst+len;

    /* Unwind loop 8 times, avoid postdecrementing in conditional: */
    for (i = (len >> 3) +1;  --i;  ) {
	/* Use fixed offsets instead of increments  */
	/* to give risc instruction-reordering code */
	/* and superscalars more of a chance to	    */
	/* enjoy themselves:			    */
	d[0] = s[0];
	d[1] = s[1];
	d[2] = s[2];
	d[3] = s[3];
	d[4] = s[4];
	d[5] = s[5];
	d[6] = s[6];
	d[7] = s[7];
	d   += 8;
	s   += 8;
    }

    /* Mop up: */
    for (i = (len & 0x7) +1;  --i;  )   *d++ = *s++;

    return dst;
}

/************************************************************************/
/*-    vsystem -- wrapper for system()					*/
/************************************************************************/

static void
vsystem(
    const Vm_Uch* file,
          int     line,
    const Vm_Uch* cmd
){
    /* This wrapper gives us a central place */
    /* to add debugging logic or such.       */
/*  printf("%s.%d: vmsystem(%s)...\n",file,line,cmd); */
    system(cmd);
}

/************************************************************************/
/*-    vopen -- wrapper for open()					*/
/************************************************************************/

static int
vopen(
    const Vm_Uch* file,
          int     line,
    const Vm_Uch* name,
          int     mode
){
    int fd = open(name,mode);
    /* This wrapper gives us a central place */
    /* to add debugging logic or such.       */
/*  printf("%s.%d: vopen(%s,%d) = %d...\n",file,line,name,mode,fd); */
    return fd;
}

/************************************************************************/
/*-    vclose -- wrapper for close()					*/
/************************************************************************/

static int
vclose(
    const Vm_Uch* file,
          int     line,
          int     fd
){
    /* This wrapper gives us a central place */
    /* to add debugging logic or such.       */
/*  printf("%s.%d: vclose(%d)...\n",file,line,fd); */
    return close(fd);
}

/************************************************************************/
/*-    dbDuplicate -- Copy CURRENT to RUNNING db			*/
/************************************************************************/

static void
dbDuplicate(
    Vm_Db   db,
    Vm_Uch* ext		/* Always ".muq" at moment. */
) {
    Vm_Int    fd;
    Vm_Uch    buf[ 256 ];

    /*******************************************/
    /* Abort if there is already a RUNNING db. */
    /*******************************************/

    /* Construct name of running db: */
    strcpy( buf, dbpath1(db->dbfile,VM_PATH_RUNNING, ext ) );

    /* Exit if that RUNNING db already exists: */
    if ((fd = vmopen( buf, O_RDONLY)) >= 0) {
	vmclose( fd );
	fprintf(stderr, "\n\n***** A '%s' ALREADY EXISTS!\n", buf );
	fprintf(stderr, "Either another Muq is already running on this db,\n");
	fprintf(stderr, "or else a previous Muq run on this db crashed.\n\n");
	fprintf(stderr, "If another Muq is running, wait until it exits.\n");
	fprintf(stderr, "If the previous Muq run crashed, do\n");
	fprintf(stderr, "  rm -rf %s\n", buf );
	fprintf(stderr, "and then try again.  Muq will automatically\n");
	fprintf(stderr,
	    "revert to %s, which should be an intact db.\n",
            dbpath1(db->dbfile,VM_PATH_CURRENT, ext )
	);
	exit(1);
    }

    /* Same check for gzipped version : */
    sprintf( buf, "%s%s", dbpath1(db->dbfile,VM_PATH_RUNNING, ext), ".gz" );
    if ((fd = vmopen( buf, O_RDONLY)) >= 0) {
	vmclose( fd );
	fprintf(stderr, "\n\n***** A '%s' ALREADY EXISTS!\n", buf );
	fprintf(stderr, "Either another Muq is already running on this db,\n");
	fprintf(stderr, "or else a previous Muq run on this db crashed.\n\n");
	fprintf(stderr, "If another Muq is running, wait until it exits.\n");
	fprintf(stderr, "If the previous Muq run crashed, do\n");
	fprintf(stderr, "  rm -rf %s\n", buf );
	fprintf(stderr, "and then try again.  Muq will automatically\n");
	fprintf(stderr,
	    "revert to %s%s, which should be an intact db.\n",
            dbpath1(db->dbfile,VM_PATH_CURRENT,ext), ".gz"
	);
	exit(1);
    }

    /* Same check for lzopped version : */
    sprintf( buf, "%s%s", dbpath1(db->dbfile,VM_PATH_RUNNING, ext), ".lzo" );
    if ((fd = vmopen( buf, O_RDONLY)) >= 0) {
	vmclose( fd );
	fprintf(stderr, "\n\n***** A '%s' ALREADY EXISTS!\n", buf );
	fprintf(stderr, "Either another Muq is already running on this db,\n");
	fprintf(stderr, "or else a previous Muq run on this db crashed.\n\n");
	fprintf(stderr, "If another Muq is running, wait until it exits.\n");
	fprintf(stderr, "If the previous Muq run crashed, do\n");
	fprintf(stderr, "  rm -rf %s\n", buf );
	fprintf(stderr, "and then try again.  Muq will automatically\n");
	fprintf(stderr,
	    "revert to %s%s, which should be an intact db.\n",
            dbpath1(db->dbfile,VM_PATH_CURRENT,ext), ".lzo"
	);
	exit(1);
    }

    /* Same check for bzip2ed version : */
    sprintf( buf, "%s%s", dbpath1(db->dbfile,VM_PATH_RUNNING,ext),".bz2" );
    if ((fd = vmopen( buf, O_RDONLY)) >= 0) {
	vmclose( fd );
	fprintf(stderr, "\n\n***** A '%s' ALREADY EXISTS!\n", buf );
	fprintf(stderr, "Either another Muq is already running on this db,\n");
	fprintf(stderr, "or else a previous Muq run on this db crashed.\n\n");
	fprintf(stderr, "If another Muq is running, wait until it exits.\n");
	fprintf(stderr, "If the previous Muq run crashed, do\n");
	fprintf(stderr, "  rm -rf %s\n", buf );
	fprintf(stderr, "and then try again.  Muq will automatically\n");
	fprintf(stderr,
	    "revert to %s%s, which should be an intact db.\n",
            dbpath1(db->dbfile,VM_PATH_CURRENT,ext),".bz2"
	);
	exit(1);
    }

    /* If CURRENT exists, copy contents to RUNNING: */
    strcpy( buf, dbpath1(db->dbfile,VM_PATH_CURRENT,ext) );
    if ((fd = vmopen( buf, O_RDONLY)) >= 0) {

	vmclose( fd );

	/* Copy the db file: */
	sprintf(buf,
	    "cp %s %s",
            dbpath1( db->dbfile, VM_PATH_CURRENT, ext ),
            dbpath2( db->dbfile, VM_PATH_RUNNING, ext )
	);

	vmsystem(buf);
    } else {
        sprintf( buf, "%s%s", dbpath1(db->dbfile,VM_PATH_CURRENT,ext), ".gz" );
	if ((fd = vmopen( buf, O_RDONLY)) >= 0) {

	    vmclose( fd );

	    /* Copy the db file: */
	    sprintf(buf,
		"cp %s.gz %s.gz",
		dbpath1( db->dbfile, VM_PATH_CURRENT, ext ),
		dbpath2( db->dbfile, VM_PATH_RUNNING, ext )
	    );

	    vmsystem(buf);
	} else {

            sprintf( buf, "%s%s", dbpath1(db->dbfile,VM_PATH_CURRENT,ext), ".lzo" );
	    if ((fd = vmopen( buf, O_RDONLY)) >= 0) {

		vmclose( fd );

		/* Copy the db file: */
		sprintf(buf,
		    "cp %s.lzo %s.lzo",
		    dbpath1( db->dbfile, VM_PATH_CURRENT, ext ),
		    dbpath2( db->dbfile, VM_PATH_RUNNING, ext )
		);

		vmsystem(buf);

	    } else {
		sprintf( buf, "%s%s", dbpath1(db->dbfile,VM_PATH_CURRENT,ext), ".bz2" );
		if ((fd = vmopen( buf, O_RDONLY)) >= 0) {

		    vmclose( fd );

		    /* Copy the db file: */
		    sprintf(buf,
			"cp %s.bz2 %s.bz2",
			dbpath1( db->dbfile, VM_PATH_CURRENT, ext ),
			dbpath2( db->dbfile, VM_PATH_RUNNING, ext )
		    );

		    vmsystem(buf);
	        } else {

	            /* Create a vm0, with blank fileset: */
                    dbindexClear(db);
		}
	    }
	}
    }
}



/************************************************************************/
/*-    dbfileOffset -- Compute file offset of given octave record.	*/
/************************************************************************/

static Vm_Unt
dbfileOffset(
    Vm_Db     db,
    Vm_Unt octave,
    Vm_Unt offset
){

    #if MUQ_IS_PARANOID
    if (octave < VM_FIRST_OCTAVE
    ||  octave > VM_FINAL_OCTAVE
    ){
	VM_FATAL ("dbfileOffset: bad arg");
    }
    #endif

    if (octave < VM_FINAL_OCTAVE) {
	Vm_Unt slotsPerQuart   = db->o[octave].slotsPerQuart;
	Vm_Unt quart           = offset / slotsPerQuart;	/* These two might  */
	Vm_Unt slot            = offset % slotsPerQuart;	/* be a speed issue */
	Vm_Unt slotsize        = db->o[octave].bytesPerSlot;
	Vm_Unt quartAddr       = db->o[octave].quartOffset[quart];
	Vm_Unt fileOffset      = quartAddr   +   slot * slotsize;

        return fileOffset;
    }

    return   db->o[octave].quartOffset[offset];
}


/************************************************************************/
/*-    dbfileGet -- Get record from octave file, return Block.		*/
/************************************************************************/

static Block
dbfileGet(
    Vm_Db  db,
    Vm_Obj o
) {
    Vm_Unt exact_size;
    Vm_Unt rounded_up_size;
    Block    h;
    A_Ex e;
    objExplode( &e, o );

    if (e.dbfile != db->dbfile) {
	db = dbfind( e.dbfile );
    }

    exact_size = sizeGet( db, e.octave, e.offset );

    rounded_up_size  = (
	exact_size + (VM_INTBYTES-1)   &   ~(VM_INTBYTES-1)
    );


    /* Create a ramobj big enough to hold object:  */
    h = bigbufNew( e.octave, e.offset, e.unique, rounded_up_size, e.dbfile );

    {   /* Compute where to read record to.  We want  */
	/* to avoid moving it once read, although we  */
        /* will have to diddle the size info a bit:   */
        Vm_Uch*    buf    = (Vm_Uch*)(h+1);

	/* Compute offset of our slot within our file: */
	Vm_Unt fileOffset = dbfileOffset( db, e.octave, e.offset );

        /* Save h->next while our read() clobbers it: */
        Vm_Unt next = h->next;

	/* Read our record in from disk: */
	dbfileReadOrWrite(
            db        ,
            fileOffset,
	    buf       ,
	    rounded_up_size,
	    VM_READ
	);

	/* Buggo, at some point we need to do some sort */
	/* of graceful recovery from dangling pointers: */
	if (e.unique != bytget(  db, e.octave, e.offset, UNIQ )) {
            printf("vm.t:dbfileGet: dangling pointer %llx\n",o);
	    VM_FATAL("dangling pointer");
	}

	/* Store size info in low bits of h->next	*/
	/* (small octaves) or before *h (big octaves):	*/
	if (e.octave < VM_FIRST_BIG_OCTAVE) {
	    h[0].next = (
		next       & ~VM_SMALLSIZE_MASK
		|
		(exact_size) &  VM_SMALLSIZE_MASK
	    );
	} else {
	    h[-1].next = exact_size << VM_BIGSIZE_SHIFT;
	}
    }

    return h;
}


/************************************************************************/
/*-    dbread -- Read n bytes from a file descriptor.			*/
/************************************************************************/

static Vm_Int
dbread(
    Vm_Uch* buf,
    Vm_Int  bytecount,
    int     fd
){
    Vm_Int bytesread = (Vm_Int)0;

    /* Read requested number of bytes, remembering that read() */
    /* is not guaranteed to return requested number:           */
    for (;;) {
	Vm_Int i = read( fd, buf+bytesread, bytecount-bytesread );
	if (i <= (Vm_Int)0)  return i;
	bytesread += i;
	if (bytesread == bytecount)   break;
    }
    return bytesread;
}

/************************************************************************/
/*-    dbinit -- Initialize a new Vm_A_Db record.			*/
/************************************************************************/

static void
dbinit(
    Vm_Db  db,
    Vm_Unt dbId
){
    db->hnext         = NULL;
    db->s             = default_stats;
    db->next          = NULL;
    db->dbfile        = dbId;
    db->wasCompressed = dbId;
    /* Should we be clearing out any of the rest of *db? */

    /* Enter dbfile record into hashtable: */
    {   Vm_Int  h = VM_DBTAB_HASH(dbId);
        db->hnext = dbtab[h];
        dbtab[h]  = db;
    }
}

/************************************************************************/
/*-    dbnew -- Create and install a new Vm_A_Db record.		*/
/************************************************************************/

static Vm_Db
dbnew(
    Vm_Unt dbId
){
    /* Append a new db record to end of db chain: */
    Vm_Db db   = vm_Root_Db;
    while (db->next)    db = db->next;
    db->next   = (Vm_Db) alloc( sizeof(Vm_A_Db) );
    db         = db->next;
    dbinit( db, dbId );
    return db;
}

/************************************************************************/
/*-    dbfileReadOrWrite -- Fetch/Store an octave file record.		*/
/************************************************************************/

static void
dbfileReadOrWrite(
    Vm_Db       db   ,
    Vm_Unt fileOffset,
    Vm_Uch*    buf   ,
    Vm_Unt bytecount ,
    Vm_Int readOrWrite		/* VM_READ or VM_SEND */
) {
    /* Seek our file to our slot: */
    {   off_t loffset = fileOffset;
        off_t rslt    = lseek(vm_Root_Db->fileDescriptor,loffset,SEEK_SET);
	if (rslt==-1) VM_FATAL ("dbfileReadOrWrite: bad seek");
    }

    /* Read/write our record: */
    {   Vm_Unt i = 0;	/* Assignment is just to suppress compiler warnings. */

	switch (readOrWrite) {

	case VM_READ:
            ++db->s.object_reads;
	    i = dbread( buf, bytecount, vm_Root_Db->fileDescriptor );
            break;

	case VM_SEND:
            ++db->s.object_sends;
            i = write( vm_Root_Db->fileDescriptor, buf, bytecount );
            break;

	    /* buggo? -- should we be checking for read/write I/O errors here? */
	    /* checking bytes read/written will catch most cases, true, but we */
	    /* might want to do something more graceful on disk-full errors in */
	    /* particular, such as hanging until the problem is resolved.      */
	    /* Also, logging/reporting the errno might be nice.		   */
	default:
	    VM_FATAL ("dbfileReadOrWrite: bad readOrWrite value");
	}
	if (i != bytecount) {
	    VM_FATAL ("dbfileReadOrWrite: bad read/write fd %d",vm_Root_Db->fileDescriptor);
	}
        obj_NoteDateAsRandomBits();
    }
}



/************************************************************************/
/*-    dbfileSet -- Store record to octave file.			*/
/************************************************************************/

static void
dbfileSet(
    Vm_Db    db,
    Block h
) {
    A_Ex e;

    if (!h->o & VM_DIRTYBIT)   return;

    objExplode( &e, h->o );

    if (e.dbfile != db->dbfile) {
	db = dbfind( e.dbfile );
    }

    {   /* Compute where to start write from */
	/* by stepping over in-ram header:   */
        Vm_Uch*    buf    = (Vm_Uch*)(h+1);

	/* Compute offset of our slot within our file: */
	Vm_Unt fileOffset = dbfileOffset( db, e.octave, e.offset );

	/* Compute number of bytes to write: */
	Vm_Unt bufsize    = len(h);

        #if MUQ_IS_PARANOID
	/* At one point, we were writing records that extended */
	/* past end of bigbuf[] (because we were using the     */
	/* octave size instead of the exact size) which was    */
	/* harmless until it triggered a SEGV due to write()   */
	/* attempting to read past end of address space:       */
	if (buf+bufsize > (Vm_Uch*)bigbufEnd)  VM_FATAL ("bigbuf[] overrun");
	#endif

	/* Write our record to disk: */
	dbfileReadOrWrite(
            db        ,
            fileOffset,
	    buf       ,
            bufsize   ,
	    VM_SEND
	);

	/* Clear dirty bit: */
        h->o &= ~VM_DIRTYBIT;
    }
}



/************************************************************************/
/*-    dbfileZero -- Write all-zero record to octave file.		*/
/************************************************************************/

static void
dbfileZero(
    Vm_Db     db,
    Vm_Unt octave,
    Vm_Unt offset,
    Vm_Uch*zerobytes
) {
    Vm_Unt fileOffset = dbfileOffset( db, octave, offset );
    Vm_Int bytes = db->o[octave].bytesPerSlot;

    /* Write our record to disk: */
    dbfileReadOrWrite(
	db        ,
	fileOffset,
	zerobytes ,
	bytes     ,
	VM_SEND
    );
}

/************************************************************************/
/*-    dbfileZeroAllEmptySlots  -- Clear all unused slots on disk.	*/
/************************************************************************/

static void
dbfileZeroAllEmptySlots(
    Vm_Db     db
) {
    /* Zero unused parts of db file.   The only point of */
    /* this is to make the db file more compressible. On */
    /* the only case I tested, the file compressed 5%    */
    /* smaller as a result of this.        -- 99May05CrT */

    Vm_Uch zerobytes[VM_QUART_BYTES];
    Vm_Unt octave;
    Vm_Unt offset;

    {   Vm_Int i; 
	for (i = VM_QUART_BYTES;  i --> 0; )   zerobytes[i] = 0;
    }

    for     (octave = VM_FIRST_OCTAVE;   octave <  VM_FINAL_OCTAVE;           ++octave) {
        for (offset = 0              ;   offset <  db->o[octave].diskSlots;   ++offset) {

	    if (!getAllocBit(db,octave,offset)) {
		dbfileZero( db, octave, offset, zerobytes );
     	    }
	}
    }
    {   Vm_Unt quartNo;
        for   (quartNo = db->o[octave].quarts;   quartNo --> 0;  ) {
            if (!quartIsInUse( db, quartNo )) {
	        quartZero(     db, quartNo );
	    }
	}
    }
}



/************************************************************************/
/*-    dbloadI64 -- Read 64-bit integer value from file.		*/
/************************************************************************/

static Vm_Unt
dbloadI64(
    int fd,
    int swap
) {
    union {
        Vm_Unt i;
	Vm_Uch buf[ sizeof( Vm_Unt ) ];
    } u;

    if (sizeof(Vm_Unt) != dbread( u.buf, sizeof(Vm_Unt), fd)) {
        VM_FATAL("disk read failed");
    }

    return swap ? vm_Reverse64(u.i) : u.i;
}

/************************************************************************/
/*-    dbloadBytes -- Read N bytes from file.				*/
/************************************************************************/

static void
dbloadBytes(
    Vm_Uch* buf,
    int     bytes,
    int     fd
) {
    if (bytes != dbread( buf, bytes, fd)) {
        VM_FATAL("disk read failed");
    }
}

/************************************************************************/
/*-    dbsaveI64 -- Write 64-bit integer value to file.			*/
/************************************************************************/

static void
dbsaveI64(
    int    fd,
    Vm_Unt i
) {
    union {
        Vm_Unt i;
	Vm_Uch buf[ sizeof( Vm_Unt ) ];
    } u;

    u.i = i;

    if (sizeof(Vm_Unt) != write(fd,u.buf,sizeof(Vm_Unt))) {
        VM_FATAL("disk write failed");
    }
}

/************************************************************************/
/*-    dbsavebytes -- Write N bytes to file.				*/
/************************************************************************/

static void
dbsavebytes(
    int     fd,
    Vm_Uch* buf,
    int     bytes
) {
    if (bytes != write(fd,buf,bytes)) {
        VM_FATAL("disk write failed");
    }
}

/************************************************************************/
/*-    dbfindInRam -- Map database integer id to database record.	*/
/************************************************************************/

static Vm_Db
dbfindInRam(
    Vm_Unt id
) {
    Vm_Db  db = dbtab[ VM_DBTAB_HASH(id) ];
    for (db = dbtab[ VM_DBTAB_HASH(id) ];   db;   db = db->hnext) {
	if (db->dbfile == id)   return db;
    }
    return NULL;
}

/************************************************************************/
/*-    dbfind -- Map database integer id to database record.		*/
/************************************************************************/

static Vm_Db
dbfind(
    Vm_Unt id
) {
    Vm_Db  db;
    if (db= dbfindInRam( id ))  return db;
    {   Vm_Uch buf[1024];
        sprintf(
	    buf,
	    "vm.t(%s):dbfind: bad 'id' argument %" VM_X "/%s",
            vm_Octave_File_Path,
	    id,
	    vm_DbId_To_Asciz(id)
	);
        VM_FATAL(buf);
    }
    return NULL;	/* Just to quiet compilers.*/
}

/************************************************************************/
/*-    dbgetUniqueBits -- Find the unique bits for a given obj.		*/
/************************************************************************/

static Vm_Unt
dbgetUniqueBits(
    Vm_Db     db, 
    Vm_Unt octave,
    Vm_Unt offset
) {
    return bytget(  db, octave, offset, UNIQ );
}

/************************************************************************/
/*-    dbgetTagBits -- Find the tag bits for a given obj.		*/
/************************************************************************/

static Vm_Unt
dbgetTagBits(
    Vm_Db     db, 
    Vm_Unt octave,
    Vm_Unt offset
) {
    return bytget(  db, octave, offset, TAGS );
}

/************************************************************************/
/*-    find_compressor -- Locate compression executable.		*/
/************************************************************************/

static Vm_Int
find_compressor(
    Vm_Uch** result,
    Vm_Uch** path,
    Vm_Uch*  envvar
){
    Vm_Uch* gzip = getenv(envvar);
    if (gzip) {
	if (*gzip && access(gzip,X_OK) >=0) {
	    *result = gzip;
	    return TRUE;
	}
    } else {
	int  i;
	for (i = 0;   ;  ++i) {
	    if (!path[i])  break;
	    if (access(path[i],X_OK) >=0) {
		*result = path[i];
		return TRUE;
	    }
	}
    }

    return FALSE;
}

/************************************************************************/
/*-    find_gzip -- Locate gzip executable.				*/
/************************************************************************/

static  Vm_Uch*
gzip_path[] = {
    "/bin/gzip",
    "/usr/bin/gzip",
    "/usr/local/bin/gzip",
    NULL
}; 

static Vm_Int
find_gzip(
    Vm_Uch** result
){
    return find_compressor(result,gzip_path,"MUQ_GZIP");
}

/************************************************************************/
/*-    find_lzop -- Locate lzop executable.				*/
/************************************************************************/

static  Vm_Uch*
lzop_path[] = {
    "/bin/lzop",
    "/usr/bin/lzop",
    "/usr/local/bin/lzop",
    NULL
}; 

static Vm_Int
find_lzop(
    Vm_Uch** result
){
    return find_compressor(result,lzop_path,"MUQ_LZOP");
}

/************************************************************************/
/*-    find_bzip2 -- Locate bzip2 executable.				*/
/************************************************************************/

static  Vm_Uch*
bzip2_path[] = {
    "/bin/bzip2",
    "/usr/bin/bzip2",
    "/usr/local/bin/bzip2",
    NULL
}; 

static Vm_Int
find_bzip2(
    Vm_Uch** result
){
    return find_compressor(result,bzip2_path,"MUQ_BZIP2");
}

/************************************************************************/
/*-    dbindexCompress -- Compress a db file.				*/
/************************************************************************/

static Vm_Int
dbindexCompress(
    Vm_Db  db,
    Vm_Int gen,
    Vm_Uch*ext	/* ".db" or ".muq" */
) {
    Vm_Uch  buf[ 256 ];
    int     fd;
    Vm_Uch* gzip;
    Vm_Uch* lzop;
    Vm_Uch* bzip2;

    /* Does an uncompressed version of the file exist? */
    strcpy( buf, dbpath1(db->dbfile,gen,ext) );
    fd = vmopen( buf, O_RDWR );
    if (fd < 0)   return FALSE;
    vmclose(fd);

    /* Can we find gzip? */
    if (find_gzip( &gzip )) {
        sprintf(
            buf,
            "%s %s%c",
            gzip,
            dbpath1(db->dbfile,gen,ext),
            vm_Compress_Files_Asynchronously ? '&' : '\0'
        );
        vmsystem( buf);
        return TRUE;
    }

    /* Can we find lzop? */
    if (find_lzop( &lzop )) {
	sprintf(
	    buf,
            "%s --no-stdin --delete %s%c",
            lzop,
            dbpath1(db->dbfile,gen,ext),
            vm_Compress_Files_Asynchronously ? '&' : '\0'
        );
	vmsystem( buf);
        return TRUE;
    }

    /* Can we find bzip2? */
    if (find_bzip2( &bzip2 )) {
        sprintf(
            buf,
            "%s --compress --repetitive-fast %s%c",
            bzip2,
            dbpath1(db->dbfile,gen,ext),
            vm_Compress_Files_Asynchronously ? '&' : '\0'
        );
        vmsystem( buf);
        return TRUE;
    }

    return FALSE;
}

/************************************************************************/
/*-    dbindexDecompress -- Uncompress a compressed db file.		*/
/************************************************************************/

static Vm_Int
dbindexDecompress(
    Vm_Db   db,
    Vm_Uch* ext		/* ".muq" or ".db" */
) {
    Vm_Uch  buf[ 256 ];
    int     fd;

    /* Does a gzip-compressed version of the file exist? */
    sprintf( buf, "%s%s", dbpath1(db->dbfile,VM_PATH_RUNNING,ext), ".gz" );
    fd = vmopen( buf, O_RDWR );
    if (fd >= 0) {
        Vm_Uch* gzip;
        vmclose(fd);

	/* Can we find gzip? */
	if (find_gzip( &gzip )) {
	    sprintf(buf, "%s --decompress %s.gz", gzip, dbpath1(db->dbfile,VM_PATH_RUNNING,ext) );
	    vmsystem(buf);
	    db->wasCompressed = (Vm_Unt)TRUE;
	    return TRUE;
	}
    }

    /* Does a lzop-compressed version of the file exist? */
    sprintf( buf, "%s.lzo", dbpath1(db->dbfile,VM_PATH_RUNNING,ext) );
    fd = vmopen( buf, O_RDWR );
    if (fd >= 0) {
        Vm_Uch* lzop;
        vmclose(fd);

	/* Can we find lzop? */
	if (find_lzop( &lzop )) {
	    sprintf(buf,
		"%s --no-stdin --decompress --delete %s.lzo",
		lzop,
		dbpath1(db->dbfile,VM_PATH_RUNNING,ext)
	    );
	    vmsystem(buf);
	    db->wasCompressed = (Vm_Unt)TRUE;
	    return TRUE;
	}
    }

    /* Does a bz2-compressed version of the file exist? */
    sprintf( buf, "%s.bz2", dbpath1(db->dbfile,VM_PATH_RUNNING,ext) );
    fd = vmopen( buf, O_RDWR );
    if (fd >= 0) {
        Vm_Uch* bzip2;
        vmclose(fd);

	/* Can we find bzip2? */
	if (find_bzip2( &bzip2 )) {
	    sprintf(buf, "%s --decompress %s.bz2", bzip2, dbpath1(db->dbfile,VM_PATH_RUNNING,ext) );
	    vmsystem(buf);
	    db->wasCompressed = (Vm_Unt)TRUE;
	    return TRUE;
	}
    }

    return FALSE;
}

/************************************************************************/
/*-    dbindexClear -- Establish a valid empty bitmap set.		*/
/************************************************************************/

static void
dbindexClear(
    Vm_Db db
) {
    Vm_Uch  buf[ 256 ];
    int fd;
    strcpy( buf, dbpath1(db->dbfile,VM_PATH_RUNNING,".muq") );
    fd = open( buf, O_WRONLY | O_CREAT, S_IREAD | S_IWRITE );
    if (fd < 0) {
        #ifdef HAVE_STRERROR
	sprintf(buf,
	    "Couldn't create %s (%s)!",
	    dbpath1(db->dbfile,VM_PATH_RUNNING,".muq"),
	    strerror(errno)
	);
	#else
	sprintf(buf,
	    "Couldn't create %s (%d)!",
	    dbpath1(db->dbfile,VM_PATH_RUNNING,".muq"),
	    errno
	); 
	#endif
	VM_FATAL (buf);
    }

    /* Print an 8-byte (one 'long long') magic */
    /* value to help identify muq db files:    */
    write(fd,"muqmuq\n\0",8);

    /* Write endian-indicator: */
    dbsaveI64( fd, (Vm_Unt)1 );								/*  1 */

    /* Write a version number word: */
    dbsaveI64( fd, (Vm_Unt)1 );								/*  2 */

    /* Write db ID: */
    dbsaveI64( fd, db->dbfile );							/*  3 */

    /* Write eight zero words as reserve for any   */
    /* future needs -- pid of server locking the   */
    /* db, say:                                    */
    dbsaveI64( fd, (Vm_Unt)0 );								/*  4 */
    dbsaveI64( fd, (Vm_Unt)0 );								/*  5 */
    dbsaveI64( fd, (Vm_Unt)0 );								/*  6 */
    dbsaveI64( fd, (Vm_Unt)0 );								/*  7 */
    dbsaveI64( fd, (Vm_Unt)0 );								/*  8 */
    dbsaveI64( fd, (Vm_Unt)0 );								/*  9 */
    dbsaveI64( fd, (Vm_Unt)0 );								/* 10 */
    dbsaveI64( fd, (Vm_Unt)0 );								/* 11 */

    /* Write offset of start of trailer: 	*/
    dbsaveI64( fd, VM_QUART0_OFFSET );							/* 12 */

    /* Pad header out to 256 bytes long: */
    {   int    bytes_to_write = VM_QUART0_OFFSET - (8 + 12 * sizeof(Vm_Unt));
        Vm_Uch buf[ VM_QUART0_OFFSET ];
	Vm_Int i;
	for (i = VM_QUART0_OFFSET;   i --> 0;  )   buf[i] = 0;
	write(fd,buf,bytes_to_write);
	/* buggo, should check return value */
    }

    /* Write the global statistics: */
    dbsaveI64( fd, (Vm_Unt) db->s.root				   		);
    dbsaveI64( fd, (Vm_Unt) 0  /* Bytes_In_Useful_Data		*/ 		);
    dbsaveI64( fd, (Vm_Unt) 0  /* Bytes_Lost_In_Used_Blocks	*/ 		);
    dbsaveI64( fd, (Vm_Unt) 0  /* Bytes_Lost_In_Free_Blocks	*/ 		);
    dbsaveI64( fd, (Vm_Unt) 0  /* Used_Blocks			*/ 		);
    dbsaveI64( fd, (Vm_Unt) 0  /* Free_Blocks			*/ 		);
    dbsaveI64( fd, (Vm_Unt) db->s.consecutive_backups_to_keep	   		);
    dbsaveI64( fd, (Vm_Unt) 0  /* backups_done			*/		);
    dbsaveI64( fd, (Vm_Unt) db->s.logarithmic_backups		   		);
    dbsaveI64( fd, (Vm_Unt) db->s.bytes_allocated_since_last_garbage_collection	);
    dbsaveI64( fd, (Vm_Unt) db->s.next_unique_to_issue				);

    /* Write the per-db bitmaps &tc: */
    dbsaveI64( fd, (Vm_Unt) VM_INTBITS  /* bitmapSlots			*/	);
    dbsaveI64( fd, (Vm_Unt) 0  		/* bitmap			*/	);

    /* Write the per-octave bitmaps &tc: */
    dbsaveI64( fd, (Vm_Unt) VM_FIRST_OCTAVE					);
    dbsaveI64( fd, (Vm_Unt) VM_FINAL_OCTAVE					);


    {   Vm_Int octave;
	for (octave = VM_FIRST_OCTAVE;   octave <= VM_FINAL_OCTAVE;   ++octave) {

	    /* Figure number of slots per quart for this octave: */
            Vm_Unt bytesPerSlot  = vm_octave_capacity[ octave ];
	    Vm_Unt slotsPerQuart =  VM_QUART_BYTES / bytesPerSlot;

	    dbsaveI64( fd, (Vm_Unt) octave			/* Octave     */    );
            dbsaveI64( fd, (Vm_Unt) 0  				/* diskSlots  */    );
	    dbsaveI64( fd, (Vm_Unt) 0				/* bitmapSlots*/    );

            dbsaveI64( fd, (Vm_Unt) VM_BITMAPS			/*            */    );
            dbsaveI64( fd, (Vm_Unt) VM_BYTMAPS			/*            */    );

            dbsaveI64( fd, (Vm_Unt) bytesPerSlot		/* bytesPerSlot*/   );
	    dbsaveI64( fd, (Vm_Unt) slotsPerQuart		/* slotsPerQuart*/  );
	    dbsaveI64( fd, (Vm_Unt) 0				/* quarts     */    );

            dbsaveI64( fd, (Vm_Unt) 0				/* reserved0*/      );
            dbsaveI64( fd, (Vm_Unt) 0				/* reserved1*/      );
	    dbsaveI64( fd, (Vm_Unt) 0				/* reserved2*/      );
	    dbsaveI64( fd, (Vm_Unt) 0				/* reserved3*/      );
    }   }

    /* For root db, write count of secondary dbs: */
    if (!db->dbfile) dbsaveI64( fd, (Vm_Unt) 0 );

    vmclose(fd);

    dbindexCompress(db,VM_PATH_RUNNING,".muq");
}

/************************************************************************/
/*-    dbindexLoad -- Read in our bitmaps.				*/
/************************************************************************/

 /***********************************************************************/
 /*-    dbMagicLoad -- Read and check 8-byte 'magic' header in file.	*/
 /***********************************************************************/

static void
dbMagicLoad(
    Vm_Db   db,
    int     fd,
    Vm_Uch* ext	/* ".db" or ".muq" */
) {
    Vm_Uch  path[ 256 ];
    Vm_Uch buf[ 8 ];
    if (8 != dbread( buf, 8, fd)
    ||  (STRCMP(ext, == ,".muq") &&  STRCMP(buf, != ,"muqmuq\n"))
    ||  (STRCMP(ext, == ,".db" ) &&  STRCMP(buf, != ,"muq-db\n"))
    ){ 
	sprintf(path,"%s isn't a valid Muq db! ('%s')", dbpath1(db->dbfile,VM_PATH_RUNNING,ext), buf );
	VM_FATAL (path);
    }
}
  
 /***********************************************************************/
 /*-    dbVersionLoad -- Read and check 8-byte version/sex from file.	*/
 /***********************************************************************/

static void
dbVersionLoad(
    Vm_Db  db,
    int    fd,
    int*   swap
) {
    Vm_Uch  path[ 256 ];
    Vm_Unt endian  = dbloadI64(fd,0);
    Vm_Unt version = dbloadI64(fd,0);
    Vm_Unt dbfile  = dbloadI64(fd,0);

    /* Check endian-indicator: */
    *swap = (endian != (Vm_Unt)1);

    if (*swap) {
        endian  = vm_Reverse64( endian  );
	version = vm_Reverse64( version );
        dbfile  = vm_Reverse64( dbfile  );
	if (endian != (Vm_Unt)1) {
            endian  = vm_Reverse64( endian  );
	    sprintf(path,
		"%s has invalid 'endian' field #%" VM_X "!",
		dbpath1(db->dbfile,VM_PATH_RUNNING,".muq"),
		endian
	    );
	    VM_FATAL (path);
	}
    }

    if (version != (Vm_Unt)1) {
	sprintf(path,
	    "%s has unsupported version #%" VM_D "!",
	    dbpath1(db->dbfile,VM_PATH_RUNNING,".muq"),
	    version
	);
	VM_FATAL (path);
    }

    if (dbfile != db->dbfile) {
	sprintf(path,
	    "%s has wrong db ID -- x=%" VM_X " instead of x=%" VM_D,
	    dbpath1(db->dbfile,VM_PATH_RUNNING,".muq"),
	    dbfile,
	    db->dbfile
	);
	VM_FATAL (path);
    }
}
  
 /***********************************************************************/
 /*-    dbReserveLoad -- Read and ignore 8 zero words.			*/
 /***********************************************************************/

static void
dbReserveLoad(
    Vm_Db  db,
    int    fd,
    int    swap
) {
    /* These are reserve against future needs: */
    Vm_Int i0 = dbloadI64(fd,swap);
    Vm_Int i1 = dbloadI64(fd,swap);
    Vm_Int i2 = dbloadI64(fd,swap);
    Vm_Int i3 = dbloadI64(fd,swap);
    Vm_Int i4 = dbloadI64(fd,swap);
    Vm_Int i5 = dbloadI64(fd,swap);
    Vm_Int i6 = dbloadI64(fd,swap);
    Vm_Int i7 = dbloadI64(fd,swap);

    if (i0 | i1 | i2 | i3 | i4 | i5 | i6 | i7) {
        Vm_Uch  path[ 256 ];
	sprintf(
	    path,
	    "%s has bad reserved words -- not all zero\n",
	    dbpath1(db->dbfile,VM_PATH_RUNNING,".muq")
	);
        printf("Reserved word 0: %" VM_X "\n", i0);
        printf("Reserved word 1: %" VM_X "\n", i1);
        printf("Reserved word 2: %" VM_X "\n", i2);
        printf("Reserved word 3: %" VM_X "\n", i3);
        printf("Reserved word 4: %" VM_X "\n", i4);
        printf("Reserved word 5: %" VM_X "\n", i5);
        printf("Reserved word 6: %" VM_X "\n", i6);
        printf("Reserved word 7: %" VM_X "\n", i7);
	VM_FATAL (path);
    }
}
  
 /***********************************************************************/
 /*-    dbTrailerOffsetLoad -- Read trailer offset, seek to it.		*/
 /***********************************************************************/

static void
dbTrailerOffsetLoad(
    Vm_Db  db,
    int    fd,
    int    swap
) {
    Vm_Uch  path[ 256 ];
    Vm_Unt offset = dbloadI64(fd,swap);

    {   int rslt = lseek(fd,(off_t)offset, SEEK_SET );
	if (rslt==-1) {
	    sprintf(path,
		"Couldn't seek to trailer offset %" VM_X " in db file %s\n",
		offset,
		dbpath1(db->dbfile,VM_PATH_RUNNING,".muq")
	    );
	    VM_FATAL (path);
    }   }
    db->bytesInFile = offset;
}
  
 /***********************************************************************/
 /*-    dbStatsLoad -- Read in global statistics counters.		*/
 /***********************************************************************/

static void
dbStatsLoad(
    Vm_Db  db,
    int    fd,
    int    swap
) {

    db->s.root						= dbloadI64( fd, swap );
    db->s.bytes_in_useful_data				= dbloadI64( fd, swap );
    db->s.bytes_lost_in_used_blocks			= dbloadI64( fd, swap );
    db->s.bytes_in_free_blocks				= dbloadI64( fd, swap );
    db->s.used_blocks					= dbloadI64( fd, swap );
    db->s.free_blocks					= dbloadI64( fd, swap );
    db->s.consecutive_backups_to_keep			= dbloadI64( fd, swap );
    db->s.backups_done					= dbloadI64( fd, swap ) +1;
    db->s.logarithmic_backups				= dbloadI64( fd, swap );
    db->s.bytes_allocated_since_last_garbage_collection	= dbloadI64( fd, swap );
    db->s.next_unique_to_issue				= dbloadI64( fd, swap );

}

 /***********************************************************************/
 /*-    dbOctaveLoad -- Read one set of per-octave info from trailer.	*/
 /***********************************************************************/

static void
dbOctaveLoad(
    Vm_Db  db,
    int    fd,
    Vm_Unt octave,
    int    swap,
    Vm_Uch* ext
) {
    Octave   p = &db->o[ octave ];

    /* Read length of bitmap from file, also octave as a check: */
    if (dbloadI64(fd,swap) != octave) {
	VM_FATAL ("Trashed index file");
    }

    /* Allocate and fill our bitmap: */

    /* Read number of disk records allocated for this octave: */
    p->diskSlots      = dbloadI64(fd,swap);

    /* Read size in bits of allocation bitmap for this octave: */
    p->allocSlots    = dbloadI64(fd,swap);

    if ( ((int) dbloadI64(fd,swap)) != VM_BITMAPS) {
        VM_FATAL("unsupported BITMAPS value in dbfile");
    }

    if ( ((int) dbloadI64(fd,swap)) != VM_BYTMAPS) {
        VM_FATAL("unsupported BYTMAPS value in dbfile");
    }

    /* How many bytes per record for this octave (including size info)? */
    p->bytesPerSlot    = dbloadI64(fd,swap);

    /* How many records does this octave pack into one quart? */
    p->slotsPerQuart   = dbloadI64(fd,swap);

    /* How many quarts have been allocated for this octave? */
    p->quarts          = dbloadI64(fd,swap);

    /* Ignore four slots reserved for future expansion: */
    dbloadI64( fd, swap );
    dbloadI64( fd, swap );
    dbloadI64( fd, swap );
    dbloadI64( fd, swap );

    /* Allocate per-slot bitmaps and bytemaps: */
    if (!p->allocSlots) {
	int  i;
	for (i = VM_BITMAPS;   i --> 0;   )    p->bitmap[i]    = NULL;
	for (i = VM_BYTMAPS;   i --> 0;   )    p->bytmap[i]    = NULL;
        p->size.b           = NULL;
    } else {
	int  map;
	for (map = VM_BITMAPS;   map --> 0;   ) {
	    if (octave != VM_FINAL_OCTAVE   ||   map != ALLOC) {
                p->bitmap[map]    = (Vm_Unt*) alloc( p->allocSlots >> VM_LOG2_BYTEBITS );
	    }
	}
	for (map = VM_BYTMAPS;   map --> 0;   ) {
            p->bytmap[map]    = (Vm_Uch*) alloc( p->allocSlots                     );
	}
        p->size.b   = (Vm_Uch*) alloc( p->allocSlots * ((p->bytesPerSlot <= 128) ? 1 : VM_INTBYTES) );
    }

    /* Zero bitmaps: */
    {   int  map;
	for (map = VM_BITMAPS;   map --> 0;   ) {
	    if (octave != VM_FINAL_OCTAVE   ||   map != ALLOC) {
		Vm_Int  j;
		Vm_Unt*slot = p->bitmap[map];
		for (j = p->allocSlots >> VM_LOG2_INTBITS;  j --> 0;  ) {
		    slot[j] = 0;
		}
	    }
   	}
    }
    /* And bytemaps: */
    {   int  map;
	for (map = VM_BYTMAPS;   map --> 0;   ) {
            Vm_Int  j;
            Vm_Uch*slot = p->bytmap[map];
	    for (j = p->allocSlots;  j --> 0;  ) {
	        slot[j] = 0;
    }	}   }
    /* And size info: */
    if (p->bytesPerSlot <= 128) {
        Vm_Int  j;
        Vm_Uch*slot = p->size.b;
	for (j = p->allocSlots;  j --> 0;  ) {
	    slot[j] = 0;
    	}
    } else {
        Vm_Int  j;
        Vm_Int*slot = p->size.i;
	for (j = p->allocSlots;  j --> 0;  ) {
	    slot[j] = 0;
    	}
    }

    /* Read contents of bitmaps from file: */
    {   int  map;
	for (map = 0;   map < VM_BITMAPS;   ++map) {
	    if (octave != VM_FINAL_OCTAVE   ||   map != ALLOC) {
		Vm_Int  j;
		Vm_Unt*slot = p->bitmap[map];
		for (j = 0;   j < p->allocSlots >> VM_LOG2_INTBITS;  ++j) {
		    slot[j] = dbloadI64(fd,swap);
		}
            }
        }
    }

    /* Read contents of bytemaps from file: */
    {   int  map;
	for (map = 0;   map < VM_BYTMAPS;   ++map) {
            dbloadBytes(  p->bytmap[map], p->allocSlots, fd );
    }	}

    /* Read size info from file: */
    if (p->bytesPerSlot <= 128) {
        dbloadBytes( p->size.b, p->allocSlots, fd );
    } else {
        Vm_Unt j;
        Vm_Unt*slot = p->size.i;
	for (j = 0;   j < p->allocSlots;  ++j) {
	    slot[j] = dbloadI64(fd,swap);
     	}
    }

    /* Load quart offset table recording where our */
    /* quarts are located within the db file:      */
    if (p->quarts) {
	p->quartOffset   = (Vm_Unt*) malloc(
	    p->quarts * sizeof(Vm_Unt)
	);
    }
    /* Only .muq files contain (or need) */
    /* actual quartOffset[] information: */
    if (STRCMP(ext, == ,".db")) {
        Vm_Int  j;
	for (j = 0;   j < p->quarts;   ++j) {
	    p->quartOffset[j] = (Vm_Unt)0;
        }
    } else {
        Vm_Int  j;
	for (j = 0;   j < p->quarts;   ++j) {
	    p->quartOffset[j] = dbloadI64(fd,swap);
    }   }

    /* Count all free slots: */
    p->freeSlots = 0;
    if (octave != VM_FINAL_OCTAVE) {
	Vm_Int  j;
	for (j = p->diskSlots;   j --> 0; ) {
	    if (!getAllocBit(db,octave,j)) ++p->freeSlots;
    }   }

    /* Initialize our freecache: */
    p->freeCacheLen = 0;
    if (octave != VM_FINAL_OCTAVE)  cacheRefill( db, octave );
}

 /***********************************************************************/
 /*-    dbDbInfoLoad -- Read all per-db info from trailer.		*/
 /***********************************************************************/

static void
dbDbInfoLoad(
    Vm_Db   db,
    int     fd,
    int     swap,
    Vm_Uch* ext
) {
    db->quartAllocSlots    = dbloadI64( fd, swap );
    {   Vm_Int bitmapwords = db->quartAllocSlots >> VM_LOG2_INTBITS;
        Vm_Int bitmapbytes = bitmapwords * sizeof(Vm_Unt);
        db->quartAlloc     = (Vm_Unt*) alloc( bitmapbytes );
        {   Vm_Unt i;
	    for (i = 0;   i < bitmapwords;   ++i) {
		db->quartAlloc[i] = dbloadI64( fd, swap );
            }
	}
    }
}

 /***********************************************************************/
 /*-    dbOctavesLoad -- Read all per-octave info from trailer.		*/
 /***********************************************************************/

static void
dbOctavesLoad(
    Vm_Db   db,
    int     fd,
    int     swap,
    Vm_Uch* ext
) {
    Vm_Int first = dbloadI64( fd, swap );
    Vm_Int final = dbloadI64( fd, swap );

    if (first != VM_FIRST_OCTAVE
    ||  final != VM_FINAL_OCTAVE
    ){
	VM_FATAL ("Bad index file");
    }
    {   Vm_Unt  octave;
	for (octave = VM_FIRST_OCTAVE;   octave <= VM_FINAL_OCTAVE;   ++octave) {
	    dbOctaveLoad( db, fd, octave, swap, ext );
}   }   }

 /***********************************************************************/
 /*-    dbSecondaryDbsLoad -- Load in non-primary db files.		*/
 /***********************************************************************/

static void
dbSecondaryDbsLoad(
    Vm_Db   db,
    int     fd,
    int     swap,
    Vm_Uch* ext
) {
    /* If this is the root db, read appended a list of loaded dbs: */
    if (!db->dbfile) {

        /* Read count of number of secondary dbs: */
	Vm_Int dbcount = dbloadI64(fd,swap);

	/* Read dbfile values proper: */
	Vm_Int i;
        /* Write db ids: */
        for (i = 0;   i < dbcount;   ++i) {
	    Vm_Int dbfile = dbloadI64(fd,swap);
            Vm_Db db   = dbnew(dbfile);	/* Make new Vm_A_Db. */
	    dbtrailerLoad( db, fd, swap, ext );
	}
    }
}

 /***********************************************************************/
 /*-    dbfileExists -- Test to see if file exists.			*/
 /***********************************************************************/

int
dbfileExists(
    Vm_Unt id,
    Vm_Uch*ext  /* ".db" or ".muq" */
) {
    Vm_Uch  path[ 256 ];
    int     fd;

    /* Test for uncompressed version: */
    strcpy(path, dbpath1(id,VM_PATH_CURRENT,ext) );
    fd = vmopen( path, O_RDWR );
    if (fd >= 0) {
        vmclose(fd);
        return (Vm_Unt)1;
    }

    /* Test for compressed version: */
    sprintf(path, "%s.gz", dbpath1(id,VM_PATH_CURRENT,ext) );
    fd = vmopen( path, O_RDWR );
    if (fd >= 0) {
        vmclose(fd);
        return (Vm_Unt)2;
    }
    sprintf(path, "%s.lzo", dbpath1(id,VM_PATH_CURRENT,ext) );
    fd = vmopen( path, O_RDWR );
    if (fd >= 0) {
        vmclose(fd);
        return (Vm_Unt)2;
    }
    sprintf(path, "%s.bz2", dbpath1(id,VM_PATH_CURRENT,ext) );
    fd = vmopen( path, O_RDWR );
    if (fd >= 0) {
        vmclose(fd);
        return (Vm_Unt)2;
    }
    
    /* Test for uncompressed version: */
    strcpy(path, dbpath1(id,VM_PATH_RUNNING,ext) );
    fd = vmopen( path, O_RDWR );
    if (fd >= 0) {
        vmclose(fd);
        return (Vm_Unt)1;
    }

    /* Test for compressed version: */
    sprintf(path, "%s.gz", dbpath1(id,VM_PATH_RUNNING,ext) );
    fd = vmopen( path, O_RDWR );
    if (fd >= 0) {
        vmclose(fd);
        return (Vm_Unt)2;
    }
    sprintf(path, "%s.lzo", dbpath1(id,VM_PATH_RUNNING,ext) );
    fd = vmopen( path, O_RDWR );
    if (fd >= 0) {
        vmclose(fd);
        return (Vm_Unt)2;
    }
    sprintf(path, "%s.bz2", dbpath1(id,VM_PATH_RUNNING,ext) );
    fd = vmopen( path, O_RDWR );
    if (fd >= 0) {
        vmclose(fd);
        return (Vm_Unt)2;
    }
    
    return FALSE;
}

 /***********************************************************************/
 /*-    dbtrailerLoad -- Read contents of index file into ram.		*/
 /***********************************************************************/

static void
dbtrailerLoad(
    Vm_Db   db,
    int     fd,
    int     swap,
    Vm_Uch* ext
) {
    /* Read the trailer statistics: */
    dbStatsLoad( db, fd, swap );

    /* Read per-db info from trailer: */
    dbDbInfoLoad( db, fd, swap, ext );

    /* Read per-octave info from trailer: */
    dbOctavesLoad( db, fd, swap, ext );

    /* Read info on secondary dbs: */
    dbSecondaryDbsLoad( db, fd, swap, ext );

    /* Um, what's the cleanest way to check for eof here?    */
    /* if (-1 != fgetc(fd)) VM_FATAL ("Trashed index file"); */
    /* (We should be at eof at this point.)                  */
}

 /***********************************************************************/
 /*-    dbindexLoad -- Read contents of index file into ram.		*/
 /***********************************************************************/

static void
dbindexLoad(
    Vm_Db   db,
    Vm_Uch* ext,
    int   *pswap
) {
    Vm_Uch  path[ 256 ];
    int     fd;

    #ifdef VERBOSE
    if (!muq_Is_In_Daemon_Mode) {
	fprintf(stderr,
	    "Opening db %s...\n",
	    vm_DbId_To_Asciz( db->dbfile )
	);
    }
    #endif

    sprintf(path, dbpath1(db->dbfile,VM_PATH_RUNNING,ext) );

    db->wasCompressed = (Vm_Unt)FALSE;

    fd = vmopen( path, O_RDWR );

    /* If we couldn't find an uncompressed version of the */
    /* db, see if a compressed version of it exists:      */ 
    if (fd < 0) {

	Vm_Uch buf[256];
	if (!dbindexDecompress(db,ext) || ((fd = vmopen( path, O_RDWR )) < 0)) {
	    #ifdef HAVE_STRERROR
	    sprintf(buf,
		"Couldn't open %s (%s)!",
		path,
		strerror(errno)
	    );
	    #else
	    sprintf(buf,
		"Couldn't open %s (%d)!",
		path,
		errno
	    );
	    #endif
	    VM_FATAL (buf);
	}
    }

    /* Read and check the 8-byte 'magic' */
    /* file header value ("muqmuq\n\0"): */
    dbMagicLoad( db, fd, ext );

    /* Read and check the 8-byte version */
    /* file header value (must be 1),    */
    /* the byte-sex indicator, and the   */
    /* db->dbfile value:                 */
    dbVersionLoad( db, fd, pswap );

    /* Ignore 8 words reserved for       */
    /* future expansion:                 */
    dbReserveLoad( db, fd, *pswap );

    /* Read the 8-byte trailer-offset value, and seek to trailer: */
    dbTrailerOffsetLoad( db, fd, *pswap );

    /* Read the trailer: */
    dbtrailerLoad( db, fd, *pswap, ext );

    /* Publish index file file descriptor: */
    db->fileDescriptor = fd;
}

/************************************************************************/
/*-    dbtrailerSave -- Write bitmaps to disk.				*/
/************************************************************************/

static void
dbtrailerSave(
    Vm_Db   db,
    int     fd,
    Vm_Uch* magic		/* "muqmuq\n\0" or "muq-db\n\0" */
) {

    /* Write global statistics: */
    dbsaveI64( fd, (Vm_Unt) db->s.root				   		);	/* 12 */
    dbsaveI64( fd, (Vm_Unt) db->s.bytes_in_useful_data		 		);	/* 13 */
    dbsaveI64( fd, (Vm_Unt) db->s.bytes_lost_in_used_blocks	 		);	/* 14 */
    dbsaveI64( fd, (Vm_Unt) db->s.bytes_in_free_blocks	 			);	/* 15 */
    dbsaveI64( fd, (Vm_Unt) db->s.used_blocks			 		);	/* 16 */
    dbsaveI64( fd, (Vm_Unt) db->s.free_blocks			 		);	/* 17 */
    dbsaveI64( fd, (Vm_Unt) db->s.consecutive_backups_to_keep	   		);	/* 18 */
    dbsaveI64( fd, (Vm_Unt) db->s.backups_done					);	/* 19 */
    dbsaveI64( fd, (Vm_Unt) db->s.logarithmic_backups		   		);	/* 20 */
    dbsaveI64( fd, (Vm_Unt) db->s.bytes_allocated_since_last_garbage_collection	);	/* 21 */
    dbsaveI64( fd, (Vm_Unt) db->s.next_unique_to_issue				);	/* 22 */

    /* Write per-db quart allocation map: */
    dbsaveI64( fd, (Vm_Unt) db->quartAllocSlots					);
    {   Vm_Int statuswords = db->quartAllocSlots >> VM_LOG2_INTBITS;
	Vm_Int i;
	for (i = 0;   i < statuswords;   ++i) {
	    dbsaveI64( fd, db->quartAlloc[i]	);
    }	}

    /* Summarize octaves present in index.new: */
    dbsaveI64( fd, (Vm_Unt) VM_FIRST_OCTAVE					);
    dbsaveI64( fd, (Vm_Unt) VM_FINAL_OCTAVE					);

    /* For each octave, write header giving number of bits	*/
    /* in octave bitmap, followed by binary dump of bitmap:	*/
    {   Vm_Int octave;
	for (octave = VM_FIRST_OCTAVE;   octave <= VM_FINAL_OCTAVE;   ++octave) {
	    Vm_Int j;
	    Octave  p = &db->o[octave];
	    Vm_Int words_in_map= p->allocSlots >> VM_LOG2_INTBITS;
	    /* Write a bitmap for file: */
	    dbsaveI64( fd, (Vm_Unt) octave		);
	    dbsaveI64( fd, (Vm_Unt) p->diskSlots	);
	    dbsaveI64( fd, (Vm_Unt) p->allocSlots	);

	    /* Dump per-octave parameters: */
	    dbsaveI64( fd, (Vm_Unt) VM_BITMAPS          );
	    dbsaveI64( fd, (Vm_Unt) VM_BYTMAPS          );
	    dbsaveI64( fd, (Vm_Unt) p->bytesPerSlot     );
	    dbsaveI64( fd, (Vm_Unt) p->slotsPerQuart	);
	    dbsaveI64( fd, (Vm_Unt) p->quarts           );

	    /* Dump four slots reserved for future expansion: */
            dbsaveI64( fd, (Vm_Unt) 0			);
            dbsaveI64( fd, (Vm_Unt) 0			);
	    dbsaveI64( fd, (Vm_Unt) 0			);
	    dbsaveI64( fd, (Vm_Unt) 0			);

	    /* Dump octave bitmaps: */
	    {   int  map;
		for (map = 0;   map < VM_BITMAPS;   ++map) {
		    if (octave != VM_FINAL_OCTAVE   ||   map != ALLOC) {
			Vm_Int*slot = p->bitmap[map];
			for (j = 0;   j < words_in_map;   ++j) {
			    dbsaveI64( fd, slot[j]	);
			}
	            }
	        }
	    }

	    /* Dump octave bytmaps: */
	    {   int  map;
		for (map = 0;   map < VM_BYTMAPS;   ++map) {
	            dbsavebytes(fd, p->bytmap[map], p->allocSlots );
	    }	}

	    /* Dump size info: */
    	    if (p->bytesPerSlot <= 128) {
	        dbsavebytes(fd, p->size.b, p->allocSlots );
	    } else {
	        Vm_Int*slot        = p->size.i;
	        for (j = 0;   j < p->allocSlots;   ++j) {
		    dbsaveI64( fd, slot[j]	);
	        }
	    }

	    /* Only for .muq files, not .db files: */
	    if (magic[3] == 'm') {
	        /* Dump quart offset table: */
		for (j = 0;   j < p->quarts;   ++j) {
		    dbsaveI64( fd, p->quartOffset[j]);
                }
            }
        }
    }

    /* If this is the root db, append a list of loaded dbs: */
    if (!db->dbfile) {

        /* Count number of dbs loaded: */
	Vm_Int dbcount = 0;
	Vm_Db db;
        for (db = vm_Root_Db->next;   db;   db = db->next)  ++dbcount;

        /* Write count of auxilliary dbs: */	
	dbsaveI64( fd, dbcount );

        /* Write db ids: */
        for (db = vm_Root_Db->next;   db;   db = db->next) {
	    dbsaveI64( fd, db->dbfile);
            dbtrailerSave( db, fd, magic );
	}
    }
}

/************************************************************************/
/*-    dbquartsRead -- Read all quarts in db from disk.			*/
/************************************************************************/

static void
dbquartsRead(
    Vm_Db db,
    int   fd
) {
    /* Over all quart-per-slot octaves in db:  */
    Vm_Int octave;
    for (octave = VM_FIRST_OCTAVE;   octave < VM_FINAL_OCTAVE;   ++octave) {

        /* Over all quarts in octave: */
        Vm_Int slot;
	for (slot = 0;   slot < db->o[octave].quarts;   ++slot) {

	    Vm_Uch buf[ VM_QUART_BYTES ];

	    /* Read quart from .db file: */
            dbread( buf, VM_QUART_BYTES, fd );
	    /* Allocate a quart: */
	    db->o[octave].quartOffset[slot] = quartAlloc( vm_Root_Db );

	    /* Write quart to main db (.muq file): */
	    dbfileReadOrWrite(
		db        ,
		db->o[octave].quartOffset[slot], 	/* fileOffset */
		buf       ,
		VM_QUART_BYTES,
		VM_SEND
	    );
	}
    }



    /* FINAL_OCTAVE is a special case because it can have  */
    /* multiple quarts per quartOffset[] slot, in general. */

    /* Over all slots in FINAL_OCTAVE's quartOffset[] array: */
    {   Vm_Int slot;
	for (slot = 0;   slot < db->o[VM_FINAL_OCTAVE].quarts;   ++slot) {

	    /* Allocate needed number of quarts for this slot: */
	    Vm_Int len    = db->o[VM_FINAL_OCTAVE].size.i[slot];
	    Vm_Int quarts = (len + (VM_QUART_BYTES-1)) >> VM_LOG2_QUART_BYTES;
	    Vm_Int q;
	    db->o[octave].quartOffset[slot] = quartsAlloc( vm_Root_Db, quarts );

 	    /* Over all quarts allocated for this slot: */
	    for   (q = 0;   q < quarts;   ++q) {

		/* Read quart from .db file: */
		Vm_Uch  buf[ VM_QUART_BYTES ];
                dbread( buf, VM_QUART_BYTES, fd );

	        /* Write quart to main db (.muq file): */
		dbfileReadOrWrite(
		    db             ,
		    db->o[VM_FINAL_OCTAVE].quartOffset[slot]   +   q * VM_QUART_BYTES, /* fileOffset */
		    buf            ,
		    VM_QUART_BYTES ,
		    VM_SEND
		);
	    }
	}
    }
}

/************************************************************************/
/*-    dbquartsSave -- Write all quarts in db to disk.			*/
/************************************************************************/

static Vm_Int
dbquartsSave(
    Vm_Db db,
    int   fd
) {
    Vm_Int bytesInFile = VM_QUART0_OFFSET;

    /* Over all quart-per-slot octaves in db:  */
    Vm_Int octave;
    for (octave = VM_FIRST_OCTAVE;   octave < VM_FINAL_OCTAVE;   ++octave) {

        /* Over all quarts in octave: */
        Vm_Int slot;
	for (slot = 0;   slot < db->o[octave].quarts;   ++slot) {

	    /* Read quart from current db: */
	    Vm_Uch buf[ VM_QUART_BYTES ];
	    Vm_Unt fileOffset = db->o[octave].quartOffset[slot];
	    dbfileReadOrWrite(
		db        ,
		fileOffset,
		buf       ,
		VM_QUART_BYTES,
		VM_READ
	    );

	    /* Write quart to new db: */
            write( fd, buf, VM_QUART_BYTES );	/* buggo, no check for write-failed */

	    /* Tot up bytes written: */
	    bytesInFile += VM_QUART_BYTES;
	}
    }



    /* FINAL_OCTAVE is a special case 'cause it has multiple */
    /* quarts per quartOffset[] slot, in general:            */

    /* Over all slots in this octave's quartOffset[] array: */
    {   Vm_Int slot;
	for (slot = 0;   slot < db->o[VM_FINAL_OCTAVE].quarts;   ++slot) {

 	    /* Over all quarts allocated for this slot: */
	    Vm_Int len    = db->o[VM_FINAL_OCTAVE].size.i[slot];
	    Vm_Int quarts = (len + (VM_QUART_BYTES-1)) >> VM_LOG2_QUART_BYTES;
	    Vm_Int q;
	    for   (q = 0;   q < quarts;   ++q) {

		/* Read quart from current db: */
		Vm_Uch buf[ VM_QUART_BYTES ];
		Vm_Unt fileOffset = db->o[VM_FINAL_OCTAVE].quartOffset[slot]   +   q * VM_QUART_BYTES;
		dbfileReadOrWrite(
		    db             ,
		    fileOffset     ,
		    buf            ,
		    VM_QUART_BYTES ,
		    VM_READ
		);

		/* Write quart to new db: */
		write( fd, buf, VM_QUART_BYTES );	/* buggo, no check for write-failed */

		/* Tot up bytes written: */
		bytesInFile += VM_QUART_BYTES;
	    }
	}
    }


    return bytesInFile;
}

/************************************************************************/
/*-    dbindexSave -- Write bitmaps to disk.				*/
/************************************************************************/

static void
dbindexSave(
    Vm_Db  db,
    int    fd,
    Vm_Uch*magic,		/* "muqmuq\n\0" or "muq-db\n\0" */
    Vm_Unt bytesInFile
) {

    /* Seek back to start of db file: */
    lseek( fd, 0, SEEK_SET );

    /* Print an 8-byte (one 'long long') magic */
    /* value to help identify muq db files:    */
    write( fd, magic, 8 );

    /* Write endian-indicator: */
    dbsaveI64( fd, (Vm_Unt)1 );								/*  1 */

    /* Write a version number word: */
    dbsaveI64( fd, (Vm_Unt)1 );								/*  2 */

    /* Write db->dbfile: */
    dbsaveI64( fd, db->dbfile );							/*  3 */

    /* Write eight zero words, reserving space for */
    /* future contingencies:                       */
    dbsaveI64( fd, (Vm_Unt)0 );								/*  4 */
    dbsaveI64( fd, (Vm_Unt)0 );								/*  5 */
    dbsaveI64( fd, (Vm_Unt)0 );								/*  6 */
    dbsaveI64( fd, (Vm_Unt)0 );								/*  7 */
    dbsaveI64( fd, (Vm_Unt)0 );								/*  8 */
    dbsaveI64( fd, (Vm_Unt)0 );								/*  9 */
    dbsaveI64( fd, (Vm_Unt)0 );								/* 10 */
    dbsaveI64( fd, (Vm_Unt)0 );								/* 11 */

    /* Write offset of start of trailer: */
    dbsaveI64( fd, bytesInFile );							/* 12 */

    /* Pad header out to 256 bytes: */
    {   int    bytes_to_write = VM_QUART0_OFFSET - (8 + 12 * sizeof(Vm_Unt));
        Vm_Uch buf[ VM_QUART0_OFFSET ];
	Vm_Int i;
	for (i = VM_QUART0_OFFSET;   i --> 0;  )   buf[i] = 0;
	write(fd,buf,bytes_to_write);
	/* buggo, should check return value */
    }

    /* Seek file to location of trailer: */
    lseek( fd,  bytesInFile, SEEK_SET );

    dbtrailerSave( db, fd, magic );

    vmclose(fd);
}


/************************************************************************/
/*-    bitreverse_dbid							*/
/************************************************************************/

#ifdef UNUSED
static Vm_Int
bitreverse_dbid(
    Vm_Int id
) {
    Vm_Int dstbit = VM_DBFILE_BITS;
    Vm_Int srcbit =              0;
    Vm_Int result = 0;
    for(;   dstbit --> 0;   ++srcbit) {
	result |= ((id >> srcbit) & 1)  <<  dstbit;
    }
    return result;
}
#endif

/************************************************************************/
/*-    vm_Asciz_To_DbId							*/
/************************************************************************/

/* Can't use standard isupper/islower because we depend on */
/* exactly 26 consecutive alphabetic characters here:      */
#undef  isUpper
#undef  isLower
#define isUpper(a) ((a) >= 'A' && (a) <= 'Z')
#define isLower(a) ((a) >= 'a' && (a) <= 'z')

Vm_Int
vm_Asciz_To_DbId(
    Vm_Uch*asciz
){
    /*****************************************************************/
    /* Convert printable ascii representation of dbId to internal    */
    /* 21-bit binary representation of dbId, handling insane inputs  */
    /* gracefully.                                                   */
    /*                                                               */
    /* The printable ascii representation should be either all upper */
    /* case letters (system db files) or all lowercase letters (user */
    /* db files), except that dashes are allowed in either.          */
    /*                                                               */
    /* The internal binary representation is 21 bits, with the high  */
    /* bit set for user db files and clear for system db files.      */
    /*                                                               */
    /* The transformation is via a radix-27 representation, using    */
    /* one of the alphabets                                          */
    /*    "-ABCDEFGHIJKLMNOPQRSTUVWXYZ"				     */
    /*    "-abcdefghijklmnopqrstuvwxyz"				     */
    /*****************************************************************/

    Vm_Uch buf[8];

    Vm_Int uppersSeen = 0;
    Vm_Int lowersSeen = 0;
    Vm_Int i;

    /* Special case for readability: */
    if (STRCMP(asciz, == ,"ROOTDB"))   return 0;

    /* Decide whether given string is mostly upper or lower case: */
    for (i = 0;  i < 5;   ++i) {

        /* Make local copy of given string: */
        buf[i] = asciz[i];

        /* Null out everything after first null: */
        if (i && !buf[i-1]) buf[i]=buf[i-1];

	/* Count upper vs lower case: */
	if (buf[i]) {
	    lowersSeen += (isLower(buf[i]) != 0);
	    uppersSeen += (isUpper(buf[i]) != 0);
	}
    }

    /* Clear string to base-27 representation: */
    for (i = 0;   i < 5;   ++i) {
	if      (isUpper(buf[i])) buf[i] -= 'A'-1;
	else if (isLower(buf[i])) buf[i] -= 'a'-1;
	else                      buf[i]  ='\0';
    }
    /* Fifth letter can only be A or -: */
    if (buf[4] > 1) buf[4]='\0';

    {   Vm_Int result = 0;
        for (i = 0;  i < 4;   ++i) {
	    result = result * 27 + buf[i];
	}

	/* Final tweak to provide an ascii representation */
	/* for all available binary db id numbers:        */
        if (buf[4]) {
	    if (result +  ((Vm_Unt)27*27*27*27) < ((Vm_Unt)1 << (VM_DBFILE_BITS-1))) {
	        result += (27*27*27*27);
	}   }

	/* Mask to available precision. This should be unneeded: */
	result &= VM_DBFILE_MASK>>1;

	/* Set high bit if this is a user dbfile: */
	result |= (lowersSeen > uppersSeen) << (VM_DBFILE_BITS-1); 

        return result;
    }
}

/************************************************************************/
/*-    vm_DbId_To_Asciz							*/
/************************************************************************/

Vm_Uch*
vm_DbId_To_Asciz(
    Vm_Int id
){
    static Vm_Uch dbname[7];
    
    /* Map 21-bit "id" (database name) to an ascii representation: */
    static Vm_Uch* hi = "-ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    static Vm_Uch* lo = "-abcdefghijklmnopqrstuvwxyz";
    Vm_Uch* map ;

    /* Special case for readability: */
    if (!id) {
	strcpy(dbname,"ROOTDB");
	return dbname;
    }

    /* Upper/lower case is controlled by high bit on id: */
    if (id & (1 << (VM_DBFILE_BITS-1))) {
        /* High bit is set (user db), map it to lower-case chars: */
	map = lo;
    } else {
        /* High bit is clear (library db), map it to upper-case chars: */
	map = hi;
    }

    /* Clear high bit on id: */
    id &= VM_DBFILE_MASK>>1;

    /* Construct the name: */
    dbname[3] = map[id % 27];	id /= 27;
    dbname[2] = map[id % 27];	id /= 27;
    dbname[1] = map[id % 27];	id /= 27;
    dbname[0] = map[id % 27];	id /= 27;
    /* Final tweak to provide an ascii representation */
    /* for all available binary db id numbers:        */
    dbname[4] = (id ? (map==hi?'A':'a') : '-');
    dbname[5] = '-';
    dbname[6] = '\0';

    /* Drop terminal dashes: */
    {   int i;
        for (i = 6;  i && dbname[i-1]=='-';  --i) {
	    dbname[i-1] = '\0';
    }   }    

    return dbname;
}


/************************************************************************/
/*-    dbpath1, dbpath2 -- Construct db pathname from dbid &tc		*/
/************************************************************************/

Vm_Uch*
dbpath(
    Vm_Uch* buf,
    Vm_Int id,
    Vm_Int gen,
    Vm_Uch* ext
){
    unsigned char dbname[8];
    strcpy( dbname, vm_DbId_To_Asciz(id) );

    switch (gen) {
    case VM_PATH_RUNNING: sprintf(buf, "%s-RUNNING-%s%s",     vm_Octave_File_Path, dbname,      ext ); break;
    case VM_PATH_CURRENT: sprintf(buf, "%s-CURRENT-%s%s",     vm_Octave_File_Path, dbname,      ext ); break;
    default:              sprintf(buf, "%s-%07" VM_D "-%s%s", vm_Octave_File_Path, gen, dbname, ext ); break;
    }

    return buf;
}

static Vm_Uch*
dbpath1(
    Vm_Int id,
    Vm_Int gen,
    Vm_Uch* ext
) {
    static Vm_Uch buf[ 2048 ];
    return dbpath( buf, id, gen, ext );
}

/* dbpath2 is identical except for name, it allows constructing two */
/* paths in one expression, as when making up a 'cp' shell command: */
static Vm_Uch*
dbpath2(
    Vm_Int id,
    Vm_Int gen,
    Vm_Uch* ext
) {
    static Vm_Uch buf[ 2048 ];
    return dbpath( buf, id, gen, ext );
}

/************************************************************************/
/*-    quartFindFree -- Find free quart in bitmap			*/
/************************************************************************/

static Vm_Unt
quartFindFree(
    Vm_Db        db,
    Vm_Unt* quartNo
) {
    /****************************************/
    /* Search the bitmaps for a free quart. */
    /****************************************/

    /* Figure out how big bitmap is: */
    Vm_Unt i;
    Vm_Unt statusWords = vm_Root_Db->quartAllocSlots >> VM_LOG2_INTBITS;

    /* Try to find a bitmap word with a zero bit: */
    for (i = 0;   i < statusWords;   ++i) {
	Vm_Unt word = vm_Root_Db->quartAlloc[i];
	if (word != ~(Vm_Unt)0) {

	    /* Find the zero bit in the bitmap word: */
#ifdef NAIVE
	    Vm_Unt j;
	    for (j = 0;   j < VM_INTBITS;   ++j) {
		Vm_Unt mask = ((Vm_Unt)1) << j;
	        if (!(word & mask)) {

		    /* Mark the quart as allocated, by      */
		    /* flipping its 0 bit to a 1 in bitmap: */
		    vm_Root_Db->quartAlloc[i] = (word | mask);

		    /* Return the quart number allocated: */
		    *quartNo = (i * VM_INTBITS) + j;

		    /* Return success: */
		    return TRUE;
		}
	    }
#else
	    /* Construct a mask which is 0 everywhere  */
	    /* except for the bit corresponding to the */
	    /* first nonzero bit in 'word':            */
	    Vm_Unt mask = (((word+1)^word) >> 1) + 1;

	    /* Mark the quart as allocated, by      */
	    /* flipping its 0 bit to a 1 in bitmap: */
	    vm_Root_Db->quartAlloc[i] = (word | mask);

	    /* Return the quart number allocated: */
	    {   Vm_Unt j=0;
		Vm_Unt m;
		if (m = (mask >> 32)) { mask = m; j += 32; }
		if (m = (mask >> 16)) { mask = m; j += 16; }
		if (m = (mask >>  8)) { mask = m; j +=  8; }
		if (m = (mask >>  4)) { mask = m; j +=  4; }
		if (m = (mask >>  2)) { mask = m; j +=  2; }
		if (m = (mask >>  1)) { mask = m; j +=  1; }
		/* Last four above should likely become a */
		/* table lookup operation at some point.  */
		
		*quartNo = (i * VM_INTBITS) + j;

		/* Return success: */
		return TRUE;
	    }
#endif
	}
    }

    /* No zero bits in bitmap, return failure: */
    return FALSE;
}

/************************************************************************/
/*-    quartsFindFree -- Find sequence of free quarts in bitmap		*/
/************************************************************************/

static Vm_Unt
quarts_find_free(
    Vm_Db        db,
    Vm_Unt* quartNo,
    Vm_Unt        n,
    Vm_Int        do_alloc
) {
    /****************************************/
    /* Search the bitmaps for a free quart. */
    /****************************************/

    /* Figure out how big bitmap is: */
    Vm_Unt w;
    Vm_Unt statusWords = vm_Root_Db->quartAllocSlots >> VM_LOG2_INTBITS;

    /* Make an n-bit mask -- 111 if n==3: */
    Vm_Unt nbits = ((Vm_Unt)1 << (n & (VM_INTBITS-1))) -1;	/* < 1 word of mask */

    /* Handle case where N is less than a quarterword: */
    if (n < (VM_INTBITS/4)) {

	/* Try to find a bitmap word with a zero bit: */
	for (w = 0;   w < statusWords;   ++w) {

	    /* Over all plausible n-bit positions within the word: */
	    Vm_Unt mask;
	    Vm_Unt word;
	    for   (word = vm_Root_Db->quartAlloc[w];  word != ~(Vm_Unt)0;  word |= mask) {
		int  bit=0;
		Vm_Unt m;
		Vm_Unt t;

		/* Find first zero bit in the bitmap word: */
		mask  = m = (((word+1)^word) >> 1) + 1;
		if (t = (m >> 32)) {   m = t;   bit += 32;   }
		if (t = (m >> 16)) {   m = t;   bit += 16;   }
		if (t = (m >>  8)) {   m = t;   bit +=  8;   }  /* These last   */
		if (t = (m >>  4)) {   m = t;   bit +=  4;   }  /* four should  */
		if (t = (m >>  2)) {   m = t;   bit +=  2;   }  /* become one   */
		if (t = (m >>  1)) {   m = t;   bit +=  1;   }  /* table lookup.*/

		/* Check for N consecutive zero bits: */

		/* Done with word if there are  */
		/* less than N bits left in it: */
		if (n + bit > VM_INTBITS)   break;

		/* If next N bits are zero: */
		t = nbits << bit;
		if (!(t & word)) {

		    /* Mark those quarts as allocated: */
		    if (do_alloc)   vm_Root_Db->quartAlloc[w] |= t;
/*		    if (do_alloc)   vm_Root_Db->quartAlloc[w]  = (word | t);      NOT THIS!! */

		    /* Return success: */
		    *quartNo = (w * VM_INTBITS) + bit;
		    return TRUE;
		}
	    }
	    /* NB: Might be construed as a bug that above code will never */
	    /* allocate across word boundaries.  Feel free to code up and */
	    /* submit a patch! :)                                         */
	}
	/* Return failure: */
	return FALSE;
    }

    /* N at least a quarterword but less than a halfword: */
    if (n <= (VM_INTBITS/2)) {
        /* Allocate halfword aligned. This might or might not  */
        /* be a good idea, but it is easy to code. :)          */
	for (w = 0;   w < statusWords;   ++w) {
	    Vm_Unt word = vm_Root_Db->quartAlloc[w];
	    if (!(word & nbits)) {
		if (do_alloc) 	vm_Root_Db->quartAlloc[w] = (word | nbits);
		*quartNo = w * VM_INTBITS;
		return TRUE;
	    }
	    if (!(word & (nbits << (VM_INTBITS/2)))) {
		if (do_alloc)   vm_Root_Db->quartAlloc[w] = (word | (nbits << (VM_INTBITS/2)));
		*quartNo = w * VM_INTBITS + (VM_INTBITS/2);
		return TRUE;
	    }
	}
	/* Fail: */
	return FALSE;
    }

    /* N less than a word, and greater than a halfword: */
    if (n < VM_INTBITS) {
        /* Allocate word-aligned: */
	for (w = 0;   w < statusWords;   ++w) {
	    Vm_Unt word = vm_Root_Db->quartAlloc[w];
	    if (!(word & nbits)) {
		if (do_alloc)   vm_Root_Db->quartAlloc[w] = (word | nbits);
		*quartNo = w * VM_INTBITS;
		return TRUE;
	    }
	}
	/* Fail: */
	return FALSE;
    }

    /* N exactly equal to wordsize: */
    if (n == VM_INTBITS) {
        /* Allocate aligned: */
	for (w = 0;   w < statusWords;   ++w) {
	    Vm_Unt word = vm_Root_Db->quartAlloc[w];
	    if (!word) {
	        if (do_alloc)   vm_Root_Db->quartAlloc[w] = ~(Vm_Unt)0;
		*quartNo = w * VM_INTBITS;
		return TRUE;
	    }
	}
	/* Fail: */
	return FALSE;
    }

    /* Case where N is a multiple of wordsize: */
    if (!(n & (VM_INTBITS-1))) {
        Vm_Int zero_words_needed = n >> VM_LOG2_INTBITS;
	Vm_Int consecutive_zero_words = 0;

        /* Allocate word-aligned: */
	for (w = 0;   w < statusWords;   ++w) {
	    Vm_Unt word = vm_Root_Db->quartAlloc[w];
	    if (word) {
	        consecutive_zero_words = 0;
		continue;
	    }
	    if (++consecutive_zero_words == zero_words_needed) {
		*quartNo = (w - (consecutive_zero_words-1)) * VM_INTBITS;
	        if (do_alloc)   while (consecutive_zero_words --> 0) {
		    vm_Root_Db->quartAlloc[w-consecutive_zero_words] = ~(Vm_Unt)0;
		}
		return TRUE;
	    }
	}
	/* Return failure: */
	return FALSE;
    }

    /* N bigger than a word and not a multiple of wordsize: */
    {   Vm_Int zero_words_needed = n >> VM_LOG2_INTBITS;
	Vm_Int consecutive_zero_words = 0;

        /* Allocate word-aligned: */
	for (w = 0;   w < statusWords;   ++w) {
	    Vm_Unt word = vm_Root_Db->quartAlloc[w];
	    if (!word) {
	        if (++consecutive_zero_words > zero_words_needed) {
		    *quartNo = (w - (consecutive_zero_words-1)) * VM_INTBITS;
		    if (do_alloc)   while (consecutive_zero_words --> 1) {
			vm_Root_Db->quartAlloc[w-consecutive_zero_words] = ~(Vm_Unt)0;
		    }
		    if (do_alloc)   vm_Root_Db->quartAlloc[w] = nbits;
		    return TRUE;
		}
		continue;
	    }
	    if (consecutive_zero_words == zero_words_needed
	    &&  !(word & nbits)
	    ){
		*quartNo = (w - consecutive_zero_words) * VM_INTBITS;
		if (do_alloc)   while (consecutive_zero_words --> 1) {
		    vm_Root_Db->quartAlloc[w-consecutive_zero_words] = ~(Vm_Unt)0;
		}
		if (do_alloc)   vm_Root_Db->quartAlloc[w] |= nbits;
		return TRUE;

	    }
	    consecutive_zero_words = 0;
	}
	/* Return failure: */
	return FALSE;
    }
}

static Vm_Unt
quartsFindFree(
    Vm_Db        db,
    Vm_Unt* quartNo,	/* Put return value here.	*/
    Vm_Unt        n	/* # consecutive quarts needed.	*/
) {
    /* This wrapper is pure paranoia, because   */
    /* quarts_find_free has so much bit hacking */
    /* and so many cases:                       */

    Vm_Unt result = quarts_find_free(db,quartNo,n, FALSE );

    if   (!result) return result;

    /* Sanity checks on return value: */
    {   Vm_Unt q = *quartNo;

	/* Check that all values returned */
        /* are in fact in our bitmap:     */
	if (q + n > vm_Root_Db->quartAllocSlots) {
            VM_FATAL("quartsFindFree(): internal err #1");
	}

	/* Check that all of the indicated  */
	/* quarts are in fact free:         */
	{   Vm_Int i;
	    for   (i = 0;   i < n;   ++i) {
		if (quartIsInUse( db, q+i ))        VM_FATAL("quartsFindFree(): internal err #2");
	    }
	}

        if (!quarts_find_free(db,quartNo,n, TRUE )) VM_FATAL("quartsFindFree(): internal err #3");
        if (q != *quartNo)                          VM_FATAL("quartsFindFree(): internal err #4");

	/* Check that all of the indicated  */
	/* quarts are now NOT free:         */
	{   Vm_Int i;
	    for   (i = 0;   i < n;   ++i) {
		if (!quartIsInUse( db, q+i ))       VM_FATAL("quartsFindFree(): internal err #5");
	    }
	}
    }

    /* Ok, maybe now we believe the result: */
    return result;
}

/************************************************************************/
/*-    quartAllocExpand -- Add another word to quartAlloc bitmap	*/
/************************************************************************/

static void
quartAllocExpand(
    Vm_Db      db
) {
    Vm_Unt statusWords = db->quartAllocSlots >> VM_LOG2_INTBITS;

    Vm_Int* newmap = (Vm_Int*)realloc(
	db->quartAlloc,
	(statusWords+1) * VM_INTBYTES
    );
    if (!newmap) VM_FATAL ("quartAllocExpand: couldn't realloc() status bitmap");
    db->quartAlloc               = newmap;
    db->quartAlloc[statusWords]  = 0;
    db->quartAllocSlots         += VM_INTBITS;
}

/************************************************************************/
/*-    quartsAllocExpand -- Add more words to quartAlloc bitmap		*/
/************************************************************************/

static void
quartsAllocExpand(
    Vm_Db      db,
    Vm_Unt     n
) {
    Vm_Unt statusWords = db->quartAllocSlots  >> VM_LOG2_INTBITS;
    Vm_Unt wordsToAdd  = (n + (VM_INTBITS-1)) >> VM_LOG2_INTBITS;

    Vm_Int* newmap = (Vm_Int*)realloc(
	db->quartAlloc,
	(statusWords + wordsToAdd) * VM_INTBYTES
    );
    if (!newmap) VM_FATAL ("quartAllocExpand: couldn't realloc() quart status bitmap");
    db->quartAlloc               = newmap;
    db->quartAllocSlots         += VM_INTBITS * wordsToAdd;
    {   Vm_Int i;
        for   (i = wordsToAdd;   i --> 0;  ) {
            db->quartAlloc[ statusWords + i ]  = 0;
	}
    }
}

/************************************************************************/
/*-    quartZero -- Zero out given quart on disk			*/
/************************************************************************/

static void
quartZero(
    Vm_Db       db,
    Vm_Unt quartNo
) {
    Vm_Unt buf[ VM_QUART_WORDS ];
    Vm_Unt i;
    for (i = 0;   i < VM_QUART_WORDS;   ++i) {
        buf[i] = (Vm_Unt)0;
    }
   
    /* Seek to our slot in db file: */
    {   off_t loffset = VM_QUART0_OFFSET + quartNo * VM_QUART_BYTES;
        off_t rslt    = lseek(vm_Root_Db->fileDescriptor,loffset,SEEK_SET);
	size_t segb   = VM_QUART_BYTES;
	if (rslt==-1) VM_FATAL ("quartZero: bad seek");


	i = write(vm_Root_Db->fileDescriptor,buf,segb);
	if (i != VM_QUART_BYTES) {
	    VM_FATAL("Couldn't expand Muq db file.");
	}
    }
}

/************************************************************************/
/*-    quartFree -- Mark a quart as unallocated				*/
/************************************************************************/

static void
quartFree(
    Vm_Unt quartNo
) {
    /* Figure out how big bitmap is: */
    Vm_Unt statusWords = vm_Root_Db->quartAllocSlots >> VM_LOG2_INTBITS;

    /* Figure out relevant word and bit: */
    Vm_Unt word = quartNo >> VM_LOG2_INTBITS;
    Vm_Unt bit  = quartNo & (((Vm_Unt)1 << VM_LOG2_INTBITS)-1);
    Vm_Unt mask = (Vm_Unt)1 << bit;

    #if MUQ_IS_PARANOID
    if (word >= statusWords) VM_FATAL("quartFree: bad quartNo");
    #endif

    {   Vm_Unt bits = vm_Root_Db->quartAlloc[word];

	#if MUQ_IS_PARANOID
	if (!(bits & mask)) VM_FATAL("quartFree: quart already free?!");
	#endif

	/* Clear our quart allocation bit: */
	vm_Root_Db->quartAlloc[word] = bits & ~mask;
    }
}

/************************************************************************/
/*-    quartValidate -- Make sure quart is ready to use			*/
/************************************************************************/

static void
quartValidate(
    Vm_Db       db,
    Vm_Unt quartNo
) {
    Vm_Unt byte_offset_in_file  = VM_QUART0_OFFSET + quartNo * VM_QUART_BYTES;
    if    (byte_offset_in_file >= db->bytesInFile) {
        quartZero( db, quartNo );
	db->bytesInFile = VM_QUART0_OFFSET + (quartNo+1) * VM_QUART_BYTES;
    }
}

/************************************************************************/
/*-    quartsValidate -- Make sure quart is ready to use		*/
/************************************************************************/

static void
quartsValidate(
    Vm_Db       db,
    Vm_Unt quartNo,
    Vm_Unt      n
) {
    Vm_Unt u;
    for   (u = 0;   u < n;   ++u) {
	quartValidate( db, quartNo + u );
    }
}

/************************************************************************/
/*-    quartAlloc -- Allocate a quart.					*/
/************************************************************************/

static Vm_Unt
quartAlloc(
    Vm_Db db
) {
    Vm_Unt quartNo;
    if (!quartFindFree(     db, &quartNo )) {
        quartAllocExpand(   db          );
	if (!quartFindFree( db, &quartNo )) {
	    VM_FATAL("quartAlloc: Internal err");
    }	}

    quartValidate( db, quartNo );

    return   VM_QUART0_OFFSET  +  quartNo * VM_QUART_BYTES;
}

/************************************************************************/
/*-    quartAllocBit -- Check if a quart is allocated.			*/
/************************************************************************/

static Vm_Unt
quartIsInUse(
    Vm_Db  db,
    Vm_Unt quartNo
) {
    /* Figure out relevant word and bit: */
    Vm_Unt word = quartNo >> VM_LOG2_INTBITS;
    Vm_Unt bit  = quartNo & (((Vm_Unt)1 << VM_LOG2_INTBITS)-1);
    Vm_Unt mask = (Vm_Unt)1 << bit;

    #if MUQ_IS_PARANOID
    Vm_Unt statusWords = vm_Root_Db->quartAllocSlots >> VM_LOG2_INTBITS;
    if (word >= statusWords) VM_FATAL("quartIsInUse: bad quartNo");
    #endif

    return   (vm_Root_Db->quartAlloc[word] & mask) != 0;
}


/************************************************************************/
/*-    quartsAlloc -- Allocate a sequence of quarts.			*/
/************************************************************************/

static Vm_Unt
quartsAlloc(
    Vm_Db db,
    Vm_Int n	/* Number of consecutive quarts to allocate */
) {
    Vm_Unt quartNo;

    if (!n)   return (Vm_Unt)0;

    if (!quartsFindFree(     db, &quartNo, n )) {
        quartsAllocExpand(   db,           n );
	if (!quartsFindFree( db, &quartNo, n )) {
	    VM_FATAL("quartsAlloc: Internal err");
    }	}

    quartsValidate( db, quartNo, n );

    return   VM_QUART0_OFFSET  +  quartNo * VM_QUART_BYTES;
}

/************************************************************************/
/*-    quartOffsetSlotAlloc -- Allocate a FINAL_OCTAVE quart slot.	*/
/************************************************************************/

static Vm_Unt
quartOffsetSlotAlloc(
    Vm_Db db
) {

    /* Try to allocate an existing quart */
    /* offset slot in final octave:      */
    Vm_Unt*quart  = db->o[VM_FINAL_OCTAVE].quartOffset;
    Vm_Int lim    = db->o[VM_FINAL_OCTAVE].quarts;
    Vm_Int offset;
    for (offset = 0;   offset < lim;  ++offset) {
	if (!quart[offset]) {
	    return offset;
	}
    }

    /* For final octave, 'quarts' and 'diskSlots' */
    /* should be synonymous, since we just use    */
    /* one slot in the quartOffset map per obj:   */
    #if MUQ_IS_PARANOID
    if (db->o[VM_FINAL_OCTAVE].quarts != db->o[VM_FINAL_OCTAVE].diskSlots) {
	VM_FATAL("quartOffsetSlotAlloc: quarts != diskSlots?!");
    }
    #endif

    /* Expand the quart offset map for final octave: */
    offset = db->o[VM_FINAL_OCTAVE].quarts;
    bitmapExpandQuartOffsetArray( db, VM_FINAL_OCTAVE );
    db->o[VM_FINAL_OCTAVE].diskSlots = db->o[VM_FINAL_OCTAVE].quarts;
    
    /* Maybe need to physically expand bitmaps and bytmaps: */
    if (db->o[VM_FINAL_OCTAVE].allocSlots <= offset				/* Support requested offset. */
    ||  db->o[VM_FINAL_OCTAVE].allocSlots <  db->o[VM_FINAL_OCTAVE].diskSlots	/* Support all disk slots.   */
    ){
	bitmapExpandBitmapProper( db, VM_FINAL_OCTAVE, offset );
    }

    return offset;
}
    
/************************************************************************/
/*-    dbtab_clear -- clear out dbtab[]					*/
/************************************************************************/

void
dbtab_clear(
    void
) {
    int  i;
    for (i = VM_DBTAB_MAX;    i --> 0;   ) {
        dbtab[i] = NULL;
    }
}



/************************************************************************/
/*-    db_nuke -- Remove given db if it exists				*/
/************************************************************************/

static void
db_nuke(
    Vm_Db     db,
    Vm_Int which,
    Vm_Uch*  ext
) {
    Vm_Uch buf[ 256 ];

    /* Remove the db index file: */
    strcpy( buf, dbpath1( db->dbfile, which, ext ) );
    remove(buf);

    /* Look for compressed versions also: */
    sprintf( buf, "%s.gz",  dbpath1(db->dbfile,which,ext) );   remove(buf);
    sprintf( buf, "%s.lzo", dbpath1(db->dbfile,which,ext) );   remove(buf);
    sprintf( buf, "%s.bz2", dbpath1(db->dbfile,which,ext) );   remove(buf);
}



/************************************************************************/
/*-    db_rename -- Rename an existing db, vm0/ -> vm1/ or such.	*/
/************************************************************************/

static void
db_rename(
    Vm_Db  db,
    Vm_Int new_index,
    Vm_Int old_index
) {
    /* Our caller guarantees that the new name */
    /* does not conflict with any existing db. */

    Vm_Uch     old_name[ 256 ];
    Vm_Uch     new_name[ 256 ];
    Vm_Int     tries = 0;

    /* Ansi C doesn't say rename() has to work for   */
    /* directories, but POSIX.1 does: cross fingers. */
    for (;;) {
	Vm_Uch buf[ 512 ];

	strcpy( new_name, dbpath1(db->dbfile,new_index,".muq") );
	strcpy( old_name, dbpath1(db->dbfile,old_index,".muq") );
        if (rename(old_name, new_name) >= 0) break;

	strcpy( new_name, dbpath1(db->dbfile,new_index,".muq.gz") );
	strcpy( old_name, dbpath1(db->dbfile,old_index,".muq.gz") );
        if (rename(old_name, new_name) >= 0) break;

	strcpy( new_name, dbpath1(db->dbfile,new_index,".muq.lzo") );
	strcpy( old_name, dbpath1(db->dbfile,old_index,".muq.lzo") );
        if (rename(old_name, new_name) >= 0) break;

	strcpy( new_name, dbpath1(db->dbfile,new_index,".muq.bz2") );
	strcpy( old_name, dbpath1(db->dbfile,old_index,".muq.bz2") );
        if (rename(old_name, new_name) >= 0) break;

	/* Avoid falling into an infinite loop under  */
	/* any circumstances:                         */
	#ifndef VM_MAX_FILE_RENAME_RETRIES
	#define VM_MAX_FILE_RENAME_RETRIES 8
	#endif
	if (tries++ < VM_MAX_FILE_RENAME_RETRIES) {

	    /* If error was due to random signal that     */
	    /* happened to arrive in the middle of the    */
	    /* call, just retry it:                       */
	    if (errno == EINTR)   continue;

	    /* Ignore error due to missing db generation  */
	    /* other than generation 0, since this will   */
	    /* be normal when bootstrapping:              */
	    #ifdef ENOENT
	    if (errno == ENOENT  &&  old_index != VM_PATH_RUNNING)   break;
	    #endif

	    /* I've a report of rename failing on Linux   */
	    /* with a 'directory not empty' error.  I'm   */
	    /* not sure why;  I'm guessing Linux does     */
	    /* 'rename' asynchronously, so that one can   */
	    /* start before the previous one completes.   */
	    /* On this theory, I'll try sleeping and      */
	    /* retrying on these:                         */
	    #ifdef EEXIST
	    if (errno == EEXIST) {
	       sleep(2); /* Some unices may sometimes return */
	       continue; /* immediately on sleep(1);         */
	    }
	    #endif
	}
	#ifdef HAVE_STRERROR
	sprintf(buf,
	    "Could not rename %s -> %s (%s)! i %d max %d",
	    old_name,
	    new_name,
	    strerror(errno),
	    (int)old_index,
	    (int)db->s.consecutive_backups_to_keep
	);
	#else
	sprintf(buf,
	    "Could not rename %s -> %s (%d)! i %d max %d",
	    old_name,
	    new_name,
	    errno,
	    (int)old_index,
	    (int)db->s.consecutive_backups_to_keep
	);
	#endif
	VM_FATAL (buf);
    }
}

/************************************************************************/
/*-    db_renaming -- Rename existing dbs, vm0/ -> vm1/ -> vm2/ ...	*/
/************************************************************************/

/* Each time we do a backup/garbage collect,	*/
/* the existing RUNNING db becomes CURRENT, and	*/
/* the existing CURRENT db gets renumbered to	*/
/* its decimal version number:			*/

static void
db_renaming(
    Vm_Db db
) {
    db_rename( db, /*to:*/ db->s.backups_done -1, /*from:*/ VM_PATH_CURRENT );
    db_rename( db, /*to:*/ VM_PATH_CURRENT      , /*from:*/ VM_PATH_RUNNING );
}



/************************************************************************/
/*-    db_logarithmic_nuke -- Thin existing dbs logarithmically.	*/
/************************************************************************/

/********************************************************/
/*							*/
/* My experience running muds has been that keeping	*/
/* deep sequences of backups is unsatisfactory because	*/
/* it fills up disk too quickly, and one rarely really	*/
/* has use for huge numbers of old versions of the db,	*/
/* but that keeping shallow sequences of db backups is	*/
/* almost equally unsatisfactory, because every now and	*/
/* then one realizes that something important got nuked	*/
/* a month ago (say) and is no longer on any retained	*/
/* backup.						*/
/*							*/
/* This function attempts to implement a middle ground,	*/
/* in which a relatively large number of recent copies	*/
/* of the db are kept, together with a logarithmically	*/
/* declining number of older dbs.  The basic notion is	*/
/* that at any given time we'll have on hand something	*/
/* like:						*/
/*							*/
/*    current db.	(generation 0)			*/
/*    last db		(generation 1)			*/
/*    next-to-last db   (generation 2)			*/
/*    fourth-to-last db	(generation 4)			*/
/*    eighth-to-last db	(generation 8)			*/
/*    ...						*/
/*							*/
/* Clearly, after a million backups we'll have only	*/
/* twenty or so dbs on disk, and after a billion	*/
/* only thirty or so, so we -won't- be flooding the	*/
/* disk quickly, but we -will- have a reasonable	*/
/* sampling of dbs of various ages to retreat to,	*/
/* should problems arise.				*/
/*							*/
/* The above goal is strictly speaking impossible,	*/
/* since if the seventh-to-last db is deleted		*/
/* this generation, it won't be around to be the	*/
/* eighth-to-last db next generation.			*/
/*							*/
/* What we do instead is to number all db generations	*/
/* sequentially 0,1,2,3... and to arrange that at any	*/
/* given time we are keeping exactly one backup db:	*/
/* * which is an even multiple of 1			*/
/* * which is an even multiple of 2			*/
/* * which is an even multiple of 4			*/
/* * which is an even multiple of 8			*/
/* and so forth -- and in each case, the most recent	*/
/* such multiple.					*/
/*							*/
/* Clearly, this will have the desired property of	*/
/* maintaining a total number of backups O(log2(n))	*/
/* after N generations, with the distribution skewed	*/
/* towards the most recent dbs as desired.		*/
/*							*/
/* Equally important, maintaining this distribution is	*/
/* possible, because it requires only, each time we 	*/
/* save a new backup, we delete the most recent backup	*/
/* whose binary generation number has the same number	*/
/* of trailing zeros.					*/
/*							*/
/********************************************************/

static Vm_Int
trailing_zeros(
    Vm_Int n
) {
    Vm_Int bit;
    Vm_Int zeros=0;
    for (bit=(Vm_Unt)1; n && !(n&bit); ++zeros,bit<<=1);
    return zeros;
}

static void
db_logarithmic_nuke(
    Vm_Db db
) {
    /* Our algorithm is based on merely scanning	*/
    /* the binary representation for vm_backups_done,	*/
    /* which counts all backups performed over the life */
    /* of the db.  We count the number of consecutive   */
    /* '1' bits at the low end of the word, and rename  */
    /* upward that many db copies, leaving the rest     */
    /* unchanged.  Note that the basic vm.t logic	*/
    /* requires that vm0 always be renamed to vm1, to	*/
    /* make room for the next scratch db.  Also, I	*/
    /* prefer to always preserve vm1, to minimize	*/
    /* loss if vm0 is somehow trashed.  So typical	*/
    /* cases keying on possible vm_backups_done are:	*/
    /*  0x14E0:  Two renamings to be done.		*/
    /*  0x14E1:  Three db renamings to be done.		*/
    /*  0x14E3:  Four db renamings to be done.		*/
    /*  0x14E7:  Five db renamings to be done.		*/
    /*  0x14EF:  Six db renamings to be done.		*/
    /* (&tc...)						*/

    Vm_Int  us     = db->s.backups_done - db->s.consecutive_backups_to_keep;
    Vm_Int  zeros  = trailing_zeros(us);
    Vm_Int  step   = ((Vm_Unt)1) << (zeros+1);
    Vm_Int  to_zap = us-step;

    while (to_zap>0 && trailing_zeros(to_zap) != zeros) {
	to_zap -= step;
    }

    if (to_zap > 0) {
        db_nuke( db, to_zap, ".muq" );
    }
}



/************************************************************************/
/*     gc_color_obj_grey -- If 'o' is Black, color Grey & return TRUE.	*/
/************************************************************************/

#ifdef SOMEDAY
static Vm_Int
gc_color_obj_grey(
    Vm_Obj o
) {
    if (!gc_obj_is_black(o)) {
	return FALSE;
    } else {
	A_Ex e;
	objExplode(         &e, o );
	bitmapTake( vm_This_Db, e.octave,  e.offset           );
	return TRUE;
    }
}
#endif


/************************************************************************/
/*     gc_color_obj_white -- Set 'o' to be White.			*/
/************************************************************************/

#ifdef SOMEDAY
static void
gc_color_obj_white(
    Vm_Obj o
) {
    A_Ex e;
    objExplode( &e, o );

    /* We assume 'o' is currently Grey: */
    setAllocBit( last_db, e.octave, e.offset, 0 );
}
#endif


/************************************************************************/
/*     gc_grey_stack_init -- Set gc_grey_stack to empty.		*/
/************************************************************************/

#ifdef SOMEDAY
static void
gc_grey_stack_init( void ) {

    if (gc_grey_stack == NULL) {
	gc_grey_stack =  alloc(
	    VM_MIN_GREY_STACK * sizeof( Vm_Obj )
	);
	gc_grey_stack_size = VM_MIN_GREY_STACK;
    }
    gc_grey_stack_top = 0;
}
#endif


/************************************************************************/
/*     gc_grey_stack_pop -- Next gc_grey_stack object else FALSE.	*/
/************************************************************************/

#ifdef SOMEDAY
static Vm_Obj
gc_grey_stack_pop( void ) {

    if (!gc_grey_stack_top)    return FALSE;

    return gc_grey_stack[ --gc_grey_stack_top ];
}
#endif


/************************************************************************/
/*     gc_grey_stack_push -- Insert object in gc_grey_queue.		*/
/************************************************************************/

#ifdef SOMEDAY
static void
gc_grey_stack_push(
    Vm_Obj o
) {
    /* If stack is full, expand it: */
    if (gc_grey_stack_top == gc_grey_stack_size) {
	Vm_Obj* new_stack = realloc(
	    gc_grey_stack,
	    gc_grey_stack_size * 2 * sizeof( Vm_Obj )
	);
	if (!new_stack) {
	    VM_FATAL ("gc_grey_stack_push: out of ram");
        }
	gc_grey_stack_size *= 2;
	gc_grey_stack       = new_stack;
    }

    /* Push given object on stack: */
    gc_grey_stack[ gc_grey_stack_top++ ] = o;
}
#endif


/************************************************************************/
/*     gc_note_roots -- Set gc_roots to copy of 'roots' block.		*/
/************************************************************************/

#ifdef SOMEDAY
static void
gc_note_roots(
    Vm_Obj** ppo
) {
    /* Count number of pointers in *ppo, */
    /* including terminal NULL:          */
    Vm_Int i = 0;   while (ppo[i]) ++i;

    /* Recycle any old roots list: */
    if (gc_roots)   free( gc_roots );

    /* Malloc sufficient memory to hold roots+NULL: */
    gc_roots = alloc( ++i * sizeof( Vm_Obj* ) );

    /* Copy roots+NULL into *gc_roots: */
    while (i --> 0)   gc_roots[i] = ppo[i];
}
#endif


/************************************************************************/
/*     gc_obj_is_black -- TRUE iff 'o' is Black.			*/
/************************************************************************/

#ifdef SOMEDAY
static Vm_Int
gc_obj_is_black(
    Vm_Obj o
) {
    A_Ex e;
    objExplode( &e, o );

    return ( getAllocBit(vm_This_Db,e.octave,e.offset) == 0
    &&       getAllocBit(last_db,e.octave,e.offset) == 1
    );
}
#endif


/************************************************************************/
/*     gc_obj_is_grey -- TRUE iff 'o' is Grey.				*/
/************************************************************************/

#ifdef SOMEDAY
static Vm_Int
gc_obj_is_grey(
    Vm_Obj o
) {
    A_Ex e;
    objExplode( &e, o );

    return ( getAllocBit(vm_This_Db,e.octave,e.offset) == 1
    &&       getAllocBit(last_db,e.octave,e.offset) == 1
    );
}
#endif


/************************************************************************/
/*     gc_obj_is_white -- TRUE iff 'o' is White.			*/
/************************************************************************/

#ifdef SOMEDAY
static Vm_Int
gc_obj_is_white(
    Vm_Obj o
) {
    A_Ex e;
    objExplode( &e, o );

    return ( getAllocBit(vm_This_Db,e.octave,e.offset) == 1
    &&       getAllocBit(last_db,e.octave,e.offset) == 0
    );
}
#endif


/************************************************************************/
/*     gc_process_grey_object -- Color 'o' White if it is Grey.		*/
/************************************************************************/

/*************************************************/
/* We minimize local variables in these two fns, */
/* due to the possibility of deep recursion. 	 */
/*************************************************/

#ifdef SOMEDAY
static void
gc_process_grey_object_fn(
    Vm_Obj o
) {
    if (gc_color_obj_grey(o)) {

	/* We don't allow Grey objects in ram,   */
	/* so process 'o' immediately if in ram, */
	/* else stack it for later processing:   */
	if (vm_Is_In_Ram( o )) gc_process_grey_object( o );
	else		       gc_grey_stack_push(     o );
    }
}
#endif

#ifdef SOMEDAY
static Vm_Int
gc_process_grey_object(
    Vm_Obj o
) {
    /* If object is not actually Grey, due to	*/
    /* having been processed on an emergency	*/
    /* basis, we have nothing to do:		*/
    if (!gc_obj_is_grey(o))   return FALSE;

    /* If object is not in ram, load it from	*/
    /* last_db:					*/
    if (!vm_Is_In_Ram(o))     dbfileGet( last_db, o );

    /* Mark 'o' dirty, to force it to be 	*/
    /* (eventually) written to vm_This_Db:		*/
    vm_Dirty( o );

    /* Color 'o' White, to prevent any nasty	*/
    /* infinite recursions:			*/
    gc_color_obj_white(o);

    /* Find all Black objects referenced by 'o'	*/
    /* and color them Grey:			*/
    gc_all_ptrs( o, gc_process_grey_object_fn );

    return TRUE;
}
#endif



/************************************************************************/
/*     gc_start -- Initiate another garbage collection / backup.	*/
/************************************************************************/

#ifdef SOMEDAY
static void
gc_start(
    void
){
    int swap;

    /* Can't do backup if user hasn't specified */
    /* gc_all_ptrs() and gc_roots yet:		*/
    if (!gc_all_ptrs
    ||  !gc_roots
    ){
	return;
    }

    gc_in_progress	= TRUE;

    /* Freeze current db: */
    bigbufClean();
    dbindexSave(vm_This_Db,vm_This_Db->fileDescriptor,"muqmuq\n\0",(Vm_Unt)vm_This_Db->bytesInFile);

    /* Rename vm0/ -> vm1/ -> vm2/ etc	*/
    /* to make room for new vm0/:	*/
    db_renaming();

    if (vm_This_Db->wasCompressed) {
	dbindexCompress(vm_This_Db,VM_PATH_CURRENT);
    }

    /* That gives us one more db than	*/
    /* we're supposed to be keeping:	*/
    db_nuke( vm_This_Db, vm_This_Db->s.consecutive_backups_to_keep+1, ".muq" );

    /* Swap vm_This_Db and last_db: */
    {   Vm_Db tmp = last_db;
        last_db = vm_This_Db;
        vm_This_Db = tmp;

	/* Propagage the stats: */
	vm_This_Db->s = last_db->s;
    }

    /* Create a new vm_This_Db in a new vm0/: */
    dbindexClear(vm_This_Db);
    dbindexLoad( vm_This_Db, ".muq", &swap );

    /* Process given roots: */
    {   Vm_Obj** o;
        gc_grey_stack_init();
	for (o = gc_roots;   *o;   o++)   gc_color_obj_grey(      **o );
	for (o = gc_roots;   *o;   o++)   gc_process_grey_object( **o );
    }

    vm_This_Db->s.steps_done_for_this_gc	= 0;
}
#endif



/************************************************************************/
/*-    hshtabFree -- Delete 'p' from hashtab.				*/
/************************************************************************/

static void
hshtabFree(
    Block p
) {
    /* Delete p from hashtable: */

    register Vm_Unt o = p->o >> VM_HASHTAB_SHIFT;
             Block*   f = &bigbufHashtab[ o & VM_HASHTAB_MASK ];
    register Block    g = *f;
    register Block    h = g;

    /* If hashtable vector points directly to us, it's easy: */

    if (*f == p) {
       *f = VM_NEXT_HASH_BLOCK(*f);
	return;
    }

    /* Over all blocks h on our hashchain: */
    for ( ;
	h->next >> VM_SMALLSIZE_SHIFT;
	g = h,   h = VM_NEXT_HASH_BLOCK(g)
    ) {

	/* If h == p, update person pointing	*/
	/* to us to point to our successor:	*/
	if (h == p) {

	    g->next = (
		g->next &  VM_SMALLSIZE_MASK
		|
		h->next & ~VM_SMALLSIZE_MASK
	    );
	    return;
    }	}

vm_Print_State(stdout,"hshtabFree dying");
    VM_FATAL ("hshtabFree: bad arg");
}



/************************************************************************/
/*-    hshtabInvariants -- Sanitycheck hash table.			*/
/************************************************************************/

/* #if VM_DEBUG */
static int
hshtabInvariants(
    FILE*   f,
    Vm_Uch* t,
    int     count
) {
    Vm_Int errsfound = 0;

    /********************************************************************/
    /* INVARIANT:							*/
    /* bigbufHashTab always points to a vector of length      	       	*/
    /* bigbufHashtabMask +1.                                  		*/
    /********************************************************************/
    /*  Unfortunately, malloc doesn't give us a way to check this.	*/

    /********************************************************************/
    /* INVARIANT:							*/
    /* Each slot leads to a hashtable chain ending on bigbufNullBlock.  */
    /* (Rationale: Having every bigbufHashTab slot point to valid ram	*/
    /*  saves us a NULL pointer check in the most speed-critical case	*/
    /* in vm_Loc().)							*/
    /********************************************************************/
    {	Block nullBlock   = (Block) ((Vm_Unt*)bigbufBeg +1);
    	Block firstBlock  = bigbufFirst();
	/* Compute a max hashchain length, so we can  */
        /* detect looped chains, rather than hanging: */
	Vm_Unt max_chain = bigbuffree - bigbufBeg;

	/* Over all hashchains in hashtable: */
	Vm_Int    i;
	for (i = VM_HASHTAB_SIZE;   i --> 0; ) {

	    /* Over all blocks on hashchain: */
	    Vm_Unt   len = 0;
	    Block p;
	    for (
		p  = bigbufHashtab[i];
		p != nullBlock;
		p  = VM_NEXT_HASH_BLOCK(p)
	    ) {

		/* Check for loop in chain: */
		if (++len > max_chain) {
		    ++errsfound;
		    err(f,t,"Hashchain %d loops on itself.\n",(int)i);
		    break;
		}

		/* Make sure block is in bigbuf: */
		if (p < firstBlock  ||  p >= bigbuffree) {
		    ++errsfound;
		    err(f,t,
			"Hashchain %d block %d (%p) not in bigbuf\n",
			(int)i, (int)len, p
		    );
		    break;
    }	}   }   }

    /********************************************************************/
    /* INVARIANT:							*/
    /* Excepting only bigbufNullBlock, every bigbufBlock reachable     	*/
    /* from bigbufHashtab (via 'next' chains) maps a Vm_Obj (which     	*/
    /* has been issued by vm_Malloc() and not eliminated by vm_Free()) 	*/
    /* to the memory address of the object in question (which is in    	*/
    /* bigbuf).		      	      	      	       	       	       	*/
    /********************************************************************/
    /* No way to check this invariant, since it's in time, not space.	*/

    return errsfound;
}
/* #endif */



/************************************************************************/
/*-    hshtabNoteMotion -- Fix hashtable for 'old' moving to 'new'.	*/
/************************************************************************/

static void
hshtabNoteMotion(
    Block new,
    Block old
) {
    register Vm_Unt o = old->o >> VM_HASHTAB_SHIFT;
             Block*   f = &bigbufHashtab[ o & VM_HASHTAB_MASK ];
    register Block    g = *f;
    register Block    h = g;

    /* If 'old' is DEAD, nothing to do: */
    if (!VM_IS_LIVE(old))   return;

    /* If hashtable vector points directly to us, it's easy: */
    if (*f == old) {
       *f = new;
	return;
    }

    /* Over all blocks h on our hashchain: */
    for ( ;
	h->next >> VM_SMALLSIZE_SHIFT;
	g = h,   h = VM_NEXT_HASH_BLOCK(g)
    ) {

	/* If h == old, update person pointing	*/
	/* to us to reflect new location:	*/
	if (h == old) {

	    /* Figure word offset of 'new' in bigbuf: */
	    Vm_Unt offset = (Vm_Int*)new - (Vm_Int*)bigbufBeg;

	    g->next = (
		g->next & VM_SMALLSIZE_MASK
		|
		offset << VM_SMALLSIZE_SHIFT
	    );
	    return;
    }	}
}



/************************************************************************/
/*-    hshtabPrint -- Print contents of hashtab.			*/
/************************************************************************/

/************************************************************************/
/*-    hshtabPrintChain -- Print contents of hashtab chain 'i'.		*/
/************************************************************************/

#if VM_DEBUG
static void
hshtabPrintChain(
    FILE* f,
    Vm_Int   i
) {
    Block nullBlock = (Block) ((Vm_Unt*)bigbufBeg +1);

    Block  p = bigbufHashtab[i];
    Block  q = bigbufHashtab[i];
    Vm_Int    j = 1;
    while (p != nullBlock) {

	/* Broken chain insurance: */
	if (p < bigbufBeg
	||  p > bigbuffree
	){
	    fprintf(f,
		"HASHTAB chain %3x leaves bigbuf! p x=%p <----****\n",
		(int)i, p
	    );
	    break;
	}

	fprintf(f,
	    "HASHTAB chain %3x: p x=%p p->o x=%08" VM_X " p->next x=%08" VM_X "\n",
	    (int)i, p, (Vm_Unt)p->o, (Vm_Unt)p->next
	);

	/* Q travels half as fast as p down hashchain. */
	/* If they ever meet, chain has a loop:        */
	p               = VM_NEXT_HASH_BLOCK(p);
	if (j ^= 1)   q = VM_NEXT_HASH_BLOCK(q);

	/* Looping chain insurance: */
	if (p == q) {
	    fprintf(f,"HASHTAB chain %3xd loops! <----****\n",(int)i);
	    break;
    }   }
}
#endif



#if VM_DEBUG
static void
hshtabPrint(
    FILE* f
) {
    Vm_Int    i;
    for (i = VM_HASHTAB_SIZE;   i --> 0; )   hshtabPrintChain( f, i );
}
#endif



/************************************************************************/
/*-    len -- Return size-in-bytes of Block 'p'.			*/
/************************************************************************/

/* We return the 'len' value originally supplied to vm_Malloc: */

static Vm_Unt
len(
    Block p
) {
    /* Sizefield is sometimes in h[0].next and sometimes in h[-1].next. */
    /* Short sizes are offset by 1 to fit sizes 1->64 in six bits:      */
    if (VM_IS_BIG_OCTAVE(p->o))  return (p[-1].next >> VM_BIGSIZE_SHIFT );
    else                         return (p[ 0].next  & VM_SMALLSIZE_MASK);
}



/************************************************************************/
/*-    loc -- A vm_Loc() that returns header instead of user data.	*/
/************************************************************************/

static Block
loc(
    Vm_Obj obj
) {
    /* See vm_Loc() for comments. */
    register Vm_Unt o = (obj >> VM_HASHTAB_SHIFT);
    register Block    h = bigbufHashtab[ o & VM_HASHTAB_MASK ];
    if (h->o >> VM_HASHTAB_SHIFT  ==  o)   return h;
    else                                   return (Block)locB(obj) -1;
}



/************************************************************************/
/*-    locB -- Does most of vm_Loc/loc's work for them.			*/
/************************************************************************/

/* We arrive here if vm_Loc didn't find the    */
/* desired block at the head of the hashchain. */

static void*
locB(
    Vm_Unt obj
) {
    register Vm_Unt o = (obj >> VM_HASHTAB_SHIFT);
             Block*   f = &bigbufHashtab[ o & VM_HASHTAB_MASK ];
    register Block    g = *f;
    register Block    h = g;
    /****************************************************/
    /* Over all blocks on the chain, if o~=block->o,	*/
    /* move block to head of queue (so we don't have	*/
    /* to look so far for it next time) and return the	*/
    /* associated record.  Note the test on ->o will	*/
    /* never succeed first time through the loop, else  */
    /* vm_Loc wouldn't have called us.  Which is good,  */
    /* because our move-to-head-of-queue logic would    */
    /* fail then :).  But we need the firstloop check   */
    /* on h->next:                                      */
    /****************************************************/
    for ( ;
	h->next >> VM_SMALLSIZE_SHIFT;
	g = h,   h = VM_NEXT_HASH_BLOCK(g)
    ) {

	/* If we've found the bucket we want: */
        if (h->o >> VM_HASHTAB_SHIFT   ==   o) {
	    /* Above shift is price we pay for hiding a DIRTY bit */
	    /* in 'o' field.  We could mask instead of shifting,  */
	    /* but I think they're both single-cycle on today's	  */
	    /* machines, and the mask constant is bigger than	  */
	    /* the shift constant, which might cost us a cycle--  */
	    /* lots of RISCs only have 16-bit immediate constants.*/

	    /* Delete bucket from current spot in hashchain: */
	    g->next = (
		g->next &  VM_SMALLSIZE_MASK
		|
		h->next & ~VM_SMALLSIZE_MASK
	    );

	    /* Insert bucket at head of hashchain: */
	    h->next = (
		h->next                              &  VM_SMALLSIZE_MASK
		|
	        ((Vm_Int*)(*f) - (Vm_Int*)bigbufBeg) << VM_SMALLSIZE_SHIFT
	    );
	    *f      = h;

	    /* Return record associated with 'obj': */
	    return (void*) (h+1);
	}
    }

    /* Icky special case for length-zero object: */
    if (o   ==   VM_LEN0_OBJ >> VM_TAGBITS) {
	/* Return nullblock.  Folks taking its    */
        /* length will get the right answer, and  */
        /* folks setting the DIRTY bit on it will */
        /* do no harm:                            */
        return (Block)((Vm_Int*)bigbufBeg +1) +1;
    }

    /* Object isn't in memory, so swap it in from disk. */
    /* If no garbage collection is in progress, this	*/
    /* just means reading it in from disk:		*/
    #ifdef SOMEDAY
    if (!gc_in_progress
    ||  gc_obj_is_white( obj )
    ){
    #endif
    {	Vm_Unt dbfile = VM_DBFILE(obj);
	Vm_Db  db     = dbfind(dbfile);
	return dbfileGet( db, obj ) +1;
    }
    #ifdef SOMEDAY
    }
    #endif
    
    #ifdef SOMEDAY
    /* An incremental garbage-collection / backup is in	*/
    /* progress and object is Grey.  Since we do not    */
    /* allow Grey objects in ram, need to stop and      */
    /* color object White:				*/
    if (gc_process_grey_object( obj )) {
	return          vm_Loc( obj );
    }

    /* We shouldn't be accessing Black or Free objects: */
    VM_FATAL ("locB: bad color");
    return (void*)0;	/* Purely to keep compilers quiet. */
    #endif
}



/************************************************************************/
/*-    lockedInRam -- True iff 'o' is locked in ram.			*/
/************************************************************************/

static int
lockedInRam(
    Vm_Obj o
) {
    /* We ignore the call if p is locked in ram: */
    register Vm_Obj o4 = (o >> VM_TAGBITS);
    register Vm_Int    i  = bigbufHardPointerCount;
    while (i --> 0) {
	Vm_Obj o = *bigbufHardPointers[i].o;
	if (o && (o >> VM_TAGBITS) == o4)   return TRUE;
    }
    return FALSE;
}



/************************************************************************/
/*-    maybeCopyObj -- Maybe copy 'obj' to front of bigbuf.		*/
/************************************************************************/

#if VM_LOC_MAYBE_COPY_FRACTION
static void* maybeCopyObj(
    Vm_Obj obj
) {
    /************************************************************/
    /* To guarantee we don't become a CPU hog, we need to	*/
    /* make sure we only do a small constant amount of		*/
    /* call on average.  Thus, we copy blocks with a		*/
    /* probability inverse to their size.  If folks want	*/
    /* to take this as a reason to avoid large objects,		*/
    /* that's ok by me *grin*.					*/
    /************************************************************/
    static   clock = 0;
    Vm_Unt bit   = 8;
    clock         += 8;
    while (obj & bit) {
	if (!(clock & bit))   return vm_Loc(obj);
	bit <<= 1;
    }

    /* Copy obj to head of bigbuf: */
    buggo -- not implemented.

    /* As a convenience, we return vm_Loc(o): */
    return vm_Loc(o);
}
#endif



/************************************************************************/
/*-    objExplode -- Extract octave/offset/size from Vm_Obj.		*/
/************************************************************************/


/****************************************************************/
/* I find a diagram helpful when checking this code.		*/
/* Using 's' for dirty flag, and 't' for offset bits,		*/
/* and 'u' for the userbits vm_Get/Set_Userbits() export,	*/
/* for the first few generations, the least sig bits are:	*/
/* 								*/
/*   Octave 2:  ...tttttt0uus1					*/
/*   Octave 3:  ...ttttt01uus1					*/
/*   Octave 4:  ...tttt011uus1					*/
/* 								*/
/****************************************************************/


void
objExplode(
    Ex        e,
    Vm_Obj    o
) {
    e->octave = (o >> VM_OCTAVE_SHIFT) & VM_OCTAVE_MASK;
    e->offset = (o >> VM_OFFSET_SHIFT) & VM_OFFSET_MASK;
    e->dbfile = (o >> VM_DBFILE_SHIFT) & VM_DBFILE_MASK;
    e->unique = (o >> VM_UNIQUE_SHIFT) & VM_UNIQUE_MASK;
}



/************************************************************************/
/*-    objImplode -- Construct Vm_Obj from octave/offset pair.		*/
/************************************************************************/

static Vm_Obj
objImplode(
    Vm_Unt octave,
    Vm_Unt offset,
    Vm_Unt dbfile,
    Vm_Unt unique
) {
    return (
	(offset << VM_OFFSET_SHIFT)
      | (unique << VM_UNIQUE_SHIFT)
      | (octave << VM_OCTAVE_SHIFT)
      | (dbfile << VM_DBFILE_SHIFT)	
#ifdef OLD
      | ((Vm_Unt)~0   >>   VM_INTBITS-VM_TAGBITS)
#endif
    );
}



/************************************************************************/
/*-    powerOfTwoCeiling -- Smallest power of two >= 'u'.		*/
/************************************************************************/

static Vm_Unt
powerOfTwoCeiling(
    Vm_Unt u
) {
    /* Binary search is faster, but this */
    /* fn shouldn't be a hotspot:        */
    Vm_Unt   result = 1;
    while (u > result)  result <<= 1;
    return     result;
}



/************************************************************************/
/*-    saveHardPointerOffsets -- Before we slide bigbuf contents.	*/
/************************************************************************/

static void
saveHardPointerOffsets( void ) {
    Vm_Int    i = bigbufHardPointerCount;
    while (i --> 0) {
	Vm_Obj o = *bigbufHardPointers[i].o;
	void** p =  bigbufHardPointers[i].p;
	if (o && p) {
	    #if MUQ_IS_PARANOID
	    if (!vm_Is_In_Ram(o)) {
		VM_FATAL ( "vm.c:saveHardPointerOffsets: locked ptr %" VM_X " not in ram!\n",o);
	    }
	    #endif
	    bigbufHardPointers[i].offset = (
		((Vm_Uch*)(*p))        - 
		((Vm_Uch*) vm_Loc( o ))
	    );
    }   }
}



/************************************************************************/
/*-    set_signals -- Arrange full coredumps.				*/
/************************************************************************/

#include <signal.h>
static void
set_signals( void ) {

 #if defined(SA_PARTDUMP) && defined(SA_FULLDUMP)

    /* Try to get full coredump out of AIX/posix: */
    {   struct sigaction sa;
	sigaction( SIGSEGV, NULL, &sa  );
	sa.sa_flags &= ~SA_PARTDUMP;
	sa.sa_flags |=  SA_FULLDUMP;
	sigaction( SIGSEGV, &sa , NULL );
    }
    {   struct sigaction sa;
	sigaction( SIGABRT, NULL, &sa  );
	sa.sa_flags &= ~SA_PARTDUMP;
	sa.sa_flags |=  SA_FULLDUMP;
	sigaction( SIGABRT, &sa , NULL );
    }

#endif
}



/************************************************************************/
/*-    updateHardPointers -- Stuff has moved, fix hard pointers.	*/
/************************************************************************/

static void
updateHardPointers(
    void
) {
    Vm_Int    i = bigbufHardPointerCount;
    while (i --> 0) {
	Vm_Obj o = *bigbufHardPointers[i].o;
	void** p =  bigbufHardPointers[i].p;
	if (o && p) {
	    *p = (void*)(
		(Vm_Uch*) vm_Loc( o )  +
		bigbufHardPointers[i].offset
	    );
    }   }
}




/************************************************************************/
/*-    File variables							*/
/************************************************************************/
/*

Local variables:
mode: c
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

@end example
