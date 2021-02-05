( --------------------------------------------------------------------- )
(			x-stack.muf				    CrT )
( Exercise stack operators.						)
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

"Stack operator tests\n" log,
"\nStack operator tests:" ,



( Tests 1-5: )

:: 2 3 pop         2 = ; shouldBeTrue
:: 3   dup  *      9 = ; shouldBeTrue
:: 2 6 swap /      3 = ; shouldBeTrue
:: 1 2 dup2nd + + 4 = ; shouldBeTrue
:: 2 1 dupNth     2 = ; shouldBeTrue




( Tests 6-9: )

:: 1 2 2 dupNth swap pop           1 = ; shouldBeTrue
:: 1 2 3 rot     swap pop swap  pop 1 = ; shouldBeTrue
:: 1 2 3 rot          pop       pop 2 = ; shouldBeTrue
:: 1 2 3 rot       pop swap  pop 3 = ; shouldBeTrue



( Tests 10-11: )

:: 3 [ 2 | ]pop  3 = ; shouldBeTrue
:: 3 2 1 depth    3 = ; shouldBeTrue
:: 3 2 1 depth    3 = ; shouldBeTrue
