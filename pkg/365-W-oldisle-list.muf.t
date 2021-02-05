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

( - 365-W-oldisle-list.muf -- Per-isle list of other isles.		)
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
( Created:      97Nov04, from oldwhoList.				)
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

( The 'if's here are to establish the symbol as a function of )
( the appropriate signature, but without clobbering the fn if )
( it already exists -- i.e., if we're just reloading one file )

( Implemented in ping file: )
'doReqPing   export
'doReqPing.function compiledFunction? not if
  :: { [] -> [] ! } ; --> 'doReqPing.function
fi

( Room constructor, so makeIsle can create nursery and quay rooms: )
'makeRoom export
'makeRoom.function compiledFunction? not if
    :: { [] -> [] ! } ; --> 'makeRoom.function
fi

( Exit constructor, so makeIsle can connect nursery and quay rooms: )
'makeExit export
'makeExit.function compiledFunction? not if
    :: { [] -> [] ! } ; --> 'makeExit.function
fi

( Holding: )
'enhold export
'enhold.function compiledFunction? not if
    :: { $ $ -> ! } ; --> 'enhold.function
fi
'enheldBy export
'enheldBy.function compiledFunction? not if
    :: { $ $ -> ! } ; --> 'enheldBy.function
fi
'deholding export
'deholding.function compiledFunction? not if
    :: { $ $ -> $ ! } ; --> 'deholding.function
fi
'deheldBy export
'deheldBy.function compiledFunction? not if
    :: { $ $ -> $ ! } ; --> 'deheldBy.function
fi




( =====================================================================	)

( - Parameters -							)

200 --> _isleListDefaultMaxListed
200 --> _isleListDefaultMaxSubscribers

( =====================================================================	)

( - Functions -								)


( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - isleList -- perIsle list of other isles				)

( ISLE-ISLE is a pointer to the isle proper.				)
( ISLE-NAME is name for the isle.					)
( ISLE-LISTED-SINCE is the date at which it was entered on the ist.	)
( ISLE-ID  is an integer listing id, are assigned sequentially.	)
(									)
( ISLE-NEXT is the next ID to assign.					)
( ISLE-LIST-LOCK is a lock to serialize updates to the isleList.	)

defclass: isleList
    :export t

    :slot :isleNameMax		:prot "rw----"   :initval  32
    :slot :isleListLock		:prot "rw----"   :initform :: makeLock ;
    :slot :isleNext		:prot "rw----"   :initval  1
    :slot :isleMaxListed	:prot "rw----"   :initform :: _isleListDefaultMaxListed ;
    :slot :isleMaxSubscribers :prot "rw----"   :initform :: _isleListDefaultMaxSubscribers ;

    :slot :isleIsle		:prot "rw----"   :initform :: makeStack ;
    :slot :isleListedSince	:prot "rw----"   :initform :: makeStack ;
    :slot :isleId		:prot "rw----"   :initform :: makeStack ;
    :slot :isleName		:prot "rw----"   :initform :: makeStack ;
    :slot :isleProa		:prot "rw----"   :initform :: makeStack ;

    :slot :isleSubscribers	:prot "rw----"   :initform :: makeStack ;
;







( =====================================================================	)

( =====================================================================	)

( - Public class creation functions -					)

( =====================================================================	)
( - doReqIsleListInfo -- 						)

:  doReqIsleListInfo { [] -> [] }
    {[                    'me       'it 'hu 'av 'id 'a0 'a1 'a2 ]}

    me.isleIsle length -> len

    [ nil len me.isleNext |
;
'doReqIsleListInfo export

( =====================================================================	)
( - doReqJoinIsleList -- 						)

:  doReqJoinIsleList { [] -> [] }
    {[                    'me       'it 'hu 'av 'id 'a  'a1 'a2 ]}

    me.isleListLock withLockDo{

	( Avoid being spammed: )
	me.isleSubscribers -> sub
	sub length         -> len
	len me.isleMaxSubscribers >= if
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
'doReqJoinIsleList export

( =====================================================================	)
( - doReqQuitIsleQuitList -- 						)

:  doReqQuitIsleList { [] -> [] }
    {[                    'me       'it 'hu 'av 'id 'a  'a1 'a2 ]}

    me.isleListLock withLockDo{

	me.isleSubscribers  -> sub
	sub length          -> len
	0 -> i
	do{ i len < while
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
'doReqQuitIsleList export

( =====================================================================	)
( - doReqIsleNextEntry -- 						)

:  doReqIsleNextEntry { [] -> [] }
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIsleNextEntry/aaa\n" d, )
    {[                     'me       'it 'hu 'av 'id 'n  'a1 'a2 ]}

    me.isleListLock withLockDo{
	me.isleId            -> id
	me.isleIsle          -> wd
	me.isleName          -> wn
	me.isleListedSince  -> ls
	wd length             -> len
	for i from 0 below len do{
	    id[i] -> idi
	    idi n > if
		wd[i] -> wdi
		ls[i] -> lsi
		getUniversalTime lsi - -> lsi
		wn[i] -> nam
		[ nil wdi lsi idi nam | return
	    fi
	}
    }

    [ nil nil nil nil nil |
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIsleNextEntry/zzz\n" d, )
;
'doReqIsleNextEntry export

( =====================================================================	)
( - doReqIslePrevEntry -- 						)

:  doReqIslePrevEntry { [] -> [] }
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry/aaa\n" d, )
    {[                     'me       'it 'hu 'av 'id 'n  'a1 'a2 ]}
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry me=" d, me d, "\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry it=" d, it d, "\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry hu=" d, hu d, "\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry av=" d, av d, "\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry id=" d, id d, "\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry  n=" d, n  d, "\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry a1=" d, a1 d, "\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry a2=" d, a2 d, "\n" d, )

    me.isleListLock withLockDo{
	me.isleId            -> id
	me.isleIsle          -> wd
	me.isleName          -> wn
	me.isleListedSince  -> ls
	wd length 1-          -> top
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry top=" d, top d, "\n" d, )
	for i from top downto 0 do{
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry i=" d, i d, "\n" d, )
	    id[i] -> idi
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry idi=" d, idi d, "\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry n=" d, n d, "\n" d, )
	    idi n < if
		wd[i] -> wdi
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry wdi=" d, wdi d, "\n" d, )
		ls[i] -> lsi
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry lsi=" d, lsi d, "\n" d, )
		getUniversalTime lsi - -> lsi
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry lsi=" d, lsi d, "\n" d, )
		wn[i] -> nam
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry nam=" d, nam d, "\n" d, )
		[ nil wdi lsi idi nam | return
	    fi
	}
    }

    [ nil nil nil nil nil |
( .sys.muqPort d, "(365)<" d, @ d, ">doReqIslePrevEntry/zzz\n" d, )
;
'doReqIslePrevEntry export

( =====================================================================	)
( - isleNoteProa -- 							)

:   isleNoteProa { [] -> [] }
( .sys.muqPort d, "(365)<" d, @ d, ">isleNoteProa/aaa\n" d, )
    |shift -> me
( .sys.muqPort d, "(365)<" d, @ d, ">isleNoteProa me=" d, me d, "\n" d, )
    |shift -> isle
( .sys.muqPort d, "(365)<" d, @ d, ">isleNoteProa isle=" d, isle d, "\n" d, )
    |shift -> proa
( .sys.muqPort d, "(365)<" d, @ d, ">isleNoteProa proa=" d, proa d, "\n" d, )
    ]pop

    asMeDo{
	me.isleListLock withLockDo{
	    me.isleId            -> id
( .sys.muqPort d, "(365)<" d, @ d, ">isleNoteProa me.isleId=" d, me.isleId d, "\n" d, )
	    me.isleIsle          -> is
( .sys.muqPort d, "(365)<" d, @ d, ">isleNoteProa me.isleIsle=" d, me.isleIsle d, "\n" d, )
	    me.isleName          -> nm
( .sys.muqPort d, "(365)<" d, @ d, ">isleNoteProa me.isleName=" d, me.isleName d, "\n" d, )
	    me.isleProa          -> pr
( .sys.muqPort d, "(365)<" d, @ d, ">isleNoteProa me.isleProa=" d, me.isleProa d, "\n" d, )
	    me.isleListedSince  -> ls
( .sys.muqPort d, "(365)<" d, @ d, ">isleNoteProa me.isleListedSince=" d, me.isleListedSince d, "\n" d, )
	    is length 1-          -> top
	    for i from top downto 0 do{
( .sys.muqPort d, "(365)<" d, @ d, ">isleNoteProa i=" d, i d, "\n" d, )
		is[i] -> isi
( .sys.muqPort d, "(365)<" d, @ d, ">isleNoteProa isi=" d, isi d, " vs isle=" d, isle d, "\n" d, )
		isi isle = if
( .sys.muqPort d, "(365)<" d, @ d, ">isleNoteProa got a match pr[i]=" d, pr[i] d, "\n" d, )
		    pr[i] not if
( .sys.muqPort d, "(365)<" d, @ d, ">isleNoteProa updating pr[i]\n" d, )
			proa --> pr[i]
		    fi
( .sys.muqPort d, "(365)<" d, @ d, ">isleNoteProa DONE\n" d, )
		    [ | return
		fi
    }   }   }

( .sys.muqPort d, "(365)<" d, @ d, ">isleNoteProa DONE II\n" d, )
    [ |
;
'isleNoteProa export

( =====================================================================	)
( - isleFindEntry -- 							)

:   isleFindEntry { [] -> [] }
    |shift -> me
    |shift -> n
    ]pop

    asMeDo{
	me.isleListLock withLockDo{
	    me.isleId            -> id
	    me.isleIsle          -> is
	    me.isleName          -> nm
	    me.isleProa          -> pr
	    me.isleListedSince  -> ls
	    is length 1-          -> top
	    n string? if
		for i from top downto 0 do{
		    nm[i] -> nmi
		    nmi n =-ci if
			is[i] -> isi
			ls[i] -> lsi
			nm[i] -> nmi
			id[i] -> idi
			pr[i] -> pri
			getUniversalTime lsi - -> lsi
			[ nil isi lsi idi nmi pri | return
		    fi
		}
	    else
		for i from top downto 0 do{
		    is[i] -> isi
		    isi n = if
			is[i] -> isi
			ls[i] -> lsi
			nm[i] -> nmi
			id[i] -> idi
			pr[i] -> pri
			getUniversalTime lsi - -> lsi
			[ nil isi lsi idi nmi pri | return
		    fi
		}
	    fi
	}
    }

    [ nil nil nil nil nil |
;
'isleFindEntry export

( =====================================================================	)
( - doReqIsleFindEntry -- 						)

:   doReqIsleFindEntry { [] -> [] }
    {[                     'me       'it 'hu 'av 'id 'n  'a1 'a2 ]}

    [ me n | isleFindEntry
;
'doReqIsleFindEntry export

( =====================================================================	)
( - addToIsleList -- 							)

defgeneric: addToIsleList {[ $          $    $   ]} ;
defmethod:  addToIsleList { 't         't   't    } "addToIsleList" gripe ;
( See main method further below. )

( =====================================================================	)
( - normalizeIsleName -- Impose sanity on isleSupplied names		)

:   normalizeIsleName { $ $ -> $ }
    -> it
    -> nam

    ( Make sure nam is a string: )
    nam string? not if "Anonymous" -> nam fi

    ( Keep nuts from spamming us with 16K names or such: )
    nam length it.isleNameMax > if
	nam 0  it.isleNameMax substring -> nam
    fi

    ( Keep nuts from spoofing us with weird chars in names: )
    nam vals[
        |for c do{
	    c digitChar? not if
	    c alphaChar? not if
		c '-'  != if
		c '_'  != if
                   0 -> c
	    fi fi fi fi
	}
	|deleteNonchars

    ]join -> nam

    ( Make sure nam is unique: )
    nam -> n
    1   -> j
    do{ 
	it.isleName -> wn
	wn length     -> len
	for i from 0 below len do{
	    wn[i] -> wni
	    wni n = if
		++ j
		nam "#" j toString join join -> n
		loopFinish
	    fi
	}
	i len = if n return fi
    }
;
'normalizeIsleName export

( =====================================================================	)

( - suckNthIsleListEntry ---						)

:   suckNthIsleListEntry { [] -> [] ! } ;	( Forward declaration	)

:   suckNthIsleListEntry { [] -> [] }
( .sys.muqPort d, "(365)<" d, @ d, ">suckNthIsleListEntry.aaa\n" d, )

    |shift -> me		( fa	)	( isle list	)
( .sys.muqPort d, "(365)<" d, @ d, ">suckNthIsleListEntry me=" d, me d, "\n" d, )
    |shift -> taskId
( .sys.muqPort d, "(365)<" d, @ d, ">suckNthIsleListEntry taskId=" d, taskId d, "\n" d, )
    |shift -> from
( .sys.muqPort d, "(365)<" d, @ d, ">suckNthIsleListEntry from=" d, from d, "\n" d, )
    |shift -> w			( to	)	( list host	)
( .sys.muqPort d, "(365)<" d, @ d, ">suckNthIsleListEntry w=" d, w d, "\n" d, )
    |shift -> n			( a0	)	( list index	)
( .sys.muqPort d, "(365)<" d, @ d, ">suckNthIsleListEntry n=" d, n d, "\n" d, )
    |shift -> who		( a1	)	( list name	)
( .sys.muqPort d, "(365)<" d, @ d, ">suckNthIsleListEntry who=" d, who d, "\n" d, )
    |shift -> err		( r0	)
( .sys.muqPort d, "(365)<" d, @ d, ">suckNthIsleListEntry err=" d, err d, "\n" d, )
    |shift -> avi		( r1	)
( .sys.muqPort d, "(365)<" d, @ d, ">suckNthIsleListEntry avi=" d, avi d, "\n" d, )
    |shift -> lsi		( r2	)
( .sys.muqPort d, "(365)<" d, @ d, ">suckNthIsleListEntry lsi=" d, lsi d, "\n" d, )
    |shift -> idi		( r3	)
( .sys.muqPort d, "(365)<" d, @ d, ">suckNthIsleListEntry idi=" d, idi d, "\n" d, )
    |shift -> nam		( r4	)
( .sys.muqPort d, "(365)<" d, @ d, ">suckNthIsleListEntry nam=" d, nam d, "\n" d, )
    ]pop

    err if   err errcho    [ | return   fi
( .sys.muqPort d, "(365)<" d, @ d, ">suckNthIsleListEntry.bbb\n" d, )
    avi not if [ | return fi
( .sys.muqPort d, "(365)<" d, @ d, ">suckNthIsleListEntry/ccc\n" d, )

    ( Maybe add new isle to isle list: )
    [ me avi nam | addToIsleList ]pop
( .sys.muqPort d, "(365)<" d, @ d, ">suckNthIsleListEntry/ddd\n" d, )

    (   List next isleList entry also: )
    [   :op 'oldmud:REQ_PREV_LIST_ENTRY
	:to w					( Isle hosting whoList  )
	:a0 idi					( Get entry with idx < n )
	:a1 "isle"				( Name of list		 )
	:fa me
	:fn 'suckNthIsleListEntry
    |   ]request

    [ |
( .sys.muqPort d, "(365)<" d, @ d, ">suckNthIsleListEntry/zzz\n" d, )
;

( =====================================================================	)
( - suckNewIsleDry -- 							)

:   suckNewIsleDry { [] -> [] }
( .sys.muqPort d, "(365)<" d, @ d, ">suckNewIsleDry/aaa\n" d, )
    |shift -> me	( isle list	)
( .sys.muqPort d, "(365)<" d, @ d, ">suckNewIsleDry me=" d, me d, "\n" d, )
    |shift -> w
( .sys.muqPort d, "(365)<" d, @ d, ">suckNewIsleDry w=" d, w d, "\n" d, )
    ]pop

    ( Ask new isle for all the isles it knows about: )
    [   :op 'oldmud:REQ_PREV_LIST_ENTRY
	:to w					( Isle hosting isleList )
	:a0 1000000000				( Get entry with idx < n )
	:a1 "isle"				( Name of list		 )
	:fa me
	:fn 'suckNthIsleListEntry
    |   ]request

    [ |
( .sys.muqPort d, "(365)<" d, @ d, ">suckNewIsleDry/zzz\n" d, )
;

( =====================================================================	)
( - tellQuayResidentsProaAppeared -- Support fn for addExit		)

:   tellQuayResidentsProaAppeared { [] -> [] }
    |shift -> me
    |shift -> proa
    ]pop

    me.quay -> quay

    ( Scope out what's in the quay: )
    [   :op 'oldmud:REQ_NUMBER_HOLDING
	:to quay
	:am "tellProaAppeared/REQ_NUMBER_HOLDING"
	:fa [ me proa | ]vec
	:fn :: { [] -> [] }
	    |shift -> fa		( fa	)
	    |shift -> taskId
	    |shift -> from
	    |shift -> quay		( to	)
	    |shift -> err		( r0	)
	    |shift -> n			( r1	)
	    ]pop
	    err if [ | return fi
	    fa[0] -> me
	    fa[1] -> proa

	    ( Defend against being spammed by quays    )
	    ( that claim to contain a billion objects: )
	    n   me.quayJanitorMax > if
		me.quayJanitorMax -> n
	    fi

	    ( For each object in quay: )
	    for i from 0 below n do{
		[   :op 'oldmud:REQ_NTH_HOLDING
		    :to quay
		    :a0 i
		    :am "tellProaAppeared/REQ_NTH_HOLDING"
		    :fa proa
		    :fn :: { [] -> [] }
			|shift -> proa		( fa	)
			|shift -> taskId
			|shift -> from
			|shift -> quay		( to	)
			|shift -> i		( a0	)
			|shift -> err		( r0	)
			|shift -> o		( r1	)
			]pop

			err if [ | return fi

			( Tell object proa has come: )
			[   :op 'oldmud:REQ_HAS_COME
			    :to o
			    :a0 proa	( Object which is leaving )
			    :a1 quay	( Object which been left  )
			|   ]request

			[ |
		    ;
		|   ]request
	    }
	    [ |
	;
    |   ]request

    [ |
;

( =====================================================================	)
( - addExitToNewIsle -- 						)

:   addExitToNewIsle { [] -> [] }
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/aaa\n" d, )
    |shift -> me		( isle list	) 
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle me=" d, me d, "\n" d, )
    |shift -> w
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle w=" d, w d, "\n" d, )
    |shift -> isleName
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle isleName=" d, isleName d, "\n" d, )
    ]pop

    [ me isleName | ]vec -> fa

    [   :op 'oldmud:REQ_ISLE_QUAY
	:to w
	:fa fa
	:fn :: { [] -> [] }
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle: got reply to REQ_ISLE_QUAY call\n" d, )
	    |shift -> fa	( fa	)
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/reply: fa=" d, fa d, "\n" d, )
	    |shift -> taskId
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/reply: taskId=" d, taskId d, "\n" d, )
	    |shift -> from
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/reply: from=" d, from d, "\n" d, )
	    |shift -> w		( to	)
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/reply: w=" d, w d, "\n" d, )
	    |shift -> err	( Return val from doReqEnholding	)
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/reply: err=" d, err d, "\n" d, )
	    |shift -> daemon	( r0	)
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/reply: daemon=" d, daemon d, "\n" d, )
	    |shift -> name	( r1	)
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/reply: name=" d, name d, "\n" d, )
	    ]pop
	    err if err toString echo [ | return fi

	    fa[0] -> me
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/reply: me=" d, me d, "\n" d, )
	    fa[1] -> isleName
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/reply: isleName=" d, isleName d, "\n" d, )

	    me.quay -> ourQuay
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/reply: me.quay=" d, ourQuay d, "\n" d, )

	    [ isleName "a proa leaving for " isleName join   me | makeExit ]-> hereToThere
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/reply: hereToThere exit=" d, hereToThere d, "\n" d, )

	    name   --> hereToThere.exitDestination
	    daemon --> hereToThere.exitDaemon

( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/reply: doing enhold...\n" d, )
	    ourQuay     hereToThere enhold
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/reply: doing enheldBy...\n" d, )
	    hereToThere ourQuay     enheldBy

( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/reply: doing isleNoteProa...\n" d, )
	    [ me w hereToThere | isleNoteProa ]pop
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/reply: doing tellQuayResidentsProaAppeared...\n" d, )
	    [ me   hereToThere | tellQuayResidentsProaAppeared ]pop

( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/reply: done.\n" d, )
	    [ |
	;
	:am "REQ_ISLE_QUAY"
    |   ]request

    [ |
( .sys.muqPort d, "(365)<" d, @ d, ">addExitToNewIsle/zzz\n" d, )
;

( =====================================================================	)
( - addToIsleList -- 							)

defmethod:  addToIsleList { 'isleList 't   't    }
    {[                      'me       'wdx 'wnm ]}

( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList/aaa\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList me = " d, me d, "\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList wdx = " d, wdx d, "\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList wnm = " d, wnm d, "\n" d, )
    me.isleListLock withLockDo{

( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList/bbb\n" d, )
	( Ignore adds of self: )
	me wdx = if [ nil | return fi
( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList/ccc\n" d, )

	( Ignore redundant adds: )
	me.isleId            -> id
	me.isleIsle          -> wd
	me.isleName          -> wn
	me.isleProa          -> pr
	me.isleListedSince  -> ls
	wd length             -> len
	for i from 0 below len do{
	    wd[i] -> wdi
( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList comparing wd<" d, i d, ">=" d, wd[i] d, " to wdx=" d, wdx d, "\n" d, )
( wdi proxyInfo pop pop -> i2 -> i1 -> i0 -> guest )
( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList wdi proxyInfo = " d, guest d, ":" d, i0 d, "." d, i1 d, "." d, i2 d, "\n" d, )
( wdx proxyInfo pop pop -> i2 -> i1 -> i0 -> guest )
( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList wdx proxyInfo = " d, guest d, ":" d, i0 d, "." d, i1 d, "." d, i2 d, "\n" d, )
	    wdi wdx = if
( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList/ddd (redundant add ignored)\n" d, )
		[ nil | return
	    fi
	}

	( Refuse to be insanely spammed: )
	len me.isleMaxListed >= if
( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList/eee (limit-overflowing add ignored)\n" d, )
	    [ "isle list is full" | return
	fi

	( Normalize isle name: )
	wnm me normalizeIsleName -> wnm
( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList/fff\n" d, )

	( Assign new id number: )
	me.isleNext -> idi
	idi 1 +      --> me.isleNext
( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList/ggg\n" d, )

	( Add the entry: )
	getUniversalTime -> now
	idi id push
	wdx wd push
	wnm wn push
	now ls push
	nil pr push
( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList/hhh\n" d, )
    }

( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList wdx = " d, wdx d, "\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList me  = " d, me  d, "\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList me.name  = " d, me.name  d, "\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList invoking ADD_TO_LIST on wdx...\n" d, )
    ( Add ourself to remote isle's knownIsles list: )
    [   :op 'oldmud:REQ_ADD_TO_LIST
	:to wdx
	:a0 "isle"	( Name of list to modify.	)
	:a1 me		( Object to add.		)
	:a2 me.name	( Name of object to add.	)
	:am "REQ_ADD_TO_LIST"
    |   ]request
    ( Note that we do the above only when adding a new  )
    ( isle to our knownIsles list:  Doing it routinely )
    ( would produce infinite loops of mutual updates.   )

    ( Build an exit from our Quay to new isle's Quay: )
    [ me wdx wnm | addExitToNewIsle ]pop

    ( See if new isle knows of still more isles: )
    [ me wdx | suckNewIsleDry ]pop

    [ nil |
( .sys.muqPort d, "(365)<" d, @ d, ">addToIsleList/zzz\n" d, )
;
'addToIsleList export

( =====================================================================	)
( - doReqAddToIsleList -- 						)

:   doReqAddToIsleList { [] -> [] }
    |shift -> me
    |shift -> it
    |shift -> hu
    |shift -> av
    |shift -> id
    |shift -> wdx
    |shift -> wdn
    ]pop

    [ me wdx wdn | addToIsleList
;
'doReqAddToIsleList export

( =====================================================================	)
( - dropFromIsleList -- 						)

defgeneric: dropFromIsleList {[ $          $    ]} ;
defmethod:  dropFromIsleList { 't         't     } "dropFromIsleList" gripe ;
defmethod:  dropFromIsleList { 'isleList 't     }
    {[                            'me        'isle ]}

    asMeDo{
	me.isleListLock withLockDo{

	    ( Find entry: )
	    me.isleId            -> id
	    me.isleIsle          -> is
	    me.isleName          -> wn
	    me.isleProa          -> pr
	    me.isleListedSince  -> ls
	    is length             -> len
	    0 -> i
	    do{ i len < while
		is[i] -> isi
		isi isle = if
		    id i deleteBth
		    is i deleteBth
		    wn i deleteBth
		    ls i deleteBth
		    pr i deleteBth
		    -- len
		else
		    ++ i
		fi
    }	}   }

    asMeDo{
	me.isleListLock withLockDo{

	    ( Find entry: )
	    me.isleId            -> id
	    me.isleIsle          -> is
	    me.isleName          -> wn
	    me.isleProa          -> pr
	    me.isleListedSince  -> ls
	    is length             -> len
	    0 -> i
	    do{ i len < while
		is[i] -> isi
		id[i] -> idi
		wn[i] -> wni
		pr[i] -> pri
		ls[i] -> lsi
		++ i
    }	}   }

    [ |
;
'dropFromIsleList export

( =====================================================================	)

( - updateNthIsleListEntry --- support fn for updateKnownIsles		)

:   updateNthIsleListEntry { [] -> [] ! } ;	( Forward declaration	)

:   updateNthIsleListEntry { [] -> [] }
( .sys.muqPort d, "(365)<" d, @ d, ">updateNthIsleIsleListEntry/aaa...\n" d, )
    |shift -> me		( fa	)	( isle list	)
( .sys.muqPort d, "(365)<" d, @ d, ">updateNthIsleIsleListEntry me=" d, me d, "\n" d, )
    |shift -> taskId
( .sys.muqPort d, "(365)<" d, @ d, ">updateNthIsleIsleListEntry taskId=" d, taskId d, "\n" d, )
    |shift -> from
( .sys.muqPort d, "(365)<" d, @ d, ">updateNthIsleIsleListEntry from=" d, from d, "\n" d, )
    |shift -> me		( to	)	( list host	)
( .sys.muqPort d, "(365)<" d, @ d, ">updateNthIsleIsleListEntry me=" d, me d, "\n" d, )
    |shift -> n			( a0	)	( list index	)
( .sys.muqPort d, "(365)<" d, @ d, ">updateNthIsleIsleListEntry n=" d, n d, "\n" d, )
    |shift -> who		( a1	)	( list name	)
( .sys.muqPort d, "(365)<" d, @ d, ">updateNthIsleIsleListEntry who=" d, who d, "\n" d, )
    |shift -> err		( r0	)
( .sys.muqPort d, "(365)<" d, @ d, ">updateNthIsleIsleListEntry err=" d, err d, "\n" d, )
    |shift -> isle		( r1	)
( .sys.muqPort d, "(365)<" d, @ d, ">updateNthIsleIsleListEntry isle=" d, isle d, "\n" d, )
    |shift -> lsi		( r2	)
( .sys.muqPort d, "(365)<" d, @ d, ">updateNthIsleIsleListEntry lsi=" d, lsi d, "\n" d, )
    |shift -> idi		( r3	)
( .sys.muqPort d, "(365)<" d, @ d, ">updateNthIsleIsleListEntry idi=" d, idi d, "\n" d, )
    |shift -> nam		( r4	)
( .sys.muqPort d, "(365)<" d, @ d, ">updateNthIsleIsleListEntry nam=" d, nam d, "\n" d, )
    ]pop

    err if   err errcho    [ | return   fi
    isle not if [ | return fi

    ( Maybe add new isle to isle list: )
    [ me isle nam | addToIsleList ]pop

    (   List next isleList entry also: )
    [   :op 'oldmud:REQ_PREV_LIST_ENTRY
	:to me					( Isle hosting whoList  )
	:a0 idi					( Get entry with idx < n )
	:a1 "isle"				( Name of list		 )
	:fa me
	:fn 'updateNthIsleListEntry
    |   ]request

    [ |
( .sys.muqPort d, "(365)<" d, @ d, ">updateNthIsleIsleListEntry/zzz...\n" d, )
;

( =====================================================================	)
( - updateKnownIsles -- support fn for wakeLiveDaemon method		)

:   updateKnownIsles { [] -> [] }
( .sys.muqPort d, "(365)<" d, @ d, ">updateKnownIsle/aaa...\n" d, )
    |shift -> me	( isle list	)
    ]pop

    ( Purpose of this function is to tell all isles we knew of when	)
    ( we went down that we are back, and to find all isles which they	)
    ( know of.  This should mean that after our first run, we don't	)
    ( depend on any of the well-known servers being up, just at least	)
    ( one server that was up when we went down.				)

    ( Ask self for all known isles: )
    [   :op 'oldmud:REQ_PREV_LIST_ENTRY
	:to me					( Isle hosting isleList )
	:a0 1000000000				( Get entry with idx < n )
	:a1 "isle"				( Name of list		 )
	:fa me
	:fn 'updateNthIsleListEntry
    |   ]request

    [ |
( .sys.muqPort d, "(365)<" d, @ d, ">updateKnownIsles/zzz...\n" d, )
;

( =====================================================================	)
( - updateIslesList -- support fn for wakeLiveDaemon method		)

:   updateIslesList { [] -> [] }
    |shift -> me	( isle list	)
    ]pop

    ( Check in with well-known Muq servers. )

( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList called... <=================\n" d, )
    ( Over all well-known Muqservers: )
    muqnetVars:_ip0 length -> len
    for i from 0 below len do{

	muqnetVars:_ip0[i]  -> ip0
	muqnetVars:_ip1[i]  -> ip1
	muqnetVars:_ip2[i]  -> ip2
	muqnetVars:_ip3[i]  -> ip3

	muqnetVars:_port[i] -> port
( .sys.muqPort d, "(365)<" d, @ d, ">oldisle-list: updateIslesList processing well-known isle " d, )
( ip0 d, "." d, )
( ip1 d, "." d, )
( ip2 d, "." d, )
( ip3 d, ":" d, )
( port d, "\n" d, )

	( Ask well-known server for its muqnet identity: )
( .sys.muqPort d, "(365)<" d, @ d, ">oldisle-list: now invoking requestGetMuqnetUser\n" d, )
        [   :ip0  ip0
            :ip1  ip1
            :ip2  ip2
            :ip3  ip3
            :port port
            :fa me
            :fn :: { [] -> [] }
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList: got reply back from requestGetMuqnetUser!\n" d, )
		|shift -> me
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList GetMuqnetUser reply: me = " d, me d, "\n" d, )
		|shift -> taskId
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList GetMuqnetUser reply: taskId = " d, taskId d, "\n" d, )
		|shift -> muqnetuser
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList GetMuqnetUser reply: from   = " d, GetMuqnetUser d, "\n" d, )
		|shift -> ip0
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList GetMuqnetUser reply: ip0 = " d, ip0 d, "\n" d, )
		|shift -> ip1
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList GetMuqnetUser reply: ip1 = " d, ip1 d, "\n" d, )
		|shift -> ip2
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList GetMuqnetUser reply: ip2 = " d, ip2 d, "\n" d, )
		|shift -> ip3
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList GetMuqnetUser reply: ip3 = " d, ip3 d, "\n" d, )
		|shift -> port
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList GetMuqnetUser reply: port = " d, port d, "\n" d, )
( |for val iii do{ .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList GetMuqnetUser reply: " d, iii d, "-th val: " d, val d, "\n" d, } )
		]pop

		( Ask well-known server how many isles it contains: )
		[   :to muqnetuser
		    :fa me
		    :fn :: { [] -> [] }
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList: got reply back from requestMuqnetIsles!\n" d, )
( |for val iii do{ .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList reply: " d, iii d, "-th val: " d, val d, "\n" d, } )
			|shift -> me
			|shift -> taskId
			|shift -> muqnetuser ( from )
			:isles nil |gep -> isles
			]pop
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList: requestMuqnetIsles isles = " d, isles d, "\n" d, )

			( Over all isles on well-known server: )
( BUGGO, should put a configurable maximum here on 'isles', to prevent spamming us via isles==10^100 )
			for j from 0 below isles do{
.sys.muqPort d, "(365)<" d, @ d, ">updateIslesList: requestMuqnetIsles querying isle # " d, j d, "\n" d,
			    [   :to    muqnetuser
				:index j
				:fa    me
				:fn :: { [] -> [] }
( "\n" d, "\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">===============================================================================\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">===============================================================================\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">===============================================================================\n" d, )
.sys.muqPort d, "(365)<" d, @ d, ">updateIslesList: got reply back from requestMuqnetISLE!\n" d,
( .sys.muqPort d, "(365)<" d, @ d, ">===============================================================================\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">===============================================================================\n" d, )
( .sys.muqPort d, "(365)<" d, @ d, ">===============================================================================\n" d, )
( "\n" d, "\n" d, )
( |for val iii do{ .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList ISLE reply: " d, iii d, "-th val: " d, val d, "\n" d, } )
				    |shift -> me
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList ISLE reply: me = " d, me d, "\n" d, )
				    |shift -> taskId
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList ISLE reply: taskId = " d, taskId d, "\n" d, )
				    |shift -> muqnetuser  ( from )
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList ISLE reply: from = " d, muqnetuser d, "\n" d, )
				    |shift -> index
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList ISLE reply: index = " d, index d, "\n" d, )
				    :isle nil |gep -> isle
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList ISLE reply: isle = " d, isle d, "\n" d, )
				    :name nil |gep -> isleName
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList ISLE reply: isleName = " d, isleName d, "\n" d, )
				    ]pop

				    ( Add remote isle to local knownIsles list: )
				    [ me isle isleName | addToIsleList ]pop

				    [ |
				;
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList: calling requestMuqnetISLE\n" d, )
			    |   task:]requestMuqnetIsle
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList: back from requestMuqnetISLE\n" d, )
			}
			[ |
		    ;
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList: calling requestMuqnetIsles\n" d, )
		|   task:]requestMuqnetIsles	
( .sys.muqPort d, "(365)<" d, @ d, ">updateIslesList: back from requestMuqnetIsles\n" d, )

		[ |
	    ;
	|   task:]requestGetMuqnetUser
( .sys.muqPort d, "(365)<" d, @ d, ">oldisle-list: done invoking requestGetMuqnetUser\n" d, )
    }

    ( Check in with isles remembered from last run: )
    [ me | updateKnownIsles ]pop

    [ |
( .sys.muqPort d, "(365)<" d, @ d, ">oldisle-list/zzz\n" d, )
;

( =====================================================================	)
( - tellQuayResidentsProaVanished -- Support fn for noteIsleSank	)

:   tellQuayResidentsProaVanished { [] -> [] }
    |shift -> me
    |shift -> proa
    ]pop

    me.quay -> quay

    ( Scope out what's in the quay: )
    [   :op 'oldmud:REQ_NUMBER_HOLDING
	:to quay
	:am "tellProaVanished/REQ_NUMBER_HOLDING"
	:fa [ me proa | ]vec
	:fn :: { [] -> [] }
	    |shift -> fa		( fa	)
	    |shift -> taskId
	    |shift -> from
	    |shift -> quay		( to	)
	    |shift -> err		( r0	)
	    |shift -> n			( r1	)
	    ]pop
	    err if [ | return fi
	    fa[0] -> me
	    fa[1] -> proa

	    ( Defend against being spammed by quays    )
	    ( that claim to contain a billion objects: )
	    n   me.quayJanitorMax > if
		me.quayJanitorMax -> n
	    fi

	    ( For each object in quay: )
	    for i from 0 below n do{
		[   :op 'oldmud:REQ_NTH_HOLDING
		    :to quay
		    :a0 i
		    :am "tellProaVanished/REQ_NTH_HOLDING"
		    :fa proa
		    :fn :: { [] -> [] }
			|shift -> proa		( fa	)
			|shift -> taskId
			|shift -> from
			|shift -> quay		( to	)
			|shift -> i		( a0	)
			|shift -> err		( r0	)
			|shift -> o		( r1	)
			]pop

			err if [ | return fi

			( Tell object proa has left: )
			[   :op 'oldmud:REQ_HAS_LEFT
			    :to o
			    :a0 proa	( Object which is leaving )
			    :a1 quay	( Object which been left  )
			|   ]request

			[ |
		    ;
		|   ]request
	    }
	    [ |
	;
    |   ]request

    [ |
;

( =====================================================================	)
( - noteIsleSank -- support fn for quayJanitorTask			)

:   noteIsleSank { [] -> [] }
    |shift -> me	( isle list	)
    |shift -> isle
    ]pop

    me.quay -> ourQuay

    ( Find proa associated with that isle: )
    [ me isle | isleFindEntry
        5 |shiftpN
        |shift -> proa
    ]pop

    ( If proa exists, remove it from our )
    ( Quay and notify anyone on Quay:    )
    proa if
	ourQuay proa deholding pop
	proa ourQuay deheldBy pop
	[ me proa | tellQuayResidentsProaVanished ]pop
    fi

    ( Drop isle from our list of known isles: )
    [ me isle | dropFromIsleList ]pop

    [ |
;

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

