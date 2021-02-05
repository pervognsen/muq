( --------------------------------------------------------------------- )
(			x-bignum.muf				    CrT )
( Exercise multiprecision integer stuff.				)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      98Mar21							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1999, by Jeff Prothero.				)
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
( 98Mar21 jsp	Created.						)
( --------------------------------------------------------------------- )

"Bignum tests\n" log,
"\nBignum tests:\n" ,

( A little local abbreviation: )
: bm makeBignum ;

( Tests 1-11: Basic creation and comparison: )

::  "#xf" bm  "#xf" bm = ; shouldBeTrue
:: "#x-f" bm "#x-f" bm = ; shouldBeTrue
::  "#xf" bm "#x-f" bm = ; shouldBeFalse
:: "#x-f" bm  "#xf" bm = ; shouldBeFalse
::  "#xf" bm  "#xe" bm = ; shouldBeFalse

::  "#xf" bm "#x-f" bm > ; shouldBeTrue
::  "#xf" bm  "#xf" bm > ; shouldBeFalse
:: "#x-f" bm  "#xf" bm > ; shouldBeFalse
:: "#x-f" bm "#x-f" bm > ; shouldBeFalse
:: "#x-e" bm "#x-f" bm > ; shouldBeTrue
::  "#xf" bm  "#xe" bm > ; shouldBeTrue



( Tests 12-39: Multiprecision creation and comparison: )

::   "#xffffffffffffffff" bm   "#xffffffffffffffff" bm = ; shouldBeTrue
::  "#x-ffffffffffffffff" bm  "#x-ffffffffffffffff" bm = ; shouldBeTrue
::   "#xffffffffffffffff" bm  "#x-ffffffffffffffff" bm = ; shouldBeFalse
::  "#x-ffffffffffffffff" bm   "#xffffffffffffffff" bm = ; shouldBeFalse
::   "#xffffffffffffffff" bm   "#xeeeeeeeeeeeeeeee" bm = ; shouldBeFalse

::   "#xffffffffffffffff" bm  "#x-ffffffffffffffff" bm > ; shouldBeTrue
::   "#xffffffffffffffff" bm   "#xffffffffffffffff" bm > ; shouldBeFalse
::  "#x-ffffffffffffffff" bm   "#xffffffffffffffff" bm > ; shouldBeFalse
::  "#x-ffffffffffffffff" bm  "#x-ffffffffffffffff" bm > ; shouldBeFalse
::  "#x-eeeeeeeeeeeeeeee" bm  "#x-ffffffffffffffff" bm > ; shouldBeTrue
::   "#xffffffffffffffff" bm   "#xeeeeeeeeeeeeeeee" bm > ; shouldBeTrue

::  "#xfffffffffffffffff" bm  "#xfffffffffffffffff" bm = ; shouldBeTrue
:: "#x-fffffffffffffffff" bm "#x-fffffffffffffffff" bm = ; shouldBeTrue
::  "#xfffffffffffffffff" bm "#x-fffffffffffffffff" bm = ; shouldBeFalse
:: "#x-fffffffffffffffff" bm  "#xfffffffffffffffff" bm = ; shouldBeFalse
::  "#xfffffffffffffffff" bm  "#xfeeeeeeeeeeeeeeee" bm = ; shouldBeFalse

::  "#xfffffffffffffffff" bm "#x-fffffffffffffffff" bm > ; shouldBeTrue
::  "#xfffffffffffffffff" bm  "#xfffffffffffffffff" bm > ; shouldBeFalse
:: "#x-fffffffffffffffff" bm  "#xfffffffffffffffff" bm > ; shouldBeFalse
:: "#x-fffffffffffffffff" bm "#x-fffffffffffffffff" bm > ; shouldBeFalse
:: "#x-eeeeeeeeeeeeeeeee" bm "#x-fffffffffffffffff" bm > ; shouldBeTrue
::  "#xfffffffffffffffff" bm  "#xeeeeeeeeeeeeeeeee" bm > ; shouldBeTrue

::  "#xfffffffffffffffff" bm   "#xffffffffffffffff" bm = ; shouldBeFalse
::  "#xfffffffffffffffff" bm  "#xffffffffffffffff0" bm = ; shouldBeFalse
::  "#xfffffffffffffffff" bm  "#xffffffffffffffffe" bm > ; shouldBeTrue
:: "#x-ffffffffffffffffe" bm "#x-fffffffffffffffff" bm > ; shouldBeTrue
::  "#xfffffffffffffffff" bm   "#xffffffffffffffff" bm > ; shouldBeTrue
::  "#x-ffffffffffffffff" bm "#x-fffffffffffffffff" bm > ; shouldBeTrue



( Tests 40-57: Basic addition and subtraction: )

::  "#x0" bm    "#x0" bm   +    "#x0" bm   = ;   shouldBeTrue
::  "#x0" bm    "#x1" bm   +    "#x1" bm   = ;   shouldBeTrue
::  "#x1" bm    "#x0" bm   +    "#x1" bm   = ;   shouldBeTrue
::  "#x1" bm    "#x1" bm   +    "#x2" bm   = ;   shouldBeTrue
:: "#x-1" bm    "#x0" bm   +   "#x-1" bm   = ;   shouldBeTrue
::  "#x0" bm   "#x-1" bm   +   "#x-1" bm   = ;   shouldBeTrue
:: "#x-1" bm   "#x-1" bm   +   "#x-2" bm   = ;   shouldBeTrue
:: "#x-1" bm    "#x1" bm   +    "#x0" bm   = ;   shouldBeTrue
::  "#x1" bm   "#x-1" bm   +    "#x0" bm   = ;   shouldBeTrue

::  "#x0" bm    "#x0" bm   -    "#x0" bm   = ;   shouldBeTrue
::  "#x0" bm    "#x1" bm   -   "#x-1" bm   = ;   shouldBeTrue
::  "#x1" bm    "#x0" bm   -    "#x1" bm   = ;   shouldBeTrue
::  "#x1" bm    "#x1" bm   -    "#x0" bm   = ;   shouldBeTrue
:: "#x-1" bm    "#x0" bm   -   "#x-1" bm   = ;   shouldBeTrue
::  "#x0" bm   "#x-1" bm   -    "#x1" bm   = ;   shouldBeTrue
:: "#x-1" bm   "#x-1" bm   -    "#x0" bm   = ;   shouldBeTrue
:: "#x-1" bm    "#x1" bm   -   "#x-2" bm   = ;   shouldBeTrue
::  "#x1" bm   "#x-1" bm   -    "#x2" bm   = ;   shouldBeTrue




( Tests 58-153: Multiprecision addition and subtraction: )

::   "#x1111111111111111" bm   "#x1111111111111111" bm   +    "#x2222222222222222" bm   = ; shouldBeTrue
::   "#x2222222222222222" bm   "#x2222222222222222" bm   +    "#x4444444444444444" bm   = ; shouldBeTrue
::   "#x4444444444444444" bm   "#x4444444444444444" bm   +    "#x8888888888888888" bm   = ; shouldBeTrue
::   "#x8888888888888888" bm   "#x8888888888888888" bm   +   "#x11111111111111110" bm   = ; shouldBeTrue
::  "#x-1111111111111111" bm  "#x-1111111111111111" bm   +   "#x-2222222222222222" bm   = ; shouldBeTrue
::  "#x-2222222222222222" bm  "#x-2222222222222222" bm   +   "#x-4444444444444444" bm   = ; shouldBeTrue
::  "#x-4444444444444444" bm  "#x-4444444444444444" bm   +   "#x-8888888888888888" bm   = ; shouldBeTrue
::  "#x-8888888888888888" bm  "#x-8888888888888888" bm   +  "#x-11111111111111110" bm   = ; shouldBeTrue
::  "#x-1111111111111111" bm   "#x1111111111111111" bm   +                   "#x0" bm   = ; shouldBeTrue
::   "#x1111111111111111" bm  "#x-1111111111111111" bm   +                   "#x0" bm   = ; shouldBeTrue
::  "#x-8888888888888888" bm   "#x8888888888888888" bm   +                   "#x0" bm   = ; shouldBeTrue
::   "#x8888888888888888" bm  "#x-8888888888888888" bm   +                   "#x0" bm   = ; shouldBeTrue
::   "#xffffffffffffffff" bm                  "#x1" bm   +   "#x10000000000000000" bm   = ; shouldBeTrue
::                  "#x1" bm   "#xffffffffffffffff" bm   +   "#x10000000000000000" bm   = ; shouldBeTrue
::  "#x-ffffffffffffffff" bm                 "#x-1" bm   +  "#x-10000000000000000" bm   = ; shouldBeTrue
::                 "#x-1" bm  "#x-ffffffffffffffff" bm   +  "#x-10000000000000000" bm   = ; shouldBeTrue
::  "#x-ffffffffffffffff" bm                  "#x1" bm   +   "#x-fffffffffffffffe" bm   = ; shouldBeTrue
::                  "#x1" bm  "#x-ffffffffffffffff" bm   +   "#x-fffffffffffffffe" bm   = ; shouldBeTrue
::   "#xffffffffffffffff" bm                 "#x-1" bm   +    "#xfffffffffffffffe" bm   = ; shouldBeTrue
::                 "#x-1" bm   "#xffffffffffffffff" bm   +    "#xfffffffffffffffe" bm   = ; shouldBeTrue
 
::  "#x11111111111111111" bm  "#x11111111111111111" bm   +   "#x22222222222222222" bm   = ; shouldBeTrue
::  "#x22222222222222222" bm  "#x22222222222222222" bm   +   "#x44444444444444444" bm   = ; shouldBeTrue
::  "#x44444444444444444" bm  "#x44444444444444444" bm   +   "#x88888888888888888" bm   = ; shouldBeTrue
::  "#x88888888888888888" bm  "#x88888888888888888" bm   +  "#x111111111111111110" bm   = ; shouldBeTrue
:: "#x-11111111111111111" bm "#x-11111111111111111" bm   +  "#x-22222222222222222" bm   = ; shouldBeTrue
:: "#x-22222222222222222" bm "#x-22222222222222222" bm   +  "#x-44444444444444444" bm   = ; shouldBeTrue
:: "#x-44444444444444444" bm "#x-44444444444444444" bm   +  "#x-88888888888888888" bm   = ; shouldBeTrue
:: "#x-88888888888888888" bm "#x-88888888888888888" bm   + "#x-111111111111111110" bm   = ; shouldBeTrue
:: "#x-11111111111111111" bm  "#x11111111111111111" bm   +                   "#x0" bm   = ; shouldBeTrue
::  "#x11111111111111111" bm "#x-11111111111111111" bm   +                   "#x0" bm   = ; shouldBeTrue
:: "#x-88888888888888888" bm  "#x88888888888888888" bm   +                   "#x0" bm   = ; shouldBeTrue
::  "#x88888888888888888" bm "#x-88888888888888888" bm   +                   "#x0" bm   = ; shouldBeTrue
::  "#xfffffffffffffffff" bm                  "#x1" bm   +  "#x100000000000000000" bm   = ; shouldBeTrue
::                  "#x1" bm  "#xfffffffffffffffff" bm   +  "#x100000000000000000" bm   = ; shouldBeTrue
:: "#x-fffffffffffffffff" bm                 "#x-1" bm   + "#x-100000000000000000" bm   = ; shouldBeTrue
::                 "#x-1" bm "#x-fffffffffffffffff" bm   + "#x-100000000000000000" bm   = ; shouldBeTrue
:: "#x-fffffffffffffffff" bm                  "#x1" bm   +  "#x-ffffffffffffffffe" bm   = ; shouldBeTrue
::                  "#x1" bm "#x-fffffffffffffffff" bm   +  "#x-ffffffffffffffffe" bm   = ; shouldBeTrue
::  "#xfffffffffffffffff" bm                 "#x-1" bm   +   "#xffffffffffffffffe" bm   = ; shouldBeTrue
::                 "#x-1" bm  "#xfffffffffffffffff" bm   +   "#xffffffffffffffffe" bm   = ; shouldBeTrue

:: "#x100000000000000000" bm                 "#x-1" bm   +   "#xfffffffffffffffff" bm   = ; shouldBeTrue
::                 "#x-1" bm "#x100000000000000000" bm   +   "#xfffffffffffffffff" bm   = ; shouldBeTrue
:: "#x-100000000000000000" bm                 "#x1" bm   +  "#x-fffffffffffffffff" bm   = ; shouldBeTrue
::                 "#x1" bm "#x-100000000000000000" bm   +  "#x-fffffffffffffffff" bm   = ; shouldBeTrue


::   "#x1111111111111111" bm  "#x-1111111111111111" bm   -    "#x2222222222222222" bm   = ; shouldBeTrue
::   "#x2222222222222222" bm  "#x-2222222222222222" bm   -    "#x4444444444444444" bm   = ; shouldBeTrue
::   "#x4444444444444444" bm  "#x-4444444444444444" bm   -    "#x8888888888888888" bm   = ; shouldBeTrue
::   "#x8888888888888888" bm  "#x-8888888888888888" bm   -   "#x11111111111111110" bm   = ; shouldBeTrue
::  "#x-1111111111111111" bm   "#x1111111111111111" bm   -   "#x-2222222222222222" bm   = ; shouldBeTrue
::  "#x-2222222222222222" bm   "#x2222222222222222" bm   -   "#x-4444444444444444" bm   = ; shouldBeTrue
::  "#x-4444444444444444" bm   "#x4444444444444444" bm   -   "#x-8888888888888888" bm   = ; shouldBeTrue
::  "#x-8888888888888888" bm   "#x8888888888888888" bm   -  "#x-11111111111111110" bm   = ; shouldBeTrue
::  "#x-1111111111111111" bm  "#x-1111111111111111" bm   -                   "#x0" bm   = ; shouldBeTrue
::   "#x1111111111111111" bm   "#x1111111111111111" bm   -                   "#x0" bm   = ; shouldBeTrue
::  "#x-8888888888888888" bm  "#x-8888888888888888" bm   -                   "#x0" bm   = ; shouldBeTrue
::   "#x8888888888888888" bm   "#x8888888888888888" bm   -                   "#x0" bm   = ; shouldBeTrue
::   "#xffffffffffffffff" bm                 "#x-1" bm   -   "#x10000000000000000" bm   = ; shouldBeTrue
::                  "#x1" bm  "#x-ffffffffffffffff" bm   -   "#x10000000000000000" bm   = ; shouldBeTrue
::  "#x-ffffffffffffffff" bm                  "#x1" bm   -  "#x-10000000000000000" bm   = ; shouldBeTrue
::                 "#x-1" bm   "#xffffffffffffffff" bm   -  "#x-10000000000000000" bm   = ; shouldBeTrue
::  "#x-ffffffffffffffff" bm                 "#x-1" bm   -   "#x-fffffffffffffffe" bm   = ; shouldBeTrue
::                  "#x1" bm   "#xffffffffffffffff" bm   -   "#x-fffffffffffffffe" bm   = ; shouldBeTrue
::   "#xffffffffffffffff" bm                  "#x1" bm   -    "#xfffffffffffffffe" bm   = ; shouldBeTrue
::                 "#x-1" bm  "#x-ffffffffffffffff" bm   -    "#xfffffffffffffffe" bm   = ; shouldBeTrue
 
::  "#x11111111111111111" bm "#x-11111111111111111" bm   -   "#x22222222222222222" bm   = ; shouldBeTrue
::  "#x22222222222222222" bm "#x-22222222222222222" bm   -   "#x44444444444444444" bm   = ; shouldBeTrue
::  "#x44444444444444444" bm "#x-44444444444444444" bm   -   "#x88888888888888888" bm   = ; shouldBeTrue
::  "#x88888888888888888" bm "#x-88888888888888888" bm   -  "#x111111111111111110" bm   = ; shouldBeTrue
:: "#x-11111111111111111" bm  "#x11111111111111111" bm   -  "#x-22222222222222222" bm   = ; shouldBeTrue
:: "#x-22222222222222222" bm  "#x22222222222222222" bm   -  "#x-44444444444444444" bm   = ; shouldBeTrue
:: "#x-44444444444444444" bm  "#x44444444444444444" bm   -  "#x-88888888888888888" bm   = ; shouldBeTrue
:: "#x-88888888888888888" bm  "#x88888888888888888" bm   - "#x-111111111111111110" bm   = ; shouldBeTrue
:: "#x-11111111111111111" bm "#x-11111111111111111" bm   -                   "#x0" bm   = ; shouldBeTrue
::  "#x11111111111111111" bm  "#x11111111111111111" bm   -                   "#x0" bm   = ; shouldBeTrue
:: "#x-88888888888888888" bm "#x-88888888888888888" bm   -                   "#x0" bm   = ; shouldBeTrue
::  "#x88888888888888888" bm  "#x88888888888888888" bm   -                   "#x0" bm   = ; shouldBeTrue
::  "#xfffffffffffffffff" bm                 "#x-1" bm   -  "#x100000000000000000" bm   = ; shouldBeTrue
::                  "#x1" bm "#x-fffffffffffffffff" bm   -  "#x100000000000000000" bm   = ; shouldBeTrue
:: "#x-fffffffffffffffff" bm                  "#x1" bm   - "#x-100000000000000000" bm   = ; shouldBeTrue
::                 "#x-1" bm  "#xfffffffffffffffff" bm   - "#x-100000000000000000" bm   = ; shouldBeTrue
:: "#x-fffffffffffffffff" bm                 "#x-1" bm   -  "#x-ffffffffffffffffe" bm   = ; shouldBeTrue
::                  "#x1" bm  "#xfffffffffffffffff" bm   -  "#x-ffffffffffffffffe" bm   = ; shouldBeTrue
::  "#xfffffffffffffffff" bm                  "#x1" bm   -   "#xffffffffffffffffe" bm   = ; shouldBeTrue
::                 "#x-1" bm "#x-fffffffffffffffff" bm   -   "#xffffffffffffffffe" bm   = ; shouldBeTrue

:: "#x100000000000000000" bm                  "#x1" bm   -   "#xfffffffffffffffff" bm   = ; shouldBeTrue
::                 "#x-1" bm "#x-100000000000000000" bm  -   "#xfffffffffffffffff" bm   = ; shouldBeTrue
:: "#x-100000000000000000" bm                "#x-1" bm   -  "#x-fffffffffffffffff" bm   = ; shouldBeTrue
::                 "#x1" bm  "#x100000000000000000" bm   -  "#x-fffffffffffffffff" bm   = ; shouldBeTrue

::                                   "#x1" bm
    "#xffffffffffffffffffffffffffffffffff" bm
    +
   "#x10000000000000000000000000000000000" bm
   =
; shouldBeTrue

::  "#xffffffffffffffffffffffffffffffffff" bm
                                     "#x1" bm
    +
   "#x10000000000000000000000000000000000" bm
   =
; shouldBeTrue

:: "#x10000000000000000000000000000000000" bm
   "#x-ffffffffffffffffffffffffffffffffff" bm
    +
                                     "#x1" bm
   =
; shouldBeTrue

::  "#xffffffffffffffffffffffffffffffffff" bm
  "#x-10000000000000000000000000000000000" bm
    +
                                    "#x-1" bm
   =
; shouldBeTrue

::                                   "#x1" bm
   "#x-ffffffffffffffffffffffffffffffffff" bm
    -
   "#x10000000000000000000000000000000000" bm
   =
; shouldBeTrue

::  "#xffffffffffffffffffffffffffffffffff" bm
                                    "#x-1" bm
    -
   "#x10000000000000000000000000000000000" bm
   =
; shouldBeTrue

:: "#x10000000000000000000000000000000000" bm
    "#xffffffffffffffffffffffffffffffffff" bm
    -
                                     "#x1" bm
   =
; shouldBeTrue

::  "#xffffffffffffffffffffffffffffffffff" bm
   "#x10000000000000000000000000000000000" bm
    -
                                    "#x-1" bm
   =
; shouldBeTrue



( Tests 154-159: Basic / and %: )

:: "#x5" bm "#x3" bm / "#x1" bm = ; shouldBeTrue
:: "#x5" bm "#x3" bm % "#x2" bm = ; shouldBeTrue
:: "#xf" bm "#x2" bm / "#x7" bm = ; shouldBeTrue
:: "#xf" bm "#x2" bm % "#x1" bm = ; shouldBeTrue
:: "#x1000000000000000000003" bm "#x4" bm / "#x400000000000000000000" bm = ; shouldBeTrue
:: "#x1000000000000000000003" bm "#x4" bm % "#x3" bm = ; shouldBeTrue



( Tests 160-2: Basic expt: )
:: "#x1" bm 3 expt "#x1" bm = ; shouldBeTrue
:: "#x2" bm 3 expt "#x8" bm = ; shouldBeTrue
:: "#x3" bm 2 expt "#x9" bm = ; shouldBeTrue


( Tests 163-6: Basic gcd: )
::   "10" bm   "9" bm gcd   "1" bm = ; shouldBeTrue
::  "117" bm "199" bm gcd   "1" bm = ; shouldBeTrue
::  "240" bm "120" bm gcd "120" bm = ; shouldBeTrue
:: "1764" bm "868" bm gcd  "28" bm = ; shouldBeTrue

( Tests 167-9: Extended gcd: )
:: "693" bm "609" bm egcd -> v -> u -> g   g   "21" bm = ; shouldBeTrue
:: "693" bm "609" bm egcd -> v -> u -> g   u "-181" bm = ; shouldBeTrue
:: "693" bm "609" bm egcd -> v -> u -> g   v  "206" bm = ; shouldBeTrue

( Tests 170-214: Montgomery exponentiation: )
:: "2" bm "3" bm "2001" bm exptmod "8" bm = ; shouldBeTrue
:: "3" bm "1000" bm "3" bm exptmod "0" bm = ; shouldBeTrue
:   fermatsLittleThm { $ $ -> $ }
    -> p
    -> a

    ( ----------------------------------------------------------- )
    (                                      P                      )
    ( For any prime P, and any integer A, A  mod P should == A    )
    ( ----------------------------------------------------------- )

    a p p exptmod
    a =
;
:: "77" bm "113" bm fermatsLittleThm                        ; shouldBeTrue



( -------------------------------------------- )
( Primes used in following are from            )
( Table 1 p354 in Art of Computer Programming  )
( Vol 2 -- Seminumerical Algorithms Sect 4.5.4 )
( -------------------------------------------- )

:: "7777" bm "2" bm 31 expt   "1" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 60 expt  "93" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 60 expt "107" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 60 expt "173" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 60 expt "179" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 60 expt "257" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 60 expt "279" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 60 expt "369" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 60 expt "395" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 60 expt "399" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 60 expt "453" bm - fermatsLittleThm ; shouldBeTrue

:: "7777" bm "2" bm 63 expt  "25" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 63 expt "165" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 63 expt "259" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 63 expt "301" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 63 expt "375" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 63 expt "387" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 63 expt "391" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 63 expt "409" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 63 expt "457" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 63 expt "471" bm - fermatsLittleThm ; shouldBeTrue

:: "7777" bm "2" bm 64 expt  "59" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 64 expt  "83" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 64 expt  "95" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 64 expt "179" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 64 expt "189" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 64 expt "257" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 64 expt "279" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 64 expt "323" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 64 expt "353" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm 64 expt "363" bm - fermatsLittleThm ; shouldBeTrue



( -------------------------------------------- )
( Unfortunately, above table ends there.       )	
( Mersenne Primes used in following are from   )
( p356 in Art of Computer Programming          )
( Vol 2 -- Seminumerical Algorithms Sect 4.5.4 )
( -------------------------------------------- )

:: "7777" bm "2" bm   17 expt "1" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm   19 expt "1" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm   31 expt "1" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm   61 expt "1" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm   89 expt "1" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm  107 expt "1" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm  127 expt "1" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm  521 expt "1" bm - fermatsLittleThm ; shouldBeTrue
:: "7777" bm "2" bm  607 expt "1" bm - fermatsLittleThm ; shouldBeTrue "\n\nNext takes a few secs...\n" ,
:: "7777" bm "2" bm 1279 expt "1" bm - fermatsLittleThm ; shouldBeTrue "\n\nNext takes a minute...\n" ,
:: "7777" bm "2" bm 2203 expt "1" bm - fermatsLittleThm ; shouldBeTrue
( The remaining ones here have been tested, but don't seem worth taking      )
( time to run during routine regression suite tests.  Also, running most     )
( of them requires increasing the size of a contant or two in bnm.t:         )
( :: "7777" bm "2" bm 2281 expt "1" bm - fermatsLittleThm ; shouldBeTrue )
( :: "7777" bm "2" bm 3217 expt "1" bm - fermatsLittleThm ; shouldBeTrue )
( :: "7777" bm "2" bm 4253 expt "1" bm - fermatsLittleThm ; shouldBeTrue )
( :: "7777" bm "2" bm 4423 expt "1" bm - fermatsLittleThm ; shouldBeTrue )
( :: "7777" bm "2" bm 9689 expt "1" bm - fermatsLittleThm ; shouldBeTrue )
( :: "7777" bm "2" bm 9941 expt "1" bm - fermatsLittleThm ; shouldBeTrue )
( The last couple above currently each take over 30 min on a 150MHz i686...  )



( Tests 215-246: Comparison of bignums and fixnums:  )

::   2       2  =  ; shouldBeTrue
::   2       3 <= ; shouldBeTrue
::   2       2 <= ; shouldBeTrue
::  -1      -1  = ; shouldBeTrue
::  -1      -1 <= ; shouldBeTrue
::  -2      -1 <= ; shouldBeTrue
::  -2      -1 <  ; shouldBeTrue
::  -2       1 <  ; shouldBeTrue

::  "2" bm  "2" bm  = ; shouldBeTrue
::  "2" bm  "3" bm <= ; shouldBeTrue
::  "2" bm  "2" bm <= ; shouldBeTrue
:: "-1" bm "-1" bm  = ; shouldBeTrue
:: "-1" bm "-1" bm <= ; shouldBeTrue
:: "-2" bm "-1" bm <= ; shouldBeTrue
:: "-2" bm "-1" bm <  ; shouldBeTrue
:: "-2" bm  "1" bm <  ; shouldBeTrue

::   2      "2" bm  = ; shouldBeTrue
::   2      "3" bm <= ; shouldBeTrue
::   2      "2" bm <= ; shouldBeTrue
::  -1     "-1" bm  = ; shouldBeTrue
::  -1     "-1" bm <= ; shouldBeTrue
::  -2     "-1" bm <= ; shouldBeTrue
::  -2     "-1" bm <  ; shouldBeTrue
::  -2      "1" bm <  ; shouldBeTrue

::  "2" bm   2      = ; shouldBeTrue
::  "2" bm   3     <= ; shouldBeTrue
::  "2" bm   2     <= ; shouldBeTrue
:: "-1" bm  -1      = ; shouldBeTrue
:: "-1" bm  -1     <= ; shouldBeTrue
:: "-2" bm  -1     <= ; shouldBeTrue
:: "-2" bm  -1     <  ; shouldBeTrue
:: "-2" bm   1     <  ; shouldBeTrue

( Tests 247-273: Addition over mixtures of bignums and fixnums: )
( These tests assume 62-bit fixnums -- 1152921504606846976      )
( is the largest positive power of two that fits in a fixnum.   )

( Test the basic predicates: )
:: 1152921504606846976 integer? ; shouldBeTrue
:: 1152921504606846976 fixnum?  ; shouldBeTrue
:: 1152921504606846976 bignum?  ; shouldBeFalse

( Test adding two fixnums to get a bignum: )
:: 1152921504606846976 1152921504606846976 + --> _a ; shouldWork
:: _a integer?     ; shouldBeTrue
:: _a fixnum?      ; shouldBeFalse
:: _a bignum?      ; shouldBeTrue

( Test adding a bignum to a fixnum to get a bignum: )
:: _a  1 + pop     ; shouldWork
:: _a  1 + bignum? ; shouldBeTrue

( Test adding a bignum to a fixnum to get a fixnum: )
:: _a -1 + pop      ; shouldWork
:: _a -1 + fixnum?  ; shouldBeTrue
:: _a _a + --> _a ; shouldWork
:: _a bignum?       ; shouldBeTrue

( Test adding a bignum to a bignum to get a fixnum: )
:: -1152921504606846976 integer? ; shouldBeTrue
:: -1152921504606846976 fixnum?  ; shouldBeTrue
:: -1152921504606846976 bignum?  ; shouldBeFalse
:: -1152921504606846976 -1152921504606846976 + --> _b ; shouldWork
:: _b integer?      ; shouldBeTrue
:: _b fixnum?       ; shouldBeTrue
:: _b bignum?       ; shouldBeFalse
:: _b _b + --> _b ; shouldWork
:: _b integer?      ; shouldBeTrue
:: _b fixnum?       ; shouldBeFalse
:: _b bignum?       ; shouldBeTrue
:: _a _b + --> _c ; shouldWork
:: _c integer?      ; shouldBeTrue
:: _c fixnum?       ; shouldBeTrue
( "_c = " , _c , "\n" , )

( Test subtracting two fixnums to get a bignum: )
::  1152921504606846976                        --> _a ; shouldWork
:: -1152921504606846976 -1152921504606846976 + --> _b ; shouldWork
:: _a _b - --> _c ; shouldWork
:: _c integer? ; shouldBeTrue
:: _c fixnum?  ; shouldBeFalse
:: _c bignum?  ; shouldBeTrue

( Test subtracting fixnum from bignum to get a fixnum: )
:: _c _a - _a - --> _d ; shouldWork
:: _d integer? ; shouldBeTrue
:: _d fixnum?  ; shouldBeTrue
:: _d bignum?  ; shouldBeFalse

( Test subtracting bignum from bignum to get a fixnum: )
:: _a _a + --> _aa ; shouldWork
:: _aa integer? ; shouldBeTrue
:: _aa fixnum?  ; shouldBeFalse
:: _aa bignum?  ; shouldBeTrue
:: _c _aa - --> _d ; shouldWork
:: _d integer? ; shouldBeTrue
( Restore as soon as maybeConvertToFixnum in bnm_Sub is restored: )
( :: _d fixnum?  ; shouldBeTrue )
( :: _d bignum?  ; shouldBeFalse )



( Test mixed-mode / ops: )
:: "12" bm 3     / 4 =     ; shouldBeTrue
:: "12" bm 3     / fixnum? ; shouldBeTrue
::  12    "3" bm / 4 =     ; shouldBeTrue
::  12    "3" bm / fixnum? ; shouldBeTrue



( Test mixed-mode % ops: )
:: "14" bm 3     % 2 =     ; shouldBeTrue
:: "14" bm 3     % fixnum? ; shouldBeTrue
::  14    "3" bm % 2 =     ; shouldBeTrue
::  14    "3" bm % fixnum? ; shouldBeTrue



( Test mixed-mode expt ops: )
:: "5" bm 5 expt 3125 =     ; shouldBeTrue
:: "5" bm 5 expt fixnum?    ; shouldBeTrue
::  5     5 expt 3125 =     ; shouldBeTrue
::  5     5 expt fixnum?    ; shouldBeTrue
::  5   100 expt bignum?    ; shouldBeTrue



( Test mixed-mode arithmetic shifts: )
:: "1" bm 100 ash bignum?   ; shouldBeTrue
:: "1" bm   1 ash 2 =       ; shouldBeTrue
:: "1" bm   1 ash fixnum?   ; shouldBeTrue
:: "2" bm  -1 ash 1 =       ; shouldBeTrue
:: "2" bm  -1 ash fixnum?   ; shouldBeTrue
:: "1" bm  -1 ash 0 =       ; shouldBeTrue
:: "1" bm  -1 ash fixnum?   ; shouldBeTrue
::  1       0 ash 1 =       ; shouldBeTrue
::  1       0 ash fixnum?   ; shouldBeTrue
::  1       1 ash 2 =       ; shouldBeTrue
::  1       1 ash fixnum?   ; shouldBeTrue
::  1     100 ash bignum?   ; shouldBeTrue
:: "1" bm 100 ash 1 100 ash =  ; shouldBeTrue



( Test mixed-mode logands: )

::  15      7     logand 7 =      ; shouldBeTrue
::  15      7     logand fixnum?  ; shouldBeTrue

:: "15" bm  7     logand 7 =      ; shouldBeTrue
:: "15" bm  7     logand fixnum?  ; shouldBeTrue

::  15     "7" bm logand 7 =      ; shouldBeTrue
::  15     "7" bm logand fixnum?  ; shouldBeTrue

:: "15" bm "7" bm logand 7 =      ; shouldBeTrue
:: "15" bm "7" bm logand fixnum?  ; shouldBeTrue

:: 1 100 ash 1 - --> _a          ; shouldWork
:: _a -10 ash   --> _b          ; shouldWork

:: _a bignum?                    ; shouldBeTrue
:: _b bignum?                    ; shouldBeTrue

:: _a _b logand --> _c         ; shouldWork
:: _c bignum?                    ; shouldBeTrue
:: _c _b =                      ; shouldBeTrue

:: _a 15 logand 15 =             ; shouldBeTrue
:: _a 15 logand fixnum?          ; shouldBeTrue

:: 15 _a logand 15 =             ; shouldBeTrue
:: 15 _a logand fixnum?          ; shouldBeTrue



( Test mixed-mode logiors: )

::  8      7     logior 15 =      ; shouldBeTrue
::  8      7     logior fixnum?   ; shouldBeTrue

:: "8" bm  7     logior 15 =      ; shouldBeTrue
:: "8" bm  7     logior fixnum?   ; shouldBeTrue

::  8     "7" bm logior 15 =      ; shouldBeTrue
::  8     "7" bm logior fixnum?   ; shouldBeTrue

:: "8" bm "7" bm logior 15 =      ; shouldBeTrue
:: "8" bm "7" bm logior fixnum?   ; shouldBeTrue

:: 1 100 ash --> _a              ; shouldWork
:: _a 1 +   --> _b              ; shouldWork

:: _a bignum?                    ; shouldBeTrue
:: _b bignum?                    ; shouldBeTrue

:: _a 1   logior _b =           ; shouldBeTrue
:: _a _a logior _a =           ; shouldBeTrue



( Test mixed-mode logxors: )

::  12      7     logxor 11 =      ; shouldBeTrue
::  12      7     logxor fixnum?   ; shouldBeTrue

:: "12" bm  7     logxor 11 =      ; shouldBeTrue
:: "12" bm  7     logxor fixnum?   ; shouldBeTrue

::  12     "7" bm logxor 11 =      ; shouldBeTrue
::  12     "7" bm logxor fixnum?   ; shouldBeTrue

:: "12" bm "7" bm logxor 11 =      ; shouldBeTrue
:: "12" bm "7" bm logxor fixnum?   ; shouldBeTrue

:: 1 100 ash 1 - --> _a           ; shouldWork
:: _a _a logxor 0 =              ; shouldBeTrue
:: _a _a logxor fixnum?          ; shouldBeTrue

:: 1 100 ash --> _a               ; shouldWork
:: _a 1 +   --> _b               ; shouldWork
:: _a 1 logxor _b =              ; shouldBeTrue
:: _a 1 logxor bignum?            ; shouldBeTrue



( Test neg op: )

:: 1 neg -1 = ; shouldBeTrue
:: 1 neg neg 1 = ; shouldBeTrue
:: 1.0 neg -1.0 = ; shouldBeTrue
:: 1.0 neg neg 1.0 = ; shouldBeTrue
:: 1 100 ash --> _a ; shouldWork
:: _a neg --> _b ; shouldWork
:: _b bignum? ; shouldBeTrue
:: _a _b = ; shouldBeFalse
:: _a _b neg = ; shouldBeTrue



( Test mixed-mode multiplies: )

::  2      2     * 4 = ; shouldBeTrue
:: "2" bm  2     * 4 = ; shouldBeTrue
::  2     "2" bm * 4 = ; shouldBeTrue
:: "2" bm "2" bm * 4 = ; shouldBeTrue

::  2      2     * fixnum? ; shouldBeTrue
:: "2" bm  2     * fixnum? ; shouldBeTrue
::  2     "2" bm * fixnum? ; shouldBeTrue
:: "2" bm "2" bm * fixnum? ; shouldBeTrue

:: 1 40 ash --> _a ; shouldWork
:: _a _a * --> _b ; shouldWork
:: _b bignum? ; shouldBeTrue
:: _b _a * bignum? ; shouldBeTrue
:: _a _b * bignum? ; shouldBeTrue
:: _a _b * _b _a * = ; shouldBeTrue
:: _b _b * bignum? ; shouldBeTrue

::  -1      -1     * 1 = ; shouldBeTrue
:: "-1" bm  -1     * 1 = ; shouldBeTrue
::  -1     "-1" bm * 1 = ; shouldBeTrue
:: "-1" bm "-1" bm * 1 = ; shouldBeTrue

::  -1      -1     * fixnum? ; shouldBeTrue
:: "-1" bm  -1     * fixnum? ; shouldBeTrue
::  -1     "-1" bm * fixnum? ; shouldBeTrue
:: "-1" bm "-1" bm * fixnum? ; shouldBeTrue



( Test mixed-mode gcds: )

::  15      35     gcd 5 = ; shouldBeTrue
:: "15" bm  35     gcd 5 = ; shouldBeTrue
::  15     "35" bm gcd 5 = ; shouldBeTrue
:: "15" bm "35" bm gcd 5 = ; shouldBeTrue

::  15      35     gcd fixnum? ; shouldBeTrue
:: "15" bm  35     gcd fixnum? ; shouldBeTrue
::  15     "35" bm gcd fixnum? ; shouldBeTrue
:: "15" bm "35" bm gcd fixnum? ; shouldBeTrue



( Tests mixed-mode egcd: )

:: "693" bm "609" bm egcd -> v -> u -> g   g    21 = ; shouldBeTrue
:: "693" bm "609" bm egcd -> v -> u -> g   u  -181 = ; shouldBeTrue
:: "693" bm "609" bm egcd -> v -> u -> g   v   206 = ; shouldBeTrue

:: "693" bm "609" bm egcd -> v -> u -> g   g fixnum? ; shouldBeTrue
:: "693" bm "609" bm egcd -> v -> u -> g   u fixnum? ; shouldBeTrue
:: "693" bm "609" bm egcd -> v -> u -> g   v fixnum? ; shouldBeTrue

:: "693" bm  609     egcd -> v -> u -> g   g    21 = ; shouldBeTrue
:: "693" bm  609     egcd -> v -> u -> g   u  -181 = ; shouldBeTrue
:: "693" bm  609     egcd -> v -> u -> g   v   206 = ; shouldBeTrue

:: "693" bm  609     egcd -> v -> u -> g   g fixnum? ; shouldBeTrue
:: "693" bm  609     egcd -> v -> u -> g   u fixnum? ; shouldBeTrue
:: "693" bm  609     egcd -> v -> u -> g   v fixnum? ; shouldBeTrue

::  693     "609" bm egcd -> v -> u -> g   g    21 = ; shouldBeTrue
( vvv )
::  693     "609" bm egcd -> v -> u -> g   u  -181 = ; shouldBeTrue
::  693     "609" bm egcd -> v -> u -> g   v   206 = ; shouldBeTrue
( ^^^ )

::  693     "609" bm egcd -> v -> u -> g   g fixnum? ; shouldBeTrue
::  693     "609" bm egcd -> v -> u -> g   u fixnum? ; shouldBeTrue
::  693     "609" bm egcd -> v -> u -> g   v fixnum? ; shouldBeTrue

::  693      609     egcd -> v -> u -> g   g    21 = ; shouldBeTrue
::  693      609     egcd -> v -> u -> g   u  -181 = ; shouldBeTrue
::  693      609     egcd -> v -> u -> g   v   206 = ; shouldBeTrue

::  693      609     egcd -> v -> u -> g   g fixnum? ; shouldBeTrue
::  693      609     egcd -> v -> u -> g   u fixnum? ; shouldBeTrue
::  693      609     egcd -> v -> u -> g   v fixnum? ; shouldBeTrue



( Test lognot: )
:: 12 lognot -13 =   ; shouldBeTrue
:: 12 lognot fixnum? ; shouldBeTrue
:: 1 100 ash -> a  a lognot lognot a = ; shouldBeTrue



( Test diffieHellman support: )

:: dh:g dh:p generateDiffieHellmanKeyPair --> publicKey1 --> privateKey1 ; shouldWork
:: dh:g dh:p generateDiffieHellmanKeyPair --> publicKey2 --> privateKey2 ; shouldWork

:: publicKey1 privateKey2 dh:p generateDiffieHellmanSharedSecret --> sharedSecret1 ; shouldWork
:: publicKey2 privateKey1 dh:p generateDiffieHellmanSharedSecret --> sharedSecret2 ; shouldWork

( Check that a valid signature is recognized: )
::  [ 'a' 'b' 'c' | sharedSecret1 |signedDigest
    sharedSecret2 |signedDigestCheck
    |pop --> wantNil
    |pop --> wantC
    |pop --> wantB
    |pop --> wantA
    ]pop
; shouldWork
:: wantNil nil = ; shouldBeTrue
:: wantA   'a' = ; shouldBeTrue
:: wantB   'b' = ; shouldBeTrue
:: wantC   'c' = ; shouldBeTrue

( Check that an invalid signature is rejected: )
:: dh:g dh:p generateDiffieHellmanKeyPair --> publicKey3 --> privateKey3 ; shouldWork
:: publicKey1 privateKey3 dh:p generateDiffieHellmanSharedSecret --> sharedSecret3 ; shouldWork
::  [ 'a' 'b' 'c' | sharedSecret1 |signedDigest
    sharedSecret3 |signedDigestCheck
    |pop --> wantNil
( Following may be missing in secure version, since )
( number of bytes of padding can't be reliably      )
( determined without correct decryption key:        )
(   |pop --> wantC )
(   |pop --> wantB )
(   |pop --> wantA )
    ]pop
; shouldWork
:: wantNil nil = ; shouldBeFalse
( :: wantA   'a' = ; shouldBeTrue )
( :: wantB   'b' = ; shouldBeTrue )
( :: wantC   'c' = ; shouldBeTrue )



( Test bothersome case of negation of biggest negative fixnum   )
( -- bothersome because two's complement allows no matching     )
( positive fixnum:                                              )
:: 2 61 expt 1 - neg 1 - -> x   x     fixnum? ;            shouldBeTrue
:: 2 61 expt 1 - neg 1 - -> x   x neg fixnum? ;            shouldBeFalse
:: 2 61 expt 1 - neg 1 - -> x   x neg -> y   x y = ;       shouldBeFalse
:: 2 61 expt 1 - neg 1 - -> x   x neg -> y   x y neg = ;   shouldBeTrue



( Test basic bignum embyte/debyte:  )
:: 2 100 expt --> x ;                         shouldWork
:: [ x | |enbyte ]pop  ;                      shouldWork
:: [ x | |enbyte |debyte -> y ]pop y ;        shouldBeFalse
:: [ x | |enbyte |debyte pop ]-> y   x y = ;  shouldBeTrue
:: x neg --> x ;                              shouldWork
:: [ x | |enbyte |debyte pop ]-> y   x y = ;  shouldBeTrue

( This was crashing us for awhile due to a )
( sloppy bnm_Divmod  divide-by-zero check: )
::
    "51257014809112898170965097186402712342459907339" makeBignum -> k
  "1308618728062336023527658292623074027163064308975" makeBignum -> k1
  k k1 * dh:q %
  1 =
; shouldBeTrue

( A little test of intToManglish / manglishToInt: )
::  571678763552183 -> x
    x dict:intToManglish -> y
    y dict:manglishToInt -> z
    x z =
; shouldBeTrue

( The following isn't run as a part of standard test suite, 	)
( but can be useful as a confidence-building measure when	)
( frigging around with the divide/mod logic:			)
( )
( for i from 0 below 100 do{	)
( 	)
(     do{	)
(         frandom  170000000000000000.0 * floor -> dividend	)
(         frandom           500000000.0 * floor -> divisor	)
( 	divisor 0 = while	)
(     }	)
( 	)
(     dividend divisor / -> quotient	)
(     dividend divisor % -> remainder	)
( 	)
(     [ "#x%x" dividend  | ]print -> strtop	)
(     [ "#x%x" divisor   | ]print -> strbot	)
(     [ "#x%x" quotient  | ]print -> strquo	)
(     [ "#x%x" remainder | ]print -> strrem	)
( 	)
(     strtop bm -> bigtop	)
(     strbot bm -> bigbot	)
(     strquo bm -> bigquo	)
(     strrem bm -> bigrem	)
( 	)
(     bigtop bigbot / -> quo	)
(     bigtop bigbot % -> rem	)
( 	)
(     strtop , "/" , strbot , " -> " , strquo , ", " , strrem ,	)
( 	)
(     quo bigquo = not if "   quo WRONG: " , quo , fi	)
(     rem bigrem = not if "   rem WRONG: " , rem , fi	)
( 	)
(     "\n" ,	)
( }	)


( The following isn't run as a part of standard test suite, 	)
( but can be useful as a confidence-building measure when	)
( frigging around with the multiply logic -- tests it against	)
( div/mod:							)	
( )
( "0" bm --> zero )
( for i from 0 below 1000 do{ )
(  )
(     do{ )
(         frandom  17000000000000.0 * floor -> a0 )
(         frandom  17000000000000.0 * floor -> a1 )
(         frandom  17000000000000.0 * floor -> b0 )
(         frandom  17000000000000.0 * floor -> b1 )
( 	a0 0 =  )
( 	a1 0 = or )
( 	b0 0 = or )
( 	b1 0 = or while )
(     } )
(  )
(     [ "%x" a0  | ]print -> stra0 )
(     [ "%x" a1  | ]print -> stra1 )
(     [ "%x" b0  | ]print -> strb0 )
(     [ "%x" b1  | ]print -> strb1 )
(  )
(     stra0 bm -> biga0 )
(     stra1 bm -> biga1 )
(     strb0 bm -> bigb0 )
(     strb1 bm -> bigb1 )
(  )
(     biga0 biga1 * -> biga )
(     bigb0 bigb1 * -> bigb )
(  )
(     biga bigb *   -> bigc )
(     bigc bigb / -> quo )
(     bigc bigb % -> rem )
(  )
(     biga , " * " , bigb , " -> " , bigc , ", " ,  )
(  )
(     quo biga = not if "   quo WRONG: " , quo , fi )
(     rem zero = not if "   rem WRONG: " , rem , fi )
(  )
(     "\n" , )
( } )


( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
