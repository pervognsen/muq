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

( - 205-C-debugger.muf -- Muf debugger.					)
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
( Created:      95Apr28							)
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
( - Epigrams.								)

( Programming?								)
( It's very simple:							)
(   First you put the bugs in, one at a time, by hand.			)
(   Then you take them out again.					)
  
( "Just Say No To Bugs!"                                                )
(       -- Yellow Pages ad for Redi National Exterminators              )

( =====================================================================	)
( - Quotes								)

( 		"worse is better"					)
( 			-- Marc Andreesen"				)

( 	"We have, historically, definitely prioritized features		) 
(	over time and time over quality."				)
(		-- Marc Andreessen describing Netscape development.	)

( =====================================================================	)

( - Public fns								)

"DBUG" rootValidateDbfile pop
[ "debug" .db["DBUG"] | ]inPackage


( =====================================================================	)
( - disassembleCompiledFunction             				)

:   disassembleCompiledFunction { $ $ -> }
    -> s
    -> cfn

    cfn isACompiledFunction

    ( Do a nice disassembly of a compiled function for human consumption: )

    cfn.source -> fn
    fn function? if

	fn.name -> name
	name string? if
	    "name: "   s writeStream
	    name       s writeStream
	    "\n"       s writeStream
	fi

	fn.source -> src
	src  string? if
	    "source: " s writeStream
	    src        s writeStream
	    "\n"       s writeStream
	fi
    fi

    "constants:\n" s writeStream
    cfn compiledFunctionConstants[
	|for v i do{
	    [ "%2d: " i | ]print  s writeStream
	    v toDelimitedString s writeStream
	    "\n"                  s writeStream
	}
    ]pop
    
    "code bytes:" s writeStream
    cfn compiledFunctionBytecodes[    
	|for v i do{
	    i 15 logand 0 = if [ "\n%02x: " i | ]print s writeStream fi
	    [ "%02x " v | ]print                       s writeStream
	}
    ]pop
    "\n" s writeStream

    "code disassembly:\n"             s writeStream
    cfn compiledFunctionDisassembly s writeStream
;
'disassembleCompiledFunction export

( =====================================================================	)

( - Private fns								)

( =====================================================================	)
( - showEvent			             				)

: showEvent -> s -> v
    "\n+-----------< Event >-----------\n" s writeStream

    ( Over all keys and vals in vector: )
    v length -> len
    for i from 0 below len do{

	v[i] -> val

	( Different code for keys vs vals: )
	i 1 logand 0 = if

	    ( We're doing a key: )
	    val -> key

	else
	    ( We're doing a val: )

	    ( Show keyval pair to user: )
	    [ "| %s\t%s\n" key val | ]print  s writeStream
	fi
    }
    "+-------------------------------\n" s writeStream
;

( =====================================================================	)
( - showDisassembly		             				)

: showDisassembly -> s -> n

    "\n+---------< Unassembly >--------\n" s writeStream

    ( Find relevant 'normal' stackframe: )
    do{
        n @ getStackframe[ :kind |get -> kind ]pop
	kind :normal = if loopFinish fi
	n 1 - -> n
    }
	
    ( Find compiledFunction for this stackframe: )
    n @ getStackframe[ :compiledFunction |get -> cfn ]pop
    
    ( Disassemble it: )
    cfn s disassembleCompiledFunction
    "+-------------------------------\n" s writeStream
;

( =====================================================================	)
( - showRawStackframe		             				)

( Not currently used.  Absolutely raw dump of contents. )

# : showRawStackframe -> n
#     @.debugIo -> s
#     "Stackframe "     s writeStream
#     [ "%d" n | ]print s writeStream
#     ":\n"             s writeStream
#     n @ getStackframe[
# 	|for val i do{
# 	    "  " s writeStream
# 	    [ "%s" val | ]print  s writeStream
# 	    i 1 logand 1 = if "\n" else " " fi s writeStream
# 	}
#     ]pop
# ;

( =====================================================================	)
( - showStack			             				)

: showStack -> s -> n
    "\n+--------< Data Stack >---------\n" s writeStream
    depth 1- -> last
    0        -> first
    last n >= if last n - 1 + -> first fi

    ( Over all vals on stack: )
    for i from first upto last do{
	i dupBth -> val
	( Note: We need "val print" rather than just "val" )
	( only for the case where val is [ which fools     )
	( the '|' into seeing an empty block.              )
	i last != if
            [ "| %3d: %s\n" i val print | ]print     s writeStream
	else
            [ "| top: %s\n"   val print | ]print     s writeStream
	fi
    }
    "+-------------------------------\n"   s writeStream
;

( =====================================================================	)
( - showStackframe		             				)

:   showStackframe
    -> s
    -> n

    nil -> localVars
    [ "\n+-------< Stackframe %d >--------\n" n | ]print s writeStream
    n @ getStackframe[

	( Over all keys and vals in block: )
	|for val i do{

	    ( Different code for keys vs vals: )
	    i 1 logand 0 = if

		( We're doing a key: )
		val -> key

	    else
		( We're doing a val. First,   )
		( examine saved key.          )

		( Keys are normally keywords, )
		( but local variables instead )
		( get integer keys:           )
		key integer? if

		    localVars if
			( Look up name of var:    )
			localVars[key] -> key

			( Compiler-generated var  )
			( names are supposed to   )
			( start with a blank. We  )
			( want to ignore them. We )
			( flag key to be ignored  )
			( by setting it to NIL:   )
			key string? if
			    key length 0 != if
				key[0] ' ' = if
				    nil -> key
				fi
			    else
				nil -> key
			    fi
			else
			    nil -> key
			fi
		    fi
		fi

		( Do nothing if key has been set to NIL: )
		key if

		    ( If key is :compiledFunction, we   )
		    ( need to fish the localVariables   )
		    ( name vector out of it:             )
		    key :compiledFunction = if
			val.source -> function
			function.localVariableNames -> localVars
		    fi

		    ( Show keyval pair to user: )
		    [ "| %s\t%s\n" key val | ]print  s writeStream
		fi
	    fi
	}
    ]pop
    "+-------------------------------\n" s writeStream
;

( =====================================================================	)
( - showStacktrace		             				)

:   showStacktrace { $ $ -> }
    -> s
    -> n

    nil -> localVars
    "\n+--------< Stacktrace >----------\n" s writeStream

    ( We want "called from" on all but first: )
    "Stopped at:" -> prefix

    ( Over all stackframes starting at given one: )
    for i from n downto 0 do{

	i @ getStackframe[

	    ( Ignore all but :NORMAL stackframes: )
	    :kind |get :normal = not if ]pop loopNext fi

	    ( Get compiledFunction: )
	    :compiledFunction |get -> compiledFunction

	    ( Get matching function: )
	    compiledFunction.source -> function

	    ( Get function's name for printout: )
	    function.name -> fnName

	    ( Get program counter for frame: )
	    :programCounter |get -> programCounter

	    ( Get line number corresponding to program counter: )
	    programCounter function programCounterToLineNumber -> line

	    ( Print summary of the frame: )
	    line if
		[   "| %s line %3d in file (%3d in fn) pc %03x in '%s'\n"
		    prefix 
		    function.fnLine line 1 + +
		    line 1 +
		    programCounter
		    fnName
		| ]print s writeStream

		"called from" -> prefix
	    fi
	]pop
    }
    "+--------------------------------\n" s writeStream
;

( =====================================================================	)
( - showRestarts		             				)

: showRestarts -> stream

    ( Print list of available restarts: )
    "+---------< Restarts >----------\n" stream writeStream
    0 -> i
    nil computeRestarts[
	|length -> len
	|for r do{

	    ( Locate the restart: )
	    r getRestart
	    -> name
	    -> fn
	    -> tFn
	    -> iFn
	    -> rFn
	    -> data
	    -> id

	    ( Ignore non-interactive restarts: )

	    rFn string? if
		i 1 + -> i
		[ "| %d) %s\n" i rFn | ]print stream writeStream
	    fi

	    rFn callable? if
		i 1 + -> i
		[ "| %d) " i | ]print stream writeStream
		stream rFn
		"\n" stream writeStream
	    fi
	}
    ]pop
    "+-------------------------------\n" stream writeStream
;

( =====================================================================	)
( - showHelp			             				)

: showHelp -> stream
    "\n+-------------------< Debugger Help >---------------------\n"
    stream writeStream

    "|   You may continue via any of the numbered restarts,\n"
    stream writeStream

    "|   simply by typing that number and hitting ENTER.\n"
    stream writeStream

    "|\n"
    stream writeStream

    "|   You may type 'restarts' to list the restarts again.\n"
    stream writeStream

    "|\n"
    stream writeStream

    "|   (Other commands are also available, most of them\n"
    stream writeStream

    "|   of interest only to programmers.  Enter 'moreHelp'\n"
    stream writeStream

    "|   if you wish a list of them.)'\n"
    stream writeStream

    "+---------------------------------------------------------\n\n"
    stream writeStream
;

( =====================================================================	)
( - showMoreHelp		             				)

: showMoreHelp -> stream
    "\n+-------------------< Debugger Help >---------------------\n"
    stream writeStream

    "|   The debugger also accepts alphabetic commands,\n"
    stream writeStream

    "|   which may be abbreviated to a single letter:\n"
    stream writeStream

    "|       help:       General-user help.\n"
    stream writeStream

    "|       moreHelp:  Programmer help.\n"
    stream writeStream

    "|       up:         List stackframe above last one.\n"
    stream writeStream

    "|       down:       List stackframe below last one.\n"
    stream writeStream

    "|       event:      List event again.\n"
    stream writeStream

    "|       restarts:   List restarts again.\n"
    stream writeStream

    "|       stack N:    List top N data stack entries. (Default=20.)\n"
    stream writeStream

    "|       trace:      List stack trace (who called who).\n"
    stream writeStream

    "|       Unassemble: Unassemble fn for current stack frame.\n"
    stream writeStream

    "+---------------------------------------------------------\n\n"
    stream writeStream
;

( =====================================================================	)
( - showClue			             				)

: showClue -> stream
    "(Please enter a number, or else 'help' for help.)\n" stream writeStream
;

( =====================================================================	)

( - Public fns								)

( =====================================================================	)
( - mufDebugger		             				)

: mufDebugger { $ -> @ }   -> event
    @.debugIo            -> ioStream
    @ countStackframes 1 - -> maxStackframe
    maxStackframe          -> stackframe
    nil computeRestarts[ |length -> len ]pop

    ( We're given an event.  Primitive printout of it: )
    event ioStream showEvent

    ( Show restart options to user: )
    ioStream showRestarts

    ( Dispense one clue: )
    ioStream showClue

    ( Loop until user exits via a restart: )
    do{
	"debug>\n" ioStream writeStream

	( Read a restart choice from user: )
	do{
            ioStream readStreamLine pop trimString -> string

	    ( This serves to munch the empty )
	    ( line mufshell often leaves us: )
            string length 0 != until
	}

	( Handle "help" requests: )
        string[0] 'h' = if
	    ioStream showHelp
	    loopNext
	fi

	( Handle "moreHelp" requests: )
        string[0] 'm' = if
	    ioStream showMoreHelp
	    loopNext
	fi

	( Handle "up" requests: )
        string[0] 'u' = if
	    stackframe maxStackframe < if ++ stackframe fi
	    stackframe ioStream showStackframe
	    loopNext
	fi

	( Handle "down" requests: )
        string[0] 'd' = if
	    stackframe 0 > if -- stackframe fi
	    stackframe ioStream showStackframe
	    loopNext
	fi

	( Handle "event" requests: )
        string[0] 'c' = if
	    event ioStream showEvent
	    loopNext
	fi

	( Handle "restarts" requests: )
        string[0] 'r' = if
	    ioStream showRestarts
	    loopNext
	fi

	( Handle "stack" requests: )
        string[0] 's' = if
	    string " " substring? if
		string words[ |pop -> string ]pop
		string stringInt -> n
		n 1 < if 1 -> n fi
	    else
		20 -> n
	    fi
	    n ioStream showStack
	    loopNext
	fi

	( Handle "trace" requests: )
        string[0] 't' = if
	    maxStackframe ioStream showStacktrace
	    loopNext
	fi

	( Handle "Unassemble" requests: )
        string[0] 'U' = if
	    stackframe ioStream showDisassembly
	    loopNext
	fi

	( Handle random commands  )
	( by reprinting restarts: )
	string[0] digitChar? not if
	    ioStream showRestarts
	    ioStream showClue
	    loopNext
	fi


	( Handle integer restart number requests: )

	string stringInt -> result

	result 0 <= if
	    "Sorry, choice must be at least 1\n"
	    @.debugIo writeStream
	    loopNext
	fi

	result len > if
	    [ "Sorry, choice must be at most %d\n" len
	    | ]print  @.debugIo writeStream
	    loopNext
	fi

        ( Invoke selected restart: )
	0 -> i
	nil computeRestarts[
	    |for r do{
		( Locate the restart: )
		r getRestart
		-> name
		-> fn
		-> tFn
		-> iFn
		-> rFn
		-> data
		-> id

		rFn string? if
		    i 1 + -> i
		fi

		rFn callable? if
		    i 1 + -> i
		fi

		i result = if
		    event vals[
		    r invokeRestartInteractively
		fi
	    }
	]pop	( Should never get here. )
    }
;
'mufDebugger export
'mufDebugger --> .u["root"]$s.debugger
'mufDebugger --> .etc.jb0.debugger

( =====================================================================	)

( - File variables							)


( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example
