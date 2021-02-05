@example  @c

( - 070-C-lispprint.muf -- Printer for Muq Lisp.				)
( - This file is formatted for outline-minor-mode in emacs19.		)
( -^C^O^A shows All of file.						)
(  ^C^O^Q Quickfolds entire file. (Leaves only top-level headings.)	)
(  ^C^O^T hides all Text. (Leaves all headings.)			)
(  ^C^O^I shows Immediate children of node.				)
(  ^C^O^S Shows all of a node.						)
(  ^C^O^D hiDes all of a node.						)
(  ^HFoutline-mode gives more details.					)
(  (Or do ^HI and read emacs:outline mode.)				)


( =====================================================================	)
( - Dedication and Copyright.						)

(  -------------------------------------------------------------------  )
(									)
(		For Firiss:  Aefrit, a friend.				)
(									)
(  -------------------------------------------------------------------  )

(  -------------------------------------------------------------------	)
( Author:       Jeff Prothero						)
( Created:      96Mar31							)
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
(  Contact cynbe@@eskimo.com for a COMMERCIAL LICENSE.			)
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
( NO EVENT SHALL JEFF PROTHERO BE LIABLE FOR ANY SPECIAL, INDIRECT OR	)
( CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS	)
( OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,		)
( NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION	)
( WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.				)
( 									)
( Please send bug reports/fixes etc to bugs@@muq.org			)
(  -------------------------------------------------------------------	)

( =====================================================================	)
( - Quote.								)
(									)
(   The phrase "The King's English" came in, we are told,		)
(   with Henry VIII, who ruled from 1509 to 1547.  He was		)
(   a poet and a man of letters when he had the time. The		)
(   King's English remained standard, even under George I,		)
(   who could not speak English.					)
(   -- American Heritage Dictionary of the English Language,		)
(    p XXI								)
(									)


( =====================================================================	)
( - Select LISP Package							)

"lisp" inPackage


( Forward declaration of prin1 for   )
( recursive calls from subfunctions: )
:   prin1 { [] -> [] ! } ;


( =====================================================================	)
( - Public fns -							)

( =====================================================================	)
( - prin1List -- Lisp list printer				        )



:   prin1List { $ $ -> [] }
    -> stream
    -> cell

    ( We keep 'cell' for return value, )
    ( use 'c' to step down our list:   )
    cell -> c


    ( Special-case lists starting with QUOTE: )
    cell car 'quote =
    cell cdr cons? and
    if
	[ '\'' | "txt" nil stream |writeStreamPacket pop pop ]pop
	[ c cdr stream | prin1 ]pop [ cell | return
    fi

    ( Write opening paren: )
    [ '(' | "txt" nil stream |writeStreamPacket pop pop ]pop

    ( Print list out, value by value: )
    do{
	( Print current value: )
	[ c car stream | prin1 ]pop

	( Step to next value: )
	c cdr -> c

	( If next value is NIL, we're done: )
	c not until

	( If next value is a cons cell, we need )
	( to write a blank to separate last val )
	( from it:                              )
        [ ' ' | "txt" nil stream |writeStreamPacket pop pop ]pop
	c cons? if loopNext fi

	( Next is neither cons nor nil, need to   )
	( wrap up list with dottedList notation: )
        [ '.' ' ' | "txt" nil stream |writeStreamPacket pop pop ]pop
	[ c stream | prin1 ]pop
	loopFinish
    }

    ( Write closing paren: )
    [ ')' | "txt" nil stream |writeStreamPacket pop pop ]pop

    ( Return list: )
    [ cell |
;

( =====================================================================	)
( - prin1String -- Lisp string printer				        )

:   prin1String { $ $ -> [] }
    -> stream
    -> str

    ( Write opening doubleQuote: )
    [ '"' | "txt" nil stream |writeStreamPacket pop pop ]pop

    ( Print string out, line by line: )
    str length2 -> len  ( Length in bytes of string )
    0           -> loc	( Location within string    )
    do{
	( Break loop if string all printed: )
	loc len >= until

	( Get next line <= 256 chars long, update loc: )
	str loc 256 explodeBoundedStringLine[
        loc + -> loc
	
        ( Print the line: )
	|dup '\n' = -> completeLine
	"txt" completeLine stream
	|writeStreamPacket
        pop pop ]pop
    }

    ( Write closing doubleQuote: )
    [ '"' | "txt" nil stream |writeStreamPacket pop pop ]pop

    ( Return object: )
    [ str |
;

( =====================================================================	)
( - prin1 -- Lisp printer					        )

:   prin1 { [] -> [] }

    ( Declare two local vars: )
    parameter: obj
    parameter: stream

    ( Process parameter block into above: )
    applyPrintLambdaList
    ]setLocalVars

    ( Branch on type of obj: )
    obj string? if obj stream prin1String return fi
    obj cons?   if obj stream prin1List   return fi
    obj symbol? if
	obj explodeSymbol[ "txt" nil stream
	|writeStreamPacket
	pop pop ]pop
        [ obj |
	return
    fi
    obj number? if
	obj explodeNumber[ "txt" nil stream
	|writeStreamPacket
	pop pop ]pop
        [ obj |
	return
    fi

    "prin1: unsupported value type" simpleError
;
'prin1 export

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example
