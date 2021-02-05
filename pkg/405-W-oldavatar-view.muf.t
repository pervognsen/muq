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

( - 405-W-oldavatar-view.muf -- avatar 'view' support for islekit.	)
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
( Created:      97Oct04, from 405-W-oldavatar-look.t			)
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
( - Quote								)

( She laughed, and she said,						)
(  "It's better sometimes, when we don't get to touch our dreams."	)
(				"Sequel"  Harry Chapin			)
( --------------------------------------------------------------------- )

( =====================================================================	)
( - Package 'oldmud' --							)

"oldmud" inPackage


( =====================================================================	)

( - Functions -								)



( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - viewableAavatar -- Mixin for 'view'able objects.			)

defclass: viewableAavatar
    :export  t

    :slot :mayNotViewState  :prot "rw----"   :initform :: 'viewable makeInstance ;
    :slot :publicViewState  :prot "rw----"   :initform :: 'viewable makeInstance ;
    :slot :friendViewState  :prot "rw----"   :initform :: 'viewable makeInstance ;
    :slot :loverViewState   :prot "rw----"   :initform :: 'viewable makeInstance ;
    :slot :friendViewList   :prot "rw----"   :initval nil
    :slot :loverViewList    :prot "rw----"   :initval nil
;

( =====================================================================	)

( - Viewable constants -						)

( Classes of observers.  We may wish to   )
( generate different appearances for each )
( class:                                  )
0 --> mayNotView
1 --> publicView
2 --> friendView
3 --> loverView

( =====================================================================	)

( - Viewable Generic Functions -					)

( =====================================================================	)

( - Viewable Server Functions -						)

( =====================================================================	)
( - viewerClass -- Decide what class of observer we have.		)

defgeneric: viewerClass {[ $    $                $   $     $     ]} ;
defmethod:  viewerClass { 't   't               't  't    't      } "viewerClass" gripe ;
defmethod:  viewerClass { 't   'viewableAavatar 't  't    't      }
    {[                     'who 'me              'av 'side 'mime  ]}

    ( For now, we return a constant public appearance.  )
    ( Beware that viewer (av) may be on another server, )
    ( so testing properties on viewer may stall this    )
    ( thread for multiple seconds.  You should probably )
    ( either use only properties on your avatar, which  )
    ( is known to be local -- such as a list of lovers  )
    ( -- or else pass the task off to a separate job.   )

    ( For now, we have just a single public view: )
    [ publicView |
;
'viewerClass export

( =====================================================================	)
( - doMayNotView -- Reject attempt to view us.			)

defgeneric: doMayNotView {[ $                $   $   $   $   $        $   $  ]} ;
defmethod:  doMayNotView { 't               't  't  't  't  't       't  't   } "doMayNotView" gripe ;
defmethod:  doMayNotView { 'viewableAavatar 't  't  't  't  't       't  't   }

    ( Delegate to appropriate subobject: )
    |shift -> me
    me.mayNotViewState |unshift
    doReqView
;
'doMayNotView export

( =====================================================================	)
( - doPublicView -- Public view.					)

defgeneric: doPublicView {[ $                $   $   $   $   $        $   $  ]} ;
defmethod:  doPublicView { 't               't  't  't  't  't       't  't   } "doPublicView" gripe ;
defmethod:  doPublicView { 'viewableAavatar 't  't  't  't  't       't  't   }

    ( Delegate to appropriate subobject: )
    |shift -> me
    me.publicViewState |unshift
    doReqView
;
'doPublicView export

( =====================================================================	)
( - doFriendView -- Friendly view.					)

defgeneric: doFriendView {[ $                $   $   $   $   $        $   $  ]} ;
defmethod:  doFriendView { 't               't  't  't  't  't       't  't   } "doFriendView" gripe ;
defmethod:  doFriendView { 'viewableAavatar 't  't  't  't  't       't  't   }

    ( Delegate to appropriate subobject: )
    |shift -> me
    me.friendViewState |unshift
    doReqView
;
'doFriendView export

( =====================================================================	)
( - doLoverView -- Lover's-only view.					)

defgeneric: doLoverView {[ $                $   $   $   $   $        $   $  ]} ;
defmethod:  doLoverView { 't               't  't  't  't  't       't  't   } "doLoverView" gripe ;
defmethod:  doLoverView { 'viewableAavatar 't  't  't  't  't       't  't   }

    ( Delegate to appropriate subobject: )
    |shift -> me
    me.loverViewState |unshift
    doReqView
;
'doLoverView export

( =====================================================================	)
( - doReqView -- Return view of object.				)

defmethod:  doReqView { 'viewableAavatar 't  't  't  't  't    't    't   }
    {[                  'me              'it 'hu 'av 'id 'side 'mime 'a2 ]}

    [ hu me av side mime | viewerClass ]-> vc

    ( Use a different generic for each view class,  )
    ( to simplify defining new methods for a single )
    ( class:                                        )
    vc case{
    on: mayNotView  [ me it hu av id side mime a2 | doMayNotView return
    on: publicView  [ me it hu av id side mime a2 | doPublicView return
    on: friendView  [ me it hu av id side mime a2 | doFriendView return
    on: loverView   [ me it hu av id side mime a2 |  doLoverView return
    }

    ( Just to keep the compiler happy: )
    [ |
;

( =====================================================================	)
( - doReqShortView -- Return short ( < 32-char) view of object.		)

defmethod:  doReqShortView { 'viewableAavatar 't  't  't  't  't  't  't   }
    {[                       'me              'it 'hu 'av 'id 'a0 'a1 'a2 ]}

    [ nil me.publicViewState.short |
;


( =====================================================================	)
( - doSetView -- Set view of object.					)

defmethod:  doSetView { 'viewableAavatar 't    't    't    }
    {[                  'me              'side 'mime 'str ]}

    side "short" = if
	[ me.mayNotViewState side mime str | doSetView ]pop
	[ me.publicViewState side mime str | doSetView ]pop
	[ me.friendViewState side mime str | doSetView ]pop
	[ me.loverViewState  side mime str | doSetView ]pop
    else
	[ me.publicViewState  side mime str | doSetView ]pop
    fi

    [ |
;

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

