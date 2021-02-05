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

( - 425-W-badlands.muf -- Procedurally defined building support.	)
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
( Created:      97Dec07							)
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

( - Quote -								)


( From: "Jon A. Lambert" <jlsysinc@ix.netcom.com>			)
( To: mudDev@null.net							)
( Subject: [MUD-Dev]  World Design					)
( 									)
( On  7 Dec 97 at 13:05, Marian Griffith wrote:				)
( > On Sat 06 Dec, s001gmu@nova.wright.edu wrote:			)
( > > On Fri, 5 Dec 1997, Sauron wrote:					)
( > > > One of the challenges I	have found both interesting and 	)
( > > > enjoying about working with an entirely	original theme is	)
( > > > that of creating a believable world with an enthralling		)
( > > > history which draws people in.					)
( > 									)
( > I belief this is much more important to the game than the actual	)
( > map. The history  will provide the game with a sense of continuity	)
( > and it can guide the area builders in their efforts much more than	)
( > a fairly abstract map can do.					)
( > 									)
( > > Amen.  :)  I think having a full world map also makes solving the )
( > > problem of long distance travel a little easier.. at least it's 	)
( > > easier to keep it a realistic solution.				)
( 									)
( Regarding the design of worlds in general:				)
( 									)
( The following is a synthesis of several FRPG systems of creating 	)
( worlds that was jotted down many moons ago by myself (I think mostly 	)
( from 1st edition RoleMaster stuff).  The order and comments were 	)
( somewhat subjective to my worlds and some of them might be odd, but 	)
( I thought I'd include it in its entirety.  Perhaps I've overlooked	)
( some important aspects or there is a more logical way to order this.	)
( 									)
( --cut--								)
( Designing a World Checklist						)
( 									)
( 1)  Choose a world environment.					)
( 2)  Sketch major land masses, oceans, moons, and suns.		)
( 3)  Plot prevailing winds, ocean currents, and climatic bands of	)
(     the world.							)
( 4)  Make notes of settings, characters, and situations you want to	)
(     include in play. 							)
( 5)  Draw up a historical timeLine running back at least 3000 years.	)
( 6)  Establish major forces and/or conflicts in the world.		)
( 7)  Decide on major flora and fauna resources. 			)
( 8)  Plot trade routes and locations of resources in the world. 	)
( 9)  From trade routes plot the political forces, tensions, trade, and )
(     interests of civilizations. 					)
( 10) Consider the growth of civilizations and their influence on world )
(     events. 								)
( 11) Establish the philosophical foundations of the universe and the 	)
(     gods (mythology) that represent that philosophy. 			)
( 12) Create folk tales and local traditions, past political history, 	)
(     racial distribution, and religious beliefs of each area. 		)
( 13) Establish heroes and legends from the political and mythological 	)
(     history. 								)
( 14) Determine technological levels of the various civilizations. 	)
( 15) Determine local mores and codes of conduct. 			)
( 16) Plot constellations of the night sky and develop astrological 	)
(     symbols.								)
( 17) Determine the location and prevalence of ancient ruins. 		)
( 18) Determine any powerful non-governmental powers in the world. 	)
( 19) Develop languages and customs of each civilization.		)
( --cut--								)
( 									)
( --									)
( Jon A. Lambert							)
( "Everything that deceives may be said to enchant" - Plato		)


( =====================================================================	)

( - Classes -								)

( =====================================================================	)

( - Synonyms -								)

( abominable atrocious awful ; anchorage aerie abode alley arcade avenue apartments ; little awful annie? *grin )
( bad broken banned baleful burned ; berth buffet boardwalk bivouac bungalow boulevard bar bridge bayou bay bypass byway )
( calamity catastrophe cancer condemned ; castle croft coffeehouse canteen club cabaret corral court crecent circus cabin chateau chalet cottage corner commons crossing camp city cafe channel cut causeway canal )
( dreadful dire detestable dessication ; den dive drive dwelling )
( excrable ersatz egregious ; expressway esplanade )
( failure frightful foul folly ; flats farmhouse forest ford falls footbridge )
( ghastly glum gray grimy ; gulch groves ginhouse grange gorge gate grill gardens )
( hardluck hapless hopeless horrid hostile ; hospice hermitage hacienda hutch hut haunt harbor hamlet hall highway hovel hostel hotel house hill homestead )
( inferior ill ignoble ; iglu inn )
( jaundice junk ; junction jacal )
( kaput knaves ; kennel knoll kiosk )
( lamentable lousy lost ; lane lake lair lodge )
( miserable malfeasance ; mall mews meander mission motel mountain mansion )
( nasty null ; neighborhood? nook? nave? neck? narrows? )
( ominous ; oasis omission )
( pox plague pestilence penury poor poverty ; piazza pavilion perch palace port park parkway place pass pub pool passage )
( questionable ; quad quarter )
( regrettable rotten ruined rank ; roost rotunda row road rivulet river rapids restaurant resort retreat )
( sickly starvation shoddy slovenly surplus sallow ; spa shack shanty station stream street square saloon store speedway stile )
( toothache tedious tainted trivial trashy ; tenement toft terrace towers tepee town tavern track thoroughfare throughway trickle torrent turnpike tarn )
( venial vile ; valley villa village )
( worn worst wretched ; wigwam way woods wharf )
( xenophobia ; xenodochium )
( yellow ; yard yurt )
( zeolite zapulation ; zanana zoo )

( =====================================================================	)

( - Functions -								)

( =====================================================================	)
( - badRoot -- Invent root room for badlands.				)

:   badRoot { [] -> [] }
    |shift -> fa
    |shift -> badExit
    |shift -> exitName
    ]pop

    [   "BadLands"
	"the dreaded Badlands"
	badExit.liveDaemon
    | makeRoom 
    ]-> root

    [ nil root |
;

( =====================================================================	)
( - installBadlands -- Install base badlands room.			)

:   installBadlands { [] -> [] }
    |shift -> isle
    ]pop

    isle.quay -> quay    

    ( Create exit from quay to badlands: )
    [   "N"
        "a path leading to the BadLands"
        isle
	'badRoot
	nil
    | makeBadExit ]-> quayToBadlands

    ( Point exit to procedurally defined room: )
    quay.name ";N" join --> quayToBadlands.exitDestination

    ( Put exit in quay: )
    quay             quayToBadlands enhold
    quayToBadlands quay             enheldBy

    [ |
;

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

