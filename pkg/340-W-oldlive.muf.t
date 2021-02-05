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

( - 340-W-oldlive.muf -- Live objects for rooms-and-exits islekit.	)
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
( Created:      97Jul10, from 33-W-oldmud.t				)
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
( ---------------------------------------------------------------------	)

( =====================================================================	)
( - Overview -								)




( =====================================================================	)
( - Package 'oldmud', forward declarations --				)

"oldmud" inPackage

( Implemented in ping file: )
'enterPingServerFunctions   export
'enterPingServerFunctions.function compiledFunction? not if
  :: { $ $ $ -> ! } ; --> 'enterPingServerFunctions.function
fi

( Implemented in nop file: )
'enterNopServerFunctions   export
'enterNopServerFunctions.function compiledFunction? not if
  :: { $ $ $ -> ! } ; --> 'enterNopServerFunctions.function
fi


( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - live -- mixin making an object responsive via an I/O queue		)

( 'io' is the message queue used to communicate with object;		)
(									)
( 'liveDaemon' is a daemonHome instance, home to the daemon which	)
(       handles requests on IO:  the basic driver invariant is that	)
(	live/driver/daemonJob should the job reading IO, for any	)
(	live object.							)
( 'liveNames', 'liveFns' and 'liveClasses' stacks define the operations	)
(	implemented by the object:  They are filled in by functions	)
(	like enterDefaultAvatarHandlers and used by functions like	)
(	]daemon.							)

defclass: live
    :export t

    ( Message stream accepting request packet: )
    :slot :io	       		:prot "rwr-r-"
    :slot :liveDaemon 		:prot "rwr-r-"
    :slot :liveNames		:prot "rw----"
    :slot :liveFns		:prot "rw----"
    :slot :liveClasses		:prot "rw----"
;

( =====================================================================	)

( - Functions -								)

( =====================================================================	)
( - enterDefaultLiveHandlers -- Convenience fn.			)

:   enterDefaultLiveHandlers { $ $ $ -> }
    -> c
    -> f
    -> n

    n f c enterNopServerFunctions
    n f c enterPingServerFunctions
;

( =====================================================================	)
( - initLiveHandlers -- Convenience fn.				)

:   initLiveHandlers { $ $ $ $ -> }
    -> c
    -> f
    -> n
    -> o

    n --> o.liveNames
    f --> o.liveFns
    c --> o.liveClasses
;
'initLiveHandlers export

( =====================================================================	)
( - wakeLiveDaemon -- Generic fn called after starting up daemon.	)

defgeneric: wakeLiveDaemon {[ $    ]} ;
defmethod:  wakeLiveDaemon { 't     } ;
'wakeLiveDaemon export

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

