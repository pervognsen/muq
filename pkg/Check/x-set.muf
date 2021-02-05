( --------------------------------------------------------------------- )
(			x-set.muf				    CrT )
( Exercise stack operators.						)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      99Aug04							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 2000 by Jeff Prothero.					)
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
( 99Aug04 jsp	Created.						)
( --------------------------------------------------------------------- )

"Basic sett tests\n" log,
"\nBasic set stuff:" ,



( Tests 1-9: )

( Regression test: for awhile we couldn't index by fixnums > 2**31. )
( We'll check some other basic types while we're at it:             )
:: 1          -> i   makeSet -> o   t --> o[i]   o[i] ;   shouldBeTrue
:: 1          -> i   makeSet -> o   t --> o[i]   o[0] ;   shouldBeFalse
:: 1.5        -> i   makeSet -> o   t --> o[i]   o[i] ;   shouldBeTrue
:: 2 90 expt  -> i   makeSet -> o   t --> o[i]   o[i] ;   shouldBeTrue
:: 2 40 expt  -> i   makeSet -> o   t --> o[i]   o[i] ;   shouldBeTrue
:: "a"        -> i   makeSet -> o   t --> o[i]   o[i] ;   shouldBeTrue
:: 'a'        -> i   makeSet -> o   t --> o[i]   o[i] ;   shouldBeTrue
:: :a         -> i   makeSet -> o   t --> o[i]   o[i] ;   shouldBeTrue
:: "abcdefgh" -> i   makeSet -> o   t --> o[i]   o[i] ;   shouldBeTrue
:: makeSet    -> i   makeSet -> o   t --> o[i]   o[i] ;   shouldBeTrue
