( --------------------------------------------------------------------- )
(			x-skt.muf				    CrT )
( Exercise sockets.							)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      95Oct21							)
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
( 95Oct21 jsp	Created.						)
( --------------------------------------------------------------------- )

"Socket tests\n" log,
"\nSocket tests:" ,

( First, exercise vanilla tcp stuff: )

( Tests 1-4: Create a socket listening )
( for connections on port 32123:       )
:: makeSocket --> _listen ; shouldWork
:: makeMessageStream --> _listenOutput ; shouldWork
:: _listenOutput --> _listen.standardOutput ; shouldWork
:: [ :socket _listen
     :port 32123
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
     :port 32123
     :protocol :stream
   | ]openSocket
; shouldWork

( Tests 11-17: Accept the connection, creating server: )
:: _listenOutput readStreamLine --> _server --> _opcode ; shouldWork
:: _server socket? ; shouldBeTrue
:: _opcode "new" = ; shouldBeTrue
:: makeMessageStream --> _serverInput ; shouldWork
:: makeMessageStream --> _serverOutput ; shouldWork
:: _serverInput --> _server.standardInput ; shouldWork
:: _serverOutput --> _server.standardOutput ; shouldWork

( Test 18: Send a line from client to server: )
:: "This is a test\n" _clientInput writeStream ; shouldWork

( Test 19-21: Read line at server end: )
:: _serverOutput readStreamLine --> _who --> _line ; shouldWork
:: _who _server = ; shouldBeTrue
:: _line "This is a test\n" = ; shouldBeTrue

( Test 22: Send a line from server to client: )
:: "This is not a test\n" _serverInput writeStream ; shouldWork

( Test 23-25: Read line at client end: )
:: _clientOutput readStreamLine --> _who --> _line ; shouldWork
:: _who _client = ; shouldBeTrue
:: _line "This is not a test\n" = ; shouldBeTrue

( Tests 26-28: Close all ports: )
:: [ :socket _client | ]closeSocket ; shouldWork
:: [ :socket _server | ]closeSocket ; shouldWork
:: [ :socket _listen | ]closeSocket ; shouldWork



( Okie, now to exercise some udp stuff: )

( Tests 29-34: Create a socket listening )
( for udp packets on port 60127:       )
:: makeSocket --> _server ; shouldWork
:: makeMessageStream --> _serverOutput ; shouldWork
:: makeMessageStream --> _serverInput ; shouldWork
:: _serverInput  --> _server.standardInput ; shouldWork
:: _serverOutput --> _server.standardOutput ; shouldWork
:: [ :socket _server
     :port 60127	( Local socket on which we read. )
     :protocol :datagram
   | ]listenOnSocket
; shouldWork

( Tests 35-41: Open a socket for sending )
( udp packets to port 60127:             )
:: makeSocket --> _client ; shouldWork
:: makeMessageStream --> _clientOutput ; shouldWork
:: makeMessageStream --> _clientInput ; shouldWork
:: _clientInput  --> _client.standardInput ; shouldWork
:: _clientOutput --> _client.standardOutput ; shouldWork
:: [ :socket _client
     :port 60127	( Far socket to which we send. )
     :protocol :datagram
   | ]openSocket
; shouldWork

( Tests 42-43: Preserve datagram boundaries: )
:: nil --> _server.inputByLines ; shouldWork
:: nil --> _client.inputByLines ; shouldWork

( Tests 44-46: Send a query until )
( we get an acknowledgement back: )
:: nil --> _timeForServerToExit ; shouldWork
:: makeLock --> _lock ; shouldWork
::  _lock withChildLockDo{
        1000 -> millisecsToWait
        "t10" forkJob -> amParent
        amParent if

	    ( We'll have parent job play client: )
	    do{
	        ( Send a query to server: )
	        "Party!\nRSVP" stringChars[
                "txt" t _clientInput
		|writeStreamPacket
		pop pop ]pop

		( Read an acknowledgement: )
	        [ _clientOutput | t millisecsToWait
                |readAnyStreamPacket dup not if

		    ( Timeout: Discard dummy )
                    ( values and try again:  )
		    pop pop pop ]pop
		    millisecsToWait 2 * -> millisecsToWait

                else

		    ( Got acknowledgement:   )
                    ( save it and quit loop: )
	            --> _clientStream
	            --> _clientSocket
	            --> _clientTag

		    ( Delete address info    )
		    ( from datagram packet:  )
		    |deleteNonchars

		    ( Save server response:  )
	            ]join --> _serverLine

		    ( Reset wait time before next request: )
		    1000 -> millisecsToWait

		    ( Do only one request,  )
		    ( for this toy example: )
		    loopFinish
                fi
	    }

	    ( Tell server to exit: )
	    t --> _timeForServerToExit	

	    ( Wait until it does: )
	    _lock withLockDo{ }

        else
	    ( We'll have child job play server: )
	    do{
	        ( Read datagram from client: )
	        [ _serverOutput | t millisecsToWait
                |readAnyStreamPacket dup not if

		    ( Timeout: Discard )
                    ( dummy values:    )
		    pop pop pop ]pop

		else

		    ( Got request -- save it: )
	            --> _serverStream
	            --> _serverSocket
	            --> _serverTag

		    ( Remember where request came from: )
		    :ip0  |get -> ip0
		    :ip1  |get -> ip1
		    :ip2  |get -> ip2
		    :ip3  |get -> ip3
		    :port |get -> port

		    ( Remove address info )
		    |deleteNonchars

		    ( Record request line: )
	            ]join --> _clientLine

		    ( Acknowledge request: )
		    [ :ip0 ip0 :ip1 ip1 :ip2 ip2 :ip3 ip3 :port port |
	            "No thanks!" stringChars[ ]|join
		    "txt" t _serverInput
                    |writeStreamPacket
		    pop pop ]pop
                fi

	        ( Exit if client says to: )
	        _timeForServerToExit if

                    ( Exiting releases lock: )
		    nil endJob
	        fi
	    }
       fi
    }
; shouldWork

( Tests 47-48: Check datagram contents: )
:: _clientLine "Party!\nRSVP" = ; shouldBeTrue
:: _serverLine "No thanks!"   = ; shouldBeTrue

( Tests 49-50: Close both ports: )
:: [ :socket _server | ]closeSocket ; shouldWork
:: [ :socket _client | ]closeSocket ; shouldWork

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
