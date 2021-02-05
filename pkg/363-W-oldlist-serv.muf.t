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

( - 363-W-oldlist-serv.muf -- Support list publication.			)
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
( - Package 'oldmud', forward declarations --				)

"oldmud" inPackage



( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - listServ -- Publish lists						)

( LIST-LOCK  serializes accesses.					)
( LIST-NAME  contains the name of the nth list.				)
( LIST-NEXT  contains a fn to return next entry from named list.	)
( LIST-PREV  contains a fn to return prev entry from named list.	)
( LIST-THIS  contains a fn to return entry from named list given id.	)
( LIST-INFO  contains a fn to return global list information.		)
( LIST-FIND  contains a fn to search list for an entry.			)
( LIST-JOIN  contains a fn to subscribe to change notifications.	)
( LIST-QUIT  contains a fn to unsubscribe from change notifications.	)
( LIST-ADD-TO contains a fn to add entries to list.			)
( LIST-DROP  contains a fn to remove entries from list.			)
( LIST-STATE contains a state record for list.				)

defclass: listServ
    :export t

    :slot :listLock		:prot "rw----"   :initform :: makeLock ;

    :slot :listName	 	:prot "rw----"   :initform :: makeStack ;
    :slot :listInfo		:prot "rw----"   :initform :: makeStack ;
    :slot :listNext		:prot "rw----"   :initform :: makeStack ;
    :slot :listPrev		:prot "rw----"   :initform :: makeStack ;
    :slot :listThis		:prot "rw----"   :initform :: makeStack ;
    :slot :listFind		:prot "rw----"   :initform :: makeStack ;
    :slot :listJoin		:prot "rw----"   :initform :: makeStack ;
    :slot :listQuit		:prot "rw----"   :initform :: makeStack ;
    :slot :listAddTo		:prot "rw----"   :initform :: makeStack ;
    :slot :listDropFrom         :prot "rw----"   :initform :: makeStack ;
    :slot :listState		:prot "rw----"   :initform :: makeStack ;
;

( =====================================================================	)

( - Functions -								)

( =====================================================================	)
( - enterDefaultListServHandlers -- 					)

:   enterDefaultListServHandlers { $ $ $ -> }
    -> c
    -> f
    -> n

    REQ_LIST_NAMES      'doReqListNames     nil   n f c enterOp
    REQ_LIST_INFO       'doReqListInfo      nil   n f c enterOp
    REQ_JOIN_LIST       'doReqJoinList      nil   n f c enterOp
    REQ_QUIT_LIST       'doReqQuitList      nil   n f c enterOp
    REQ_NEXT_LIST_ENTRY 'doReqNextListEntry nil   n f c enterOp
    REQ_PREV_LIST_ENTRY 'doReqPrevListEntry nil   n f c enterOp
    REQ_THIS_LIST_ENTRY 'doReqThisListEntry nil   n f c enterOp
    REQ_FIND_LIST_ENTRY 'doReqFindListEntry nil   n f c enterOp
    REQ_ADD_TO_LIST     'doReqAddToList     nil   n f c enterOp
    REQ_DROP_FROM_LIST  'doReqDropFromList  nil   n f c enterOp
;
'enterDefaultListServHandlers export

( =====================================================================	)
( - doReqListNames -- 							)

defgeneric: doReqListNames {[ $          $   $   $   $   $   $   $  ]} ;
defmethod:  doReqListNames { 't         't  't  't  't  't  't  't   } "doReqListNames" gripe ;
defmethod:  doReqListNames { 'listServ 't  't  't  't  't  't  't   }
    {[                          'me        'it 'hu 'av 'id 'a0 'a1 'a2 ]}

    me.listName vals[
    nil |unshift
;
'doReqListNames export

( =====================================================================	)
( - doReqJoinList -- 							)

defgeneric: doReqJoinList {[ $         $   $   $   $   $     $   $  ]} ;
defmethod:  doReqJoinList { 't        't  't  't  't  't    't  't   } "doReqJoinList" gripe ;
defmethod:  doReqJoinList { 'listServ 't  't  't  't  't    't  't   }
    {[                      'me       'it 'hu 'av 'id 'nam  'a1 'a2 ]}

    me.listLock withLockDo{
	me.listName         -> ln
	me.listState        -> st
	ln length            -> len
	for i from 0 below len do{
	    ln[i] nam = if
		me.listJoin[i] -> ljoin
		ljoin callable? if
		    [ st[i] it hu av id me a1 a2 | ljoin call{ [] -> [] }   return
		else
		    [ "List-join not available for list " nam join | return
	    fi  fi
	}
    }

    [ "No such list: " nam join nil nil nil nil nil |
;
'doReqJoinList export

( =====================================================================	)
( - doReqQuitList -- 							)

defgeneric: doReqQuitList {[ $         $   $   $   $   $     $   $  ]} ;
defmethod:  doReqQuitList { 't        't  't  't  't  't    't  't   } "doReqQuitList" gripe ;
defmethod:  doReqQuitList { 'listServ 't  't  't  't  't    't  't   }
    {[                      'me       'it 'hu 'av 'id 'nam  'a1 'a2 ]}

    me.listLock withLockDo{
	me.listName         -> ln
	me.listState        -> st
	ln length            -> len
	for i from 0 below len do{
	    ln[i] nam = if
		me.listQuit[i] -> lquit
		lquit callable? if
		    [ st[i] it hu av id me a1 a2 | lquit call{ [] -> [] }   return
		else
		    [ "List-quit not available for list " nam join | return
	    fi  fi
	}
    }

    [ "No such list: " nam join nil nil nil nil nil |
;
'doReqQuitList export

( =====================================================================	)
( - doReqListInfo -- 							)

defgeneric: doReqListInfo {[ $          $   $   $   $   $     $   $  ]} ;
defmethod:  doReqListInfo { 't         't  't  't  't  't    't  't   } "doReqListInfo" gripe ;
defmethod:  doReqListInfo { 'listServ 't  't  't  't  't    't  't   }
    {[                         'me        'it 'hu 'av 'id 'nam  'a1 'a2 ]}

    me.listLock withLockDo{
	me.listName         -> ln
	me.listState        -> st
	ln length            -> len
	for i from 0 below len do{
	    ln[i] nam = if
		me.listInfo[i] -> info
		info callable? if
		    [ st[i] it hu av id me a1 a2 | info call{ [] -> [] }   return
		else
		    [ "List-info not available for list " nam join | return
	    fi  fi
	}
    }

    [ "No such list: " nam join nil nil nil nil nil |
;
'doReqListInfo export

( =====================================================================	)
( - doReqNextListEntry -- 						)

defgeneric: doReqNextListEntry {[ $          $   $   $   $   $   $    $  ]} ;
defmethod:  doReqNextListEntry { 't         't  't  't  't  't  't   't   } "doReqNextListEntry" gripe ;
defmethod:  doReqNextListEntry { 'listServ 't  't  't  't  't  't   't   }
    {[                               'me        'it 'hu 'av 'id 'n  'nam 'a2 ]}

    me.listLock withLockDo{
	me.listName         -> ln
	me.listState        -> st
	ln length            -> len
	for i from 0 below len do{
	    ln[i] nam = if
		me.listNext[i] -> next
		next callable? if
		    [ st[i] it hu av id n me a2 | next call{ [] -> [] }   return
		else
		    [ "List-next not available for list " nam join | return
	    fi  fi
	}
    }

    [ "No such list: " nam join nil nil nil nil nil |
;
'doReqNextListEntry export

( =====================================================================	)
( - doReqPrevListEntry -- 						)

defgeneric: doReqPrevListEntry {[ $         $   $   $   $   $  $    $  ]} ;
defmethod:  doReqPrevListEntry { 't        't  't  't  't  't 't   't   } "doReqPrevListEntry" gripe ;
defmethod:  doReqPrevListEntry { 'listServ 't  't  't  't  't 't   't   }
    {[                           'me       'it 'hu 'av 'id 'n 'nam 'a2 ]}

    me.listLock withLockDo{
	me.listName         -> ln
	me.listState        -> st
	ln length            -> len
	for i from 0 below len do{
	    ln[i] nam = if
		me.listPrev[i] -> prev
		prev callable? if
		    [ st[i] it hu av id n me a2 | prev call{ [] -> [] }   return
		else
		    [ "List-prev not available for list " nam join | return
	    fi  fi
	}
    }

    [ "No such list: " nam join nil nil nil nil nil |
;
'doReqPrevListEntry export

( =====================================================================	)
( - doReqThisListEntry -- 						)

defgeneric: doReqThisListEntry {[ $         $   $   $   $   $  $    $  ]} ;
defmethod:  doReqThisListEntry { 't        't  't  't  't  't 't   't   } "doReqThisListEntry" gripe ;
defmethod:  doReqThisListEntry { 'listServ 't  't  't  't  't 't   't   }
    {[                           'me       'it 'hu 'av 'id 'n 'nam 'a2 ]}

    me.listLock withLockDo{
	me.listName         -> ln
	me.listState        -> st
	ln length            -> len
	for i from 0 below len do{
	    ln[i] nam = if
		me.listPrev[i] -> this
		this callable? if
		    [ st[i] it hu av id n me a2 | this call{ [] -> [] }   return
		else
		    [ "List-this not available for list " nam join | return
	    fi  fi
	}
    }

    [ "No such list: " nam join nil nil nil nil nil |
;
'doReqThisListEntry export

( =====================================================================	)
( - doReqFindListEntry -- 						)

defgeneric: doReqFindListEntry {[ $         $   $   $   $   $   $    $  ]} ;
defmethod:  doReqFindListEntry { 't        't  't  't  't  't  't   't   } "doReqPrevListEntry" gripe ;
defmethod:  doReqFindListEntry { 'listServ 't  't  't  't  't  't   't   }
    {[                           'me       'it 'hu 'av 'id 'k  'nam 'a2 ]}

    me.listLock withLockDo{
	me.listName         -> ln
	me.listState        -> st
	ln length            -> len
	for i from 0 below len do{
	    ln[i] nam = if
		me.listFind[i] -> find
		find callable? if
		    [ st[i] it hu av id k me a2 | find call{ [] -> [] }   return
		else
		    [ "List-find not available for list " nam join | return
	    fi  fi
	}
    }

    [ "No such list: " nam join nil nil nil nil nil |
;
'doReqPrevListEntry export

( =====================================================================	)
( - doReqAddToList -- 							)

defgeneric: doReqAddToList {[ $         $   $   $   $   $    $   $  ]} ;
defmethod:  doReqAddToList { 't        't  't  't  't  't   't  't   } "doReqAddToList" gripe ;
defmethod:  doReqAddToList { 'listServ 't  't  't  't  't   't  't   }
    {[                       'me       'it 'hu 'av 'id 'nam 'a  'a2 ]}
( .sys.muqPort d, "(363)<" d, @ d, ">doReqAddToList/aaa\n" d, )
( .sys.muqPort d, "(363)<" d, @ d, ">doReqAddToList me = " d, me d, "\n" d, )
( .sys.muqPort d, "(363)<" d, @ d, ">doReqAddToList it = " d, it d, "\n" d, )
( .sys.muqPort d, "(363)<" d, @ d, ">doReqAddToList hu = " d, hu d, "\n" d, )
( .sys.muqPort d, "(363)<" d, @ d, ">doReqAddToList av = " d, av d, "\n" d, )
( .sys.muqPort d, "(363)<" d, @ d, ">doReqAddToList id = " d, id d, "\n" d, )
( .sys.muqPort d, "(363)<" d, @ d, ">doReqAddToList nam = " d, nam d, "\n" d, )
( .sys.muqPort d, "(363)<" d, @ d, ">doReqAddToList a = " d, a d, "\n" d, )
( .sys.muqPort d, "(363)<" d, @ d, ">doReqAddToList a2 = " d, a2 d, "\n" d, )

    me.listLock withLockDo{
	me.listName          -> ln
	me.listState         -> st
	ln length            -> len
	for i from 0 below len do{
	    ln[i] nam = if
		me.listAddTo[i] -> addTo
		addTo callable? if
		    [ st[i] it hu av id a a2 nil | addTo call{ [] -> [] }
( .sys.muqPort d, "(363)<" d, @ d, ">doReqAddToList/zzz\n" d, )
                    return
		else
( .sys.muqPort d, "(363)<" d, @ d, ">doReqAddToList/yyy\n" d, )
		    [ "List-add-to not available for list " nam join | return
	    fi  fi
	}
    }

( .sys.muqPort d, "(363)<" d, @ d, ">doReqAddToList/xxx\n" d, )
    [ "No such list: " nam join nil nil nil nil nil |
;
'doReqAddToListEntry export

( =====================================================================	)
( - doReqDropFromList -- 						)

defgeneric: doReqDropFromList {[ $         $   $   $   $   $    $   $  ]} ;
defmethod:  doReqDropFromList { 't        't  't  't  't  't   't  't   } "doReqDropFromList" gripe ;
defmethod:  doReqDropFromList { 'listServ 't  't  't  't  't   't  't   }
    {[                          'me       'it 'hu 'av 'id 'nam 'a  'a2 ]}

    me.listLock withLockDo{
	me.listName         -> ln
	me.listState        -> st
	ln length            -> len
	for i from 0 below len do{
	    ln[i] nam = if
		me.listDropFrom[i] -> dropFrom
		dropFrom callable? if
		    [ st[i] it hu av id a a2 | dropFrom call{ [] -> [] }   return
		else
		    [ "List-drop-from not available for list " nam join | return
	    fi  fi
	}
    }

    [ "No such list: " nam join nil nil nil nil nil |
;
'doReqDropFromList export

( =====================================================================	)
( - addList -- 								)

defgeneric: addList {[ $          $     $      $     $     $     $     $     $     $     $       $ ]} ;
defmethod:  addList { 't         't    't     't    't    't    't    't    't    't    't      't  } "addList" gripe ;
defmethod:  addList { 'listServ 't    't     't    't    't    't    't    't    't    't      't        }
    {[                 'me        'name 'state 'info 'next 'prev 'this 'find 'join 'quit 'addTo 'dropFrom ]}

    me.listLock withLockDo{

	( Ignore redundant adds: )
	me.listName      -> lnam
	me.listInfo      -> linf
	me.listNext      -> lnxt
	me.listPrev      -> lprv
	me.listThis      -> lths
	me.listFind      -> lfnd
	me.listJoin      -> ljoi
	me.listQuit      -> lqit
	me.listAddTo    -> ladd
	me.listDropFrom -> ldrp
	me.listState -> lsta
	lnam length   -> len
	for i from 0 below len do{
	    lnam[i] name = if [ | return fi
	}

	( Add the entry: )
	name      lnam push
	state     lsta push
	info      linf push
	next      lnxt push
	prev      lprv push
	this      lths push
	find      lfnd push
	join      ljoi push
	quit      lqit push
	addTo    ladd push
	dropFrom ldrp push
    }

    [ |
;
'addList export

( =====================================================================	)
( - dropList -- 							)

defgeneric: dropList {[ $          $    ]} ;
defmethod:  dropList { 't         't     } "dropList" gripe ;
defmethod:  dropList { 'listServ 't     }
    {[                  'me        'name ]}

    me.listLock withLockDo{

	me.listName      -> lnam
	me.listState     -> lsta
	me.listInfo      -> linf
	me.listNext      -> lnxt
	me.listPrev      -> lprv
	me.listThis      -> lths
	me.listFind      -> lfnd
	me.listJoin      -> ljoi
	me.listQuit      -> lqit
	me.listAddTo    -> ladd
	me.listDropFrom -> ldrp
	lnam length   -> len
	0 -> i
	do{ i len < while
	    lnam[i] nam = if
		lnam i deleteBth
		lnxt i deleteBth
		lprv i deleteBth
		lths i deleteBth
		linf i deleteBth
		lsta i deleteBth
		lfnd i deleteBth
		ljoi i deleteBth
		lqit i deleteBth
		ladd i deleteBth
		ldrp i deleteBth
		-- len
	    else
		++ i
	    fi
	}
    }

    [ |
;
'dropList export


( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

