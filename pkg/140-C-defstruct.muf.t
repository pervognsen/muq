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

( - 140-C-defstruct.muf -- Structure definition syntax for MUF.		)
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
( - Quotation.								)
(									)
(   In their frenzied exhilaration the crusaders showed no mercy but	)
(   massacred all the Jews and Moslems they could find. Some ten	)
(   thousand of them, according to one chronicler, were beheaded in	)
(   Solomon's Temple alone, and "had you been there, your feet would	)
(   have been stained up to the ankles with the blood of the slain."	)
(   (Another chronicler described the blood of the victims here in	)
(   the temple so deep that it reached the bridle reins of the		)
(   horsemen who did the slaughtering!)					)
(									)
(      -- "A history of the Middle Ages", Joseph Dahmus, p273ff		)
(									)
( =====================================================================	)

( =====================================================================	)
( - Select MUF Package:							)

"muf" inPackage

( =====================================================================	)
( - Types -								)



( =====================================================================	)
( - Support fns -							)

( The relevant support functions are in 03-C-struct.t --		)
( it would be nice to move them here, but they need to be		)
( defined before 11-C-compile.t loads, since it defines a		)
( structure.  Such are the travails of bootstrapping! *wrygrin*		)

( =====================================================================	)
( - Public fns -							)

( =====================================================================	)
( - defstruct: -- Define a structure					)

:   defstruct: { $ -> ! }   -> oldCtx
    compileTime

    ( ------------------------------------------- )
    ( This is just a wrapper around ]defstruct.   )
    ( ]defstruct is perfectly usable as it stands )
    ( but I think the prefix defdefstruct: syntax )
    ( fits better with the general pattern of the )
    ( defmethod: ... defgeneric: ... syntax.	  )
    ( ------------------------------------------- )

    oldCtx.symbols -> symbols
    symbols length2 -> symbolsSp

( Buggo?  Actually, just an efficiency issue:  )
( I doubt there's any actual need to compile   )
( a separate function using a separate context )
( here: Just inlining the code should be fine. )
( But this works, so it's good enough for now. )
( If you -do- fix this, fix defclass also...   )

    ( Allocate a new context in which to compile fn: )
    [   :ephemeral  t
        :mss        oldCtx.mss
        :package    @.lib["muf"]
        :symbols    symbols
        :symbolsSp symbolsSp
        :syntax     oldCtx.syntax
    | 'compile:context ]makeStructure -> ctx

    ( Read next token (structName) and stash: )
    [ ctx.mss | |scanTokenToNonwhitespace ]pop
    [ ctx.mss | |scanTokenToWhitespace
    |popp ( lineloc )
    |readTokenChars   ( Get token chars as block. )
    |backslashesToHighbit
(   |downcase )
    ]join    ->   className

    -1 --> ctx.arity

    ( Mark scope on stack: )
    0 ctx compile:pushColon

    ( Assemble an implicit startOfBlock: )
    'startBlock ctx.asm assembleCall

    ( Assemble className as a symbol: )
    className ctx.asm assembleConstant
    'intern   ctx.asm assembleCall

    ( Loop compiling classdef body.   We    )
    ( exit this loop by compileSemi doing  )
    ( a GOTO to semiTag when we hit a ';': )
    withTag semiTag do{
        do{
            compile:modeGet ctx compilePath
        }
        semiTag
    }

    ( Assemble an implicit endOfBlock: )
    'endBlock ctx.asm assembleCall

    ( Assemble an implicit ]defstruct: )
    ']defstruct ctx.asm assembleCall

    ( Finish assembly to produce  )
    ( a compiled function:        )
    nil -1 makeFunction ctx.asm finishAssembly -> cfn

    ( Pop any nested symbols off symbol stack: )
    do{ symbols length2  symbolsSp = until
        symbols pull -> sym
    }

    ( Save assembler for possible re-use: )
    ctx.asm --> @.spareAssembler

    ( Deposit code to invoke compiled function. )
    ( Invoking it directly would defeat, for    )
    ( example, a nested rootOmnipotentlyDo{}: )
    cfn oldCtx.asm assembleCall
;
'defstruct: export

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


