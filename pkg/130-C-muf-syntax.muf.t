@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Muf Syntax Fns, Muf Syntax Fns Overview, Muq Compiler Wrapup, Top
@chapter Muf Compiler

@menu
* Muf Syntax Fns Overview::
* Muf Syntax Fns Source::
* Muf Syntax Fns Wrapup::
@end menu

@c
@node Muf Syntax Fns Overview, Muf Syntax Fns Source, Muf Syntax Fns, Muf Syntax Fns
@section Muf Syntax Fns Overview

This chapter documents the syntax functions for
the in-db (@sc{muf}) implementation of the
@sc{muf} compiler, and includes all the source for
them.  You most definitely do not need to read or
understand this chapter in order to write
application code in @sc{muf}, but you may find it
interesting if you are curious about the internals
of the @sc{muf} compiler, or are interested in
writing a Muq compiler of your own.

@c
@node Muf Syntax Fns Source, Muf Syntax Fns Wrapup, Muf Syntax Fns Overview, Muf Compiler
@section Muf Syntax fns Source

Here it is, the complete source.

Eventually, I intend to have the source more
intricately formatted in literate-programming
style, but for now you get it in one great glob:

@example  @c

( - 130-C-muf-syntax.muf -- Syntax for "Multi-User Forth".		)
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
( Created:      96Jun08							)
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

( 	"Managing programmers is like herding cats"			)


( =====================================================================	)
( - Select MUF Package:							)

"muf" inPackage

( =====================================================================	)
( - Types -								)



( =====================================================================	)
( - Public fns -							)



( =====================================================================	)
( - readTokenToWhitespace[ -- Parse token, return as block		)

:   readTokenToWhitespace[ { $ -> [] }   -> ctx
    ( Eat whitespace: )
    [ ctx.mss | |scanTokenToNonwhitespace ]pop

    ( Read name of variable: )
    [ ctx.mss
    | |scanTokenToWhitespace
    |popp 	        ( Line number                    )
    |readTokenChars   ( Get token chars as block.      )

    ( Canonicalize token: )
    |backslashesToHighbit
(   |downcase )
;
'readTokenToWhitespace[ export

( =====================================================================	)
( - readLocalVarName[ -- Parse local var name, return as block		)

:   readLocalVarName[ { $ -> [] }   -> ctx
    ( Eat whitespace: )
    [ ctx.mss | |scanTokenToNonwhitespace ]pop

    ( Read name of variable: )
    [ ctx.mss "\n\r\t [$." '\\'
    | |scanTokenToChars
    |popp	        ( Line number                    )
    |readTokenChars   ( Get token chars as block.      )
    |pop -> nextchar
    [ ctx.mss | |unreadTokenChar ]pop    

    ( Catch err of exp  -> a.b )
    ( in stead  of exp --> a.b )
    nextchar whitespace? not if
	"Can't use [$. in local var names. (Did you want --> not -> ?)"
	simpleError
    fi

    ( Canonicalize var name: )
    |backslashesToHighbit
(   |downcase )
;
'readLocalVarName[ export

( =====================================================================	)
( - ]makeLocalVar -- Parse local var name, find/create slot for it	)

:   ]makeLocalVar { [] $ -> $ }   -> ctx

    ( Find/assign slot for variable: )
    ctx compile:|findLocal?  -> val  -> typ  -> nam  -> pos
    pos if
        pos ctx.symbolsSp < if
            nil -> pos
    fi  fi
    pos if
	( Buggo, need to check that it is in scope )
	val integer? not if
	    ]join "Not a variable: " swap join simpleError
	fi
	]pop
    else
	( New local variable:    )
        ( Assign it a slot and   )
	( save on symbols stack: )
	]join -> varName
	varName ctx.asm assembleVariableSlot -> val

        varName :var val ctx compile:noteLocal
    fi

    ( Return variable slot: )
    val
;
']makeLocalVar export

( =====================================================================	)
( - makeLocalVar -- Parse local var name, find/create slot for it	)

:   makeLocalVar { $ -> $ }   -> ctx

    ( Read name of var: )
    ctx readLocalVarName[

    ( Convert to slot: )
    ctx ]makeLocalVar -> slot

    ( Return variable slot: )
    slot
;
'makeLocalVar export

( =====================================================================	)
( - parameter: -- 		 					)

: parameter: { $ -> }   -> ctx   compileTime
    ctx makeLocalVar pop
;
'parameter: export

( =====================================================================	)
( - parseArity -- Read type signature 					)

: parseArity { $ -> $ $ }   -> ctx

    ( Parse and reduce arity: )    

    ( Initialize components: )
    0 -> blksGet    0 -> blksRet
    0 -> argsGet    0 -> argsRet

    nil -> force

    arityNormal -> typ

    ( Read first part, up to '->': )
    do{
	
	( Eat whitespace: )
	[ ctx.mss | |scanTokenToNonwhitespace ]pop

	( Read next token.  Since strings of 0-3 )
	( chars are in-pointer, reducing [] $ -> )
	( to strings generates no garbage:       )
	[ ctx.mss |
        |scanTokenToWhitespace
	|popp		 ( lineloc )
	|readTokenChars   ( Get token chars as block.      )
	|backslashesToHighbit	( Good habit.	)
(	|downcase	)	( "         "	)
	]join -> token

	token case{
	on: "$"     ++ argsGet
	on: "[]"    ++ blksGet
	    argsGet 0 != if "[]s must precede $s" simpleError fi
	on: "->"    loopFinish
	else:
	    "Unexpected token in arity declaration: " token join simpleError
	}
    }

    ( Read second part, up to '}': )
    do{
	[ ctx.mss | |scanTokenToNonwhitespace ]pop

	[ ctx.mss |
        |scanTokenToWhitespace
	|popp ( lineloc )
	|readTokenChars
	|backslashesToHighbit
(	|downcase )
	]join -> token

	token case{
	on: "$"     ++ argsRet
	on: "[]"    ++ blksRet
	    argsRet 0 != if "[]s must precede $s" simpleError fi
	on: "}"    loopFinish
	on: "!"   t -> force
	on: "?"   arityQ           -> typ
	on: "["   arityStartBlock -> typ
	on: "|"   arityEndBlock   -> typ
	on: "]"   arityEatBlock   -> typ
	on: "@"   arityExit        -> typ
	    blksRet 0 != if "'@' precludes returning '[]'" simpleError fi
	    argsRet 0 != if "'@' precludes returning '$'"  simpleError fi
	else:
	    "Unexpected token in arity declaration: " token join simpleError
	}
    }

    ( Compute overall arity: )
    blksGet argsGet blksRet argsRet typ implodeArity -> arity

    ( Return computed arity: )
    arity
    force
;
'parseArity export

( =====================================================================	)
( - { -- Compile type signature 					)

:   compile-{ { $ -> }   -> ctx   compileTime

    ( Parse and reduce arity: )    
    ctx parseArity -> force -> arity

    ( Stash arity declaration for )
    ( later use by compileSemi:  )
    arity --> ctx.arity
    force --> ctx.force
;
'compile-{ export
"{" intern -> sym   sym export   #'compile-{ --> sym.function


( =====================================================================	)
( - parseLambdaList -- Read lambdaList style type signature		)

:   parseLambdaList { $ -> $ ! }   -> oldCtx

    ( ----------------------------------------------------------------- )
    ( Basic syntax looks like:						)
    (									)
    (     {[ R0 R1 ... ; O0 o0 O1 o1 ... ; K0 k0 K1 k1 ... ]}		)
    (									)
    ( Where:								)
    (									)
    (   R0 R1 ...    First, second &tc required parameters.		)
    (   O0 O1 ...    First, second &tc optional parameters.		)
    (   o0 o1 ...    Default vals  for optional parameters.		)
    (   K0 K1 ...    First, second &tc keyword  parameters.		)
    (   k0 k1 ...    Default vals  for keyword  parameters.		)
    (									)
    ( ----------------------------------------------------------------- )

    ( Allocate a new context in which to compile fn: )
    oldCtx.symbols -> symbols
    symbols length2 -> symbolsSp
    [   :ephemeral  t
        :mss        oldCtx.mss
        :package    @.lib["muf"]
        :symbols    symbols
        :symbolsSp symbolsSp
        :syntax     oldCtx.syntax
    | 'compile:context ]makeStructure -> ctx

    -1 --> ctx.arity

    makeFunction -> fun

    ( Reset assembler: )
    ctx.asm reset

    ( Mark scope on stack: )
    0 ctx compile:pushColon

    ( Compile required parameters.  We exit  )
    ( this loop by compileSemi doing a GOTO )
    ( to semiTag when we hit a ';':         )
    nil -> seenBrace
    withTags semiTag braceTag do{
        do{
            compile:modeGet ctx compilePath
        }
	braceTag
	t -> seenBrace
        semiTag
    }

    ( Finish assembly to produce actual  )
    ( compiled function:                 )
    nil -1 fun ctx.asm finishAssembly -> cfn

    ( Pop any nested symbols off symbol stack: )
    do{ symbols length2  symbolsSp = until
        symbols pull -> sym
    }	

    ( Invoke compiled function, leaving )
    ( block of required parameters:     )
    [ cfn call |
    ]evec -> requiredArgs



    ( Parse optional args, if present: )
    seenBrace not if

	( Reset assembler: )
	ctx.asm reset

	( Mark scope on stack: )
	0 ctx compile:pushColon

	( Compile optional parameters.  We exit  )
	( this loop by compileSemi doing a GOTO )
	( to semiTag when we hit a ';':         )
	withTags semiTag braceTag do{
	    do{
		compile:modeGet ctx compilePath
	    }
	    braceTag
	    t -> seenBrace
	    semiTag
	}

	( Finish assembly to produce actual  )
	( compiled function:                 )
	nil -1 fun ctx.asm finishAssembly -> cfn

	( Pop any nested symbols off symbol stack: )
	do{ symbols length2  symbolsSp = until
	    symbols pull -> sym
	}	

	( Invoke compiled function, leaving )
	( block of optional parameters:     )
	[ cfn call |
        |dup[
        |keys ]evec -> optionalArgs
	|vals ]evec -> optionalDefaults
    else
	[ |   ]evec -> optionalArgs
	[ |   ]evec -> optionalDefaults
    fi



    seenBrace not if

	( Reset assembler: )
	ctx.asm reset

	( Mark scope on stack: )
	0 ctx compile:pushColon

	( Compile keyword parameters.  We exit   )
	( this loop by compileSemi doing a GOTO )
	( to semiTag when we hit a ';':         )
	withTags semiTag braceTag do{
	    do{
		compile:modeGet ctx compilePath
	    }
	    braceTag
	    t -> seenBrace
	    semiTag
	}

	( Finish assembly to produce actual  )
	( compiled function:                 )
	nil -1 fun ctx.asm finishAssembly -> cfn

	( Pop any nested symbols off symbol stack: )
	do{ symbols length2  symbolsSp = until
	    symbols pull -> sym
	}	

	( Invoke compiled function, leaving )
	( block of keyword parameters:      )
	[ cfn call |
        |dup[
        |keys ]evec -> keywordArgs
	|vals ]evec -> keywordDefaults
    else
	[ |   ]evec -> keywordArgs
	[ |   ]evec -> keywordDefaults
    fi


    seenBrace not if

	( Read next token.  Since strings of 0-3 )
	( chars are in-pointer, reducing [] $ -> )
	( to strings generates no garbage:       )
	[ ctx.mss | |scanTokenToNonwhitespace ]pop
	[ ctx.mss |
	|scanTokenToWhitespace
	|popp		    ( lineloc )
	|readTokenChars   ( Get token chars as block.      )
	|backslashesToHighbit	( Good habit.	)
(	|downcase	)	( "         "	) 
	]join -> token

	token "]}" != if
	    "Unexpected lack of ]} encountered" simpleError
	fi
    fi

    ( Create lambdaList instance to hold info: )
    requiredArgs length2 -> ra
    optionalArgs length2 -> oa
    keywordArgs  length2 -> ka
    ra oa ka 0 makeLambdaList -> lambda

    ( Copy requiredArg names into lambdaList: )
    for i from 0 below ra do{
	lambda :name i requiredArgs[i]$s.name setLambdaSlotProperty
    }

    ( Copy optionalArg info into lambdaList: )
    for i from 0 below oa do{
	ra i + -> j
	lambda :name j optionalArgs[i]$s.name setLambdaSlotProperty
	optionalDefaults[i] -> dflt
	dflt callable? if
	    lambda :initform j dflt setLambdaSlotProperty
	else
	    lambda :initval  j dflt setLambdaSlotProperty
	fi
    }

    ( Copy keywordArg info into lambdaList: )
    for i from 0 below ka do{
	ra oa + i + -> j
	lambda :name j keywordArgs[i] setLambdaSlotProperty
	keywordDefaults[i] -> dflt
	dflt callable? if
	    lambda :initform j dflt setLambdaSlotProperty
	else
	    lambda :initval  j dflt setLambdaSlotProperty
	fi
    }

    lambda
;
'parseLambdaList export

( =====================================================================	)
( - {[ -- Compile lambda list style type signature 			)

: compile-{[ { $ -> }   -> ctx   compileTime

    ( Parse and reduce arity: )    
    ctx parseLambdaList -> lambda

    ( Create local vars corresponding )
    ( to the lambda list arguments:   )
    lambda.totalArgs -> totalArgs
    for i from 0 below totalArgs do{

	( Get name of this slot.  For required and    )
	( optional args, it will already be a string; )
	( for keyword args it will be a keyword, and  )
	( we fetch the string name of that keyword:   )
	lambda :name i getLambdaSlotProperty -> name
	name symbol? if name.name -> name fi
	
	( Allocate a local variable slot for the parameter: )
	name ctx.asm assembleVariableSlot -> val

	( Note local variable, so user )
	( can later read and write it: )
        name :var val ctx compile:noteLocal
    }

    ( Deposit code to apply lambdaList )
    ( and copy results into local vars: )
    lambda               ctx.asm assembleConstant
    '|applyLambdaList ctx.asm assembleCall
    ']setLocalVars    ctx.asm assembleCall

    ( Stash arity declaration for )
    ( later use by compileSemi:  )
(    arity --> ctx.arity )
(    force --> ctx.force )
;
'compile-{[ export
"{[" intern -> sym   sym export   #'compile-{[ --> sym.function



( =====================================================================	)
( - compileArrow -- Assignment to local var: exp -> var			)

:   compileArrow   { $ -> }   -> ctx
    compileTime

    ( Find/assign slot for variable: )
    ctx makeLocalVar -> slot

    ( Deposit code to do the store: )
    slot ctx.asm assembleVariableSet
;
'compileArrow export
"->" intern -> sym   sym export   #'compileArrow --> sym.function

( =====================================================================	)
( - compileBracketArrow -- ]shift + ->					)

:   compileBracketArrow   { $ -> }   -> ctx
    compileTime

    ']shift ctx.asm assembleCall

    ( Find/assign slot for variable: )
    ctx makeLocalVar -> slot

    ( Deposit code to do the store: )
    slot ctx.asm assembleVariableSet
;
'compileBracketArrow export
"]->" intern -> sym   sym export   #'compileBracketArrow --> sym.function



( =====================================================================	)
( - compileAarrow -- Assignment to global path/var: exp --> path	)

:   compileAarrow  { $ -> }   -> ctx
    compileTime
    compile:modeSet ctx compilePath
;
'compileAarrow export
"-->" intern -> sym   sym export   #'compileAarrow --> sym.function



( =====================================================================	)
( - compileBracketAarrow -- ]shift + --> 				)

:   compileBracketAarrow  { $ -> }   -> ctx
    compileTime
    ']shift ctx.asm assembleCall
    compile:modeSet ctx compilePath
;
'compileBracketAarrow export
"]-->" intern -> sym   sym export   #'compileBracketAarrow --> sym.function



( =====================================================================	)
( - compileAarrowConstant --  to const path/var: exp -->constant path	)

:   compileAarrowConstant  { $ -> }   -> ctx
    compileTime
    compile:modeSet compile:modeConst logior ctx compilePath
;
'compileAarrowConstant export
"-->constant" intern -> sym  sym export #'compileAarrowConstant --> sym.function



( =====================================================================	)
( - after{ -- First part of after{...}alwaysDo{...} construct		)

: after{   { $ -> }   -> ctx   compileTime
    ctx.asm -> asm
    asm assembleLabelGet -> label
    label asm assembleAfter
    label ctx compile:pushAfter

    ( Push endOfScope fn to be called by '}' fn: )
    ::  { $ -> ! }   -> ctx
        "Missing }alwaysDo{" simpleError
    ; ctx.syntax push
;
'after{ export
'afterParentDoes{ export
'after{ symbolFunction 'afterParentDoes{ setSymbolFunction

( =====================================================================	)
( - afterChildDoes{ -- First part of afterChildDoes{...}alwaysDo{...}	)

: afterChildDoes{   { $ -> }   -> ctx   compileTime
    ctx.asm -> asm
    asm assembleLabelGet -> label
    label asm assembleAfterChild
    label ctx compile:pushAfter

    ( Push endOfScope fn to be called by '}' fn: )
    ::  { $ -> ! }   -> ctx
        "Missing }alwaysDo{" simpleError
    ; ctx.syntax push
;
'afterChildDoes{ export

( =====================================================================	)
( - }alwaysDo{ -- Middle part of after{...}alwaysDo{...} construct	)

: }alwaysDo{   { $ -> }   -> ctx   compileTime
    ctx.asm    -> asm
    ctx.syntax -> syntax
    syntax pull -> cfn	( Discard } cfn pushed by after{ )
    ctx compile:popAfter  -> lastLabel
    asm assembleLabelGet -> nextLabel
    nextLabel ctx compile:pushAlways
    nextLabel asm assembleAlwaysDo
    lastLabel asm assembleLabel

    ( Push endOfScope fn to be called by '}' fn: )
    ::  { $ -> }   -> ctx
        ctx.asm -> asm   
        ctx compile:popAlways -> nextLabel
        nextLabel asm assembleLabel
        'popUnwindframe asm assembleCall
    ; syntax push
;
'}alwaysDo{ export

( =====================================================================	)
( - endOfLoop --							)

: endOfLoop { $ -> }   -> ctx
    ctx compile:popTop    -> top
    ctx compile:popBottom -> bot
    ctx compile:popExit   -> xit

    ctx.asm -> asm

    bot asm assembleLabel
    top asm assembleBra
    xit asm assembleLabel
;
'endOfLoop export

( =====================================================================	)
( - do{ -- 								)

: do{ { $ -> }    -> ctx   compileTime
    ctx.asm -> asm

    ( Allocate labels for our loop: )
    asm assembleLabelGet -> top
    asm assembleLabelGet -> bot
    asm assembleLabelGet -> xit

    ( Generate top of loop: )
    top asm assembleLabel

    ( Save labels on syntax stack: )
    xit ctx compile:pushExit
    bot ctx compile:pushBottom
    top ctx compile:pushTop

    ( Push endOfScope fn to be called by '}' fn: )
    'endOfLoop ctx.syntax push
;
'do{ export

( =====================================================================	)
( - compile-} --							)

: compile-} { $ -> }   -> ctx   compileTime
    ctx.asm -> asm
    ctx.syntax pull -> cfn
    cfn callable? not if
	"Syntax error: '}' doesn't match current scope." simpleError
    fi
    ctx cfn call{ $ -> }
;
'compile-} export
"}" intern -> sym   sym export   #'compile-} --> sym.function


( =====================================================================	)
( - loopFinish -- 							)

: loopFinish { $ -> }   -> ctx   compileTime

    ctx.syntax -> syntax

    ( Check that 'loopFinish' is in a loop: )
    syntax :exit getKey? -> exitLoc not if
	"'loopFinish' must be within a loop." simpleError
    fi

    ( Check that 'loopFinish' isn't jumping out of    )
    ( an after{ }alwaysDo{ }. (We should allow  )
    ( doing so some day, but need to do some     )
    ( work to preserve after{}alwaysDo{} first: )
    syntax :after getKey? -> afterLoc if
	afterLoc exitLoc > if
	    "May not 'loopFinish' from after{ }always_do{ }." simpleError
    fi  fi
    syntax :always getKey? -> alwaysLoc if
	alwaysLoc exitLoc > if
	    "May not 'loopFinish' from after{ }always_do{ }." simpleError
    fi  fi

    ( Exit label is stored under :exit keyword: )
    exitLoc 1 -     -> exitLoc
    syntax[exitLoc] -> exitLoc

    ( Deposit branch to loop exit: )
    exitLoc ctx.asm assembleBra
;
'loopFinish export

( =====================================================================	)
( - loopNext -- Compile a 'loopNext'					)

: loopNext { $ -> }   -> ctx   compileTime

    ctx.syntax -> syntax

    ( Check that 'loopFinish' is in a loop: )
    syntax :top getKey? -> topLoc not if
	"'loopNext' must be within a loop." simpleError
    fi

    ( Check that 'loopNext' isn't jumping out of    )
    ( an after{ }alwaysDo{ }. (We should allow  )
    ( doing so some day, but need to do some     )
    ( work to preserve after{}alwaysDo{} first: )
    syntax :after getKey? -> afterLoc if
	afterLoc topLoc > if
	    "May not 'loopNext' from after{ }always_do{ }." simpleError
    fi  fi
    syntax :always getKey? -> alwaysLoc if
	alwaysLoc topLoc > if
	    "May not 'loopNext' from after{ }always_do{ }." simpleError
    fi  fi

    ( top label is stored under :top keyword: )
    topLoc 1 -     -> topLoc
    syntax[topLoc] -> topLoc

    ( Deposit branch to loop top: )
    topLoc ctx.asm assembleBra
;
'loopNext export

( =====================================================================	)
( - while -- 								)

: while { $ -> }   -> ctx   compileTime

    ctx.syntax -> syntax

    ( Check that 'while' is in a loop: )
    syntax :exit getKey? -> exitLoc not if
	"'while' must be within a loop." simpleError
    fi

    ( Check that 'while' isn't jumping out of    )
    ( an after{ }alwaysDo{ }. (We should allow  )
    ( doing so some day, but need to do some     )
    ( work to preserve after{}alwaysDo{} first: )
    syntax :after getKey? -> afterLoc if
	afterLoc exitLoc > if
	    "May not 'while' from after{ }always_do{ }." simpleError
    fi  fi
    syntax :always getKey? -> alwaysLoc if
	alwaysLoc exitLoc > if
	    "May not 'while' from after{ }always_do{ }." simpleError
    fi  fi

    ( Exit label is stored under :exit keyword: )
    exitLoc 1 -     -> exitLoc
    syntax[exitLoc] -> exitLoc

    ( Deposit conditional branch to loop exit: )
    exitLoc ctx.asm assembleBeq
;
'while export

( =====================================================================	)
( - until -- 								)

: until { $ -> }   -> ctx   compileTime

    ctx.syntax -> syntax

    ( Check that 'until' is in a loop: )
    syntax :exit getKey? -> exitLoc not if
	"'until' must be within a loop." simpleError
    fi

    ( Check that 'until' isn't jumping out of    )
    ( an after{ }alwaysDo{ }. (We should allow  )
    ( doing so some day, but need to do some     )
    ( work to preserve after{}alwaysDo{} first: )
    syntax :after getKey? -> afterLoc if
	afterLoc exitLoc > if
	    "May not 'until' from after{ }always_do{ }." simpleError
    fi  fi
    syntax :always getKey? -> alwaysLoc if
	alwaysLoc exitLoc > if
	    "May not 'until' from after{ }always_do{ }." simpleError
    fi  fi

    ( Exit label is stored under :exit keyword: )
    exitLoc 1 -     -> exitLoc
    syntax[exitLoc] -> exitLoc

    ( Deposit conditional branch to loop exit: )
    exitLoc ctx.asm assembleBne
;
'until export

( =====================================================================	)
( - |for -- Compile a '|for'						)

: |for { $ -> }   -> ctx   compileTime
    ctx.asm -> asm

    ( Basic syntax is "|for v i do{ ... }" (i optional): )

    ( Find/assign slot for variable: )
    ctx makeLocalVar -> varslot

    ( Next token may be optional varname or 'do{': )
    ctx readLocalVarName[

    ( If last wasn't 'do{' still need to read it: )
    "do{" |= if
	]pop

	( Create an anonymous local variable to )
	( hold current offset into stack block: )
	"" asm assembleVariableSlot    -> idxslot

    else
        ctx ]makeLocalVar -> idxslot

        ctx readLocalVarName[
        "do{" |= not if
	    "'|for' is missing 'do{'!" simpleError
    	fi
	]pop
    fi	

    ( Create an anonymous local variable )
    ( to hold stack block size:          )
    "" asm assembleVariableSlot    -> limslot

    ( Create an anonymous local variable )
    ( to hold stack base offset:         )
    "" asm assembleVariableSlot    -> basslot

    ( Allocate labels for our loop: )
    asm assembleLabelGet -> top
    asm assembleLabelGet -> bot
    asm assembleLabelGet -> xit

    asm assembleLabelGet -> mid

    ( Deposit code to initialize  )
    ( limit var to blocksize:     )
    '|length asm assembleCall
    limslot asm assembleVariableSet


    ( Deposit code to initialize  )
    ( base var to block base:     )
    'depth asm assembleCall
    limslot asm assembleVariableGet
    '- asm assembleCall
    1   asm assembleConstant
    '- asm assembleCall
    basslot asm assembleVariableSet


    ( Deposit code to initialize  )
    ( index var to -1:            )
    -1 asm assembleConstant
    idxslot asm assembleVariableSet

    ( Generate top of loop: )
    xit ctx compile:pushExit
    bot ctx compile:pushBottom
    top ctx compile:pushTop
    top asm assembleLabel

    ( Deposit code to save result )
    ( of previous loop back in    )
    ( appropriate stack slot.     )
    ( Don't do this first time:   )
    idxslot asm assembleVariableGet
    -1 asm assembleConstant
    '= asm assembleCall
    mid asm assembleBne

    varslot asm assembleVariableGet
    basslot asm assembleVariableGet
    idxslot asm assembleVariableGet
    '+ asm assembleCall
    'setBth asm assembleCall

    mid asm assembleLabel


    ( Deposit code to increment   )
    ( index variable by one:      )
    idxslot asm assembleVariableGet
    1 asm assembleConstant
    '+ asm assembleCall
    idxslot asm assembleVariableSet

    ( Deposit code to exit if     )
    ( index variable >= limit:    )
    idxslot asm assembleVariableGet
    limslot asm assembleVariableGet
    '>= asm assembleCall
    xit asm assembleBne

    ( Deposit code to load appropriate  )
    ( block element into our local var: )
    basslot asm assembleVariableGet
    idxslot asm assembleVariableGet
    '+ asm assembleCall
    'dupBth asm assembleCall
    varslot asm assembleVariableSet

    ( Push endOfScope fn to be called by '}' fn: )
    'endOfLoop ctx.syntax push
;
'|for export

( =====================================================================	)
( - |forPairs -- Compile a '|forPairs'					)

: |forPairs { $ -> }   -> ctx   compileTime
    ctx.asm -> asm

    ( Basic syntax is "|for k v i do{ ... }" (i optional): )

    ( Find/assign slot for variables: )
    ctx makeLocalVar -> keyslot
    ctx makeLocalVar -> valslot

    ( Next token may be optional varname or 'do{': )
    ctx readLocalVarName[

    ( If last wasn't 'do{' still need to read it: )
    "do{" |= if
	]pop

	( Create an anonymous local variable to )
	( hold current offset into stack block: )
	"" asm assembleVariableSlot    -> idxslot

    else
        ctx ]makeLocalVar -> idxslot

        ctx readLocalVarName[
        "do{" |= not if
	    "'|forPairs' is missing 'do{'!" simpleError
    	fi
	]pop
    fi	

    ( Create an anonymous local variable )
    ( to hold stack block size:          )
    "" asm assembleVariableSlot    -> limslot

    ( Create an anonymous local variable )
    ( to hold stack base offset:         )
    "" asm assembleVariableSlot    -> basslot

    ( Allocate labels for our loop: )
    asm assembleLabelGet -> top
    asm assembleLabelGet -> bot
    asm assembleLabelGet -> xit

    asm assembleLabelGet -> mid

    ( Deposit code to initialize  )
    ( limit var to blocksize:     )
    '|length asm assembleCall
    limslot asm assembleVariableSet


    ( Deposit code to initialize  )
    ( base var to block base:     )
    'depth asm assembleCall
    limslot asm assembleVariableGet
    '- asm assembleCall
    1   asm assembleConstant
    '- asm assembleCall
    basslot asm assembleVariableSet


    ( Deposit code to initialize  )
    ( index var to -2:            )
    -2 asm assembleConstant
    idxslot asm assembleVariableSet

    ( Generate top of loop: )
    xit ctx compile:pushExit
    bot ctx compile:pushBottom
    top ctx compile:pushTop
    top asm assembleLabel

    ( Deposit code to save result )
    ( of previous loop back in    )
    ( appropriate stack slot.     )
    ( Don't do this first time:   )
    idxslot asm assembleVariableGet
    -2 asm assembleConstant
    '= asm assembleCall
    mid asm assembleBne

    keyslot asm assembleVariableGet
    basslot asm assembleVariableGet
    idxslot asm assembleVariableGet
    '+ asm assembleCall
    'setBth asm assembleCall

    valslot asm assembleVariableGet
    basslot asm assembleVariableGet
    idxslot asm assembleVariableGet
    '+ asm assembleCall
    1   asm assembleConstant
    '+ asm assembleCall
    'setBth asm assembleCall

    mid asm assembleLabel


    ( Deposit code to increment   )
    ( index variable by two:      )
    idxslot asm assembleVariableGet
    2 asm assembleConstant
    '+ asm assembleCall
    idxslot asm assembleVariableSet

    ( Deposit code to exit if     )
    ( index variable >= limit:    )
    idxslot asm assembleVariableGet
    limslot asm assembleVariableGet
    '>= asm assembleCall
    xit asm assembleBne

    ( Deposit code to load appropriate   )
    ( block element into our local vars: )

    basslot asm assembleVariableGet
    idxslot asm assembleVariableGet
    '+ asm assembleCall
    'dupBth asm assembleCall
    keyslot asm assembleVariableSet

    basslot asm assembleVariableGet
    idxslot asm assembleVariableGet
    '+ asm assembleCall
    1   asm assembleConstant
    '+ asm assembleCall
    'dupBth asm assembleCall
    valslot asm assembleVariableSet

    ( Push endOfScope fn to be called by '}' fn: )
    'endOfLoop ctx.syntax push
;
'|forPairs export

( =====================================================================	)
( - listfor -- Compile a 'listfor'					)

: listfor { $ -> }   -> ctx   compileTime
    ctx.asm -> asm

    ( Basic syntax is "<list> listfor val cons do{ ... }" (cons optional): )

    ( Find/assign slot for variable: )
    ctx makeLocalVar -> varslot

    ( Next token may be optional varname or 'do{': )
    ctx readLocalVarName[

    ( If last wasn't 'do{' still need to read it: )
    "do{" |= if
	]pop

	( Create an anonymous local variable to )
	( hold current offset into stack block: )
	"" asm assembleVariableSlot    -> cnsslot

    else
        ctx ]makeLocalVar -> cnsslot

        ctx readLocalVarName[
        "do{" |= not if
	    "'listfor' is missing 'do{'!" simpleError
    	fi
	]pop
    fi	

    "" asm assembleVariableSlot    -> lastslot

    ( Allocate labels for our loop: )
    asm assembleLabelGet -> top
    asm assembleLabelGet -> bot
    asm assembleLabelGet -> xit

    asm assembleLabelGet -> mid

    ( Deposit code to initialize )
    ( cns var to list:           )
    cnsslot asm assembleVariableSet

    ( Deposit code to initialize )
    ( last slot to NIL.          )
    nil asm assembleConstant
    lastslot asm assembleVariableSet

    ( Generate top of loop: )
    xit ctx compile:pushExit
    bot ctx compile:pushBottom
    top ctx compile:pushTop
    top asm assembleLabel


    ( Deposit code to save result )
    ( of previous loop back in    )
    ( appropriate cons cell.      )
    ( Don't do this first time:   )
    lastslot asm assembleVariableGet
    mid asm assembleBeq
    cnsslot asm assembleVariableGet
    varslot asm assembleVariableGet
    'rplaca asm assembleCall

    ( Deposit code to step to     )
    ( next cons cell:             )
    cnsslot asm assembleVariableGet
    'cdr asm assembleCall
    cnsslot asm assembleVariableSet

    mid asm assembleLabel

    ( Remember we've done first time: )
    cnsslot asm assembleVariableGet
    lastslot asm assembleVariableSet

    ( Deposit code to exit if     )
    ( cons cell is nil:           )
    cnsslot asm assembleVariableGet
    xit asm assembleBeq

    ( Deposit code to load appropriate )
    ( list element into our local var: )
    cnsslot asm assembleVariableGet
    'car asm assembleCall
    varslot asm assembleVariableSet

    ( Push endOfScope fn to be called by '}' fn: )
    'endOfLoop ctx.syntax push
;
'listfor export

( =====================================================================	)
( - call{ -- '								)

: call{ { $ -> }   -> ctx   compileTime

    ( Parse and reduce arity: )    
    ctx parseArity -> force -> arity

    arity ctx.asm assembleCalla
;
'call{ export

( =====================================================================	)
( - if -- 'if'								)

: if { $ -> }   -> ctx   compileTime

    ( Allocate label which 'if' jumps to -- )
    ( this might be the 'else' or 'fi':     )
    ctx.asm -> asm
    asm assembleLabelGet -> orig

    ( Deposit the conditional test: )
    orig asm assembleBeq

    ( Note on syntax stack that we )
    ( are inside an 'if' scope:    )
    orig ctx compile:pushOrig
;
'if export

( =====================================================================	)
( - else -- 'else'							)

:   else { $ -> }   -> ctx   compileTime

    ( Allocate label for 'fi': )
    ctx.asm -> asm
    asm assembleLabelGet -> fiLabel

    ( Deposit the jump over the )
    ( second (else) clause:     )
    ctx compile:popOrig -> elseLabel
    fiLabel asm assembleBra

    ( Deposit the label to which )
    ( our matching 'if' jumps:   )
    elseLabel asm assembleLabel

    ( Remember fiLabel for 'fi' )
    fiLabel ctx compile:pushOrig
;
'else export

( =====================================================================	)
( - fi -- 'fi'								)

:   fi { $ -> }   -> ctx   compileTime

    ( Desposit bottom label for if...fi: )
    ctx.asm -> asm
    ctx compile:popOrig -> fiLabel
    fiLabel asm assembleLabel
;
'fi export

( =====================================================================	)
( - case{ -- Compile a 'case{'						)

:   case{ { $ -> }   -> ctx   compileTime
    ctx.asm -> asm

    ( Syntax is "key case{ on: val ... on: val ... else: ... }": )

    ( Create an anonymous local )
    ( variable to hold key val: )
    "" asm assembleVariableSlot    -> keyOffset

    ( Pop object into its var: )
    keyOffset asm assembleVariableSet

    ( Deposit end-of-'switch' label on syntax stack: )
    asm assembleLabelGet -> endLabel
    endLabel ctx compile:pushOrig

    ( Deposit dummy end-of-'on:' label on syntax stack. )
    ( This mildly 'clever' hack depends on the fact   )
    ( that 'getNextLabel' would never issue a '0'   )
    ( val at this point, since it starts at 0 and we  )
    ( have already called it once above:              )
    0 ctx compile:pushOrig

    ( Deposit keyOffset on syntax stack for compileOn: )
    keyOffset ctx compile:pushSwitch

    ( Deposit anonFn for '}': )
    :: { $ -> }   -> ctx
        ctx compile:popSwitch pop ( Discard keyOffset          )
	ctx compile:popOrig   pop ( Discard endOfOn label     )
	ctx compile:popOrig   pop ( Discard endOfSwitch label )
    ; ctx.syntax push
;
'case{ export

( =====================================================================	)
( - on: -- Compile a 'on:'						)

: on: { $ -> }   -> ctx   compileTime
    ctx.asm -> asm

    ( Syntax is "key case{ on: val ... on: val ... else: ... }": )

    ( We'd (better be!) in a "case{ on: tag ... }" statement: )
    ctx.syntax pull pop ( Discard } anonFn )
    ctx compile:popSwitch -> keyOffset
    ctx compile:popOrig   ->   thisId
    ctx compile:popOrig   -> switchId
    asm assembleLabelGet -> nextId

    ( Error if we've already )
    ( seen an 'else:':       )
    thisId -1 = if "'else:' must follow all 'on:'s!" simpleError fi

    ( If this isn't first 'on:',  )
    ( we need a jump from end of  )
    ( previous 'on:' to end of    )
    ( enclosing 'switch' followed )
    ( by label used to jump over  )
    ( body of the previous 'on:'  )
    ( clause:                     )
    thisId 0 != if
        switchId asm assembleBra
	thisId   asm assembleLabel
    fi

    ( Next token must be a constant.    )
    ( Deposit code to load it on stack: )
    compile:modeGet ctx compilePath
    ( Buggo? Do we need some sort of check that it's a constant here? )

    ( Deposit testAndJump comparison of )
    ( 'on:' constant with key which jumps )
    ( to next 'on:' clause on mismatch:   )
    keyOffset asm assembleVariableGet
    'muf:=    asm assembleCall
    nextId    asm assembleBeq

    ( Save switch state back on data stack: )
    switchId  ctx compile:pushOrig
    nextId    ctx compile:pushOrig
    keyOffset ctx compile:pushSwitch

    ( Deposit anonFn for '}': )
    :: { $ -> }   -> ctx
	ctx.asm -> asm
        ctx compile:popSwitch pop ( Discard keyOffset          )
	ctx compile:popOrig   -> nextId
	ctx compile:popOrig   -> switchId
	( next_id should be -1 unless we had no 'else:': )
	nextId -1 != if nextId asm assembleLabel fi
	switchId asm assembleLabel
    ; ctx.syntax push
;
'on: export

( =====================================================================	)
( - else: -- Compile a 'else:'						)

: else: { $ -> }   -> ctx   compileTime
    ctx.asm -> asm

    ( Syntax is "key case{ on: val ... on: val ... else: ... }": )

    ( We'd (better be!) in a "case{ on: tag ... }" statement: )
    ctx.syntax pull        -> cfn
    ctx compile:popSwitch -> keyOffset
    ctx compile:popOrig   ->   thisId
    ctx compile:popOrig   -> switchId

    ( Error if we've already )
    ( seen a 'else:':     )
    thisId -1 = if
	"only one 'else:' per case{...} :)" simpleError
    fi

    ( If we've seen an 'on:',    )
    ( we need a jump from end of )
    ( previous 'on:' to end of   )
    ( enclosing switch, followed )
    ( by label used to jump over )
    ( body of the previous 'on:' )
    ( clause:                    )
    thisId 0 != if
        switchId asm assembleBra
	thisId   asm assembleLabel
    fi

    ( Save switch state back on syntax stack: )
    switchId  ctx compile:pushOrig
    -1         ctx compile:pushOrig
    keyOffset ctx compile:pushSwitch

    ( Re-store anonFn for } as well: )
    cfn ctx.syntax push
;
'else: export

( =====================================================================	)
( - asMeDo{ -- 								)

: asMeDo{   { $ -> }   -> ctx   compileTime
    0 ctx compile:pushUser
    'pushUserMeFrame ctx.asm assembleCall

    ( Deposit anonFn for '}': )
    :: { $ -> }   -> ctx
        ctx compile:popUser pop
	'popUserFrame ctx.asm assembleCall
    ; ctx.syntax push
;
'asMeDo{ export


( =====================================================================	)
( - rootAsUserDo{ -- 							)

: rootAsUserDo{   { $ -> }   -> ctx   compileTime
    0 ctx compile:pushUser
    'rootPushUserFrame ctx.asm assembleCall

    ( Deposit anonFn for '}': )
    :: { $ -> }   -> ctx
        ctx compile:popUser pop
	'popUserFrame ctx.asm assembleCall
    ; ctx.syntax push
;
'rootAsUserDo{ export


( =====================================================================	)
( - rootOmnipotentlyDo{ -- 						)

: rootOmnipotentlyDo{   { $ -> }   -> ctx   compileTime
    0 ctx compile:pushPrivs
    'rootPushPrivsOmnipotentFrame ctx.asm assembleCall

    ( Deposit anonFn for '}': )
    :: { $ -> }   -> ctx
        ctx compile:popPrivs pop
	'popPrivsFrame ctx.asm assembleCall
    ; ctx.syntax push
;
'rootOmnipotentlyDo{ export


( =====================================================================	)
( - ]withHandlersDo{ -- 						)

: ]withHandlersDo{   { $ -> }   -> ctx   compileTime
    0 ctx compile:pushHandlers
    ']pushHandlersframe ctx.asm assembleCall

    ( Deposit anonFn for '}': )
    :: { $ -> }   -> ctx
        ctx compile:popHandlers pop
	'popHandlersframe ctx.asm assembleCall
    ; ctx.syntax push
;
']withHandlersDo{ export
']withHandlersDo{ symbolFunction --> #']withHandlerDo{
']withHandlerDo{ export


( =====================================================================	)
( - ( -- Compile comment 						)

:   compile-( { $ -> }   -> ctx    compileTime

    ( Eat text to next ')': )
    ctx.mss -> mss
    do{
        [ mss ")\n" |			( Scan to next right paren,	)
        |scanTokenToChars		( reading a line at a time.	)
        |popp 				( Discard lineloc.		)
        |readTokenChars		( Read comment text.		)
	|pop -> endchar
	endchar '\n' = if ]pop loopNext fi ( Ignore line.		)
	endchar ')' != if "internal err" simpleError fi ( Hrm?		)
	|length 0 = if ]pop return fi   ( Don't crash on empty lines	)
	|pop whitespace? if		( Check char before paren	)
	    ]pop return			( Found end of comment.		)
	fi
	]pop				( Ignore parens not preceded by )
    }					( whitespace.			)
;
"(" intern -> sym   sym export   #'compile-( --> sym.function

( =====================================================================	)
( - [ --		 						)

: [ { $ -> }   -> ctx    compileTime
    0 ctx compile:pushLbracket
    'startBlock ctx.asm assembleCall
;
'[ export

( =====================================================================	)
( - | --		 						)

: | { $ -> }   -> ctx    compileTime
    ctx compile:popLbracket pop
    'endBlock ctx.asm assembleCall
;
'| export

( =====================================================================	)
( - ]e --		 						)

: ]e { $ -> }   -> ctx    compileTime
    ctx compile:popLbracket pop
    ']makeEphemeralList ctx.asm assembleCall
;
']e export

( =====================================================================	)
( - endLockScope --	 						)

: endLockScope { $ -> } -> ctx
    ctx compile:popLock pop
    'popLockframe ctx.asm assembleCall
;

( =====================================================================	)
( - withLockDo{ --	 						)

: withLockDo{   { $ -> }   -> ctx    compileTime
    0 ctx compile:pushLock
    'pushLockframe ctx.asm assembleCall

    ( Deposit fn for '}': )
    'endLockScope ctx.syntax push
;
'withLockDo{ export
'withLockDo{ symbolFunction --> #'withParentLockDo{
'withParentLockDo{ export

( =====================================================================	)
( - withChildLockDo{ --							)

: withChildLockDo{   { $ -> }   -> ctx    compileTime
    0 ctx compile:pushLock
    'pushLockframeChild ctx.asm assembleCall

    ( Deposit fn for '}': )
    'endLockScope ctx.syntax push
;
'withChildLockDo{ export

( =====================================================================	)
( - ]withRestartDo{ --							)

: ]withRestartDo{   { $ -> }   -> ctx    compileTime
    0 ctx compile:pushRestart
    ']pushRestartframe ctx.asm assembleCall

    ( Deposit anonFn for '}': )
    :: { $ -> }   -> ctx
        ctx compile:popRestart pop
	'popRestartframe ctx.asm assembleCall
    ; ctx.syntax push
;
']withRestartDo{ export

( =====================================================================	)
( - catch{ --								)

: catch{   { $ -> }   -> ctx    compileTime
    ctx.asm -> asm

    ( Buggo?  Is catch{ something obsolete which  )
    ( should be phased out?  It's not in mufcore. )

    asm assembleLabelGet -> orig
    orig asm assembleCatch

    orig ctx compile:pushOrig
    0    ctx compile:pushCatch

    ( Deposit anonFn for '}': )
    :: { $ -> }   -> ctx
	ctx.asm -> asm
        ctx compile:popCatch pop

	'popCatchframe asm assembleCall
        ctx compile:popOrig asm assembleLabel
    ; ctx.syntax push
;
'catch{ export

( =====================================================================	)
( - withTags --								)

: withTags   { $ -> }   -> ctx    compileTime
    ctx.asm -> asm

    0 -> tagCount

    ( This isn't logically needed, but I feel )
    ( better having the extra checking, first )
    ( time around:                            )
    0    ctx compile:pushGobot

    ( Read tags until we reach a 'do{': )
    do{
        ctx readTokenToWhitespace[
        "do{" |= until

	( Found tag name. )

	( Convert it to a symbol: )
	ctx.package ]makeSymbol -> sym

	( Allocate an assembly label for it: )
	asm assembleLabelGet -> label

	( Generate code to push an appropriate tagframe: )
	sym asm assembleConstant
	label asm assembleTag

	( Remember that we need to generate a matching pop: )
	0 ctx compile:pushGoto
	++ tagCount

	( Remember tag is defined: )
	sym.name :tag label ctx compile:noteLocal
    }
    ]pop

    'pushTagtopframe asm assembleCall
    tagCount ctx compile:pushGotop


    ( Deposit anonFn for '}': )
    :: { $ -> }   -> ctx
	ctx.asm -> asm
        ctx compile:popGotop -> tagCount
	'popTagtopframe asm assembleCall
	do{
	    tagCount 0 = until
	    ctx compile:popGoto pop
	    'popTagframe asm assembleCall

	    ( buggo:  We don't erase the definitions )
	    ( of the tags yet, so they can actually  )
	    ( wind up placed outside the do{ ... }   )
	    ( scope.  No great harm, but ugly.       )

	    -- tagCount
	}
	ctx compile:popGobot pop
    ; ctx.syntax push
;
'withTags export
'withTags symbolFunction --> #'withTag
'withTag  export

( =====================================================================	)
( - compileTime -- 							)

:   compileTim3   { $ -> }   -> ctx   compileTime
    t --> ctx.asm.compileTime?
;
'compileTim3 symbolFunction 'compileTime setSymbolFunction
'compileTime export

( =====================================================================	)
( - pleaseInline -- 							)

:   pleaseInlin3   { $ -> }   -> ctx   compileTime
    t --> ctx.asm.pleaseInline?
;
'pleaseInlin3 symbolFunction 'pleaseInline setSymbolFunction
'pleaseInline export

( =====================================================================	)
( - neverInline -- 							)

:   neverInlin3   { $ -> }   -> ctx   compileTime
    t --> ctx.asm.neverInline?
;
'neverInlin3 symbolFunction 'neverInline setSymbolFunction
'neverInline export

( =====================================================================	)
( - delete: -- 								)

:   delete:   { $ -> }   -> ctx   compileTime
    compile:modeDel ctx compilePath
;
'delete: export

( =====================================================================	)
( - ++ -- Compile ++							)

:   ++  { $ -> }   -> ctx    compileTime
    compile:modeInc ctx compilePath
;
'++ export

( =====================================================================	)
( - -- -- Compile --							)

:   --  { $ -> }   -> ctx    compileTime
    compile:modeDec ctx compilePath
;
'-- export

( =====================================================================	)
( - => --								)

:   =>  { $ -> }   -> ctx    compileTime
    ctx.asm -> asm

    ( Read name of symbol to bind: )
    ctx readTokenToWhitespace[

    ( Find corresponding symbol: )
    ctx.package ]makeSymbol -> sym

    ( Load the symbol onto the stack: )
    sym asm assembleConstant

    ( Push a VAR_BIND frame: )
    'pushVariableBinding asm assembleCall

    ( Remember we need to do a POP_VAR_BINDING: )
    ctx.syntax -> s
    0         s push
    :varBind s push
;
'=> export

( =====================================================================	)
( - =>fn --								)

:   =>fn  { $ -> }   -> ctx    compileTime
    ctx.asm -> asm

    ( Read name of symbol to bind: )
    ctx readTokenToWhitespace[

    ( Find corresponding symbol: )
    ctx.package ]makeSymbol -> sym

    ( Load the symbol onto the stack: )
    sym asm assembleConstant

    ( Push a FUN_BIND frame: )
    'pushFunctionBinding asm assembleCall

    ( Remember we need to do a POP_FUN_BINDING: )
    ctx.syntax -> s
    0         s push
    :funBind s push
;
'=>fn export

( =====================================================================	)
( - doForArg -- local support for 'for' fn				)

:   doForArg   { $ -> $ }   -> ctx

    ctx.asm -> asm

    ( Need to compile code for value,   )
    ( save it in slot, and return slot: )

    compile:modeGet ctx compilePath

    "" asm assembleVariableSlot -> slot
    slot asm assembleVariableSet

    slot
;

( =====================================================================	)
( - for -- 								)

:   for   { $ -> }   -> ctx   compileTime
    ctx.asm -> asm

    ( Full syntax is "for i from 0 upto 1 by 0.1 do{ ... }": )

    ( Initialize some state: )
    nil -> aboveSlot    nil -> uptoSlot   nil -> fromSlot
    nil -> belowSlot    nil -> dntoSlot   nil -> bySlot

    ( Read index variable: )
    ctx makeLocalVar -> idxSlot

    ( Parse "from" "upto" "by" sequence, )
    ( which are all optional:            )
    do{
	( Read next token: )
	ctx readLocalVarName[

	( Done when we reach "do{": )
	"do{" |= until

	( Dispatch on various keywords: )	

	"from"   |= if   ]pop   ctx doForArg -> fromSlot   loopNext   fi
	"upto"   |= if   ]pop   ctx doForArg -> uptoSlot   loopNext   fi
	"downto" |= if   ]pop   ctx doForArg -> dntoSlot   loopNext   fi
	"by"     |= if   ]pop   ctx doForArg -> bySlot     loopNext   fi
	"above"  |= if   ]pop   ctx doForArg -> aboveSlot  loopNext   fi
	"below"  |= if   ]pop   ctx doForArg -> belowSlot  loopNext   fi
        ]join "Unrecognized 'for' loop keyword: " swap join simpleError
    }

    ]pop

    ( Decide whether to stop at or  )
    ( just short of limiting value: )
    aboveSlot belowSlot or -> skipLimit

    ( Increment or decrement? )
    aboveSlot dntoSlot or -> down
    belowSlot uptoSlot or -> up

    ( Allocate labels for our loop: )
    asm assembleLabelGet -> top
    asm assembleLabelGet -> bot
    asm assembleLabelGet -> xit



    ( Set initial value in )
    ( our local var slot:  )

    fromSlot if
	( We could re-use fromSlot as idxSlot )
        ( if we wanted to be cute, but *shrug*: )
	fromSlot asm assembleVariableGet
    else
	0 asm assembleConstant
    fi

    bySlot if
        bySlot asm assembleVariableGet
    else        
	1 asm assembleConstant
    fi

    down if '+ else '- fi asm assembleCall

    idxSlot asm assembleVariableSet


    ( Generate top of loop: )
    xit ctx compile:pushExit
    bot ctx compile:pushBottom
    top ctx compile:pushTop
    top asm assembleLabel



    ( Deposit code to de/increment )
    ( loop variable appropriately: )

    idxSlot asm assembleVariableGet

    bySlot if
        bySlot asm assembleVariableGet
    else        
	1 asm assembleConstant
    fi

    down if '- else '+ fi asm assembleCall

    idxSlot asm assembleVariableSet



    ( Deposit code to exit when   )
    ( loop var reaches limit var: )
    down up or if

	idxSlot asm assembleVariableGet

	skipLimit if

	    aboveSlot if aboveSlot else belowSlot fi
            asm assembleVariableGet

	    up if '< else '> fi asm assembleCall

	else
	    dntoSlot if dntoSlot else uptoSlot fi
            asm assembleVariableGet

	    up if '<= else '>= fi asm assembleCall
	fi

	xit asm assembleBeq
    fi

    ( Push endOfScope fn to be called by '}' fn: )
    'endOfLoop ctx.syntax push
;
'for export

( =====================================================================	)
( - doForeach -- 							)

:   doForeach   { $ $ $ -> }
 
    -> ctx       ( Compile context                )
    -> nextKey  ( 'hiddenGetNextKey? or such )
    -> getVal   ( 'hiddenGet or such           )

    ctx.asm -> asm

    ( Full syntax is "obj foreach key     do{ ... }"  )
    (             or "obj foreach key val do{ ... }": )

    ( Read index variable: )
    ctx makeLocalVar -> keySlot

    ( Read next token: )
    ctx readLocalVarName[

    ( Done when we reach "do{": )
    "do{" |= if
	]pop
	nil -> valSlot
    else
	( Convert to slot: )
        ctx ]makeLocalVar -> valSlot

        ( Read the do{: )
        ctx readLocalVarName[
        "do{" |= not if
	    ]join "Expected do{ got " swap join simpleError
	fi
	]pop
    fi

    ( Create an anonymous local    )
    ( variable to hold target obj: )
    "" asm assembleVariableSlot -> objSlot

    ( Pop object into its var: )
    objSlot asm assembleVariableSet

    ( Allocate labels for our loop: )
    asm assembleLabelGet -> top
    asm assembleLabelGet -> bot
    asm assembleLabelGet -> xit

    ( Initialize key to minkey: )
    firstKey asm assembleConstant
    keySlot asm assembleVariableSet

    ( Generate top of loop: )
    xit ctx compile:pushExit
    bot ctx compile:pushBottom
    top ctx compile:pushTop
    top asm assembleLabel

    ( Deposit code to find next  )
    ( key in object:             )
    objSlot asm assembleVariableGet
    keySlot asm assembleVariableGet
    nextKey asm assembleCall
    keySlot asm assembleVariableSet

    ( Deposit code to exit  )
    ( if no keys left:      )
    xit asm assembleBeq

    ( Optionally deposit code to set 'val' var: )
    valSlot if
	objSlot asm assembleVariableGet
	keySlot asm assembleVariableGet
	getVal  asm assembleCall
	valSlot asm assembleVariableSet
    fi

    ( Push endOfScope fn to be called by '}' fn: )
    'endOfLoop ctx.syntax push
;


( =====================================================================	)
( - foreach -- 								)

:   foreach { $ -> }   -> ctx   compileTime
    'get 'getNextKey? ctx doForeach
;
'foreach export


( =====================================================================	)
( - foreachAdmins -- 							)

:   foreachAdmins { $ -> }   -> ctx   compileTime
    'adminsGet 'adminsGetNextKey? ctx doForeach
;
'foreachAdmins export


( =====================================================================	)
( - foreachHidden -- 							)

:   foreachHidden { $ -> }   -> ctx   compileTime
    'hiddenGet 'hiddenGetNextKey? ctx doForeach
;
'foreachHidden export


( =====================================================================	)
( - foreachMethod -- 							)

( :   foreachMethod { $ -> }   -> ctx   compileTime )
(    'methodGet 'methodGetNextKey? ctx doForeach )
( ; )
( 'foreachMethod export )


( =====================================================================	)
( - foreachSystem -- 							)

:   foreachSystem { $ -> }   -> ctx   compileTime
    'systemGet 'systemGetNextKey? ctx doForeach
;
'foreachSystem export


( =====================================================================	)
( - compileColon -- Handle start of function				)

:   compileColon   { $ -> ! }   -> oldCtx
    compileTime

    oldCtx.symbols  -> symbols
    symbols length2 -> symbolsSp

    ( Allocate a new context in which to compile fn: )
    [   :ephemeral  t
        :mss        oldCtx.mss
        :package    @.lib["muf"]
        :symbols    symbols
        :symbolsSp symbolsSp
        :syntax     oldCtx.syntax
    | 'compile:context ]makeStructure -> ctx

    -1 --> ctx.arity

    makeFunction -> fun

    ( Read next token (fnName) and stash: )
    [ ctx.mss | |scanTokenToNonwhitespace ]pop
    [ ctx.mss | |scanTokenToWhitespace
    |pop -> lineloc
    |readTokenChars   ( Get token chars as block.      )
    |backslashesToHighbit
(   |downcase )
    ]join    ->     fnName

    fnName  --> ctx.fnName
    lineloc --> ctx.fnLine

    ctx.asm  -> asm
    lineloc --> asm.fnLine
    0       --> asm.lineInFn
    fnName  --> asm.fnName

    ( Push fn name on symbols stack: )
    fnName :fn nil ctx compile:noteLocal

    ( Mark scope on stack: )
    0 ctx compile:pushColon

    ( Loop compiling rest of function.  We  )
    ( exit this loop by compileSemi doing  )
    ( a GOTO to semiTag when we hit a ';': )
    withTag semiTag do{
        do{
            compile:modeGet ctx compilePath
        }
        semiTag
    }

    ( Finish assembly to produce actual  )
    ( compiled function.  We don't check )
    ( for zero bytecodes here because a  )
    ( null function can be useful:       )
    ctx.force ctx.arity fun ctx.asm finishAssembly -> cfn
    ""     --> fun.source
    cfn    --> fun.executable
    fnName --> fun.name

    ( Pop any nested symbols off symbol stack: )
    do{ symbols length2  symbolsSp = until
        symbols pull -> sym
    }	

    ( If function called itself, 'sym' will now )
    ( be the symbol through which the recursive )
    ( call was indirected, and we need to slot  )
    ( the compiledFunction into it:            )
    sym if cfn --> sym.function fi

    ( If we're at outmost level, should declare )
    ( function in a global symbol, otherwise we )
    ( just remember it on locals stack:         )
    oldCtx.outermost if
	fnName intern -> sym
	cfn --> sym.function
    else
	fnName :fn cfn ctx compile:noteLocal
    fi

    ( Save assembler for possible re-use: )
    ctx.asm --> @.spareAssembler
;
'compileColon export
":" intern -> sym   sym export   #'compileColon --> sym.function

( =====================================================================	)
( - compileColonColon -- Handle start of anonymous function		)

:   compileColonColon { $ -> ! }   -> oldCtx
    compileTime


    oldCtx.symbols -> symbols
    symbols length2 -> symbolsSp

    ( Allocate a new context in which to compile fn: )
    [   :ephemeral t
        :mss        oldCtx.mss
        :package    @.lib["muf"]
        :symbols    symbols
        :symbolsSp symbolsSp
        :syntax     oldCtx.syntax
    | 'compile:context ]makeStructure -> ctx

    -1 --> ctx.arity

    makeFunction -> fun

    ( Mark scope on stack: )
    0 ctx compile:pushColon

    ( Loop compiling rest of function.  We  )
    ( exit this loop by compileSemi doing  )
    ( a GOTO to semiTag when we hit a ';': )
    withTag semiTag do{
        do{ compile:modeGet ctx compilePath }
        semiTag
    }

    ( Finish assembly to produce actual  )
    ( compiled function.  We don't check )
    ( for zero bytecodes here because a  )
    ( null function can be useful:       )
    ctx.force ctx.arity fun ctx.asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    ( Pop any nested symbols off symbol stack: )
    do{ symbols length2  symbolsSp = until
        symbols pull -> sym
    }	

    ( Save assembler for possible re-use: )
    ctx.asm --> @.spareAssembler

    ( Deposit code to load compileFn on stack: )
    cfn oldCtx.asm assembleConstant ( Assemble string as const )
;
'compileColonColon export
"::" intern -> sym   sym export   #'compileColonColon --> sym.function

( =====================================================================	)
( - compileSemi -- Handle end of function				)

:   compileSemi { $ -> ! }   -> ctx
    compileTime

    ( Check ';' correctly matches a ':' or such: )
    ctx compile:popColon pop

    ( Jump to compileColon or such to )
    ( finish compilation of function:  )
    'semiTag goto
;
'compileSemi export
";" intern -> sym   sym export   #'compileSemi --> sym.function


( =====================================================================	)
( - compile-]} -- Handle end of lambda list				)

:   compile-]} { $ -> ! }   -> ctx
    compileTime

    ( This is an exact clone of compileSemi, )
    ( except it jumps to braceTag instead of )
    ( semiTag:                               )
    ctx compile:popColon pop
    'braceTag goto
;
'compile-]} export
"]}" intern -> sym   sym export   #'compile-]} --> sym.function

( =====================================================================	)
( - Install muf:compileFile as default compiler muf:compileMufFile	)

#'compileFile --> #'compileMufFile



( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

@c
@node Muf Syntax Fns Wrapup, Function Index, Muf Syntax Fns Source, Muf Syntax Fns
@section Muf Syntax Fns Wrapup

This completes the in-db @sc{muf}-compiler chapter.  If you have
questions or suggestions, feel free to email cynbe@@sl.tcp.com.
