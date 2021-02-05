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

( - 420-W-badweight.muf -- Mixin for weights varying contextually.	)
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
( Created:      97Dec10							)
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
( - Package 'oldmud', exported symbols --				)

"oldmud" inPackage

( =====================================================================	)

( - Motivation -							)

( How do we introduce long-range order into procedural building		)
( while keeping the code well-factored?					)
(									)
( For example, how do we arrange for deserts to contain mostly		)
( cacti and jungles mostly trees and vines, while maintaining		)
( the ability to cleanly add a new type of cactus or vine		)
( without having to go back and hack the functions generating		)
( deserts and jungles?							)
(									)
( The solution adopted here consists of:				)
(									)
( 1)  Defining 'contexts' consisting of propertyValue pairs such as:	)
(       :arid   0.9							)
(       :hot    0.7							)
(	:season 0.4							)
(     which are passed down from high-level construction functions to	)
(     lower-level construction functions:  This provides a way of	)
(     specifying that in general an entire area is arid and should	)
(     have plant life &tc appropriate to an arid climate -- while	)
(     allowing local exceptions, such as oases, which may reset the	)
(     context's :arid value to 0.5 before doing plant generation, and	)
(     get date trees instead of cacti, say.				)
(									)
( 2)  Creating categories of objects such as 'bigPlant'.		)
(     Higher-level areaCreation functions can invoke them		)
(     as black boxes:  "Gimme a big plant. Gimme some furniture."	)
(     Builders can add new classes of objects to these categories	)
(     without having to go hack the code using them.			)
(     See badSet for the implementation of these categories.		)
(									)
( 3)  Equipping the objects in these categories with weights which	)
(     are a function of context:  The weight for cacti may be high	)
(     when :arid is high, say, while the weight for vines may be the	)
(     highest when :arid is low.  The objectCreation blackBox for	)
(     a category can then choose objects with probability proportional	)
(     to their weight in the particular context.  The designer of a	)
(     new type of object can thus specify an appropriate distribution	)
(     for it merely by picking an appropriate category to place it in,	)
(     and then writing an appropriate weight function.			)


( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - badWeight -- Class which computes its weight from context.		)

defclass: badWeight
    :export t
;

( =====================================================================	)

( - Generics -								)

( =====================================================================	)
( - weight -- Compute weight from context.				)

defgeneric: weight {[ $           $       ]} ;
defmethod:  weight { 't          't        } ]pop [ 0.5 | ; 
defmethod:  weight { 'badWeight 't        }
    {[               'me         'context ]}

    ( The 'context' is a vector of keyValue pairs;	)
    ( Typical code to access values in the context:	)
    (							)
    (     context vals[					)
    (	      :arid 0.5 |ged -> arid			)
    (	      :hot  0.5 |ged -> hot			)
    (     ]pop						)
    (							)
    ( after which the weight may be computed per	)
    ( preference.  Using |ged as above ensures that	)
    ( the code will return a moderately sensible result	)
    ( even if the context doesn't contain explicit	)
    ( values for one or more of the parameters used.	)

    ( Default to a boring middle value.  We presume	)
    ( all subclasses of badWeight will override this	)
    ( method:						)
    [ 0.5 |
;

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

