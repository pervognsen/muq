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

( - 180-C-make-instance.muf -- makeInstance and related fns.		)
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
( Created:      96Sep29							)
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
( - |makeInstance -- Generic						)

defgeneric: |makeInstance {[ $ ]} ;
'|makeInstance export

( =====================================================================	)
( - |makeInstance -- symbol method					)

defmethod: |makeInstance { 'lisp:symbol } { [] -> [] }

    ( Replace class symbol by class proper, )
    ( then re-issue the generic fn call:    )
    |shift -> ourClassName
    ourClassName$s.type |unshift
    |makeInstance
;

( =====================================================================	)
( - |makeInstance -- standardClass method				)

defmethod: |makeInstance { 'standardClass } { [] -> [] }

    ( First task -- see CLtT2p808 -- is )
    ( to default the initarg list.      )
    ( We currently skip this completely )

    ( Second task is to validate the    )
    ( defaulted initarg list. We skip   )
    ( this completely too!              )

    ( Third task is to create a new     )
    ( instance of given class.  We are  )
    ( supposed to give it unbound slots )
    ( but we currently do not...        )
    0 |dupNth -> ourClass
    [ | ourClass ]makeStructure -> newObj

    ( Our fourth and final task is to   )
    ( call initializeInstance on the   )
    ( new object.  We don't do that     )
    ( either. One outa 4 isn't too bad! )

    ( Discard the initialization args: )
    ]pop

    ( Return new object: )
    [ newObj |
;

( =====================================================================	)
( - makeInstance -- Convenience wrapper				)

:   makeInstance { $ -> $ } -> k
    [ k | |makeInstance ]shift
;
'makeInstance export


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


