( --------------------------------------------------------------------- )
(			x-stream.muf				    CrT )
( Exercise message streams.						)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      95Oct15							)
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
( 95Oct15 jsp	Created.						)
( --------------------------------------------------------------------- )

"Message stream tests\n" log,
"\nMessage stream tests:" ,

( Tests 1-3: )
( Test that combining packets works as expected: )
::  makeLock --> _lock ; shouldWork
::  makeMessageStream -> mss
    _lock withChildLockDo{
	"t11" forkJob not if
	    [ 'a' 'b' 'c' | "txt" nil mss |writeStreamPacket pop pop ]pop
	    [ 'd' 'e' 'f' | "txt"   t mss |writeStreamPacket pop pop ]pop

	    ( Fork reader job as child of writer job  )
	    ( so reader inherits lock and releases it )
	    ( only when _string is valid:            )
	    "t12" forkJob not if
		t mss readStreamPacket[
		    -> who
		    -> tag
		]join --> _string
		nil endJob
	    fi
	    nil endJob
	fi
    }
    ( Wait for reader to exit: )
    _lock withLockDo{ }
; shouldWork
:: "abcdef" _string = ; shouldBeTrue

( Tests 4-9: )
( Test basic |readAnyStreamPacket functionality: )
::  makeMessageStream --> _mss ; shouldWork
::  [ 'm' 'n' 'o' | "txt" t _mss |writeStreamPacket pop pop ]pop

    [ _mss | t nil
    |readAnyStreamPacket
    --> _stream
    --> _who
    --> _tag
    ]join --> _string

; shouldWork
:: _stream _mss = ; shouldBeTrue
:: _who me = ; shouldBeTrue
:: _tag "txt" = ; shouldBeTrue
:: _string "mno" = ; shouldBeTrue

( Tests 10-16: )
( Test special null case for |readAnyStreamPacket: )
::  "xyz" --> _string ; shouldWork
::  makeMessageStream --> _mss ; shouldWork
::  [ 'm' 'n' 'o' | "txt" t _mss |writeStreamPacket pop pop ]pop

    [ | t nil
    |readAnyStreamPacket
    --> _stream
    --> _who
    --> _tag
    ]join --> _string

; shouldWork
:: _stream nil = ; shouldBeTrue
:: _who nil = ; shouldBeTrue
:: _tag nil = ; shouldBeTrue
:: _string "" = ; shouldBeTrue

( Tests 17-30: )
( Test ability to select from either of    )
( two streams when no waiting is required: )
::  makeMessageStream --> _mssl ; shouldWork
::  makeMessageStream --> _mss1 ; shouldWork
::  [ 'g' 'h' 'i' | "txt" t _mssl |writeStreamPacket pop pop ]pop

    [ _mssl _mss1 | t nil
    |readAnyStreamPacket
    --> _stream
    --> _who
    --> _tag
    ]join --> _string

; shouldWork
:: _stream _mssl = ; shouldBeTrue
:: _who me = ; shouldBeTrue
:: _tag "txt" = ; shouldBeTrue
:: _string "ghi" = ; shouldBeTrue

::  makeMessageStream --> _mssl ; shouldWork
::  makeMessageStream --> _mss1 ; shouldWork
::  [ 'j' 'k' 'l' | "txt" t _mss1 |writeStreamPacket pop pop ]pop

    [ _mssl _mss1 | t nil
    |readAnyStreamPacket
    --> _stream
    --> _who
    --> _tag
    ]join --> _string

; shouldWork
:: _stream _mss1 = ; shouldBeTrue
:: _who me = ; shouldBeTrue
:: _tag "txt" = ; shouldBeTrue
:: _string "jkl" = ; shouldBeTrue

( Tests 31-37: )
( Test ability to time-out while waiting for input: )
::  makeMessageStream --> _mssl ; shouldWork
::  makeMessageStream --> _mss1 ; shouldWork
::  [ _mssl _mss1 | t 2
    |readAnyStreamPacket
    --> _stream
    --> _who
    --> _tag
    ]join --> _string

; shouldWork
:: _stream nil = ; shouldBeTrue
:: _who nil = ; shouldBeTrue
:: _tag nil = ; shouldBeTrue
:: _string "" = ; shouldBeTrue

( Tests 38-45: )
( Test ability read from initially empty streams: )
::  makeMessageStream --> _mssl ; shouldWork
::  makeMessageStream --> _mss1 ; shouldWork
::  makeLock           --> _lock  ; shouldWork
::  _lock withChildLockDo{
	"t13" forkJob if
	    ( Parent, doesn't inherit lock. )

	    ( Make sure child has time to   )
	    ( block on read before writing: )
	    2000 sleepJob

	    ( Write something for child to  )
	    ( read, so it unblocks:         )
            [ 'm' 'u' 'q' | "txt" t _mss1 |writeStreamPacket pop pop ]pop
	    
	    ( Wait until child has read,    )
	    ( marked by release of lock:    )
	    _lock withLockDo{ }

        else
	    ( Child, inherits lock. )

	    ( Promiscuously read    )
            ( packet from streams:  )
	    [ _mssl _mss1 | t nil
	    |readAnyStreamPacket
	    --> _stream
	    --> _who
	    --> _tag
	    ]join --> _string

	    ( Exit, releasing lock )
	    ( in the process:      )
	    nil endJob
        fi
    }
; shouldWork
:: _stream _mss1 = ; shouldBeTrue
:: _who me = ; shouldBeTrue
:: _tag "txt" = ; shouldBeTrue
:: _string "muq" = ; shouldBeTrue

( Tests 46-53: )
( Same as above, other stream: )
::  makeMessageStream --> _mssl ; shouldWork
::  makeMessageStream --> _mss1 ; shouldWork
::  makeLock           --> _lock  ; shouldWork
::  _lock withChildLockDo{
	"t14" forkJob if
	    ( Parent, doesn't inherit lock. )

	    ( Make sure child has time to   )
	    ( block on read before writing: )
	    2000 sleepJob

	    ( Write something for child to  )
	    ( read, so it unblocks:         )
            [ 'm' 'u' 'q' | "txt" t _mssl |writeStreamPacket pop pop ]pop
	    
	    ( Wait until child has read,    )
	    ( marked by release of lock:    )
	    _lock withLockDo{ }

        else
	    ( Child, inherits lock. )

	    ( Promiscuously read    )
            ( packet from streams:  )
	    [ _mssl _mss1 | t nil
	    |readAnyStreamPacket
	    --> _stream
	    --> _who
	    --> _tag
	    ]join --> _string

	    ( Exit, releasing lock )
	    ( in the process:      )
	    nil endJob
        fi
    }
; shouldWork
:: _stream _mssl = ; shouldBeTrue
:: _who me = ; shouldBeTrue
:: _tag "txt" = ; shouldBeTrue
:: _string "muq" = ; shouldBeTrue




( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
