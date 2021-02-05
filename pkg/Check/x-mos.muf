( --------------------------------------------------------------------- )
(			x-mos.muf				    CrT )
( Exercise Common Lisp Object System.					)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      96Feb25							)
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
(                              history                              CrT )
(                                                                       )
( 96Feb25 jsp	Created.						)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
(                              comment                              	)
(                                                                       )
( Every big program stands silent witness to untold blood on the keys.	)
( --------------------------------------------------------------------- )

"MOS (Muq Object System) support tests\n" log,
"\nMOS (Muq Object System) support tests:" ,




( Test 1: Test class creation: )
:: makeMosClass --> _c ; shouldWork



( Tests 2-25: Test key creation: )
:: _c  0  0  0  0  0 0 0 0 0 makeMosKey --> _g ; shouldWork
:: _c  0  0  0  0  0 0 0 0   makeMosKey ; shouldFail

:: _c -1  0  0  0  0  0 0 0 0 makeMosKey ; shouldFail
:: _c  0 -1  0  0  0  0 0 0 0 makeMosKey ; shouldFail
:: _c  0  0 -1  0  0  0 0 0 0 makeMosKey ; shouldFail
:: _c  0  0  0 -1  0  0 0 0 0 makeMosKey ; shouldFail
:: _c  0  0  0  0 -1  0 0 0 0 makeMosKey ; shouldFail

:: _c nil 0  0  0  0  0 0 0 0 makeMosKey ; shouldFail
:: _c  0 nil 0  0  0  0 0 0 0 makeMosKey ; shouldFail
:: _c  0  0 nil 0  0  0 0 0 0 makeMosKey ; shouldFail
:: _c  0  0  0 nil 0  0 0 0 0 makeMosKey ; shouldFail
:: _c  0  0  0  0 nil 0 0 0 0 makeMosKey ; shouldFail

:: _c  1  0  0  0  0  0 0 0 0 makeMosKey ; shouldWork
:: _c  0  1  0  0  0  0 0 0 0 makeMosKey ; shouldWork
:: _c  0  0  1  0  0  0 0 0 0 makeMosKey ; shouldWork
:: _c  0  0  0  1  0  0 0 0 0 makeMosKey ; shouldWork
:: _c  0  0  0  0  1  0 0 0 0 makeMosKey ; shouldWork

:: _c  1  3  5  7  0 0 2  0 0 makeMosKey --> _g ; shouldWork
:: _g.mosClass    _c = ; shouldBeTrue
:: _g.unsharedSlots 1  = ; shouldBeTrue
:: _g.sharedSlots   3  = ; shouldBeTrue
:: _g.mosParents   5  = ; shouldBeTrue
:: _g.mosAncestors 7  = ; shouldBeTrue
:: _g.initargs       2  = ; shouldBeTrue




( Tests 26-70: Test key ancestor and parent lists: )
:: makeMosClass --> p0 ; shouldWork
:: makeMosClass --> p1 ; shouldWork
:: makeMosClass --> p2 ; shouldWork
:: makeMosClass --> p3 ; shouldWork
:: makeMosClass --> p4 ; shouldWork

:: p0 0 0 0 0 0 0 0 0 0 makeMosKey --> p0.key ; shouldWork
:: p1 0 0 0 0 0 0 0 0 0 makeMosKey --> p1.key ; shouldWork
:: p2 0 0 0 0 0 0 0 0 0 makeMosKey --> p2.key ; shouldWork
:: p3 0 0 0 0 0 0 0 0 0 makeMosKey --> p3.key ; shouldWork
:: p4 0 0 0 0 0 0 0 0 0 makeMosKey --> p4.key ; shouldWork


:: makeMosClass --> a0 ; shouldWork
:: makeMosClass --> a1 ; shouldWork
:: makeMosClass --> a2 ; shouldWork
:: makeMosClass --> a3 ; shouldWork
:: makeMosClass --> a4 ; shouldWork
:: makeMosClass --> a5 ; shouldWork
:: makeMosClass --> a6 ; shouldWork

:: a0 0 0 0 0 0 0 0 0 0 makeMosKey --> a0.key ; shouldWork
:: a1 0 0 0 0 0 0 0 0 0 makeMosKey --> a1.key ; shouldWork
:: a2 0 0 0 0 0 0 0 0 0 makeMosKey --> a2.key ; shouldWork
:: a3 0 0 0 0 0 0 0 0 0 makeMosKey --> a3.key ; shouldWork
:: a4 0 0 0 0 0 0 0 0 0 makeMosKey --> a4.key ; shouldWork
:: a5 0 0 0 0 0 0 0 0 0 makeMosKey --> a5.key ; shouldWork
:: a6 0 0 0 0 0 0 0 0 0 makeMosKey --> a6.key ; shouldWork


:: _g -1 p0  setMosKeyParent ; shouldFail
:: nil  0 p0 setMosKeyParent ; shouldFail
:: _g 0 nil  setMosKeyParent ; shouldFail

:: _g 0 p0 setMosKeyParent ; shouldWork
:: _g 1 p1 setMosKeyParent ; shouldWork
:: _g 2 p2 setMosKeyParent ; shouldWork
:: _g 3 p3 setMosKeyParent ; shouldWork
:: _g 4 p4 setMosKeyParent ; shouldWork

:: _g 0 a0 setMosKeyAncestor ; shouldWork
:: _g 1 a1 setMosKeyAncestor ; shouldWork
:: _g 2 a2 setMosKeyAncestor ; shouldWork
:: _g 3 a3 setMosKeyAncestor ; shouldWork
:: _g 4 a4 setMosKeyAncestor ; shouldWork
:: _g 5 a5 setMosKeyAncestor ; shouldWork
:: _g 6 a6 setMosKeyAncestor ; shouldWork

:: _g 0 'a "a" setMosKeyInitarg ; shouldWork
:: _g 1 'b "b" setMosKeyInitarg ; shouldWork


:: _g 0 getMosKeyParent p0 = ; shouldBeTrue
:: _g 1 getMosKeyParent p1 = ; shouldBeTrue
:: _g 2 getMosKeyParent p2 = ; shouldBeTrue
:: _g 3 getMosKeyParent p3 = ; shouldBeTrue
:: _g 4 getMosKeyParent p4 = ; shouldBeTrue

:: _g 0 getMosKeyAncestor a0 = ; shouldBeTrue
:: _g 1 getMosKeyAncestor a1 = ; shouldBeTrue
:: _g 2 getMosKeyAncestor a2 = ; shouldBeTrue
:: _g 3 getMosKeyAncestor a3 = ; shouldBeTrue
:: _g 4 getMosKeyAncestor a4 = ; shouldBeTrue
:: _g 5 getMosKeyAncestor a5 = ; shouldBeTrue
:: _g 6 getMosKeyAncestor a6 = ; shouldBeTrue

:: _g 0 getMosKeyInitarg      pop 'a  = ; shouldBeTrue
:: _g 0 getMosKeyInitarg swap pop "a" = ; shouldBeTrue
:: _g 1 getMosKeyInitarg      pop 'b  = ; shouldBeTrue
:: _g 1 getMosKeyInitarg swap pop "b" = ; shouldBeTrue





( Tests 71-198: Test key slots properties: )

:: :: ; --> _getFn0 ; shouldWork
:: :: ; --> _getFn1 ; shouldWork
:: :: ; --> _getFn2 ; shouldWork
:: :: ; --> _getFn3 ; shouldWork

:: :: ; --> _setFn0 ; shouldWork
:: :: ; --> _setFn1 ; shouldWork
:: :: ; --> _setFn2 ; shouldWork
:: :: ; --> _setFn3 ; shouldWork


:: _g :allocation 0 getMosKeySlotProperty :instance = ; shouldBeTrue
:: _g :allocation 1 getMosKeySlotProperty :class    = ; shouldBeTrue
:: _g :allocation 2 getMosKeySlotProperty :class    = ; shouldBeTrue
:: _g :allocation 3 getMosKeySlotProperty :class    = ; shouldBeTrue

:: _g :symbol 0 'zero  setMosKeySlotProperty ; shouldWork
:: _g :symbol 1 'one   setMosKeySlotProperty ; shouldWork
:: _g :symbol 2 'two   setMosKeySlotProperty ; shouldWork
:: _g :symbol 3 'three setMosKeySlotProperty ; shouldWork

:: :: 0 ; --> _zero  ; shouldWork
:: :: 1 ; --> _one   ; shouldWork
:: :: 2 ; --> _two   ; shouldWork
:: :: 3 ; --> _three ; shouldWork

:: _g :initform 0 _zero  setMosKeySlotProperty ; shouldWork
:: _g :initform 1 _one   setMosKeySlotProperty ; shouldWork
:: _g :initform 2 _two   setMosKeySlotProperty ; shouldWork
:: _g :initform 3 _three setMosKeySlotProperty ; shouldWork

:: _g :getFunction 0 _getFn0 setMosKeySlotProperty ; shouldWork
:: _g :getFunction 1 _getFn1 setMosKeySlotProperty ; shouldWork
:: _g :getFunction 2 _getFn2 setMosKeySlotProperty ; shouldWork
:: _g :getFunction 3 _getFn3 setMosKeySlotProperty ; shouldWork

:: _g :setFunction 0 _setFn0 setMosKeySlotProperty ; shouldWork
:: _g :setFunction 1 _setFn1 setMosKeySlotProperty ; shouldWork
:: _g :setFunction 2 _setFn2 setMosKeySlotProperty ; shouldWork
:: _g :setFunction 3 _setFn3 setMosKeySlotProperty ; shouldWork

:: rootOmnipotentlyDo{ _g :rootMayRead    0   t setMosKeySlotProperty } ; shouldWork
:: rootOmnipotentlyDo{ _g :rootMayRead    1 nil setMosKeySlotProperty } ; shouldWork
:: rootOmnipotentlyDo{ _g :rootMayRead    2   t setMosKeySlotProperty } ; shouldWork
:: rootOmnipotentlyDo{ _g :rootMayRead    3 nil setMosKeySlotProperty } ; shouldWork

:: rootOmnipotentlyDo{ _g :rootMayWrite   0   t setMosKeySlotProperty } ; shouldWork
:: rootOmnipotentlyDo{ _g :rootMayWrite   1   t setMosKeySlotProperty } ; shouldWork
:: rootOmnipotentlyDo{ _g :rootMayWrite   2 nil setMosKeySlotProperty } ; shouldWork
:: rootOmnipotentlyDo{ _g :rootMayWrite   3 nil setMosKeySlotProperty } ; shouldWork

:: _g :userMayRead    0 nil setMosKeySlotProperty ; shouldWork
:: _g :userMayRead    1   t setMosKeySlotProperty ; shouldWork
:: _g :userMayRead    2 nil setMosKeySlotProperty ; shouldWork
:: _g :userMayRead    3   t setMosKeySlotProperty ; shouldWork

:: _g :userMayWrite   0 nil setMosKeySlotProperty ; shouldWork
:: _g :userMayWrite   1 nil setMosKeySlotProperty ; shouldWork
:: _g :userMayWrite   2   t setMosKeySlotProperty ; shouldWork
:: _g :userMayWrite   3   t setMosKeySlotProperty ; shouldWork

:: _g :classMayRead  0   t setMosKeySlotProperty ; shouldWork
:: _g :classMayRead  1 nil setMosKeySlotProperty ; shouldWork
:: _g :classMayRead  2 nil setMosKeySlotProperty ; shouldWork
:: _g :classMayRead  3   t setMosKeySlotProperty ; shouldWork

:: _g :classMayWrite 0 nil setMosKeySlotProperty ; shouldWork
:: _g :classMayWrite 1   t setMosKeySlotProperty ; shouldWork
:: _g :classMayWrite 2   t setMosKeySlotProperty ; shouldWork
:: _g :classMayWrite 3 nil setMosKeySlotProperty ; shouldWork

:: _g :worldMayRead   0 nil setMosKeySlotProperty ; shouldWork
:: _g :worldMayRead   1 nil setMosKeySlotProperty ; shouldWork
:: _g :worldMayRead   2 nil setMosKeySlotProperty ; shouldWork
:: _g :worldMayRead   3   t setMosKeySlotProperty ; shouldWork

:: _g :worldMayWrite  0 nil setMosKeySlotProperty ; shouldWork
:: _g :worldMayWrite  1   t setMosKeySlotProperty ; shouldWork
:: _g :worldMayWrite  2   t setMosKeySlotProperty ; shouldWork
:: _g :worldMayWrite  3   t setMosKeySlotProperty ; shouldWork

:: _g :inherited        0   t setMosKeySlotProperty ; shouldWork
:: _g :inherited        1   t setMosKeySlotProperty ; shouldWork
:: _g :inherited        2 nil setMosKeySlotProperty ; shouldWork
:: _g :inherited        3   t setMosKeySlotProperty ; shouldWork




:: _g :allocation 0 getMosKeySlotProperty :instance = ; shouldBeTrue
:: _g :allocation 1 getMosKeySlotProperty :class    = ; shouldBeTrue
:: _g :allocation 2 getMosKeySlotProperty :class    = ; shouldBeTrue
:: _g :allocation 3 getMosKeySlotProperty :class    = ; shouldBeTrue

:: _g :symbol 0 getMosKeySlotProperty 'zero  = ; shouldBeTrue
:: _g :symbol 1 getMosKeySlotProperty 'one   = ; shouldBeTrue
:: _g :symbol 2 getMosKeySlotProperty 'two   = ; shouldBeTrue
:: _g :symbol 3 getMosKeySlotProperty 'three = ; shouldBeTrue

:: _g :initform 0 getMosKeySlotProperty _zero  = ; shouldBeTrue
:: _g :initform 1 getMosKeySlotProperty _one   = ; shouldBeTrue
:: _g :initform 2 getMosKeySlotProperty _two   = ; shouldBeTrue
:: _g :initform 3 getMosKeySlotProperty _three = ; shouldBeTrue

:: _g :getFunction 0 getMosKeySlotProperty _getFn0 = ; shouldBeTrue
:: _g :getFunction 1 getMosKeySlotProperty _getFn1 = ; shouldBeTrue
:: _g :getFunction 2 getMosKeySlotProperty _getFn2 = ; shouldBeTrue
:: _g :getFunction 3 getMosKeySlotProperty _getFn3 = ; shouldBeTrue
		     				            
:: _g :setFunction 0 getMosKeySlotProperty _setFn0 = ; shouldBeTrue
:: _g :setFunction 1 getMosKeySlotProperty _setFn1 = ; shouldBeTrue
:: _g :setFunction 2 getMosKeySlotProperty _setFn2 = ; shouldBeTrue
:: _g :setFunction 3 getMosKeySlotProperty _setFn3 = ; shouldBeTrue

:: _g :rootMayRead    0 getMosKeySlotProperty   t = ; shouldBeTrue
:: _g :rootMayRead    1 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :rootMayRead    2 getMosKeySlotProperty   t = ; shouldBeTrue
:: _g :rootMayRead    3 getMosKeySlotProperty nil = ; shouldBeTrue
		       				         
:: _g :rootMayWrite   0 getMosKeySlotProperty   t = ; shouldBeTrue
:: _g :rootMayWrite   1 getMosKeySlotProperty   t = ; shouldBeTrue
:: _g :rootMayWrite   2 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :rootMayWrite   3 getMosKeySlotProperty nil = ; shouldBeTrue
		       				         
:: _g :userMayRead    0 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :userMayRead    1 getMosKeySlotProperty   t = ; shouldBeTrue
:: _g :userMayRead    2 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :userMayRead    3 getMosKeySlotProperty   t = ; shouldBeTrue
		       				         
:: _g :userMayWrite   0 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :userMayWrite   1 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :userMayWrite   2 getMosKeySlotProperty   t = ; shouldBeTrue
:: _g :userMayWrite   3 getMosKeySlotProperty   t = ; shouldBeTrue
		       				         
:: _g :classMayRead  0 getMosKeySlotProperty   t = ; shouldBeTrue
:: _g :classMayRead  1 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :classMayRead  2 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :classMayRead  3 getMosKeySlotProperty   t = ; shouldBeTrue
		       				         
:: _g :classMayWrite 0 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :classMayWrite 1 getMosKeySlotProperty   t = ; shouldBeTrue
:: _g :classMayWrite 2 getMosKeySlotProperty   t = ; shouldBeTrue
:: _g :classMayWrite 3 getMosKeySlotProperty nil = ; shouldBeTrue
		       				         
:: _g :worldMayRead   0 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :worldMayRead   1 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :worldMayRead   2 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :worldMayRead   3 getMosKeySlotProperty   t = ; shouldBeTrue
		       				         
:: _g :worldMayWrite  0 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :worldMayWrite  1 getMosKeySlotProperty   t = ; shouldBeTrue
:: _g :worldMayWrite  2 getMosKeySlotProperty   t = ; shouldBeTrue
:: _g :worldMayWrite  3 getMosKeySlotProperty   t = ; shouldBeTrue

:: _g :inherited        0 getMosKeySlotProperty   t = ; shouldBeTrue
:: _g :inherited        1 getMosKeySlotProperty   t = ; shouldBeTrue
:: _g :inherited        2 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :inherited        3 getMosKeySlotProperty   t = ; shouldBeTrue



( Tests 203-214: Retest above didn't modify ancestor or parent lists: )

:: _g 0 getMosKeyParent p0 = ; shouldBeTrue
:: _g 1 getMosKeyParent p1 = ; shouldBeTrue
:: _g 2 getMosKeyParent p2 = ; shouldBeTrue
:: _g 3 getMosKeyParent p3 = ; shouldBeTrue
:: _g 4 getMosKeyParent p4 = ; shouldBeTrue

:: _g 0 getMosKeyAncestor a0 = ; shouldBeTrue
:: _g 1 getMosKeyAncestor a1 = ; shouldBeTrue
:: _g 2 getMosKeyAncestor a2 = ; shouldBeTrue
:: _g 3 getMosKeyAncestor a3 = ; shouldBeTrue
:: _g 4 getMosKeyAncestor a4 = ; shouldBeTrue
:: _g 5 getMosKeyAncestor a5 = ; shouldBeTrue
:: _g 6 getMosKeyAncestor a6 = ; shouldBeTrue



( Tests 227-: Preliminary ]defclass functionality tests: )
:: defclass: a-class ; ; shouldWork
:: defclass: a-class :documentation "Whee!"  ; ; shouldWork
:: defclass: a-class :metaclass 'lisp:standardClass     ; ; shouldWork
:: defclass: a-class :slot :myslot                       ; ; shouldWork
:: defclass: a-class :slot :myslot :initval     12       ; ; shouldWork
:: defclass: a-class :slot :myslot :initform :: 12 ;     ; ; shouldWork
:: defclass: a-class :slot :myslot :initarg  'mine       ; ; shouldWork
:: defclass: a-class :slot :myslot :type     t           ; ; shouldWork
:: defclass: a-class :slot :myslot :reader 'get-mine     ; ; shouldWork
:: defclass: a-class :slot :myslot :writer 'set-mine     ; ; shouldWork
:: defclass: a-class :slot :myslot :accessor   'mine     ; ; shouldWork
:: defclass: a-class :slot :myslot :allocation :class    ; ; shouldWork
:: defclass: a-class :slot :myslot :allocation :instance ; ; shouldWork
:: defclass: a-class :slot :myslot :documentation "Yow!" ; ; shouldWork
:: defclass: a-class :slot :myslot :rootMayRead      t ; ; shouldWork
:: defclass: a-class :slot :myslot :rootMayWrite     t ; ; shouldWork
:: defclass: a-class :slot :myslot :userMayRead      t ; ; shouldWork
:: defclass: a-class :slot :myslot :userMayWrite     t ; ; shouldWork
:: defclass: a-class :slot :myslot :classMayRead    t ; ; shouldWork
:: defclass: a-class :slot :myslot :classMayWrite   t ; ; shouldWork
:: defclass: a-class :slot :myslot :worldMayRead     t ; ; shouldWork
:: defclass: a-class :slot :myslot :worldMayWrite    t ; ; shouldWork

( Tests 237-244: Basic |tsort functionality: )
:: [ | |tsort -> r ]pop r ; shouldBeTrue
:: [ | |tsort pop ]join "" = ; shouldBeTrue
:: [ 'b' 'a' | |tsort -> r ]pop r ; shouldBeTrue
:: [ 'b' 'a' | |tsort pop ]join "ba" =  ; shouldBeTrue
:: [ 'b' 'a' 'a' 'b' | |tsort -> r ]pop r ; shouldBeFalse
:: [ 'b' 'a' 'a' 'b' | |tsort -> r ]pop r ; shouldBeFalse
:: [ 'i' 'x'   'n' 'i'   'u' 'n' | |tsort -> r ]pop r ; shouldBeTrue
:: [ 'i' 'x'   'n' 'i'   'u' 'n' | |tsort pop ]join "unix" = ; shouldBeTrue


( Tests 245-273: |tsortMos tie-breaking per CLtL2 p784: )
:: makeMosClass --> _classa ; shouldWork
:: _classa  0  0  1  0  0 0 0  0 0 makeMosKey --> _keya ; shouldWork
:: _keya --> _classa.key ; shouldWork

:: makeMosClass --> _classb ; shouldWork
:: _classb  0  0  0  0  0 0 0  0 0 makeMosKey --> _keyb ; shouldWork
:: _keyb --> _classb.key ; shouldWork

:: makeMosClass --> _classc ; shouldWork
:: _classc  0  0  0  0  0 0 0  0 0 makeMosKey --> _keyc ; shouldWork
:: _keyc --> _classc.key ; shouldWork

:: makeMosClass --> _classd ; shouldWork
:: _classd  0  0  0  0  0 0 0  0 0 makeMosKey --> _keyd ; shouldWork
:: _keyd --> _classd.key ; shouldWork

:: _classa.key _keya = ; shouldBeTrue
:: _classb.key _keyb = ; shouldBeTrue
:: _classc.key _keyc = ; shouldBeTrue

:: _keya 0 _classb setMosKeyParent   ; shouldWork

:: [ _classa _classb   _classa _classc
     _classb _classd   _classc _classd
   | |tsortMos -> r ]pop r ; shouldBeTrue

:: [ _classa _classb   _classa _classc
     _classb _classd   _classc _classd
   | |tsortMos pop |length -> len ]pop len 4 = ; shouldBeTrue

:: [ _classa _classb   _classa _classc
     _classb _classd   _classc _classd
   | |tsortMos pop 0 |dupNth -> c ]pop c _classa = ; shouldBeTrue
:: [ _classa _classb   _classa _classc
     _classb _classd   _classc _classd
   | |tsortMos pop 1 |dupNth -> c ]pop c _classb = ; shouldBeTrue
:: [ _classa _classb   _classa _classc
     _classb _classd   _classc _classd
   | |tsortMos pop 2 |dupNth -> c ]pop c _classc = ; shouldBeTrue
:: [ _classa _classb   _classa _classc
     _classb _classd   _classc _classd
   | |tsortMos pop 3 |dupNth -> c ]pop c _classd = ; shouldBeTrue

( Reversing key info should reverse tie-break: )
:: _keya 0 _classc setMosKeyParent   ; shouldWork

:: [ _classa _classb   _classa _classc
     _classb _classd   _classc _classd
   | |tsortMos -> r ]pop r ; shouldBeTrue

:: [ _classa _classb   _classa _classc
     _classb _classd   _classc _classd
   | |tsortMos pop |length -> len ]pop len 4 = ; shouldBeTrue

:: [ _classa _classb   _classa _classc
     _classb _classd   _classc _classd
   | |tsortMos pop 0 |dupNth -> c ]pop c _classa = ; shouldBeTrue
:: [ _classa _classb   _classa _classc
     _classb _classd   _classc _classd
   | |tsortMos pop 1 |dupNth -> c ]pop c _classc = ; shouldBeTrue
:: [ _classa _classb   _classa _classc
     _classb _classd   _classc _classd
   | |tsortMos pop 2 |dupNth -> c ]pop c _classb = ; shouldBeTrue
:: [ _classa _classb   _classa _classc
     _classb _classd   _classc _classd
   | |tsortMos pop 3 |dupNth -> c ]pop c _classd = ; shouldBeTrue



( Tests 274-: Setting various slot properties via ]defclass: )
:: defclass: a-class
     :documentation "Whee!"
     :metaclass 'lisp:standardClass
     :slot :a0
       :initarg 'aa0
       :initval  100
       :initform :: 100 ;
       :type     t
       :reader   'get-a0
       :writer   'set-a0
       :allocation :class
       :documentation "a0 docs"
       :userMayRead      t
       :userMayWrite   nil
       :classMayRead    t
       :classMayWrite nil
       :worldMayRead     t
       :worldMayWrite  nil
; ; shouldWork
:: 'a-class.type --> _f ; shouldWork
:: _f.key --> _g ; shouldWork
:: _g.sharedSlots 1 = ; shouldBeTrue
:: _g.unsharedSlots 0 = ; shouldBeTrue
:: _g.initargs 1 = ; shouldBeTrue
:: _g :initval 0 getMosKeySlotProperty 100 = ; shouldBeTrue
:: _g :initform 0 getMosKeySlotProperty call{ -> $ } 100 = ; shouldBeTrue
:: _g :type 0 getMosKeySlotProperty t = ; shouldBeTrue
:: _g :getFunction 0 getMosKeySlotProperty 'get-a0 = ; shouldBeTrue
:: _g :setFunction 0 getMosKeySlotProperty 'set-a0 = ; shouldBeTrue
:: _g :allocation 0 getMosKeySlotProperty :class = ; shouldBeTrue
:: _g :documentation 0 getMosKeySlotProperty "a0 docs" = ; shouldBeTrue
:: _g :userMayRead 0 getMosKeySlotProperty t = ; shouldBeTrue
:: _g :userMayWrite 0 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :classMayRead 0 getMosKeySlotProperty t = ; shouldBeTrue
:: _g :classMayWrite 0 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :worldMayRead 0 getMosKeySlotProperty t = ; shouldBeTrue
:: _g :worldMayWrite 0 getMosKeySlotProperty nil = ; shouldBeTrue

:: defclass: b-class
     :slot :b0
       :initarg 'bb0
       :initval  200
       :initform :: 200 ;
       :reader   'get-b0
       :writer   'set-b0
       :allocation :instance
       :documentation "b0 docs"
       :userMayRead    nil
       :userMayWrite     t
       :classMayRead  nil
       :classMayWrite   t
       :worldMayRead   nil
       :worldMayWrite    t
; ; shouldWork
:: 'b-class.type --> _f ; shouldWork
:: _f.key --> _g ; shouldWork
:: _g.sharedSlots 0 = ; shouldBeTrue
:: _g.unsharedSlots 1 = ; shouldBeTrue
:: _g.initargs 1 = ; shouldBeTrue
:: _g :initval 0 getMosKeySlotProperty 200 = ; shouldBeTrue
:: _g :initform 0 getMosKeySlotProperty call{ -> $ } 200 = ; shouldBeTrue
:: _g :getFunction 0 getMosKeySlotProperty 'get-b0 = ; shouldBeTrue
:: _g :setFunction 0 getMosKeySlotProperty 'set-b0 = ; shouldBeTrue
:: _g :allocation 0 getMosKeySlotProperty :instance = ; shouldBeTrue
:: _g :documentation 0 getMosKeySlotProperty "b0 docs" = ; shouldBeTrue
:: _g :userMayRead 0 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :userMayWrite 0 getMosKeySlotProperty t = ; shouldBeTrue
:: _g :classMayRead 0 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :classMayWrite 0 getMosKeySlotProperty t = ; shouldBeTrue
:: _g :worldMayRead 0 getMosKeySlotProperty nil = ; shouldBeTrue
:: _g :worldMayWrite 0 getMosKeySlotProperty t = ; shouldBeTrue

:: defclass: c-class :isA 'b-class ; ; shouldWork

:: defclass: m-class ; ; shouldWork
:: :: ; --> _cfn0 ; shouldWork
:: :: ; --> _cfn1 ; shouldWork
:: 1 makeMethod --> _mtd0 ; shouldWork
:: 1 makeMethod --> _mtd1 ; shouldWork

( Tests 316-: )
:: 'm-class.type.key
    0
    0
    _cfn0
    _mtd0
    insertMosKeyClassMethod
    --> q0
; shouldWork
:: q0 mosKey? shouldBeTrue ;
:: q0.classMethods 1 = ; shouldBeTrue
:: q0 0 getMosKeyClassMethod -> m -> c -> i i 0      = ; shouldBeTrue
:: q0 0 getMosKeyClassMethod -> m -> c -> i m _mtd0 = ; shouldBeTrue
:: q0 0 getMosKeyClassMethod -> m -> c -> i c _cfn0 = ; shouldBeTrue
:: q0 0 1 _cfn1 _mtd1 setMosKeyClassMethod ; shouldWork
:: q0 0 getMosKeyClassMethod -> m -> c -> i i 1      = ; shouldBeTrue
:: q0 0 getMosKeyClassMethod -> m -> c -> i m _mtd1 = ; shouldBeTrue
:: q0 0 getMosKeyClassMethod -> m -> c -> i c _cfn1 = ; shouldBeTrue
:: q0 0 0 _cfn0 _mtd0 setMosKeyClassMethod ; shouldWork

( Tests 327-: )
:: q0
    1
    1
    _cfn1
    _mtd1
    insertMosKeyClassMethod
    --> q1
; shouldWork
:: q1 mosKey? shouldBeTrue ;
:: q1.classMethods 2 = ; shouldBeTrue
:: q1 0 getMosKeyClassMethod -> m -> c -> i i 0      = ; shouldBeTrue
:: q1 0 getMosKeyClassMethod -> m -> c -> i m _mtd0 = ; shouldBeTrue
:: q1 0 getMosKeyClassMethod -> m -> c -> i c _cfn0 = ; shouldBeTrue
:: q1 1 getMosKeyClassMethod -> m -> c -> i i 1      = ; shouldBeTrue
:: q1 1 getMosKeyClassMethod -> m -> c -> i m _mtd1 = ; shouldBeTrue
:: q1 1 getMosKeyClassMethod -> m -> c -> i c _cfn1 = ; shouldBeTrue

:: q1
    _mtd1
    deleteMosKeyClassMethod
    --> q2
; shouldWork
:: q2 mosKey? shouldBeTrue ;
:: q2.classMethods 1 = ; shouldBeTrue
:: q2 0 getMosKeyClassMethod -> m -> c -> i i 0      = ; shouldBeTrue
:: q2 0 getMosKeyClassMethod -> m -> c -> i m _mtd0 = ; shouldBeTrue
:: q2 0 getMosKeyClassMethod -> m -> c -> i c _cfn0 = ; shouldBeTrue

:: q1
    _mtd0
    deleteMosKeyClassMethod
    --> q3
; shouldWork
:: q3 mosKey? shouldBeTrue ;
:: q3.classMethods 1 = ; shouldBeTrue
:: q3 0 getMosKeyClassMethod -> m -> c -> i i 1      = ; shouldBeTrue
:: q3 0 getMosKeyClassMethod -> m -> c -> i m _mtd1 = ; shouldBeTrue
:: q3 0 getMosKeyClassMethod -> m -> c -> i c _cfn1 = ; shouldBeTrue



( Tests 344-: )
:: 'm-class.type.key
    0
    0
    _cfn0
    _mtd0
    '0'
    insertMosKeyObjectMethod
    --> q0
; shouldWork
:: q0 mosKey? shouldBeTrue ;
:: q0.objectMmethods 1 = ; shouldBeTrue
:: q0 0 getMosKeyObjectMethod -> o -> m -> c -> i i 0      = ; shouldBeTrue
:: q0 0 getMosKeyObjectMethod -> o -> m -> c -> i m _mtd0 = ; shouldBeTrue
:: q0 0 getMosKeyObjectMethod -> o -> m -> c -> i c _cfn0 = ; shouldBeTrue
:: q0 0 getMosKeyObjectMethod -> o -> m -> c -> i o '0'    = ; shouldBeTrue
:: q0 0 1 _cfn1 _mtd1 '1' setMosKeyObjectMethod ; shouldWork
:: q0 0 getMosKeyObjectMethod -> o -> m -> c -> i i 1      = ; shouldBeTrue
:: q0 0 getMosKeyObjectMethod -> o -> m -> c -> i m _mtd1 = ; shouldBeTrue
:: q0 0 getMosKeyObjectMethod -> o -> m -> c -> i c _cfn1 = ; shouldBeTrue
:: q0 0 getMosKeyObjectMethod -> o -> m -> c -> i o '1'    = ; shouldBeTrue

:: q0 0 0 _cfn0 _mtd0 '0' setMosKeyObjectMethod ; shouldWork

:: q0
    1
    1
    _cfn1
    _mtd1
    '1'
    insertMosKeyObjectMethod
    --> q1
; shouldWork
:: q1 mosKey? shouldBeTrue ;
:: q1.objectMmethods 2 = ; shouldBeTrue
:: q1 0 getMosKeyObjectMethod -> o -> m -> c -> i i 0      = ; shouldBeTrue
:: q1 0 getMosKeyObjectMethod -> o -> m -> c -> i m _mtd0 = ; shouldBeTrue
:: q1 0 getMosKeyObjectMethod -> o -> m -> c -> i c _cfn0 = ; shouldBeTrue
:: q1 0 getMosKeyObjectMethod -> o -> m -> c -> i o '0'    = ; shouldBeTrue
:: q1 1 getMosKeyObjectMethod -> o -> m -> c -> i i 1      = ; shouldBeTrue
:: q1 1 getMosKeyObjectMethod -> o -> m -> c -> i m _mtd1 = ; shouldBeTrue
:: q1 1 getMosKeyObjectMethod -> o -> m -> c -> i c _cfn1 = ; shouldBeTrue
:: q1 1 getMosKeyObjectMethod -> o -> m -> c -> i o '1'    = ; shouldBeTrue


:: q1
    _mtd1
    deleteMosKeyObjectMethod
    --> q2
; shouldWork
:: q2 mosKey? shouldBeTrue ;
:: q2.objectMmethods 1 = ; shouldBeTrue
:: q2 0 getMosKeyObjectMethod -> o -> m -> c -> i i 0      = ; shouldBeTrue
:: q2 0 getMosKeyObjectMethod -> o -> m -> c -> i m _mtd0 = ; shouldBeTrue
:: q2 0 getMosKeyObjectMethod -> o -> m -> c -> i c _cfn0 = ; shouldBeTrue
:: q2 0 getMosKeyObjectMethod -> o -> m -> c -> i o '0'    = ; shouldBeTrue

:: q1
    _mtd0
    deleteMosKeyObjectMethod
    --> q3
; shouldWork
:: q3 mosKey? shouldBeTrue ;
:: q3.objectMmethods 1 = ; shouldBeTrue
:: q3 0 getMosKeyObjectMethod -> o -> m -> c -> i i 1      = ; shouldBeTrue
:: q3 0 getMosKeyObjectMethod -> o -> m -> c -> i m _mtd1 = ; shouldBeTrue
:: q3 0 getMosKeyObjectMethod -> o -> m -> c -> i c _cfn1 = ; shouldBeTrue
:: q3 0 getMosKeyObjectMethod -> o -> m -> c -> i o '1'    = ; shouldBeTrue



:: 'm-class.type.key
    0
    0
    _cfn0
    _mtd0
    insertMosKeyClassMethod
    --> q0
; shouldWork
::  q0
    0
    1
    _cfn1
    _mtd1
    '1'
    insertMosKeyObjectMethod
    --> q1
; shouldWork
:: q1.objectMmethods 1 = ; shouldBeTrue
:: q1.classMethods 1 = ; shouldBeTrue
:: q1 0 getMosKeyObjectMethod -> o -> m -> c -> i i 1      = ; shouldBeTrue
:: q1 0 getMosKeyObjectMethod -> o -> m -> c -> i m _mtd1 = ; shouldBeTrue
:: q1 0 getMosKeyObjectMethod -> o -> m -> c -> i c _cfn1 = ; shouldBeTrue
:: q1 0 getMosKeyObjectMethod -> o -> m -> c -> i o '1'    = ; shouldBeTrue
:: q1 0 getMosKeyClassMethod -> m -> c -> i i 0      = ; shouldBeTrue
:: q1 0 getMosKeyClassMethod -> m -> c -> i m _mtd0 = ; shouldBeTrue
:: q1 0 getMosKeyClassMethod -> m -> c -> i c _cfn0 = ; shouldBeTrue

:: q1
    _mtd1
    deleteMosKeyObjectMethod
    --> q3
; shouldWork
:: q3.objectMmethods 0 = ; shouldBeTrue
:: q3.classMethods 1 = ; shouldBeTrue
:: q3 0 getMosKeyClassMethod -> m -> c -> i i 0      = ; shouldBeTrue
:: q3 0 getMosKeyClassMethod -> m -> c -> i m _mtd0 = ; shouldBeTrue
:: q3 0 getMosKeyClassMethod -> m -> c -> i c _cfn0 = ; shouldBeTrue



:: 'm-class.type.key
    0
    0
    _cfn0
    _mtd0
    insertMosKeyClassMethod
    --> q0
; shouldWork
::  q0
    1
    0
    _cfn1
    _mtd1
    insertMosKeyClassMethod
    --> q0
; shouldWork

:: q0 0 _cfn0 0 findMosKeyClassMethod? -> s -> m ; shouldBeTrue
:: q0 0 _cfn0 0 findMosKeyClassMethod? -> s -> m pop m _mtd0 = ; shouldBeTrue
:: q0 0 _cfn0 0 findMosKeyClassMethod? -> s -> m pop s 1 = ; shouldBeTrue

:: q0 0 _cfn1 0 findMosKeyClassMethod? -> s -> m ; shouldBeTrue
:: q0 0 _cfn1 0 findMosKeyClassMethod? -> s -> m pop m _mtd1 = ; shouldBeTrue
:: q0 0 _cfn1 0 findMosKeyClassMethod? -> s -> m pop s 2 = ; shouldBeTrue

:: q0 0 _cfn0 1 findMosKeyClassMethod? -> s -> m ; shouldBeFalse
:: q0 0 _cfn1 1 findMosKeyClassMethod? -> s -> m ; shouldBeTrue
:: q0 0 _cfn1 2 findMosKeyClassMethod? -> s -> m ; shouldBeFalse



:: 'm-class.type.key
    0
    0
    _cfn0
    _mtd0
    '0'
    insertMosKeyObjectMethod
    --> q0
; shouldWork
::  q0
    1
    0
    _cfn1
    _mtd1
    '1'
    insertMosKeyObjectMethod
    --> q0
; shouldWork

:: q0 0 _cfn0 '0' 0 findMosKeyObjectMethod? -> s -> m ; shouldBeTrue
:: q0 0 _cfn0 '0' 0 findMosKeyObjectMethod? -> s -> m pop m _mtd0 = ; shouldBeTrue
:: q0 0 _cfn0 '0' 0 findMosKeyObjectMethod? -> s -> m pop s 1 = ; shouldBeTrue

:: q0 0 _cfn1 '1' 0 findMosKeyObjectMethod? -> s -> m ; shouldBeTrue
:: q0 0 _cfn1 '1' 0 findMosKeyObjectMethod? -> s -> m pop m _mtd1 = ; shouldBeTrue
:: q0 0 _cfn1 '1' 0 findMosKeyObjectMethod? -> s -> m pop s 2 = ; shouldBeTrue

:: q0 0 _cfn0 '0' 1 findMosKeyObjectMethod? -> s -> m ; shouldBeFalse
:: q0 0 _cfn1 '1' 1 findMosKeyObjectMethod? -> s -> m ; shouldBeTrue
:: q0 0 _cfn1 '1' 2 findMosKeyObjectMethod? -> s -> m ; shouldBeFalse
:: q0 0 _cfn1 '2' 1 findMosKeyObjectMethod? -> s -> m ; shouldBeFalse



( Tests 418-609: )

( dup[ )
:: 'a' 'b' 'c' 3 dup[ ]join -> a pop pop pop a "abc" = ; shouldBeTrue

( Basic defgeneric: )
:: defgeneric: abc { $ -> $ } ; ; shouldWork

( Basic defmethod: )
:: defclass: g-class ; ; shouldWork
:: defmethod: abc { 'g-class } pop 12 ; ; shouldWork

( Basic object creation: )
:: [ | 'g-class ]makeStructure --> _objA ; shouldWork
:: [ | 'g-class ]makeStructure mosObject? ; shouldBeTrue

( Basic generic function invocation: )
:: _objA abc 12 = ; shouldBeTrue

( Two methods on same class, different generics: )
:: defgeneric: def { $ -> $ } ; ; shouldWork
:: defmethod:  def { 'g-class } pop 13 ; ; shouldWork
( Recreate _objA so it points to new class-key: )
:: [ | 'g-class ]makeStructure --> _objA ; shouldWork
:: _objA abc 12 = ; shouldBeTrue
:: _objA def 13 = ; shouldBeTrue


( Two methods on same class, same generic: )
:: defclass: h-class ; ; shouldWork
:: defclass: i-class ; ; shouldWork
:: defclass: j-class ; ; shouldWork
:: defgeneric: ghi { $ $ -> $ } ; ; shouldWork
:: defmethod:  ghi { 'h-class 'i-class } pop pop 14 ; ; shouldWork
:: defmethod:  ghi { 'h-class 'j-class } pop pop 15 ; ; shouldWork
:: defmethod:  ghi { 'i-class 'h-class } pop pop 16 ; ; shouldWork
:: defmethod:  ghi { 'i-class 'i-class } pop pop 17 ; ; shouldWork
:: [ | 'h-class ]makeStructure --> _objH ; shouldWork
:: [ | 'i-class ]makeStructure --> _objI ; shouldWork
:: [ | 'j-class ]makeStructure --> _objJ ; shouldWork
:: _objH _objI ghi 14 = ; shouldBeTrue
:: _objH _objJ ghi 15 = ; shouldBeTrue
:: _objI _objH ghi 16 = ; shouldBeTrue
:: _objI _objI ghi 17 = ; shouldBeTrue


( Check that most specific method )
( is called no matter which order )
( the methods are defined in:     )
:: defclass: artifact                  ; ; shouldWork
:: defclass: vehicle   :isA 'artifact ; ; shouldWork
:: defclass: boat      :isA 'vehicle  ; ; shouldWork
:: defclass: sailboat  :isA 'boat     ; ; shouldWork
:: defclass: ski-boat  :isA 'boat     ; ; shouldWork
:: defgeneric: zap { $ $ -> $ } ; ; shouldWork
:: defmethod: zap { 'artifact 'artifact } pop pop :assassinates ; ; shouldWork
:: defmethod: zap { 'vehicle  'vehicle  } pop pop :vanishes     ; ; shouldWork
:: defmethod: zap { 'boat     'boat     } pop pop :blasts       ; ; shouldWork
:: defmethod: zap { 'sailboat 'sailboat } pop pop :sinks        ; ; shouldWork
:: defmethod: zap { 'sailboat 'boat     } pop pop :rams         ; ; shouldWork
:: defmethod: zap { 'ski-boat 'boat     } pop pop :swamps       ; ; shouldWork
:: defmethod: zap { 'ski-boat 'ski-boat } pop pop :smashes      ; ; shouldWork
:: [ | 'artifact ]makeStructure --> _artifact ; shouldWork
:: [ | 'vehicle  ]makeStructure --> _vehicle  ; shouldWork
:: [ | 'boat     ]makeStructure --> _boat     ; shouldWork
:: [ | 'sailboat ]makeStructure --> _sailboat ; shouldWork
:: [ | 'ski-boat ]makeStructure --> _skiBoat ; shouldWork
:: _artifact _artifact zap :assassinates = ; shouldBeTrue
:: _vehicle  _vehicle  zap :vanishes     = ; shouldBeTrue
:: _boat     _boat     zap :blasts       = ; shouldBeTrue
:: _sailboat _sailboat zap :sinks        = ; shouldBeTrue
:: _sailboat _boat     zap :rams         = ; shouldBeTrue
:: _skiBoat _skiBoat zap :smashes      = ; shouldBeTrue
:: _skiBoat _artifact zap :assassinates = ; shouldBeTrue
:: _artifact _skiBoat zap :assassinates = ; shouldBeTrue



( Check that adding a method after   )
( subclasses and instances have been )
( created works correctly:           )
:: defgeneric: fix { $ -> $ } ; ; shouldWork
:: defmethod:  fix { 'artifact } pop :works ; ; shouldWork
:: _skiBoat fix :works = ; shouldBeTrue



( Check lambda-driven methods: )
:: defclass:   cc ; ; shouldWork
:: defgeneric: gg {[ $ ]} ; ; shouldWork
:: defmethod:  gg { 'cc } {[ 'a ; 'b 12 'c 13 ; :d 14 :e 15 ]} [ b c d e + + + | ; ; shouldWork
:: [ | 'cc ]makeStructure --> ccs ; shouldWork
:: [ ccs | gg ]shift 54 = ; shouldBeTrue
:: [ ccs 22 | gg ]shift 64 = ; shouldBeTrue
:: [ ccs 22 23 | gg ]shift 74 = ; shouldBeTrue
:: [ ccs 22 23 :e 25 | gg ]shift 84 = ; shouldBeTrue
:: [ ccs 22 23 :d 24 | gg ]shift 84 = ; shouldBeTrue
:: [ ccs 22 23 :e 25 :d 24 | gg ]shift 94 = ; shouldBeTrue



( Check reading and writing slots )
( shared and unshared, inherited  )
( and local:                      )

( Create an appropriate class pair: )
:: defclass: ccc
   :slot :ccc-u0 :allocation :instance
   :slot :ccc-s0 :allocation :class
   :slot :ccc-u1 :allocation :instance
   :slot :ccc-s1 :allocation :class
; ; shouldWork
:: defclass: ddd :isA 'ccc
   :slot :ddd-u0 :allocation :instance
   :slot :ddd-s0 :allocation :class
   :slot :ddd-u1 :allocation :instance
   :slot :ddd-s1 :allocation :class
; ;  shouldWork

:: 'ccc.type.key.sharedSlots   2 = ; shouldBeTrue
:: 'ccc.type.key.unsharedSlots 2 = ; shouldBeTrue
:: 'ddd.type.key.sharedSlots   4 = ; shouldBeTrue
:: 'ddd.type.key.unsharedSlots 4 = ; shouldBeTrue


( Create enough instances to verify )
( un/shared and un/inherited stuff: )
:: [ | 'ccc ]makeStructure --> ccc0 ; shouldWork
:: [ | 'ccc ]makeStructure --> ccc1 ; shouldWork
:: [ | 'ddd ]makeStructure --> ddd0 ; shouldWork
:: [ | 'ddd ]makeStructure --> ddd1 ; shouldWork


( Test reads and writes of various slots: )

( First, we write all the slots on each )
( object including the shared ones, and )
( check that we get back what we wrote: )

:: ccc0 100 'ccc.type :ccc-u0 setNamedStructureSlot  ; shouldWork
:: ccc0 101 'ccc.type :ccc-u1 setNamedStructureSlot  ; shouldWork
:: ccc0 102 'ccc.type :ccc-s0 setNamedStructureSlot  ; shouldWork
:: ccc0 103 'ccc.type :ccc-s1 setNamedStructureSlot  ; shouldWork


:: ccc0 'ccc.type :ccc-u0 getNamedStructureSlot 100 = ; shouldBeTrue
:: ccc0 'ccc.type :ccc-u1 getNamedStructureSlot 101 = ; shouldBeTrue
:: ccc0 'ccc.type :ccc-s0 getNamedStructureSlot 102 = ; shouldBeTrue
:: ccc0 'ccc.type :ccc-s1 getNamedStructureSlot 103 = ; shouldBeTrue

:: ccc1 110 'ccc.type :ccc-u0 setNamedStructureSlot  ; shouldWork
:: ccc1 111 'ccc.type :ccc-u1 setNamedStructureSlot  ; shouldWork
:: ccc1 112 'ccc.type :ccc-s0 setNamedStructureSlot  ; shouldWork
:: ccc1 113 'ccc.type :ccc-s1 setNamedStructureSlot  ; shouldWork


:: ccc1 'ccc.type :ccc-u0 getNamedStructureSlot 110 = ; shouldBeTrue
:: ccc1 'ccc.type :ccc-u1 getNamedStructureSlot 111 = ; shouldBeTrue
:: ccc1 'ccc.type :ccc-s0 getNamedStructureSlot 112 = ; shouldBeTrue
:: ccc1 'ccc.type :ccc-s1 getNamedStructureSlot 113 = ; shouldBeTrue



:: ddd0 200 'ddd.type :ccc-u0 setNamedStructureSlot  ; shouldWork
:: ddd0 201 'ddd.type :ccc-u1 setNamedStructureSlot  ; shouldWork
:: ddd0 202 'ddd.type :ccc-s0 setNamedStructureSlot  ; shouldWork
:: ddd0 203 'ddd.type :ccc-s1 setNamedStructureSlot  ; shouldWork
:: ddd0 204 'ddd.type :ddd-u0 setNamedStructureSlot  ; shouldWork
:: ddd0 205 'ddd.type :ddd-u1 setNamedStructureSlot  ; shouldWork
:: ddd0 206 'ddd.type :ddd-s0 setNamedStructureSlot  ; shouldWork
:: ddd0 207 'ddd.type :ddd-s1 setNamedStructureSlot  ; shouldWork

:: ddd0 'ddd.type :ccc-u0 getNamedStructureSlot 200 = ; shouldBeTrue
:: ddd0 'ddd.type :ccc-u1 getNamedStructureSlot 201 = ; shouldBeTrue
:: ddd0 'ddd.type :ccc-s0 getNamedStructureSlot 202 = ; shouldBeTrue
:: ddd0 'ddd.type :ccc-s1 getNamedStructureSlot 203 = ; shouldBeTrue
:: ddd0 'ddd.type :ddd-u0 getNamedStructureSlot 204 = ; shouldBeTrue
:: ddd0 'ddd.type :ddd-u1 getNamedStructureSlot 205 = ; shouldBeTrue
:: ddd0 'ddd.type :ddd-s0 getNamedStructureSlot 206 = ; shouldBeTrue
:: ddd0 'ddd.type :ddd-s1 getNamedStructureSlot 207 = ; shouldBeTrue

:: ddd1 210 'ddd.type :ccc-u0 setNamedStructureSlot  ; shouldWork
:: ddd1 211 'ddd.type :ccc-u1 setNamedStructureSlot  ; shouldWork
:: ddd1 212 'ddd.type :ccc-s0 setNamedStructureSlot  ; shouldWork
:: ddd1 213 'ddd.type :ccc-s1 setNamedStructureSlot  ; shouldWork
:: ddd1 214 'ddd.type :ddd-u0 setNamedStructureSlot  ; shouldWork
:: ddd1 215 'ddd.type :ddd-u1 setNamedStructureSlot  ; shouldWork
:: ddd1 216 'ddd.type :ddd-s0 setNamedStructureSlot  ; shouldWork
:: ddd1 217 'ddd.type :ddd-s1 setNamedStructureSlot  ; shouldWork

:: ddd1 'ddd.type :ccc-u0 getNamedStructureSlot 210 = ; shouldBeTrue
:: ddd1 'ddd.type :ccc-u1 getNamedStructureSlot 211 = ; shouldBeTrue
:: ddd1 'ddd.type :ccc-s0 getNamedStructureSlot 212 = ; shouldBeTrue
:: ddd1 'ddd.type :ccc-s1 getNamedStructureSlot 213 = ; shouldBeTrue
:: ddd1 'ddd.type :ddd-u0 getNamedStructureSlot 214 = ; shouldBeTrue
:: ddd1 'ddd.type :ddd-u1 getNamedStructureSlot 215 = ; shouldBeTrue
:: ddd1 'ddd.type :ddd-s0 getNamedStructureSlot 216 = ; shouldBeTrue
:: ddd1 'ddd.type :ddd-s1 getNamedStructureSlot 217 = ; shouldBeTrue


( Now, we read back all the slots again )
( to check that sharing resulted in the )
( expected pattern of value clobbering: )

:: ccc0 'ccc.type :ccc-u0 getNamedStructureSlot 100 = ; shouldBeTrue
:: ccc0 'ccc.type :ccc-u1 getNamedStructureSlot 101 = ; shouldBeTrue
:: ccc0 'ccc.type :ccc-s0 getNamedStructureSlot 212 = ; shouldBeTrue
:: ccc0 'ccc.type :ccc-s1 getNamedStructureSlot 213 = ; shouldBeTrue

:: ccc1 'ccc.type :ccc-u0 getNamedStructureSlot 110 = ; shouldBeTrue
:: ccc1 'ccc.type :ccc-u1 getNamedStructureSlot 111 = ; shouldBeTrue
:: ccc1 'ccc.type :ccc-s0 getNamedStructureSlot 212 = ; shouldBeTrue
:: ccc1 'ccc.type :ccc-s1 getNamedStructureSlot 213 = ; shouldBeTrue

:: ddd0 'ddd.type :ccc-u0 getNamedStructureSlot 200 = ; shouldBeTrue
:: ddd0 'ddd.type :ccc-u1 getNamedStructureSlot 201 = ; shouldBeTrue
:: ddd0 'ddd.type :ccc-s0 getNamedStructureSlot 212 = ; shouldBeTrue
:: ddd0 'ddd.type :ccc-s1 getNamedStructureSlot 213 = ; shouldBeTrue
:: ddd0 'ddd.type :ddd-u0 getNamedStructureSlot 204 = ; shouldBeTrue
:: ddd0 'ddd.type :ddd-u1 getNamedStructureSlot 205 = ; shouldBeTrue
:: ddd0 'ddd.type :ddd-s0 getNamedStructureSlot 216 = ; shouldBeTrue
:: ddd0 'ddd.type :ddd-s1 getNamedStructureSlot 217 = ; shouldBeTrue

:: ddd1 'ddd.type :ccc-u0 getNamedStructureSlot 210 = ; shouldBeTrue
:: ddd1 'ddd.type :ccc-u1 getNamedStructureSlot 211 = ; shouldBeTrue
:: ddd1 'ddd.type :ccc-s0 getNamedStructureSlot 212 = ; shouldBeTrue
:: ddd1 'ddd.type :ccc-s1 getNamedStructureSlot 213 = ; shouldBeTrue
:: ddd1 'ddd.type :ddd-u0 getNamedStructureSlot 214 = ; shouldBeTrue
:: ddd1 'ddd.type :ddd-u1 getNamedStructureSlot 215 = ; shouldBeTrue
:: ddd1 'ddd.type :ddd-s0 getNamedStructureSlot 216 = ; shouldBeTrue
:: ddd1 'ddd.type :ddd-s1 getNamedStructureSlot 217 = ; shouldBeTrue



( Should be able to read same )
( slots using path notation:  )

:: ccc0.ccc-u0 100 = ; shouldBeTrue
:: ccc0.ccc-u1 101 = ; shouldBeTrue
:: ccc0.ccc-s0 212 = ; shouldBeTrue
:: ccc0.ccc-s1 213 = ; shouldBeTrue

:: ccc1.ccc-u0 110 = ; shouldBeTrue
:: ccc1.ccc-u1 111 = ; shouldBeTrue
:: ccc1.ccc-s0 212 = ; shouldBeTrue
:: ccc1.ccc-s1 213 = ; shouldBeTrue
	  	 
:: ddd0.ccc-u0 200 = ; shouldBeTrue
:: ddd0.ccc-u1 201 = ; shouldBeTrue
:: ddd0.ccc-s0 212 = ; shouldBeTrue
:: ddd0.ccc-s1 213 = ; shouldBeTrue
:: ddd0.ddd-u0 204 = ; shouldBeTrue
:: ddd0.ddd-u1 205 = ; shouldBeTrue
:: ddd0.ddd-s0 216 = ; shouldBeTrue
:: ddd0.ddd-s1 217 = ; shouldBeTrue
	  	 
:: ddd1.ccc-u0 210 = ; shouldBeTrue
:: ddd1.ccc-u1 211 = ; shouldBeTrue
:: ddd1.ccc-s0 212 = ; shouldBeTrue
:: ddd1.ccc-s1 213 = ; shouldBeTrue
:: ddd1.ddd-u0 214 = ; shouldBeTrue
:: ddd1.ddd-u1 215 = ; shouldBeTrue
:: ddd1.ddd-s0 216 = ; shouldBeTrue
:: ddd1.ddd-s1 217 = ; shouldBeTrue



( Should be able to write same )
( slots using path notation:   )

:: 9210 --> ddd1.ccc-u0 ; shouldWork
:: 9211 --> ddd1.ccc-u1 ; shouldWork
:: 9212 --> ddd1.ccc-s0 ; shouldWork
:: 9213 --> ddd1.ccc-s1 ; shouldWork
:: 9214 --> ddd1.ddd-u0 ; shouldWork
:: 9215 --> ddd1.ddd-u1 ; shouldWork
:: 9216 --> ddd1.ddd-s0 ; shouldWork
:: 9217 --> ddd1.ddd-s1 ; shouldWork

:: ddd1.ccc-u0 9210 = ; shouldBeTrue
:: ddd1.ccc-u1 9211 = ; shouldBeTrue
:: ddd1.ccc-s0 9212 = ; shouldBeTrue
:: ddd1.ccc-s1 9213 = ; shouldBeTrue
:: ddd1.ddd-u0 9214 = ; shouldBeTrue
:: ddd1.ddd-u1 9215 = ; shouldBeTrue
:: ddd1.ddd-s0 9216 = ; shouldBeTrue
:: ddd1.ddd-s1 9217 = ; shouldBeTrue



( Tests 610-614: )

( Basic |makeInstance invocation: )
:: defclass: xx ; ; shouldWork
:: [ 'xx | |makeInstance ]--> xxi ; shouldWork
:: xxi$s.isA 'xx$s.type$s.key = ; shouldBeTrue

( The makeInstance wrapper for makeInstance: )
:: 'xx makeInstance --> xxi ; shouldWork
:: xxi$s.isA 'xx$s.type$s.key = ; shouldBeTrue


( Tests 615-: )

( Basic default method declaration and invocation: )
:: defgeneric: yy { $ -> $ } ; ; shouldWork
:: defmethod:  yy { 't } 2 * ; ; shouldWork
:: 13 yy 26 = ; shouldBeTrue
