( --------------------------------------------------------------------- )
(			x-debug.muf				    CrT )
( Exercise debugger-related stuff.					)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      95Apr29							)
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
( 95Apr29 jsp	Created.						)
( --------------------------------------------------------------------- )

"Debugger support function tests\n" log,
"\nDebugger support function tests:" ,

( Tests 1-3: Check counting stackframes: )
: f @ countStackframes --> _count ;
: g f ;
:: f ; shouldWork
_count --> _countZero
:: g ; shouldWork
:: _countZero 1 + _count = ; shouldBeTrue

( Tests 4-10: Fetching various things from NORMAL stackframe: )
::  @ countStackframes 1 - @ getStackframe[ ]pop ; shouldWork
::  @ countStackframes 1 - @ getStackframe[
        :kind |get -> kind
    ]pop
    kind :normal =
; shouldBeTrue
::  @ countStackframes 1 - @ getStackframe[
        :owner |get -> owner
    ]pop
    owner me =
; shouldBeTrue
::  @ countStackframes 1 - @ getStackframe[
        :variables |get -> variables
    ]pop
    variables 1 =
; shouldBeTrue
::  @ countStackframes 1 - @ getStackframe[
        :programCounter |get -> pc
    ]pop
    pc integer?
; shouldBeTrue
::  @ countStackframes 1 - @ getStackframe[
        :compiledFunction |get -> fn
    ]pop
    fn compiledFunction?
; shouldBeTrue
::  12 -> x
    @ countStackframes 1 - @ getStackframe[
        0 |get --> _x
    ]pop
    x _x =
; shouldBeTrue

( Tests 11-18: Fetching various things from HANDLERS stackframe: )
: f { [] -> [] ! } ;
::  [ .e.warning #'f | ]withHandlerDo{
        @ countStackframes 1 - @ getStackframe[
	    :kind |get -> kind
	]pop
    }
    kind :handlers =
; shouldBeTrue
::  [ .e.warning #'f | ]withHandlerDo{
        @ countStackframes 1 - @ getStackframe[
	    :owner |get -> owner
	]pop
    }
    owner me =
; shouldBeTrue
::  [ .e.warning #'f | ]withHandlerDo{
        @ countStackframes 1 - @ getStackframe[
	    :handlers |get -> handlers
	]pop
    }
    handlers 1 =
; shouldBeTrue
: g { [] -> [] ! } ;
::  [ .e.warning #'f .e.error #'g | ]withHandlerDo{
        @ countStackframes 1 - @ getStackframe[
	    :handlers |get -> handlers
	]pop
    }
    handlers 2 =
; shouldBeTrue
::  [ .e.warning #'f .e.error #'g | ]withHandlerDo{
        @ countStackframes 1 - @ getStackframe[
	    0 |get -> cond0
	]pop
    }
    .e.warning cond0 =
; shouldBeTrue
::  [ .e.warning #'f .e.error #'g | ]withHandlerDo{
        @ countStackframes 1 - @ getStackframe[
	    1 |get -> hand0
	]pop
    }
    #'f hand0 =
; shouldBeTrue
::  [ .e.warning #'f .e.error #'g | ]withHandlerDo{
        @ countStackframes 1 - @ getStackframe[
	    2 |get -> cond1
	]pop
    }
    .e.error cond1 =
; shouldBeTrue
::  [ .e.warning #'f .e.error #'g | ]withHandlerDo{
        @ countStackframes 1 - @ getStackframe[
	    3 |get -> hand1
	]pop
    }
    #'g hand1 =
; shouldBeTrue

( Tests 19-21: Fetching various things from LOCK stackframe: )
makeLock --> _myLock
::  _myLock withLockDo{
        @ countStackframes 1 - @ getStackframe[
	    :kind |get -> kind
	]pop
    }
    kind :lock =
; shouldBeTrue
::  _myLock withLockDo{
        @ countStackframes 1 - @ getStackframe[
	    :owner |get -> owner
	]pop
    }
    owner me =
; shouldBeTrue
::  _myLock withLockDo{
        @ countStackframes 1 - @ getStackframe[
	    :lock |get -> lock
	]pop
    }
    lock _myLock =
; shouldBeTrue



( Tests 22-29: Fun with ephemeral structures: )
:: defstruct: qq 'a 'b 'c ; ; shouldWork
:: [ :ephemeral t :a 10 :b 11 :c 12 |
   'qq ]makeStructure pop
   @ countStackframes 1 - @ getStackframe[
   :owner |get -> x ]pop
   x @.actingUser =
; shouldBeTrue
:: [ :ephemeral t :a 10 :b 11 :c 12 |
   'qq ]makeStructure pop
   @ countStackframes 1 - @ getStackframe[
   :kind |get -> x ]pop
   x :ephemeral-struct
; shouldBeTrue
:: [ :ephemeral t :a 10 :b 11 :c 12 |
   'qq ]makeStructure pop
   @ countStackframes 1 - @ getStackframe[
   :isA |get -> x ]pop
   x 'qq.type.key =
; shouldBeTrue
:: [ :ephemeral t :a 10 :b 11 :c 12 |
   'qq ]makeStructure pop
   @ countStackframes 1 - @ getStackframe[
   :slots |get -> x ]pop
   x 3 =
; shouldBeTrue
:: [ :ephemeral t :a 10 :b 11 :c 12 |
   'qq ]makeStructure pop
   @ countStackframes 1 - @ getStackframe[
   0 |get -> x ]pop
   x 10 =
; shouldBeTrue
:: [ :ephemeral t :a 10 :b 11 :c 12 |
   'qq ]makeStructure pop
   @ countStackframes 1 - @ getStackframe[
   1 |get -> x ]pop
   x 11 =
; shouldBeTrue
:: [ :ephemeral t :a 10 :b 11 :c 12 |
   'qq ]makeStructure pop
   @ countStackframes 1 - @ getStackframe[
   2 |get -> x ]pop
   x 12 =
; shouldBeTrue


( Tests 30-35: Fun with ephemeral vectors: )
:: [ 'a' 'b' 'c' | ]evec pop
   @ countStackframes 1 - @ getStackframe[
   :owner |get -> x ]pop
   x @.actingUser =
; shouldBeTrue
:: [ 'a' 'b' 'c' | ]evec pop
   @ countStackframes 1 - @ getStackframe[
   :kind |get -> x ]pop
   x :ephemeral-vector
; shouldBeTrue
:: [ 'a' 'b' 'c' | ]evec pop
   @ countStackframes 1 - @ getStackframe[
   :slots |get -> x ]pop
   x 3 =
; shouldBeTrue
:: [ 'a' 'b' 'c' | ]evec pop
   @ countStackframes 1 - @ getStackframe[
   0 |get -> x ]pop
   x 'a' =
; shouldBeTrue
:: [ 'a' 'b' 'c' | ]evec pop
   @ countStackframes 1 - @ getStackframe[
   1 |get -> x ]pop
   x 'b' =
; shouldBeTrue
:: [ 'a' 'b' 'c' | ]evec pop
   @ countStackframes 1 - @ getStackframe[
   2 |get -> x ]pop
   x 'c' =
; shouldBeTrue

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
