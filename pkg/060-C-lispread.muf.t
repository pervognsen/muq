@example  @c

( - 060-C-lispread.muf -- Reader for Muq Lisp.				)
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
( Created:      96Mar10							)
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
( - Epigram.								)

(   Fall in love with what you do for a living.				)
(   I don't care what it is.   It works.				)
(      -- George Burns							)

( =====================================================================	)
( - Select LISP Package							)

"lisp" inPackage

( =====================================================================	)
( - Some borrowings from the muf package				)
#'muf:cons --> #'lisp:cons
'lisp:cons export

( =====================================================================	)
( - Public constants -							)

( States used by the |readLispChars prim. These )
( are #define'd in job.t:job_P_Read_Lisp_Chars:   )
 1 -->constant stateInitial	   'stateInitial	export
 2 -->constant stateEven	   'stateEven		export
 3 -->constant stateOdd	   'stateOdd		export
 4 -->constant stateEvenEscape   'stateEvenEscape	export
 5 -->constant stateOddEscape	   'stateOddEscape	export
 6 -->constant stateMacro	   'stateMacro		export
 7 -->constant stateSymbol	   'stateSymbol	export
 8 -->constant statePotnum	   'statePotnum	export
 9 -->constant stateEof	   'stateEof		export
10 -->constant stateDot	   'stateDot		export
11 -->constant stateRightParen   'stateRightParen	export
12 -->constant stateWhitespace	   'stateWhitespace	export

( Types returned by ]makeNumber prim.  These )
( are #define'd in job.t:job_P_Lisp_Number:   )
0 -->constant lispBadnum          'lispBadnum		export
1 -->constant lispShortFloat     'lispShortFloat	export
2 -->constant lispSingleFloat    'lispSingleFloat	export
3 -->constant lispDoubleFloat    'lispDoubleFloat	export
4 -->constant lispExtendedFloat  'lispExtendedFloat	export
5 -->constant lispFixnum	   'lispFixnum		export
6 -->constant lispBignum	   'lispBignum		export
7 -->constant lispRatio	   'lispRatio		export

( =====================================================================	)
( - Public fns -							)

( =====================================================================	)
( - list -- Construct a list.						)
:   list { [] -> [] }

    nil    -> result
    do{
	|length 0 = until
        |pop result cons -> result
    }

    result |push
;
'list export

( =====================================================================	)
( - dottedList -- Construct a list with given terminal element.	)
:   dottedList { [] $ -> [] }

    -> result
    do{
	|length 0 = until
        |pop result cons -> result
    }

    result |push
;
'dottedList export

( =====================================================================	)
( - read -- Lisp reader						        )
:   read { [] -> [] }

    ( Declare four local vars for parameters: )
    parameter: inputStream
    parameter: eofErrorP
    parameter: eofValue
    parameter: recursiveP

    ( Process parameter block into above: )
    applyReadLambdaList
    ]setLocalVars


    do{
	( Munch a token/part: )
	[ inputStream |
        |scanLispToken
	|pop -> state
	|pop -> line

	state case{

        on: stateWhitespace
	    ]pop

	on: stateSymbol
	    muf:|readTokenChars
            |classifyLispToken
	    case{

            on: stateSymbol
	        nil muf:]makeSymbol -> val
	        [ val | return

	    on: statePotnum
	        muf:]makeNumber -> val
	        pop ( Ignore number type )
	        [ val | return

	    on: stateDot
		"'.' not allowed here" simpleError

	    else:
		"read internal err" simpleError
	    }

	on: stateMacro
	    muf:|readTokenChars
	    |pop -> c  ( Character triggering macro )
	    ]pop

	    ( Find macro function: )
	    [ c | getMacroCharacter |popp |pop -> cfn ]pop
	    cfn callable? not if
		[ "Unexpected char '%c'" c | ]print simpleError
	    fi	

	    ( Invoke macro function: )
	    [ inputStream c | cfn call{ [] -> [] }

	    ( If it contains one value, return )
	    ( that value, else continue loop:  )
	    |length 1 = if return fi
	    ]pop
	    loopNext

	else:
	    "read internal err" simpleError
	}
    }
;
'read export


( =====================================================================	)
( - readLispList -- Lisp char macro function for '('		        )
:   readLispList { [] -> [] }

    ( Pop the '(' which triggered us: )
    |popp

    ( Remember our input stream: )
    |pop -> inputStream

    ( Accumulate stuff until we find  )
    ( and discard a ')':              )
    do{
	( Unfortunately, I cannot find a nicer solution )
	( here than replicating most of 'read':         )
	( o  I don't want to read and unread a token    )
        (    constantly checking for upcoming ')'       )
        ( o  I don't want to put the guts of 'read'     )
        (    in a separate fn, for efficiency reasons   )
        ( o  'read' must issue an error message if it   )
        (    encounters a ')'.                          )

	[ inputStream |
        |scanLispToken
	|pop -> state
	|pop -> line
	
	state case{

        on: stateWhitespace
	    ]pop

	on: stateSymbol
	    muf:|readTokenChars
            |classifyLispToken
	    case{

	    on: stateSymbol
		nil muf:]makeSymbol |push
		loopNext

	    on: statePotnum
		muf:]makeNumber -> val
		pop ( Ignore number type )
		val |push
		loopNext

	    on: stateDot
		( What an odd syntactic hack! : ^ )

		( Discard block containing '.': )
		]pop

		( Dot must not be first in list: )
		|length 0 = if ". must not be first in list" simpleError fi

		( Dot must be followed by exactly )
		( one element. Read it in:        )
		[ inputStream t nil t | read |pop -> val ]pop

		( Must have ')' now, possibly preceded by comments: )
		do{
		    ( Read next token: )
		    [ inputStream |
		    |scanLispToken
		    |pop -> state
		    |pop -> line
		    state stateWhitespace = if ]pop loopNext fi

		    ( If it is ')' we're home free: )
		    ". must precede last element of list" -> err
		    state stateMacro    != if err simpleError fi
		    muf:|readTokenChars
		    |pop -> c ]pop

		    [ c | getMacroCharacter |popp |pop -> cfn ]pop

		    cfn stateRightParen = if loopFinish fi

		    ( We probably have a comment: )
		    cfn callable? not if err simpleError fi
		    [ inputStream c | cfn call{ [] -> [] }
		    |length 0 != if err simpleError fi

		    ( Yup. Or some macro returning nothing, )
		    ( which seems close enough.  Clean up   )
		    ( and on to next token:                 )
		    ]pop
		}

		( Construct and return list value: )
		val dottedList return

	    else:
		"read internal err" simpleError
	    }

	on: stateMacro
	    muf:|readTokenChars
	    |pop -> c  ( Character triggering macro )
	    ]pop

	    ( Find macro function: )
	    [ c | getMacroCharacter |popp |pop -> cfn ]pop

	    ( Check for ')' terminating list: )
	    cfn stateRightParen = if
		( Convert stackblock to a list: )
		list
		( Return list: )
		return
	    fi

	    ( Invoke macro function: )
	    cfn callable? not if
		[ "Unexpected char '%c'" c | ]print simpleError
	    fi	
	    [ inputStream c | cfn call{ [] -> [] }

	    ( If it contains one value, add it )
	    ( to result block else continue:   )
	    |length 1 = if
		|pop -> val   ]pop   val |push
	    else
		]pop
	    fi

	    loopNext

	else:
	    "read internal err" simpleError
	}
    }
;


( =====================================================================	)
( - readLispComment -- Lisp char macro function for ';'	        )
:   readLispComment { [] -> [] }

    ( Pop the ';' which triggered us: )
    |popp

    ( Push delimiter we'll scan to: )
    '\n' |push
    
    ( Read the comment: )
    |scanTokenToChar

    ( Return an empty block: )
    ]pop
    [ |
;


( =====================================================================	)
( - readLispString -- Lisp char macro function for '"'	        )
:   readLispString { [] -> [] }

    ( Set up args: )
(    '\\' |push )

    ( Read the string: )
(    |scanTokenToChar |pop -> line )
    |scanLispStringToken |pop -> line
    muf:|readTokenChars

    ( Pop terminal ": )
    |popp

    ( Remove one level of quoting: )
    |dropSingleQuotes

    ( Collapse charblock into a string: )
    ]join -> str

    ( Return string in lispStyle block: )
    [ str | 
;


( =====================================================================	)
( - readLispQuote -- Lisp char macro function for '\''        	)
:   readLispQuote { [] -> [] }

    ( Get ' proper: )
    |pop -> c

    ( Get input stream: )
    |pop -> inputStream
    ]pop

    ( Recursively read an object: )
    [ inputStream t nil t | read |pop -> val ]pop

    ( Construct and return list of quote and val: )
    [ 'quote val | list
;
'quote export


( =====================================================================	)
( - readLispHash -- Lisp char macro function for '#'	        	)
:   readLispHash { [] -> [] }

    ( Drop # proper: )
    |popp

    ( Get input stream: )
    |pop -> inputStream
    ]pop

    ( Buggo -- Not finished.  Dummy return value: )
    [ |
;


( =====================================================================	)
( - Initialize readtable -						)

[ ')'  stateRightParen   | setMacroCharacter ]pop
[ ';'  #'readLispComment | setMacroCharacter ]pop
[ '('  #'readLispList    | setMacroCharacter ]pop
[ '"'  #'readLispString  | setMacroCharacter ]pop
[ '\'' #'readLispQuote   | setMacroCharacter ]pop

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example
