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

( - 363-W-oldprop-serv.muf -- Support property publication.		)
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
( Created:      97Nov02							)
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
( - Quip --								)

( Gun:  A handle with at one end a barrel, and at the other a moron.	)

( =====================================================================	)
( - Package 'oldmud', forward declarations --				)

"oldmud" inPackage



( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - propServ -- Publish properties					)

( PROP-LOCK  serializes accesses.					)
( PROP-NAME  contains the name of the nth property.			)
( PROP-GET   contains a fn to return the property.			)
( PROP-JOIN  contains a fn to subscribe to property changes.		)
( PROP-QUIT  contains a fn to unsubscribe from property changes.	)
( PROP-STATE contains a state record for property.			)

defclass: propServ
    :export t

    :slot :propLock		:prot "rw----"   :initform :: makeLock ;

    :slot :propName	 	:prot "rw----"   :initform :: makeStack ;
    :slot :propGet		:prot "rw----"   :initform :: makeStack ;
    :slot :propJoin	 	:prot "rw----"   :initform :: makeStack ;
    :slot :propQuit	 	:prot "rw----"   :initform :: makeStack ;
    :slot :propState		:prot "rw----"   :initform :: makeStack ;
;

( =====================================================================	)

( - Functions -								)

( =====================================================================	)
( - enterDefaultPropServHandlers -- 					)

:   enterDefaultPropServHandlers { $ $ $ -> }
    -> c
    -> f
    -> n

    REQ_JOIN_PROP       'doReqJoinProp       nil   n f c enterOp
    REQ_QUIT_PROP       'doReqQuitProp       nil   n f c enterOp
    REQ_PROP_NAMES      'doReqPropNames      nil   n f c enterOp
    REQ_PROPERTY        'doReqProperty        nil   n f c enterOp
;
'enterDefaultPropServHandlers export

( =====================================================================	)
( - doReqPropNames -- 						)

defgeneric: doReqPropNames {[ $          $   $   $   $   $   $   $  ]} ;
defmethod:  doReqPropNames { 't         't  't  't  't  't  't  't   } "doReqPropNames" gripe ;
defmethod:  doReqPropNames { 'propServ 't  't  't  't  't  't  't   }
    {[                          'me        'it 'hu 'av 'id 'a0 'a1 'a2 ]}

    me.propName vals[
    nil |unshift
;
'doReqListNames export

( =====================================================================	)
( - doReqJoinProp -- 						)

defgeneric: doReqJoinProp {[ $         $   $   $   $   $     $   $  ]} ;
defmethod:  doReqJoinProp { 't        't  't  't  't  't    't  't   } "doReqJoinProp" gripe ;
defmethod:  doReqJoinProp { 'listServ 't  't  't  't  't    't  't   }
    {[                      'me       'it 'hu 'av 'id 'nam  'a1 'a2 ]}

    me.propLock withLockDo{
	me.propName         -> pn
	me.propState        -> st
	pn length            -> len
	for i from 0 below len do{
	    pn[i] nam = if
		me.propJoin[i] -> pjoin
		pjoin callable? if
		    [ st[i] it hu av id me a1 a2 | pjoin call{ [] -> [] }   return
		else
		    [ "Prop-join not available for property " nam join | return
	    fi  fi
	}
    }

    [ "No such property: " nam join nil nil nil nil nil |
;
'doReqJoinProp export

( =====================================================================	)
( - doReqQuitProp -- 						)

defgeneric: doReqQuitProp {[ $         $   $   $   $   $     $   $  ]} ;
defmethod:  doReqQuitProp { 't        't  't  't  't  't    't  't   } "doReqQuitProp" gripe ;
defmethod:  doReqQuitProp { 'listServ 't  't  't  't  't    't  't   }
    {[                      'me       'it 'hu 'av 'id 'nam  'a1 'a2 ]}

    me.propLock withLockDo{
	me.propName         -> pn
	me.propState        -> st
	pn length            -> len
	for i from 0 below len do{
	    pn[i] nam = if
		me.propQuit[i] -> pquit
		pquit callable? if
		    [ st[i] it hu av id me a1 a2 | pquit call{ [] -> [] }   return
		else
		    [ "Prop-quit not available for property " nam join | return
	    fi  fi
	}
    }

    [ "No such property: " nam join nil nil nil nil nil |
;
'doReqQuitProp export

( =====================================================================	)
( - doReqProperty -- 							)

defgeneric: doReqProperty {[ $         $   $   $   $   $     $   $  ]} ;
defmethod:  doReqProperty { 't        't  't  't  't  't    't  't   } "doReqProperty" gripe ;
defmethod:  doReqProperty { 'listServ 't  't  't  't  't    't  't   }
    {[                      'me       'it 'hu 'av 'id 'nam  'a1 'a2 ]}

    me.propLock withLockDo{
	me.propName         -> pn
	me.propState        -> st
	pn length            -> len
	for i from 0 below len do{
	    pn[i] nam = if
		me.propGet[i] -> pget
		pget callable? if
		    [ st[i] it hu av id me a1 a2 | pget call{ [] -> [] }   return
		else
		    [ "Prop-get not available for property " nam join | return
	    fi  fi
	}
    }

    [ "No such property: " nam join nil nil nil nil nil |
;
'doReqProperty export

( =====================================================================	)
( - addProp -- 							)

defgeneric: addProp {[ $         $     $      $        $           $         ]} ;
defmethod:  addProp { 't        't    't     't        't         't          } "addProp" gripe ;
defmethod:  addProp { 'propServ 't    't     't        't         't          }
    {[                 'me      'name 'state 'propGet 'propJoin 'propQuit ]}

    me.propLock withLockDo{

	( Ignore redundant adds: )
	me.propName  -> pnam
	me.propState -> psta
	me.propGet   -> pget
	me.propJoin  -> pjoi
	me.propQuit  -> pqit
	pnam length   -> len
	for i from 0 below len do{
	    pnam[i] name = if [ nil | return fi
	}

	( Add the entry: )
	name      pnam push
	state     psta push
	propGet  pget push
	propJoin pjoi push
	propQuit pqit push
    }

    [ nil |
;
'addProp export

( =====================================================================	)
( - dropProp -- 							)

defgeneric: dropProp {[ $          $    ]} ;
defmethod:  dropProp { 't         't     } "dropProp" gripe ;
defmethod:  dropProp { 'propServ 't     }
    {[                  'me        'name ]}

    me.propLock withLockDo{

	me.propName  -> pnam
	me.propState -> psta
	me.propGet   -> pget
	me.propJoin  -> pjoi
	me.propQuit  -> pqit
	pnam length   -> len
	0 -> i
	do{ i len < while
	    pnam[i] nam = if
		pnam i deleteBth
		psta i deleteBth
		pget i deleteBth
		pjoi i deleteBth
		pqit i deleteBth
		-- len
	    else
		++ i
	    fi
	}
    }

    [ |
;
'dropProp export


( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

