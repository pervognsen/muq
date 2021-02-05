@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)
@example  @c

( - 400-W-oldexit.muf -- Exits for rooms-and-exits islekit.		)
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

( --------------------------------------------------------------------- )
(									)
(	For Mike Jittlov: A wiz of a wiz if ever there was!		)
(									)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      97Jul14, from 400-W-oldroom.t				)
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
( ---------------------------------------------------------------------	)

( =====================================================================	)
( - Package 'oldmud', exported symbols --				)

"oldmud" inPackage





( =====================================================================	)

( - Functions -								)

( =====================================================================	)

( - Plain functions -							)

( =====================================================================	)
( - enterExitHandlers -- 						)

:   enterExitHandlers { $ $ $ -> }
    -> c
    -> f
    -> n

    REQ_EXIT_DESTINATION 'doReqExitDestination nil   n f c enterOp
;
'enterExitHandlers export

( =====================================================================	)
( - enterDefaultExitHandlers -- Convenience fn.				)

:   enterDefaultExitHandlers { $ $ $ -> }
    -> c
    -> f
    -> n

    n f c enterDefaultThingHandlers
    n f c enterExitHandlers
;
'enterDefaultExitHandlers export

( =====================================================================	)

( - Private static variables						)

'_exitOpNames   not bound? if makeStack --> _exitOpNames   fi
'_exitOpFns     not bound? if makeStack --> _exitOpFns     fi
'_exitOpClasses not bound? if makeStack --> _exitOpClasses fi

_exitOpNames   reset
_exitOpFns     reset
_exitOpClasses reset

_exitOpNames _exitOpFns _exitOpClasses enterDefaultExitHandlers


( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - exit -- Link from one room to another.				)

( EXIT-DESTINATION  Canonical name of destination room -- text string.	)
( EXIT-DAEMON       Daemon animating destination room.			)
( EXIT-TWIN         Exit leading opposite direction, if any.		)

defclass: exit
    :export t
    :isA 'thing

    :slot :exitDestination	  :prot "rw----"
    :slot :exitDaemon		  :prot "rw----"
    :slot :exitTwin		  :prot "rw----"	:initval nil
;


( =====================================================================	)

( - Generic functions -							)

( =====================================================================	)

( - Public class creation functions -					)

( =====================================================================	)
( - initExit -- 							)

:   initExit { [] -> [] }
    |shift -> exit
    |shift -> name
    |shift -> short
    |shift -> home
    ]pop

    name  --> exit.name
    short --> exit.short

    CAN_EXIT -> can
    exit.viewExteriorText exit.viewInteriorText or if can CAN_TEXT_VIEW + -> can fi
    exit.viewExteriorHtml exit.viewInteriorHtml or if can CAN_HTML_VIEW + -> can fi
    exit.viewExteriorVrml exit.viewInteriorVrml or if can CAN_VRML_VIEW + -> can fi
    can --> exit.can

    ( Exits don't have individual daemons, )
    ( they use HOME's daemon and io:       )
    home.io --> exit.io
    home    --> exit.liveDaemon
    home    --> exit.exitDaemon

    ( Define commands implemented by exit daemon: )
    _exitOpNames   --> exit.liveNames
    _exitOpFns     --> exit.liveFns
    _exitOpClasses --> exit.liveClasses

    [ exit |
;
'initExit export


( =====================================================================	)
( - makeExit -- 							)

defgeneric: makeExit {[ $     $      $           ]} ;
defmethod:  makeExit { 't    't     't            } ;
defmethod:  makeExit { 't    't     'daemonHome  }
    {[                  'name 'short 'home        ]}

    name isAString

    'exit makeInstance -> exit

    [ exit name short home | initExit
;
'makeExit export


( =====================================================================	)
( - doReqExitDestination -- Read an exit.				)

defgeneric: doReqExitDestination {[ $     $   $   $   $   $   $   $  ]} ;
defmethod:  doReqExitDestination { 't    't  't  't  't  't  't  't   } "doReqExitDestination" gripe ;
defmethod:  doReqExitDestination { 'exit 't  't  't  't  't  't  't   }
    {[                                'me   'it 'hu 'av 'id 'a0 'a1 'a2 ]}

    [ nil me.exitDaemon me.exitDestination |
;
'doReqExitDestination export

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

