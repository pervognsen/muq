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

( - 280-vt100.muf -- Basic ANSI terminal escape sequences.		)
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
( Author:       Jeff Prothero						)
( Created:      95Jul04							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1996, by Jeff Prothero.				)
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
( - Epigram.								)

( This space available						 	)

( =====================================================================	)
( -- Package 'vt100', exported symbols --				)

"ANSI" rootValidateDbfile pop
[ "vt100" .db["ANSI"] | ]inPackage
( "vt100" inPackage )

( =====================================================================	)
( -- enableEscapes --							)

: enableEscapes
 t --> @.jobSet.session.socket.allowNonprintingOutput
;
'enableEscapes export

( =====================================================================	)
( -- disableEscapes --							)

: disableEscapes
 nil --> @.jobSet.session.socket.allowNonprintingOutput
;
'disableEscapes export

( =====================================================================	)
( -- homeCursor --							)

: homeCursor     "\e[H" ,    ;
'homeCursor export

( =====================================================================	)
( -- clearScreen --							)

: clearScreen     "\e[2J" ,    ;
'clearScreen export

( =====================================================================	)
( -- clearToScreenStart --						)

: clearToScreenStart    "\e[1J" ,    ;
'clearToScreenStart export

( =====================================================================	)
( -- clearToScreenEnd --						)

: clearToScreenEnd    "\e[0J" ,    ;
'clearToScreenEnd export

( =====================================================================	)
( -- clearLine --							)

: clearLine    "\e[2K" ,    ;
'clearLine export

( =====================================================================	)
( -- clearToLineStart --						)

: clearToLineStart    "\e[1K" ,    ;
'clearToLineStart export

( =====================================================================	)
( -- clearToLineEnd --						)

: clearToLineEnd    "\e[0K" ,    ;
'clearToLineEnd export

( =====================================================================	)
( -- reverseIndex --							)

: reverseIndex    "\eM" ,    ;
'reverseIndex export

( =====================================================================	)
( -- enterInsertCharMode --						)

: enterInsertCharMode    "\e[4h" ,    ;
'enterInsertCharMode export

( =====================================================================	)
( -- exitInsertCharMode --						)

: exitInsertCharMode    "\e[4l" ,    ;
'exitInsertCharMode export

( =====================================================================	)
( -- enterReverseVideoMode --					)

: enterReverseVideoMode    "\e[7m" ,    ;
'enterReverseVideoMode export

( =====================================================================	)
( -- exitReverseVideoMode --						)

: exitReverseVideoMode    "\e[0m" ,    ;
'exitReverseVideoMode export

( =====================================================================	)
( -- moveNRight --							)

: moveNRight -> n [ "\e[%dC" n | ]print ,    ;
'moveNRight export

( =====================================================================	)
( -- moveNLeft --							)

: moveNLeft -> n [ "\e[%dD" n | ]print ,    ;
'moveNLeft export

( =====================================================================	)
( -- moveNUp --							)

: moveNUp -> n [ "\e[%dA" n | ]print ,    ;
'moveNUp export

( =====================================================================	)
( -- moveNDown --							)

: moveNDown -> n [ "\e[%dB" n | ]print ,    ;
'moveNDown export

( =====================================================================	)
( -- moveRowCol --							)

: moveRowCol -> col -> row [ "\e[%d;%dH" row col | ]print ,    ;
'moveRowCol export

( =====================================================================	)
( -- insertNLines --							)

: insertNLines -> n [ "\e[%dL" n | ]print ,    ;
'insertNLines export

( =====================================================================	)
( -- deleteNLines --							)

: deleteNLines -> n [ "\e[%dM" n | ]print ,    ;
'deleteNLines export

( =====================================================================	)
( -- deleteNChars --							)

: deleteNChars -> n [ "\e[%dP" n | ]print ,    ;
'deleteNChars export



( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example
