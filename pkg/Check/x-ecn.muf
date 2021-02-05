( --------------------------------------------------------------------- )
(			x-ecn.muf				    CrT )
( Exercise ephemeral lists.						)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      95Oct09							)
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
( 95Oct09 jsp	Created.						)
( --------------------------------------------------------------------- )

"Ephemeral list tests\n" log,
"\nEphemeral list tests:" ,

( Tests 1-5: )

:: 'a 'd econs car 'a = ; shouldBeTrue
:: 'a 'd econs cdr 'd = ; shouldBeTrue
:: 'a 'd econs cons? ; shouldBeTrue
:: 'a 'd econs list? ; shouldBeTrue
:: 'a 'd econs ephemeral? ; shouldBeTrue

( Tests 6-9: )
:: 'a 'd econs -> x  'A' 'D' econs -> y   x car 'a  = ; shouldBeTrue
:: 'a 'd econs -> x  'A' 'D' econs -> y   x cdr 'd  = ; shouldBeTrue
:: 'a 'd econs -> x  'A' 'D' econs -> y   y car 'A' = ; shouldBeTrue
:: 'a 'd econs -> x  'A' 'D' econs -> y   y cdr 'D' = ; shouldBeTrue

( Tests 10-13: )
:: 'a 'd econs -> x  x.car 'a = ; shouldBeTrue
:: 'a 'd econs -> x  x.cdr 'd = ; shouldBeTrue
:: 'a 'd econs -> x  'A' --> x.car  x.car 'A' = ; shouldBeTrue
:: 'a 'd econs -> x  'D' --> x.cdr  x.cdr 'D' = ; shouldBeTrue

( Tests 14-21: )
:: [ ]e nil = ; shouldBeTrue
:: [ 'a ]e ephemeral? ; shouldBeTrue
:: [ 'a ]e cons? ; shouldBeTrue
:: [ 'a ]e list? ; shouldBeTrue
:: [ 'a ]e car 'a = ; shouldBeTrue
:: [ 'a ]e cdr ; shouldBeFalse
:: [ 'a 'b ]e car 'a = ; shouldBeTrue
:: [ 'a 'b ]e cdar 'b = ; shouldBeTrue

( Tests 22-23: )
:: 'a 'd econs -> c   c 'A' rplaca   c car 'A' = ; shouldBeTrue
:: 'a 'd econs -> c   c 'D' rplacd   c cdr 'D' = ; shouldBeTrue

( Test 24: )
:: [ 'a 'b ]e length 2 = ; shouldBeTrue
:: 'a 'd econs nil = ; shouldBeFalse ( We were crashing on this. )
