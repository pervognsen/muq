@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Standard Events, , , Top
@chapter Standard Events

@menu
* Standard Events Overview::
* Standard Events Source::
* Standard Events Wrapup::
@end menu

@c
@node Standard Events Overview, Standard Events Source, Standard Events, Standard Events
@section Standard Events Overview

This chapter documents the standard Events
defined by the Muq Object System.  These exist
primarily to communicate server-detected error
events to in-db event handlers.  They
are also extremely rudimentary at present, and
what does is exist is not yet used effectively
by the server -- lots of work needed here.

@c
@node Standard Events Source, Standard Events Wrapup, Standard Events Overview, Standard Events
@section Standard Events Source

Here it is, the complete source.

Eventually, I intend to have the source more
intricately formatted in literate-programming
style, but for now you get it in one great glob:

@example  @c

( - 155-C-stdevents.muf -- Standard events for Muq Object Sys.		)
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
( Created:      98Jan31							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1999, by Jeff Prothero.				)
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
( - Quote								)
(									)
(    "The doctor is more to be feared than the disease."		)
(                    -- Latin Proverb					)
(  -------------------------------------------------------------------	)

( =====================================================================	)
( - Select MUF Package:							)

"muf" inPackage

( =====================================================================	)
( - Types -								)

defclass: event                       :export t                      ;

defclass: seriousEvent                :export t      :isA 'event     ;
defclass: simpleEvent                 :export t      :isA 'event     ;
defclass: warning                     :export t      :isA 'event     ;
defclass: printJobs                   :export t      :isA 'event     ;

defclass: abort                       :export t      :isA 'seriousEvent ;
defclass: debug                       :export t      :isA 'seriousEvent ;
defclass: error                       :export t      :isA 'seriousEvent ;
defclass: kill                        :export t      :isA 'seriousEvent ;
defclass: storageEvent                :export t      :isA 'seriousEvent ;

defclass: simpleWarning               :export t      :isA 'warning    :isA 'simpleEvent ;
defclass: brokenPipeWarning           :export t      :isA 'warning     ;
defclass: readFromDeadStreamWarning   :export t      :isA 'warning     ;
defclass: writeToDeadStreamWarning    :export t      :isA 'warning     ;
defclass: urgentCharacterWarning      :export t      :isA 'warning     ;

defclass: arithmeticError             :export t      :isA 'error       ;
defclass: cellError                   :export t      :isA 'error       ;
defclass: controlError                :export t      :isA 'error       ;
defclass: fileError                   :export t      :isA 'error       ;
defclass: packageError                :export t      :isA 'error       ;
defclass: programError                :export t      :isA 'error       ;
defclass: simpleError                 :export t      :isA 'error     :isA 'simpleEvent ;
defclass: streamError                 :export t      :isA 'error       ;
defclass: typeError                   :export t      :isA 'error       ;
defclass: serverError                 :export t      :isA 'error       ;

defclass: endOfFile                   :export t      :isA 'streamError ;

defclass: unboundVariable             :export t      :isA 'cellError   ;
defclass: undefinedFunction           :export t      :isA 'cellError   ;

defclass: divisionByZero	      :export t      :isA 'arithmeticError   ;
defclass: floatingPointOverflow       :export t      :isA 'arithmeticError   ;
defclass: floatingPointUnderflow      :export t      :isA 'arithmeticError   ;

'event.type                     --> .e.event
'seriousEvent.type              --> .e.seriousEvent
'simpleEvent.type               --> .e.simpleEvent
'warning.type                   --> .e.warning

( ...
... )

'printJobs.type                 --> .e.printJobs
'abort.type                     --> .e.abort
'debug.type                     --> .e.debug
'error.type                     --> .e.error
'kill.type                      --> .e.kill



'storageEvent.type              --> .e.storageEvent
'simpleWarning.type             --> .e.simpleWarning

'brokenPipeWarning.type         --> .e.brokenPipeWarning

( ...
... )


'readFromDeadStreamWarning.type --> .e.readFromDeadStreamWarning
'writeToDeadStreamWarning.type  --> .e.writeToDeadStreamWarning
'urgentCharacterWarning.type    --> .e.urgentCharacterWarning


'arithmeticError.type           --> .e.arithmeticError
'cellError.type                 --> .e.cellError
'controlError.type              --> .e.controlError
'fileError.type                 --> .e.fileError
'packageError.type              --> .e.packageError
'programError.type              --> .e.programError
'simpleError.type               --> .e.simpleError
'streamError.type               --> .e.streamError
'typeError.type                 --> .e.typeError
'serverError.type               --> .e.serverError

'endOfFile.type                 --> .e.endOfFile
'unboundVariable.type           --> .e.unboundVariable
'undefinedFunction.type         --> .e.undefinedFunction

'divisionByZero.type            --> .e.divisionByZero
'floatingPointOverflow.type     --> .e.floatingPointOverflow

'floatingPointUnderflow.type    --> .e.floatingPointUnderflow



( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

@c
@node Standard Events Wrapup, , Standard Events Source, Standard Events
@section Standard Events

If you have questions or suggestions, feel free to email cynbe@@muq.com.



