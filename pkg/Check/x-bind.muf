( --------------------------------------------------------------------- )
(			x-bind.muf				    CrT )
( Exercise variable and function binding stuff.				)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      95Apr30							)
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
( 95Apr30 jsp	Created.						)
( --------------------------------------------------------------------- )

"Binding tests\n" log,
"\nBinding tests:\n" ,

( Tests 1-3: Check basic syntax works: )
::  13 --> _y ; shouldWork
::  14 => _y ; shouldWork
::  1 if 14 => _y else 15 => _y fi ; shouldWork

( Tests 4-7: Check semantics: )
::  14 => _y  _y 14 = ; shouldBeTrue
::  _y 13 = ; shouldBeTrue
: g _y --> _z ;
12 --> _z
:: 14 => _y  g  _z 14 = ; shouldBeTrue
::  _y 13 = ; shouldBeTrue

( Tests 8-12:  Similar checks on fn binding: )
: l 1 ;
:: l 1 = ; shouldBeTrue
::   :: 2 ; =>fn l   l 2 =   ; shouldBeTrue
:: l 1 = ; shouldBeTrue
1 --> _y
::   :: 2 ; =>fn l   : g l --> _y ;   g   _y 2 =   ; shouldBeTrue
1 --> _y
: g   l --> _y ;
::   :: 2 ; =>fn l    g   _y 2 =   ; shouldBeTrue

( Test 13: Locals shadow globals: )
:: 12 -> job  job 12 = ; shouldBeTrue
13 --> xx
:: 14 -> xx   xx  14 = ; shouldBeTrue
:: xx 13 = ; shouldBeTrue


( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
