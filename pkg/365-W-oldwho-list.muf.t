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

( - 365-W-oldwho-list.muf -- Flavor so isles can support WHO-lists.	)
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

( - Parameters -							)

200 --> _whoListDefaultMaxListed
200 --> _WhoListDefaultMaxSubscribers

( =====================================================================	)

( - Functions -								)


( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - whoList -- perIsle info for WHO					)

( WHO-AVATAR is a pointer to the avatar proper.				)
( WHO-LISTED-SINCE is the date at which it was entered on the WHO list.	)
( WHO-ID  is an integer listing id -- they are assigned sequentially.	)
(									)
( WHO-NEXT is the next ID to assign.					)
( WHO-LOCK is a lock to serialize updates to the whoList.		)

defclass: whoList
    :export t

    :slot :whoLock		:prot "rw----"   :initform :: makeLock ;
    :slot :whoNext		:prot "rw----"   :initval  1
    :slot :whoMaxListed	:prot "rw----"   :initform :: _whoListDefaultMaxListed ;
    :slot :whoMaxSubscribers	:prot "rw----"   :initform :: _WhoListDefaultMaxSubscribers ;

    :slot :whoAvatar	 	:prot "rw----"   :initform :: makeStack ;
    :slot :whoListedSince	:prot "rw----"   :initform :: makeStack ;
    :slot :whoId		:prot "rw----"   :initform :: makeStack ;
    :slot :whoName		:prot "rw----"   :initform :: makeStack ;

    :slot :whoSubscribers	:prot "rw----"   :initform :: makeStack ;
;







( =====================================================================	)

( =====================================================================	)

( - Public class creation functions -					)

( =====================================================================	)
( - doReqWhoListInfo -- 						)

:  doReqWhoListInfo { [] -> [] }
    {[                    'me       'it 'hu 'av 'id 'a0 'a1 'a2 ]}

    me.whoAvatar length -> len

    [ nil len me.whoNext |
;
'doReqWhoListInfo export

( =====================================================================	)
( - doReqJoinWhoList -- 						)

:  doReqJoinWhoList { [] -> [] }
    {[                    'me       'it 'hu 'av 'id 'a  'a1 'a2 ]}

    me.whoLock withLockDo{

	( Avoid being spammed: )
	me.whoSubscribers -> sub
	sub length         -> len
	len me.whoMaxSubscribers >= if
	    [ "List is oversubscribed" | return
	fi

	( Avoid entering subscriber more than once: )
	for i from 0 below len do{
	    sub[i] -> subi
	    subi a = if [ nil | return fi
	}

	a sub push
    }
    [ nil |
;
'doReqJoinWhoList export

( =====================================================================	)
( - doReqQuitWhoQuitList -- 						)

:  doReqQuitWhoList { [] -> [] }
    {[                    'me       'it 'hu 'av 'id 'a  'a1 'a2 ]}

    me.whoLock withLockDo{

	me.whoSubscribers  -> sub
	sub length          -> len
	0 -> i
	do{  i len < while
	    sub[i] -> subi
	    subi a = if
		sub i deleteBth
		-- len
	    else
		++ i
	    fi
	}
    }
    [ nil |
;
'doReqQuitWhoList export

( =====================================================================	)
( - doReqWhoNextEntry -- 						)

:  doReqWhoNextEntry { [] -> [] }
    {[                     'me       'it 'hu 'av 'id 'n  'a1 'a2 ]}

    me.whoLock withLockDo{
	me.whoId            -> id
	me.whoAvatar        -> av
	me.whoName          -> nm
	me.whoListedSince  -> ls
	av length            -> len
	for i from 0 below len do{
	    id[i] -> idi
	    idi n > if
		av[i] -> avi
		ls[i] -> lsi
		nm[i] -> nmi
		getUniversalTime lsi - -> lsi
		[ nil avi lsi idi nmi | return
	    fi
	}
    }

    [ nil nil nil nil nil |
;
'doReqWhoNextEntry export

( =====================================================================	)
( - doReqWhoPrevEntry -- 						)

:  doReqWhoPrevEntry { [] -> [] }
    {[                     'me       'it 'hu 'av 'id 'n  'a1 'a2 ]}

    me.whoLock withLockDo{
	me.whoId            -> id
	me.whoAvatar        -> av
	me.whoName          -> nm
	me.whoListedSince  -> ls
	av length 1-         -> top
	for i from top downto 0 do{
	    id[i] -> idi
	    idi n < if
		av[i] -> avi
		ls[i] -> lsi
		nm[i] -> nmi
		getUniversalTime lsi - -> lsi
		[ nil avi lsi idi nmi | return
	    fi
	}
    }

    [ nil nil nil nil nil |
;
'doReqWhoPrevEntry export

( =====================================================================	)
( - whoFindEntry -- 							)

:   whoFindEntry { [] -> [] }
    |shift -> me
    |shift -> n
    ]pop

    asMeDo{
	me.whoLock withLockDo{
	    me.whoId            -> id
	    me.whoAvatar        -> av
	    me.whoName          -> nm
	    me.whoListedSince  -> ls
	    av length 1-         -> top
	    for i from top downto 0 do{
		nm[i] -> nmi
		nmi n =-ci if
		    av[i] -> avi
		    ls[i] -> lsi
		    nm[i] -> nmi
		    id[i] -> idi
		    getUniversalTime lsi - -> lsi
		    [ nil avi lsi idi nmi | return
		fi
	    }
	}
    }

    [ nil nil nil nil nil |
;
'whoFindEntry export

( =====================================================================	)
( - doReqWhoFindEntry -- 						)

:   doReqWhoFindEntry { [] -> [] }
    {[                     'me       'it 'hu 'av 'id 'n  'a1 'a2 ]}

    [ me n | whoFindEntry
;
'doReqWhoFindEntry export

( =====================================================================	)
( - addToWhoList -- 							)

defgeneric: addToWhoList {[ $         $   ]} ;
defmethod:  addToWhoList { 't        't    } "addToWhoList" gripe ;
defmethod:  addToWhoList { 'whoList 't    }
    {[                        'me       'avx ]}

    avx @.task.taskState = if
	asMeDo{
	    me.whoLock withLockDo{

		( Ignore redundant adds: )
		me.whoId            -> id
		me.whoAvatar        -> av
		me.whoName          -> nm
		me.whoListedSince  -> ls
		av length            -> len
		for i from 0 below len do{
		    av[i] -> avi
		    avi avx = if [ nil | return fi
		}

		( Refuse to be insanely spammed: )
		len me.whoMaxListed >= if
		    [ "@who list is full" | return
		fi

		( Assign new id number: )
		me.whoNext -> idi
		idi 1 +    --> me.whoNext

		( Add the entry: )
		getUniversalTime -> now
		avx.name           -> nam
		idi id push
		avx av push
		nam nm push
		now ls push
	    }
	}
    fi

    [ nil |
;
'addToWhoList export

( =====================================================================	)
( - dropFromWhoList -- 							)

defgeneric: dropFromWhoList {[ $         $   ]} ;
defmethod:  dropFromWhoList { 't        't    } "dropFromWhoList" gripe ;
defmethod:  dropFromWhoList { 'whoList 't    }
    {[                           'me       'avx ]}

    avx @.task.taskState = if
	asMeDo{
	    me.whoLock withLockDo{

		( Find entry: )
		me.whoId            -> id
		me.whoAvatar        -> av
		me.whoName          -> nm
		me.whoListedSince  -> ls
		av length            -> len
		0 -> i 
		do{	i len < while
		    av[i] -> avi
		    avi avx = if
			id i deleteBth
			av i deleteBth
			nm i deleteBth
			ls i deleteBth
			-- len
		    else
			++ i
		    fi
		}
	    }
	}
    fi

    [ |
;
'dropFromWhoList export


( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

