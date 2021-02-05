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

( - 475-W-oldmsh-who.muf -- Do player '@who'.				)
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

(  -------------------------------------------------------------------  )
(									)
(	For Mike Jittlov: A wiz of a wiz if ever there was!		)
(									)
(  -------------------------------------------------------------------  )

(  -------------------------------------------------------------------  )
( Author:       Jeff Prothero						)
( Created:      97Oct29							)
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
(  ------------------------------------------------------------------- 	)

( =====================================================================	)
( - Package 'msh', exported symbols --					)

"oldmsh" inPackage

( =====================================================================	)
( - Overview --								)


( =====================================================================	)

( - Classes ---								)

( =====================================================================	)
( - cmdWho ---								)

defclass: cmdWho
    :export t
    :isA 'mshCommand
;

( =====================================================================	)

( - Methods ---								)

( =====================================================================	)

( - cmdNames ---							)

( Return the list of names by which the user can invoke command.	)
( Full/normal names should be first, nicknames and abbrevs later.	)
( One name is sufficient for most commands.				)

defmethod:  cmdNames { 'cmdWho }
    {[                  'it     ]}

    [ "@who" |
;


( =====================================================================	)
( - cmdHelpCategory ---							)

( Following only needed if we change the return value to other than ""	)

( defmethod:  cmdHelpCategory { 'cmdWho }	)
(    {[                         'it    ]}	)
(    [ "" |                              	)
( ;                                      	)

( =====================================================================	)

( - cmdHelp1 ---							)

( Return a short (less than one line) description of command.		)

defmethod:  cmdHelp1 { 'cmdWho }
    {[                   'it     ]}

    [ "List who is active." |
;


( =====================================================================	)

( - cmdHelpN ---							)

( Return a multi-line description of command.  Think of a manpage.	)

defmethod:  cmdHelpN { 'cmdWho }
    {[                   'it     ]}

    [
"Lists active avatars, along with their doing fields and idle times."
    |
;

( =====================================================================	)

( - millisecsToDdhhmmss ---						)

:   millisecsToDdhhmmss { $ -> $ }
    -> i
    i 1000 / -> i

    i 60 %   -> ss
    i 60 /   -> i
    i 0 = if ss toString return fi

    i 60 %   -> mm
    i 60 /   -> i
    i 0 = if [ "%d:%02d" mm ss | ]print return fi

    i 24 %   -> hh
    i 24 /   -> i
    i 0 = if [ "%d:%02d:%02d" hh mm ss | ]print return fi

    [ "%d:%02d:%02d:%02d" i hh mm ss | ]print
;

( =====================================================================	)

( - showNthWhoListEntry ---						)

:   showNthWhoListEntry { [] -> [] ! } ;	( Forward declaration	)

:   showNthWhoListEntry { [] -> [] }
    |shift -> v			( fa	)
    |shift -> taskId
    |shift -> from
    |shift -> w			( to	)
    |shift -> n			( a0	)
    |shift -> who		( a1	)
    |shift -> err		( r0	)
    |shift -> avi		( r1	)
    |shift -> lsi		( r2	)
    |shift -> idi		( r3	)
    |shift -> nam		( r4	)
    ]pop

    v[0] -> av
    v[1] -> worldName

    err if   err errcho    [ | return   fi
    avi not if [ | return fi

    nam av.thisRoomCache oldmud:normalizeName -> nam
    (   List next @whoList entry also: )
    [   :op 'oldmud:REQ_PREV_LIST_ENTRY
	:to w					( Isle hosting whoList  )
	:a0 idi					( Get entry with idx > n )
	:a1 "who"				( Name of list		 )
	:fa v
	:fn 'showNthWhoListEntry
    |   ]request

    ( If avatar is on another world, qualify its name )
    ( with its worldname, otherwise list its rank:    )
    worldName if
	[ nam "." worldName | ]join -> nam
    else 
	avi$s.owner -> owner
	owner user? if
	    owner$s.rank -> rank
	    [ "%s #%d" nam rank | ]print -> nam
    fi  fi

    ( Ask avatar for its 'doing' info: )
    [   :op 'oldmud:REQ_WHO_USER_INFO
	:to avi			( Avatar )
	:fa [ "%12s %-20s" lsi millisecsToDdhhmmss nam | ]print
	:fn :: { [] -> [] }
	    |shift -> str		( fa	)
	    |shift -> taskId
	    |shift -> from
	    |shift -> avi		( to	)
	    |shift -> err		( r0	)
	    |shift -> idle		( r1	)
	    |shift -> doing		( r2	)
	    ]pop

	    err if   err errcho    [ | return   fi

	    idle integer? not if 0 -> idle fi

	    doing @.task.taskState.thisRoomCache oldmud:normalizeDoing -> doing

	    [ "%11s%s %s" idle millisecsToDdhhmmss str doing | ]print echo

	    [ |
	;
    |   ]request

    [ |
;

( =====================================================================	)

( - showNthIsleListEntry ---					)

:   showNthIsleListEntry { [] -> [] ! } ;	( Forward declaration	)

:   showNthIsleListEntry { [] -> [] }

    |shift -> av		( fa	)
    |shift -> taskId
    |shift -> from
    |shift -> w			( to	)
    |shift -> n			( a0	)
    |shift -> who		( a1	)
    |shift -> err		( r0	)
    |shift -> avi		( r1	)
    |shift -> lsi		( r2	)
    |shift -> idi		( r3	)
    |shift -> nam		( r4	)
    ]pop

    err if   err errcho    [ | return   fi
    avi not if [ | return fi

    ( List everyone publicly online on foriegn isle: )
    [   :op 'oldmud:REQ_PREV_LIST_ENTRY
	:to avi					( Islehosting whoList   )
	:a0 1000000000				( Get entry with idx < n )
	:a1 "who"				( Name of list		 )
	:fa [ av nam | ]vec
	:fn 'showNthWhoListEntry
    |   ]request

    (   List next isleList entry also: )
    [   :op 'oldmud:REQ_PREV_LIST_ENTRY
	:to av.homeIsle			( Isle hosting whoList  )
	:a0 idi					( Get entry with idx < n )
	:a1 "isle"				( Name of list		 )
	:fa av
	:fn 'showNthIsleListEntry
    |   ]request

    [ |
;

( =====================================================================	)

( - cmdDo ---								)

( Actually execute command.						)

defmethod: cmdDo { 'cmdWho 't  't     }
        |shift -> it
        |shift -> av
        |shift -> cmdName

	|intChar

    ]join -> pattern

    ( Start with an explanatory header: )
    "Secs idle   Secs online Name .Isle           Doing" echo
    "----------- ----------- -------------------- ----------------" echo

    ( List everyone publicly online on home isle: )
    [   :op 'oldmud:REQ_PREV_LIST_ENTRY
	:to av.homeIsle			( Isle hosting whoList  )
	:a0 1000000000				( Get entry with idx < n )
	:a1 "who"				( Name of list		 )
	:fa [ av nil | ]vec
	:fn 'showNthWhoListEntry
    |   ]request



    ( List everyone publicly online on other isles: )
    [   :op 'oldmud:REQ_PREV_LIST_ENTRY
	:to av.homeIsle			( Isle hosting isleList )
	:a0 1000000000				( Get entry with idx < n )
	:a1 "isle"				( Name of list		 )
	:fa av
	:fn 'showNthIsleListEntry
    |   ]request

    [ |
;


( =====================================================================	)

( - Vanilla functions ---						)

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example
