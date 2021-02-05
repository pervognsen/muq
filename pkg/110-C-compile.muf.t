@example  @c

( - 110-C-compile.muf -- Muq compiler support package.			)
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
( Created:      96Apr14, partly from 94Jan16 in-db muf compiler.	)
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

(   Many hands make light work.						)

( =====================================================================	)
( - Select COMPILER Package						)

[ "compile" | ]inPackage

( =====================================================================	)
( - Structures -							)

( =====================================================================	)
( - findAssembler -- Function returning an assembler			)
 
: findAssembler { -> $ }
    @.spareAssembler -> asm
    asm assembler? if
        ( This is not a race condition as long as  )
        ( jobs only use their own spareAssembler: )
        nil --> @.spareAssembler
    else
        makeAssembler -> asm
    fi
    asm reset
    asm
;

( =====================================================================	)
( - context -- Structure holding functionCompilationInProgress state	)


( Recompiling this definition tends to crash the )
( mufInMuf compiler, because it winds up using   )
( a pre-existing 'context' instance with the new )
( context access functions,  which then complain )
( about being given the wrong kind of structure: )
'contextAsm symbolFunction not if
  [ 'context	        ( Name of structure class )
    :export 1           ( Export all symbols.     )

    'asm         :initform #'findAssembler        ( Assembler instance	  )
    'mss         :initform :: @.standardInput ;   ( Source code stream    )
    'package     :initval nil                      ( Compiler library     )
    'symbols     :initform :: makeStack ;	 ( Stack of local symbols )
    'symbolsSp   :initval   0			 ( Logical bottom of prev )
    'syntax      :initform :: makeStack ;	 ( Stack of nested scopes )
    'container   :initval nil ( Context we're nested in, else NIL	  )
    'sp          :initval   0 ( Depth of data stack at start of fn	  )
    'fnLine      :initval   0 ( Line number in file where function starts )
    'fnName      :initval nil ( Name of function being compiled		  )
    'fn          :initval nil ( Function being compiled			  )
    'fnBeg       :initval   0 ( Offset first byte of fn being compiled    )
    'qvars       :initval   0 ( # of quoted vars  in fn being compiled    )
    'arity       :initval     ( Declared arity of function		  )
		 0 0 0 0 5 muf:implodeArity
    'force       :initval nil ( non-NIL to force arity of function	  )
    'line        :initval   0 ( Line number in file.			  )
    'outermost   :initval nil ( True if at global file scope.		  )
    'ateNewline  :initval nil ( True if shell should issue new prompt.	  )
  | ]defstruct
fi


( =====================================================================	)
( - Public fns -							)

( =====================================================================	)
( - resetContext -- Reset context for new compile			)

:   resetContext { [] -> [] }
    |pop -> c   c isAContext
    ]pop


    ( Point of this arity is to have   )
    ( commandline anonymous functions  )
    ( be implicitly { -> ? ! } so that )
    ( we can interactively type stuff  )
    ( like                             )
    (   : x { -> ? } if pop fi ;       )
    (   t t 'x call                    )
    ( without getting complaints from  )
    ( the arity checker.  Functions    )
    ( actually declared with : or such )
    ( don't get this default: do_colon )
    ( defaults them to arity -1.       )
    0 0 0 0 arityQ muf:implodeArity -> arity

    c.line -> line

    nil   --> c.container
    line  --> c.fnLine   
    nil   --> c.fnName
    0     --> c.fnBeg
    depth --> c.sp
    arity --> c.arity
    t     --> c.force
    0     --> c.symbolsSp

    c.symbols   reset
    c.syntax    reset
    c.asm       reset

    [ c |
;
'resetContext export

( =====================================================================	)
( - Public constants -							)


( Values for the compilePath 'mode' arg: )
  1 -->constant modeSet    ( For "--> sym" instead of "sym".		)
  2 -->constant modeGet    ( For "sym" instead of "--> sym".		)
  4 -->constant modeDel    ( For "delete: path" instead of "path".	)
  8 -->constant modeFn	    ( For "#'sym" instead of "sym".		)
 16 -->constant modeQuote  ( For "'sym" instead of "sym".		)
 32 -->constant modeConst  ( If we're doing -->constant			)
 64 -->constant modeSubex  ( If we're inside [...] pair.		)
128 -->constant modeInc    ( For ++ sym					)
256 -->constant modeDec    ( For -- sym					)

'modeSet   export
'modeGet   export
'modeDel   export
'modeFn    export
'modeQuote export
'modeConst export
'modeSubex export
'modeInc   export
'modeDec   export


( =====================================================================	)
( - Public fns -							)

( =====================================================================	)
( - push-* -- Fns to push syntax markers on data stack			)

: pushAfter    { $ $ -> } -> c c.syntax -> s s push :after    s push ;
: pushAlways   { $ $ -> } -> c c.syntax -> s s push :always   s push ;
: pushCase     { $ $ -> } -> c c.syntax -> s s push :case     s push ;
: pushCatch    { $ $ -> } -> c c.syntax -> s s push :catch    s push ;
: pushColon    { $ $ -> } -> c c.syntax -> s s push :colon    s push ;
: pushOrig     { $ $ -> } -> c c.syntax -> s s push :orig     s push ;
: pushTop      { $ $ -> } -> c c.syntax -> s s push :top      s push ;
: pushBottom   { $ $ -> } -> c c.syntax -> s s push :bottom   s push ;
: pushExit     { $ $ -> } -> c c.syntax -> s s push :exit     s push ;
: pushSwitch   { $ $ -> } -> c c.syntax -> s s push :switch   s push ;
: pushUser     { $ $ -> } -> c c.syntax -> s s push :user     s push ;
: pushPrivs    { $ $ -> } -> c c.syntax -> s s push :privs    s push ;
: pushHandlers { $ $ -> } -> c c.syntax -> s s push :handlers s push ;
: pushLbracket { $ $ -> } -> c c.syntax -> s s push :lbracket s push ;
: pushLock     { $ $ -> } -> c c.syntax -> s s push :lock     s push ;
: pushRestart  { $ $ -> } -> c c.syntax -> s s push :restart  s push ;
: pushGobot    { $ $ -> } -> c c.syntax -> s s push :gobot    s push ;
: pushGoto     { $ $ -> } -> c c.syntax -> s s push :goto     s push ;
: pushGotop    { $ $ -> } -> c c.syntax -> s s push :gotop    s push ;

'pushAfter    export
'pushAlways   export
'pushCase     export
'pushCatch    export
'pushColon    export
'pushOrig     export
'pushTop      export
'pushBottom   export
'pushExit     export
'pushSwitch   export
'pushUser     export
'pushPrivs    export
'pushHandlers export
'pushLbracket export
'pushLock     export
'pushRestart  export
'pushGobot    export
'pushGoto     export
'pushGotop    export

( =====================================================================	)
( - pop-* -- Fns to pop syntax markers off syntax stack			)

:   popIt { $ $ -> $ } -> key -> ctx
    ctx.syntax -> s

    ( => and =>fn are implicitly scoped, )
    ( so we may need to pop some markers )
    ( for them, generating appropriate   )
    ( code, before we get what we want:  )
    do{
	s pull -> k

	k :funBind = if
	    s pull pop
	    'popFunctionBinding ctx.asm assembleCall
	    loopNext
	fi

	k :varBind = if
	    s pull pop
	    'popVariableBinding ctx.asm assembleCall
	    loopNext
	fi

	loopFinish
    }
    k key != if "Mismatched control structure." simpleError fi
    s pull
;

: popAfter    { $ -> $ } :after    popIt ;   'popAfter    export
: popAlways   { $ -> $ } :always   popIt ;   'popAlways   export
: popCase     { $ -> $ } :case     popIt ;   'popCase     export
: popCatch    { $ -> $ } :catch    popIt ;   'popCatch    export
: popColon    { $ -> $ } :colon    popIt ;   'popColon    export
: popOrig     { $ -> $ } :orig     popIt ;   'popOrig     export
: popTop      { $ -> $ } :top      popIt ;   'popTop      export
: popBottom   { $ -> $ } :bottom   popIt ;   'popBottom   export
: popExit     { $ -> $ } :exit     popIt ;   'popExit     export
: popSwitch   { $ -> $ } :switch   popIt ;   'popSwitch   export
: popUser     { $ -> $ } :user     popIt ;   'popUser     export
: popPrivs    { $ -> $ } :privs    popIt ;   'popPrivs    export
: popHandlers { $ -> $ } :handlers popIt ;   'popHandlers export
: popLbracket { $ -> $ } :lbracket popIt ;   'popLbracket export
: popLock     { $ -> $ } :lock     popIt ;   'popLock     export
: popRestart  { $ -> $ } :restart  popIt ;   'popRestart  export
: popGobot    { $ -> $ } :gobot    popIt ;   'popGobot    export
: popGoto     { $ -> $ } :goto     popIt ;   'popGoto     export
: popGotop    { $ -> $ } :gotop    popIt ;   'popGotop    export


( =====================================================================	)
( - noteLocal -- Push local name, type and value			)

:   noteLocal   { $ $ $ $ -> }   -> ctx   -> val   -> typ   -> nam
    ctx.symbols -> symbols

    val symbols push
    typ symbols push
    nam symbols push
;
'noteLocal export


( =====================================================================	)
( - |findLocal? -- Look up local by name, type and value		)

:   |findLocal?   { [] $ -> [] $ $ $ $ }   -> ctx
    ctx.symbols -> symbols

    symbols |positionInStack? -> pos if
	symbols[pos] -> nam
	-- pos
	symbols[pos] -> typ
	-- pos
	symbols[pos] -> val
	pos nam typ val return
    fi
    nil nil nil nil
;
'|findLocal? export


( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example
