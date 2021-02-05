@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Rex Syntax Fns, Rex Syntax Fns Overview, , Top
@chapter Muf Compiler

@menu
* Rex Syntax Fns Overview::
* Rex Syntax Fns Source::
* Rex Syntax Fns Wrapup::
@end menu

@c
@node Rex Syntax Fns Overview, Rex Syntax Fns Source, Rex Syntax Fns, Rex Syntax Fns
@section Mos Syntax Fns Overview

This chapter documents the syntax functions
supporting the regular expression syntax for
the in-db (@sc{muf}) implementation of the
@sc{muf} compiler, and includes all the source for
them.

@c
@node Rex Syntax Fns Source, Rex Syntax Fns Wrapup, Rex Syntax Fns Overview, Muf Compiler
@section Rex Syntax fns Source

@example  @c

( - 164-C-rex.muf -- Regular expression syntax for "Multi-User Forth".	)
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
( Created:      98Jun03							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1998, by Jeff Prothero.				)
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
( - Select MUF Package:							)

"muf" inPackage

( =====================================================================	)
( - Types -								)


( =====================================================================	)
( - rexContext -- Structure holding compilation state			)


[ 'rexContext	        ( Name of structure class )
  :export 1           ( Export all symbols.     )

  'ctx         :initval nil		        ( Compilation context	  )
  'asm         :initval nil		        ( Same as ctx.asm	  )
  'mss         :initval nil		        ( Same as ctx.mss	  )
  'parensSeen  :initval 0
  'getchar     :initval :: -> s   [ s.mss | |readTokenChar ]-> c   c ;
  'ungetchar   :initval :: -> s   [ s.mss | |unreadTokenChar ]pop    ;
  'string      :initval nil
  'offset      :initval 0

| ]defstruct


( =====================================================================	)
( - Public fns -							)

( Forward declaration: )
:   compileRex { $ $ -> ! } ;

( =====================================================================	)
( - printRexParse -- Print parsed regular expression			)

:   printRexParse { $ -> }
    -> theParse

    theParse cons? if
	"[ " ,
	do{ 
	    theParse car 'printRexParse call{ $ -> }
	    theParse cdr -> theParse
	    theParse while
	}
	"]" ,
    else
	theParse , " " ,
    fi
;

( =====================================================================	)
( - rexTrueFn -- A function which returns t				)

:   rexTrueFn   t   ;

( =====================================================================	)
( - compileRexDot -- Compile "." regular expression node		)

:   compileRexDot { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state

    state.asm -> asm

    ( Reset assembler for new compile: )
    asm reset

    ( Assemble the actual regular expression check: )
    'rexMatchDot asm assembleCall

    ( Return nil if match failed: )
    asm assembleLabelGet -> ok
    ok       asm assembleBne
    nil      asm assembleConstant
    'return asm assembleCall
    ok       asm assembleLabel

    ( Call next function if match succeeded: )
    nextFn   asm assembleCall

    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    cfn
;

( =====================================================================	)
( - compileRexWhitespace -- Compile "\s" regular expression node	)

:   compileRexWhitespace { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state

    state.asm -> asm

    ( Reset assembler for new compile: )
    asm reset

    ( Assemble the actual regular expression check: )
    'rexMatchWhitespace asm assembleCall

    ( Return nil if match failed: )
    asm assembleLabelGet -> ok
    ok       asm assembleBne
    nil      asm assembleConstant
    'return asm assembleCall
    ok       asm assembleLabel

    ( Call next function if match succeeded: )
    nextFn   asm assembleCall

    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    cfn
;

( =====================================================================	)
( - compileRexDigit -- Compile "\d" regular expression node		)

:   compileRexDigit { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state

    state.asm -> asm

    ( Reset assembler for new compile: )
    asm reset

    ( Assemble the actual regular expression check: )
    'rexMatchDigit asm assembleCall

    ( Return nil if match failed: )
    asm assembleLabelGet -> ok
    ok       asm assembleBne
    nil      asm assembleConstant
    'return asm assembleCall
    ok       asm assembleLabel

    ( Call next function if match succeeded: )
    nextFn   asm assembleCall

    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    cfn
;

( =====================================================================	)
( - compileRexWordboundary -- Compile "\b" regular expression node	)

:   compileRexWordboundary { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state

    state.asm -> asm

    ( Reset assembler for new compile: )
    asm reset

    ( Assemble the actual regular expression check: )
    'rexMatchWordboundary asm assembleCall

    ( Return nil if match failed: )
    asm assembleLabelGet -> ok
    ok       asm assembleBne
    nil      asm assembleConstant
    'return asm assembleCall
    ok       asm assembleLabel

    ( Call next function if match succeeded: )
    nextFn   asm assembleCall

    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    cfn
;

( =====================================================================	)
( - compileRexWordchar -- Compile "\w" regular expression node		)

:   compileRexWordchar { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state

    state.asm -> asm

    ( Reset assembler for new compile: )
    asm reset

    ( Assemble the actual regular expression check: )
    'rexMatchWordchar asm assembleCall

    ( Return nil if match failed: )
    asm assembleLabelGet -> ok
    ok       asm assembleBne
    nil      asm assembleConstant
    'return asm assembleCall
    ok       asm assembleLabel

    ( Call next function if match succeeded: )
    nextFn   asm assembleCall

    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    cfn
;

( =====================================================================	)
( - compileRexNonwhitespace -- Compile "\S" regular expression node	)

:   compileRexNonwhitespace { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state

    state.asm -> asm

    ( Reset assembler for new compile: )
    asm reset

    ( Assemble the actual regular expression check: )
    'rexMatchNonwhitespace asm assembleCall

    ( Return nil if match failed: )
    asm assembleLabelGet -> ok
    ok       asm assembleBne
    nil      asm assembleConstant
    'return asm assembleCall
    ok       asm assembleLabel

    ( Call next function if match succeeded: )
    nextFn   asm assembleCall

    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    cfn
;

( =====================================================================	)
( - compileRexNondigit -- Compile "\D" regular expression node		)

:   compileRexNondigit { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state

    state.asm -> asm

    ( Reset assembler for new compile: )
    asm reset

    ( Assemble the actual regular expression check: )
    'rexMatchNondigit asm assembleCall

    ( Return nil if match failed: )
    asm assembleLabelGet -> ok
    ok       asm assembleBne
    nil      asm assembleConstant
    'return asm assembleCall
    ok       asm assembleLabel

    ( Call next function if match succeeded: )
    nextFn   asm assembleCall

    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    cfn
;

( =====================================================================	)
( - compileRexNonwordboundary -- Compile "\B" regular expression node	)

:   compileRexNonwordboundary { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state

    state.asm -> asm

    ( Reset assembler for new compile: )
    asm reset

    ( Assemble the actual regular expression check: )
    'rexMatchNonwordboundary asm assembleCall

    ( Return nil if match failed: )
    asm assembleLabelGet -> ok
    ok       asm assembleBne
    nil      asm assembleConstant
    'return asm assembleCall
    ok       asm assembleLabel

    ( Call next function if match succeeded: )
    nextFn   asm assembleCall

    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    cfn
;

( =====================================================================	)
( - compileRexNonwordchar -- Compile "\W" regular expression node	)

:   compileRexNonwordchar { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state

    state.asm -> asm

    ( Reset assembler for new compile: )
    asm reset

    ( Assemble the actual regular expression check: )
    'rexMatchNonwordchar asm assembleCall

    ( Return nil if match failed: )
    asm assembleLabelGet -> ok
    ok       asm assembleBne
    nil      asm assembleConstant
    'return asm assembleCall
    ok       asm assembleLabel

    ( Call next function if match succeeded: )
    nextFn   asm assembleCall

    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    cfn
;

( =====================================================================	)
( - compileRexMatchPrevious -- Compile "\1" (&tc) regex node		)

:   compileRexMatchPrevious { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state

    state.asm -> asm

    ( Reset assembler for new compile: )
    asm reset

    ( Assemble the actual regular expression check: )
    rex car                 asm assembleConstant
    'rexMatchPreviousMatch asm assembleCall

    ( Return nil if match failed: )
    asm assembleLabelGet -> ok
    ok       asm assembleBne
    nil      asm assembleConstant
    'return asm assembleCall
    ok       asm assembleLabel

    ( Call next function if match succeeded: )
    nextFn   asm assembleCall

    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    cfn
;

( =====================================================================	)
( - compileRexDollar -- Compile "$" regular expression node		)

:   compileRexDollar { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state

    state.asm -> asm

    ( Reset assembler for new compile: )
    asm reset

    ( Assemble the actual regular expression check: )
    'rexDone? asm assembleCall

    ( Return nil if match failed: )
    asm assembleLabelGet -> ok
    ok       asm assembleBne
    nil      asm assembleConstant
    'return asm assembleCall
    ok       asm assembleLabel

    ( Call next function if match succeeded: )
    nextFn   asm assembleCall

    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    cfn
;

( =====================================================================	)
( - compileRexStringConstant -- Compile "xyz" regular expression node	)

:   compileRexStringConstant { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state

    state.asm -> asm

    ( Reset assembler for new compile: )
    asm reset

    ( Assemble the actual regular expression check: )
    rex car          asm assembleConstant
    'rexMatchString asm assembleCall

    ( Return nil if match failed: )
    asm assembleLabelGet -> ok
    ok       asm assembleBne
    nil      asm assembleConstant
    'return asm assembleCall
    ok       asm assembleLabel

    ( Call next function if match succeeded: )
    nextFn   asm assembleCall

    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    cfn
;

( =====================================================================	)
( - compileRexCharacterClass -- Compile "[xyz]" regular expression node	)

:   compileRexCharacterClass { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state

    state.asm -> asm

    ( Reset assembler for new compile: )
    asm reset

    ( Assemble code to load the constant string on the stack: )
    rex car   asm   assembleConstant

    ( Assemble the actual regular expression check: )
    'rexMatchCharClass asm assembleCall

    ( Return nil if match failed: )
    asm assembleLabelGet -> ok
    ok       asm assembleBne
    nil      asm   assembleConstant
    'return asm assembleCall
    ok       asm assembleLabel

    ( Call next function if match succeeded: )
    nextFn asm assembleCall

    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    cfn
;

( =====================================================================	)
( - compileRexRepeat -- Compile "x*"/"x+"/"x?"/...			)

:   compileRexRepeat { $ $ $ $ $ -> $ }
    -> maxRepeats
    -> minRepeats
    -> nextFn
    -> rex
    -> state

    state.asm -> asm
( buggo? This may not implement nested repeats correctly )


    ( Locate our subexpression: )
    rex car     -> rex0

    ( Compile code for subexpression: )
    state rex0 'rexTrueFn compileRex -> cfn0



    ( Reset assembler for new compile: )
    asm reset

    ( Assemble code putting [ nil | on stack: )
    'startBlock   asm assembleCall
    nil            asm assembleConstant
    'endBlock     asm assembleCall

    ( Assemble label at start of first loop: )
    asm assembleLabelGet -> lup0
    lup0           asm assembleLabel

    ( Assemble code pushing current location within matched string: )
    'rexGetCursor asm assembleCall
    '|push        asm assembleCall

    ( Call match function: )
    cfn0 asm assembleCall

    asm assembleLabelGet -> lup1
    maxRepeats not if
	( If subexpression succeeds, we want to jump back and do it again, )
	( since the usual convention is that '*' should default to eating  )
	( as much stuff as possible:                                       )
	lup0           asm assembleBne
    else
	( If subexpression succeeds, and we're allowed more matches,	   )
        ( we want to jump back and do it again, since the usual convention )
        ( is that we' should default to eating as much stuff as possible:  )
        asm assembleLabelGet -> xit0
	xit0           asm assembleBeq
	'|length      asm assembleCall
        maxRepeats 1 + asm assembleConstant
	'<            asm assembleCall
	lup0           asm assembleBne
	lup1           asm assembleBra
        xit0           asm assembleLabel
    fi


    ( When subexpression finally fails, we need to )
    ( pop the last cursor location  since it was a )
    ( dud, then continue with nextFn expression:   )
    '|pop         asm assembleCall
    'rexSetCursor asm assembleCall    
    lup1           asm assembleLabel

    minRepeats if
	( Fail if insufficient number of repeats are left: )
	asm assembleLabelGet -> enoughLeft
	'|length      asm assembleCall
        minRepeats     asm assembleConstant
	'>            asm assembleCall
	enoughLeft     asm assembleBne
	']pop         asm assembleCall
	nil            asm assembleConstant
	'return       asm assembleCall
	enoughLeft     asm assembleLabel
    fi    

    nextFn         asm assembleCall

    ( If full expression succeeded, just pop our block and return success: )
    asm assembleLabelGet -> failed
    failed         asm assembleBeq
    ']pop         asm assembleCall
    t              asm assembleConstant
    'return       asm assembleCall
    failed         asm assembleLabel

    ( If full expression failed, we may able to back up one match and retry: )
    asm assembleLabelGet -> moreTriesLeft
    '|dup         asm assembleCall
    moreTriesLeft  asm assembleBne
    ']pop         asm assembleCall
    nil            asm assembleConstant
    'return       asm assembleCall
    moreTriesLeft  asm assembleLabel
    '|pop         asm assembleCall
    'rexSetCursor asm assembleCall    
    lup1           asm assembleBra



    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    cfn
;

( =====================================================================	)
( - compileRexStar -- Compile "x*" regular expression node		)

:   compileRexStar { $ $ $ -> $ }
    nil nil compileRexRepeat
;

( =====================================================================	)
( - compileRexPlus -- Compile "x+" regular expression node		)

:   compileRexPlus { $ $ $ -> $ }
    1 nil compileRexRepeat
;

( =====================================================================	)
( - compileRexQuestion -- Compile "x?" regular expression node		)

:   compileRexQuestion { $ $ $ -> $ }
    nil 1 compileRexRepeat
;

( =====================================================================	)
( - compileRexBraces -- Compile "x{n,m}" regular expression node	)

:   compileRexBraces { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state
    
    rex car -> minRepeats   rex cdr -> rex
    rex car -> maxRepeats   rex cdr -> rex

    state rex nextFn minRepeats maxRepeats compileRexRepeat
;

( =====================================================================	)
( - compileRexConcatenation -- Compile regular expression node		)

:   compileRexConcatenation { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state

    state.asm -> asm

    ( Locate our two subexpressions: )
    rex car     -> rex0
    rex cdr car -> rex1

    ( Compile code for second subexpression: )
    state rex1 nextFn compileRex -> cfn1

    ( Compile code for first subexpression: )
    state rex0 cfn1   compileRex -> cfn0

    ( Reset assembler for new compile: )
    asm reset

    ( Call first match function: )
    cfn0 asm assembleCall

    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    cfn
;

( =====================================================================	)
( - compileRexParens -- Compile "(x)" regular expression node		)

:   compileRexParens { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state

    state.asm -> asm

    ( Which paren pair are we? )
    rex car     -> parens
    rex cdr     -> rex

    ( Locate our subexpressions: )
    rex car     -> rex0



    ( Compile function noting end of matched string: )

    ( Reset assembler for new compile: )
    asm reset

    ( Note end of matched text: )
    parens          asm assembleConstant
    'rexCloseParen asm assembleCall

    ( Call our continuation function: )
    nextFn asm assembleCall

    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn1
    ""   --> fun.source
    cfn1 --> fun.executable



    ( Compile code for subexpression: )
    state rex0 cfn1 compileRex -> cfn0



    ( Reset assembler for new compile: )
    asm reset

    ( Note start of matched text: )
    parens         asm assembleConstant
    'rexOpenParen asm assembleCall

    ( Call our match function: )
    cfn0 asm assembleCall

    ( If match failed, clear matched text, return nil: )
    asm assembleLabelGet -> label0
    label0           asm assembleBne
    parens           asm assembleConstant
    'rexCancelParen asm assembleCall
    nil              asm assembleConstant
    'return         asm assembleCall
    label0           asm assembleLabel

    ( Return value: )
    t                asm assembleConstant

    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    cfn
;

( =====================================================================	)
( - compileRexAlternative -- Compile "x|y" regular expression node	)

:   compileRexAlternative { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state

    state.asm -> asm

    ( Locate our two subexpressions: )
    rex car     -> rex0
    rex cdr car -> rex1

    ( Compile code for second subexpression: )
    state rex1 'rexTrueFn compileRex -> cfn1

    ( Compile code for first subexpression: )
    state rex0 'rexTrueFn compileRex -> cfn0

    ( Reset assembler for new compile: )
    asm reset

    ( Assemble code saving offset within parsed string: )
    "cursor" asm assembleVariableSlot -> ourVariable
    'rexGetCursor asm assembleCall
    ourVariable    asm assembleVariableSet

    ( Assemble code to call first subexpression )
    ( and then continuation if it matches:      )
    asm assembleLabelGet -> label0
    cfn0     asm assembleCall
    label0   asm assembleBeq
    nextFn    asm assembleCall
    'return asm assembleCall
    label0   asm assembleLabel

    ( Assemble code restoring original offset within parsed string: )
    ourVariable    asm assembleVariableGet
    'rexSetCursor asm assembleCall

    ( Assemble code to call second subexpression )
    ( and return NIL if it fails to match:       )
    asm assembleLabelGet -> label1
    cfn1      asm assembleCall
    label1    asm assembleBne
    nil       asm assembleConstant
    'return  asm assembleCall
    label1    asm assembleLabel

    ( Assemble code to call nextFn and return its result: )
    nextFn    asm assembleCall

    makeFunction -> fun
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    cfn
;

( =====================================================================	)
( - compileRex -- Compile an arbitrary regular expression node		)

:   compileRex { $ $ $ -> $ }
    -> nextFn
    -> rex
    -> state

    rex car case{
    on: 'string           state  rex cdr   nextFn   compileRexStringConstant  -> cfn
    on: 'class            state  rex cdr   nextFn   compileRexCharacterClass  -> cfn
    on: 'cat              state  rex cdr   nextFn   compileRexConcatenation   -> cfn
    on: 'or               state  rex cdr   nextFn   compileRexAlternative     -> cfn
    on: 'star             state  rex cdr   nextFn   compileRexStar            -> cfn
    on: 'plus             state  rex cdr   nextFn   compileRexPlus            -> cfn
    on: 'matchprevious    state  rex cdr   nextFn   compileRexMatchPrevious   -> cfn
    on: 'question         state  rex cdr   nextFn   compileRexQuestion        -> cfn
    on: 'braces           state  rex cdr   nextFn   compileRexBraces          -> cfn
    on: 'parens           state  rex cdr   nextFn   compileRexParens          -> cfn
    on: 'dot              state  rex cdr   nextFn   compileRexDot             -> cfn
    on: 'dollar           state  rex cdr   nextFn   compileRexDollar          -> cfn
    on: 'nonwhitespace    state  rex cdr   nextFn   compileRexNonwhitespace   -> cfn
    on: 'nonwordboundary  state  rex cdr   nextFn   compileRexNonwordboundary -> cfn
    on: 'nonwordchar      state  rex cdr   nextFn   compileRexNonwordchar     -> cfn
    on: 'nondigit         state  rex cdr   nextFn   compileRexNondigit        -> cfn
    on: 'whitespace       state  rex cdr   nextFn   compileRexWhitespace      -> cfn
    on: 'wordboundary     state  rex cdr   nextFn   compileRexWordboundary    -> cfn
    on: 'wordchar         state  rex cdr   nextFn   compileRexWordchar        -> cfn
    on: 'digit            state  rex cdr   nextFn   compileRexDigit           -> cfn
    else:
	"compileRex: unrecognized node operator:" rex car toString join simpleError
    }

    cfn
;

( =====================================================================	)
( - compileRexFunction -- Compile a complete regular expression		)

:   compileRexFunction { $ $ $ -> $ }
    -> fnName
    -> rex
    -> state

    state.asm -> asm



    ( Compile main body of match code: )
    state rex 'rexTrueFn compileRex -> cfn0



    ( Reset assembler for new compile: )
    asm reset

    makeFunction -> fun

    ( Compile start of rex match. At runtime  )
    ( This will initialize global match state )
    ( and pop string to be matched off  stack )
    ( and into internal match state:          )
    "string"       asm assembleVariableSlot -> stringVariable
    'dup          asm assembleCall
    stringVariable asm assembleVariableSet
    'rexBegin     asm assembleCall


    ( Compile call to main body of match code: )
    cfn0 asm assembleCall

    ( Assemble code to push results   )
    ( of all the parens on the stack: )
    state.parensSeen -> parens
    for i from 0 below parens do{
        stringVariable asm assembleVariableGet
        i              asm assembleConstant
        'rexGetParen  asm assembleCall
        'substring    asm assembleCall
    }

    ( Compile instruction to clear match state: )
    'rexEnd asm assembleCall


    ( Finish assembly to produce actual  )
    ( compiled function for method:      )
    nil -1 fun asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable
    fnName --> fun.name

    cfn
;


(   Forward declaration: )
:   parseRexAlternation { $ $ -> $ ! } ;

( =====================================================================	)
( - parseRexCharClass -- Character class in a regular expression	)

:   parseRexCharClass { $ $ -> $ }
    -> delim
    -> state

    ( Char class syntax is like [ath] or [a-z] or [^a-zA-Z]: )
    [ |
    t -> notBackslashed
    do{
        state state.getchar call{ $ -> $ } -> c
        c case{
	on: ']'    notBackslashed if loopFinish fi
	on: '\\'   nil -> notBackslashed  loopNext
	}
        c |push
	t -> notBackslashed
    }
    ]join -> k

    [ 'class k ]l
;

( =====================================================================	)
( - parseRexDot -- '.' in a regular expression				)

:   parseRexDot { $ $ -> $ }
    -> delim
    -> state

    [ 'dot ]l
;

( =====================================================================	)
( - parseRexDollar -- '$' in a regular expression			)

:   parseRexDollar { $ $ -> $ }
    -> delim
    -> state

    ( $ is special only if it is the last char in the rex: )
    state state.getchar   call{ $ -> $ } -> c
    state state.ungetchar call{ $ -> }
    c delim = if
        [ 'dollar ]l
    else        
        [ 'string "$" ]l
    fi    
;

( =====================================================================	)
( - parseRexBraceSuffix -- '{1,4}' in a regular expression		)

:   parseRexBraceSuffix { $ $ $ -> $ }
    -> parse
    -> delim
    -> state

    0 -> minRepeats
    0 -> maxRepeats

    do{
        state state.getchar call{ $ -> $ } -> c

	c digitChar? if
	    c charInt '0' charInt - -> i
	    minRepeats 10 * i + -> minRepeats
	    loopNext
	fi

        ( /a{n}/ means exactly n 'a's: )
	c '}' = if
	    [ 'braces minRepeats minRepeats parse ]l return
	fi

	c ',' = if loopFinish fi

	"Unexpected character inside regular expression {...} construct" simpleError 
    }

    state state.getchar call{ $ -> $ } -> c

    ( /a{n,}/ means at least n 'a's: )
    c '}' = if
	[ 'braces minRepeats nil parse ]l return
    fi

    do{
	c digitChar? if
	    c charInt '0' charInt - -> i
	    maxRepeats 10 * i + -> maxRepeats
            state state.getchar call{ $ -> $ } -> c
	    loopNext
	fi

	c '}' = if
	    [ 'braces minRepeats maxRepeats parse ]l return
	fi

	"Unexpected character inside regular expression {...} construct" simpleError 
    }
;

( =====================================================================	)
( - parseRexSuffix -- '*' and such in a regular expression		)

:   parseRexSuffix { $ $ $ -> $ }
    -> parse
    -> delim
    -> state

    ( $ is special only if it is the last char in the rex: )
    do{
        state state.getchar call{ $ -> $ } -> c

        c case{
        on: '*'   [ 'star     parse ]l                   -> parse   loopNext
        on: '?'   [ 'question parse ]l                   -> parse   loopNext
        on: '+'   [ 'plus     parse ]l                   -> parse   loopNext
        on: '{'   state delim parse parseRexBraceSuffix -> parse   loopNext
        else:
            state state.ungetchar call{ $ -> }
            parse return
	}
    }

;

( =====================================================================	)
( - parseRexStringConstant -- String constant in a regular expression	)

:   parseRexStringConstant { $ $ -> $ }
    -> delim
    -> state

    ( Any char sequence without funny operators like []  or (): )
    [ |
    t -> notBackslashed
    do{
        state state.getchar call{ $ -> $ } -> c

	( Keep constant strings below length 64, )
	( max that the rexMatchString primitive  )
	( will currently handle:                 )
	notBackslashed if
	    |length 60 >  if
		loopFinish
	fi  fi
	c case{
	on: delim  notBackslashed if loopFinish fi
	on: '['    notBackslashed if loopFinish fi
	on: '('    notBackslashed if loopFinish fi
	on: ')'    notBackslashed if loopFinish fi
	on: '|'    notBackslashed if loopFinish fi
	on: '.'    notBackslashed if loopFinish fi
	on: '$'    notBackslashed if loopFinish fi
	on: '\\'   notBackslashed if nil -> notBackslashed  loopNext fi
	on: 'f'    notBackslashed if else '\f' -> c fi
	on: 'n'    notBackslashed if else '\n' -> c fi
	on: 'r'    notBackslashed if else '\r' -> c fi
	on: 't'    notBackslashed if else '\t' -> c fi
	on: '0'    notBackslashed if else '\0' -> c fi
	on: '1'    notBackslashed if else
		]join -> k
		state delim [ 'matchprevious 0 ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: '2'    notBackslashed if else
		]join -> k
		state delim [ 'matchprevious 1 ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: '3'    notBackslashed if else
		]join -> k
		state delim [ 'matchprevious 2 ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: '4'    notBackslashed if else
		]join -> k
		state delim [ 'matchprevious 3 ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: '5'    notBackslashed if else
		]join -> k
		state delim [ 'matchprevious 4 ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: '6'    notBackslashed if else
		]join -> k
		state delim [ 'matchprevious 5 ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: '7'    notBackslashed if else
		]join -> k
		state delim [ 'matchprevious 6 ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: '8'    notBackslashed if else
		]join -> k
		state delim [ 'matchprevious 7 ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: '9'    notBackslashed if else
		]join -> k
		state delim [ 'matchprevious 8 ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: 'b'    notBackslashed if else
		]join -> k
		state delim [ 'wordboundary ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: 'B'    notBackslashed if else
		]join -> k
		state delim [ 'nonwordboundary ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: 'd'    notBackslashed if else
		]join -> k
		state delim [ 'digit ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: 'D'    notBackslashed if else
		]join -> k
		state delim [ 'nondigit ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l return
		fi
		parse return
	    fi
	on: 's'    notBackslashed if else
		]join -> k
		state delim [ 'whitespace ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: 'S'    notBackslashed if else
		]join -> k
		state delim [ 'nonwhitespace ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: 'w'    notBackslashed if else
		]join -> k
		state delim [ 'wordchar ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: 'W'    notBackslashed if else
		]join -> k
		state delim [ 'nonwordchar ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: '*'    notBackslashed if
		|pop -> c
		]join -> k
                state state.ungetchar call{ $ -> }
		state delim [ 'string [ c | ]join ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: '?'    notBackslashed if
		|pop -> c
		]join -> k
                state state.ungetchar call{ $ -> }
		state delim [ 'string [ c | ]join ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: '+'    notBackslashed if
		|pop -> c
		]join -> k
                state state.ungetchar call{ $ -> }
		state delim [ 'string [ c | ]join ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	on: '{'    notBackslashed if
		|pop -> c
		]join -> k
                state state.ungetchar call{ $ -> }
		state delim [ 'string [ c | ]join ]l parseRexSuffix -> parse
		k "" != if
		   [ 'cat [ 'string k ]l parse ]l -> parse
		fi
		parse return
	    fi
	else:
	}
        c |push
	t -> notBackslashed
    }
    state state.ungetchar call{ $ -> }
    ]join -> k

    [ 'string k ]l
;

( =====================================================================	)
( - parseRexParenthesis -- Parenthetical expression in a rex		)

:   parseRexParenthesis { $ $ -> $ }
    -> delim
    -> state

    ( Which paren pair are we? )
    state.parensSeen -> ourNumber
    ourNumber 1 + --> state.parensSeen

    state delim parseRexAlternation -> theParse

    state state.getchar call{ $ -> $ } -> c

    c ')' != if "Missing ')' in regular expression" simpleError fi

    [ 'parens ourNumber theParse ]l
;

( =====================================================================	)
( - parseRexLeaf -- Parse leaf level of a regular expression		)

:   parseRexLeaf { $ $ -> $ }
    -> delim
    -> state

    state state.getchar call{ $ -> $ } -> c

    c case{
    on: delim      state state.ungetchar call{ $ -> } nil return
    on: '.'        state delim parseRexDot         -> theParse
    on: '$'        state delim parseRexDollar      -> theParse
    on: '['        state delim parseRexCharClass   -> theParse
    on: '('        state delim parseRexParenthesis -> theParse
    on: ')'        state state.ungetchar call{ $ -> } nil return
    else:
        state state.ungetchar call{ $ -> }
	state delim parseRexStringConstant -> theParse
    }
    state delim theParse parseRexSuffix -> theParse

    theParse
;

( =====================================================================	)
( - parseRexConcatenation -- Parse sequence of rex leafs		)

:   parseRexConcatenation { $ $ -> $ }
    -> delim
    -> state

    state delim parseRexLeaf -> theParse

    do{
        state state.getchar call{ $ -> $ } -> c
        state state.ungetchar call{ $ -> }

        c case{
        on: delim  theParse return
        on: '|'    theParse return
        on: ')'    theParse return
        else:
	    [ 'cat   theParse   state delim parseRexLeaf ]l -> theParse
	}
    }
;

( =====================================================================	)
( - parseRexAlternation -- Parse top level of a regular expression	)

:   parseRexAlternation { $ $ -> $ }
    -> delim
    -> state

    state delim parseRexConcatenation -> theParse

    do{
        state state.getchar call{ $ -> $ } -> c
        c '|' = while
        [ 'or   theParse   state delim parseRexConcatenation ]l -> theParse
    }

    state state.ungetchar call{ $ -> }

    theParse
;

( =====================================================================	)
( - rex: -- Define a regular expression function			)

( Syntax is						  )
( rex: yourFunctionName /.../				  )
( where the /s can be most any character and ... is       )
( intended to eventually be full Perl regular expression  )
( syntax, but for now looks more like:                    )

:   rex: { $ -> ! }   -> oldCtx
    compileTime

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

    ctx.asm -> asm
    ctx.mss -> mss

    [ :ephemeral  t
    | 'rexContext ]makeStructure -> state
    ctx --> state.ctx
    asm --> state.asm
    mss --> state.mss


    ( Read next token (genericName) and stash: )
    [ state.mss | |scanTokenToNonwhitespace ]pop
    [ state.mss | |scanTokenToWhitespace
    |popp ( lineloc )
    |readTokenChars   ( Get token chars as block. )
    |backslashesToHighbit
(   |downcase )
    ]join    ->     fnName

    ( Skip whitespace before rex: )
    [ state.mss | |scanTokenToNonwhitespace ]pop

    ( Read initial delimiter: )
    [ state.mss | |readTokenChar ]-> delim

    ( Peek at next character, eat it if it is a '^': )
    [ state.mss | |readTokenChar ]-> maybeCarat
    maybeCarat '^' != if state state.ungetchar call{ $ -> } fi

    ( Parse the rex: )
    state delim parseRexAlternation -> theParse

    ( Read terminal delimiter: )
    state state.getchar call{ $ -> $ } -> delim2

    delim delim2 != if "rex: missing final delimiter" simpleError fi

    ( If rex didn't begin with '^' -- unanchored )
    ( search -- then prepend a ".*" to parse:    )
    maybeCarat '^' != if [ 'cat [ 'star [ 'dot ]l ]l theParse ]l -> theParse fi
( "rex: parse = " , theParse printRexParse "\n" , )

    ( Compile it: )
    state theParse fnName compileRexFunction -> cfn

    ( Create/find package symbol naming function: )
    fnName intern -> sym

    ( Hang function off package symbol: )
    cfn --> sym.function

;
'rex: export

( =====================================================================	)
( - compileRexString -- Define a regular expression function		)

( Syntax is						  )
( rex: yourFunctionName /.../				  )
( where the /s can be most any character and ... is       )
( intended to eventually be full Perl regular expression  )
( syntax, but for now looks more like:                    )

:   compileRexString { $ $ -> $ $ }   -> offset -> string

    ( Allocate a new context in which to compile fn: )
    [   :ephemeral  t
        :package    @.lib["muf"]
    | 'compile:context ]makeStructure -> ctx

    -1 --> ctx.arity

    ctx.asm -> asm

    [ :ephemeral  t
      :string     string
      :offset     offset
      :getchar    :: -> s  s.string[s.offset] -> c   ++ s.offset   c ;
      :ungetchar  :: -> s  -- s.offset  ;
    | 'rexContext ]makeStructure -> state
    ctx --> state.ctx
    asm --> state.asm

    "(regex)" -> fnName

    ( Read initial delimiter: )
    state state.getchar call{ $ -> $ } -> delim

    ( Peek at next character, eat it if it is a '^': )
    state state.getchar call{ $ -> $ } -> maybeCarat
    maybeCarat '^' != if state state.ungetchar call{ $ -> } fi

    ( Parse the rex: )
    state delim parseRexAlternation -> theParse

    ( Read terminal delimiter: )
    state state.getchar call{ $ -> $ } -> delim2

    delim delim2 != if "rex: missing final delimiter" simpleError fi

    ( If rex didn't begin with '^' -- unanchored )
    ( search -- then prepend a ".*" to parse:    )
    maybeCarat '^' != if [ 'cat [ 'star [ 'dot ]l ]l theParse ]l -> theParse fi
( "rex: parse = " , theParse printRexParse "\n" , )

    ( Compile it: )
    state theParse fnName compileRexFunction -> cfn

    cfn state.offset
;
'compileRexString export

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


