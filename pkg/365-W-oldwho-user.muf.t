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

( - 370-W-oldwho-user.muf -- Flavor so avatars can be WHO-listed.	)
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
( Created:      97Oct27							)
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
( - Package 'oldmud', forward declarations --				)

"oldmud" inPackage



( =====================================================================	)

( - Functions -								)


( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - whoUser -- perUser info for WHO					)

defclass: whoUser
    :export t

    :slot :whoDoing		:prot "rw----"		:initval  nil
    :slot :whoHidden		:prot "rw----"		:initval  nil
    :slot :whoLastActivity	:prot "rw----"		:initval  0
;


( =====================================================================	)
( - enterDefaultWhoUserHandlers -- 				)

:   enterDefaultWhoUserHandlers { $ $ $ -> }
    -> c
    -> f
    -> n

    REQ_WHO_USER_INFO 'doReqWhoUserInfo nil   n f c enterOp
;
'enterDefaultWhoUserHandlers export

( =====================================================================	)
( - noteWhoUserActivity -- 						)

:   noteWhoUserActivity { [] -> [] }
    ]-> av

    getUniversalTime --> av.whoLastActivity

    [ |
;
'noteWhoUserActivity export

( =====================================================================	)
( - noteWhoUserConnect -- 						)

:   noteWhoUserConnect { [] -> [] }
    ]-> av

    [ av | noteWhoUserActivity ]pop
    [ av.homeIsle av |
	av.whoHidden if oldmud:dropFromWhoList else oldmud:addToWhoList fi
    ]pop

    [ |
;
'noteWhoUserConnect export

( =====================================================================	)
( - noteWhoUserDisconnect -- 					)

:   noteWhoUserDisconnect { [] -> [] }
    ]-> av

    [ av.homeIsle av | oldmud:dropFromWhoList ]pop

    [ |
;
'noteWhoUserDisconnect export

( =====================================================================	)
( - doReqWhoUserInfo -- 						)

defgeneric: doReqWhoUserInfo {[ $         $   $   $   $   $   $   $  ]} ;
defmethod:  doReqWhoUserInfo { 't        't  't  't  't  't  't  't   } "doReqWhoUserInfo" gripe ;
defmethod:  doReqWhoUserInfo { 'whoUser 't  't  't  't  't  't  't   }
    {[                             'me       'it 'hu 'av 'id 'a0 'a1 'a2 ]}

    me.whoHidden if [ "Not on whoList" | return fi

    getUniversalTime me.whoLastActivity - -> idle
    [ nil idle me.whoDoing |
;
'doReqWhoUserInfo export

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

