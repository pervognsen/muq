@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)
@example  @c

( - 030-C-struct.muf -- Core functions on structures.			)
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

(  -------------------------------------------------------------------  )
( Author:       Jeff Prothero						)
( Created:      95Sep25							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1996, by Jeff Prothero.				)
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

( - Public fns								)

"muf" inPackage

( =====================================================================	)
( - ]doStructureInitforms --						)
: ]doStructureInitforms { [] $ $ -> $ } -> stc -> sdf

    ( Perform any initform fn calls )
    ( needed to initialize slots:   )
    do{
	|length 0 = until
	|pop -> cfn
	|pop -> slot
	stc cfn call{ -> $ } sdf slot setNthStructureSlot
    }
    ]pop
    
    ( Return new structure: )
    stc
;
']doStructureInitforms export

( =====================================================================	)
( - |parseDefstructPreamble --					)
: |parseDefstructPreamble { [] $ $ -> [] $ $ }
     -> fa -> fn ( Continuation for options )

    ( Parse the structure options: )
    |length -> lim
    1 -> loc
    do{
        loc lim = if loopFinish fi
	loc |dupNth -> key
	key keyword? not if loopFinish fi
	++ loc
        loc lim = if "Missing keyword value" simpleError fi
	loc |dupNth -> val
	fn if fa key val fn call{ $ $ $ -> $ } -> fa fi
	++ loc
    }
    loc fa
;

( =====================================================================	)
( - |parseDefstructSlots --						)
: |parseDefstructSlots { [] $ $ $ $ $ $ -> [] $ $ }
    -> optnFa -> optnFn   ( Continuation for slots        )
    -> slotFa -> slotFn   ( Continuation for slot options )
    -> slot    -> loc

    ( How many args in argblock? )
    |length -> lim

    ( Parse the structure slots: )
    do{
        loc lim = if slotFa optnFa return fi
	loc |dupNth -> slotSym
	slotSym symbol? not if "Slot name must be a symbol" simpleError fi
	++ loc
	slotFn if
            slotFa
            slotSym
            slot
            slotFn
            call{ $ $ $ -> $ }
            -> slotFa
        fi

	( Parse the structure slot options: )
	do{
	    loc lim = if slotFa optnFa return fi
	    loc |dupNth -> key
	    key keyword? not if loopFinish fi
	    ++ loc
	    loc lim = if "Missing keyword value" simpleError fi
	    loc |dupNth -> val
	    optnFn if optnFa key val slot optnFn call{ $ $ $ $ -> $ } -> optnFa fi
	    ++ loc
	}

	++ slot
    }
    slotFa optnFa
;

( =====================================================================	)
( - saveDefstructOption -- Store a parsed defstruct option.		)
:   saveDefstructOption { $ $ $ -> $ }

    -> val
    -> key
    -> structDef

    key case{

    on: :concName
	val string? not if
	    ":concName value must be a string" simpleError
	fi
	val --> structDef.concName

    on: :constructor
	val symbol? not if
	    ":constructor value must be a symbol" simpleError
	fi
	val.name --> structDef.constructor

    on: :copier
	val symbol? not if
	    ":copier value must be a symbol" simpleError
	fi
	val.name --> structDef.copier

    on: :assertion
	val symbol? not if
	    ":assertion value must be a symbol" simpleError
	fi
	val.name --> structDef.assertion

    on: :predicate
	val symbol? not if
	    ":predicate value must be a symbol" simpleError
	fi
	val.name --> structDef.predicate

    on: :include
	val symbol? not if
	    ":include value must be a symbol" simpleError
	fi
	val --> structDef.include

    on: :printFunction
	val callable? not if
	    ":printFunction value must be callable" simpleError
	fi
	val --> structDef.printFunction

    on: :type
	( We handle types like '(vector t) as )
	( being identical to 'vector, etc:    )
	val cons? if val car -> val fi
	val case{	
	on: 'vector   'vector --> structDef.type
	on: 'list     'list   --> structDef.type
	else:
	    ":type value must 'vector or 'list" simpleError
	}
	val --> structDef.type

    on: :named
	val symbol? not if
	    ":named value must be a symbol" simpleError
	fi
	val --> structDef.named

    on: :initialOffset
	val integer? not if
	    ":initialOffset value must be an integer" simpleError
	fi
	val 0 < if
	    ":initialOffset value must be >= 0" simpleError
	fi
	val --> structDef.initialOffset

    on: :export
	val --> structDef.export

    else:
	"Unrecognized 'defstruct' option" simpleError
    }

    structDef
;

( =====================================================================	)
( - saveDefstructSlot -- Store a parsed defstruct slot.		)
:   saveDefstructSlot { $ $ $ -> $ }

    -> slot
    -> slotSym
    -> structDef

    ( Construct symbol corresponding to name of slotSym: )
    slotSym.name stringKeyword -> slotSymbol

    ( Save symbol in structure definition slot: )
    structDef :symbol slot slotSymbol setMosKeySlotProperty

    structDef
;

( =====================================================================	)
( - saveDefstructSlotOption -- Store a parsed slot option.		)
:   saveDefstructSlotOption { $ $ $ $ -> $ }

    -> slot
    -> val
    -> key
    -> structDef

    key case{

    on: :initval
	structDef :initval  slot val setMosKeySlotProperty

    on: :initform
	structDef :initform slot val setMosKeySlotProperty

    on: :type
	structDef :type slot val setMosKeySlotProperty

    on: :readOnly
	structDef :userMayWrite slot val not setMosKeySlotProperty


    on: :rootMayRead
	structDef :rootMayRead slot val setMosKeySlotProperty

    on: :rootMayWrite
	structDef :rootMayWrite slot val setMosKeySlotProperty


    on: :userMayRead
	structDef :userMayRead slot val setMosKeySlotProperty

    on: :userMayWrite
	structDef :userMayWrite slot val setMosKeySlotProperty


    on: :classMayRead
	structDef :classMayRead slot val setMosKeySlotProperty

    on: :classMayWrite
	structDef :classMayWrite slot val setMosKeySlotProperty


    on: :worldMayRead
	structDef :worldMayRead slot val setMosKeySlotProperty

    on: :worldMayWrite
	structDef :worldMayWrite slot val setMosKeySlotProperty

    else:
	"Unrecognized 'defstruct' slot option" simpleError
    }

    structDef
;

( =====================================================================	)
( - compileStructDef -- Compile a parsed defstruct.			)

:   compileStructDef { $ -> }
    -> structDef

    structDef.export    -> exprt
    structDef.mosClass -> mosClass

    ( Allocate an assembler    )
    ( to create our functions: )
    makeAssembler  -> asm

    ( Find name of structure: )
    structDef.name -> structName

    ( Get count of slots in structure: )
    structDef.unsharedSlots -> slots

    ( Build constructor function: )
    structDef.constructor -> constructorName
    constructorName if
        constructorName "" = if
(	    "]make-" structName join -> constructorName )
	    "]make" vals[ structName vals[
                 0 |dupNth
                 upcase
                 0 |setNth
             ]|join ]join -> constructorName
	fi
	constructorName intern -> constructorSymbol
	exprt if constructorSymbol export fi
	asm reset
	'|errorIfEphemeral asm assembleCall
	mosClass             asm assembleConstant
	']makeStructure     asm assembleCall
	makeFunction -> fn
	constructorName --> fn.name
	"( ]defstruct generated constructor )" --> fn.source
	nil -1 fn asm finishAssembly -> cfn
	cfn --> structDef.constructor
	cfn --> constructorSymbol.function
    fi

    ( Build copier function: )
    structDef.copier -> copierName
    copierName if
        copierName "" = if
(	    "copy-" structName join -> copierName )
	    "copy" vals[ structName vals[
                 0 |dupNth
                 upcase
                 0 |setNth
             ]|join ]join -> copierName
	fi
	copierName intern -> copierSymbol
	exprt if copierSymbol export fi
	asm reset
	mosClass        asm assembleConstant
	'copyStructure asm assembleCall
	makeFunction -> fn
	copierName  --> fn.name
	"( ]defstruct generated copier )" --> fn.source
	nil -1 fn asm finishAssembly -> cfn
	cfn --> structDef.copier
	cfn --> copierSymbol.function
    fi

    ( Build predicate function: )
    structDef.predicate -> predicateName
    predicateName if
        predicateName "" = if
	    structName "?" join -> predicateName
	fi
	predicateName intern -> predicateSymbol
	exprt if predicateSymbol export fi
	asm reset
	mosClass         asm assembleConstant
	'thisStructure? asm assembleCall
	makeFunction   -> fn
	predicateName --> fn.name
	"( ]defstruct generated predicate )" --> fn.source
	nil -1 fn asm finishAssembly -> cfn
	cfn --> structDef.predicate
	cfn --> predicateSymbol.function
    fi

    ( Build assert function too: )
    structDef.assertion -> assertionName
    assertionName if
        assertionName "" = if
(	    "is-a-" structName join -> assertionName )
	    "isA" vals[ structName vals[
                 0 |dupNth
                 upcase
                 0 |setNth
             ]|join ]join -> assertionName
	fi
	assertionName intern -> assertionSymbol
	exprt if assertionSymbol export fi
	asm reset
	mosClass           asm assembleConstant
	'isThisStructure asm assembleCall
	makeFunction -> fn
	assertionName  --> fn.name
	"( ]defstruct generated assertion )" --> fn.source
	nil -1 fn asm finishAssembly -> cfn
	cfn --> structDef.assertion
	cfn --> assertionSymbol.function
    fi

    ( Build slot reading/writing functions: )
    structDef.concName -> concName
    concName "" = if
	structName ( "-" join ) -> concName
    fi
    for slot from 0 below slots do{

	( Build slot reader: )
	structDef :symbol slot getMosKeySlotProperty -> key
(	concName key.name join -> readerName )
	concName vals[ key.name vals[
	     0 |dupNth
	     upcase
	     0 |setNth
	 ]|join ]join -> readerName

	readerName intern -> readerSymbol
	exprt if readerSymbol export fi
	asm reset
	mosClass                asm assembleConstant
	slot                     asm assembleConstant
	'getNthStructureSlot asm assembleCall
	makeFunction -> fn
	readerName  --> fn.name
	"( ]defstruct generated slotReader )" --> fn.source
	nil -1 fn asm finishAssembly -> cfn
	structDef :getFunction slot cfn setMosKeySlotProperty
	cfn --> readerSymbol.function

	( Build slot writer: )
(	"set-" readerName join -> writerName )
	"set" vals[ readerName vals[
	     0 |dupNth
	     upcase
	     0 |setNth
	]|join ]join -> writerName
	writerName intern -> writerSymbol
	exprt if writerSymbol export fi
	asm reset
	mosClass                asm assembleConstant
	slot                     asm assembleConstant
	'setNthStructureSlot asm assembleCall
	makeFunction -> fn
	writerName  --> fn.name
	"( ]defstruct generated slotWriter )" --> fn.source
	nil -1 fn asm finishAssembly -> cfn
	structDef :setFunction slot cfn setMosKeySlotProperty
	cfn --> writerSymbol.function
    }
;

( =====================================================================	)
( - ]defstruct -- Define a structure.					)
:   ]defstruct { [] -> }

	( Syntax looks like:						)
	( symbol (*							)
	(   :concName      string |					)
	(   :constructor    symbol |					)
	(   :copier         symbol |					)
	(   :assertion      symbol |					)
	(   :predicate      symbol |					)
	(   :include        symbol |					)
	(   :printFunction cfn    |					)
	(   :type           symbol |					)
	(   :named          symbol |					)
	(   :initialOffset symbol |					)
	(   :export         t      *)					)
	( (* symbol (*							)
	(     :initval  any              |				)
	(     :initform cfn              |				)
	(     :type type                 |				)
	(     :readOnly tOrNil        |				)
	(     :rootMayRead    tOrNil |				)
	(     :rootMayWrite   tOrNil |				)
	(     :userMayRead    tOrNil |				)
	(     :userMayWrite   tOrNil |				)
	(     :classMayRead   tOrNil |				)
	(     :classMayWrite  tOrNil |				)
	(     :worldMayRead   tOrNil |				)
	(     :worldMayWrite  tOrNil |				)
	( *) *)								)

	( Pick out the structure name: )
	|length 0 = if "Missing structure name" simpleError fi
	0 |dupNth -> structSym
	structSym symbol? not if
	    "Structure name must be a symbol" simpleError
	fi


        ( We make two passes over the argblock. )
	( The first pass just counts the number )
	( of slots.  With that in hand, we then )
	( create a structure definition of the  )
	( appropriate size.  During the second  )
	( pass, we fill in the structdef based  )
	( on the information in the argblock.   )

	( Pass 1 )

	( Skim the preamble looking for an ':include': )
	::  -> val -> key -> includedSym
	    key :include = if val -> includedSym fi 
	    includedSym
	; nil |parseDefstructPreamble -> includedSym -> loc

	( Count the slots: )
        loc 0 :: -> i pop pop i 1 + ; 0 nil 0 |parseDefstructSlots pop -> slots

	( If we have an :include, count its slots too: )
	0   -> includedSlots
	nil -> includedType
	includedSym if
	    includedSym symbol? not if
		":include value must be a symbol" simpleError
	    fi
	    includedSym.type -> includedClass
	    includedClass mosClass? not if
		":include value must name a structure class" simpleError
	    fi
	    includedClass.key -> includedKey
	    includedKey mosKey? not if
		":include class must have a key" simpleError
	    fi
	    includedKey.unsharedSlots -> includedSlots
	    includedKey.mosAncestors  -> includedAncestors
	fi	

	( Create the structure definition: )
	makeMosClass -> newClass
	includedSym if
	    newClass	   ( Class for this structure )
            slots includedSlots + ( Number of slots )
            0              ( Shared slots in class )
            3              ( Parents, including standardStructure and t )
            includedAncestors 1 + ( Length of precedence list )
            0		   ( Slotargs )
            0		   ( Methargs )
            0		   ( Initargs )
            0		   ( Object methods )
            0		   ( Class methods )
            makeMosKey -> structDef
	    structDef  --> newClass.key

	    ( Copy inherited slot info over: )
	    for i from 0 below includedSlots do{
		structDef i includedKey i copyMosKeySlot
	    }

	    structDef 0 includedClass                  setMosKeyParent
	    structDef 1 'lisp:standardStructure.type setMosKeyParent
	    structDef 2                  'lisp:t.type setMosKeyParent

	    structDef 0 newClass                       setMosKeyAncestor
	    for i from 0 below includedAncestors do{
		includedKey i      getMosKeyAncestor -> c
		structDef   i 1+ c setMosKeyAncestor
	    }
	else
	    newClass		( Class for this structure )
            slots		( Number of slots )
            0			( Shared slots in class )
            2                   ( Parents, including standardStructure and t )
            3			( Length of precedence list )
            0			( Slotargs )
            0			( Methargs )
            0			( Initargs )
            0			( Object methods )
            0			( Class methods )
            makeMosKey -> structDef
	    structDef  --> newClass.key

	    structDef 0 'lisp:standardStructure.type setMosKeyParent
	    structDef 1                  'lisp:t.type setMosKeyParent 

	    structDef 0 newClass                       setMosKeyAncestor
	    structDef 1 'lisp:standardStructure.type setMosKeyAncestor
	    structDef 2                  'lisp:t.type setMosKeyAncestor
	fi

	( Copy symbol name to structure definition name: )
	structSym.name --> structDef.name
	structSym.name -->  newClass.name



	( Pass 2 )

	( Parse preamble info into structDef: )
        'saveDefstructOption structDef
        |parseDefstructPreamble ( [] $ $ -> [] $ $ )
        -> structDef
	-> loc

	( Parse slot info into structDef: )
	loc includedSlots
	'saveDefstructSlot        structDef
	'saveDefstructSlotOption structDef
	|parseDefstructSlots ( [] $ $ $ $ $ -> [] $ $ )
	-> structDef
	-> structDef


        ( Export symbol naming structure if so requested: )
	structDef.export if structSym export fi


	( Save structure definition in symbol typefield, )
	( unless :type 'vector or :type 'list specified: )
	structSym.type not if
	    newClass structSym setSymbolType
	fi



	( Delegate process of generating the )
	( required access functions &tc:     )
	structDef compileStructDef

    ]pop
;
']defstruct export

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
 
@end example
