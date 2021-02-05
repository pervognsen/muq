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

( - 423-W-badroom.muf -- Procedurally defined room.			)
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

( - Overview -								)

( We are defining a spatial grammar here, in which			)
( rooms recursively define subRooms linked by exits.			)
(									)
( The crucial elements in making this work seem to me to be:		)
(									)
( 1) 'Canonical' state element 'naming' the room, making it unique;	)
(									)
( 2) 'Contextual' state to be inherited by child rooms, allowing	)
(    some degree of local order and relationship;			)
(									)
( 3) 'Grammatical' defining the types of allowed children.		)
(									)
( In this implementation:						)
(									)
( The canonical state element is the string name for the room, which	)
( is actually the path by which we reach it from the root badlands	)
( room: Something like "badlands;N;W;NE;UP" or such.			)
(   By hashing this string to an integer or float, we can make local	)
( configuration decisions such as picking a name and description that	)
( will be reproducible each time this room is re/created, yet distinct	)
( from other rooms of the same class.					)
(									)
( The contextual state element is a vector of keywordValue pairs,	)
( given to us by value by our parent room, edited by us as we please,	)
( and then handed in turn by value to any child rooms we create.	)
( It may contain any sort of information we please which may give	)
( local coherence to the building, say:					)
(   :thisAreasClimate  :hotAndDry					)
(   :thisTownsName     "KimVille"					)
(   :thisTownsTheme    :wild-west					)
(   :thisStreetsType   :commercial					)
(   :thisBuildingsType :hotel						)
( Individual procedural room class constructors can then make their 	)
( result be conditional on this context in various ways, perhaps	)
( putting in fewer windows in :hotAndDry climates, more marble in	)
( :bank type buildings, and so forth.					)
(									)
( The grammatical state elements consist, for a given procedural room	)
( class, of a set of <weight,subroomClass> pairs, from which we pick	)
( children with probabilities based on the weights -- a subroom class	)
( A with a weight twice that of subroom class B will be picked twice	)
( as often as B.  As usual, the choice will ultimately be controlled	)
( by some hash of the parent room's caonical name, to make the room	)
( construction reproducible.						)
(   The procedural building process revolves around defining		)
( new classes of rooms, with each new class of room needing to be	)
( hooked into the existing 'spatial grammar' by being added to the	)
( gramatical state elements of one or more pre-existing classes --	)
( otherwise, the new room class will never get generated.		)
(   In the interests of code cleanliness and maintainability, we need	)
( to be able to do these hookups without actually modifying the code	)
( of those pre-existing classes.  Thus, the grammatical state elements	)
( need to be regarded not as fixed code, but as datastructures linked	)
( to the class, updatable after class creation via suitable calls.	)
(   It is also convenient to distinguish different types of subobjects	)
( generated by a given class of procedurally defined room:  In		)
( particular, we wish to distinguish:					)
( o Objects contained within the current room, such as furniture.	)
( o Rooms adjacent to the current room, perhaps linked by doorways	)
(   or constituting parts of the same road or stream or field.		)
(   We make this distinction by maintaining separate datastructures	)
( for each such class of generated object.				)





( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - badRoom -- Procedurally defined room.				)

defclass: badRoom
    :export t
    :isA 'room

    :slot :contentsClasses
        :prot       "rw----"
        :allocation :class 
        :initform   :: 'badSet makeInstance ;

    :slot :neighborsClasses
        :prot       "rw----"
        :allocation :class 
        :initform   :: 'badSet makeInstance ;

    :slot :badFn	:prot "rw----"	:initval nil
    :slot :badFa	:prot "rw----"	:initval nil
;

( =====================================================================	)
( - makeBadRoom -- 							)

defgeneric: makeBadRoom {[ $     $      $           $   $  ]} ;
defmethod:  makeBadRoom { 't    't     't          't  't   } ;
defmethod:  makeBadRoom { 't    't     'daemonHome 't  't   }
    {[                    'name 'short 'home       'fn 'fa ]}

    name isAString

    'badRoom makeInstance -> room

    [ exit name short home | initRoom ]pop

    fn --> exit.badFn
    fa --> exit.badFa

    [ room |
;
'makeBadRoom export


( =====================================================================	)
( - augmentNeighborsClasses -- Add a class to the set.		)

defgeneric: augmentNeighborsClasses {[ $        $      $     ]} ;
defmethod:  augmentNeighborsClasses { 't       't     't      } ]pop [ | ; 
defmethod:  augmentNeighborsClasses { 'badRoom 't     't      }
    {[                                'me      'klass 'weight ]}

    [ me.neighborsClasses klass weight | augmentBadset
;

( =====================================================================	)
( - augmentContentsClasses -- Add a class to the set.			)

defgeneric: augmentContentsClasses {[ $         $      $     ]} ;
defmethod:  augmentContentsClasses { 't        't     't      } ]pop [ | ; 
defmethod:  augmentContentsClasses { 'badRoom 't     't      }
    {[                                 'me       'klass 'weight ]}

    [ me.contentsClasses klass weight | augmentBadset
;

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

