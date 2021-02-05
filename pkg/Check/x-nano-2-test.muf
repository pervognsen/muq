( --------------------------------------------------------------------- )
(			x-nanomud.muf				    CrT )
( Exercise nanomud package.						)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      96Oct19							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1997, by Jeff Prothero.				)
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
( 96Oct19 jsp	Created.						)
( --------------------------------------------------------------------- )

"Nanomud tests\n" log,
"\nNanomud tests:" ,
( t --> .muq.logBytecodes )

( Test 1: Start nanomud on port 32000: )
:: nanomud:start ; shouldWork

( Tests 2-11: Open a client connection to nanomud: )
:: makeSocket --> _client1 ; shouldWork
:: makeMessageStream --> _in1 ; shouldWork
:: makeMessageStream --> _out1 ; shouldWork
:: makeMessageStream --> _oob1 ; shouldWork
:: makeMessageStream --> _client1OobInput ; shouldWork
:: _in1      --> _client1.standardInput ; shouldWork
:: _out1     --> _client1.standardOutput ; shouldWork
:: _client1OobInput  --> _client1.outOfBandInput  ; shouldWork
:: _oob1 --> _client1.outOfBandOutput ; shouldWork
:: [ :socket _client1
     :port 32000
     :protocol :stream
   | ]openSocket
; shouldWork

( Test 12: Set client for TELNET support: )
:: t --> _client1.telnetProtocol ; shouldWork

( Some TELNET protocol constants: )
255 intChar -->constant IAC
253 intChar -->constant DO
251 intChar -->constant WILL
250 intChar -->constant SB
246 intChar -->constant AYT
240 intChar -->constant SE
  1 intChar -->constant ECHO

( A convenience function to read expected text: )
:   expect { $ $ $ $ -> }
    --> __line
    --> __who
    --> __oob
    --> __stream
    do{
	:: [ __stream __oob | t 50000
	   |readAnyStreamPacket
	   --> _stream
	   --> _who
	   --> _tag
	   ]join --> _line
	; shouldWork

	_stream __oob = if loopNext fi

	:: _stream __stream = ; shouldBeTrue
	:: _who    __who    = ; shouldBeTrue
	:: _tag    "txt"      = ; shouldBeTrue
	:: _line   __line   = ; shouldBeTrue
	return
    }
;

( Tests 13-17: Read login prompt from nanomud: )
_out1 _oob1 _client1 "login:\n" expect

( Test 18: Write login back to nanomud: )
:: "nano1\n" _in1 writeStream ; shouldWork

( Tests 19-23: Read passphrase prompt from nanomud: )
_out1 _oob1 _client1 "passphrase:\n" expect

( Test 32: Send passphrase to nanomud: )
:: "nano1\n" _in1 writeStream ; shouldWork

( Tests 33-52: Read welcome messages back from nanomud: )
_out1 _oob1 _client1 "Welcome to the Muq nanomud!\n"     expect
_out1 _oob1 _client1 "Do '.help' for help.\n"            expect
_out1 _oob1 _client1
"You see lots of cradles and a harried-looking nurse.\n" expect
_out1 _oob1 _client1 "Obvious exits: garden\n"           expect


( Test 53-63: Send view command to nanomud: )
:: ".v\n" _in1 writeStream ; shouldWork

_out1 _oob1 _client1
"You see lots of cradles and a harried-looking nurse.\n" expect
_out1 _oob1 _client1 "Obvious exits: garden\n"        expect

( Tests 64-69: Send MUF command to nanomud: )
:: ", 2 2 +\n" _in1 writeStream ; shouldWork

_out1 _oob1 _client1 "Stack: 4\n"                     expect



( Tests 70-120: Open a second client connection to nanomud: )
:: makeSocket --> _client2 ; shouldWork
:: makeMessageStream --> _in2 ; shouldWork
:: makeMessageStream --> _out2 ; shouldWork
:: makeMessageStream --> _oob2 ; shouldWork
:: makeMessageStream --> _client2OobInput ; shouldWork
:: _in2      --> _client2.standardInput ; shouldWork
:: _out2     --> _client2.standardOutput ; shouldWork
:: _client2OobInput  --> _client2.outOfBandInput  ; shouldWork
:: _oob2 --> _client2.outOfBandOutput ; shouldWork
:: [ :socket _client2
     :port 32000
     :protocol :stream
   | ]openSocket
; shouldWork

:: t --> _client2.telnetProtocol ; shouldWork
_out2 _oob2 _client2 "login:\n"                       expect

:: "nano2\n" _in2 writeStream ; shouldWork
_out2 _oob2 _client2 "passphrase:\n"                    expect

:: "nano2\n" _in2 writeStream ; shouldWork

_out2 _oob2 _client2 "Welcome to the Muq nanomud!\n"  expect
_out2 _oob2 _client2 "Do '.help' for help.\n"         expect
_out2 _oob2 _client2
"You see lots of cradles and a harried-looking nurse.\n" expect
_out2 _oob2 _client2 "Obvious exits: garden\n"        expect
_out2 _oob2 _client2 "Listening: nano1\n"             expect

_out1 _oob1 _client1 "[ nano2 has connected.\n"       expect



( Tests 121-141: Have nano1 say something: )
:: "Hey, sexy!\n" _in1 writeStream ; shouldWork
_out1 _oob1 _client1 "You say, \"Hey, sexy!\"\n"      expect
_out2 _oob2 _client2 "nano1 says, \"Hey, sexy!\"\n"   expect

( Tests 142-152: Have nano2 say something: )
:: "Well, hello handsome!\n" _in2 writeStream ; shouldWork
_out2 _oob2 _client2 "You say, \"Well, hello handsome!\"\n"    expect
_out1 _oob1 _client1 "nano2 says, \"Well, hello handsome!\"\n" expect


( Tests 153-163: Have nano1 pose something: )
:: " chuckles\n" _in1 writeStream ; shouldWork
_out1 _oob1 _client1 "nano1 chuckles\n"               expect
_out2 _oob2 _client2 "nano1 chuckles\n"               expect


( Tests 164-174: Have nano2 pose something: )
:: " giggles\n" _in2 writeStream ; shouldWork
_out2 _oob2 _client2 "nano2 giggles\n"                expect
_out1 _oob1 _client1 "nano2 giggles\n"                expect




( Tests 175-195: Have nano1 exit the room: )
:: ".g garden\n" _in1 writeStream ; shouldWork
_out2 _oob2 _client2 "> nano1 has left.\n"            expect
_out1 _oob1 _client1
"You pass through exit 'garden' into room 'Rose Garden'\n" expect
_out1 _oob1 _client1
"Sun-warmed roses scent the air, only the robin in the birdbath breaks the silence.\n"                                                  expect
_out1 _oob1 _client1 "Obvious exits: nursery\n"       expect



( Tests 196-221: Have nano2 exit the room: )
:: ".g garden\n" _in2 writeStream ; shouldWork

_out1 _oob1 _client1 "< nano2 has arrived.\n"         expect
_out2 _oob2 _client2
"You pass through exit 'garden' into room 'Rose Garden'\n" expect
_out2 _oob2 _client2
"Sun-warmed roses scent the air, only the robin in the birdbath breaks the silence.\n"                                                  expect
_out2 _oob2 _client2 "Obvious exits: nursery\n"       expect
_out2 _oob2 _client2 "Listening: nano1\n"             expect




( Tests 222-242: Have nano2 return to nursery: )
:: ".g nursery\n" _in2 writeStream ; shouldWork

_out1 _oob1 _client1 "> nano2 has left.\n"            expect
_out2 _oob2 _client2
"You pass through exit 'nursery' into room 'Nursery'\n"  expect
_out2 _oob2 _client2
"You see lots of cradles and a harried-looking nurse.\n" expect
_out2 _oob2 _client2 "Obvious exits: garden\n"        expect


( Tests 243-268: Have nano1 return to nursery: )
:: ".g nursery\n" _in1 writeStream ; shouldWork

_out2 _oob2 _client2 "< nano1 has arrived.\n"         expect
_out1 _oob1 _client1
"You pass through exit 'nursery' into room 'Nursery'\n"  expect
_out1 _oob1 _client1 
"You see lots of cradles and a harried-looking nurse.\n" expect
_out1 _oob1 _client1 "Obvious exits: garden\n"        expect
_out1 _oob1 _client1 "Listening: nano2\n"             expect



( Tests 269-279: Have nano1 quit: )
:: ".q\n" _in1 writeStream ; shouldWork

_out1 _oob1 _client1 "Come again!\n"                  expect
_out2 _oob2 _client2 "] nano1 has disconnected.\n"    expect


( Tests 280-: Have nano2 quit: )
:: ".q\n" _in2 writeStream ; shouldWork

_out2 _oob2 _client2 "Come again!\n"                  expect


( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
