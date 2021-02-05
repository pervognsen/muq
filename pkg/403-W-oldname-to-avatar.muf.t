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

( - 403-W-oldname-to-avatar.muf -- Find avatar given name.		)
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
( Created:      97Nov22							)
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
( - globalNameToAvatar -- Locate avatar given global name for it	)

:   globalNameToAvatar { [] -> [] }
    :fn      nil |gep -> fn
    :fa      nil |gep -> fa
    :isle    nil |gep -> isle
    :name    nil |gep -> globalName
    ]pop

    ( Sanity checks: )
    isle isle? not if
        [ "Global-name-to-avatar: 1st arg must be an isle" nil | return
    fi 
    globalName string? not if
        [ "Global-name-to-avatar: 2nd arg must be a string" nil | return
    fi 
   
    globalName "." findSubstring? -> loc pop if
	globalName       0        loc                  substring -> avatarName
	globalName       loc 1+   globalName length   substring -> isleName
    else
        globalName -> avatarName
        nil         -> isleName
    fi

    ( If name is local, fish out of local list: )
    isleName not if
	[ isle avatarName | whoFindEntry
	    |shift -> err
	    |shift -> avi
	    |shift -> lsi
	    |shift -> idi
	    |shift -> nmi
	]pop
	[ fa err avi | fn call{ [] -> [] } ]pop
	[ | return
    else

	( Find named isle: )
	[ isle isleName | isleFindEntry
	    |shift -> err
	    |shift -> isi
	    |shift -> lsi
	    |shift -> idi
	    |shift -> nmi
	]pop
	err    isi not   or if
	    [ fa "No such world" nil | fn call{ [] -> [] } ]pop
	    [ | return
	else
	    ( Find named avatar on given isle: )
	    [   :op 'oldmud:REQ_FIND_LIST_ENTRY
		:to isi			( Isle hosting nativeList	)
		:a0 avatarName		( Name to search list for	)
		:a1 "native"		( Name of list to search	)
		:fa [ fn fa | ]vec
		:fn :: { [] -> [] }
		    |shift -> fa2		( fa	)
		    |shift -> taskId
		    |shift -> from
		    |shift -> isi		( to	)
		    |shift -> avatarName	( a0	)
		    |shift -> listName		( a1	)
		    |shift -> err
		    |shift -> avi
		    |shift -> lsi
		    |shift -> idi
		    |shift -> nmi
		    ]pop		    
		    fa2[0] -> fn
		    fa2[1] -> fa

		    [ fa nil avi | fn call{ [] -> [] } ]pop 

		    [ | return
		;
	    |   ]request

	    [ | return
    fi  fi
;
'globalNameToAvatar export

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

