( --------------------------------------------------------------------- )
(			x-est.muf				    CrT )
( Exercise structure operators.						)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      95Oct06							)
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
(                              history                              CrT )
(                                                                       )
( 95Oct06 jsp	Created.						)
( --------------------------------------------------------------------- )

"Ephemeral structure tests\n" log,
"\nEphemeral structure tests:" ,



( Tests 1-21: )

:: nil --> 'dad.type ; shouldWork
:: nil --> 'kid.type ; shouldWork
:: defstruct: dad 'key0 ; ; shouldWork
:: defstruct: kid :include 'dad 'key1 'key2 ; ; shouldWork
:: [ :ephemeral t | 'kid ]makeStructure --> _stc ; shouldWork
:: [ :ephemeral t | 'kid ]makeStructure length2 3 = ; shouldBeTrue
:: [ :ephemeral t | 'kid ]makeStructure ephemeral? ; shouldBeTrue
:: [ :ephemeral t | 'kid ]makeStructure structure? ; shouldBeTrue
:: [ :ephemeral t | 'kid ]makeStructure kid? ; shouldBeTrue

:: 'kid.type.key.createdAnInstance t = ; shouldBeTrue
:: [ :ephemeral t :key0 7 | 'kid ]makeStructure kidKey0 7 = ; shouldBeTrue
:: [ :ephemeral t :key1 8 | 'kid ]makeStructure kidKey1 8 = ; shouldBeTrue
:: [ :ephemeral t :key2 9 | 'kid ]makeStructure kidKey2 9 = ; shouldBeTrue

:: [ :ephemeral t :key0 7 | 'kid ]makeStructure -> x x.key0 7 = ; shouldBeTrue
:: [ :ephemeral t :key1 8 | 'kid ]makeStructure -> x x.key1 8 = ; shouldBeTrue
:: [ :ephemeral t :key2 9 | 'kid ]makeStructure -> x x.key2 9 = ; shouldBeTrue

:: [ :ephemeral t | 'kid ]makeStructure -> x 7 --> x.key0 x kidKey0 7 = ; shouldBeTrue
:: [ :ephemeral t | 'kid ]makeStructure -> x 8 --> x.key1 x kidKey1 8 = ; shouldBeTrue
:: [ :ephemeral t | 'kid ]makeStructure -> x 9 --> x.key2 x kidKey2 9 = ; shouldBeTrue

:: [ :ephemeral t | 'kid ]makeStructure copyKid --> _kid ; shouldWork
:: _kid kid? ; shouldBeTrue

:: [ :ephemeral t :key0 13 | 'kid ]makeStructure copyKid --> _kid ; shouldWork

:: _kid.key0 13 =  ; shouldBeTrue




( Tests 22-42: Initform stuff: )
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

:: [ :ephemeral t | _mom ]makeStructure --> _m   ( 1 11 )
   _m _mom.mosClass 0 getNthStructureSlot 1  = 
; shouldBeTrue
:: [ :ephemeral t | _mom ]makeStructure --> _m   ( 2 12 )
   _m _mom.mosClass 1 getNthStructureSlot 12 = 
; shouldBeTrue

:: [ :ephemeral t | _mom ]makeStructure --> _m   ( 3 13 )
   _m _mom.mosClass 0 getNthStructureSlot 3  = 
; shouldBeTrue
:: [ :ephemeral t | _mom ]makeStructure --> _m   ( 4 14 )
   _m _mom.mosClass 1 getNthStructureSlot 14 = 
; shouldBeTrue

:: [ :ephemeral t :a 97 | _mom ]makeStructure --> _m   ( 4 15 )
   _m _mom.mosClass 0 getNthStructureSlot 97 = 
; shouldBeTrue
:: [ :ephemeral t :a 97 | _mom ]makeStructure --> _m   ( 4 16 )
   _m _mom.mosClass 1 getNthStructureSlot 16 = 
; shouldBeTrue

:: [ :ephemeral t :b 99 | _mom ]makeStructure --> _m   ( 5 16 )
   _m _mom.mosClass 0 getNthStructureSlot  5 = 
; shouldBeTrue
:: [ :ephemeral t :b 99 | _mom ]makeStructure --> _m   ( 6 16 )
   _m _mom.mosClass 1 getNthStructureSlot 99 = 
; shouldBeTrue

:: [ :ephemeral t :a 77 :b 88 | _mom ]makeStructure --> _m   ( 6 16 )
   _m _mom.mosClass 0 getNthStructureSlot 77 = 
; shouldBeTrue
:: [ :ephemeral t :a 77 :b 88 | _mom ]makeStructure --> _m   ( 6 16 )
   _m _mom.mosClass 1 getNthStructureSlot 88 = 
; shouldBeTrue

:: [ :ephemeral t | _mom ]makeStructure --> _m   ( 7 17 )
   _m _mom.mosClass 0 getNthStructureSlot 7 = 
; shouldBeTrue
:: [ :ephemeral t | _mom ]makeStructure --> _m   ( 8 18 )
   _m _mom.mosClass 1 getNthStructureSlot 18 = 
; shouldBeTrue

:: [ :ephemeral t | _mom ]makeStructure --> _m 
   _m getMosKey _mom =
; shouldBeTrue





