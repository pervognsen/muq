( --------------------------------------------------------------------- )
(			x-propdir.muf				    CrT )
( Exercise propdir stuff.						)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      99Oct13							)
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
( 99Oct13 jsp	Created.						)
( --------------------------------------------------------------------- )

"Propdir tests\n" log,
"\nPropdir tests:" ,

( For awhile propdirs were badly broken, perhaps particularly ones	)
( with mixtures of btree and fixed keyval pairs.  This regression	)
( file is intended to prevent a repeat of that problem:			)


1000 -->constant TIMES



( ------ INDEX OBJECTS ------- )

( int keys: )
makeIndex --> _i
for i from 0 below TIMES do{ i -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ i -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
:: count TIMES = ; shouldBeTrue

( float keys: )
makeIndex --> _i
for i from 0 below TIMES do{ i 0.5 + -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ i 0.5 + -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
:: count TIMES = ; shouldBeTrue

( string keys: )
makeIndex --> _i
for i from 0 below TIMES do{ [ "a%03d" i | ]print -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ [ "a%03d" i | ]print -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
:: count TIMES = ; shouldBeTrue

( keyword keys: )
makeIndex --> _i
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
:: count TIMES = ; shouldBeTrue

( All of the above keys: )
makeIndex --> _i
for i from 0 below TIMES do{ i                            -> key  i --> _i[key] }
for i from 0 below TIMES do{ i 0.5 +                      -> key  i --> _i[key] }
for i from 0 below TIMES do{ [ "a%03d"  i | ]print        -> key  i --> _i[key] }
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ i                            -> key  _i[key] i != if ++ _whoopsies fi }
for i from 0 below TIMES do{ i 0.5 +                      -> key  _i[key] i != if ++ _whoopsies fi }
for i from 0 below TIMES do{ [ "a%03d"  i | ]print        -> key  _i[key] i != if ++ _whoopsies fi }
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
:: count TIMES 4 * = ; shouldBeTrue





( ------ HASH OBJECTS ------- )

( int keys: )
makeHash --> _i
for i from 0 below TIMES do{ i -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ i -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
:: count TIMES = ; shouldBeTrue

( float keys: )
makeHash --> _i
for i from 0 below TIMES do{ i 0.5 + -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ i 0.5 + -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
:: count TIMES = ; shouldBeTrue

( string keys: )
makeHash --> _i
for i from 0 below TIMES do{ [ "a%03d" i | ]print -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ [ "a%03d" i | ]print -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
:: count TIMES = ; shouldBeTrue

( keyword keys: )
makeHash --> _i
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
:: count TIMES = ; shouldBeTrue

( All of the above keys: )
makeHash --> _i
for i from 0 below TIMES do{ i                            -> key  i --> _i[key] }
for i from 0 below TIMES do{ i 0.5 +                      -> key  i --> _i[key] }
for i from 0 below TIMES do{ [ "a%03d"  i | ]print        -> key  i --> _i[key] }
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ i                            -> key  _i[key] i != if ++ _whoopsies fi }
for i from 0 below TIMES do{ i 0.5 +                      -> key  _i[key] i != if ++ _whoopsies fi }
for i from 0 below TIMES do{ [ "a%03d"  i | ]print        -> key  _i[key] i != if ++ _whoopsies fi }
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
:: count TIMES 4 * = ; shouldBeTrue





( ------ PLAIN OBJECTS ------- )

( int keys: )
makePlain --> _i
for i from 0 below TIMES do{ i -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ i -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
:: count TIMES = ; shouldBeTrue

( float keys: )
makePlain --> _i
for i from 0 below TIMES do{ i 0.5 + -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ i 0.5 + -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
:: count TIMES = ; shouldBeTrue

( string keys: )
makePlain --> _i
for i from 0 below TIMES do{ [ "a%03d" i | ]print -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ [ "a%03d" i | ]print -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
:: count TIMES = ; shouldBeTrue

( keyword keys: )
makePlain --> _i
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
:: count TIMES = ; shouldBeTrue

( All of the above keys: )
makePlain --> _i
for i from 0 below TIMES do{ i                            -> key  i --> _i[key] }
for i from 0 below TIMES do{ i 0.5 +                      -> key  i --> _i[key] }
for i from 0 below TIMES do{ [ "a%03d"  i | ]print        -> key  i --> _i[key] }
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ i                            -> key  _i[key] i != if ++ _whoopsies fi }
for i from 0 below TIMES do{ i 0.5 +                      -> key  _i[key] i != if ++ _whoopsies fi }
for i from 0 below TIMES do{ [ "a%03d"  i | ]print        -> key  _i[key] i != if ++ _whoopsies fi }
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
:: count TIMES 4 * = ; shouldBeTrue



( ------ JOB OBJECTS ------- )


( Count number of pre-existing properties: )
@ --> _i
0 --> hardwiredProps
_i foreach key val do{ ++ hardwiredProps }

( int keys: )
for i from 0 below TIMES do{ i -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ i -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
::   count   TIMES hardwiredProps +  = ; shouldBeTrue
for i from 0 below TIMES do{ i -> key  delete: _i[key]  }
0 --> count
_i foreach key val do{ ++ count }
::   count hardwiredProps = ; shouldBeTrue

( float keys: )
@ --> _i
for i from 0 below TIMES do{ i 0.5 + -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ i 0.5 + -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
::   count   TIMES hardwiredProps +  = ; shouldBeTrue
for i from 0 below TIMES do{ i 0.5 + -> key  delete: _i[key] }
0 --> count
_i foreach key val do{ ++ count }
::   count hardwiredProps = ; shouldBeTrue


( string keys: )
@ --> _i
for i from 0 below TIMES do{ [ "a%03d" i | ]print -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ [ "a%03d" i | ]print -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
::   count   TIMES hardwiredProps +  = ; shouldBeTrue
for i from 0 below TIMES do{ [ "a%03d" i | ]print -> key  delete: _i[key] }
0 --> count
_i foreach key val do{ ++ count }
::   count hardwiredProps = ; shouldBeTrue



( keyword keys: )
@ --> _i
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
::   count   TIMES hardwiredProps +  = ; shouldBeTrue
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  delete: _i[key] }
0 --> count
_i foreach key val do{ ++ count }
::   count hardwiredProps = ; shouldBeTrue


( All of the above keys: )
@ --> _i
for i from 0 below TIMES do{ i                            -> key  i --> _i[key] }
for i from 0 below TIMES do{ i 0.5 +                      -> key  i --> _i[key] }
for i from 0 below TIMES do{ [ "a%03d"  i | ]print        -> key  i --> _i[key] }
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ i                            -> key  _i[key] i != if ++ _whoopsies fi }
for i from 0 below TIMES do{ i 0.5 +                      -> key  _i[key] i != if ++ _whoopsies fi }
for i from 0 below TIMES do{ [ "a%03d"  i | ]print        -> key  _i[key] i != if ++ _whoopsies fi }
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue
0 --> count
_i foreach key val do{ ++ count }
:: count TIMES 4 * hardwiredProps + = ; shouldBeTrue
for i from 0 below TIMES do{ i                            -> key  delete: _i[key] }
for i from 0 below TIMES do{ i 0.5 +                      -> key  delete: _i[key] }
for i from 0 below TIMES do{ [ "a%03d"  i | ]print        -> key  delete: _i[key] }
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  delete: _i[key] }
0 --> count
_i foreach key val do{ ++ count }
::   count hardwiredProps = ; shouldBeTrue





( ---------------- SIZE OF .lib["muf"] ------------------- )

( For awhile we had a weird bug where the regression suite )
( was running flawlessly, but trying to list .lib["muf"]   )
( would show zero symbols.  Yikes!  Turned out to be due   )
( to the compiler using the implicit slots but 'ls'  the   )
( explicit slots.  Doubt that will ever happen again, but  )
( why not add a test to be sure?  MUF currently has about  )
( 2500 symbols defined, so if we ever count less than      )
( 1000, there is probably something seriously wrong:       )

0 --> count
:: .lib["muf"] foreach key val do{ ++ count } ; shouldWork
:: count 1000 > ; shouldBeTrue



( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
