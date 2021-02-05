@c - This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)
@example  @c

( - 211-C-muc-compiler.muf -- Code generation for Multi-User-C.		)
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
( Created:      99Sep19							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 2000, by Jeff Prothero.				)
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
( - Quote			             				)

(	"They say that with the really big ones, you can see		)
(	 the front coming... an impossibly huge semitransparent		)
(	 grey curtain, like an amoeba the size of Canada.		)
(	 The grey is dust, pollen and suchlike driven			)
(	 just ahead of the front.  Tendrils extend southward		)
(	 ahead of the main mass;  you can feel the temperature		)
(	 fluctuating abruptly.  Sometimes the rapidly changing		)
(	 air pressure sets up resonances between the ground		)
(	 and the thermocline, producing low-frequency pulses		)
(	 like distant cannon fire.  Dogs howl; cattle bawl		)
(	 and run aimlessly;  humans become uneasy and skittish."	)
(									)
(  This file contains a slightly different kind of front end! *grin*	)


( =====================================================================	)
( - Package			             				)

"MUC" rootValidateDbfile pop
[ "muc" .db["MUC"] | ]inPackage

( =====================================================================	)
( - TO DO			             				)

( Need to do switch (...) {...}                                         )
( Need to do 'a$h.b;'                                                   )
( Need to do 'a:b                                                       )
( Need to do constant folding.                                          )
( Need to do struct definitions.                                        )
( Need to do += -= /= %= &= |= ^= for nontrivial args                   )
( Need to do ++ -- for nontrivial args                                  )
( Need to do class definitions.                                         )
( Need to do arrays.                                                    )
( Need to do calls to runtime-specified fns: cast syntax for arity?     )
( Need to do 'a.b.f()'                                                  )
( Need to do functions with optional args &tc                           )
( Need to do better error checking most everywhere!                     )
( Need to do something about #define CONST 113                          )
( Need to do something about enum { ... }                               )
( Need to do 'try' (exception handling). Python syntax? C++} setjmp()?  )
( Need to do 'after {...} always do {...}                               )
( Need to make 'for (;;) {...}' an infinite loop.                       )
( Need to do "float a[] = {1.0,2.0,3.0};"			        )
( Need to support C++ new-vector syntax "new int [16];" or equivalent.	)
( Need to let /* comments */ span more than one line.			)
( NEED TO HACK PARSER TO WORK MULTI-USER.                               )
( I think we should junk =~ ... ~= is better if we need it.             )
( I think we should implement 'x ~= tr/A-Z/a-z/ (str);'			)
( I think we should implement 'x ~= s/regex/replacement/ (str);'	)
( I think we should have a 'muc("code;");' to compile+eval a string.    )
( Should we support 'statement &;' to fork to background ala unix?      )
( Should likely support 'package muc;' as sugar for 'inPackage("muc");  )
( How should we return a block?  "return [a,b,c];"...?                  )
( Should we support "*/" and "+/" for product and sum of a vector?      )
( How about  when a,b,c=f(x,y,z) {...}   syntax for asynch ops?         )

( =====================================================================	)
( - prettyPrintNode		             				)

:   prettyPrintNode { $ $ -> }
    -> deep
    -> node
    for i from 0 below deep do{
	i 1 logand 0 = if '|' else ' ' fi ,
    }
    node vector? if
	"[ " ,
	node length -> len
	len 0 > if
	    node[0] , "\n" ,
	    for i from 1 below len do{
		node[i]   deep 2 +   'prettyPrintNode call{ $ $ -> }
	    }
	fi
	for i from 0 below deep do{
	    i 1 logand 0 = if '|' else ' ' fi ,
	}
	"]\n" ,
    else
	node , '\n' ,
    fi
;
( A -real- prettyprint puts subexpressions on one line when they )
( will fit reasonably.  Be nice to modify the above to do that.  )

( =====================================================================	)
( - prettyPrint			             				)

:   prettyPrint { $ -> }
    -> node
    node 0 prettyPrintNode
;

( =====================================================================	)
( - balanceArgs -- match actual return values to needed pattern		)

:   balanceArgs { $ $ $ $ $ -> }
    -> argsWant
    -> blksWant
    -> argsHave
    -> blksHave
    -> x		( Context for compile.	)

    @.yydebug if
	"balanceArgs: mapping []" , 
        blksHave , " " , argsHave ,
        " -> []" , 
        blksWant , " " , argsWant ,
        "\n" ,
    fi

    ( Maybe caller wants us to ignore arity? )
    argsWant -1 =
    blksWant -1 =
    and if return fi

    ( Maybe we have nothing to do? )
    argsHave argsWant =
    blksHave blksWant =
    and if return fi

    ( Maybe all we need to do is pop stuff? )
    argsWant 0 =
    blksWant 0 = and if
	for i from argsWant below argsHave do{
	    'muf:pop x.asm assembleCall
	}
	for i from blksWant below blksHave do{
	    'muf:]pop x.asm assembleCall
	}
	return
    fi

    ( Maybe we need only pop some scalars? )
    blksHave blksWant = if
	argsHave argsWant < if
	    argsHave 0 = if "Attempt to use void result in expression" simpleError fi
	    argsHave 0 = if "Expression returns too few results"       simpleError fi
	fi
	for i from argsWant below argsHave do{
	    'muf:pop x.asm assembleCall
	}
	return
    fi
    
    ( Maybe we need to pop some scalars from a block? )
    argsHave 0 = 
    argsWant 0 > and
    blksWant 0 = and
    blksHave 1 = and if
	argsWant case{
        on: 1  	'muf:]shift  x.asm assembleCall    return
        on: 2  	'muf:]shift2 x.asm assembleCall    return
        on: 3  	'muf:]shift3 x.asm assembleCall    return
        on: 4  	'muf:]shift4 x.asm assembleCall    return
        on: 5  	'muf:]shift5 x.asm assembleCall    return
        on: 6  	'muf:]shift6 x.asm assembleCall    return
        on: 7  	'muf:]shift7 x.asm assembleCall    return
        on: 8  	'muf:]shift8 x.asm assembleCall    return
        on: 9  	'muf:]shift9 x.asm assembleCall    return
	else:
	    "Cannot currently unpack more than 9 args from return block" simpleError
	}
    fi
  
    "Expression returns wrong block/args signature for this context" simpleError
;

( =====================================================================	)
( - compileExpr -- Forward declaration	 				)

:   compileExpr { $ $ $ $ $ -> ! } ;

( =====================================================================	)
( - merge	-- Merge two possibly empty parsetrees			)

:   merge { $ $ -> $ }
    -> b
    -> a

    a not if b return fi
    b not if a return fi

    [ ';' a b ]
;

( =====================================================================	)
( - stripAllcrements	-- Remove and return pre/post-in/decrements	)

:   stripAllcrements { $ -> $ $ $ }
    -> node

    nil -> before
    nil -> after

    node vector? not if node before after return fi

    node length -> len
    len 2 = if

	node[1] -> subexpr

	node[0] case{

	on: '+'
	    subexpr vector? not if "stripAllcrements: internal err" simpleError fi
	    subexpr[0] 'v' != if "++ only supported on simple vars" simpleError fi
	    [ '=' subexpr [ 'muf:+ subexpr 1 ] ] -> after
	    subexpr -> node
	    node before after return

	on: '-'
	    subexpr vector? not if "stripAllcrements: internal err" simpleError fi
	    subexpr[0] 'v' != if "-- only supported on simple vars" simpleError fi
	    [ '=' subexpr [ 'muf:- subexpr 1 ] ] -> after
	    subexpr -> node
	    node before after return

	on: 'p'
	    subexpr vector? not if "stripAllcrements: internal err" simpleError fi
	    subexpr[0] 'v' != if "++ only supported on simple vars" simpleError fi
	    [ '=' subexpr [ 'muf:+ subexpr 1 ] ] -> before
	    subexpr -> node
	    node before after return

	on: 's'
	    subexpr vector? not if "stripAllcrements: internal err" simpleError fi
	    subexpr[0] 'v' != if "-- only supported on simple vars" simpleError fi
	    [ '=' subexpr [ 'muf:- subexpr 1 ] ] -> before
	    subexpr -> node
	    node before after return


	}
    fi

    ( Don't hoist side-effects out of loops or such: )
    node[0] case{
    on: '['	( Ok to hoist out of a[b] expressions.	)
    on: '('	( Ok to hoist out of f(x) expressions.	)
    on: '.'	( Ok to hoist out of a.b  expressions.	)
    else:
	( Ok to hoist out of a+b (&tc) expressions: )
        node[0] symbol? not if node before after return fi
    }

    ( Hoist de/increments out of all subexpressions of node: )
    for i from 1 below len do{
	node[i] 'stripAllcrements call{ $ -> $ $ $ } -> a -> b --> node[i]
	a after  merge -> after
	b before merge -> before
    }

    node before after return
;

( =====================================================================	)
( - compileNode		-- compileExpr with side-effect handling	)

:   compileNode  { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Next is a useful debug trace: )
    @.yydebug if
	"compileNode prettyPrinting node:\n" ,
	node prettyPrint
    fi

    ( Collect ++/-- code in 'before'/'after': )
    node stripAllcrements -> after -> before -> node

    ( Assemble all code for node: )
    before if before x 0    0    0    compileExpr fi
    node             x blks args mode compileExpr
    after  if after  x 0    0    0    compileExpr fi
;

( =====================================================================	)
( - compileAdotB	-- 'a.b'	 				)

:   compileAdotB { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile 'a.b': )

    node[1] -> a
    node[2] -> b

    a x 0 1 0 compileExpr

    b vals[ ':' |unshift |backslashesToHighbit x.package ]makeSymbol -> sym
    sym x.asm assembleConstant

    mode compile:modeSet logand 0 != if
        'muf:set x.asm assembleCall
    else
        'muf:get x.asm assembleCall
         x 0 1 blks args balanceArgs
    fi
;

( =====================================================================	)
( - compileAsubB	-- 'a[b]'	 				)

:   compileAsubB { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile 'a[b]': )

    node[1] -> a
    node[2] -> b

    a x 0 1 0 compileExpr
    b x 0 1 0 compileExpr

    mode compile:modeSet logand 0 != if
        'muf:set x.asm assembleCall
    else
        'muf:get x.asm assembleCall
         x 0 1 blks args balanceArgs
    fi
;

( =====================================================================	)
( - compileBlock	-- '{...}'	 				)

:   compileBlock { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile '{...}': )

    x.symbols -> symbols
    nil      --> x.outermost

    ( Note number of local symbols defined: )
    symbols length -> startingDepth

    ( Assemble code for block: )
    node[1] x 0 0 0 compileNode

    ( Pop all local symbols defined within block: )
    do{   symbols length   startingDepth   >   while
	symbols pull pop
    }
;

( =====================================================================	)
( - compileSequence			 				)

:   compileSequence { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile a simple sequence of statements: )
    node length -> len
    for i from 1 below len do{
	node[i] x 0 0 0 compileNode
    }
;

( =====================================================================	)
( - compileIfThen			 				)

:   compileIfThen { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile an if-then statement: )

    ( Allocate the tag at end of conditional: )
    x.asm assembleLabelGet -> end

    ( Compile the condition code itself: )
    node[1] x 0 1 0 compileNode

    ( Deposit the branch over the conditional statement: )
    end x.asm assembleBeq

    ( Compile the conditional statement: )
    node[2] x 0 0 0 compileNode

    ( Deposit the terminal branch tag: )
    end x.asm assembleLabel
;

( =====================================================================	)
( - compileIfThenElse			 				)

:   compileIfThenElse { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile an if-then-else statement: )

    x.asm assembleLabelGet -> startOfElse
    x.asm assembleLabelGet -> endOfElse

    ( Compile the condition code itself: )
    node[1] x 0 1 0 compileNode
    startOfElse x.asm assembleBeq

    ( Compile the 'then' clause: )
    node[2] x 0 0 0 compileNode
    endOfElse x.asm assembleBra

    ( Compile the 'else' clause: )
    startOfElse x.asm assembleLabel
    node[3] x 0 0 0 compileNode
    endOfElse   x.asm assembleLabel
;

( =====================================================================	)
( - compileQColon			 				)

:   compileQColon { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile an '... ? ... : ...' )

    ( Buggo, for now this is identical to compileIfThemElse: )

    x.asm assembleLabelGet -> startOfElse
    x.asm assembleLabelGet -> endOfElse

    ( Compile the condition code itself: )
    node[1] x 0 1 mode compileNode
    startOfElse x.asm assembleBeq

    ( Compile the 'then' clause: )
    node[2] x blks args mode compileNode
    endOfElse x.asm assembleBra

    ( Compile the 'else' clause: )
    startOfElse x.asm assembleLabel
    node[3] x blks args mode compileNode
    endOfElse   x.asm assembleLabel
;

( =====================================================================	)
( - compileAmpAmp			 				)

:   compileAmpAmp { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile an '... && ...': )


    x.asm assembleLabelGet -> secondClause
    x.asm assembleLabelGet -> endOfExpression

    node[1] x 0 1 mode compileNode
    secondClause x.asm assembleBne
    nil x.asm assembleConstant
    endOfExpression x.asm assembleBra

    secondClause x.asm assembleLabel
    node[2] x 0 1 mode compileNode
    endOfExpression x.asm assembleLabel

    x 0 1 blks args balanceArgs
;

( =====================================================================	)
( - compileBarBar			 				)

:   compileBarBar { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile an '... || ...': )

    x.asm assembleLabelGet -> secondClause
    x.asm assembleLabelGet -> endOfExpression

    node[1] x 0 1 mode compileNode
    secondClause x.asm assembleBeq
    t x.asm assembleConstant
    endOfExpression x.asm assembleBra

    secondClause x.asm assembleLabel
    node[2] x 0 1 mode compileNode
    endOfExpression x.asm assembleLabel
;

( =====================================================================	)
( - compileDoWhile			 				)

:   compileDoWhile { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile a 'do{ ... } while (...);' )

    x.asm assembleLabelGet -> top	( where 'continue' should go	)
    x.asm assembleLabelGet -> bot
    x.asm assembleLabelGet -> xit	( where 'break' should go	)

    xit x compile:pushExit
    bot x compile:pushBottom
    top x compile:pushTop

    top     x.asm assembleLabel
    node[1] x 0 0 0 compileNode
    node[2] x 0 1 0 compileNode
    top     x.asm assembleBne
    xit     x.asm assembleLabel

    x compile:popTop    -> top
    x compile:popBottom -> bot
    x compile:popExit   -> xit
;

( =====================================================================	)
( - compileWhile			 				)

:   compileWhile { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile a 'while (...) {...}' )

    x.asm assembleLabelGet -> top	( where 'continue' should go	)
    x.asm assembleLabelGet -> bot
    x.asm assembleLabelGet -> xit	( where 'break' should go	)

    xit x compile:pushExit
    bot x compile:pushBottom
    top x compile:pushTop

    top     x.asm assembleLabel
    node[1] x 0 1 0 compileNode
    xit     x.asm assembleBeq
    node[2] x 0 0 0 compileNode
    top     x.asm assembleBra
    xit     x.asm assembleLabel

    x compile:popTop    -> top
    x compile:popBottom -> bot
    x compile:popExit   -> xit
;

( =====================================================================	)
( - compileFor				 				)

:   compileFor { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile a 'for (...;...;...) {...}' )

    node[1] -> init
    node[2] -> test
    node[3] -> step
    node[4] -> body

    x.asm assembleLabelGet -> top	( where 'continue' should go	)
    x.asm assembleLabelGet -> bot
    x.asm assembleLabelGet -> xit	( where 'break' should go	)
    x.asm assembleLabelGet -> lup

    xit x compile:pushExit
    bot x compile:pushBottom
    top x compile:pushTop

    init x 0 0 0 compileNode
    lup  x.asm  assembleLabel
    test x 0 1 0 compileNode
    xit  x.asm  assembleBeq
    body x 0 0 0 compileNode
    top  x.asm  assembleLabel
    step x 0 0 0 compileNode
    lup  x.asm  assembleBra
    xit  x.asm  assembleLabel

    x compile:popTop    -> top
    x compile:popBottom -> bot
    x compile:popExit   -> xit
;

( =====================================================================	)
( - compileSwitch			 				)

:   compileSwitch { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile a 'switch (expr) ...' )

3 2 < if return fi "compileSwitch: unimplemented" simpleError
;

( =====================================================================	)
( - compileCase				 				)

:   compileCase { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile a 'case 43: ...' )

3 2 < if return fi "compileCase: unimplemented" simpleError
;

( =====================================================================	)
( - compileDefault			 				)

:   compileDefault { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile a 'default: ...' )

3 2 < if return fi "compileDefault: unimplemented" simpleError
;

( =====================================================================	)
( - compileDelete			 				)

:   compileDelete { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile a 'delete ...' )

3 2 < if return fi "compileDelete: unimplemented" simpleError
;

( =====================================================================	)
( - compileGoto				 				)

:   compileGoto { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile a 'goto momma; ...' )

3 2 < if return fi "compileGoto: unimplemented" simpleError
;

( =====================================================================	)
( - compileTag				 				)

:   compileTag { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile a 'momma: ...' )

3 2 < if return fi "compileTag: unimplemented" simpleError
;

( =====================================================================	)
( - compileBreak			 				)

:   compileBreak { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile a 'break;' )

    ( Check that 'break;' is in a loop: )
    x.syntax :exit getKey? -> exitLoc not if
	"'break;' must be within a loop or case." simpleError
    fi

    ( Check that 'break;' isn't jumping out of   )
    ( an after {} always do {}.  We should allow )
    ( doing so some day, but need to do some     )
    ( work to preserve after{}alwaysDo{} first:  )
    x.syntax :after getKey? -> afterLoc if
	afterLoc exitLoc > if
	    "May not 'break;' from after {...} always do {...}." simpleError
    fi  fi
    x.syntax :always getKey? -> alwaysLoc if
	alwaysLoc exitLoc > if
	    "May not 'break;' from after {...} always do {...}." simpleError
    fi  fi

    ( Exit label is stored under :exit keyword: )
    exitLoc 1 -       -> exitLoc
    x.syntax[exitLoc] -> exitLoc

    ( Deposit branch to loop exit: )
    exitLoc x.asm assembleBra
;

( =====================================================================	)
( - compileContinue			 				)

:   compileContinue { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile a 'continue;' )

    ( Check that 'continue;' is in a loop: )
    x.syntax :top getKey? -> topLoc not if
	"'continue;' must be within a loop." simpleError
    fi

    ( Check that 'continue;' isn't jumping out of  )
    ( an after{ }alwaysDo{ }. (We should allow     )
    ( doing so some day, but need to do some       )
    ( work to preserve after{}alwaysDo{} first:    )
    x.syntax :after getKey? -> afterLoc if
	afterLoc topLoc > if
	    "May not 'continue' from after{ }always_do{ }." simpleError
    fi  fi
    x.syntax :always getKey? -> alwaysLoc if
	alwaysLoc topLoc > if
	    "May not 'continue;' from after{ }always_do{ }." simpleError
    fi  fi

    ( top label is stored under :top keyword: )
    topLoc 1 -       -> topLoc
    x.syntax[topLoc] -> topLoc

    ( Deposit branch to loop top: )
    topLoc x.asm assembleBra
;

( =====================================================================	)
( - compileReturn			 				)

:   compileReturn { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile a 'return;' or 'return expr;' )

    node length 2 = if node[1] x -1 -1 mode compileNode fi
    'muf:return x.asm assembleCall
;

( =====================================================================	)
( - countFunctionArgs			 				)

:   countFunctionArgs { $ -> $ }
    -> node
    node vector? not if 1 return fi
    node[0] ' '  =   if 0 return fi
    node[0] ',' !=   if 1 return fi

    node[1] 'countFunctionArgs call{ $ -> $ }
    node[2] 'countFunctionArgs call{ $ -> $ }
    +
;

( =====================================================================	)
( - compileSimpleFunctionArglist	 				)

:   compileSimpleFunctionArglist { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    node vector? if
	node[0] ',' = if
	    node[1] x 0 1 mode 'compileSimpleFunctionArglist call{ $ $ $ $ $ -> }
	    node[2] x 0 1 mode 'compileSimpleFunctionArglist call{ $ $ $ $ $ -> }
	    return
	fi
    fi
    
    node x 0 1 mode compileExpr
;

( =====================================================================	)
( - compileFunctionCall			 				)

:   compileFunctionCall { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile 'f(x,y,z);' )

    ( Unpack node: )
    node[1] -> fnExpr
    node[2] -> fnArgs

    ( Handy debug trace: )
    @.yydebug if
	"compileFunctionCall: node==\n" ,
        node prettyPrint
    fi

    ( fnExpr can be pretty complex in principle, )
    ( like in a[b].c(x) it will be a[b].c, but   )
    ( for a first go-around we support only f(x) )
    ( in which case fnExpr is [v fnname]:        )
    fnExpr compiledFunction? if
	@.yydebug if
	    "compileFunctionCall: simple direct cfn case\n" ,
	fi
	fnExpr -> cfn
	fnExpr -> sym
    else
	fnExpr[0] 'v' != if
	    "compileFunctionCall: Sorry, that's not supported yet" simpleError
	fi
	fnExpr[1] -> fnName

	( Is the function a local? )
	fnName vals[ x compile:|findLocal? -> sym -> typ -> nam -> pos ]pop
	typ :fn = if
	    sym not if "Recursive calls not yet supported" simpleError fi
	else

	    ( Search for global definition of function: )
	    fnName vals[
		x.package muf:|findSymbol? -> sym not if
		    ]pop
		    "Cannot locate function named: " fnName join simpleError
		fi
	    ]pop
	fi

	( Find the actual compiledFunction object for function: )
	sym symbol?  if  sym symbolFunction  else  sym  fi   -> cfn 
    fi
    cfn compiledFunction? not if
        "Symbol does not name a function: " fnName join simpleError
    fi

    ( How many args does function accept and return? )
    cfn.source.arity -> fnArity
    fnArity explodeArity -> typ -> argsOut -> blksOut -> argsIn -> blksIn
    @.yydebug if
	"compileFunctionCall: arity is []" , blksIn , " " , argsIn ,
        " -> []" , blksOut , " " , argsOut , "\n" ,
    fi

    fnArgs countFunctionArgs -> actualArgs

    ( Handle the simple block-free case: )
    blksIn  0  =
    blksOut 0  =     blksOut 1 =   argsOut 0 =   and     or
    and if
	argsIn actualArgs != if
	    [ "%s wants %d args but you supplied %d" fnName argsIn actualArgs | ]print simpleError
	fi

	argsIn 0 != if
            fnArgs x blksIn argsIn 0 compileSimpleFunctionArglist
	fi
        sym x.asm assembleCall
        x blksOut argsOut blks args balanceArgs
	return
    fi
        
    ( Handle the simple one-block-in case: )
    blksIn  1 =
    argsIn  0 =   and
    if
	'muf:startBlock x.asm assembleCall
        fnArgs x blks args mode compileSimpleFunctionArglist
        'muf:endBlock x.asm assembleCall
        sym x.asm assembleCall
        x blksOut argsOut blks args balanceArgs
	return
    fi

    [ "Don't know how to compile call to %s" fnName | ]print simpleError
;

( =====================================================================	)
( - compileVector	-- '{a,b,c}'	 				)

:   compileVector { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile '{a,b,c}': )

    ( Trivial optimization: Don't build vector )
    ( if it isn't going to be used:            )
    args 0 = 
    blks 0 = and if return fi

    node countFunctionArgs -> argc

    'muf:startBlock x.asm assembleCall
    node[2] x 0 argc 0 compileSimpleFunctionArglist
    'muf:endBlock x.asm assembleCall

    node[1] case{
    on: 'v'	'muf:]makeVector    x.asm assembleCall
    on: 'c'	'muf:]makeVectorI08 x.asm assembleCall
    on: 's'	'muf:]makeVectorI16 x.asm assembleCall
    on: 'i'	'muf:]makeVectorI32 x.asm assembleCall
    on: 'f'	'muf:]makeVectorF32 x.asm assembleCall
    on: 'd'	'muf:]makeVectorF64 x.asm assembleCall
    else:
	"compileVector: internal err" simpleError
    }

    x 0 1 blks args balanceArgs
;

( =====================================================================	)
( - compileEmptyStatement		 				)

:   compileEmptyStatement { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( For now, at least, we do nothing. )
    ( There may be some contexts where  )
    ( we need to issue error messages?  )

    x 0 0 blks args balanceArgs
;

( =====================================================================	)
( - compileSimpleLvalList		 				)

:   compileSimpleLvalList { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    node vector? if
	node[0] ',' = if
	    node[2] x 0 1 mode 'compileSimpleLvalList call{ $ $ $ $ $ -> }
	    node[1] x 0 1 mode 'compileSimpleLvalList call{ $ $ $ $ $ -> }
	    return
	fi
    fi
    
    node x 0 1 mode compileNode
;


( =====================================================================	)
( - compilePut				 				)

:   compilePut { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile 'expr = expr;' )

    ( See if we have multiple  )
    ( lvals on left hand side: )
    node[1] countFunctionArgs -> lvals

    ( See if we have multiple   )
    ( rvals on right hand side: )
    node[2] countFunctionArgs -> rvals

    ( Handle simple 'expr = expr;' case: )
    lvals 1 =
    rvals 1 = and if

	( Compile the right hand side: )
	node[2] x 0 1 mode compileNode

	( Compile the left hand side: )
	mode compile:modeSet logior -> mode
	node[1] x 0 args mode compileNode

	x 0 0 blks args balanceArgs

	return
    fi

    ( Handle 'a,b = b,a;' and such: )
    lvals rvals =
    rvals 1    >= and if

	( Compile the right hand side: )
        node[2] x 0 1 0    compileSimpleFunctionArglist

	( Compile the left hand side: )
        mode compile:modeSet logior -> mode
        node[1] x 0 1 mode compileSimpleLvalList
	return
    fi

    ( Handle 'a,b = f(x);' and such: )
    lvals 1 >
    rvals 1 = and if

	( Compile the right hand side: )
	node[2] x 0 lvals mode compileNode

	( Compile the left hand side: )
        mode compile:modeSet logior -> mode
        node[1] x 0 1 mode compileSimpleLvalList
	return
    fi

    "compilePut: Don't know how to compile this assignment" simpleError
;

( =====================================================================	)
( - compileAssignOp			 				)

:   compileAssignOp { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    node[1] -> lval
    node[2] -> assign_op
    node[3] -> rhs

    lval vector? not if "Cannot assign to a constant" simpleError fi
    lval[0]  'v' !=  if "lhs of assign op must be a simple var" simpleError fi
    ( buggo, need to remove above restriction. )

    lval x 0 1 0 compileExpr
    rhs  x 0 1 0 compileExpr
    assign_op x.asm assembleCall
    lval x 0 1 compile:modeSet compileExpr

    x 0 0 blks args balanceArgs
;

( =====================================================================	)
( - compileVarDeclaration		 				)

:   compileVarDeclaration { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile 'obj xyzzy;': )

    ( Unpack node: )
    node[1] -> varName

    x.outermost if

	( Compile global variable declaration )
	varName vals[ x.package ]makeSymbol pop

    else

	( Compile local variable declaration )

	( Allocate the local variable slot: )
	varName x.asm assembleVariableSlot -> varSlot

	( Remember local variable exists: )
	varName :var varSlot x compile:noteLocal
    fi

    x 0 0 blks args balanceArgs
;

( =====================================================================	)
( - compileVarReference			 				)

:   compileVarReference { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile 'ID' -- may be on either side of assignment: )

    ( Unpack node: )
    node[1] -> varName

    ( Unpack 'mode' bitbucket: )
    mode compile:modeSet     logand 0 != -> gotSet	( --> path	)
    mode compile:modeGet     logand 0 != -> gotGet	( path		)
    mode compile:modeDel     logand 0 != -> gotDel	( delete: path	)
    mode compile:modeFn      logand 0 != -> gotFn	( #'path	)
    mode compile:modeQuote   logand 0 != -> gotQuote	( 'path		)
    mode compile:modeConst   logand 0 != -> gotConst	( -->constant	)
    mode compile:modeInc     logand 0 != -> gotInc	( ++		)
    mode compile:modeDec     logand 0 != -> gotDec	( --		)

    ( Is the variable a local variable? )
    varName vals[ x compile:|findLocal? -> val -> typ -> nam -> pos ]pop
    typ :var != if

	( Not a local variable, is it a global? )
	varName vals[ x.package |findSymbol? -> sym if
            ]pop

	    ( Handle stores to variable: )
	    gotSet if
		( Deposit code to load symbol on stack: )
		sym x.asm assembleConstant

		( Deposit code to do the actual store: )
		'setSymbolValue x.asm assembleCall
		return
	    fi

	    ( Save an instruction by loading consts )
	    ( directly at runtime, instead of doing )
	    ( fetch from symbol:                    )
	    sym constant?   gotQuote not   and if
		sym symbolValue x.asm assembleConstant
		x 0 1 blks args balanceArgs
		return
	    fi

	    ( Assemble code to load symbol onto stack: )
	    sym x.asm assembleConstant

	    ( Handle vanilla loads of symbol value:  )
	    sym.function not if ( Pass fns as symbol )
		gotQuote not if
		    'symbolValue x.asm assembleCall	    
	    fi	fi
	
	    x 0 1 blks args balanceArgs
	    return
	fi
        ]pop

        "Unrecognized identifier: " varName join simpleError
    fi
    pos x.symbolsSp < if
        "Unsupported identifier: " varName join simpleError
    fi
    mode compile:modeSet logand 0 != if
        val x.asm assembleVariableSet
	return
    fi

    ( Simple optimization: skip the )
    ( load if we're just going to   )
    ( pop it anyhow:                )
    blks 0 =
    args 0 = and if return fi

    val x.asm assembleVariableGet

    x 0 1 blks args balanceArgs
;

( =====================================================================	)
( - findFunctionName			 				)

:   findFunctionName { $ -> $ }
    -> resultParamSyntax

    ( For now we'll handle just the trivial case: )
    resultParamSyntax -> fnName

    fnName
;

( =====================================================================	)
( - compileFunctionParameters		 				)

:   compileFunctionParameters { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Some functions have no parameters: )
    node not if return fi
 
    ( If node is a string it is name of parameter: )
    node string? if
	node x.asm assembleVariableSlot -> varSlot
	node :var varSlot x compile:noteLocal
        varSlot x.asm assembleVariableSet
	return
    fi

    ( If node is a vector is should be a ',' record )
    ( forming the backbone of the parameter tree.   )
    ( We need to compile both subtrees RIGHT FIRST: )
    node vector?  not if "compileFunctionParameters: internal err" simpleError fi
    node[0] ',' = not if "compileFunctionParameters: internal err" simpleError fi
    node[2] x blks args mode 'compileFunctionParameters call{ $ $ $ $ $ -> }
    node[1] x blks args mode 'compileFunctionParameters call{ $ $ $ $ $ -> }
;

( =====================================================================	)
( - compileFunction			 				)

:   compileFunction { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> oldx		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile a 'int f(x){...}' )

    node[1] -> resultParamsSyntax
    node[2] -> args
    node[3] -> body

    resultParamsSyntax findFunctionName -> fnName

    oldx.symbols    -> symbols
    symbols length2 -> symbolsSp

    ( Allocate a new context in which to compile fn: )
    [   :ephemeral  t
        :mss        oldx.mss
        :package    .lib["muf"]
        :symbols    symbols
        :symbolsSp  symbolsSp
        :syntax     oldx.syntax
    | 'compile:context ]makeStructure -> x

    -1  --> x.arity
    nil --> x.outermost

    makeFunction -> fun

    0 -> lineloc	( Buggo, we don't have a real line# yet. )

    fnName  --> x.fnName
    lineloc --> x.fnLine

    x.asm    -> asm
    lineloc --> asm.fnLine
    0       --> asm.lineInFn
    fnName  --> asm.fnName

    ( Push fn name on symbols stack: )
    fnName :fn nil x compile:noteLocal

    ( Compile function parameters and body: )
    args x 0 0 0 compileFunctionParameters
    body x 0 0 0 compileNode

    ( Finish assembly to produce actual  )
    ( compiled function.  We don't check )
    ( for zero bytecodes here because a  )
    ( null function can be useful:       )
    x.force x.arity fun x.asm finishAssembly -> cfn
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
    oldx.outermost if
	fnName intern -> sym
	cfn --> sym.function
    else
	fnName :fn cfn x compile:noteLocal
    fi

    ( Save assembler for possible re-use: )
    x.asm --> @.spareAssembler

( 3 2 < if return fi "compileFunction: unimplemented" simpleError )
;

( =====================================================================	)
( - compileAnonymousFunction			 			)

:   compileAnonymousFunction { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> oldx		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile a {^$1+2*$2;} )

( 3 2 < if return fi "compileFunction: unimplemented" simpleError )
(   node[1] -> resultParamsSyntax )
(   node[2] -> args )
    node[1] -> body

(   resultParamsSyntax findFunctionName -> fnName )
    "(anon)" -> fnName

    oldx.symbols    -> symbols
    symbols length2 -> symbolsSp

    ( Allocate a new context in which to compile fn: )
    [   :ephemeral  t
        :mss        oldx.mss
        :package    .lib["muf"]
        :symbols    symbols
        :symbolsSp  symbolsSp
        :syntax     oldx.syntax
    | 'compile:context ]makeStructure -> x

    -1  --> x.arity
    nil --> x.outermost


    makeFunction -> fun

    0 -> lineloc	( Buggo, we don't have a real line# yet. )

    fnName  --> x.fnName
    lineloc --> x.fnLine

    x.asm    -> asm
    lineloc --> asm.fnLine
    0       --> asm.lineInFn
    fnName  --> asm.fnName

    ( Push fn name on symbols stack: )
(   fnName :fn nil x compile:noteLocal )

    ( Compile function parameters and body: )
(   args x 0 0 0 compileFunctionParameters )
    body x 0 0 0 compileNode

    ( Finish assembly to produce actual  )
    ( compiled function.  We don't check )
    ( for zero bytecodes here because a  )
    ( null function can be useful:       )
    x.force x.arity fun x.asm finishAssembly -> cfn
    ""     --> fun.source
    cfn    --> fun.executable
    fnName --> fun.name

    ( Pop any nested symbols off symbol stack: )
    do{ symbols length2  symbolsSp = until
        symbols pull -> sym
    }	

    ( Assemble code to return compiledFunction: )
    ( If we're at outmost level, should declare )
    ( function in a global symbol, otherwise we )
    ( just remember it on locals stack:         )
    cfn oldx.asm assembleConstant

    ( Save assembler for possible re-use: )
    x.asm --> @.spareAssembler

    ( Next is a useful debug trace: )
    @.yydebug if
	"Disassembly of anonymous function:\n" ,
	cfn @.standardOutput debug:disassembleCompiledFunction
    fi
;

( =====================================================================	)
( - compileWhen					 			)

:   compileWhen { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> oldx		( Context for compile.	)
    -> node		( Compile this subtree. )

3 2 < if return fi "compileWhen: unimplemented" simpleError
;

( =====================================================================	)
( - compileMacro				 			)

:   compileMacro { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> oldx		( Context for compile.	)
    -> node		( Compile this subtree. )

3 2 < if return fi "compileMacro: unimplemented" simpleError
;

( =====================================================================	)
( - compileHashIf -- #if (expr) 		 			)

:   compileHashIf { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> oldx		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Compile a #if )

    node[1] -> body

    body not if
	nil -> testResult
    else 
	"(#if)" -> fnName

	oldx.symbols    -> symbols
	symbols length2 -> symbolsSp

	( Allocate a new context in which to compile expression: )
	[   :ephemeral  t
	    :mss        oldx.mss
	    :package    .lib["muf"]
	    :symbols    symbols
	    :symbolsSp  symbolsSp
	    :syntax     oldx.syntax
	| 'compile:context ]makeStructure -> x

	-1  --> x.arity
	nil --> x.outermost


	makeFunction -> fun

	0 -> lineloc	( Buggo, we don't have a real line# yet. )

	fnName  --> x.fnName
	lineloc --> x.fnLine

	x.asm    -> asm
	lineloc --> asm.fnLine
	0       --> asm.lineInFn
	fnName  --> asm.fnName

	( Compile expression: )
	body x 0 1 0 compileNode

	( Finish assembly to produce actual  )
	( compiled function.  We don't check )
	( for zero bytecodes here because a  )
	( null function can be useful:       )
	x.force x.arity fun x.asm finishAssembly -> cfn
	""     --> fun.source
	cfn    --> fun.executable
	fnName --> fun.name

	( Pop any nested symbols off symbol stack: )
	do{ symbols length2  symbolsSp = until
	    symbols pull -> sym
	}	

	( Next is a useful debug trace: )
	@.yydebug if
	    "Disassembly of #if expression anonymous function:\n" ,
	    cfn @.standardOutput debug:disassembleCompiledFunction
	fi

	( If '#if' expression is false, skip to next #endif: )
	cfn call{ -> $ } -> testResult

        ( Save assembler for possible re-use: )
        x.asm --> @.spareAssembler
    fi

    testResult not if

	( Read tokens until we see a #endif / #else: )
	1  -> deep
	0  -> this
	do{ deep 0 = until

	    ( Read next token: )
            this       -> last
	    last yylex -> this

	    ( Increment depth at each '#if': )
	    last '#' charInt =
	    this IF          = and if ++ deep fi

	    ( Exit at a depth-1 #else: )
	    last '#' charInt =
	    this ELSE        = and if
		deep 1 = if loopFinish fi
	    fi

	    ( Decrement depth at each '#endif': )
	    last '#' charInt =
	    this ENDIF       = and if -- deep fi
	}
    fi

;

( =====================================================================	)
( - compileSpecialNode			 				)

:   compileSpecialNode { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Handy debug trace: )
    @.yydebug if
	"compileSpecialNode: node[0] == '" , node[0] , "'\n" ,
    fi

    node[0] case{
    on: 'v'   node x blks args mode compileVarReference
    on: 'V'   node x blks args mode compileVarDeclaration
    on: ';'   node x blks args mode compileSequence
    on: '='   node x blks args mode compilePut
    on: '%'   node x blks args mode compileAssignOp
    on: '('   node x blks args mode compileFunctionCall
    on: ' '   node x blks args mode compileEmptyStatement
    on: '.'   node x blks args mode compileAdotB
    on: '['   node x blks args mode compileAsubB
    on: '{'   node x blks args mode compileBlock
    on: '}'   node x blks args mode compileVector
    on: 'i'   node x blks args mode compileIfThen
    on: 'I'   node x blks args mode compileIfThenElse
    on: 'w'   node x blks args mode compileWhile
    on: 'b'   node x blks args mode compileBreak
    on: 'c'   node x blks args mode compileContinue
    on: 'd'   node x blks args mode compileDoWhile
    on: 'f'   node x blks args mode compileFor
    on: 'r'   node x blks args mode compileReturn
    on: 'z'   node x blks args mode compileDelete
    on: 'S'   node x blks args mode compileSwitch
    on: 'C'   node x blks args mode compileCase
    on: 'D'   node x blks args mode compileDefault
    on: 'F'   node x blks args mode compileFunction
    on: 'W'   node x blks args mode compileWhen
    on: '?'   node x blks args mode compileQColon
    on: '|'   node x blks args mode compileBarBar
    on: '&'   node x blks args mode compileAmpAmp
    on: 'a'   node x blks args mode compileAnonymousFunction
    on: 'g'   node x blks args mode compileGoto
    on: 't'   node x blks args mode compileTag
    on: '#'   node x blks args mode compileHashIf
    else:
	"compileSpecialNode: internal err, unrecognized op" simpleError
    }
;

( =====================================================================	)
( - compileExpr			             				)

:   compileExpr { $ $ $ $ $ -> }
    -> mode		( Mode bitflags.	)
    -> args		( Scalars to return.	)
    -> blks		( Blocks to return.	)
    -> x		( Context for compile.	)
    -> node		( Compile this subtree. )

    ( Handy debug trace: )
    @.yydebug if
	"compileExpr: node==\n" ,
        node prettyPrint
    fi

    ( For now, a vector is assumed to contain )
    ( a function to call in slot 0 followed   )
    ( by arguments for it in the remaining    )
    ( slots:                                  )
    node vector? if

	( As an exception, if the 'function'  )
	( in slot 0 is a character, it is a   )
        ( special construct:                  )
	node[0] char? if node x blks args mode compileSpecialNode return fi

	node length -> len
	for i from 1 below len do{
	    node[i] x blks args mode 'compileExpr call{ $ $ $ $ $ -> }
	}
	node[0] x.asm assembleCall
        x 0 1 blks args balanceArgs
	return
    fi

    ( Anything other than a vector we )
    ( treat as a constant to load on  )
    ( the stack.                      )

    ( Avoid loading a constant which  )
    ( we are just going to pop:       )
    blks 0 =
    args 0 = and if
	return
    fi

    ( Strings need escape sequence processing: )
    node string? if node expandCStringEscapes -> node fi

    ( Do the load: )
    node x.asm assembleConstant

    x 0 1 blks args balanceArgs
;

( =====================================================================	)
( - compileParseTree		             				)

:   compileParseTree { $ $ -> $ }
    -> parseTree
    -> x

    ( For a warm-up, at least, we'll generate	)
    ( code directly from the parse tree.	)

    ( Next is a useful debug trace: )
    @.yydebug if
        "compileParseTree prettyPrinting parse tree:\n" ,
	parseTree prettyPrint
    fi

    t --> x.outermost
    [ x | compile:resetContext ]pop
    parseTree x -1 -1 0 compileNode

    ( Complete assembly: )
    makeFunction -> fun
    t 0 fun x.asm finishAssembly -> cfn

    ( Plug source and executable into fn: )
    ""   --> fun.source
    cfn  --> fun.executable

    ( Return compiled function: )
    cfn
;


( =====================================================================	)
( - compileString		             				)

( Overall function to parse a string: )
:   compileString { $ -> }
    -->   @.yyinput

    makeStack --> @.yyss    ( State stack -- central data structure.   )
    makeStack --> @.yyvs    ( Value stack, parallel to state stack.    )
    nil       --> @.yyval   ( ACTIONS put rule value in this variable. )
    nil       --> @.yylval  ( LEXER puts token value in this variable. )
    nil       --> @.yydebug ( Set true for vebose logging of parsing.  )

    0      --> @.yycursor

    _yyisinteractive --> @.yyprompt

    ( Buggo, should really save and restore byacc state: )
    _yyreadlinefn    --> @.yyreadfn
    _yylhs           --> @.yylhs
    _yylen           --> @.yylen
    _yydefred        --> @.yydefred
    _yydgoto         --> @.yydgoto
    _yysindex        --> @.yysindex
    _yyrindex        --> @.yyrindex
    _yygindex        --> @.yygindex
     YYTABLESIZE     --> @.YYTABLESIZE
    _yytable         --> @.yytable
    _yycheck         --> @.yycheck
     YYFINAL         --> @.YYFINAL
     YYMAXTOKEN      --> @.YYMAXTOKEN
    _yyname          --> @.yyname
    _yyrule          --> @.yyrule
    _yyaction        --> @.yyaction

    yyparse -> result

    ( Try compiling if no syntax errors: )
    result 0 = if

	@.standardInput -> mss
	[   :ephemeral t
	    :mss       mss
	    :package   .lib["muf"]
	    :outermost t
	| 'compile:context ]makeStructure -> x

	x @.yyval compileParseTree -> cfn
    fi
;


( =====================================================================	)
( - printMucScalar	             					)

:   printMucScalar { $ -> }
    -> v
    " " ,
    v vector?
    v vectorF32? or
    v vectorF64? or if
	v length2 3 = if
	    "{" , v[0] , ", " , v[1] , ", " , v[2] , "}" ,
	    return
    fi  fi
    v toDelimitedString ,
;

( =====================================================================	)
( - printMucStack	             					)

:   printMucStack  { -> ! }   ( Lie outrageously about arity. )
    do{ depth 0 = until
	block? if
	    do{ |length 0 = until
		|shift printMucScalar
	    }
	    ]pop
	    loopNext
	fi
	printMucScalar
    }
;

( =====================================================================	)
( - evalParsetree		             				)

:   evalParsetree { $ -> ! }
    -> parseTree

    @.standardInput -> mss
    [   :ephemeral t
	:mss       mss
	:package   .lib["muf"]
	:outermost t
    | 'compile:context ]makeStructure -> x

    ( In interactive use, want to implicitly return values: )
    @.yyprompt if
	parseTree vector? if
	    parseTree[0] 'r' != if
		[ 'r' parseTree ] -> parseTree
	    fi
	fi
    fi

    ( Drop used-up portion of input string: )
    @.yyinput @.yycursor @.yyinput length2 substring --> @.yyinput
    0 --> @.yycursor

    x parseTree compileParseTree -> cfn

    ( Next is a useful debug trace: )
    @.yydebug if cfn @.standardOutput debug:disassembleCompiledFunction fi

    ( Clear stack: )
    do{   depth 0 = until   pop   }

    ( Execute compiled function: )
    cfn call{ -> }

    @.yyprompt if

        ( Issue prompt: )
	@$s.package$s.name , "> " , ( prompt                   )

        ( Print and drop final results, if any: )
        printMucStack

(	print1DataStack ,             Print out data stack     )
	"\n" ,                      ( New line for user input  )
    fi

;

( =====================================================================	)
( - evalString		             					)

( Overall function to parse a string: )
:   evalString { $ -> }

    -->   @.yyinput

    makeStack --> @.yyss    ( State stack -- central data structure.   )
    makeStack --> @.yyvs    ( Value stack, parallel to state stack.    )
    nil       --> @.yyval   ( ACTIONS put rule value in this variable. )
    nil       --> @.yylval  ( LEXER puts token value in this variable. )
    nil       --> @.yydebug ( Set true for vebose logging of parsing.  )

    nil    --> @.yyreadfn
    nil    --> @.yyprompt
    0      --> @.yycursor

    ( Buggo, should really save and restore byacc state: )
    _yylhs           --> @.yylhs
    _yylen           --> @.yylen
    _yydefred        --> @.yydefred
    _yydgoto         --> @.yydgoto
    _yysindex        --> @.yysindex
    _yyrindex        --> @.yyrindex
    _yygindex        --> @.yygindex
     YYTABLESIZE     --> @.YYTABLESIZE
    _yytable         --> @.yytable
    _yycheck         --> @.yycheck
     YYFINAL         --> @.YYFINAL
     YYMAXTOKEN      --> @.YYMAXTOKEN
    _yyname          --> @.yyname
    _yyrule          --> @.yyrule
    _yyaction        --> @.yyaction

    yyparse -> result

    ( Next is a useful debug trace: )
    @.yydebug if "\nevalString(\"" , @.yyinput , "\");\n" , fi
;
'evalString export


( =====================================================================	)

( - File variables							)


( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example
