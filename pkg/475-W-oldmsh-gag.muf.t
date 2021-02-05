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

( - 475-W-oldmsh-gag.muf -- Do player '@gag'.				)
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
( Created:      98Sep11							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1999, by Jeff Prothero.				)
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
( - Quip --								)

( In a world without walls, who needs Windows or Gates?			)


( =====================================================================	)
( - Overview --								)


( =====================================================================	)

( - Classes ---								)

( =====================================================================	)
( - cmdGag ---								)

defclass: cmdGag
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

defmethod:  cmdNames { 'cmdGag }
    {[                  'it       ]}

    [ "@gag" |
;


( =====================================================================	)
( - cmdHelpCategory ---							)

( Following only needed if we change the return value to other than ""	)

( defmethod:  cmdHelpCategory { 'cmdGag }	)
(    {[                         'it    ]}	)
(    [ "" |                              	)
( ;                                      	)

( =====================================================================	)

( - cmdHelp1 ---							)

( Return a short (less than one line) description of command.		)

defmethod:  cmdHelp1 { 'cmdGag }
    {[                 'it    ]}

    [ "Set people you wish to ignore." |
;


( =====================================================================	)

( - cmdHelpN ---							)

( Return a multi-line description of command.  Think of a manpage.	)

defmethod:  cmdHelpN { 'cmdGag }
    {[                 'it    ]}

    [
"Set/display list of people to ignore: @gag or @gag <name>=<on|off>
Gagged people won't be able to enter your rooms or contact you."
    |
;

( =====================================================================	)

( - cmdDo ---								)

( Actually execute command.						)

defmethod: cmdDo { 'cmdGag 't  't     }
        |shift -> it
        |shift -> av
        |shift -> cmdName
	'=' charInt |position -> pos
	pos not if
            |length 0 = if
		me$s.gagged -> gagged
		gagged hash? if
		    0 -> count
		    gagged foreach key val do{
			++ count
		        [ "* @gag: %s is gagged. *\n" val | ]print echo
		    }
		    [ "* @gag: %d people gagged. *\n" count | ]print echo
		fi
		]pop [ | return
	    fi
	    "Syntax is '@gag or @gag <somename>=<on|off>" errcho ]pop [ | return
        fi
	0 pos |extract[ ]join -> globalName
	|shiftp
    ]join -> text

    text case{
    on: "on"
    on: "true"   "on"  -> text
    on: "t"      "on"  -> text
    on: "yes"    "on"  -> text
    on: "off"
    on: "no"     "off" -> text
    on: "nil"    "off" -> text
    else:
	"Syntax is '@gag or @gag <somename>=<on|off>" errcho [ | return
    }

    ( Convert avatar name into avatar pointer: )
    [   :isle av.homeIsle
        :name globalName
        :fa [ av text globalName | ]vec
	:fn ::
	    |shift -> fa
	    |shift -> err
	    |shift -> who	( Avatar to send page to )
	    ]pop
	    fa[0] -> av
	    fa[1] -> text
	    fa[2] -> globalName

	    ( Check for attempt to @gag non-existent avatar: )
	    err   who not   or if
		"No \"" globalName join "\" found" join errcho
		[ | return
	    fi

	    ( Turn avatar pointer into User/Guest pointer: )
	    who remote? if
		who proxyInfo
		-> yy
		-> xx
		-> i2
		-> i1
		-> i0
		-> guest
	    else
		who$s.owner -> guest
	    fi

	    ( Find/create our gag table: )
	    me$s.gagged -> gagged
	    gagged hash? not if
		makeHash   -> gagged
		gagged    --> me$s.gagged
	    fi
	    
	    text case{
            on: "on"   globalName --> gagged[guest]
		[ "* @gag: %s is now gagged. *\n"   globalName | ]print echo
	    on: "off"  delete:        gagged[guest]
		[ "* @gag: %s is now ungagged. *\n" globalName | ]print echo
	    }

	    [ |
	;
    |   oldmud:globalNameToAvatar ]pop

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
