( --------------------------------------------------------------------- )
(			x-debug.muf				    CrT )
( Exercise debugger-related stuff.					)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      99Jun22							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 2000, by Jeff Prothero.				)
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
( 99Jun22 jsp	Created.						)
( --------------------------------------------------------------------- )

"Database support function tests\n" log,
"\nDatabase support function tests:" ,


( Test 1: Create a new dbfile: )
:: [ "lice" | rootMakeDb ]--> @.lice ; shouldWork

( Test 2: Create a package within the new dbfile: )
:: [ "lice" .db[@.lice] | ]makePackage pop ; shouldWork

( Tests 3-4: Select the new package as current package: )
:: @.package --> @.orig_package ; shouldWork
:: "lice" inPackage ; shouldWork

( Test 5: Create an index within new package: )
:: makeIndex --> x ; shouldWork

( Test 6: Enter some stuff into index: )
:: for i from 0 upto 1000 do{ "a" i toString join -> a  i --> x[a] } ; shouldWork

( Test 7: Test a value: )
:: x["a99"] 99 = ; shouldBeTrue

( Test 8: Test that X is indeed in new dbfile: )
:: x$s.dbname @.lice = ; shouldBeTrue

( Test 9: Return to original package: )
:: @.orig_package$s.name inPackage ; shouldWork


( Importing and exporting files: )
:: [ "xyz" | rootMakeDb ]pop ; shouldWork
:: [ "plugh" .db["xyz"] | ]inPackage ; shouldWork
:: 12 --> twelve ; shouldWork
:: -1 1300 makeVector --> myVec ; shouldWork
:: "root" inPackage ; shouldWork
:: plugh::myVec[0] -1 = ; shouldBeTrue
:: plugh::myVec[1299] -1 = ; shouldBeTrue
:: [ .db["xyz"] | rootExportDb ]pop ; shouldWork
:: for i from 0 below 1300 do{ 15 --> plugh::myVec[i] } ; shouldWork
:: plugh::myVec[0] 15 = ; shouldBeTrue
:: plugh::myVec[1299] 15 = ; shouldBeTrue
:: [ .db["xyz"] | rootRemoveDb ]pop ; shouldWork
:: [ "xyz"      | rootImportDb ]pop ; shouldWork
:: plugh::twelve 12 = ; shouldBeTrue
:: plugh::myVec length2 1300 = ; shouldBeTrue
:: plugh::myVec[0] -1 = ; shouldBeTrue
:: plugh::myVec[1299] -1 = ; shouldBeTrue
:: for i from 0 below 1300 do{ 14 --> plugh::myVec[i] } ; shouldWork
:: plugh::myVec[0] 14 = ; shouldBeTrue
:: plugh::myVec[1299] 14 = ; shouldBeTrue
:: [ .db["xyz"] | rootReplaceDb ]pop ; shouldWork
:: plugh::myVec[0] -1 = ; shouldBeTrue
:: plugh::myVec[1299] -1 = ; shouldBeTrue

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
