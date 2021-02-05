( --------------------------------------------------------------------- )
(			x-struct.muf				    CrT )
( Exercise structure operators.						)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
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
(  Contact cynbe@eskimo.com for a COMMERCIAL LICENSE.			)
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
( NO EVENT SHALL Jeff Prothero BE LIABLE FOR ANY SPECIAL, INDIRECT OR	)
( CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS	)
( OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,		)
( NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION	)
( WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.				)
( 									)
( Please send bug reports/fixes etc to bugs@@muq.org.			)
( ---------------------------------------------------------------------	)
( --------------------------------------------------------------------- )
(                              History                              CrT )
(                                                                       )
( 95Sep25 jsp	Created.						)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
(                              Quote                                CrT )
(                                                                       )
(	Men are born ignorant, not stupid;				)
(	they are made stupid by education.				)
(			 --Bertrand Russell				)
(									)
( --------------------------------------------------------------------- )

"Structure operator tests\n" log,
"\nStructure operator tests:" ,



( Tests 1-5: Set the global props: )

:: :: ; --> _compiler ; shouldWork
:: :: ; --> _constructor ; shouldWork
:: :: ; --> _copier ; shouldWork
:: :: ; --> _predicate ; shouldWork
:: :: ; --> _printFunction ; shouldWork

( Tests 6-33:  Create a structure definition: )

::  makeMosClass	( Class object )
    1			( Unshared slots )
    0			(   Shared slots )
    0			( Immediate parents )
    0			( Precedence list )
    0			( Slotargs )
    0			( Methargs )
    0			( Initargs )
    0			( Object methods )
    0			( Class methods )
    makeMosKey --> _dad
;   shouldWork

:: "dad" --> _dad.name ; shouldWork
:: "dad" --> _dad.mosClass.name ; shouldWork
:: _dad --> _dad.mosClass.key  ; shouldWork

:: :: ; --> _gfn0  ; shouldWork
:: :: ; --> _sfn0  ; shouldWork

:: _dad :symbol       0 :key0   setMosKeySlotProperty ; shouldWork
:: _dad :initval      0 0        setMosKeySlotProperty ; shouldWork
:: _dad :type         0 'int     setMosKeySlotProperty ; shouldWork
:: _dad :getFunction 0 _gfn0  setMosKeySlotProperty ; shouldWork
:: _dad :setFunction 0 _sfn0  setMosKeySlotProperty ; shouldWork

:: _dad :userMayRead    0 t    setMosKeySlotProperty ; shouldWork
:: _dad :userMayWrite   0 t    setMosKeySlotProperty ; shouldWork
:: _dad :classMayRead  0 t    setMosKeySlotProperty ; shouldWork
:: _dad :classMayWrite 0 nil  setMosKeySlotProperty ; shouldWork
:: _dad :worldMayRead   0 nil  setMosKeySlotProperty ; shouldWork
:: _dad :worldMayWrite  0 t    setMosKeySlotProperty ; shouldWork



::  makeMosClass	( Class object )
    3			( Unshared slots )
    0			(   Shared slots )
    1			( Immediate parents )
    2			( Precedence list )
    0			( Slotargs )
    0			( Methargs )
    0			( Initargs )
    0			( Object methods )
    0			( Class methods )
    makeMosKey --> _def
;   shouldWork

:: "def" --> _def.name ; shouldWork
:: "def" --> _def.mosClass.name ; shouldWork
:: _def --> _def.mosClass.key  ; shouldWork

::  _def 0 _dad 0 copyMosKeySlot ; shouldWork
::  _def 0 _dad.mosClass setMosKeyParent   ; shouldWork
::  _def 0 _def.mosClass setMosKeyAncestor ; shouldWork
::  _def 1 _dad.mosClass setMosKeyAncestor ; shouldWork


:: _compiler --> _dad.compiler   ; shouldWork
:: _compiler --> _def.compiler   ; shouldWork

:: "source" --> _def.source   ; shouldWork
:: "fileName" --> _def.fileName   ; shouldWork
:: 17 --> _def.fnLine   ; shouldWork
:: "concName" --> _def.concName   ; shouldWork

:: _constructor --> _def.constructor   ; shouldWork
:: _copier --> _def.copier   ; shouldWork
:: _predicate --> _def.predicate   ; shouldWork
:: _printFunction --> _def.printFunction   ; shouldWork
:: t --> _def.type   ; shouldWork
:: nil --> _def.named  ; shouldWork
:: 1 --> _def.initialOffset  ; shouldWork



( Read fields back in a separate pass,  )
( so as to be sure none map to the same )
( slot:                                 )

( Tests 34-49: Get the global props: )

:: _dad.unsharedSlots 1 =  ; shouldBeTrue
:: _def.unsharedSlots 3 =  ; shouldBeTrue

:: _compiler  _def.compiler =  ; shouldBeTrue

:: "source"  _def.source = ; shouldBeTrue
:: "fileName" _def.fileName = ; shouldBeTrue
:: 17 _def.fnLine = ; shouldBeTrue
:: "concName" _def.concName = ; shouldBeTrue
:: _dad.mosClass _def 0 getMosKeyParent = ; shouldBeTrue

:: _constructor _def.constructor = ; shouldBeTrue
:: _copier _def.copier = ; shouldBeTrue
:: _predicate _def.predicate = ; shouldBeTrue
:: _printFunction _def.printFunction = ; shouldBeTrue
:: t _def.type = ; shouldBeTrue
:: nil _def.named = ; shouldBeTrue
:: 1 _def.initialOffset = ; shouldBeTrue
:: nil _def.createdAnInstance = ; shouldBeTrue



( Tests 50-75: Set the slot props: )

:: :: ; --> _gfn1  ; shouldWork
:: :: ; --> _sfn1  ; shouldWork

:: :: ; --> _gfn2  ; shouldWork
:: :: ; --> _sfn2  ; shouldWork

:: _def :symbol       1 :key1   setMosKeySlotProperty ; shouldWork
:: _def :initval      1 11       setMosKeySlotProperty ; shouldWork
:: _def :type         1 'float   setMosKeySlotProperty ; shouldWork
:: _def :getFunction 1 _gfn1  setMosKeySlotProperty ; shouldWork
:: _def :setFunction 1 _sfn1  setMosKeySlotProperty ; shouldWork

:: _def :userMayRead    1 t    setMosKeySlotProperty ; shouldWork
:: _def :userMayWrite   1 t    setMosKeySlotProperty ; shouldWork
:: _def :classMayRead  1 nil  setMosKeySlotProperty ; shouldWork
:: _def :classMayWrite 1 t    setMosKeySlotProperty ; shouldWork
:: _def :worldMayRead   1 t    setMosKeySlotProperty ; shouldWork
:: _def :worldMayWrite  1 nil  setMosKeySlotProperty ; shouldWork

:: _def :symbol       2 :key2   setMosKeySlotProperty ; shouldWork
:: _def :initval      2 22       setMosKeySlotProperty ; shouldWork
:: _def :type         2 t        setMosKeySlotProperty ; shouldWork
:: _def :getFunction 2 _gfn2  setMosKeySlotProperty ; shouldWork
:: _def :setFunction 2 _sfn2  setMosKeySlotProperty ; shouldWork

:: _def :userMayRead    2 t    setMosKeySlotProperty ; shouldWork
:: _def :userMayWrite   2 t    setMosKeySlotProperty ; shouldWork
:: _def :classMayRead  2 nil  setMosKeySlotProperty ; shouldWork
:: _def :classMayWrite 2 t    setMosKeySlotProperty ; shouldWork
:: _def :worldMayRead   2 nil  setMosKeySlotProperty ; shouldWork
:: _def :worldMayWrite  2 t    setMosKeySlotProperty ; shouldWork



( Tests 76-127: Get the slot props: )

:: _dad :symbol       0 getMosKeySlotProperty :key0  = ; shouldBeTrue
:: _dad :initval      0 getMosKeySlotProperty 0       = ; shouldBeTrue
:: _dad :type         0 getMosKeySlotProperty 'int    = ; shouldBeTrue
:: _dad :getFunction 0 getMosKeySlotProperty _gfn0 = ; shouldBeTrue
:: _dad :setFunction 0 getMosKeySlotProperty _sfn0 = ; shouldBeTrue

:: _dad :rootMayRead    0 getMosKeySlotProperty t   = ; shouldBeTrue
:: _dad :rootMayWrite   0 getMosKeySlotProperty t   = ; shouldBeTrue
:: _dad :userMayRead    0 getMosKeySlotProperty t   = ; shouldBeTrue
:: _dad :userMayWrite   0 getMosKeySlotProperty t   = ; shouldBeTrue
:: _dad :classMayRead  0 getMosKeySlotProperty t   = ; shouldBeTrue
:: _dad :classMayWrite 0 getMosKeySlotProperty nil = ; shouldBeTrue
:: _dad :worldMayRead   0 getMosKeySlotProperty nil = ; shouldBeTrue
:: _dad :worldMayWrite  0 getMosKeySlotProperty t   = ; shouldBeTrue

:: _def :symbol       0 getMosKeySlotProperty :key0  = ; shouldBeTrue
:: _def :initval      0 getMosKeySlotProperty 0       = ; shouldBeTrue
:: _def :type         0 getMosKeySlotProperty 'int    = ; shouldBeTrue
:: _def :getFunction 0 getMosKeySlotProperty _gfn0 = ; shouldBeTrue
:: _def :setFunction 0 getMosKeySlotProperty _sfn0 = ; shouldBeTrue

:: _def :rootMayRead    0 getMosKeySlotProperty t   = ; shouldBeTrue
:: _def :rootMayWrite   0 getMosKeySlotProperty t   = ; shouldBeTrue
:: _def :userMayRead    0 getMosKeySlotProperty t   = ; shouldBeTrue
:: _def :userMayWrite   0 getMosKeySlotProperty t   = ; shouldBeTrue
:: _def :classMayRead  0 getMosKeySlotProperty t   = ; shouldBeTrue
:: _def :classMayWrite 0 getMosKeySlotProperty nil = ; shouldBeTrue
:: _def :worldMayRead   0 getMosKeySlotProperty nil = ; shouldBeTrue
:: _def :worldMayWrite  0 getMosKeySlotProperty t   = ; shouldBeTrue

:: _def :symbol       1 getMosKeySlotProperty :key1 = ; shouldBeTrue
:: _def :initval      1 getMosKeySlotProperty 11     = ; shouldBeTrue
:: _def :type         1 getMosKeySlotProperty 'float = ; shouldBeTrue
:: _def :getFunction 1 getMosKeySlotProperty _gfn1 = ; shouldBeTrue
:: _def :setFunction 1 getMosKeySlotProperty _sfn1 = ; shouldBeTrue

:: _def :rootMayRead    1 getMosKeySlotProperty t   = ; shouldBeTrue
:: _def :rootMayWrite   1 getMosKeySlotProperty t   = ; shouldBeTrue
:: _def :userMayRead    1 getMosKeySlotProperty t   = ; shouldBeTrue
:: _def :userMayWrite   1 getMosKeySlotProperty t   = ; shouldBeTrue
:: _def :classMayRead  1 getMosKeySlotProperty nil = ; shouldBeTrue
:: _def :classMayWrite 1 getMosKeySlotProperty t   = ; shouldBeTrue
:: _def :worldMayRead   1 getMosKeySlotProperty t   = ; shouldBeTrue
:: _def :worldMayWrite  1 getMosKeySlotProperty nil = ; shouldBeTrue

:: _def :symbol       2 getMosKeySlotProperty :key2  = ; shouldBeTrue
:: _def :initval      2 getMosKeySlotProperty 22      = ; shouldBeTrue
:: _def :type         2 getMosKeySlotProperty t       = ; shouldBeTrue
:: _def :getFunction 2 getMosKeySlotProperty _gfn2 = ; shouldBeTrue
:: _def :setFunction 2 getMosKeySlotProperty _sfn2 = ; shouldBeTrue

:: _def :rootMayRead    2 getMosKeySlotProperty t   = ; shouldBeTrue
:: _def :rootMayWrite   2 getMosKeySlotProperty t   = ; shouldBeTrue
:: _def :userMayRead    2 getMosKeySlotProperty t   = ; shouldBeTrue
:: _def :userMayWrite   2 getMosKeySlotProperty t   = ; shouldBeTrue
:: _def :classMayRead  2 getMosKeySlotProperty nil = ; shouldBeTrue
:: _def :classMayWrite 2 getMosKeySlotProperty t   = ; shouldBeTrue
:: _def :worldMayRead   2 getMosKeySlotProperty nil = ; shouldBeTrue
:: _def :worldMayWrite  2 getMosKeySlotProperty t   = ; shouldBeTrue



( Tests 128-130: Test finding structure slots: )

:: _def :key0 findMosKeySlot 0 = ; shouldBeTrue
:: _def :key1 findMosKeySlot 1 = ; shouldBeTrue
:: _def :key2 findMosKeySlot 2 = ; shouldBeTrue



( Tests 131-136: Make default-initialized structure and check values: )

:: [ | _def ]makeStructure --> _stc ; shouldWork
:: _stc length2 3 = ; shouldBeTrue
:: _def.createdAnInstance t = ; shouldBeTrue
:: _stc _def.mosClass 0 getNthStructureSlot  0 = ; shouldBeTrue
:: _stc _def.mosClass 1 getNthStructureSlot 11 = ; shouldBeTrue
:: _stc _def.mosClass 2 getNthStructureSlot 22 = ; shouldBeTrue



( Tests 137-142: Set its slots and read them back: )

:: _stc 100 _def.mosClass 0 setNthStructureSlot  ; shouldWork
:: _stc 101 _def.mosClass 1 setNthStructureSlot  ; shouldWork
:: _stc 102 _def.mosClass 2 setNthStructureSlot  ; shouldWork

:: _stc _def.mosClass 0 getNthStructureSlot 100 = ; shouldBeTrue
:: _stc _def.mosClass 1 getNthStructureSlot 101 = ; shouldBeTrue
:: _stc _def.mosClass 2 getNthStructureSlot 102 = ; shouldBeTrue



( Tests 143-150: Make explicitly-initialized structure and check values: )

:: [ :key0 200 :key2 202 :key1 201 | _def ]makeStructure --> _stc ; shouldWork
:: _stc length2 3 = ; shouldBeTrue

:: _stc _def.mosClass 0 getNthStructureSlot 200 = ; shouldBeTrue
:: _stc _def.mosClass 1 getNthStructureSlot 201 = ; shouldBeTrue
:: _stc _def.mosClass 2 getNthStructureSlot 202 = ; shouldBeTrue

:: _stc  nil  0 getNthStructureSlot 200 = ; shouldBeTrue
:: _stc  nil  1 getNthStructureSlot 201 = ; shouldBeTrue
:: _stc  nil  2 getNthStructureSlot 202 = ; shouldBeTrue



( Tests 151-156: Test some of the predicates and such: )

:: _def mosKey? ; shouldBeTrue
:: _stc structure? ; shouldBeTrue
:: _stc _def.mosClass thisStructure? ; shouldBeTrue
:: _def isAMosKey ; shouldWork
:: _stc isAStructure ; shouldWork
:: _stc _def.mosClass isThisStructure ; shouldWork


( Tests 157-165: Check access to struct fields via path expressions: )

:: _stc.key0 200 = ; shouldBeTrue
:: _stc.key1 201 = ; shouldBeTrue
:: _stc.key2 202 = ; shouldBeTrue

:: 300 --> _stc.key0 ; shouldWork
:: 301 --> _stc.key1 ; shouldWork
:: 302 --> _stc.key2 ; shouldWork

:: _stc.key0 300 = ; shouldBeTrue
:: _stc.key1 301 = ; shouldBeTrue
:: _stc.key2 302 = ; shouldBeTrue



( Tests 166-215: Check basic ]defstruct fn stuff: )

:: nil 'dad setSymbolType ; shouldWork
:: nil 'kid setSymbolType ; shouldWork

:: defstruct: dad               'key0        ; ; shouldWork
:: defstruct: kid :include 'dad 'key1 'key2 ; ; shouldWork

:: 'dad.type mosClass? ; shouldBeTrue
:: 'kid.type mosClass? ; shouldBeTrue

:: 'dad.type.key.unsharedSlots 1 = ; shouldBeTrue
:: 'kid.type.key.unsharedSlots 3 = ; shouldBeTrue

:: [ | ]makeDad --> _aDad ; shouldWork
:: [ | ]makeKid --> _aKid ; shouldWork

:: _aDad$s.isA.mosClass 'dad.type = ; shouldBeTrue
:: _aKid$s.isA.mosClass 'kid.type = ; shouldBeTrue

:: _aDad dad? ; shouldBeTrue
:: _aKid kid? ; shouldBeTrue
:: _aDad kid? ; shouldBeFalse
:: _aKid dad? ; shouldBeTrue

:: _aDad isADad ; shouldWork
:: _aKid isAKid ; shouldWork
:: _aDad isAKid ; shouldFail
:: _aKid isADad ; shouldWork

:: 7 --> _aDad.key0 ; shouldWork
:: 9 --> _aKid.key0 ; shouldWork
:: _aDad.key0 7 = ; shouldBeTrue
:: _aKid.key0 9 = ; shouldBeTrue
:: _aDad 3 setDadKey0 ; shouldWork
:: _aKid 5 setKidKey0 ; shouldWork
:: _aDad.key0 3 = ; shouldBeTrue
:: _aKid.key0 5 = ; shouldBeTrue
:: _aDad dadKey0 3 = ; shouldBeTrue
:: _aKid kidKey0 5 = ; shouldBeTrue
:: _aKid dadKey0 5 = ; shouldBeTrue
:: _aDad kidKey0 3 = ; shouldFail

:: _aKid 1 setKidKey1 ; shouldWork
:: _aKid 2 setKidKey2 ; shouldWork
:: _aKid kidKey1 1 = ; shouldBeTrue
:: _aKid kidKey2 2 = ; shouldBeTrue

:: _aDad copyDad --> _dad2 ; shouldWork
:: _aKid copyKid --> _kid2 ; shouldWork


:: _dad2$s.isA.mosClass 'dad.type = ; shouldBeTrue
:: _kid2$s.isA.mosClass 'kid.type = ; shouldBeTrue

:: _dad2 dad? ; shouldBeTrue
:: _kid2 kid? ; shouldBeTrue
:: _dad2 kid? ; shouldBeFalse
:: _kid2 dad? ; shouldBeTrue

:: _dad2 isADad ; shouldWork
:: _kid2 isAKid ; shouldWork
:: _dad2 isAKid ; shouldFail
:: _kid2 isADad ; shouldWork

:: _dad2 dadKey0 3 = ; shouldBeTrue
:: _kid2 kidKey0 5 = ; shouldBeTrue
:: _kid2 kidKey1 1 = ; shouldBeTrue
:: _kid2 kidKey2 2 = ; shouldBeTrue



( Tests 216-224: Check ]defstruct options: )

:: nil 'clip setSymbolType ; shouldWork
:: defstruct: clip
     :concName   "clop"
     :constructor ']makeClop
     :copier      'copyClop
     :assertion   'isAClop
     :predicate   'clop?
     'slot
   ;
; shouldWork
:: [ | ]makeClop --> _clip ; shouldWork
:: _clip isAClop ; shouldWork
:: _clip clop? ; shouldBeTrue
:: _clip clop? ; shouldBeTrue
:: _clip copyClop --> _clipped ; shouldWork
:: _clipped clop? ; shouldBeTrue
:: _clip 2 setClopSlot ; shouldWork
:: _clip clopSlot 2 = ; shouldBeTrue



( Tests 225-228: Check creating by keywords: )
:: nil 'window setSymbolType ; shouldWork
:: defstruct: window 'x 'y ; ; shouldWork
:: [ :y 3 :x 2 | ]makeWindow --> _window ; shouldWork
:: _window windowX 2 = ; shouldBeTrue
:: _window windowY 3 = ; shouldBeTrue



( Tests 229-251: Check ]defstruct slot options: )
:: nil 'blackjack setSymbolType ; shouldWork
:: defstruct: blackjack   'val :initval 21   ; ; shouldWork
:: [ | ]makeBlackjack --> _bj ; shouldWork
:: _bj blackjackVal 21 = ; shouldBeTrue

:: nil 'secret setSymbolType ; shouldWork
::  rootOmnipotentlyDo{
	defstruct: secret
	  'slot
	     :initval            0
	     :rootMayRead    nil
	     :rootMayWrite   nil
	     :userMayRead    nil
	     :userMayWrite   nil
	     :classMayRead  nil
	     :classMayWrite nil
	     :worldMayRead   nil
	     :worldMayWrite  nil
	;
    }
; shouldWork
:: 'secret.type.key --> _s ; shouldWork
:: _s :rootMayRead    0 getMosKeySlotProperty ; shouldBeFalse
:: _s :rootMayWrite   0 getMosKeySlotProperty ; shouldBeFalse
:: _s :userMayRead    0 getMosKeySlotProperty ; shouldBeFalse
:: _s :userMayWrite   0 getMosKeySlotProperty ; shouldBeFalse
:: _s :classMayRead  0 getMosKeySlotProperty ; shouldBeFalse
:: _s :classMayWrite 0 getMosKeySlotProperty ; shouldBeFalse
:: _s :worldMayRead   0 getMosKeySlotProperty ; shouldBeFalse
:: _s :worldMayWrite  0 getMosKeySlotProperty ; shouldBeFalse

:: nil 'naked setSymbolType ; shouldWork
::  rootOmnipotentlyDo{
	defstruct: naked
	  'slot
	     :rootMayRead    t
	     :rootMayWrite   t
	     :userMayRead    t
	     :userMayWrite   t
	     :classMayRead  t
	     :classMayWrite t
	     :worldMayRead   t
	     :worldMayWrite  t
	;
    }
; shouldWork
:: 'naked.type.key --> _n ; shouldWork
:: _n :rootMayRead    0 getMosKeySlotProperty ; shouldBeTrue
:: _n :rootMayWrite   0 getMosKeySlotProperty ; shouldBeTrue
:: _n :userMayRead    0 getMosKeySlotProperty ; shouldBeTrue
:: _n :userMayWrite   0 getMosKeySlotProperty ; shouldBeTrue
:: _n :classMayRead  0 getMosKeySlotProperty ; shouldBeTrue
:: _n :classMayWrite 0 getMosKeySlotProperty ; shouldBeTrue
:: _n :worldMayRead   0 getMosKeySlotProperty ; shouldBeTrue
:: _n :worldMayWrite  0 getMosKeySlotProperty ; shouldBeTrue


( Tests 252-261: Check struct privchecking: )

:: [ | ]makeSecret --> _s ; shouldWork
:: _s.slot ; shouldFail
:: _s secretSlot ; shouldFail
:: 12 --> _s.slot ; shouldFail
:: _s 12 setSecretSlot ; shouldFail

:: [ | ]makeNaked --> _n ; shouldWork
:: _n.slot ; shouldWork
:: _n nakedSlot ; shouldWork
:: 12 --> _n.slot ; shouldWork
:: _n 12 setNakedSlot ; shouldWork




( Tests 262-279: Check copyStructureContents: )


:: nil 'test setSymbolType ; shouldWork
:: defstruct: test 'a 'b ; ; shouldWork


:: [ :a 0 :b 1 | ]makeTest --> _one ; shouldWork
:: [ :a 2 :b 3 | ]makeTest --> _two ; shouldWork

:: _one.a 0 = ; shouldBeTrue
:: _one.b 1 = ; shouldBeTrue
:: _two.a 2 = ; shouldBeTrue
:: _two.b 3 = ; shouldBeTrue

:: _one _two copyStructureContents ; shouldWork

:: _one.a 2 = ; shouldBeTrue
:: _one.b 3 = ; shouldBeTrue
:: _two.a 2 = ; shouldBeTrue
:: _two.b 3 = ; shouldBeTrue


( Also test when either or both are ephemeral: )

:: [ :ephemeral t   :a 0 :b 1 | 'test ]makeStructure --> _one
   [ :ephemeral nil :a 2 :b 3 | 'test ]makeStructure --> _two
   _one _two copyStructureContents
   _one.a 2 =
; shouldBeTrue

:: [ :ephemeral t   :a 0 :b 1 | 'test ]makeStructure --> _one
   [ :ephemeral nil :a 2 :b 3 | 'test ]makeStructure --> _two
   _one _two copyStructureContents
   _one.b 3 =
; shouldBeTrue



:: [ :ephemeral nil :a 0 :b 1 | 'test ]makeStructure --> _one
   [ :ephemeral t   :a 2 :b 3 | 'test ]makeStructure --> _two
   _one _two copyStructureContents
   _one.a 2 =
; shouldBeTrue

:: [ :ephemeral nil :a 0 :b 1 | 'test ]makeStructure --> _one
   [ :ephemeral t   :a 2 :b 3 | 'test ]makeStructure --> _two
   _one _two copyStructureContents
   _one.b 3 =
; shouldBeTrue



:: [ :ephemeral t   :a 0 :b 1 | 'test ]makeStructure --> _one
   [ :ephemeral t   :a 2 :b 3 | 'test ]makeStructure --> _two
   _one _two copyStructureContents
   _one.a 2 =
; shouldBeTrue

:: [ :ephemeral t   :a 0 :b 1 | 'test ]makeStructure --> _one
   [ :ephemeral t   :a 2 :b 3 | 'test ]makeStructure --> _two
   _one _two copyStructureContents
   _one.b 3 =
; shouldBeTrue



( Tests 280-305: Check :initform slot property: )

::
    makeMosClass -> newClass
    newClass      ( Class for this structure )
    2              ( Number of slots )
    0              ( Shared slots in class )
    2              ( Parents, including standardStructure and t )
    3              ( Length of precedence list )
    0		   ( Slotargs )
    0		   ( Methargs )
    0		   ( Initargs )
    0		   ( Object methods )
    0		   ( Class methods )
    makeMosKey --> _mom

    _mom --> newClass.key

    _mom 0 'lisp:standardStructure.type setMosKeyParent
    _mom 1                  'lisp:t.type setMosKeyParent

    _mom 0 newClass                       setMosKeyAncestor
    _mom 1 'lisp:standardStructure.type setMosKeyAncestor
    _mom 2                  'lisp:t.type setMosKeyAncestor

; shouldWork

:: 0  --> _count0 ; shouldWork
:: 10 --> _count1 ; shouldWork

: count0   ++ _count0   _count0 ;
: count1   ++ _count1   _count1 ;


:: _mom :initval  0 6        setMosKeySlotProperty ; shouldWork
:: _mom :initval  1 7        setMosKeySlotProperty ; shouldWork

:: _mom :initform 0 #'count0 setMosKeySlotProperty ; shouldWork
:: _mom :initform 1 #'count1 setMosKeySlotProperty ; shouldWork

:: _mom :symbol   0 :a       setMosKeySlotProperty ; shouldWork
:: _mom :symbol   1 :b       setMosKeySlotProperty ; shouldWork


:: _mom :initform 0 getMosKeySlotProperty #'count0 = ; shouldBeTrue
:: _mom :initform 1 getMosKeySlotProperty #'count1 = ; shouldBeTrue

:: [ | _mom ]makeStructure --> _m ; shouldWork
:: _m _mom.mosClass 0 getNthStructureSlot 1  = ; shouldBeTrue
:: _m _mom.mosClass 1 getNthStructureSlot 11 = ; shouldBeTrue

:: [ | _mom ]makeStructure --> _m ; shouldWork
:: _m _mom.mosClass 0 getNthStructureSlot 2  = ; shouldBeTrue
:: _m _mom.mosClass 1 getNthStructureSlot 12 = ; shouldBeTrue

:: [ :a 17 | _mom ]makeStructure --> _m ; shouldWork
:: _m _mom.mosClass 0 getNthStructureSlot 17  = ; shouldBeTrue
:: _m _mom.mosClass 1 getNthStructureSlot 13 = ; shouldBeTrue

:: [ :b 19 | _mom ]makeStructure --> _m ; shouldWork
:: _m _mom.mosClass 0 getNthStructureSlot  3  = ; shouldBeTrue
:: _m _mom.mosClass 1 getNthStructureSlot 19 = ; shouldBeTrue

:: [ :a 31 :b 32 | _mom ]makeStructure --> _m ; shouldWork
:: _m _mom.mosClass 0 getNthStructureSlot 31  = ; shouldBeTrue
:: _m _mom.mosClass 1 getNthStructureSlot 32 = ; shouldBeTrue

