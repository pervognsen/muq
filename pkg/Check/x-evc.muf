( --------------------------------------------------------------------- )
(			x-evc.muf				    CrT )
( Exercise ephemeral-data types.					)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      95Sep30							)
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
( 95Sep30 jsp	Created.						)
( --------------------------------------------------------------------- )

"Ephemeral vector tests\n" log,
"\nEphemeral vector tests:" ,

( Tests 1-28: Ephemeral vectors: )
:: [ 1 3 7 | ]makeEphemeralVector pop ; shouldWork
:: [ 1 3 7 | ]makeEphemeralVector ephemeral? ; shouldBeTrue
:: [ 1 3 7 | ]makeEphemeralVector vector? ; shouldBeTrue
:: [ 1 3 7 | ]makeEphemeralVector length2 3 = ; shouldBeTrue
:: [ 1 3 7 | ]makeEphemeralVector -> v v[-1] 7 = ; shouldBeTrue
:: [ 1 3 7 | ]makeEphemeralVector -> v v[3] ; shouldFail
:: [ 1 3 7 | ]makeEphemeralVector -> v v[0] 1 = ; shouldBeTrue
:: [ 1 3 7 | ]makeEphemeralVector -> v v[1] 3 = ; shouldBeTrue
:: [ 1 3 7 | ]makeEphemeralVector -> v v[2] 7 = ; shouldBeTrue
:: [ 1 3 7 | ]makeEphemeralVector -> v 9 --> v[-1] ; shouldWork
:: [ 1 3 7 | ]makeEphemeralVector -> v 9 --> v[3] ; shouldFail
:: [ 1 3 7 | ]makeEphemeralVector -> v 9 --> v[0] ; shouldWork
:: [ 1 3 7 | ]makeEphemeralVector -> v 9 --> v[0] v[0] 9 = ; shouldBeTrue
:: [ 1 3 7 | ]makeEphemeralVector -> v 9 --> v[-1] v[2] 9 = ; shouldBeTrue

:: 1 3 makeEphemeralVector pop ; shouldWork
:: 1 3 makeEphemeralVector ephemeral? ; shouldBeTrue
:: 1 3 makeEphemeralVector vector? ; shouldBeTrue
:: 1 3 makeEphemeralVector length2 3 = ; shouldBeTrue
:: 1 3 makeEphemeralVector -> v v[-1] 1 = ; shouldBeTrue
:: 1 3 makeEphemeralVector -> v v[3] ; shouldFail
:: 1 3 makeEphemeralVector -> v v[0] 1 = ; shouldBeTrue
:: 1 3 makeEphemeralVector -> v v[1] 1 = ; shouldBeTrue
:: 1 3 makeEphemeralVector -> v v[2] 1 = ; shouldBeTrue
:: 1 3 makeEphemeralVector -> v 9 --> v[-1] ; shouldWork
:: 1 3 makeEphemeralVector -> v 9 --> v[3] ; shouldFail
:: 1 3 makeEphemeralVector -> v 9 --> v[0] ; shouldWork
:: 1 3 makeEphemeralVector -> v 9 --> v[0] v[0] 9 = ; shouldBeTrue
:: 1 3 makeEphemeralVector -> v 9 --> v[-1] v[2] 9 = ; shouldBeTrue

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
