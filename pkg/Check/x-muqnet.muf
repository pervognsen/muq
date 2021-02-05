( --------------------------------------------------------------------- )
(			x-muqnet.muf				    CrT )
( Exercise muqnet support.						)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      97Jan03							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1998, by Jeff Prothero.				)
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
( 98Jan03 jsp	Created.						)
( --------------------------------------------------------------------- )

"Muqnet support tests\n" log,
"\nMuqnet support tests:" ,

( Tests 1-3: Empty block: )
:: [ | |enbyte ]pop ; shouldWork
:: [ | |enbyte |debyte -> failed ]pop failed ; shouldBeFalse
:: [ | |enbyte |debyte pop |length -> len ]pop len 0 = ; shouldBeTrue


( Tests 4-13: Single immediate values: )
:: [     1 | |enbyte ]pop ; shouldWork
:: [     1 | |enbyte |debyte -> failed ]pop failed ; shouldBeFalse
:: [     1 | |enbyte |debyte pop ]shift     1 = ; shouldBeTrue
:: [    -1 | |enbyte |debyte pop ]shift    -1 = ; shouldBeTrue
:: [   1.0 | |enbyte |debyte pop ]shift   1.0 = ; shouldBeTrue
:: [   'c' | |enbyte |debyte pop ]shift   'c' = ; shouldBeTrue
:: [    "" | |enbyte |debyte pop ]shift    "" = ; shouldBeTrue
:: [   "c" | |enbyte |debyte pop ]shift   "c" = ; shouldBeTrue
:: [  "bc" | |enbyte |debyte pop ]shift  "bc" = ; shouldBeTrue
:: [ "abc" | |enbyte |debyte pop ]shift "abc" = ; shouldBeTrue

( Tests 14-78: Multiple immediate values: )
:: [     1   1 | |enbyte |debyte pop ]shift     1 = ; shouldBeTrue

:: [     1   1 | |enbyte |debyte pop ]shift     1 = ; shouldBeTrue
:: [    -1   1 | |enbyte |debyte pop ]shift    -1 = ; shouldBeTrue
:: [   1.0   1 | |enbyte |debyte pop ]shift   1.0 = ; shouldBeTrue
:: [   'c'   1 | |enbyte |debyte pop ]shift   'c' = ; shouldBeTrue
:: [    ""   1 | |enbyte |debyte pop ]shift    "" = ; shouldBeTrue
:: [   "c"   1 | |enbyte |debyte pop ]shift   "c" = ; shouldBeTrue
:: [  "bc"   1 | |enbyte |debyte pop ]shift  "bc" = ; shouldBeTrue
:: [ "abc"   1 | |enbyte |debyte pop ]shift "abc" = ; shouldBeTrue

:: [     1 1.0 | |enbyte |debyte pop ]shift     1 = ; shouldBeTrue
:: [    -1 1.0 | |enbyte |debyte pop ]shift    -1 = ; shouldBeTrue
:: [   1.0 1.0 | |enbyte |debyte pop ]shift   1.0 = ; shouldBeTrue
:: [   'c' 1.0 | |enbyte |debyte pop ]shift   'c' = ; shouldBeTrue
:: [    "" 1.0 | |enbyte |debyte pop ]shift    "" = ; shouldBeTrue
:: [   "c" 1.0 | |enbyte |debyte pop ]shift   "c" = ; shouldBeTrue
:: [  "bc" 1.0 | |enbyte |debyte pop ]shift  "bc" = ; shouldBeTrue
:: [ "abc" 1.0 | |enbyte |debyte pop ]shift "abc" = ; shouldBeTrue

:: [     1 'c' | |enbyte |debyte pop ]shift     1 = ; shouldBeTrue
:: [    -1 'c' | |enbyte |debyte pop ]shift    -1 = ; shouldBeTrue
:: [   1.0 'c' | |enbyte |debyte pop ]shift   1.0 = ; shouldBeTrue
:: [   'c' 'c' | |enbyte |debyte pop ]shift   'c' = ; shouldBeTrue
:: [    "" 'c' | |enbyte |debyte pop ]shift    "" = ; shouldBeTrue
:: [   "c" 'c' | |enbyte |debyte pop ]shift   "c" = ; shouldBeTrue
:: [  "bc" 'c' | |enbyte |debyte pop ]shift  "bc" = ; shouldBeTrue
:: [ "abc" 'c' | |enbyte |debyte pop ]shift "abc" = ; shouldBeTrue

:: [     1 "c" | |enbyte |debyte pop ]shift     1 = ; shouldBeTrue
:: [    -1 "c" | |enbyte |debyte pop ]shift    -1 = ; shouldBeTrue
:: [   1.0 "c" | |enbyte |debyte pop ]shift   1.0 = ; shouldBeTrue
:: [   'c' "c" | |enbyte |debyte pop ]shift   'c' = ; shouldBeTrue
:: [    "" "c" | |enbyte |debyte pop ]shift    "" = ; shouldBeTrue
:: [   "c" "c" | |enbyte |debyte pop ]shift   "c" = ; shouldBeTrue
:: [  "bc" "c" | |enbyte |debyte pop ]shift  "bc" = ; shouldBeTrue
:: [ "abc" "c" | |enbyte |debyte pop ]shift "abc" = ; shouldBeTrue

:: [   1     1 | |enbyte |debyte pop |shift pop ]shift     1 = ; shouldBeTrue
:: [   1    -1 | |enbyte |debyte pop |shift pop ]shift    -1 = ; shouldBeTrue
:: [   1   1.0 | |enbyte |debyte pop |shift pop ]shift   1.0 = ; shouldBeTrue
:: [   1   'c' | |enbyte |debyte pop |shift pop ]shift   'c' = ; shouldBeTrue
:: [   1    "" | |enbyte |debyte pop |shift pop ]shift    "" = ; shouldBeTrue
:: [   1   "c" | |enbyte |debyte pop |shift pop ]shift   "c" = ; shouldBeTrue
:: [   1  "bc" | |enbyte |debyte pop |shift pop ]shift  "bc" = ; shouldBeTrue
:: [   1 "abc" | |enbyte |debyte pop |shift pop ]shift "abc" = ; shouldBeTrue

:: [ 1.0     1 | |enbyte |debyte pop |shift pop ]shift     1 = ; shouldBeTrue
:: [ 1.0    -1 | |enbyte |debyte pop |shift pop ]shift    -1 = ; shouldBeTrue
:: [ 1.0   1.0 | |enbyte |debyte pop |shift pop ]shift   1.0 = ; shouldBeTrue
:: [ 1.0   'c' | |enbyte |debyte pop |shift pop ]shift   'c' = ; shouldBeTrue
:: [ 1.0    "" | |enbyte |debyte pop |shift pop ]shift    "" = ; shouldBeTrue
:: [ 1.0   "c" | |enbyte |debyte pop |shift pop ]shift   "c" = ; shouldBeTrue
:: [ 1.0  "bc" | |enbyte |debyte pop |shift pop ]shift  "bc" = ; shouldBeTrue
:: [ 1.0 "abc" | |enbyte |debyte pop |shift pop ]shift "abc" = ; shouldBeTrue

:: [ 'c'     1 | |enbyte |debyte pop |shift pop ]shift     1 = ; shouldBeTrue
:: [ 'c'    -1 | |enbyte |debyte pop |shift pop ]shift    -1 = ; shouldBeTrue
:: [ 'c'   1.0 | |enbyte |debyte pop |shift pop ]shift   1.0 = ; shouldBeTrue
:: [ 'c'   'c' | |enbyte |debyte pop |shift pop ]shift   'c' = ; shouldBeTrue
:: [ 'c'    "" | |enbyte |debyte pop |shift pop ]shift    "" = ; shouldBeTrue
:: [ 'c'   "c" | |enbyte |debyte pop |shift pop ]shift   "c" = ; shouldBeTrue
:: [ 'c'  "bc" | |enbyte |debyte pop |shift pop ]shift  "bc" = ; shouldBeTrue
:: [ 'c' "abc" | |enbyte |debyte pop |shift pop ]shift "abc" = ; shouldBeTrue

:: [ "c"     1 | |enbyte |debyte pop |shift pop ]shift     1 = ; shouldBeTrue
:: [ "c"    -1 | |enbyte |debyte pop |shift pop ]shift    -1 = ; shouldBeTrue
:: [ "c"   1.0 | |enbyte |debyte pop |shift pop ]shift   1.0 = ; shouldBeTrue
:: [ "c"   'c' | |enbyte |debyte pop |shift pop ]shift   'c' = ; shouldBeTrue
:: [ "c"    "" | |enbyte |debyte pop |shift pop ]shift    "" = ; shouldBeTrue
:: [ "c"   "c" | |enbyte |debyte pop |shift pop ]shift   "c" = ; shouldBeTrue
:: [ "c"  "bc" | |enbyte |debyte pop |shift pop ]shift  "bc" = ; shouldBeTrue
:: [ "c" "abc" | |enbyte |debyte pop |shift pop ]shift "abc" = ; shouldBeTrue

( Tests 79-80: Multiple char values -- max chars in one )
( group is 127, so check that larger numbers work ok:   )
( LATER: Max is now actually 15, but whatever...        )
:: [ 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  10 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  20 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  30 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  40 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  50 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  60 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  70 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  80 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  90 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	( 100 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	( 110 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	( 120 )
| |enbyte |debyte pop |length 120 = ; shouldBeTrue

:: [ 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  10 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  20 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  30 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  40 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  50 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  60 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  70 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  80 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	(  90 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	( 100 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	( 110 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	( 120 )
     'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a' 'a'	( 130 )
| |enbyte |debyte pop |length 130 = ; shouldBeTrue

( Tests 81-88: Proxy pointers: )
:: [ nil    | |enbyte ]pop ; shouldWork
:: [ nil    | |enbyte |debyte -> failed ]pop failed ; shouldBeFalse
:: [ nil    | |enbyte |debyte pop ]shift nil    = ; shouldBeTrue
:: [ t      | |enbyte |debyte pop ]shift t      = ; shouldBeTrue
:: [ "abcd" | |enbyte |debyte pop ]shift "abcd" = ; shouldBeTrue
:: makeIndex --> o                                ; shouldWork
:: [ o      | |enbyte |debyte pop ]shift o      = ; shouldBeTrue
:: [ @      | |enbyte |debyte pop ]shift @      = ; shouldBeTrue

( Tests 89-94: Immediate strings: )
:: [ "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" | |enbyte ; shouldWork
:: [ "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" | |enbyte |debyte -> failed ]pop failed ; shouldBeFalse
:: [ "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" | |enbyte |debyte pop ]shift "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" = ; shouldBeTrue
:: [ "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" | |enbyte ; shouldWork
:: [ "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" | |enbyte |debyte -> failed ]pop failed ; shouldBeFalse
:: [ "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" | |enbyte |debyte pop ]shift "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" = ; shouldBeTrue


( Tests 95-130: Proxy objects should compare by value not dbref: )
nil --> #'a
nil --> #'b
nil --> #'c
nil --> #'d
nil --> #'e
nil --> #'f
nil --> #'g
nil --> #'h
nil --> #'i

[ | rootMakeGuest ]--> aGuest

[ :guest aGuest :i0 39 :i1 31 :i2 32 | ]makeProxy --> a
[ :guest aGuest :i0 30 :i1 39 :i2 32 | ]makeProxy --> b
[ :guest aGuest :i0 30 :i1 31 :i2 39 | ]makeProxy --> c

:: a a = ; shouldBeTrue
:: a b = ; shouldBeFalse
:: a c = ; shouldBeFalse
:: b c = ; shouldBeFalse

:: a a =-ci ; shouldBeTrue
:: b b =-ci ; shouldBeTrue
:: c c =-ci ; shouldBeTrue

:: a a =-ci ; shouldBeTrue
:: a b =-ci ; shouldBeFalse
:: a c =-ci ; shouldBeFalse
:: b c =-ci ; shouldBeFalse

( Tests 131-133: T and NIL by value instead of reference: )
:: [ t nil | |enbyte |length -> len ]pop len 2 = ; shouldBeTrue
:: [ t nil | |enbyte |debyte pop ]shift t = ; shouldBeTrue
:: [ t nil | |enbyte |debyte pop |shift pop ]shift nil = ; shouldBeTrue

( Tests 134-142: proxyInfo: )
:: a proxyInfo  pop pop pop pop pop pop ; shouldWork
:: a proxyInfo  pop pop pop pop pop -> i i aGuest = ; shouldBeTrue
:: a proxyInfo  pop pop pop pop -> i pop i 39     = ; shouldBeTrue
:: a proxyInfo  pop pop pop -> i pop pop i 31     = ; shouldBeTrue
:: a proxyInfo  pop pop -> i pop pop pop i 32     = ; shouldBeTrue

( Tests 134-142: Immediate keywords: )
:: [ :a | |enbyte ; shouldWork
:: [ :a | |enbyte |debyte -> failed ]pop failed ; shouldBeFalse
:: [ :a | |enbyte |debyte pop ]shift :a = ; shouldBeTrue
:: [ :a23456789012345 | |enbyte ; shouldWork
:: [ :a23456789012345 | |enbyte |debyte -> failed ]pop failed ; shouldBeFalse
:: [ :a23456789012345 | |enbyte |debyte pop ]shift :a23456789012345 = ; shouldBeTrue
:: [ :a234567890123456 | |enbyte ; shouldWork
:: [ :a234567890123456 | |enbyte |debyte -> failed ]pop failed ; shouldBeFalse
:: [ :a234567890123456 | |enbyte |debyte pop ]shift :a234567890123456 = ; shouldBeTrue

( Tests 143-151: )
:: "abc" dbrefToInts3 ints3ToDbref pop ; shouldBeTrue
:: "abc" dbrefToInts3 ints3ToDbref swap pop "abc" = ; shouldBeTrue
:: 'a' dbrefToInts3 ints3ToDbref pop ; shouldBeTrue
:: 'a' dbrefToInts3 ints3ToDbref swap pop 'a' = ; shouldBeTrue
:: 0 dbrefToInts3 ints3ToDbref pop ; shouldBeTrue
:: 0 dbrefToInts3 ints3ToDbref swap pop 0 = ; shouldBeTrue
:: makeIndex -> o o dbrefToInts3 ints3ToDbref pop ; shouldBeTrue
:: makeIndex -> o o dbrefToInts3 ints3ToDbref swap pop o = ; shouldBeTrue
:: makeIndex dbrefToInts3 rootCollectGarbage pop ints3ToDbref pop ; shouldBeFalse


:: nil dbrefToInts3 --> i2 --> i1 --> i0 [ :guest aGuest :i0 i0 :i1 i1 :i2 i2 | ]makeProxy remote? ; shouldBeTrue



( Test basic functionality of |debyteMuqnetHeader: )

:: [ 13 31 14 0 'a' | |enbyte |debyteMuqnetHeader -> op -> long -> to -> from -> version -> err              ; shouldWork
:: [ 13 31 14 0 'a' | |enbyte |debyteMuqnetHeader -> op -> long -> to -> from -> version -> err err          ; shouldBeFalse
:: [ 13 31 14 0 'a' | |enbyte |debyteMuqnetHeader -> op -> long -> to -> from -> version -> err to      14 = ; shouldBeTrue
:: [ 13 31 14 0 'a' | |enbyte |debyteMuqnetHeader -> op -> long -> to -> from -> version -> err from    13 = ; shouldBeTrue
:: [ 13 31 14 0 'a' | |enbyte |debyteMuqnetHeader -> op -> long -> to -> from -> version -> err version 31 = ; shouldBeTrue
:: [ 13 31 14 0 'a' | |enbyte |debyteMuqnetHeader -> op -> long -> to -> from -> version -> err long         ; shouldBeFalse
:: [ 13 31 14 0 'a' | |enbyte |debyteMuqnetHeader -> op -> long -> to -> from -> version -> err op 97 =      ; shouldBeTrue

:: [ 2 100 expt 13 31 14 0 'a' | |enbyte |debyteMuqnetHeader -> op -> long -> to -> from -> version -> err              ; shouldWork
:: [ 2 100 expt 13 31 14 0 'a' | |enbyte |debyteMuqnetHeader -> op -> long -> to -> from -> version -> err err          ; shouldBeFalse
:: [ 2 100 expt 13 31 14 0 'a' | |enbyte |debyteMuqnetHeader -> op -> long -> to -> from -> version -> err to      14 = ; shouldBeTrue
:: [ 2 100 expt 13 31 14 0 'a' | |enbyte |debyteMuqnetHeader -> op -> long -> to -> from -> version -> err from    13 = ; shouldBeTrue
:: [ 2 100 expt 13 31 14 0 'a' | |enbyte |debyteMuqnetHeader -> op -> long -> to -> from -> version -> err version 31 = ; shouldBeTrue
:: [ 2 100 expt 13 31 14 0 'a' | |enbyte |debyteMuqnetHeader -> op -> long -> to -> from -> version -> err long         ; shouldBeTrue
:: [ 2 100 expt 13 31 14 0 'a' | |enbyte |debyteMuqnetHeader -> op -> long -> to -> from -> version -> err op   97 =    ; shouldBeTrue



( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
