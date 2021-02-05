@example  @c
/*--   cdf.c -- Class DeFinitions for Muq MOS classes.			*/
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
/*		For Firiss:  Aefrit, a friend.				*/
/*									*/
/************************************************************************/

/************************************************************************/
/* Author:       Jeff Prothero						*/
/* Created:      96Feb23						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1997, by Jeff Prothero.				*/
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
/* JEFF PROTHERO DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,	*/
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
/*-    Overview								*/
/************************************************************************/

/************************************************************************

--------------------
Proposed structure for MOS objects:
  class-key;
  slot[n];
When we start trying to handle expanding objects, we can
do this by pointing class to the new object rather than
the key, I think.

Proposed structure for MOS classes:

  metaclass  ;; standardClass
  documentation string
  key

Key object contains:
  mosClass ;; backpointer to our class object
  nextKey  ;; If class definition has changed, this is the new
             ;; definition.  Objects with the old layout need to
             ;; update themselves and then point their 'mosClass'
             ;; field to the new key.
  superclass-count
  precedence-list-length
  slot-count
  superclasses[ superclass-count ]
  precedence-list[ precedence-list-length ]
  slots[ slot-count ] where each slot contains:
      :initform
      :initarg
      :type
      :documentation string.
      :reader
      :writer
      shared/user/author/root/worldMayRead/write bits
      value (used only if SHARED bit is set)

--------------------
MOS notes:

Need ephemeral lists, I don't wanna
do &rest by allocating from the heap.

Need a crack-lisp-argblock prim.
It in turn will need a datatype to
hold a compiled lambdaList definition,
and a prim to create such...

Note: call-next-method needs to know whether it is
being called from a :before or :after method (signals
an error) or an :around method (in which case it must
be able to deduce the next least specific :around
method) or a primary method (in which case is must be
able to deduce the next least specific primary method).
  This sounds like a job for a new stackframe type
pushed by generic functions...?

Datastructure types:
  metaclasses
    determines inheritance for its classes
    determines representation for instances of its classes
  classes
    name
    metaclass
    direct superclass list
    class precedence list: class + all superclasses, most to least 'specific'.
    shared slots
  instances
    pointer to class
    local slots
  methods  (which are NOT compiled-functions)
    "a method function"
    "a sequence of parameter specializers"
    "a sequence of qualifiers used by the
       method combination facility to distinguish
       among methods": "A qualifier is any object
       other than a list, that is, any non-NIL atom.
       The qualifiers defined by standard method
       combination and by the built-in method
       combination types are symbols."
       "In standard method combination, primary
       methods are unqualified, and auxiliary methods
       are methods with a single qualifier that is one
       of :around :before or :after..." (p791)
  generic functions
    "lambda list"
      Should support required and optional parameters.
      Should support &key flag and keyword list.
      Should support &rest and &allow-other-keys flags.
    "method combination type"
    vector of methods

Datastructure instances:
  metaclass standardClass
  metaclass structureClass
  metaclass builtInClass
  class t
  class standardObject
  class standardGenericFunction
  class standardMethod
  classes for the standard types: See table on CLtL2 p 783

Functions (+macros &tc)
  fn className    Map class to name (nil for anonymous classes)
  fn find-class    Map symbol to class.
  mc defclass [ name supers slots ]  Defines a new named class
    name
    metaclass
    direct superclasses
    class options
      :default-initargs
	Arg is a list of key/val pairs, where
	key is name of an initialization argument, and
	val is an arbitrary form to compute initial val.
	Key may represent either a slot or a method arg.
      initialization defaults
    slot names
    slot options
      :initform    Initial value for slot.
      :initarg     Appears to specify a name which, when
                   provided as a keyword to makeInstance,
                   should result in the corresponding value
                   being copied into this slot. There may be
		   more than one :initarg for a given slot.
      :allocation  :instance or :class (un/shared)
      :type        Lets ignore this for now.
      :documentation String.
      :reader / :writer / :accessor   Slot function construction.
      [ Need to add user/author/root/worldMayRead/write bits ]
  gf makeInstance: class x initargs -> instance.
    Initargs are keyVal pairs. ":allow-other-keys t" is one such
    pair, disables initarg name checking.
    "Initialization arguments are used in four situations:
       Making an instance;
       When re-initializing an instance;
       Updating an instance per a redefined class;
       Updating an instance per a different class."
  gf initializeInstance
  gf reinitialize-instance
  gf update-instance-for-redefined-class
  gf update-instance-for-different-class
  gf shared-initialize
  gf allocate-instance
  gf slot-unbound   Invoked when unbound slot is read.
  fn slot-value     Get/set given slot in given instance.
  ?? defmethod
  ?? defgeneric
      signals error if given name names a fn, macro or special form.
      adds/removes methods to any existing generic function of that name
      (unless lambda lists don't match, which is an error)
      else creates a new generic function of that name.
        :argument-precedence-order
        :method-combination
          The built-in method combination types are:
            + and append list max min nconc or progn standard
          :most-specific-last
  sp generic-flet
  sp generic-labels
  sp with-added-methods
  mc genericFunction  Create an anonymous generic function.
  mc define-method-combination
  gf no-applicable-method  Called when generic fn has no matching method.
  fn call-next-method  Call next-least-specific method from a method fn.
  fn next-method-p     Test for presence of a next-least-specific method.
  gf no-next-method    Called by call-next-method when none exists.
  mc define-method-combination
  gf compute-effective-method: gf x method-combination x ap-mthds -> eff-mthd

"Parameter specializer name": class name or (eql FORM) list.
Parameter specializer names are present in defmethod &kin, and
may include code to be evaluated to produce the final
parameter specializer.

"Parameter specializer":
  A class C: Arg matches iff it is an instance of C or a subclass of C.
  (eql X)    Arg matches iff it is 'eql' to X.
Parameter specializers are lower-level fixed values.  The class 't'
will always match any argument.


 ************************************************************************/




/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Tunable parameters: */

/* Stuff you shouldn't need to fiddle with: */



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static void     for_new(    Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_cdf( Vm_Unt );

static Vm_Obj	cdf_key(           Vm_Obj	   );

static Vm_Obj	cdf_set_key(               Vm_Obj, Vm_Obj );



/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property cdf_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"key",			cdf_key,	        cdf_set_key	},

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class cdf_Hardcoded_Class = {
    OBJ_FROM_BYT3('c','d','f'),
    "MosClass",
    sizeof_cdf,
    for_new,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { cdf_system_properties, cdf_system_properties, NULL, NULL },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void cdf_doTypes(void){}
Obj_A_Module_Summary cdf_Module_Summary = {
    "cdf",
    cdf_doTypes,
    cdf_Startup,
    cdf_Linkup,
    cdf_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    --- Generic public fns ---					*/
/************************************************************************/


/************************************************************************/
/*-    cdf_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
cdf_Startup(
    void
) {

    static int done_startup = FALSE;
    if        (done_startup)   return;
    done_startup	    = TRUE;
}



/************************************************************************/
/*-    cdf_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
cdf_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}



/************************************************************************/
/*-    cdf_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
cdf_Shutdown(
    void
) {
    static int done_shutdown = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	     = TRUE;
}


#ifdef OLD

/************************************************************************/
/*-    cdf_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
cdf_Import(
    FILE* fd
) {
    MUQ_FATAL ("cdf_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    cdf_Export -- Write object into textfile.			*/
/************************************************************************/

void
cdf_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("cdf_Export unimplemented");
}


#endif








/************************************************************************/
/*-    --- Core static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new cdf object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt slots
) {
    /* Initialize ourself: */
    {   Cdf_P s 	    = CDF_P(o);

	s->key              = OBJ_NIL;

	vm_Dirty(o);
    }
}



/************************************************************************/
/*-    sizeof_cdf -- Return size of structure definition.		*/
/************************************************************************/

static Vm_Unt
sizeof_cdf(
    Vm_Unt slots
) {
    return sizeof( Cdf_A_Header );
}




/************************************************************************/
/*-    --- Prop static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    cdf_key								*/
/************************************************************************/

static Vm_Obj
cdf_key(
    Vm_Obj o
) {
    return CDF_P(o)->key;
}

/************************************************************************/
/*-    cdf_set_key	         					*/
/************************************************************************/

static Vm_Obj
cdf_set_key(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_OBJ(v) && OBJ_IS_CLASS_KEY(v)) {
        CDF_P(o)->key = v;
        vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/

/************************************************************************/
/*-    									*/
/************************************************************************/

/* The core human experience
   is the endless struggle
   to maintain the illusion
   of significance.		*/



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
