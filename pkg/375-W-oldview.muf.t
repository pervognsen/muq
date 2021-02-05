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

( - 385-W-oldview.muf -- 'view' support for rooms-and-exits islekit.	)
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
( Created:      97Jul13, from 380-W-oldholder.t				)
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
( - Package 'oldmud' --							)

"oldmud" inPackage


( =====================================================================	)

( - Functions -								)






( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - viewable -- Mixin for 'view'able objects.				)

defclass: viewable
    :export  t
    :is   'live

    :slot :short             :prot "rwr-r-"   :initval nil ( Short (<32 char) description )

    :slot :viewExteriorText  :prot "rw----"   :initval nil
    :slot :viewExteriorHtml  :prot "rw----"   :initval nil
    :slot :viewExteriorVrml  :prot "rw----"   :initval nil

    :slot :viewInteriorText  :prot "rw----"   :initval nil
    :slot :viewInteriorHtml  :prot "rw----"   :initval nil
    :slot :viewInteriorVrml  :prot "rw----"   :initval nil
;

( =====================================================================	)
( - viewIt -- Per-daemon state for our ]daemon shell.			)

defclass: viewIt
    :export t

;



( =====================================================================	)

( - Viewable Generic Functions -					)

( =====================================================================	)

( - Viewable Server Functions -						)

( =====================================================================	)
( - doReqShortView -- Return short ( < 32-char) view of object.		)

defgeneric: doReqShortView {[ $         $   $   $   $   $   $   $  ]} ;
defmethod:  doReqShortView { 't        't  't  't  't  't  't  't   } "doReqShortView" gripe ;
defmethod:  doReqShortView { 'viewable 't  't  't  't  't  't  't   }
    {[                       'me       'it 'hu 'av 'id 'a0 'a1 'a2 ]}

    [ nil me.short |
;
'doReqShortView export


( =====================================================================	)
( - doReqView -- Return view of object.					)

defgeneric: doReqView {[ $         $   $   $   $   $     $     $  ]} ;
defmethod:  doReqView { 't        't  't  't  't  't    't    't   } "doReqView" gripe ;
defmethod:  doReqView { 'viewable 't  't  't  't  't    't    't   }
    {[                  'me       'it 'hu 'av 'id 'side 'mime 'a2 ]}
    ( SIDE must be "in" or "out" at present.			)
    ( MIME must be "plain", "html" or "vrml" at present.	)

    side case{
    on: "out"
        mime case{
        on: "plain"   me.viewExteriorText -> view
        on: "html"    me.viewExteriorHtml -> view
        on: "vrml"    me.viewExteriorVrml -> view
        else:
            [ "Unsupported outside view mimetype: " mime join  nil nil nil | return
        }
    on: "in"
        mime case{
        on: "plain"   me.viewInteriorText -> view
        on: "html"    me.viewInteriorHtml -> view
        on: "vrml"    me.viewInteriorVrml -> view
        else:
            [ "Unsupported inside view mimetype: " mime join  nil nil nil | return
        }
    else:
        [ "Unsupported view: " side join  nil nil nil | return
    }

    view string? if 
        view length -> viewLen
        [ me.liveDaemon view mime nil nil | pub:publishString ]-> strId
    else
        nil -> viewLen
	nil -> strId
    fi

    [ nil strId viewLen   strId if nil else me.short fi |
;
'doReqView export


( =====================================================================	)
( - doSetView -- Set view of object.					)

defgeneric: doSetView {[ $         $     $     $   ]} ;
defmethod:  doSetView { 't        't    't    't    } "doSetView" gripe ;
defmethod:  doSetView { 'viewable 't    't    't    }
    {[                  'me       'side 'mime 'str ]}

    side case{
    on: "out"
        mime case{
        on: "plain"   str --> me.viewExteriorText
        on: "html"    str --> me.viewExteriorHtml
        on: "vrml"    str --> me.viewExteriorVrml
        else:
            "Unsupported mimetype: " mime join  errcho [ | return
        }
    on: "in"
        mime case{
        on: "plain"   str --> me.viewInteriorText
        on: "html"    str --> me.viewInteriorHtml
        on: "vrml"    str --> me.viewInteriorVrml
        else:
            "Unsupported mimetype: " mime join  errcho [ | return
        }
    on: "short"
        str --> me.short
    else:
        "Unsupported view: " side join  errcho [ | return
    }

    [ |
;
'doSetView export

( =====================================================================	)
( - enterViewableServerFunctions -- 					)

:   enterViewableServerFunctions { $ $ $ -> }
    -> c
    -> f
    -> n

    REQ_VIEW 'doReqView nil   n f c enterOp
;
'enterViewableServerFunctions export

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

