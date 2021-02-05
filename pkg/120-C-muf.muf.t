@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Muf Compiler, Muf Compiler Overview, Muq Internals Wrapup, Top
@chapter Muf Compiler

@menu
* Muf Compiler Overview::
* Muf Compiler Source::
* Muf Compiler Wrapup::
@end menu

@c
@node Muf Compiler Overview, Muf Compiler Source, Muf Compiler, Muf Compiler
@section Muf Compiler Overview

This chapter documents the in-db (@sc{muf}) implementation of the
@sc{muf} compiler, and includes all the source.  You most definitely
do not need to read or understand this chapter in order to write
application code in @sc{muf}, but you may find it interesting if you
are curious about the internals of the @sc{muf} compiler, or are
interested in writing a Muq compiler of your own.

@c
@node Muf Compiler Source, Muf Compiler Wrapup, Muf Compiler Overview, Muf Compiler
@section Muf Compiler Source

Here it is, the complete source.

Eventually, I intend to have the source more
intricately formatted in literate-programming
style, but for now you get it in one great glob:

@example  @c

( - 120-C-muf.muf -- Compile "Multi-User Forth".			)
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
( Created:      96May26							)
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

( "Notice that most things that call themselves sciences, aren't:	)
(  Military science, political science, computer science...		)
(  Real sciences don't need to call themselves that:			)
(  Physics, biology..."	*grin*						)
(                              -- Fred Brooks, 94Jan27 talk at UW.	)
(									)
(  NB: Fred is father to IBM's 360, OS/360, the computer graphics dept	)
(  at University of  North Carolina, Chapel Hill -- dept head for 20 	)
(  years -- and of the virtual reality program there.  No hacker should )
(  miss reading Fred's "The Mythical Man-Month". -- Cynbe		)

( =====================================================================	)
( - Select MUF Package:							)

"muf" inPackage

( =====================================================================	)
( - Types -								)



( =====================================================================	)
( - compileDoubleQuote -- Compile token starting with "			)

:   compileDoubleQuote { $ $ -> } -> ctx -> mode
    [ ctx.mss '"' '\\' | |scanTokenToChar
    |pop --> ctx.line	( Line number string started on. )
    |readTokenChars	( Get string chars as block.     )
    |popp               ( Drop terminal doubleQuote.    )
    |doCBackslashes   ( Expand '\' '0' to \0 &tc	 )
    ]join		( Reduce result to a string.	 )
    ctx.asm assembleConstant ( Assemble string as const )
;
'compileDoubleQuote export

( =====================================================================	)
( - compileSymbol -- Compile given symbol				)

:   compileSymbol { $ $ $ -> }   -> ctx   -> mode   -> sym

    ctx.asm -> asm

    ( Unpack 'mode' bitbucket: )
    mode compile:modeSet     logand 0 != -> gotSet	( --> path	)
    mode compile:modeGet     logand 0 != -> gotGet	( path		)
    mode compile:modeDel     logand 0 != -> gotDel	( delete: path	)
    mode compile:modeFn      logand 0 != -> gotFn	( #'path	)
    mode compile:modeQuote   logand 0 != -> gotQuote	( 'path		)
    mode compile:modeConst   logand 0 != -> gotConst	( -->constant	)
    mode compile:modeInc     logand 0 != -> gotInc	( ++		)
    mode compile:modeDec     logand 0 != -> gotDec	( --		)

    ( Handle function calls: )
    gotQuote not
    gotFn    not and
    gotGet       and if
	sym symbolFunction -> cfn
	cfn compiledFunction? if
	    cfn.compileTime? if
( "compileSymbol doing compileTime fn...\n" , )
		ctx cfn call{ $ -> }
		return
	    else
( "compileSymbol assembling call...\n" , )
		sym asm assembleCall
		return
	    fi
        fi
    fi

    ( Handle loads: )
    gotGet if

	( Save an instruction by loading consts )
	( directly at runtime, instead of doing )
	( fetch from symbol:                    )
	sym constant?   gotQuote not   and if
( "compileSymbol assembling const...\n" , )
	    sym symbolValue asm assembleConstant
	    return
        fi

	( Assemble code to load symbol onto stack: )
	sym asm assembleConstant

	( Handle #'xxx loads of function value: )
	gotFn if
( "compileSymbol assembling symbolFunction...\n" , )
	    'symbolFunction asm assembleCall
	    return
	fi

	( Handle vanilla loads of symbol value: )
	gotQuote not if
( "compileSymbol assembling symbolValue call...\n" , )
	    'symbolValue asm assembleCall	    
	fi
	return
    fi


    ( Handle stores: )
    gotSet if

( "compileSymbol assembling store...\n" , )
	( Sanity check: )
        gotQuote if "Can't do   exp --> 'sym" simpleError fi

	( Deposit code to load symbol on stack: )
	sym asm assembleConstant

	( Deposit code to do appropriate kind of store: )
	gotFn    if 'setSymbolFunction asm assembleCall
	    return	
        fi
	gotConst if 'setSymbolConstant asm assembleCall 
	else         'setSymbolValue    asm assembleCall fi

	return	
    fi

    ( Handle ++ and --: )
    gotInc gotDec or if
( "compileSymbol assembling inc/dec...\n" , )
	( Sanity check: )
        gotQuote if "Can't do   ++ 'sym" simpleError fi

	( Load symbol onto stack: )
	sym asm assembleConstant

	( Get value of symbol: )
	'symbolValue asm assembleCall	    

	( Get constant 1: )
	1 asm assembleConstant

	( Bump it: )
	gotInc if '+ else '- fi asm assembleCall

	( Load symbol onto stack again: )
	sym asm assembleConstant

	( Store new value into it: )
	'setSymbolValue asm assembleCall

	return	
    fi


    gotDel if
( "compileSymbol assembling delete...\n" , )
	"``delete: symbol'' not supported" simpleError
    fi

    "internal err" simpleError
;

( =====================================================================	)
( - compileHash -- Compile token starting with #			)

:   compileHash { $ $ -> $ } -> ctx -> mode

    [ ctx.mss '\\' | |scanTokenToWhitespace
    |pop --> ctx.line    ( Line number token started on.  )
    |readTokenChars   ( Get string chars as block.     )

    ( # Followed by whitespace is comment to end of line: )
    |length 0 = if
	]pop
	[ ctx.mss '\n' | |scanTokenToChar ]pop
	[ ctx.mss | |unreadTokenChar ]pop    
	t return
    fi

    ( Should check here for #: yielding uninterned symbol )

    ( Get 1st char, check it is '    )
    |shift -> c
    c '\'' != if
	c |unshift ]join
	"Unrecognized syntax: #" swap join simpleError
    fi

    ( Complain if using number syntax to name a function: )
    |backslashesToHighbit
(   |downcase )
    |potentialNumber? if
	]join
	"#'<number> isn't supported. Try using || or \\ quotes: #'"
	swap join simpleError
    fi

    ( Look up given symbol: )
    mode compile:modeSet   logand 0 != if
	ctx.package ]makeSymbol -> sym
    else 
        ctx.package |findSymbol? -> sym not if
	    ]join "No such symbol: #'" swap join simpleError
        fi
	]pop
    fi
    sym   mode compile:modeFn logior   ctx   compileSymbol
    nil
;
'compileHash export

( =====================================================================	)
( - compileVanilla -- Compile token not starting with # ' or "		)

:   compileVanilla { $ $ -> }   -> ctx   -> mode
    ctx.asm -> asm

    ( Read to next whitespace [ ] $ . or ' )
    [ ctx.mss
      ( Special hack mostly so --> and -> parse as one token: )
      mode compile:modeSubex logand 0 != if "[]$.'" else "\n\r\t [$.'" fi
      '\\'
    | |scanTokenToChars
    |pop --> ctx.line   ( Line number token started on.  )
    |readTokenChars   ( Get token chars as block.      )
    |pop -> nextchar

    ( Special case supporting ' ': )
    mode compile:modeQuote logand 0 != if
        |length 0 = if
	    nextchar ' ' =
            if
		( Read a token char: )
		[ ctx.mss |
		    |readTokenChar
		    |pop -> lineloc		lineloc --> ctx.line
		    |pop -> byteloc		lineloc ctx.fnLine - --> ctx.asm.lineInFn
		    |pop -> c
		]pop
		c '\'' = not if
		    "Bad syntax following singleQuote (')" simpleError
		fi
		nextchar ctx.asm assembleConstant ( Assemble char as const )
		]pop
		return
            fi
	    nextchar '$'  =
	    nextchar '.'  = or
	    nextchar '['  = or
	    nextchar ']'  = or
	    nextchar '\'' = or
            if
		( Read a token char: )
		[ ctx.mss |
		    |readTokenChar
		    |pop -> lineloc		lineloc --> ctx.line
		    |pop -> byteloc		lineloc ctx.fnLine - --> ctx.asm.lineInFn
		    |pop -> c
		]pop
		c '\'' = if
		    nextchar ctx.asm assembleConstant ( Assemble as const )
		    ]pop
		    return
		fi
		[ ctx.mss | |unreadTokenChar ]pop    
    fi  fi  fi

    ( Icky special case supporting '[' : )
    |length 0 =
    nextchar '[' =
    and if
	]pop
	[ ctx.mss
	  mode compile:modeSubex logand 0 != if "[$.'" else "\n\r\t $.'" fi
	  '\\'
	| |scanTokenToChars
	|pop --> ctx.line   ( Line number token started on.  )
	|readTokenChars   ( Get token chars as block.      )
	|pop -> nextchar
	'[' |unshift
    fi
    ( Icky special case supporting tokens ending in '[' : )
    nextchar '[' = if
	( Read a token char: )
	[ ctx.mss |
	    |readTokenChar
	    |pop -> tmplineloc
	    |pop -> tmpbyteloc	
	    |pop -> tmpnextchar
	]pop
	tmpnextchar ' '  =
	tmpnextchar '\t' = or
	tmpnextchar '\r' = or
	tmpnextchar '\n' = or if
	    '[' |push
            tmpnextchar -> nextchar
            tmplineloc	-> lineloc
            tmpbyteloc	-> byteloc
            lineloc --> ctx.line
            lineloc ctx.fnLine - --> ctx.asm.lineInFn
        else
	    [ ctx.mss | |unreadTokenChar ]pop
	fi
    fi

    ( Special case supporting 'a' '\0' '\r' &tc: )
    nextchar '\'' = if
        mode compile:modeQuote logand 0 != if
	    |doCBackslashes   ( Expand '\' '0' to \0 &tc	 )
	    |length 1 != if
		"Char consts must contain exactly one char" simpleError
	    fi
	    |pop -> c ]pop c	( Reduce result to a single char. )
	    ctx.asm assembleConstant ( Assemble char as const )
	    return
    fi  fi


    [ ctx.mss | |unreadTokenChar ]pop    

( mode compile:modeQuote logand 0 != if )
( "compileVanilla/quote: " , |dup[ ]join , " ...\n" , fi )
    |backslashesToHighbit
(   |downcase )

    ( If not at end of path  )
    ( suppress store/delete: )
    nextchar whitespace?
    nextchar '>' =
    or not if
	mode compile:modeQuote logand 0 = if
	    compile:modeGet -> mode
	else
	    compile:modeGet compile:modeQuote logior -> mode
	fi
    fi

    ( Numbers are a special case: )
    |potentialNumber? if
        nextchar '.' = if
	    ( Read rest of potential number: )
	    [ ctx.mss
	      "\n\r\t []$/'"
	      '\\'
	    | |scanTokenToChars
	    |popp
	    |readTokenChars   ( Get token chars as block.      )
	    |pop -> nextchar
	    |backslashesToHighbit
	    ]|join	
	    [ ctx.mss | |unreadTokenChar ]pop    
( "number = '" , |for i do{ i , ", " , } "'\n" , )
        fi
	]makeNumber -> val -> typ
( "val = '" , val , "'\n" , )
( "typ = '" , typ , "'\n" , )
	typ lisp:lispBadnum = if "bad number syntax" simpleError fi
	val asm assembleConstant
	return
    fi

    ( Is it a local variable? )
    ctx compile:|findLocal?  -> val  -> typ  -> nam  -> pos
    pos
    mode compile:modeQuote logand 0 =
    and if
	typ case{

	on: :var
	    pos ctx.symbolsSp >= if
		mode compile:modeGet logand 0 != if
		    val asm assembleVariableGet
		    ]pop
		    return
		fi
		mode compile:modeSet logand 0 != if
		    "Use -> not --> to set local variables." simpleError
		fi
		mode compile:modeInc logand 0 != if
		    val asm assembleVariableGet
		    1   asm assembleConstant
		    '+ asm assembleCall
		    val asm assembleVariableSet
		    ]pop
		    return
		fi
		mode compile:modeDec logand 0 != if
		    val asm assembleVariableGet
		    1   asm assembleConstant
		    '- asm assembleCall
		    val asm assembleVariableSet
		    ]pop
		    return
		fi
	    fi

	on: :fn
	    val not if
		( Recursive call to function being compiled.  )
		( Create a symbol to represent function, and  )
		( indirect call through it. compileSemi will )
		( fix up the function slot of the symbol:     )
		makeSymbol -> val
		val --> ctx.symbols[pos]
            fi
	    val callable? if
		val asm assembleCall
		]pop
		return
	    fi
	    ]join
            "Compiler bug: Local fn has unknown val type: "
            swap join simpleError

	on: :tag
	    val asm assembleLabel
	    ]pop
	    return

	else:
	    ]join "Compiler bug: Local has unknown type: " swap join simpleError
	}
    fi

    ( Here's an ugly specialCase hack for ']' )
    ( which is a normal user fn except for     )
    ( having to match '[':                     )
    nil -> rbracket
    "]"    |= if t -> rbracket fi
    "]l"   |= if t -> rbracket fi
    "]v"   |= if t -> rbracket fi
    "]i16" |= if t -> rbracket fi
    "]i32" |= if t -> rbracket fi
    "]f32" |= if t -> rbracket fi
    "]f64" |= if t -> rbracket fi
    rbracket if
	mode compile:modeQuote   logand 0 = if   ( Don't fire on '] export )
	    ctx compile:popLbracket pop
    fi  fi

    ( Find/create symbol: )
    mode compile:modeSet   logand 0 !=
    mode compile:modeQuote logand 0 != or if
	ctx.package ]makeSymbol -> sym
    else
        ctx.package |findSymbol? -> sym not if
	    ]join "Undefined identifier: " swap join simpleError
	fi
	]pop
    fi

    ( Compile symbol op: )
    sym mode ctx compileSymbol
;
'compileVanilla export

( =====================================================================	)
( - compilePath -- code for $ . and [...] parts of paths		)

:   compilePath { $ $ -> ! } -> ctx -> mode ( '!' for recursion )
    ctx.asm -> asm

    ( Find non-whitespace: )
    do{
	( Read a token char: )
	[ ctx.mss |
	    |readTokenChar
	    |pop -> lineloc	lineloc --> ctx.line
	    |pop -> byteloc	lineloc ctx.fnLine - --> ctx.asm.lineInFn
	    |pop -> c
	]pop

	( We ignore whitespace, except that we    )
	( return and prompt if we find a newline: )
	c '\n' = if   t --> ctx.ateNewline   return   fi

	c whitespace? not until

	( Eat all the whitespace: )
	[ ctx.mss | |scanTokenToNonwhitespace
	|pop -> seenEoln
	]pop
	seenEoln if   t --> ctx.ateNewline   return   fi
    }

    ( Compile part of path preceding )
    ( first $ . or [ (if any):       )
    c case{

    on: '$'
	( Path starting with null name of root: )
        'root asm assembleCall
	[ ctx.mss | |unreadTokenChar ]pop    

    on: '.'
	( Path starting with null name of root: )
        'root asm assembleCall
	[ ctx.mss | |unreadTokenChar ]pop    

    on: '"'  mode ctx compileDoubleQuote
    on: '\''
	( Parse normally, except    )
        ( with modeQuote flag set: )
        mode compile:modeQuote logior ctx compileVanilla

    on: '#'  mode ctx compileHash if t --> ctx.ateNewline return fi
    else:
	[ ctx.mss | |unreadTokenChar ]pop    
        mode ctx compileVanilla
    }

    ( Compile parts of path following the first  )
    ( $ . or [ -- done when we reach whitespace: )
    do{
        ( Read a token char: )
        [ ctx.mss |
	    |readTokenChar
	    |pop -> lineloc	lineloc --> ctx.line
	    |pop -> byteloc	lineloc ctx.fnLine - --> ctx.asm.lineInFn
	    |pop -> c
        ]pop

	( Whitespace or '>' means we're done: )
        c whitespace?
        c '>' = or     ( buggo, phasing out > )
        c ']' = or if
	    [ ctx.mss | |unreadTokenChar ]pop
	    return
	fi


	( Figure out whether we are about to read )
	( the public, hidden, admins, or system   )
	( part of the object.         We do this  )
	( by assuming PUBLIC unless prefix is one )
	( of $h[idden] $s[system]...              )
	'get     -> getVal
	'set     -> setVal
	'delKey -> delVal
        c '$' = if 
	    [ ctx.mss ".[" | |scanTokenToChars
	    |popp		( Line number )
	    |readTokenChars
	    |pop   -> c  ( Save terminal . or [ )
(	    |downcase )
	    |shift -> c1 ( Get first char     )
	    ]pop	 ( Buggo, should check rest of field )

	    c1 case{
	    on: 'a'
		'adminsGet     -> getVal
		'adminsSet     -> setVal
		'adminsDelKey -> delVal
	    on: 'h'
		'hiddenGet     -> getVal
		'hiddenSet     -> setVal
		'hiddenDelKey -> delVal
(	    on: 'm' )
(		'methodGet     -> getVal )
(		'methodSet     -> setVal )
(		'methodDelKey -> delVal  )
	    on: 'p'
		'get            -> getVal
		'set            -> setVal
		'delKey        -> delVal
	    on: 's'
		'systemGet     -> getVal
		'systemSet     -> setVal
		'systemDelKey -> delVal
	    else:
		"Bad $ field" simpleError
	    }
	fi

	c case{

	on: '.'
	    ( Read keyword chars: )

	    ( Read to next whitespace [ ] $ or . )
	    [ ctx.mss
	      ( Special hack mostly so --> and -> parse as one token: )
              mode compile:modeSubex logand 0 != if
                  "[]$."
              else
                  "\n\r\t [$."
              fi
              '\\'
            | |scanTokenToChars
	    |popp               ( Line number                    )
	    |readTokenChars   ( Get token chars as block.      )
	    |pop -> nextchar
	    [ ctx.mss | |unreadTokenChar ]pop    

	    ( Handle special cases like . by itself: )
	    |length 0 = if
		nextchar whitespace? if ]pop return fi
		( We currently don' allow null path components: )
		"bad syntax after ." simpleError
	    fi

	    ( Add initial ':' for keyword syntax: )
	    ':' |unshift

	    ( Find/make keyword: )
	    |backslashesToHighbit
(	    |downcase )
	    ctx.package ]makeSymbol -> sym

	    ( Deposit code to put keyword on stack: )
	    sym asm assembleConstant


        on: '['
	    ( Compile subPath recursively: )
	    compile:modeGet compile:modeSubex logior ctx compilePath

	    ( Eat following ']', error if missing: )
	    [ ctx.mss |
		|readTokenChar
		|pop -> lineloc		lineloc --> ctx.line
		|pop -> byteloc		lineloc ctx.fnLine - --> ctx.asm.lineInFn
		|pop -> c
	    ]pop
	    c ']' != if "Couldn't find ']' matching '['" simpleError fi

	    ( Validate nextchar: )
	    [ ctx.mss |
		|readTokenChar
		|pop -> lineloc		lineloc --> ctx.line
		|pop -> byteloc		lineloc ctx.fnLine - --> ctx.asm.lineInFn
		|pop -> nextchar
	    ]pop
	    [ ctx.mss | |unreadTokenChar ]pop    

	else:
	    "Unrecognized path syntax" simpleError
        }

	( Deposit appropriate load/store/delete: )

	( If we're not at end of path,  )
	( we always want to do a fetch: )
	nextchar whitespace? not if
	    getVal asm assembleCall
	    loopNext
	fi

	( We are at end of path, so pick )
	( load/store/delete per mode:    )
	mode compile:modeGet logand 0 != if
	    getVal asm assembleCall
	    return
	fi
	mode compile:modeSet logand 0 != if
	    setVal asm assembleCall
	    return
	fi
	mode compile:modeInc logand 0 != if
	    'dup2nd asm assembleCall
	    'dup2nd asm assembleCall
	    getVal   asm assembleCall
	    1         asm assembleConstant
	    '+       asm assembleCall
	    'rot     asm assembleCall
	    'rot     asm assembleCall
	    setVal   asm assembleCall
	    return
	fi
	mode compile:modeDec logand 0 != if
	    'dup2nd asm assembleCall
	    'dup2nd asm assembleCall
	    getVal   asm assembleCall
	    1         asm assembleConstant
	    '-       asm assembleCall
	    'rot     asm assembleCall
	    'rot     asm assembleCall
	    setVal   asm assembleCall
	    return
	fi
	mode compile:modeDel logand 0 != if
	    delVal asm assembleCall
	    return
	fi
	"Internal err: bad mode" simpleError
    }
;
'compilePath export

( =====================================================================	)
( - ]reportCompileError -- to print line # &tc				)

:   ]reportCompileError { [] -> [] ! }
    :formatString |get -> msg    
    ]pop

    @.compiler   -> ctx
    ctx.mss.twin -> mss
    mss.line     -> line

    "***** " , line 1+ , ": " , msg , "\n" ,

    'abort invokeRestart
;
']reportCompileError export

( =====================================================================	)
( - compileFile -- Simple muf file compiler.				)

:   compileFile { -> ? }

    ( This is basically just like muf:]shell )
    ( except for not issuing any prompts:    )

    ( Get stream to read from: )
    @.standardInput -> mss
    mss isAMessageStream

    [   :ephemeral t
        :mss       mss
        :package   @.lib["muf"]
        :outermost t
    | 'compile:context ]makeStructure -> ctx

    makeFunction -> fun


    (      -- BEGIN BOILERPLATE --        )

    ( Establish a restart letting users   )
    ( to kill the job from the debugger:  )
    [   :function :: { -> ! } nil endJob ;
        :name 'endJob
        :reportFunction "Terminate job."
    | ]withRestartDo{               ( 1 )

    ( Establish a handler letting users   )
    ( terminate a job with a signal       )
    ( -- via 'killJob' say:              )
    [ .e.kill :: { [] -> [] ! } :why |get endJob ;
    | ]withHandlerDo{               ( 2 )

    ( Establish a restart letting users   )
    ( return to the main shell prompt     )
    ( from the debugger:                  )
    [   :function :: { -> ! }  'abrt goto ;
	:name 'abort
	:reportFunction "Return to main mufShell prompt."
    | ]withRestartDo{               ( 3 )

    ( Establish a handler letting users   )
    ( abort a job with a signal           )
    ( -- via 'abortJob' say:             )
    [ .e.abort :: { [] -> [] ! } 'abort invokeRestart ;
    | ]withHandlerDo{               ( 4 )

    withTag abrt do{       ( 8 ) ( Trap compile errs etc    )
    abrt                          ( Continuation from errors )
    (       -- END BOILERPLATE --         )


    ( Establish handler to report errors: )
    [ .e.error ( simpleError or serverError, presumably )
      ']reportCompileError
    | ]withHandlersDo{              ( 5 )


    ( Central readEvalPrint loop: )
    do{
	( Save compile context where )
        ( user code &tc can find it: )
	ctx --> @.compiler

	( Reset assembler for new function: )
        [ ctx | compile:resetContext ]pop

	( Loop accumulating tokens until we reach )
	( an \n with no control structures open:  )
	nil --> ctx.ateNewline
	do{
	    compile:modeGet ctx compilePath
	    ctx.syntax length 0 =   ctx.ateNewline   and until
	}

	ctx.asm.bytecodes 0 != if

	    ( Complete assembly: )
	    t 0 fun ctx.asm finishAssembly -> cfn

	    ( Plug source and executable into fn: )
	    ""   --> fun.source
	    cfn  --> fun.executable

	    ( Execute compiled function: )
	    cfn call{ -> }
	fi
    }

    } ( 8 )
    } ( 5 )
    } ( 4 )
    } ( 3 )
    } ( 2 )
    } ( 1 )
;
'compileFile export


( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

@c
@node Muf Compiler Wrapup, Function Index, Muf Compiler Source, Muf Compiler
@section Muf Compiler Wrapup

This completes the in-db @sc{muf}-compiler chapter.  If you have
questions or suggestions, feel free to email cynbe@@sl.tcp.com.
