@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Mos Syntax Fns, Mos Syntax Fns Overview, Muf Syntax Fns Wrapup, Top
@chapter Muf Compiler

@menu
* Mos Syntax Fns Overview::
* Mos Syntax Fns Source::
* Mos Syntax Fns Wrapup::
@end menu

@c
@node Mos Syntax Fns Overview, Mos Syntax Fns Source, Mos Syntax Fns, Mos Syntax Fns
@section Mos Syntax Fns Overview

This chapter documents the syntax functions
supporting the Muq Object System for
the in-db (@sc{muf}) implementation of the
@sc{muf} compiler, and includes all the source for
them.  You most definitely do not need to read or
understand this chapter in order to write
application code in @sc{muf}, but you may find it
interesting if you are curious about the internals
of the @sc{muf} compiler, or are interested in
writing a Muq compiler of your own.

@c
@node Mos Syntax Fns Source, Mos Syntax Fns Wrapup, Mos Syntax Fns Overview, Muf Compiler
@section Mos Syntax fns Source

Here it is, the complete source.

Eventually, I intend to have the source more
intricately formatted in literate-programming
style, but for now you get it in one great glob:

@example  @c

( - 150-C-muf-syntax.muf -- Class syntax for "Multi-User Forth".	)
( - This file is formatted for outline-minor-mode in emacs19.		)
( -^C^O^A shows All of file.						)
(  ^C^O^Q Quickfolds entire file. (Leaves only top-level headings.)	)
(  ^C^O^T hides all Text. (Leaves all headings.)			)
(  ^C^O^I shows Immediate children of node.				)
(  ^C^O^S Shows all of a node.						)
(  ^C^O^D hiDes all of a node.						)
(  ^HFoutline-mode gives more details.					)
(  (Or do ^HI and read emacs:outline mode.)				)


( =====================================================================	)
( - Dedication and Copyright.						)

(  -------------------------------------------------------------------  )
(									)
(		For Firiss:  Aefrit, a friend.				)
(									)
(  -------------------------------------------------------------------  )

(  -------------------------------------------------------------------	)
( Author:       Jeff Prothero						)
( Created:      96Aug17							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1997, by Jeff Prothero.				)
( 									)
(  This program is free software; you may use, distribute and/or modify	)
(  it under the terms of the GNU Library General Public License as      )
(  published by	the Free Software Foundation; either version 2, or at   )
(  your option	any later version FOR NONCOMMERCIAL PURPOSES.		)
(									)
(  COMMERCIAL operation allowable at $100/CPU/YEAR.			)
(  COMMERCIAL distribution (e.g., on CD-ROM) is UNRESTRICTED.		)
(  Other commercial arrangements NEGOTIABLE.				)
(  Contact cynbe@@eskimo.com for a COMMERCIAL LICENSE.			)
( 									)
(    This program is distributed in the hope that it will be useful,	)
(    but WITHOUT ANY WARRANTY; without even the implied warranty of	)
(    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the	)
(    GNU Library General Public License for more details.		)
( 									)
(    You should have received a copy of the GNU General Public License	)
(    along with this program: COPYING.LIB; if not, write to:		)
(       Free Software Foundation, Inc.					)
(       675 Mass Ave, Cambridge, MA 02139, USA.				)
( 									)
( Jeff Prothero DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,	)
( INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN	)
( NO EVENT SHALL JEFF PROTHERO BE LIABLE FOR ANY SPECIAL, INDIRECT OR	)
( CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS	)
( OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,		)
( NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION	)
( WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.				)
( 									)
( Please send bug reports/fixes etc to bugs@@muq.org.			)
(  -------------------------------------------------------------------	)

( =====================================================================	)
( - Quotation								)
(									)
(  Gaul was in the domain of science the promised			)
(  land of teaching and learning;  this presumably			)
(  was due to the peculiar development and to the			)
(  powerful influence of the national					)
(  priesthood. Druidism was by no means a naive				)
(  popular faith, but a highly developed and				)
(  pretentious theology, which in the good				)
(  church-fashion strove to enlighten, or at any rate			)
(  control, all spheres of human thought and action,			)
(  physics and metaphysics, law and medicine; which			)
(  demanded of its scholars unwearied study, it was			)
(  said, for twenty years, and sought and found these			)
(  its scholars pre-eminently in the ranks of the			)
(  nobility. 								)
(									)
(  [...]								)
(									)
(  But the Romano-Hellenic culture, though perhaps			)
(  forced on the nation and recieved at first with			)
(  opposition, penetrated, as gradually the				)
(  antagonism wore off, so deeply into the Celtic			)
(  character, that in time the scholars applied				)
(  themselves to it more zealously than the teachers.			)
(  The training of a gentleman, somewhat after the			)
(  manner in which it at present exists in England,			)
(  based on the study of Latin and in the second			)
(  place of Greek, and vividly reminding us in the			)
(  development of the school-speach, with its finely			)
(  cut points and brilliant phrases, of more recent			)
(  literary phenomena springing from the same soil,			)
(  became gradually in the West a sort of chartered			)
(  right of the Gallo-Romans.  The teachers were			)
(  probably at all times better paid than in Italy,			)
(  and above all were better treated.					)
(									)
(  -- Theodor Mommsen,							)
(     The Provinces of the Roman Empire					)
(     p112-3								)
(									)
( So, the roots of the modern university may reach a			)
( lot deeper than one would at first suspect!  Could			)
( cultural continuity of a multi-millenial Celtic			)
( tradition of scholarship be relevant to Scottish			)
( achievements in physics?						)
(									)
( =====================================================================	)

( =====================================================================	)
( - Select MUF Package:							)

"muf" inPackage

( =====================================================================	)
( - Types -								)



( =====================================================================	)
( - Support fns -							)

( =====================================================================	)
( - |parseDefclassPreamble --						)
:   |parseDefclassPreamble { [] $ $ -> [] $ $ }
    -> fa -> fn ( Continuation for options )

    ( Parse the class options: )
    |length -> lim
    1 -> loc
    do{
        loc lim = if loopFinish fi
	loc |dupNth -> key
	key :slot = if loopFinish fi
	++ loc
        loc lim = if "Missing keyword value" simpleError fi
	loc |dupNth -> val
	key :initarg = if
	    ++ loc
	    loc lim = if "Missing keyword value" simpleError fi
	    loc |dupNth -> val2
        else
	    nil -> val2
        fi
	fn if fa key val val2 fn call{ $ $ $ $ -> $ } -> fa fi
	++ loc
    }
    loc fa
;

( =====================================================================	)
( - |parseDefclassSlots --						)
:   |parseDefclassSlots { [] $ $ $ $ $ $ -> [] $ $ }
    -> optnFa -> optnFn  ( Continuation for slots			)
    -> slotFa -> slotFn  ( Continuation for slot options		)
    -> slot		   ( -1 initially, incremented at each ":slot"	)
    -> loc		   ( argblock offset at which to start scan	)

    ( How many args in argblock? )
    |length -> lim

    ( Parse the class slots: )
    do{
        loc lim = if slotFa optnFa return fi
 	loc |dupNth :slot != if "Missing :slot keyword" simpleError fi
 	++ slot
 	++ loc
 	loc |dupNth -> slotSym
 	slotSym symbol? not if "Slot name must be a symbol" simpleError fi
 	++ loc
 	slotFn if
            slotFa slotSym slot slotFn call{ $ $ $ -> $ } -> slotFa
        fi

	( Parse the slot options: )
 	do{
	    loc lim = if slotFa optnFa return fi
 	    loc |dupNth -> key
 	    key :slot = if loopFinish fi
 	    ++ loc
 	    loc lim = if "Missing keyword value" simpleError fi
 	    loc |dupNth -> val
 	    optnFn if
                 optnFa key val slot optnFn call{ $ $ $ $ -> $ } -> optnFa
            fi
 	    ++ loc
 	}
     }
     slotFa optnFa
;

( =====================================================================	)
( - buildClassHelperFunctions -- xxx? is-a-xxx			)
:   buildClassHelperFunctions { $ -> }
    -> cdf

    ( We should prolly re-use some  )
    ( other assembler, but for now: )
    makeAssembler -> asm

    cdf.key    -> key
    key.export -> exprt

    ( Build predicate function: )
    cdf.name "?" join -> predicateName
    predicateName intern -> predicateSymbol
    exprt if predicateSymbol export fi
    asm reset
    cdf               asm assembleConstant
    'thisStructure? asm assembleCall
    makeFunction   -> fn
    predicateName --> fn.name
    "( ]defclass generated predicate )" --> fn.source
    nil -1 fn asm finishAssembly -> cfn
    cfn --> key.predicate
    cfn --> predicateSymbol.function

    ( Build assert function too: )
(   "is-a-" cdf.name join -> assertionName )
    "isA" vals[ cdf.name vals[
	 0 |dupNth
	 upcase
	 0 |setNth
    ]|join ]join -> assertionName
    assertionName intern -> assertionSymbol
    exprt if assertionSymbol export fi
    asm reset
    cdf                 asm assembleConstant
    'isThisStructure asm assembleCall
    makeFunction -> fn
    assertionName  --> fn.name
    "( ]defsclass generated assertion )" --> fn.source
    nil -1 fn asm finishAssembly -> cfn
    cfn --> key.assertion
    cfn --> assertionSymbol.function
;

( =====================================================================	)
( - figurePrecedenceList[ -- Starting with parents list in mosKey	)
:   figurePrecedenceList[   { $ -> [] }
    -> mosKey

    ( Get list of parents: )
    mosKey mosKeyParents[

    ( Count parents: )
    |length -> parents

    ( Add self at start of parents list: )
    mosKey.mosClass |unshift

    ( Expand to block of pairs, representing )
    ( explicitly the ordering constraints:   )
    |abcAbbc

    ( Append to block precedence list of each parent: )
    for i from 0 below parents do{

	mosKey i getMosKeyParent -> p
	p.key mosKeyPrecedenceList[
	    |abcAbbc	( Expand to block of pairs.		)
	]|join	 	( Merge into single block of pairs.	)

	( Eliminate redundancies.  It would be faster )
	( to do this once at the end than each step,  )
	( but I'm more worried about running out of   )
	( stack space than about compile time:        )
	|pairsSort
	|pairsUniq
    }

    ( Reduce block of pairwise constraints to )
    ( canonical precedence list using special )
    ( topological sort prescribed by Common   )
    ( Lisp the Language 2nd Ed p784:          )
    |tsortMos not if
	"Illegal combination of superclasses" simpleError
    fi
;

( =====================================================================	)
( - figureUnsharedSlots[ -- 						)
:   figureUnsharedSlots[   { $ -> [] }
    -> ancestor

    ( We are given a precedence list as an ephemeral vector; )
    ( We return a block of SYMBOL,ANCESTOR pairs, where each )
    ( SYMBOL names an unshared slot, and each		     )
    ( ANCESTOR is an integer index into the ancestor vector  )
    ( identifying the ancestor containing that slot.         )

    ( Start with an empty list: )
    [ |

    ( Over every ancestor of class, including class itself: )
    ancestor foreach i a do{

	( Over every unshared slot in ancestor: )
	a -> k
	k mosClass? if k.key -> k fi
	k.unsharedSlots -> unsharedSlots
	for j from 0 below unsharedSlots do{

	    ( If slot was not inherited: )
	    k :inherited j getMosKeySlotProperty not if

		( Push name and ancestor for )
		( slot into result block:    )
		k :symbol j getMosKeySlotProperty |push
		i |push
	    fi
	}
    }

    ( Sort pairs by both components of pair. )
    ( This will result in slots of the same  )
    ( name sorting together, but with the    )
    ( most specific slot sorting first:      )
    |pairsSort

    ( Drop all but the first slot of a given     )
    ( name. This implements shadowing correctly, )
    ( keeping only the most specific example of  )
    ( each slot with a given name:               )
    |keysvalsUniq
;

( =====================================================================	)
( - figureSharedSlots[ -- 						)
:   figureSharedSlots[   { $ -> [] }
    -> ancestor

    ( Almost identical to figureUnsharedSlots[ )
    [ |
    ancestor foreach i a do{
	a -> k
	k mosClass? if k.key -> k fi

	k.unsharedSlots            -> unsharedSlots
	k.sharedSlots              -> sharedSlots
	unsharedSlots sharedSlots + -> totalSlots
	for j from unsharedSlots below totalSlots do{
	    k :inherited j getMosKeySlotProperty not if
		k :symbol j getMosKeySlotProperty |push
		i |push
	    fi
	}
    }
    |pairsSort
    |keysvalsUniq
;

( =====================================================================	)
( - figureInitargs[ -- 						)
:   figureInitargs[   { $ -> [] }
    -> ancestor

    [ |
    ancestor foreach i a do{
	a -> k
	k mosClass? if k.key -> k fi
	k.initargs -> initargs
	for j from 0 below initargs do{
	    k j getMosKeyInitarg -> val -> key
	    key |push
	    val |push
    }	}
    |pairsSort
    |pairsUniq
;

( =====================================================================	)
( - figureClassMethods[ -- 						)
:   figureClassMethods[   { $ -> [] }
    -> ancestor

    [ |
    ancestor foreach i a do{
	a -> k
	k mosClass? if k.key -> k fi
	k.classMethods -> classMethods
	for j from 0 below   classMethods do{
	    k j getMosKeyClassMethod -> mtd -> gfn -> argno

	    ( Here we do an icky O(N^2) insertion sort )
	    ( to keep methods sorted by specificity,   )
	    ( so that searching them in order at run-  )
	    ( time will let us take the first match:   )
	    |length -> lim
	    0       -> m
	    do{
		m lim = if
		    ( Insert method at end of block: )
		    gfn |push
		    mtd |push
		    loopFinish
		fi

		m    |dupNth -> gfnM
		m 1+ |dupNth -> mtdM

		gfn gfnM = if
		    mtd mtdM methodsMatch? -> order if
			order 0 = if
			    ( Ignore method, it has same specializers )
			    ( as previous method.  Since every class  )
			    ( duplicates all methods of its ancestors )
			    ( this will happen pretty frequently...   )
			    loopFinish
			fi
			order -1 = if
			    ( Method mtd is more specific than mtdM, )
			    ( so insert it immediately before  mtdM: )
			    gfn m    |pushNth
			    mtd m 1+ |pushNth
			    loopFinish
		fi  fi  fi

		m 2 + -> m
    }	}   }
;

( =====================================================================	)
( - makeUpdatedMosKey -- Compute up-to-date version of existing key	)
:   makeUpdatedMosKey   { $ -> $ }
    -> oldKey


    ( Our canonical purpose here is to update a mosKey )
    ( after one of its ancestors has changed, computing )
    ( an appropriate new precedence list &tc.  However, )
    ( makeUpdatedMosKey is intended to be a general  )
    ( key synthesis routine, also used for creating the )
    ( original key for a new class, for example, so we  )
    ( try to write it in a fairly general fashion.      )

    ( First task is to compute precedence list: )
    oldKey figurePrecedenceList[ ]evec -> ancestor

    ( Now compute complete set of unshared slots for class: )
    ancestor figureUnsharedSlots[
    |dup[
    |keys ]evec -> nameForUnsharedSlot
    |vals ]evec -> ancestorForUnsharedSlot

    ( Ditto with shared slots for class: )
    ancestor figureSharedSlots[
    |dup[
    |keys ]evec -> nameFoSsharedSlot
    |vals ]evec -> ancestorForSharedSlot


    ( Much the same with initargs: )
    ancestor figureInitargs[
    |dup[
    |keys ]evec -> initargKey
    |vals ]evec -> initargVal

    ( Object methods cannot be inherited, so )
    ( we don't need to compute them, but can )
    ( merely copy them verbatim from oldKey )

    ( Class methods are inherited, so figure )
    ( updated, properly sorted list of them: )
    ancestor figureClassMethods[
    |dup[
    |keys ]evec -> classGfn
    |vals ]evec -> classMethod


    ( Create mosKey to hold result: )
    oldKey.mosClass            ( Mos-class       )
    nameForUnsharedSlot length2 ( Unshared slots  )
    nameFoSsharedSlot   length2 (   Shared slots  )
    oldKey.mosParents          ( Parents         )
    ancestor               length2 ( Ancestors       )
    0                              ( Slotargs        )
    0                              ( Methargs        )
    initargKey            length2 ( Initargs        )
    oldKey.objectMmethods       ( Object-methods  )
    classGfn              length2 ( Class-methods   )
    makeMosKey -> newKey



    ( Copy random scalar info )
    ( from old to new key:    )

    oldKey.name                --> newKey.name
    oldKey.type                --> newKey.type
    oldKey.layout              --> newKey.layout
    oldKey.compiler            --> newKey.compiler

    oldKey.documentation       --> newKey.documentation
    oldKey.source              --> newKey.source
    oldKey.fileName           --> newKey.fileName
    oldKey.fnLine             --> newKey.fnLine

    oldKey.assertion           --> newKey.assertion
    oldKey.predicate           --> newKey.predicate
    oldKey.printFunction      --> newKey.printFunction
    oldKey.createdAnInstance --> newKey.createdAnInstance

    oldKey.concName           --> newKey.concName
    oldKey.constructor         --> newKey.constructor
    oldKey.copier              --> newKey.copier
    oldKey.named               --> newKey.named

    oldKey.initialOffset      --> newKey.initialOffset
    oldKey.export              --> newKey.export
    oldKey.abstract            --> newKey.abstract
    oldKey.fertile             --> newKey.fertile
    oldKey.metaclass           --> newKey.metaclass



    ( Copy unshared slot info into newKey: )
    nameForUnsharedSlot length2 -> lim
    for i from 0 below lim do{
	nameForUnsharedSlot[i]     -> sym
	ancestorForUnsharedSlot[i] -> j
	ancestor[j] -> a
	a mosClass? if a.key -> a fi
	a sym findMosKeySlot -> s
	newKey i a s copyMosKeySlot
	newKey   :inherited   i   j 0 !=   setMosKeySlotProperty
    }

    ( Copy shared slot info into newKey: )
    nameForUnsharedSlot length2 -> base
    nameFoSsharedSlot   length2 -> lim
    for i from 0 below lim do{
	nameFoSsharedSlot[i]     -> sym
	ancestorForSharedSlot[i] -> j
	ancestor[j] -> a
	a mosClass? if a.key -> a fi
	a sym findMosKeySlot -> s
	newKey                    base i +   a s  copyMosKeySlot
	j 0 != if
	    ( In a shared, inherited slot, )
	    ( initval is key holding value )
	    ( initform slot# holding value )
	    newKey   :inherited   base i +   t    setMosKeySlotProperty
	    newKey   :initval     base i +   a    setMosKeySlotProperty
	    newKey   :initform    base i +   s    setMosKeySlotProperty
	fi
    }

    ( Copy parent info into newKey: )
    oldKey.mosParents -> lim
    for i from 0 below lim do{
	newKey i   oldKey i getMosKeyParent   setMosKeyParent
    }

    ( Copy precedence list into newKey.  )
    ( We also link newKey to ancestors   )
    ( and   unlink oldKey from ancestors )
    ( as we do so:                        )
    ancestor length2 -> lim
    for i from 0 below lim do{
	ancestor[i] -> a
	a mosKey? if a.mosClass -> a fi
	newKey i a setMosKeyAncestor
	newKey i linkMosKeyToAncestor 
    }
    oldKey.mosAncestors -> lim
    for i from 0 below lim do{
	oldKey i unlinkMosKeyFromAncestor 
    }

    ( Copy initargs into newKey: )
    initargKey length2 -> lim
    for i from 0 below lim do{
	newKey i initargKey[i] initargVal[i] setMosKeyInitarg
    }

    ( Copy object methods into newKey: )
    oldKey.objectMmethods -> lim
    for i from 0 below lim do{
	oldKey i getMosKeyObjectMethod -> obj -> mtd -> gfn -> argno
	newKey i argno gfn mtd obj setMosKeyObjectMethod
    }

    ( Copy class methods into newKey: )
    classGfn length2 -> lim
    for i from 0 below lim do{
	newKey i 0 classGfn[i] classMethod[i] setMosKeyClassMethod
    }

    newKey
;


( =====================================================================	)
( - updateSubclass -- To reflect new definition of a class		)
:   updateSubclass  { $ -> }
    -> oldKey

    ( We need to effectively be owner )
    ( of class to properly update it: )
    asMeDo{
	rootOmnipotentlyDo{
	    oldKey.owner rootAsUserDo{

		( Create updated version of oldKey: )
		oldKey makeUpdatedMosKey -> newKey

		( Mark old key as obsolete: )
		newKey --> oldKey.newerKey

		( Mark new key as current one: )
		newKey --> oldKey.mosClass.key

		( Unlink old key from its ancestors: )
		oldKey.mosAncestors -> lim
		for i from 0 below lim do{
		    oldKey i unlinkMosKeyFromAncestor 
		}

		( Link new key to its ancestors: )
		newKey.mosAncestors -> lim
		for i from 0 below lim do{
		    newKey i linkMosKeyToAncestor 
		}
	    }
	}
    }
;

( =====================================================================	)
( - updateSubclasses -- To reflect new definition of a class		)
:   updateSubclasses  { $ -> }
    -> oldKey

    ( oldKey is either a mosKey which has been obsoleted )
    ( by a newer mosKey, or else one which has just been  )
    ( changed, most likely by overwriting a method slot    )
    ( with a new method.  Either way, any subclasses of it )
    ( need to be updated correspondingly.                  )

    ( Over all subclasses of given class -- or more )
    ( precisely, over all their keys:               )
    oldKey -1 nextMosKeyLink -> thisSlot -> thisKey
    do{ thisKey oldKey = until

	( Note next link in chain: )
	thisKey thisSlot nextMosKeyLink -> nextSlot -> nextKey

	( We are not doing locking at present, so  )
	( oddities are possible.  I'm not worrying )
	( much about this, but the following may   )
	( prevent some infinite loops:             )
	thisSlot -1 = if
	    oldKey currentCompiledFunction call{ $ -> }
	    return
	fi

	( Update subclass appropriately: )
	thisKey updateSubclass

	( Step to next subclass: )
	nextSlot -> thisSlot
	nextKey  -> thisKey
    }
;


( =====================================================================	)
( - Offsets for |surveyClassdef state record				)

0  -->constant surveySlot
1  -->constant surveySeenAllocation
2  -->constant surveyClassSlots
3  -->constant surveyInitargs
4  -->constant surveyParents


( =====================================================================	)
( - surveyClassdefPreamble -- 					)
:   surveyClassdefPreamble { $ $ $ $ -> $ }
    -> val2	( initialValue if key == :nitarg, otherwise nil.	)
    -> val	( Value corresponding to 'key' -- string or symbol	)
    -> key	( One of :isA/:is/... :metaclass :documentation :initarg )
    -> rec	( State record containing our counts.			)

    ( Count parents and initargs: )
    key case{
    on: :isA      rec[surveyParents] 1+ --> rec[surveyParents]
    on: :is       rec[surveyParents] 1+ --> rec[surveyParents]
    on: :has      rec[surveyParents] 1+ --> rec[surveyParents]
    on: :hasA     rec[surveyParents] 1+ --> rec[surveyParents]
    on: :initarg  ( Buggo -- what happens to this info? )
    on: :metaclass
    on: :documentation
    on: :abstract
    on: :fertile
    on: :export
    else:
	"Bad defclass preamble option" simpleError
    }

    rec
;

( =====================================================================	)
( - surveyClassdefSlot -- 						)
:   surveyClassdefSlot { $ $ $ -> $ }

    -> slot      ( Int: zero for first slot. )
    -> slotSym  ( Symbol naming slot.       )
    -> rec       ( Five-slot vector as above )

    slot --> rec[surveySlot]
    nil  --> rec[surveySeenAllocation]

    rec
;


( =====================================================================	)
( - surveyClassdefSlotOption -- 					)
:   surveyClassdefSlotOption { $ $ $ $ -> $ }

    -> slot
    -> val
    -> key
    -> rec

    key :allocation = if
        rec[surveySeenAllocation] if
            "Can't have two :allocation entries for one slot" simpleError
	fi
	t --> rec[surveySeenAllocation]
	val case{
	on: :class  rec[surveyClassSlots] 1+ --> rec[surveyClassSlots]
	on: :instance
	else:
	    "Unrecognized :allocation setting" simpleError
	}
    fi

    key :initarg = if
	rec[surveyInitargs] 1+ --> rec[surveyInitargs]
    fi

    rec
;



( =====================================================================	)
( - |surveyClassdef -- Count slots &tc in classdef			)
:   |surveyClassdef { [] -> [] $ $ $ $ $ }

    ( Our job here is just to compute the number  )
    ( of slots, initargs &tc directly declared in )
    ( the classdef -- we're not worrying about    )
    ( the number of inherited slots &tc yet.      )

    ( Allocate an ephemeral )
    ( vec as scratchpad:    )
    [ -1	( slotNumber		)
      nil	( seenAllocation	)
      0		( classSlotsSeen	)
      0		( initargsSeen		)
      0		( parentsSeen		)
    | ]evec -> rec

    ( Count parents in preamble: )
    'surveyClassdefPreamble rec |parseDefclassPreamble -> rec -> loc

    loc
    -1   ( slot )
    'surveyClassdefSlot        rec 
    'surveyClassdefSlotOption rec
    |parseDefclassSlots pop pop

    ( Return results: )
    loc
    rec[surveyInitargs]
    rec[surveyParents]
    rec[surveyClassSlots]
    rec[surveySlot] 1+ rec[surveyClassSlots] -
;

( =====================================================================	)
( - |noteClassdefSlotAllocations -- Note which slots are un/shared	)
:   |noteClassdefSlotAllocations { [] $ $ -> [] }
    -> loc
    -> allocation

    loc
    -1   ( slot )
    :: pop pop pop nil ;        nil
    :: -> slot -> val -> key -> allocation
       key :allocation = if val --> allocation[slot] fi
       allocation
    ;  allocation
    |parseDefclassSlots pop pop
;

( =====================================================================	)
( Offsets for |cacheClassdef state record				)

0  -->constant cacheSlot	   ( 0 - N-1 )
1  -->constant cacheSlotType     ( :class or :instance )
2  -->constant cacheAllocation    ( n-slot vector holding :class/:instance )
3  -->constant cacheClassSlot    ( current class slot )
4  -->constant cacheInstanceSlot ( current instance slot )
5  -->constant cacheInitarg	   ( current initarg slot )
6  -->constant cacheParent	   ( current parent slot )
7  -->constant cacheKey	   ( result object )


( =====================================================================	)
( - cacheClassdefPreamble -- 						)
:   cacheClassdefPreamble { $ $ $ $ -> $ }
    -> val2	( initialValue if key == :nitarg, otherwise nil.	)
    -> val	( Value corresponding to 'key' -- string or symbol	)
    -> key	( One of :isA/:is/... :metaclass :documentation :initarg )
    -> rec	( State record containing our counts.			)

    rec[cacheKey] -> tmpKey

    ( Count parents and initargs: )
    key case{

    on: :isA
	rec[cacheParent] 1+ -> p
	p --> rec[cacheParent]
	tmpKey p val$s.type setMosKeyParent

    on: :is
	rec[cacheParent] 1+ -> p
	p --> rec[cacheParent]
	tmpKey p val$s.type setMosKeyParent

    on: :has
	rec[cacheParent] 1+ -> p
	p --> rec[cacheParent]
	tmpKey p val$s.type setMosKeyParent

    on: :hasA
	rec[cacheParent] 1+ -> p
	p --> rec[cacheParent]
	tmpKey p val$s.type setMosKeyParent

    ( Buggo -- need some initarg hacks here someday )

    on: :metaclass
	val --> tmpKey.metaclass

    on: :documentation
	val --> tmpKey.documentation

    on: :abstract
	val --> tmpKey.abstract

    on: :fertile
	val --> tmpKey.fertile

    on: :export
	val --> tmpKey.export

    else:
	"Bad defclass preamble option" simpleError
    }

    rec
;

( =====================================================================	)
( - cacheClassdefSlot -- 						)
:   cacheClassdefSlot { $ $ $ -> $ }

    -> slot      ( Int: zero for first slot. )
    -> slotSym  ( Symbol naming slot.       )
    -> rec       ( Five-slot vector as above )

    ( Remember current slot: )
    slot --> rec[cacheSlot]
    rec[cacheAllocation] -> allocation
    rec[cacheKey] -> tmpKey

    ( Look up slot type, :class vs :instance )
    allocation[slot] -> slotType
    slotType --> rec[cacheSlotType]

    ( Bump appropriate slot count, )
    ( and save slot symbol:        )
    slotType :class = if
        rec[cacheClassSlot] 1+ -> ourslot
	ourslot --> rec[cacheClassSlot]
    else
        rec[cacheInstanceSlot] 1+ -> ourslot
	ourslot --> rec[cacheInstanceSlot]
    fi
    tmpKey :symbol ourslot slotSym setMosKeySlotProperty

    rec
;


( =====================================================================	)
( - cacheClassdefSlotOption -- 					)
:   cacheClassdefSlotOption { $ $ $ $ -> $ }

    -> slot
    -> val
    -> key
    -> rec

    rec[cacheKey]        -> tmpKey
    rec[cacheSlotType]   -> slotType
    rec[cacheAllocation] -> allocation
    slotType :class = if
        rec[cacheClassSlot]    -> ourslot
    else
        rec[cacheInstanceSlot] -> ourslot
    fi


    key case{

    on: :allocation
	val slotType = not if "defclass internal err" simpleError fi

    on: :initarg
	rec[cacheInitarg] 1+ -> initarg
	initarg --> rec[cacheInitarg]
	tmpKey :symbol ourslot  getMosKeySlotProperty -> slotSym
	tmpKey initarg val slotSym setMosKeyInitarg

    on: :initval
	tmpKey :initval          ourslot val setMosKeySlotProperty

    on: :initform
	tmpKey :initform         ourslot val setMosKeySlotProperty

    on: :type
	tmpKey :type             ourslot val setMosKeySlotProperty

    on: :reader
	tmpKey :getFunction     ourslot val setMosKeySlotProperty

    on: :writer
	tmpKey :setFunction     ourslot val setMosKeySlotProperty

    on: :accessor
	tmpKey :getFunction     ourslot val setMosKeySlotProperty
	tmpKey :setFunction     ourslot val setMosKeySlotProperty

    on: :documentation
	tmpKey :documentation    ourslot val setMosKeySlotProperty

    on: :rootMayRead
	tmpKey :rootMayRead    ourslot val setMosKeySlotProperty

    on: :rootMayWrite
	tmpKey :rootMayWrite   ourslot val setMosKeySlotProperty

    on: :userMayRead
	tmpKey :userMayRead    ourslot val setMosKeySlotProperty

    on: :userMayWrite
	tmpKey :userMayWrite   ourslot val setMosKeySlotProperty

    on: :classMayRead
	tmpKey :classMayRead   ourslot val setMosKeySlotProperty

    on: :classMayWrite
	tmpKey :classMayWrite  ourslot val setMosKeySlotProperty

    on: :worldMayRead
	tmpKey :worldMayRead   ourslot val setMosKeySlotProperty

    on: :worldMayWrite
	tmpKey :worldMayWrite  ourslot val setMosKeySlotProperty

    on: :prot
	val string? not  if ":prot value must be a string"      simpleError fi
	val length2 6 != if ":prot string must be 6 chars long" simpleError fi
	tmpKey :userMayRead   ourslot val[0] 'r' = setMosKeySlotProperty
	tmpKey :userMayWrite  ourslot val[1] 'w' = setMosKeySlotProperty
	tmpKey :classMayRead  ourslot val[2] 'r' = setMosKeySlotProperty
	tmpKey :classMayWrite ourslot val[3] 'w' = setMosKeySlotProperty
	tmpKey :worldMayRead  ourslot val[4] 'r' = setMosKeySlotProperty
	tmpKey :worldMayWrite ourslot val[5] 'w' = setMosKeySlotProperty

    else:
	"Unrecognized 'defclass' slot option" simpleError
    }

    rec
;

( =====================================================================	)
( - |cacheClassdef -- Copy classdef info into temporary mosKey	)
:   |cacheClassdef { [] $ $ $ -> [] }
    -> tmpKey
    -> allocation
    -> unsharedSlots

    ( Allocate an ephemeral )
    ( vec as scratchpad:    )
    [ -1	 	( slotNumber		)
      :instance  	( slot type		)
      allocation 	( slot types		)
      unsharedSlots 1-	( classSlot		)
      -1	 	( instanceSlot		)
      -1	 	( initarg slot		)
      -1	 	( parent slot		)
      tmpKey    	( result key		)
    | ]evec -> rec

    ( Cache info in preamble: )
    'cacheClassdefPreamble rec |parseDefclassPreamble -> rec -> loc

    ( Cache info in slot declarations: )
    loc
    -1   ( slot )
    'cacheClassdefSlot        rec 
    'cacheClassdefSlotOption rec
    |parseDefclassSlots pop pop

    ( Add implicit parents standardObject and t: )
    tmpKey.mosParents -> parents
    tmpKey parents 1 -               'lisp:t.type setMosKeyParent
    tmpKey parents 2 - 'lisp:standardObject.type setMosKeyParent
;

( =====================================================================	)
( - ]defclass -- Define a class.					)
:   ]defclass { [] -> }


	( Syntax looks like:						)
        ( 'aClassName							)
        ( (* :isA          'anotherClassName 			)
        ( |  :is            'anotherClassName 			)
        ( |  :has           'anotherClassName 			)
        ( |  :hasA         'anotherClassName 			)
        ( |  :metaclass     'metaclassName				)
        ( |  :documentation "some text"					)
        ( |  :fertile       tOrNil					)
        ( |  :abstract      tOrNil					)
        ( |  :export        tOrNil					)
        ( *)								)
        ( (* :slot 'aSlotName						)
        (   (*								)
        (   |   :initval  any						)
        (   |   :initform cfn						)
        (   |   :initarg  'aName					)
        (   |   :type type						)
        (   |   :reader   'readerFnName				)
        (   |   :writer   'writerFnName				)
        (   |   :accessor 'accessorFnName				)
        (   |   :allocation :class					)
        (   |   :allocation :instance					)
        (   |   :documentation "some text"				)
        (   |   :rootMayRead    tOrNil				)
        (   |   :rootMayWrite   tOrNil				)
        (   |   :userMayRead    tOrNil				)
        (   |   :userMayWrite   tOrNil				)
        (   |   :classMayRead   tOrNil				)
        (   |   :classMayWrite  tOrNil				)
        (   |   :worldMayRead   tOrNil				)
        (   |   :worldMayWrite  tOrNil				)
        (   |   :prot		  "rw----"				)
        (   *)								)
        ( *)								)
        ( 								)



	( Pick out the class name: )
	|length 0 = if "Missing class name" simpleError fi
 	0 |dupNth -> classSym
 	classSym symbol? not if
 	    "Class name must be a symbol" simpleError
 	fi

	( Find/create the class definition object: )
	classSym.type -> cdf
	cdf mosClass? not if
	    makeMosClass -> cdf
	    cdf --> classSym.type
	fi
	classSym.name --> cdf.name

	( Make a pass over declaration,  )
        ( counting slots, parents and    )
        ( initargs, so we know how big a )
	( key we need to hold all the    )
        ( declared info:                 )
	|surveyClassdef
	-> unsharedSlots
	-> sharedSlots
	-> parents
	-> totalInitargs
	-> loc

	( Build a vector recording )
        ( allocation of each slot: )
	:instance sharedSlots unsharedSlots + evec -> allocation
	allocation loc |noteClassdefSlotAllocations


	( Create a temporary key to hold )
	( parsed class information. This )
	( is not the final key, since we )
	( don't know how many ancestors, )
	( inherited slots &tc we will    )
	( have.  We add two extra parent )
	( slots, since standardObject   )
	( and t are implicit parents of  )
	( all defclassDefined classes:  )
        cdf            ( Mos-class       )
        unsharedSlots ( Unshared slots  )
        sharedSlots   ( Shared slots    )
        parents 2 +    ( Parents         )
        0              ( Ancestors       )
        0              ( Slotargs        )
        0              ( Methargs        )
        totalInitargs ( Initargs        )
        0              ( Object-methods  )
        0              ( Class-methods   )
        makeMosKey -> tmpKey
	classSym.name --> tmpKey.name
	cdf.key --> oldKey
	tmpKey   --> cdf.key

	( Copy the declaration info into )
	( our temporary mosKey:         )
	unsharedSlots allocation tmpKey |cacheClassdef

	( Compute precedence list &tc,   )
	( and return in a new key:       )
	tmpKey makeUpdatedMosKey -> newKey

	( Enter new key into class obj:  )
	newKey   --> cdf.key

	( If we had an old key, mark it  )
        ( obsolete & update subclasses:  )
	oldKey if
	    newKey --> oldKey.newerKey
	    oldKey updateSubclasses
	fi


	( Export class definition if so requested: )
	newKey.export if classSym export fi

    ]pop

    ( For class xxx, build xxx? &tc: )
    cdf buildClassHelperFunctions
;
']defclass export


( =====================================================================	)
( - Public fns -							)

( =====================================================================	)
( - defclass: -- Define a class						)

:   defclass: { $ -> ! }   -> oldCtx
    compileTime

    ( ------------------------------------------- )
    ( This is just a wrapper around ]defclass.    )
    ( ]defclass is perfectly usable as it stands, )
    ( but I think the prefix "defclass:" syntax   )
    ( fits better with the general pattern of the )
    ( defmethod: ... defgeneric: ... syntax.	  )
    ( ------------------------------------------- )

    oldCtx.symbols -> symbols
    symbols length2 -> symbolsSp

    ( Allocate a new context in which to compile fn: )
    [   :ephemeral  t
        :mss        oldCtx.mss
        :package    @.lib["muf"]
        :symbols    symbols
        :symbolsSp symbolsSp
        :syntax     oldCtx.syntax
    | 'compile:context ]makeStructure -> ctx

    ( Read next token (className) and stash: )
    [ ctx.mss | |scanTokenToNonwhitespace ]pop
    [ ctx.mss | |scanTokenToWhitespace
    |popp ( lineloc )
    |readTokenChars   ( Get token chars as block. )
    |backslashesToHighbit
(   |downcase )
    ]join    ->   className

    -1 --> ctx.arity

    ( Mark scope on stack: )
    0 ctx compile:pushColon

    ( Assemble an implicit startOfBlock: )
    'startBlock ctx.asm assembleCall

    ( Assemble className as a symbol: )
    className ctx.asm assembleConstant
    'intern   ctx.asm assembleCall

    ( Loop compiling classdef body.   We    )
    ( exit this loop by compileSemi doing  )
    ( a GOTO to semiTag when we hit a ';': )
    withTag semiTag do{
        do{
            compile:modeGet ctx compilePath
        }
        semiTag
    }

    ( Assemble an implicit endOfBlock: )
    'endBlock ctx.asm assembleCall

    ( Assemble an implicit ]defclass: )
    ']defclass ctx.asm assembleCall

    ( Finish assembly to produce  )
    ( a compiled function:        )
    nil -1 makeFunction ctx.asm finishAssembly -> cfn

    ( Pop any nested symbols off symbol stack: )
    do{ symbols length2  symbolsSp = until
        symbols pull -> sym
    }

    ( Save assembler for possible re-use: )
    ctx.asm --> @.spareAssembler

    ( Deposit code to invoke compiled function. )
    ( Invoking it directly would defeat, for    )
    ( example, a nested rootOmnipotentlyDo{}: )
    cfn oldCtx.asm assembleCall
;
'defclass: export

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

@c
@node Mos Syntax Fns Wrapup, Function Index, Mos Syntax Fns Source, Mos Syntax Fns
@section Mos Syntax Fns Wrapup

This completes the in-db @sc{muf}-compiler Mos Object System support chapter.
If you have questions or suggestions, feel free to email cynbe@@muq.com.


