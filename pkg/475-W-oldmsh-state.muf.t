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

( - 475-W-oldmsh-state.muf -- Command for mudUser shell package.	)
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
( Created:      97Jul20, from 475-W-oldmsh-muf.t			)
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
( - cmdState ---							)

defclass: cmdState
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

defmethod:  cmdNames { 'cmdState }
    {[                  'it       ]}

    [ "@state" |
;


( =====================================================================	)
( - cmdHelpCategory ---							)

( Following only needed if we change the return value to other than ""	)

( defmethod:  cmdHelpCategory { 'cmdState }	)
(    {[                         'it      ]}	)
(    [ "" |                              	)
( ;                                      	)

( =====================================================================	)

( - cmdHelp1 ---							)

( Return a short (less than one line) description of command.		)

defmethod:  cmdHelp1 { 'cmdState }
    {[                   'it       ]}

    [ "Print out various state variables in shell and daemon." |
;


( =====================================================================	)

( - cmdHelpN ---							)

( Return a multi-line description of command.  Think of a manpage.	)

defmethod:  cmdHelpN { 'cmdState }
    {[                   'it       ]}

    [
"Print out various indications of the state of your shell
and daemon.  These will probably grow more elaborate over time..."
    |
;

( =====================================================================	)

( - cmdDo ---								)

( Actually execute command.						)

defmethod: cmdDo { 'cmdState 't  't     }
    {[              'it        'av 'name ]}

    av.shellState.opNames -> opn
    av.shellState.opIt    -> opi

    "\n" ,
    "-----------< State Summary >-----------\n" ,
    "| av = " av toString join "\n" join ,
    "| av.shellState = " av.shellState toString join "\n" join ,
    "| av.userIo = " av.userIo toString join "\n" join ,
    "| av.io = " av.io toString join "\n" join ,
    "| av.pubId = " av.pubId toString join "\n" join ,
    "| av.pubId length = " av.pubId length toString join "\n" join ,
    "| task.taskJob = " @.task.taskJob toString join "\n" join ,
    "| task.taskState = " @.task.taskState toString join "\n" join ,
    "| task.taskNextId = " @.task.taskNextId toString join "\n" join ,
    "| task.taskId = " @.task.taskId toString join "\n" join ,
    "| task.taskId length = " @.task.taskId length toString join "\n" join ,
    @.task -> ta
    ta.taskId length -> len
    for i from 0 below len do{
	"|\n" ,
	"| task[" i toString join "]:\n" join ,
	"| ta.taskId = " ta.taskId[i] toString join "\n" join ,
	"| ta.taskWhen = " ta.taskWhen[i] toString join "\n" join ,
	"| ta.taskFn = " ta.taskFn[i] toString join "\n" join ,
	"| ta.taskIofn = " ta.taskIofn[i] toString join "\n" join ,
	"| ta.taskWhy = " ta.taskWhy[i] toString join "\n" join ,
	"| ta.taskArgno = " ta.taskArgno[i] toString join "\n" join ,
	"| ta.taskTargs = " ta.taskTargs[i] toString join "\n" join ,
	"| ta.taskArg0 = " ta.taskArg0[i] toString join "\n" join ,
	"| ta.taskArg1 = " ta.taskArg1[i] toString join "\n" join ,
	"| ta.taskArg2 = " ta.taskArg2[i] toString join "\n" join ,
	"| ta.taskArg3 = " ta.taskArg3[i] toString join "\n" join ,
	"| ta.taskArg4 = " ta.taskArg4[i] toString join "\n" join ,
	"| ta.taskArg5 = " ta.taskArg5[i] toString join "\n" join ,
	"| ta.taskArg6 = " ta.taskArg6[i] toString join "\n" join ,
	"| ta.taskArg7 = " ta.taskArg7[i] toString join "\n" join ,
	"| ta.taskArg8 = " ta.taskArg8[i] toString join "\n" join ,
	"| ta.taskArg9 = " ta.taskArg9[i] toString join "\n" join ,
	"| ta.taskArga = " ta.taskArga[i] toString join "\n" join ,
	"| ta.taskArgb = " ta.taskArgb[i] toString join "\n" join ,
	"| ta.taskArgc = " ta.taskArgc[i] toString join "\n" join ,
    }				

    "---------------------------------------\n" ,

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
