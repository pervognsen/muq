( --------------------------------------------------------------------- )
(			x-jump.muf				    CrT )
( Exercise control structures and things that mess with loop stack.	)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      93Jul22							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1993-1995, by Jeff Prothero.				)
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
( 93Jul22 jsp	Created.						)
( --------------------------------------------------------------------- )

"Control structure and variables tests\n" log,
"\nControl structure and variables tests:" ,


( Tests 1-4: Basic 'if' functionality. )

:: 2 nil if 1 else 2 fi = ; shouldBeTrue
:: 1 nil if 1 else 2 fi = ; shouldBeFalse
:: 2 t   if 1 else 2 fi = ; shouldBeFalse
:: 1 t   if 1 else 2 fi = ; shouldBeTrue



( Tests 5-6: Basic local variable functionality. )

::   0 -> zero   1 -> one   zero 0 = ; shouldBeTrue
::   0 -> zero   1 -> one    one 1 = ; shouldBeTrue



( Tests 7-10: Basic function-call and 'call. )

: x * ; ::    4 5 x           20 = ; shouldBeTrue
:: { -> $ ! } 4 5 'x     call 20 = ; shouldBeTrue
:: : y * ;    4 5 y           20 = ; shouldBeTrue
:: { -> $ ! } 4 5 :: * ; call 20 = ; shouldBeTrue



( Tests 11-18: Basic catch/throw functionality. )

:: [ | 1 ]throw ; shouldFail
:: ]throw ; shouldFail
:: catch{ } ; shouldFail
:: 13 catch{ } -> f ]pop f ; shouldBeFalse

:: 13 catch{ [ "a" | 14 ]throw } -> f ]pop f ; shouldFail
:: 13 catch{ [ "a" | 13 ]throw } -> f ]pop f ; shouldBeTrue
:: 13 catch{ [ "a" | 13 ]throw } pop |length 1 = -> f ]pop f ; shouldBeTrue
:: { -> $ ! }
    : x [ "a" | 13 ]throw ;
    13 catch{ x } pop |length 1 = -> r
    ]pop
    r
; shouldBeTrue




( Tests 19-25: Global/local variable [non]interactions. )

::  0 --> e  1 --> e        e 1 = ; shouldBeTrue
::  2  -> e  3  -> e        e 3 = ; shouldBeTrue
::                          e 1 = ; shouldBeTrue

:: { -> $ ! } 4 -> e :: 5  -> e ; call e 4 = ; shouldBeTrue
::                                     e 1 = ; shouldBeTrue
:: { -> $ ! } 6 -> e :: 7 --> e ; call e 6 = ; shouldBeTrue
::                                     e 7 = ; shouldBeTrue



( Test 26: This crashed us 93Jul27! )
:: { -> ? } 233 call ; shouldFail



( Tests 27-29: "True lambdas" *grin* )
:: 2 -> two 3 -> three :: if 'two else 'three fi ; ; shouldWork
:: 2 -> two 3 -> three :: if 'two else 'three fi ; ; 
"\n -- NOTE! -- Tests 28 and 29 SHOULD fail, at present.\n" ,
: q { $ -> $ ! } call ; q --> x23
:: { -> $ ! } nil 'x23 call 3 = ; shouldBeTrue
:: { -> $ ! } t   'x23 call 2 = ; shouldBeTrue



( Tests 30-34: Thunks: )
( :: *: 2 ; *: 3 ; * 6 = ; shouldBeTrue )
( :: *:  depth ; 0 = ; shouldBeTrue )
( :: 1 1 *: 1 dupNth ; 0 = ; shouldFail )
( :: 1 1 *: ; 0 = ; shouldFail )
( :: 1 1 *: 1 1 ; 0 = ; shouldFail )



( Test 35: loop ... until: )
::
  1 -> i
  0 -> sum
  do{
    i sum + -> sum  
    i   1 + -> i
    i  10 = until
  }
  sum 45 =
;
shouldBeTrue



( Test 36: loop ... while ... repeat: )
::
  1 -> i
  0 -> sum
  do{
    i sum + -> sum  
    i   1 + -> i
    i  10 < while
  }
  sum 45 =
;
shouldBeTrue



( Test 37: loop ... loopFinish ... repeat: )
( :: loopFinish ; shouldFail ) ( Can't trap compileTime errs yet. )
::
  1 -> i
  0 -> sum
  do{
    i sum + -> sum  
    i   1 + -> i
    i  10 = if loopFinish fi
  }
  sum 45 =
;
shouldBeTrue



( Test 38: loop ... loopNext ... repeat: )
( :: loopFinish ; shouldFail ) ( Can't trap compileTime errs yet. )
::
  1 -> i
  0 -> sum
  do{
    i sum + -> sum  
    i   1 + -> i
    i  10 < if loopNext fi
    loopFinish
  }
  sum 45 =
;
shouldBeTrue



( Tests 39-44: )

:: nil  if t else nil fi ; shouldBeFalse
:: 0.0  if t else nil fi ; shouldBeTrue
::  ""  if t else nil fi ; shouldBeTrue

:: t    if t else nil fi ; shouldBeTrue
:: 1.0  if t else nil fi ; shouldBeTrue
:: "a"  if t else nil fi ; shouldBeTrue



( Tests 45-46: )
:: "t0" forkJob dup if pop else nil endJob   fi ; shouldWork
:: "t1" forkJob dup if killJobMessily else pop fi ; shouldWork



( Tests 47-49: Check withTags stuff: )

::  "" --> tmp
    withTag x do{
        tmp "a" join --> tmp
        'x goto
        tmp "b" join --> tmp
    x
        tmp "c" join --> tmp
    }
    tmp "ac" =
; shouldBeTrue

::  "" --> tmp
    withTags x y z do{
        tmp "a" join --> tmp
        'y goto
        tmp "b" join --> tmp
    x
        tmp "c" join --> tmp
	'z goto
    y
        tmp "d" join --> tmp
	'x goto
    z
        tmp "e" join --> tmp
    }
    tmp "adce" =
; shouldBeTrue

::  
    "" --> tmp
    : f -> arg
        withTags x y do{
            : g -> arg
		arg if
		    'x goto
		else
		    'y goto
		fi
	    ;
	    arg g
	x
            tmp "a" join --> tmp
	y
            tmp "b" join --> tmp
	}
    ;
    t   f
    nil f
    tmp "abb" =
; shouldBeTrue


# ( Tests 11-17: Basic errset/error/cerror functionality. )
# 
# :: [ "oops" | ]throw-error ; shouldFail
# :: [ "oops" | ]throw-continuable-error ; shouldFail
# :: catch-errors{ [ "oops" | ]throw-continuable-error } -> f ]pop f ; shouldBeTrue
# :: catch-errors{ [ "oops" | ]throw-error } -> f ]pop f ; shouldBeTrue
# 
# :: catch-errors{ 0 1 /         } -> f ]pop f ; shouldBeFalse
# :: catch-errors{ 1 0 /         } -> f ]pop f ; shouldBeTrue
# :: catch-errors{               } -> f ]pop f ; shouldBeFalse



( Tests 26-36: Basic after/alwaysDo functionality. )

# :: after{ [ "a" | ]throw-error }alwaysDo{ } ; shouldFail
# :: 0 --> a after{ [ "a" | ]throw-error 1 --> a }alwaysDo{         } ; shouldFail
# :: a 0 = ; shouldBeTrue
# :: 0 --> a after{ [ "a" | ]throw-error 1 --> a }alwaysDo{ 2 --> a } ; shouldFail
# :: a 2 = ; shouldBeTrue
# 
# :: 0 --> a after{             1 --> a }alwaysDo{         } ; shouldWork
# :: a 1 = ; shouldBeTrue
# :: 0 --> a after{             1 --> a }alwaysDo{ 2 --> a } ; shouldWork
# :: a 2 = ; shouldBeTrue
# 
# :: { -> $ ! } 4 -> b : x  5 -> b [ "x" | ]throw-error ; after{ x 6 -> b }alwaysDo{ b --> a } ; shouldFail
# :: { -> @ ! } a 4 = ; shouldBeTrue


( Tests 65: Check that after-do clause runs with correct )
( local variable stackframe restored: )
# : s { -> @ }   14 -> a  [ "err" | ]throw-error ;
# : r { -> @ } s 13 -> a ;
# : q { -> ! } catch-errors{ 12 -> a after{ r }alwaysDo{ a --> v } } -> f ]pop f ;
# :: 10 --> v   q   v 12 =   ;    shouldBeTrue



