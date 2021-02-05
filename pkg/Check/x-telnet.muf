( --------------------------------------------------------------------- )
(			x-telnet.muf				    CrT )
( Exercise telnet protocol support.					)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      95Oct27							)
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
( 95Oct27 jsp	Created.						)
( --------------------------------------------------------------------- )

"Telnet protocol support tests\n" log,
"\nTelnet protocol support tests:" ,

( Tests 1-4: Create a socket listening )
( for connections on port 32122:       )
:: makeSocket --> _listen ; shouldWork
:: makeMessageStream --> _listenOutput ; shouldWork
:: _listenOutput --> _listen.standardOutput ; shouldWork
:: [ :socket _listen
     :port 32122
     :protocol :stream
   | ]listenOnSocket
; shouldWork

( Tests 5-10: Open a client connection: )
:: makeSocket --> _client ; shouldWork
:: makeMessageStream --> _clientInput ; shouldWork
:: makeMessageStream --> _clientOutput ; shouldWork
:: _clientInput --> _client.standardInput ; shouldWork
:: _clientOutput --> _client.standardOutput ; shouldWork
:: [ :socket _client
     :port 32122
     :protocol :stream
   | ]openSocket
; shouldWork

( Tests 11-21: Accept the connection, creating server: )
:: _listenOutput readStreamLine --> _server --> _opcode ; shouldWork
:: _server socket? ; shouldBeTrue
:: _opcode "new" = ; shouldBeTrue
:: makeMessageStream --> _serverInput ; shouldWork
:: makeMessageStream --> _serverOutput ; shouldWork
:: makeMessageStream --> *server-oob-input* ; shouldWork
:: makeMessageStream --> _serverOobOutput ; shouldWork
:: _serverInput --> _server.standardInput ; shouldWork
:: _serverOutput --> _server.standardOutput ; shouldWork
:: *server-oob-input* --> _server.outOfBandInput ; shouldWork
:: _serverOobOutput --> _server.outOfBandOutput ; shouldWork

( Tests 22-25: Set both sockets to pass nonprints both ways: )
:: t --> _server.passNonprintingToNet   ; shouldWork
:: t --> _client.passNonprintingToNet   ; shouldWork
:: t --> _server.passNonprintingFromNet ; shouldWork
:: t --> _client.passNonprintingFromNet ; shouldWork

( Tests 26-27: Set server but not client for TELNET support: )
:: t   --> _server.telnetProtocol ; shouldWork
:: nil --> _client.telnetProtocol ; shouldWork

( Tests 28-29: Construct strings containing 0xFF bytes: )
255 intChar -->constant IAC
253 intChar -->constant DO
250 intChar -->constant SB
246 intChar -->constant AYT
240 intChar -->constant SE
  1 intChar -->constant ECHO
:: [ IAC IAC 'a' 'b' 'c' '\n' | ]join --> _FFFFline ; shouldWork
:: [ IAC     'a' 'b' 'c' '\n' | ]join -->   _FFline ; shouldWork

( Test 30: Send a line from client to server: )
:: _FFFFline _clientInput writeStream ; shouldWork

( Test 31-33: Read line at server end: )
:: _serverOutput readStreamLine --> _who --> _line ; shouldWork
:: _who _server = ; shouldBeTrue
:: _line _FFline = ; shouldBeTrue

( Tests 34-39: Try same with TELNET completely off: )
:: nil --> _server.telnetProtocol ; shouldWork
:: nil --> _client.telnetProtocol ; shouldWork
:: _FFFFline _clientInput writeStream ; shouldWork
:: _serverOutput readStreamLine --> _who --> _line ; shouldWork
:: _who _server = ; shouldBeTrue
:: _line _FFFFline = ; shouldBeTrue

( Tests 40-45: Try same with TELNET only on client: )
:: nil --> _server.telnetProtocol ; shouldWork
:: t   --> _client.telnetProtocol ; shouldWork
:: _FFline _clientInput writeStream ; shouldWork
:: _serverOutput readStreamLine --> _who --> _line ; shouldWork
:: _who _server = ; shouldBeTrue
:: _line _FFFFline = ; shouldBeTrue

( Tests 46-51: Try same with TELNET on both: )
:: t   --> _server.telnetProtocol ; shouldWork
:: t   --> _client.telnetProtocol ; shouldWork
:: _FFline _clientInput writeStream ; shouldWork
:: _serverOutput readStreamLine --> _who --> _line ; shouldWork
:: _who _server = ; shouldBeTrue
:: _line _FFline = ; shouldBeTrue

( Tests 52-63: Check rerouting of two-byte TELNET command: )
:: t   --> _server.telnetProtocol ; shouldWork
:: nil --> _client.telnetProtocol ; shouldWork
:: [ IAC AYT 'a' 'b' 'c' '\n' | ]join --> _AYTline ; shouldWork
:: [ IAC AYT | ]join --> _AYT ; shouldWork
:: [ 'a' 'b' 'c' '\n' | ]join --> _ABCline ; shouldWork
:: _AYTline _clientInput writeStream ; shouldWork
:: _serverOutput readStreamLine --> _who --> _line ; shouldWork
:: _who _server = ; shouldBeTrue
:: _line _ABCline = ; shouldBeTrue
:: _serverOobOutput readStreamLine --> _who --> _line ; shouldWork
:: _who _server = ; shouldBeTrue
:: _line _AYT = ; shouldBeTrue

( Tests 64-74: Check rerouting of three-byte TELNET command: )
:: t   --> _server.telnetProtocol ; shouldWork
:: nil --> _client.telnetProtocol ; shouldWork
:: [ IAC DO ECHO 'a' 'b' 'c' '\n' | ]join --> _DO_ECHOline ; shouldWork
:: [ IAC DO ECHO | ]join --> _DO_ECHO ; shouldWork
:: _DO_ECHOline _clientInput writeStream ; shouldWork
:: _serverOutput readStreamLine --> _who --> _line ; shouldWork
:: _who _server = ; shouldBeTrue
:: _line _ABCline = ; shouldBeTrue
:: _serverOobOutput readStreamLine --> _who --> _line ; shouldWork
:: _who _server = ; shouldBeTrue
:: _line _DO_ECHO = ; shouldBeTrue

( Tests 75-85: Check rerouting of multi-byte TELNET suboption commands: )
:: t   --> _server.telnetProtocol ; shouldWork
:: nil --> _client.telnetProtocol ; shouldWork
:: [ IAC SB IAC IAC IAC SE 'a' 'b' 'c' '\n' | ]join --> _SBline ; shouldWork
:: [ IAC SB IAC     IAC SE | ]join --> _SB ; shouldWork
:: _SBline _clientInput writeStream ; shouldWork
:: _serverOutput readStreamLine --> _who --> _line ; shouldWork
:: _who _server = ; shouldBeTrue
:: _line _ABCline = ; shouldBeTrue
:: _serverOobOutput readStreamLine --> _who --> _line ; shouldWork
:: _who _server = ; shouldBeTrue
:: _line _SB = ; shouldBeTrue

( Tests 86-88: Close all ports: )
:: [ :socket _client | ]closeSocket ; shouldWork
:: [ :socket _server | ]closeSocket ; shouldWork
:: [ :socket _listen | ]closeSocket ; shouldWork



( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
