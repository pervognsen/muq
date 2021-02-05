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

( - 330-W-oldmud.muf -- Old-style rooms-and-exits islekit.		)
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
( Created:      96Oct21, from 30-X-nanomud.t				)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1997, by Jeff Prothero.				)
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
( - Thought								)
(									)
(									)
(									)
(      This is from quick jottings at a 96Nov06 Randy Pausch talk.	)
(      Randy has been doing neat stuff like Alice, (named after		)
(      Alice in Wonderland) a Python-based 3D VR system built on	)
(      SGI boxes and ported to MS-Windows.  He obviously enjoys		)
(      building tools that let students to enjoyable, nontrivial	)
(      VR projects.  He also gives good and entertaining talks. :)	)
(									)
(      The 10 Disney rules he gives can obviously be applied to		)
(      some kinds of online virtual world construction as well...	)
(									)
(      Jottings courtesy of my brother Jerry.				)
(									)
(									)
(									)
( Randy Pausch was in good form, just back from six			)
( months at Disney.  He said the key to Disney's			)
( animations is hand-painted textures, not lots of			)
( polygons.  (He also showed a 2-week, 6-student			)
( project by purely art students which was pretty			)
( good, running on a pentium.  "What I think you are			)
( seeing here is the beginning of the end for SG."			)
(									)
( Need a goal & backstory (context) before putting			)
( someone into an environment, he/Disney figure.			)
( Sickness = "protein spills."						)
(									)
( Walt Disney: "You really confuse people when you			)
( give them more than one choice."					)
(									)
( He went through the usual litany of what Disney			)
( does right: he figures they're qualitatively much			)
( better than any other theme park.  Even ones like			)
( MGM which spend more per foot.  Orlando is the			)
( world's #2 tourist destination, after Mecca.				)
(									)
( 10 Disney rules:							)
( 									)
(  1 Know audience.  (Looking for reassurance,				)
(    not escapism, from Disney.)					)
( 									)
(  2 Wear guests' shoes.						)
(    (When thinking about demos, etc.)					)
( 									)
(  3 Organize flow of people & ideas.					)
( 									)
(  4 Create visual magnets.  (Everyone walks towards the		)
(    Disney Castle; He also mentioned telling one of the		)
(    Disney people that a given ride was much better at			)
(    night.  "Of course. At night we can control where			)
(    you look."  With lights.						)
(      "Retinal burn", controlling memorable images, is a		)
(    phrase.								)
( 									)
(  5 Communicate w/ visual literacy.  (There's a blend,			)
(    like a film fade, between theme regions.  In terms			)
(    of architecture & music.)						)
( 									)
(  6 Avoid overload - create turnOns.					)
(    (He had 63 slides, 7 with words.)					)
( 									)
(  7 Tell one story at a time.						)
( 									)
(  8 Avoid contradictions - maintain identity.				)
(    (Disney puts up walls to block contradictory scenes,		)
(    like dumpsters... which the Vegas theme parks don't.)		)
( 									)
(  9 Ounce of treatment - ton of treat.					)
( 									)
( 10 Keep it up.							)
( 									)
( =====================================================================	)


( =====================================================================	)
( - Motivation -							)

( This file implements the core of the Muq oldmud, which is		)
( intended as a realistic example of implementing a traditional		)
( rooms-and-exits style mud on top of Muq.				)
(									)
( If you have not yet read the Muq nanomud, you may wish to		)
( to do so before reading this file, since the nanomud implements	)
( similar functionality in a much simpler setting.			)
(									)
( The nanomud security design goals apply equally to the oldmud:	)
( I will not repeat them here.						)
(									)
( Note that oldmud deliberately includes no code for listening		)
( on a socket for new users, checking their passphrase, logging		)
( them in, creating new users, and so forth.				)
(    The nanomud includes all these in order to demonstrate all		)
( the relevant mechanics compactly within one file for tutorial		)
( purposes.								)
(    In general, however, I am presuming that creation of new		)
( user accounts, together with implementation and maintainance		)
( of the procedure by which those users log into the Muq server,	)
( are the exclusive responsibility of the Muq sysadmins, whereas	)
( implementation and maintainance of islekits such as oldmud is		)
( a logically unrelated task which in general may be done by a		)
( completely different set of people:  A given Muq server may		)
( support a number of different islekits and isles based on		)
( those kits, and Muq users may wish to connect to any or several	)
( of them after logging in.						)
(									)
( In general, I see the high-level oldmud design as being an		)
( exercise in division of rights and responsibilities between		)
( the following parties:						)
(									)
( => The Muq sysadmins, managing the server proper.			)
(									)
( => The Muq isle admins managing the particular isle.			)
(									)
( => The Muq room/area owners, managing the particular			)
(    location(s) currently of interest.					)
(									)
( => The Muq avatar owners, managing the particular			)
(    avatars currently of interest.					)
(									)
( Any islekit must decide, for example, just who controls		)
( the location of an avatar, and how.  Can the avatar owner		)
( move the avatar anywhere at will?  Is the room/area owner		)
( free to refuse entry?  To refuse exit?  Is motion a physics		)
( issue to be decided exclusively by the isle admins?			)
( Depending just what one is trying to accomplish, any of the		)
( the above might be reasonable islekit design policy decisions.	)
(									)
( As another design decision, I have defined the oldmud interfaces	)
( primarily in terms of Muq Object System classes and generic		)
( functions, in order to make them as noncommittal and customizable	)
( as possible.  The design problem is thus largely reduced to picking	)
( classes and generic functions to export.				)
(									)

( =====================================================================	)
( - Design overview -							)

( Each user has a permanent						)



( =====================================================================	)
( - Package 'oldmud', exported symbols --				)

"OMUD" rootValidateDbfile pop
"OMSH" rootValidateDbfile pop
[ "oldmsh" .db["OMSH"] | ]inPackage
[ "oldmud" .db["OMUD"] | ]inPackage
( "oldmud" inPackage )
me$s.lib["oldmud"] --> .lib["oldmud"]

( =====================================================================	)

( - Constants -								)

( =====================================================================	)
( - Object Capability Constants -					)

( These are ORed together to produce a CAN field value:			)
( A poor man's array of boolean flags.  We try and keep			)
( these capabilities unique in the first nontrivial letter,		)
( so as to let the UI abbreviate them to a single char if		)
( user so desires.							)
(									)
( Obviously, this sort of bitflag hack can't be very general or		)
( extensible.  But it -can- handle lots of the most common cases	)
( very efficiently, saving us lots of network roundtrip delays and	)
( making typical system performance a lot snappier:			)
(									)
( Intended meanings are:						)
(   CAN_AVATAR		Directly represents a human user somewhere.	)
(   CAN_DO		Legitimate target for "do" commands.		)
(   CAN_ENTER		Legitimate direct target for a 'go' command.	)
(   CAN_FEMALE		Text renderings should use she/her/hers/etc.	)
(   CAN_GET		Legitimate target for get/put/hand/etc.		)
(   CAN_HTML_VIEW	Can describe itself in HTML.			)
(   CAN_HEAR		Legitimate target for say/pose/whisper.		)
(   CAN_LINK		Non-owners may @dig new rooms from this room.	)
(   CAN_MALE		Text renderings should use he/him/hers/etc.	)
(   CAN_NOTE_ROOM_CONTENTS    Should be informed when entering/leaving.	)
(   CAN_PLURAL		Text renderings should use they/their/etc.	)
(   CAN_TEXT_VIEW	Can describe itself in straight ascii.		)
(   CAN_VRML_VIEW	Can describe itself in VRML.			)
(   CAN_EXIT		An eXit -- indirect target for a 'go' command.	)
(									)
( If you add a constant, update CAN_TO_TEXT and CAN_TO_VERBOSE_TEXT:	)

   1 -->constant CAN_AVATAR		'CAN_AVATAR 		 export	( "a" )
   2 -->constant CAN_DO			'CAN_DO			 export ( "d" )
   4 -->constant CAN_ENTER		'CAN_ENTER 		 export ( "e" )
   8 -->constant CAN_FEMALE		'CAN_FEMALE		 export ( "f" )
  16 -->constant CAN_GET		'CAN_GET		 export ( "g" )
  32 -->constant CAN_HEAR		'CAN_HEAR		 export ( "h" )
  64 -->constant CAN_LINK		'CAN_LINK		 export ( "l" )
 128 -->constant CAN_MALE		'CAN_MALE		 export ( "m" )
 256 -->constant CAN_NOTE_ROOM_CONTENTS	'CAN_NOTE_ROOM_CONTENTS  export ( "n" )
 512 -->constant CAN_PLURAL		'CAN_PLURAL		 export ( "p" )
1024 -->constant CAN_TEXT_VIEW          'CAN_TEXT_VIEW           export ( "t" )
2048 -->constant CAN_VRML_VIEW          'CAN_VRML_VIEW           export ( "v" )
4096 -->constant CAN_HTML_VIEW          'CAN_HTML_VIEW           export ( "w" )
8192 -->constant CAN_EXIT               'CAN_EXIT                export ( "x" )



( =====================================================================	)
( - Request Opcode Constants -						)

( These constants are used as request opcodes in packets		)
( sent from one oldmud object to another.  From an object-		)
( oriented programming point of view, this is pretty			)
( primitive, but since oldmud is a distributed mud where		)
( different objects may be on different Muq servers on			)
( different machines in different countries running different		)
( versions of oldmud (or even completely different islekits),		)
( the integer opcodes provide an efficient common language for		)
( communication.							)
(									)
( We centralize all the constant declarations here to avoid		)
( using the same value for two different opcodes or such.		)
( The actual semantics for the various opcodes are discussed		)
( in the functions which implement them:  For an opcode			)
( req-xxx the function will be called doReqXxx.			)

1024 -->constant REQ_PING		'REQ_PING        export
1025 -->constant REQ_NOP		'REQ_NOP export
1026 pop
1027 pop
1028 -->constant REQ_ENHOLDING		'REQ_ENHOLDING		export
1029 -->constant REQ_DEHOLDING		'REQ_DEHOLDING		export
1030 -->constant REQ_IS_HOLDING		'REQ_IS_HOLDING		export
1031 -->constant REQ_ENHELD_BY		'REQ_ENHELD_BY		export
1032 -->constant REQ_DEHELD_BY		'REQ_DEHELD_BY		export
1033 -->constant REQ_IS_HELD_BY		'REQ_IS_HELD_BY		export
1034 -->constant REQ_NUMBER_HOLDING	'REQ_NUMBER_HOLDING	export
1035 -->constant REQ_NTH_HOLDING	'REQ_NTH_HOLDING	export
1036 -->constant REQ_NUMBER_HELD_BY	'REQ_NUMBER_HELD_BY	export
1037 -->constant REQ_NTH_HELD_BY	'REQ_NTH_HELD_BY	export
1038 -->constant REQ_HAS_LEFT		'REQ_HAS_LEFT		export
1039 -->constant REQ_HAS_COME		'REQ_HAS_COME		export
1040 -->constant REQ_HAS_BEEN_EJECTED	'REQ_HAS_BEEN_EJECTED	export
1041 -->constant REQ_HAS_CHANGED	'REQ_HAS_CHANGED	export
1042 -->constant REQ_ISLE_QUAY		'REQ_ISLE_QUAY		export
1043 -->constant REQ_CANONICAL_ROOM_NAME 'REQ_CANONICAL_ROOM_NAME export
1044 -->constant REQ_EXIT_DESTINATION	'REQ_EXIT_DESTINATION	export
1045 -->constant REQ_ROOM_BY_NAME	'REQ_ROOM_BY_NAME	export
1046 -->constant REQ_VIEW		'REQ_VIEW		export
1047 -->constant REQ_SUBSTRING		'REQ_SUBSTRING		export
1048 -->constant REQ_HEAR_SAY		'REQ_HEAR_SAY		export
1049 -->constant REQ_HEAR_PAGE		'REQ_HEAR_PAGE		export
1050 -->constant REQ_HEAR_WHISPER	'REQ_HEAR_WHISPER	export
1051 -->constant REQ_WHO_USER_INFO	'REQ_WHO_USER_INFO	export
1052 -->constant REQ_JOIN_LIST		'REQ_JOIN_LIST		export
1053 -->constant REQ_QUIT_LIST		'REQ_QUIT_LIST		export
1054 -->constant REQ_NOTE_LIST_CHANGE	'REQ_NOTE_LIST_CHANGE	export
1055 -->constant REQ_LIST_NAMES		'REQ_LIST_NAMES		export
1056 -->constant REQ_ADD_TO_LIST	'REQ_ADD_TO_LIST	export
1057 -->constant REQ_DROP_FROM_LIST	'REQ_DROP_FROM_LIST	export
1058 -->constant REQ_LIST_INFO		'REQ_LIST_INFO		export
1059 -->constant REQ_NEXT_LIST_ENTRY	'REQ_NEXT_LIST_ENTRY	export
1060 -->constant REQ_PREV_LIST_ENTRY	'REQ_PREV_LIST_ENTRY	export
1061 -->constant REQ_THIS_LIST_ENTRY	'REQ_THIS_LIST_ENTRY	export
1062 -->constant REQ_FIND_LIST_ENTRY	'REQ_FIND_LIST_ENTRY	export
1063 -->constant REQ_JOIN_PROP		'REQ_JOIN_PROP		export
1064 -->constant REQ_QUIT_PROP		'REQ_QUIT_PROP		export
1065 -->constant REQ_NOTE_PROP_CHANGE	'REQ_NOTE_PROP_CHANGE	export
1066 -->constant REQ_PROP_NAMES		'REQ_PROP_NAMES		export
1067 -->constant REQ_PROPERTY		'REQ_PROPERTY		export

( =====================================================================	)

( - Request Protocols -							)

( =====================================================================	)

( - Overview -								)
(									)
( A typical request is coded as follows:				)
(									)
(       [   :op 'oldmud:REQ_ROOM_BY_NAME    	    	    	       	)
(	    :to daemon	        					)
(	    :a0 roomName						)
(	    :fa av							)
(	    :fn :: { [] -> [] }						)
(									)
(		|shift -> av		( fa	)
(		|shift -> taskId					)
(		|shift -> daemon	( to	)
(		|shift -> roomName	( a0	)
(		|shift -> err		( r0	)
(		|shift -> room		( r1	)
(		]pop							)
(		err if err errcho [ | return fi				)
(									)
(               ...                                                  	)
(									)
(		[ |							)
(	    ;								)
(	|   ]request							)
(									)
( Explanation:								)
(									)
(   ]REQUEST is a method which takes care of firing off the request	)
(	to the recipient specified by the :TO argument.  ]REQUEST	)
(	takes care of doing retries at intervals if a response is not	)
(	recieved in good time, checking that replies don't look like	)
(	spoofs or errors, and similar busywork.				)
(									)
(   :OP The type of request being made, in this case REQ-ROOM-BY-NAME.	)
(	It must be one of the above REQ- constants.			)
(									)
(   :TO The object to which the request should be sent,			)
(       in this case DAEMON.						)
(									)
(   :A0 The first argument to be passed to the request			)
(	recipient (DAEMON).  Not all requests will have an :A0,		)
(	and some may have in addition :A1 or :A2.  In this case,	)
(	:A0 is ROOM-NAME, a string identifying the desired room.	)
(									)
(   :FA ("Function Argument")  An arbitrary value which will be passed	)
(	on to the :FN function.  This is a simple way of passing	)
(       state information to :FN -- the :FA value is stored locally	)
(	and may be trusted not to be corrupted.				)
(									)
(   :FN A function to be called if/when a response to the request is	)
(       recieved.  This function must accept and return a block;	)
(       the return block is currently ignored and should be empty.	)
(	The :FN function block contains positional arguments, often	)
(	including a block of characters representing a string.		)
(	In the example, these are in order:				)
(									)
(	AV  The value supplied to :FA, which is always first if		)
(	    supplied.							)
(									)
(	TASK-ID  Integer task id used by the task facility to handle	)
(	    this request.  This can normally be ignored;  Sometimes	)
(	    it is sensible to re-use this value in a new request.	)
(									)
(	DAEMON  The :TO argument, useful if the request needs to be	)
(	    regenerated for some reason.				)
(									)
(	ROOM-NAME The :A0 argument, as above, useful if the request	)
(	    needs to be regenerated.  If :A1 and :A2 arguments had	)
(	    been supplied, they would be next.				)
(									)
(	ERR The first reply value from the actual recipient of the	)
(	    request -- all the above values were stored locally (and	)
(	    hence may be trusted... be very careful about assuming	)
(	    anything about arguments returned from the recipient).	)
(	    All request return an ERR value, which should be NIL if	)
(	    the request succeeded, else a short string suitable as a	)
(	    human-readable diagnostic explaining the failure.		)
(									)
(	ROOM The second reply value from the actual recipient. This	)
(	   will be different depending on the REQ- opcode selected,	)
(	   or may be missing entirely:  You must check the docs for	)
(	   the particular request.  Any other return values from the	)
(	   request recipient would follow here.				)
(									)
(	The function should be written to silently ignore any		)
(	additional output values beyond those expected, to allow for	)
(	future expansion of return information.				)
(									)
( ---------------------------------------------------------------------	)





( =====================================================================	)
( - REQ_PING								)
(									)
(  SYNOPSIS:  See if an object (i.e., it's daemon) is alive.		)
(									)
(  KEYWORD INPUTS:							)
(    TO:  Object to ping.						)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR -- NIL on success, else a diagnostic string.			)
( =--------------------------------------------------------------------	)

( =====================================================================	)
( - REQ_ENHOLDING							)
(									)
(  SYNOPSIS:  Request that an object A hold another object B.		)
(	      Redundant enholdings succeed without changing anything.	)
(									)
(  KEYWORD INPUTS:							)
(    TO:  Object A, to add the isHolding relationship to its state.	)
(    AO:  Object B, to be held.  Isn't modified.			)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR -- NIL on success, else a diagnostic string.			)
(    CAN -- Integer of CAN-* bitflags summarizing A's properties.	)
(    NAME   NIL or a string giving a human-readable name for A.		)
(	    Must be <= 32 chars, using only alphabetics and underlines.	)
(	    Caller will enforce this if need be.			)
(    SHORT  NIL or a short (<= 32 chars) description of A such that	)
(	    "You see NAME, SHORT." is a sensible human-readable		)
(	    description of A -- should use only alphabetics, blanks	)
(	    and commas.							)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_DEHOLDING							)
(									)
(  SYNOPSIS:  Request that an object A cease holding another object B.	)
(	      Redundant deholdings succeed without changing anything.	)
(									)
(  KEYWORD INPUTS:							)
(    TO:  Object A, which is to remove the isHolding relationship.	)
(    AO:  Object B, to be removed from isHolding.  Isn't modified.	)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR -- NIL on success, else a diagnostic string.			)
(    DID -- NIL unless a change was made to A.				)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_IS_HOLDING							)
(									)
(  SYNOPSIS:  Ask if object A thinks it is holding object B.		)
(									)
(  KEYWORD INPUTS:							)
(    TO:  Object A.							)
(    AO:  Object B.							)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR     -- NIL on success, else a diagnostic string.		)
(    HOLDING -- NIL unless A thinks it is holding B.			)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_ENHELD_BY							)
(									)
(  SYNOPSIS:  Ask object A to record that it is held by object B.	)
(	      Redundant enheldBys succeed without changing anything.	)
(									)
(  KEYWORD INPUTS:							)
(    TO:  Object A, which is to record the heldBy relationship.	)
(    AO:  Object B.  Isn't modified.					)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR -- NIL on success, else a diagnostic string.			)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_DEHELD_BY							)
(									)
(  SYNOPSIS:  Ask object A to erase any record that is is held by B.	)
(	      Redundant deheldBys succeed without changing anything.	)
(									)
(  KEYWORD INPUTS:							)
(    TO:  Object A, which is to remove the isHeldBy relationship.	)
(    AO:  Object B, to be removed from isHeldBy.  Isn't modified.	)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR -- NIL on success, else a diagnostic string.			)
(    DID -- NIL unless a change was made to A.				)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_IS_HELD_BY							)
(									)
(  SYNOPSIS:  Ask if object A thinks it is heldBy object B.		)
(									)
(  KEYWORD INPUTS:							)
(    TO:  Object A.							)
(    AO:  Object B.							)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR     -- NIL on success, else a diagnostic string.		)
(    HELD-BY -- NIL unless A thinks it is heldBy B.			)
(    CAN     -- Integer sum of CAN-* bitflags giving A's properties.	)
(    NAME    -- NIL or human-readable <32-char name for A.		)
(    SHORT   -- NIL or short human-readable <32-char description of A.	)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_NUMBER_HOLDING							)
(									)
(  SYNOPSIS:  Ask how many objects object A thinks it is holding.	)
(									)
(  KEYWORD INPUTS:							)
(    TO:  Object A.							)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR     -- NIL on success, else a diagnostic string.		)
(    COUNT   -- Integer count of objects.				)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_NTH_HOLDING							)
(									)
(  SYNOPSIS:  Ask for nth object held by object A.			)
(									)
(  KEYWORD INPUTS:							)
(    TO:  Object A.							)
(    AO:  N, a nonnegative integer.					)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR     -- NIL on success, else a diagnostic string.		)
(    OBJ     -- Nth object held by A.					)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_NUMBER_HELD_BY							)
(									)
(  SYNOPSIS:  Ask how many objects object A thinks it is heldBy.	)
(									)
(  KEYWORD INPUTS:							)
(    TO:  Object A.							)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR     -- NIL on success, else a diagnostic string.		)
(    COUNT   -- Integer count of objects.				)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_NTH_HELD_BY							)
(									)
(  SYNOPSIS:  Ask for nth object holding object A.			)
(									)
(  KEYWORD INPUTS:							)
(    TO:  Object A.							)
(    AO:  N, a nonnegative integer.					)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR     -- NIL on success, else a diagnostic string.		)
(    OBJ     -- Nth object holding A.					)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_SYNOPSIS							)
(									)
(  SYNOPSIS:  Ask object A for a dump of the most commonly needed	)
(	      information about it.					)
(									)
(  KEYWORD INPUTS:							)
(    TO:  Object A.							)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR     -- NIL on success, else a diagnostic string.		)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_HAS_LEFT							)
(									)
(  SYNOPSIS:  Inform object A that object B has left object C.		)
(	      Object A would probably be wise to confirm this with B	)
(	      and C, unless it has good reason to trust the report.	)
(									)
(  KEYWORD INPUTS:							)
(    TO:  Object A.							)
(    AO:  Object B.							)
(    A1:  Object C.							)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR     -- NIL on success, else a diagnostic string.		)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_HAS_COME							)
(									)
(  SYNOPSIS:  Inform object A that object B has entered object C.	)
(	      Object A would probably be wise to confirm this with B	)
(	      and C, unless it has good reason to trust the report.	)
(									)
(  KEYWORD INPUTS:							)
(    TO:  Object A.							)
(    AO:  Object B.							)
(    A1:  Object C.							)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR     -- NIL on success, else a diagnostic string.		)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_HAS_BEEN_EJECTED						)
(									)
(  SYNOPSIS:  Inform object A that object B has been ejected from C.	)
(	      Object A should ignore this unless it is from C.		)
(	      If object A is object B, it should go home or otherwise	)
(	      re-establish a valid location.				)
(									)
(  KEYWORD INPUTS:							)
(    TO:  Object A.							)
(    AO:  Object B.							)
(    A1:  Object C.							)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR     -- NIL on success, else a diagnostic string.		)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_HAS_CHANGED							)
(									)
(  SYNOPSIS:  Inform object A that object B in room C has changed.	)
(	      Object A would probably be wise to confirm this with B	)
(	      and C, unless it has good reason to trust the report.	)
(									)
(  KEYWORD INPUTS:							)
(    TO:  Object A.							)
(    AO:  Object B.							)
(    A1:  Object C.							)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR     -- NIL on success, else a diagnostic string.		)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_EXIT_DESTINATION						)
(									)
(  SYNOPSIS:  Ask an exit where it leads to.  Reply is in the form of	)
(	      a daemon and a string naming the destination:  One must	)
(	      us REQ_ROOM_BY_NAME to get the actual room.  This gives	)
(	      the isle daemon a chance to create the destination room	)
(	      if need be.						)
(									)
(  KEYWORD INPUTS:							)
(    TO:  The exit.							)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR     -- NIL on success, else a diagnostic string.		)
(    DAEMON  -- Isle daemon for destination.				)
(    NAME    -- Canonical name for destination room, as a string.	)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_ROOM_BY_NAME							)
(									)
(  SYNOPSIS:  Ask a daemon for the room corresponding to a given	)
(	      canonical name.						)
(									)
(  KEYWORD INPUTS:							)
(    TO:  The daemon.							)
(    AO:  The room name (a string).					)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR     -- NIL on success, else a diagnostic string.		)
(    ROOM    -- The room.						)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_VIEW								)
(									)
(  SYNOPSIS:  Ask an object to describe itself.	 Result is in the form	)
(	      of a string identifier:  The actual description must	)
(	      then be retrieved using REQ_SUBSTRING.			)
(									)
(  KEYWORD INPUTS:							)
(    TO:  The object.							)
(    AO:  SIDE: "out" or "in" what to describe.				)
(    A1:  MIME: "plain", "html" or "vrml".				)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR      -- NIL on success, else a diagnostic string.		)
(    STR-ID   -- Integer ID for result string.				)
(    VIEW-LEN -- Length in bytes of result string.			)
(    SHORT    -- Short description.     NIL if STR-ID is non-NIL;	)
(    	         Note that SHORT may be NIL even if STR-ID is non-NIL.	)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_SUBSTRING							)
(									)
(  SYNOPSIS:  Ask for part of a string published by an object.		)
(									)
(  KEYWORD INPUTS:							)
(    TO:  The object.							)
(    AO:  STR-ID, Integer ID for published string.			)
(    A1:  START:  Integer start offset for substring within string.	)
(    A2:  MAX:    Integer maximum number of chars to return.		)
(		  Object is not required to return MAX chars:  It	)
(		  is only required to return more than zero chars and	)
(		  no more than MAX chars.				)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR      -- NIL on success, else a diagnostic string.		)
(    TYP      -- One of "plain", "html" or "vrml".			)
(    LEN      -- Length in bytes of complete published string.		)
(    ...      -- Chars constituting the returned substring.		)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_HEAR_SAY							)
(									)
(  SYNOPSIS:  Ask listener in room to hear something said.		)
(									)
(  KEYWORD INPUTS:							)
(    TO:  The listener.							)
(    AO:  The speaker.							)
(    A1:  The room.							)
(    A2:  The text said, as a stringId integer published by speaker.	)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR      -- NIL on success, else a diagnostic string.		)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_HEAR_PAGE							)
(									)
(  SYNOPSIS:  Ask listener in room to hear something said.		)
(									)
(  KEYWORD INPUTS:							)
(    TO:  The listener.							)
(    AO:  The speaker.							)
(    A1:  The text said, as a stringId integer published by speaker.	)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR      -- NIL on success, else a diagnostic string.		)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - REQ_HEAR_WHISPER							)
(									)
(  SYNOPSIS:  Ask listener in room to hear something said privately.	)
(									)
(  KEYWORD INPUTS:							)
(    TO:  The listener.							)
(    AO:  The speaker.							)
(    A1:  The room.							)
(    A2:  The text said, as a stringId integer published by speaker.	)
(									)
(  POSITIONAL OUTPUTS:							)
(    ERR      -- NIL on success, else a diagnostic string.		)
( =--------------------------------------------------------------------	) 

( =====================================================================	)
( - Don't we need a general push-knob function?  If it takes and	)
( returns a string(block?), this can be a fairly general escape hack.	)
( - Do we need a special protocol for PUT?  I.e., hand an object	)
( to someone/something, without leaving it en prise to thieves midway?	)
( This then raises the question of EXCHANGE and GIVE, but I'm inclined	)
( to punt on those.							)
( =--------------------------------------------------------------------	) 

( =====================================================================	)

( - Functions -								)

( =====================================================================	)
( - echo ---								)

:   echo   { $ -> }
    -> msg

    @.task.taskState :userIo get? -> uio if	( Isle daemons don't have user shells	)
	msg vals[
	    "eko" t uio
	    |maybeWriteStreamPacket
	    pop pop
	]pop
    fi
;
'echo export
"oldmsh"  inPackage
'oldmud:echo import
"oldmud"  inPackage

( =====================================================================	)
( - errcho ---								)

:   errcho   { $ -> }
    -> msg

    @.task.taskState :userIo get? -> uio if	( Isle daemons don't have user shells	)

	msg string? not if msg toString -> msg fi

	msg vals[
	    '\n' |delete
	     '*' |delete
	    do{ |length 60 > while |popp }
	    ' ' |push
	    '*' |push
	    '*' |push
	    '*' |push

	    ' ' |unshift
	    ':' |unshift
	    'y' |unshift
	    'r' |unshift
	    'r' |unshift
	    'o' |unshift
	    'S' |unshift
	    ' ' |unshift
	    '*' |unshift
	    '*' |unshift
	    '*' |unshift
	    "eko" t uio
	    |maybeWriteStreamPacket
	    pop pop
	]pop
    fi
;
'errcho export
"oldmsh"  inPackage
'oldmud:errcho import
"oldmud"  inPackage

( =====================================================================	)
( - canToText ---							)

:   canToText { $ -> $ }
    -> can
    can integer? not if 0 -> can fi
    [ "" |
    can CAN_AVATAR             logand 0 != if "a" |push fi
    can CAN_DO                 logand 0 != if "d" |push fi
    can CAN_ENTER              logand 0 != if "e" |push fi
    can CAN_FEMALE             logand 0 != if "f" |push fi
    can CAN_GET                logand 0 != if "g" |push fi
    can CAN_HEAR               logand 0 != if "h" |push fi
    can CAN_LINK               logand 0 != if "l" |push fi
    can CAN_MALE               logand 0 != if "m" |push fi
    can CAN_NOTE_ROOM_CONTENTS logand 0 != if "n" |push fi
    can CAN_PLURAL             logand 0 != if "p" |push fi
    can CAN_TEXT_VIEW          logand 0 != if "t" |push fi
    can CAN_VRML_VIEW          logand 0 != if "v" |push fi
    can CAN_HTML_VIEW          logand 0 != if "w" |push fi
    can CAN_EXIT               logand 0 != if "x" |push fi
    ]join
;
'canToText export

( =====================================================================	)
( - canToVerboseText ---						)

:   canToVerboseText { $ -> $ }
    -> can
    can integer? not if 0 -> can fi
    [ |
    can CAN_AVATAR             logand 0 != if "avatar"          |push fi
    can CAN_DO                 logand 0 != if "do-able"         |push fi
    can CAN_ENTER              logand 0 != if "go-able"         |push fi
    can CAN_FEMALE             logand 0 != if "female"          |push fi
    can CAN_GET                logand 0 != if "get-able"        |push fi
    can CAN_HEAR               logand 0 != if "hears"           |push fi
    can CAN_LINK               logand 0 != if "dig-ok"          |push fi
    can CAN_MALE               logand 0 != if "male"            |push fi
    can CAN_NOTE_ROOM_CONTENTS logand 0 != if "notes"           |push fi
    can CAN_PLURAL             logand 0 != if "plural"          |push fi
    can CAN_TEXT_VIEW          logand 0 != if "text"            |push fi
    can CAN_VRML_VIEW          logand 0 != if "vrml"            |push fi
    can CAN_HTML_VIEW          logand 0 != if "html"            |push fi
    can CAN_EXIT               logand 0 != if "exit"            |push fi
    |length 0 = if ]pop "" return fi
    "; " ]glueStrings
;
'canToVerboseText export

( =====================================================================	)
( - rankOf	-- Fixnum rank for local avatars, else nil		)

:   rankOf { $ $ -> $ }
    -> can
    -> obj

    can fixnum? if
	can CAN_AVATAR logand 0 != if
	    obj remote? not if
		obj$s.owner -> owner
		owner user? if
		    owner$s.rank return
    fi	fi  fi  fi

    nil
;
'rankOf export

( =====================================================================	)
( - rankText	-- Text display of rank					)

:   rankText { $ $ -> $ }
    rankOf -> rank
    rank fixnum? if
	[ "; #%d" rank | ]print   return
    else
        ""   return
    fi
;
'rankText export

( =====================================================================	)
( - lookAtCan ---							)

:   lookAtCan { [] -> [] }
    |pop -> can
    |pop -> obj

    obj can rankText -> rank

    @.task.taskState.showObjectFlags case{
    on: :verbose
	can canToVerboseText -> s
	s "" != if
	    " ("  |push
	    s      |push
	    rank   |push
	    ")"    |push
	fi	
    on: :compact
	can canToText -> s
	s "" != if
	    " ("  |push
	    s      |push
	    rank   |push
	    ")"    |push
	fi	
    }
;
'lookAtCan export

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

