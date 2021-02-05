@example  @c

( - 090-C-lisp.muf -- Muq Lisp Compiler.				)
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
( Created:      96Apr03							)
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
( Please send bug reports/fixes etc to bugs@@muq.org.			)
(  -------------------------------------------------------------------	)

( =====================================================================	)
( - Epigram.								)

(   I do not fear computers.  I fear the lack of them.			)
(   -- Isaac Asimov							)

( =====================================================================	)
( - Select LISP Package							)

"lisp" inPackage

( =====================================================================	)
( - Public fns -							)

( =====================================================================	)
( - compileList -- Reduce a list to an executable fn		        )

( Input argument is anything from (+ 2 2) to (defun myfn ...)		)
( If left result is NIL, right result is return value.			)
( If left result is T,   right result is compiledFn to call for result )
:   compileList { $ -> $ $ } -> arg

    ( Peer at first element of list: )
    arg car -> sym
    sym symbol? not if "invalid function" simpleError fi
    sym symbolFunction -> fn
    fn not if "invalid function" simpleError fi
    nil arg
;

( =====================================================================	)
( - eval -- Compile + execute code, return result		        )

:   eval { [] -> [] ! }
    |pop -> arg ]pop

    ( Symbols: )
    arg symbol? if [ arg symbolValue | return fi


    ( Lists: )
    arg cons? if
	arg compileList -> fn if
	    [ fn call | return
	fi
	[ fn | return ( Lists like (defun...) and (defvar...) )
    fi

    ( Everything else evaluate to itself: )
    [ arg |
;
'eval export

( =====================================================================	)
( - shell -- Lisp readEvalPrint loop				        )

:   shell { -> }

    ( Ignore argblock: )
    ( ]pop )

    "Entering lisp shell.  Enter (system) to exit.\n" ,


    ( Select auxilliary package in )
    ( which to search for symbols: ) 
    @.lib["lisp"] --> @.compilerPackage

    ( readEvalPrint loop: )
    do{

	( Read one lisp value/expression: )
	[ | read |pop -> val ]pop

	( Exit loop on (system): )
	val cons? if
	    val cdr not if
		val car 'system = if
		    return
        fi  fi  fi
	
	( Evaluate: )
	[ val | eval 
	

	( Print return values: )
	|for v do{
	    [ v | prin1 ]pop
	    "\n" ,
	}
	]pop
    }
;
'shell export

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example
