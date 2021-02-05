@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Mos Syntax Fns, Mos Syntax Fns Overview, Muf Syntax Fns Wrapup, Top
@chapter Muf Compiler

@menu
* Mos Syntax Fns Overview::
* Mos Syntax Fns Source::
* Mos Syntax Fns Wrapup::
@end menu

@c
@node Mos Syntax Fns Overview, Mos Syntax Fns Source, Mos Syntax Fns, Mos Syntax Fns
@section Mos Syntax Fns Overview

This chapter documents the syntax functions
supporting the Muq Object System for
the in-db (@sc{muf}) implementation of the
@sc{muf} compiler, and includes all the source for
them.  You most definitely do not need to read or
understand this chapter in order to write
application code in @sc{muf}, but you may find it
interesting if you are curious about the internals
of the @sc{muf} compiler, or are interested in
writing a Muq compiler of your own.

@c
@node Mos Syntax Fns Source, Mos Syntax Fns Wrapup, Mos Syntax Fns Overview, Muf Compiler
@section Mos Syntax fns Source

Here it is, the complete source.

Eventually, I intend to have the source more
intricately formatted in literate-programming
style, but for now you get it in one great glob:

@example  @c

( - 160-C-muf-syntax.muf -- Generic-fn syntax for "Multi-User Forth".	)
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
( Created:      96Aug17							)
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
( - Quote.								)

( "Although Ceylon [Sri Lanka] has seen its share of crimes and follies	)
( in high places, the people seem reasonably free of that fantastic	)
( lack of ordinary common sense that so enlivens travel in India."	)
(   -- L Sprague de Camp, Great Cities Of The Ancient World.		)

( =====================================================================	)
( - Select MUF Package:							)

"muf" inPackage

( =====================================================================	)
( - Types -								)



( =====================================================================	)
( - Public fns -							)

( =====================================================================	)
( - defgeneric: -- Define a generic function				)

( We need to compile a function which does roughly:			)
(  -> Find class C of first argument.					)
(  -> Find key G of C.							)
(  -> Search G for all object methods matching				)
(    on object and generic function, and try each.			)
(    for all classes K in C.gkey.precedence_list, in order, do:	)
(  ->    Set G = K.key							)
(  ->    Search G for all class methods matching generic fn, and try each. )
(    }									)
(    Signal 'no appropriate method found' exception.			)
(									)
( In the above, to 'try' a method means:				)
( For each required arg R -- # must match in argblock and method --	)
(   Check qualifer type in method for R.				)
(   If qualifier type is object, qualifier value must equal R		)
(   else try fails.							)
(   Otherwise qualifier type is class:					)
(   -> Qualifier value must be in R.class.key.precedence list,		)
(   else try fails.							)
( If above loop terminates without failing, call method.cfn		)
( for method which matched: Return value is return value for generic fn	)

( For a first cut, we'll keep things very simple: )

:   defgeneric: { $ -> ! }   -> ctx
    compileTime

    ( Read next token (genericName) and stash: )
    [ ctx.mss | |scanTokenToNonwhitespace ]pop
    [ ctx.mss | |scanTokenToWhitespace
    |popp ( lineloc )
    |readTokenChars   ( Get token chars as block. )
    |backslashesToHighbit
(   |downcase )
    ]join    ->     fnName

    ( Next token should be '{' opening arity declaration: )
    [ ctx.mss | |scanTokenToNonwhitespace ]pop
    [ ctx.mss | |scanTokenToWhitespace
    |popp ( lineloc )
    |readTokenChars   ( Get token chars as block. )
    ]join -> token
    token "{" = if

	nil -> usingLambda
	( Parse and reduce arity: )    
	ctx parseArity -> force -> arity

	( Take a peek at arity: )
	arity explodeArity
	-> typ
	-> argsOut
	-> blksOut 
	-> argsIn
	-> blksIn
	blksIn 0 != if
	    "defgeneric: input blocks not supported" simpleError
	fi
    else
	token "{[" = if
	    t -> usingLambda
	    0 -> argsIn
	    1 0 1 0 arityNormal implodeArity -> arity
	    do{
		( Read next token: )
		[ ctx.mss | |scanTokenToNonwhitespace ]pop
		[ ctx.mss |
		|scanTokenToWhitespace
		|popp ( lineloc )
		|readTokenChars
		|backslashesToHighbit
(		|downcase )
		]join -> token

		token case{
		on: "$"     ++ argsIn
		on: "]}"    loopFinish
		else:
		    "Unexpected token in defgeneric {[ ... ]}: "
		    token join simpleError
		}
	    }
	else
	    "defgeneric: expected '{' or '{['" simpleError
	fi
    fi

    ( Next token should be ';' closing generic declaration: )
    [ ctx.mss | |scanTokenToNonwhitespace ]pop
    [ ctx.mss | |scanTokenToWhitespace
    |popp ( lineloc )
    |readTokenChars   ( Get token chars as block. )
    ]join ";" = not if
	"defgeneric: expected ';'" simpleError
    fi

    ( Create function instance proper: )
    makeFunction  -> fun
    makeAssembler -> asm
    fnName       --> fun.name
    argsIn	  --> fun.specializedParameters



    ( Hand-assemble code for generic function: )



    ( Find 1st arg, save in variable: )
    "arg"          asm assembleVariableSlot -> arg1
    usingLambda if
	0          asm assembleConstant
	'|dupNth asm assembleCall
    else
	argsIn    asm assembleConstant
	'dupNth  asm assembleCall
    fi
    arg1           asm assembleVariableSet



    ( Box up arguments: )
    usingLambda if
	0            asm assembleConstant
	argsIn      asm assembleConstant
	'|subblock[ asm assembleCall
    else
	argsIn      asm assembleConstant
	'dup[       asm assembleCall
    fi



    ( Find mosKey of 1st arg, save in variable: )
    "key1" asm assembleVariableSlot -> key1
    arg1 asm assembleVariableGet
    'getMosKey asm assembleCall
    key1 asm assembleVariableSet



    ( -> Search G for all object methods matching	)
    (    on object and generic function, and try each.	)
    "method1" asm assembleVariableSlot -> method1

    ( Initialize count of slot: )
    "slot1" asm assembleVariableSlot -> slot1
    0 asm assembleConstant
    slot1 asm assembleVariableSet

    ( Deposit top of loop: )
    asm assembleLabelGet -> loopTop1
    asm assembleLabelGet -> loopBot1
    loopTop1 asm assembleLabel

    ( Deposit code to search for next )
    ( matching object method:         )
    key1 asm assembleVariableGet		  ( Key to search.	)
    0 asm assembleConstant			  ( 1st argument.	)
    'currentCompiledFunction asm assembleCall ( Generic fn itself.	)
    arg1 asm assembleVariableGet    		  ( Object to key on.	)
    slot1 asm assembleVariableGet		  ( Start search here.	)
    'findMosKeyObjectMethod? asm assembleCall
    slot1   asm assembleVariableSet		  ( Remember new slot.	)
    method1 asm assembleVariableSet		  ( Remember method.	)
    loopBot1 asm assembleBeq			  ( Jump if no method	)

    ( Found an object method, )
    ( so see if it matches on )
    ( the remaining args.  If )
    ( not, try next method:   )
    method1 asm assembleVariableGet
    '|applicableMethod? asm assembleCall
    loopTop1 asm assembleBeq			( Jump if not applicable )

    ( Okie method matches on all )
    ( qualifiers, go ahead and   )
    ( call it, then return:      )
    ']pop asm assembleCall			( Discard copy of args	)
    method1 asm assembleVariableGet		( Get method		)
    :compiledFunction asm assembleConstant
    'systemGet asm assembleCall		( Compiled-fn to call	)
    'call       asm assembleCall		( Call it		)
    'return     asm assembleCall		( Done!			)

    ( Deposit bottom of loop: )
    loopBot1 asm assembleLabel



    ( Okie, no applicable object methods in this key object.   )


    ( Loop over class methods in key: )

    ( Initialize count of slot: )
    0 asm assembleConstant
    slot1 asm assembleVariableSet

    ( Deposit top of loop: )
    asm assembleLabelGet -> loopTop3
    asm assembleLabelGet -> loopBot3
    loopTop3 asm assembleLabel

    ( Deposit code to search for next )
    ( matching class method:          )
    key1 asm assembleVariableGet		  ( Key to search.	)
    0 asm assembleConstant			  ( 1st argument.	)
    'currentCompiledFunction asm assembleCall ( Generic fn itself.	)
    slot1 asm assembleVariableGet		  ( Start search here.	)
    'findMosKeyClassMethod? asm assembleCall
    slot1   asm assembleVariableSet		  ( Remember new slot.	)
    method1 asm assembleVariableSet		  ( Remember method.	)

    loopBot3 asm assembleBeq			  ( Jump if no method	)

    ( Found a class method,   )
    ( so see if it matches on )
    ( the remaining args.  If )
    ( not, try next method:   )
    method1 asm assembleVariableGet
    '|applicableMethod? asm assembleCall
    loopTop3 asm assembleBeq			( Jump if not applicable )

    ( Okie method matches on all )
    ( qualifiers, go ahead and   )
    ( call it, then return:      )
    ']pop asm assembleCall			( Discard copy of args	)
    method1 asm assembleVariableGet		( Get method		)
    :methodFunction asm assembleConstant
    'systemGet asm assembleCall		( Compiled-fn to call	)
    'call       asm assembleCall		( Call it		)
    'return     asm assembleCall		( Done!			)


    ( Bottom of loop3 )

    ( Deposit bottom of loop: )
    loopBot3 asm assembleLabel



    ( Okie, no applicable methods in this key object;  )
    ( Time to try generic methods hung off generic fn: )


    ( Allocate labels for subsequent loop: )
    asm assembleLabelGet -> loopTop5
    asm assembleLabelGet -> loopBot5

    ( Find function object for generic function: )
    "src1" asm assembleVariableSlot -> src1
    'currentCompiledFunction asm assembleCall ( Generic fn itself.	)
    :source asm assembleConstant
    'systemGet asm assembleCall
    src1 asm assembleVariableSet
    src1 asm assembleVariableGet
    'function? asm assembleCall
    loopBot5 asm assembleBeq		( No function for compiledFn?! )

    ( Find key with default methods: )
    src1 asm assembleVariableGet
    :defaultMethods asm assembleConstant
    'systemGet asm assembleCall
    key1 asm assembleVariableSet
    key1 asm assembleVariableGet
    'mosKey? asm assembleCall
    loopBot5 asm assembleBeq		( No default methods to check. )


    ( Initialize count of slot: )
    0 asm assembleConstant
    slot1 asm assembleVariableSet

    ( Deposit top of loop: )
    loopTop5 asm assembleLabel

    ( Deposit code to search for next )
    ( matching class method:          )
    key1 asm assembleVariableGet		  ( Key to search.	)
    0 asm assembleConstant			  ( 1st argument.	)
    'currentCompiledFunction asm assembleCall ( Generic fn itself.	)
    slot1 asm assembleVariableGet		  ( Start search here.	)
    'findMosKeyClassMethod? asm assembleCall
    slot1   asm assembleVariableSet		  ( Remember new slot.	)
    method1 asm assembleVariableSet		  ( Remember method.	)

    loopBot5 asm assembleBeq			  ( Jump if no method	)

    ( Found a class method,   )
    ( so see if it matches on )
    ( the remaining args.  If )
    ( not, try next method:   )
    method1 asm assembleVariableGet
    '|applicableMethod? asm assembleCall
    loopTop5 asm assembleBeq			( Jump if not applicable )

    ( Okie method matches on all )
    ( qualifiers, go ahead and   )
    ( call it, then return:      )
    ']pop asm assembleCall			( Discard copy of args	)
    method1 asm assembleVariableGet		( Get method		)
    :methodFunction asm assembleConstant
    'systemGet asm assembleCall		( Compiled-fn to call	)
    'call       asm assembleCall		( Call it		)
    'return     asm assembleCall		( Done!			)

    ( Deposit bottom of loop: )
    loopBot5 asm assembleLabel





    ( Couldn't find any applicable methods: )
    "No applicable methods for generic function" asm assembleConstant
    'simpleError asm assembleCall
    


    ( Finish assembly to produce actual  )
    ( compiled function.  We don't check )
    ( for zero bytecodes here because a  )
    ( null function can be useful:       )
    ( Since the 'calls' in the generic   )
    ( are sure to give the arity deducer )
    ( fits, always force the arity:      )
    :mosGeneric --> asm.flavor
    t -> force
    force arity fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    fnName intern -> sym
( buggo, prolly wanna avoid overwriting existing generic )
( unless signature is different. )
    cfn --> sym.function
;
'defgeneric: export


( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

@c
@node Mos Syntax Fns Wrapup, Function Index, Mos Syntax Fns Source, Mos Syntax Fns
@section Mos Syntax Fns Wrapup

This completes the in-db @sc{muf}-compiler Mos Object System support chapter.
If you have questions or suggestions, feel free to email cynbe@@muq.com.


