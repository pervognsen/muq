( --------------------------------------------------------------------- )
(			x-arith.muf				    CrT )
( Exercise arithmetic operators.					)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      93Jul16							)
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
( Jeff Prothero DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, )
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
( 93Jul16 jsp	Created.						)
( --------------------------------------------------------------------- )

"Arithmetic tests\n" log,
"\nArithmetic tests:" ,

( Tests 1-10: )

:: 2   2   +  4   = ; shouldBeTrue
:: 2   2   +  5   = ; shouldBeFalse

:: 2.0 2.0 +  4.0 = ; shouldBeTrue
:: 2.0 2   +  4.0 = ; shouldBeTrue

( Backups were crashing us for awhile, undetected because the )
( regression suite didn't do any, so here's one to prevent    )
( any repeats of that experience:                             )

rootDoBackup

:: 2   1   -  1   = ; shouldBeTrue
:: 1   2   - -1   = ; shouldBeTrue

:: 2.0 1.0 -  1.0 = ; shouldBeTrue
:: 1.0 2.0 - -1.0 = ; shouldBeTrue

:: 2.0 1   -  1.0 = ; shouldBeTrue
:: 1.0 2   - -1.0 = ; shouldBeTrue



( Tests 11-20: )

:: 2   3   *  6   = ; shouldBeTrue
:: 2.0 3.0 *  6.0 = ; shouldBeTrue
:: 2.0 3   *  6   = ; shouldBeTrue


:: 4   2   /  2   = ; shouldBeTrue
:: 4.0 2.0 /  2.0 = ; shouldBeTrue
:: 4.0 2   /  2.0 = ; shouldBeTrue


:: 1   0   /        ;    shouldFail
:: 1.0 0.0 /        ;    shouldFail
:: 1.0 0   /        ;    shouldFail

:: 5   2   %  1   = ; shouldBeTrue



( Tests 21-32: )

:: 1   1   <       ; shouldBeFalse
:: 1.0 1.0 <       ; shouldBeFalse
:: 1.0 1   <       ; shouldBeFalse

:: 1   2   <       ; shouldBeTrue
:: 1.0 2.0 <       ; shouldBeTrue
:: 1.0 2   <       ; shouldBeTrue

:: 1   1   <=      ; shouldBeTrue
:: 1.0 1.0 <=      ; shouldBeTrue
:: 1.0 1   <=      ; shouldBeTrue

:: 2   1   <=      ; shouldBeFalse
:: 2.0 1.0 <=      ; shouldBeFalse
:: 2.0 1   <=      ; shouldBeFalse



( Tests 33-44: )

:: 1   1   >       ; shouldBeFalse
:: 1.0 1.0 >       ; shouldBeFalse
:: 1.0 1   >       ; shouldBeFalse

:: 2   1   >       ; shouldBeTrue
:: 2.0 1.0 >       ; shouldBeTrue
:: 2.0 1   >       ; shouldBeTrue

:: 1   1   >=      ; shouldBeTrue
:: 1.0 1.0 >=      ; shouldBeTrue
:: 1.0 1   >=      ; shouldBeTrue

:: 1   2   >=      ; shouldBeFalse
:: 1.0 2.0 >=      ; shouldBeFalse
:: 1.0 2   >=      ; shouldBeFalse



( Tests 45-51: )

::         not ; shouldFail
:: nil     not ; shouldBeTrue
:: 1       not ; shouldBeFalse

:: 0.0  not ; shouldBeFalse
:: 1.0  not ; shouldBeFalse
:: ""   not ; shouldBeFalse

:: "a"  not ; shouldBeFalse



( Tests 52-72: )

::                   and ; shouldFail
::   0               and ; shouldFail
::   nil     nil     and ; shouldBeFalse

::   t       nil     and ; shouldBeFalse
::   nil     t       and ; shouldBeFalse
::   t       t       and ; shouldBeTrue

:: 0.0 0.0 and ; shouldBeTrue
:: 1.0 0.0 and ; shouldBeTrue
:: 0.0 1.0 and ; shouldBeTrue

:: 1.0 1.0 and ; shouldBeTrue
::  ""  "" and ; shouldBeTrue
:: "a"  "" and ; shouldBeTrue

::  "" "a" and ; shouldBeTrue
:: "a" "a" and ; shouldBeTrue
:: "a"   1 and ; shouldBeTrue

:: "a" 1.0 and ; shouldBeTrue
:: "a"   0 and ; shouldBeTrue
::   0 "a" and ; shouldBeTrue

::   1 "a" and ; shouldBeTrue
:: 1.0 "a" and ; shouldBeTrue
:: 1.0   1 and ; shouldBeTrue



( Tests 73-93: )

::                    or ; shouldFail		( 73 )
::   0                or ; shouldFail		( 74 )
::   nil     nil      or ; shouldBeFalse	( 75 )

::   t       nil      or ; shouldBeTrue	( 76 )
::   nil     t        or ; shouldBeTrue	( 77 )
::   t       t        or ; shouldBeTrue	( 78 )

:: 0.0 0.0  or ; shouldBeTrue			( 79 )
:: 1.0 0.0  or ; shouldBeTrue			( 80 )
:: 0.0 1.0  or ; shouldBeTrue			( 81 )

:: 1.0 1.0  or ; shouldBeTrue			( 82 )
::  ""  ""  or ; shouldBeTrue			( 83 )
:: "a"  ""  or ; shouldBeTrue			( 84 )

::  "" "a"  or ; shouldBeTrue			( 85 )
:: "a" "a"  or ; shouldBeTrue			( 86 )
:: "a"   1  or ; shouldBeTrue			( 87 )

:: "a" 1.0  or ; shouldBeTrue			( 88 )
:: "a"   0  or ; shouldBeTrue			( 89 )
::   0 "a"  or ; shouldBeTrue			( 90 )

::   1 "a"  or ; shouldBeTrue			( 91 )
:: 1.0 "a"  or ; shouldBeTrue			( 92 )
:: 0.0   0  or ; shouldBeTrue			( 93 )



( Tests 94-99: )

::      logand     ; shouldFail
::    1 logand     ; shouldFail
::  "a" logand     ; shouldFail

::  1.0 logand     ; shouldFail
:: "" 5 logand     ; shouldFail
:: 3  5 logand 1 = ; shouldBeTrue



( Tests 100-105: )

::      logior     ; shouldFail
::    1 logior     ; shouldFail
::  "a" logior     ; shouldFail

::  1.0 logior     ; shouldFail
:: "" 5 logior     ; shouldFail
:: 3  5 logior 7 = ; shouldBeTrue



( Tests 106-111: )

::      logxor     ; shouldFail
::    1 logxor     ; shouldFail
::  "a" logxor     ; shouldFail

::  1.0 logxor     ; shouldFail
:: "" 5 logxor     ; shouldFail
:: 3  5 logxor 6 = ; shouldBeTrue



( Tests 112-118: )

::       ash      ; shouldFail
::     1 ash      ; shouldFail
::   "a" ash      ; shouldFail

::   1.0 ash      ; shouldFail
::  "" 5 ash      ; shouldFail
::  2  3 ash 16 = ; shouldBeTrue

:: 16 -3 ash  2 = ; shouldBeTrue



( Tests 119-122: )
::   13  -> a   ++ a   a 14 =   ;  shouldBeTrue
::   13  -> a   -- a   a 12 =   ;  shouldBeTrue
::   13 --> a   ++ a   a 14 =   ;  shouldBeTrue
::   13 --> a   -- a   a 12 =   ;  shouldBeTrue




( Tests 122-32: )

:: "1"   "1"   <       ; shouldBeFalse
:: "1.0" "1.0" <       ; shouldBeFalse
:: "1.0" "1"   <       ; shouldBeFalse

:: "1"   "2"   <       ; shouldBeTrue
:: "1.0" "2.0" <       ; shouldBeTrue
:: "1.0" "2"   <       ; shouldBeTrue

:: "1"   "1"   <=      ; shouldBeTrue
:: "1.0" "1.0" <=      ; shouldBeTrue
:: "1.0" "1"   <=      ; shouldBeFalse

:: "2"   "1"   <=      ; shouldBeFalse
:: "2.0" "1.0" <=      ; shouldBeFalse
:: "2.0" "1"   <=      ; shouldBeFalse



( Tests 135-46: )

:: "1"   "1"   >       ; shouldBeFalse
:: "1.0" "1.0" >       ; shouldBeFalse
:: "1.0" "1"   >       ; shouldBeTrue

:: "2"   "1"   >       ; shouldBeTrue
:: "2.0" "1.0" >       ; shouldBeTrue
:: "2.0" "1"   >       ; shouldBeTrue

:: "1"   "1"   >=      ; shouldBeTrue
:: "1.0" "1.0" >=      ; shouldBeTrue
:: "1.0" "1"   >=      ; shouldBeTrue

:: "1"   "2"   >=      ; shouldBeFalse
:: "1.0" "2.0" >=      ; shouldBeFalse
:: "1.0" "2"   >=      ; shouldBeFalse



( Tests 147-58: )

:: "1"   "1"   =       ; shouldBeTrue
:: "1.0" "1.0" =       ; shouldBeTrue
:: "1.0" "1"   =       ; shouldBeFalse

:: "2"   "1"   =       ; shouldBeFalse
:: "2.0" "1.0" =       ; shouldBeFalse
:: "2.0" "1"   =       ; shouldBeFalse

:: "1"   "1"   !=      ; shouldBeFalse
:: "1.0" "1.0" !=      ; shouldBeFalse
:: "1.0" "1"   !=      ; shouldBeTrue

:: "1"   "2"   !=      ; shouldBeTrue
:: "1.0" "2.0" !=      ; shouldBeTrue
:: "1.0" "2"   !=      ; shouldBeTrue


( Tests 159-163: )

::  100.00 ceiling    100 = ; shouldBeTrue
::  100.25 ceiling    101 = ; shouldBeTrue
::    0.00 ceiling      0 = ; shouldBeTrue
:: -100.00 ceiling   -100 = ; shouldBeTrue
:: -100.25 ceiling   -100 = ; shouldBeTrue


( Tests 164-168: )

::  100.00 floor      100 = ; shouldBeTrue
::  100.25 floor      100 = ; shouldBeTrue
::    0.00 floor        0 = ; shouldBeTrue
:: -100.00 floor     -100 = ; shouldBeTrue
:: -100.25 floor     -101 = ; shouldBeTrue

( Tests 169-173: )

::  100.00 truncate   100 = ; shouldBeTrue
::  100.25 truncate   100 = ; shouldBeTrue
::    0.00 truncate     0 = ; shouldBeTrue
:: -100.00 truncate  -100 = ; shouldBeTrue
:: -100.25 truncate  -100 = ; shouldBeTrue

( Tests 174-180: )

::  100.00 round      100 = ; shouldBeTrue
::  100.75 round      101 = ; shouldBeTrue
::  100.25 round      100 = ; shouldBeTrue
::    0.00 round        0 = ; shouldBeTrue
:: -100.00 round     -100 = ; shouldBeTrue
:: -100.25 round     -100 = ; shouldBeTrue
:: -100.75 round     -101 = ; shouldBeTrue

( Tests 181-182: )
::  [ 13 | ]->   x   x  13 = ; shouldBeTrue
::  [ 17 | ]--> *x* *x* 17 = ; shouldBeTrue

