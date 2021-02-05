@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)
@example  @c

( - 200-O-edit.muf -- Simple line editor.				)
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

(  -------------------------------------------------------------------  )
( Author:       Jeff Prothero						)
( Created:      95May08							)
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
( Please send bug reports/fixes etc to bugs@@muq.org.			)
(  -------------------------------------------------------------------	)

( =====================================================================	)
( - Epigram.								)

(     Everything is in a state of flux,					)
(     and this includes the world of chess.				)
(         -- Mikhail Botvinnik						)
(    (who died three days before this file was created)			)    

( - Public fns								)

"LNED" rootValidateDbfile pop
[ "edit" .db["LNED"] | ]inPackage


( =====================================================================	)
( - showHelp			             				)

: showHelp -> stream
    "\n+--------------------< Editor Help >----------------------\n"
    stream writeStream

    "|   a<text>:  insert <text> as a line After current line.\n"
    stream writeStream

    "|   b<text>:  insert <text> as a line Before current line.\n"
    stream writeStream

    "|   d:  Delete current line.\n"
    stream writeStream

    "|   n:  move to Next line.\n"
    stream writeStream

    "|   p:  move to Previous line.\n"
    stream writeStream

    "|   r:  Revert to original text.\n"
    stream writeStream

    "|   s/abc/def:  Substitute 'def' for 'abc' on current line.\n"
    stream writeStream

    "|   t3:  Type current line plus 3 lines before and after\n"
    stream writeStream

    "|   x:  eXit.\n"
    stream writeStream

    "|   13:  go to line 13.\n"
    stream writeStream

    "+---------------------------------------------------------\n\n"
    stream writeStream
;

( =====================================================================	)
( - editString			             				)

: editString   { $ -> $ ! }   -> text
   
    @.terminalIo -> ioStream
    t            -> printPrompt       

    ( Start edit on first line: )
    0 -> thisLine

    ( Convert string to be edited into a block of lines: )
    text "\n" chopString[

    ( Warn user of new mode: )
    |length -> len
    [ "Editing %d-line string: Enter 'h' for help.\n" len | ]print
    ioStream writeStream

    ( Loop until user exits: )
    do{
	printPrompt if 
	    ( Issue prompt consisting of current line and number: )
	    thisLine |dupNth -> line
	    [ "%3d: %s\n" thisLine 1 + line | ]print ioStream writeStream
	fi
	t -> printPrompt

	( Read a command from user: )
	ioStream readStreamLine pop trimString -> cmd

	( If user does nothing, show we can too: )
	cmd length 0 = if loopNext fi

        cmd[0] digitChar? if
	    |length -> len
	    cmd stringInt 1 - -> thisLine
	    thisLine 0   <  if 0       -> thisLine fi
	    thisLine len >= if len 1 - -> thisLine fi
	    loopNext
	fi

	cmd[0] case{

	on: 'a'
	    ( Handle "after" request: )
	    cmd length -> len
	    cmd 1 len substring   thisLine 1 +   |pushNth
	    thisLine 1 + -> thisLine

	on: 'b'
	    ( Handle "before" request: )
	    cmd length -> len
	    cmd 1 len substring   thisLine   |pushNth

	on: 'd'
	    ( Handle "delete" request: )
	    thisLine |popNth pop
	    ( Make sure at least one line exists: )
	    |length 0 = if "" |push fi
	    ( Make sure we are on a line that exists: )
	    |length -> len
	    thisLine len >= if len 1 - -> thisLine fi

	on: 'h'
	    ( Handle "help" request: )
	    ioStream showHelp

	on: 'n'
	    ( Handle "next" request: )
	    thisLine 1 + -> thisLine
	    |length -> len
	    thisLine len >= if len 1 - -> thisLine fi

	on: 'p'
	    ( Handle "previous" request: )
	    thisLine 1 - -> thisLine
	    thisLine 0 < if 0 -> thisLine fi

	on: 'r'
	    ( Handle "revert" request: )
	    ]pop
	    text "\n" chopString[
	    |length -> len
	    thisLine len >= if len 1 - -> thisLine fi

	on: 's'
	    ( Handle "substitute" request: )
	    cmd length 4 < if loopNext fi

	    ( Get 'from' and 'to' strings: )
	    cmd cmd[1] chopString[
		|length 3 != if
		    ]pop
		    loopNext
		fi
		|pop -> to
		|pop -> from
	    ]pop
	    from "" = if loopNext fi

	    ( Perform substition: )
	    thisLine |dupNth -> line
	    [ from to | line ]replaceSubstrings -> line
	    line thisLine |setNth

	on: 't'
	    ( Handle "type" request: )
	    cmd length -> len
	    cmd 1 len substring -> cmd
	    cmd[0] digitChar? if
		|length -> len
		cmd stringInt -> n
		thisLine n - -> lo
		thisLine n + -> hi
		lo 0   < if 0 -> lo fi
		hi len >= if len 1 - -> hi fi
		for i from lo upto hi do{
		    i |dupNth -> line
		    [ "%3d: %s\n" i 1 + line | ]print ioStream writeStream
		}
		nil -> printPrompt
	    fi

	on: 'x'
	    ( Handle "exit" request: )
	    "\n" ]glueStrings
	    return
	}
    }
;
'editString export
'editString --> .u["root"]$s.textEditor

( =====================================================================	)

( - File variables							)


( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example
