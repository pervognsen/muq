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

( - 170-C-muf-syntax.muf -- Method syntax for "Multi-User Forth".	)
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
( - Select MUF Package:							)

"muf" inPackage

( =====================================================================	)
( - Types -								)


( =====================================================================	)
( - Public fns -							)

( =====================================================================	)
( - insertMethodInKey -- and return new/changed key			)

:   insertMethodInKey { $ $ $ -> $ }
    -> gfn
    -> mtd
    -> key

    key.classMethods -> classMethods
    for i from 0 below classMethods do{
	key i getMosKeyClassMethod -> m gfn != if pop else
	    0 = if
		mtd m methodsMatch? -> order if
		    order 0 = if
			asMeDo{
			    rootOmnipotentlyDo{
				key.owner rootAsUserDo{
				    key i 0 gfn mtd setMosKeyClassMethod
				}
			    }
			}
			key return
		    fi
		    order -1 = if
			asMeDo{
			    rootOmnipotentlyDo{
				key.owner rootAsUserDo{
				    ( Insert before existing one: )
				    key i 0 gfn mtd
				    insertMosKeyClassMethod -> newKey

				    ( Unlink old key from its ancestors: )
				    key.mosAncestors -> lim
				    for i from 0 below lim do{
					key i unlinkMosKeyFromAncestor 
				    }

				    ( Link new key to its ancestors: )
				    newKey.mosAncestors -> lim
				    for i from 0 below lim do{
					newKey i linkMosKeyToAncestor 
				    }

				    newKey --> key.mosClass.key
				    newKey --> key.newerKey
				}
			    }
			}
			newKey return
		    fi
		fi
	    fi
        fi
    }

    asMeDo{
	rootOmnipotentlyDo{
	    key.owner rootAsUserDo{
		key classMethods 0 gfn mtd insertMosKeyClassMethod
                -> newKey

		newKey --> key.mosClass.key
		newKey --> key.newerKey

		( Unlink old key from its ancestors: )
		key.mosAncestors -> lim
		for i from 0 below lim do{
		    key i unlinkMosKeyFromAncestor 
		}

		( Link new key to its ancestors: )
		newKey.mosAncestors -> lim
		for i from 0 below lim do{
		    newKey i linkMosKeyToAncestor 
		}
	    }
	}
    }
    newKey
;

( =====================================================================	)
( - defmethod: -- Define a method function				)

( Syntax is						  )
( defmethod: aGenericFunction { 'class 'class } &tc ;   )
( where aGenericFunction must be previously defined,    )
( the curly braces provide only the specializers, not the )
( signature -- which is obtained from the generic -- and  )
( the rest of it is normal function body code.            )

:   defmethod: { $ -> ! }   -> oldCtx
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

    makeFunction -> fun

    ( Read next token (genericName) and stash: )
    [ ctx.mss | |scanTokenToNonwhitespace ]pop
    [ ctx.mss | |scanTokenToWhitespace
    |popp ( lineloc )
    |readTokenChars   ( Get token chars as block. )
    |backslashesToHighbit
(   |downcase )
    ]join    ->     fnName

    ( Look up generic: )
    fnName intern -> sym
    sym.function -> gfn
    gfn.mosGeneric? not if
	fnName " is not a mosGeneric function" join simpleError
    fi
    gfn.source -> src
    src.arity  -> srcArity
    src.specializedParameters -> requiredArgs

    srcArity explodeArity
    -> srcTyp
    -> srcArgsOut
    -> srcBlksOut 
    -> srcAargsIn
    -> srcBlksIn



    ( Next token should be '{' opening   )
    ( parameter specializer declaration: )
    [ ctx.mss | |scanTokenToNonwhitespace ]pop
    [ ctx.mss | |scanTokenToWhitespace
    |popp ( lineloc )
    |readTokenChars   ( Get token chars as block. )
    ]join "{" = not if
	"defmethod: expected '{'" simpleError
    fi

    ( Compile parameter specializer list: )
    withTag rbraceTag do{
        ( Push endOfScope fn to be called by '}' fn: )
        :: { $ -> ! } pop 'rbraceTag goto ; ctx.syntax push
        do{
            compile:modeGet ctx compilePath
        }
        rbraceTag
    }

    ( Finish assembly to produce actual  )
    ( compiled function:                 )
    nil -1 fun ctx.asm finishAssembly -> cfn

    ( Pop any nested symbols off symbol stack: )
    do{ symbols length2  symbolsSp = until
        symbols pull -> sym
    }	

    ( Invoke compiled function, leaving )
    ( block of parameter specializers:  )
    [ cfn call |

	( Check that number of specializers    )
	( matches argsIn declared in generic: )
	|length requiredArgs != if
	    [
		|length
		"Method specializer count %d != generic argsIn %d"
		swap
		requiredArgs
	    | ]print simpleError
	fi

	( Create name for method, )
        ( from specializer list: )
	sym.name -> mtdName
	|for s do{
	    [ mtdName " " s toString | ]join -> mtdName
	}

	( Create method object for method: )
	|length makeMethod -> mtd
	mtdName --> mtd.name
	mtdName --> fun.name

	( Enter method specializers into method: )
	0 -> slot
	|for s do{
	    :eql -> op
	    s symbol?  if
	        s.type -> c
	        c mosClass? if
		    :isA -> op
		    c -> s
	    fi  fi
	    mtd slot op s setMethodSlot
	    ++  slot
	}
    ]pop

    ( Reset assembler for new compile: )
    ctx.asm reset

    ( Mark scope on stack: )
    0 ctx compile:pushColon

    ( Loop compiling rest of method.  We    )
    ( exit this loop by compileSemi doing  )
    ( a GOTO to semiTag when we hit a ';': )
    withTag semiTag do{
        do{
            compile:modeGet ctx compilePath
        }
        semiTag
    }

    ( Finish assembly to produce actual  )
    ( compiled function for method:      )
    nil -1 fun ctx.asm finishAssembly -> cfn
    ""   --> fun.source
    cfn  --> fun.executable

    ( Install compiledFunction in method: )
    cfn  --> mtd.methodFunction
    gfn  --> mtd.genericFunction

    ( Pop any nested symbols off symbol stack: )
    do{ symbols length2  symbolsSp = until
        symbols pull -> sym
    }

    ( Save assembler for possible re-use: )
    ctx.asm --> @.spareAssembler

    ( Get mosClass qualifier for )
    ( first argument specializer: )
    mtd 0 getMethodSlot -> cdf -> op



    ( If the qualifier is t, the universal )
    ( type, we instead store the method on )
    ( the generic function defaultMethods )
    ( mosKey:                             )
    cdf t.type = if

	gfn control? not if
	    "defmethod: If first specializer is t, you must own the generic fn"
	    simpleError
        fi
	src.defaultMethods -> key
	key mosKey? not if
	    ( Create mosKey to hold result: )
	    makeMosClass -> cdf
	    cdf   ( Mos-class       )
	    0     ( Unshared slots  )
	    0     (   Shared slots  )
	    0     ( Parents         )
	    0     ( Ancestors       )
	    0     ( Slotargs        )
	    0     ( Methargs        )
	    0     ( Initargs        )
	    0     ( Object-methods  )
	    1     ( Class-methods   )
	    makeMosKey -> key
	    key --> cdf.key
	    key 0 0 gfn mtd setMosKeyClassMethod
	    key --> src.defaultMethods
	    return
	fi

	( Insert method into defaultMethods vector: )
        key mtd gfn insertMethodInKey -> newKey
	newKey --> src.defaultMethods
	( We have no subclasses   )
        ( to update in this case: )
	return
    fi

    op :isA != if
	"defmethod: 1st arg must currently name a MOS class" simpleError
    fi

    cdf control? not if
	"defmethod: You must own class of first arg"
	simpleError
    fi
    cdf.key -> key

    key mtd gfn insertMethodInKey -> newKey
    key updateSubclasses

;
'defmethod: export

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


