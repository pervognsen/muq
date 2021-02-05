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

( - 405-W-oldavatar-room.muf -- avatar perRoom info record.		)
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
( Created:      97Jul22							)
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
( - Package 'oldmud' --							)

"oldmud" inPackage


( =====================================================================	)

( - Functions -								)

( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - roomCache -- Record tracking contents of a room.			)

( In a distributed environment, we can't assume instant access to,	)
( nor perfect knowledge of, the room an avatar is in.  As a practical	)
( matter, we must also deal gracefully with disconnected servers,	)
( inconsistent state information, and broken or malicious rooms,	)
( isles and avatars.							)
(									)
( With this in mind, we define an object to be 'present' in the room	)
( if the room claims it to be present and the object agrees.  		)	
( We consider an object to have left any time the room -or- the object	)
( so notify us.								)
(									)
(									)
(   MAX-CONTENTS   Maximum # of objects for which we'll cache info.	)
(   MAX-NICKNAME   Maximum length of an object nickname.		)
(   US     Object cache is maintained for, usually our avatar		)
(   ROOM   Room cache is maintained about, usually avatar's location	)
(									)
( For each object present, we track the following info:			)
(   OBJECT pointer to object proper					)
(   NAME   short text string by which we identify object.		)
(   KEY    Public key of owner, to validate messages from it.		)
(   RANK   Integer rank of owner for local users.			)
(   GHOST  NIL if fully present, else next time to ping object.		)
(   IO     object/io, cached locally as an efficiency hack.		)
(   CAN    integer giving capabilities of object. See CAN-* constants.	)
(          The CAN field is also basically an efficiency hack, saving	)
(	   us the network roundTrips needed to enquire about object	)
(	   capabilities in common cases.				)

defclass: roomCache
    :export  t

    :slot :maxContents	 :prot "rw----"   :initval 64
    :slot :maxNickname	 :prot "rw----"   :initval 32
    :slot :maxShort	 :prot "rw----"   :initval 64
    :slot :us		 :prot "rw----"   :initval nil
    :slot :room		 :prot "rw----"   :initval nil
    :slot :roomCan	 :prot "rw----"   :initval 0
    :slot :roomName	 :prot "rw----"   :initval ""
    :slot :roomShort	 :prot "rw----"   :initval ""
    :slot :object	 :prot "rw----"   :initform :: makeStack ;
    :slot :name		 :prot "rw----"   :initform :: makeStack ;
    :slot :short	 :prot "rw----"   :initform :: makeStack ;
    :slot :key		 :prot "rw----"   :initform :: makeStack ;
    :slot :rank		 :prot "rw----"   :initform :: makeStack ;
    :slot :ghost	 :prot "rw----"   :initform :: makeStack ;
    :slot :can		 :prot "rw----"   :initform :: makeStack ;

;

( =====================================================================	)

( - Generics -								)

( =====================================================================	)
( - clearRoomCache							)

defgeneric: clearRoomCache {[ $        ]} ;
defmethod:  clearRoomCache { 't         } ;
defmethod:  clearRoomCache { 'roomCache }
    {[                       'it       ]}

    nil --> it.us
    nil --> it.room

    it.object reset
    it.name   reset
    it.short  reset
    it.key    reset

    it.rank   reset
    it.ghost  reset
    it.can    reset

    [ |
;
'clearRoomCache export

( =====================================================================	)
( - enterRoomObject -- Remember room claims object is present		)

defgeneric: enterRoomObject {[ $          $   ]} ;
defmethod:  enterRoomObject { 't         't    } ;
defmethod:  enterRoomObject { 'roomCache 't    }
    {[                        'it        'obj ]}

    ( Ignore if we already have the object: )
    it.object obj  getKey? -> i if [ | return fi

    ( Store it: )
    obj it.object push
    nil it.name   push
    nil it.short  push
    nil it.key    push
    nil it.rank   push
    t   it.ghost  push  ( buggo! )
    0   it.can    push

    [ |
;
'enterRoomObject export

( =====================================================================	)
( - normalizeShort	-- Impose sanity on user-supplied shorts	)

:   normalizeShort { $ $ -> $ }
    -> it
    -> short

    ( Make sure short is a string: )
    short string? not if "" -> short fi

    ( Keep nuts from spamming us with 16K names or such: )
    short length it.maxShort > if
	short 0 it.maxShort substring -> short
    fi

    ( Keep nuts from spamming us with weird chars in short descriptions: )
    short vals[
        |for c do{
	    c alphaChar? not if
            c digitChar? not if
		c ' '  != if
		c '-'  != if
		c '_'  != if
		c ','  != if
                   0 -> c
	    fi fi fi fi fi fi
	}
	|deleteNonchars
    ]join -> short

    short
;
'normalizeShort export

( =====================================================================	)
( - normalizeDoing	-- Impose sanity on user-supplied DOINGs	)

:   normalizeDoing { $ $ -> $ }
    -> it
    -> doing

    ( Make sure doing is a string: )
    doing string? not if "" -> doing fi

    ( Keep nuts from spamming us with 16K names or such: )
    doing length it.maxShort > if
	doing 0 it.maxShort substring -> doing
    fi

    ( Keep nuts from spamming us with weird chars in doing descriptions: )
    doing vals[
        |for c do{
	    c graphicChar? not if
                0 -> c
	    fi
	}
	|deleteNonchars
    ]join -> doing

    doing
;
'normalizeDoing export

( =====================================================================	)
( - normalizeName2	-- Impose sanity on user-supplied names		)

:   normalizeName2 { $ $ -> $ }
    -> maxName
    -> nam

    ( Make sure nam is a string: )
    nam string? not if "Anonymous" -> nam fi

    ( Keep nuts from spamming us with 16K names or such: )
    nam length maxName > if
	nam 0 maxName substring -> nam
    fi

    ( Keep nuts from spoofing us with weird chars in names: )
    nam vals[
        |for c do{
	    c '0' = if 'O' -> c fi  ( Prevent "011iver" style spoofing )
	    c '1' = if 'l' -> c fi
            c digitChar? not if
	    c alphaChar? not if
		c '-'  != if
		c '_'  != if
                   0 -> c
	    fi fi fi fi
	}
	|deleteNonchars

    ]join -> nam

    ( Spoof insurance: )
    nam "you"   =-ci if "Yu"    -> nam fi
    nam "me"    =-ci if "Mie"   -> nam fi
    nam "in"    =-ci if "Inn"   -> nam fi
    nam "it"    =-ci if "Itt"   -> nam fi
    nam "she"   =-ci if "Shei"  -> nam fi
    nam "he"    =-ci if "Hea"   -> nam fi
    nam "they"  =-ci if "Thea"  -> nam fi
    nam "their" =-ci if "Thera" -> nam fi
    nam "lanya" =-ci if "Al"    -> nam fi
    nam "here"  =-ci if "Heare" -> nam fi
    nam "her"   =-ci if "Hera"  -> nam fi
    nam "his"   =-ci if "Hiss"  -> nam fi
    nam ""      =    if "Anon"  -> nam fi

    nam
;
'normalizeName2 export

( =====================================================================	)
( - normalizeName	-- Impose sanity on user-supplied names		)

:   normalizeName { $ $ -> $ }
    -> it
    -> nam
    nam it.maxNickname normalizeName2
;
'normalizeName export

( =====================================================================	)
( - uniquifyName	-- Make name locally unique			)

:   uniquifyName { $ $ -> $ }
    -> it
    -> nam

    ( Rename if we already have something by that name: )
    nam -> n
    1   -> j
    do{ it.name n getKey? pop while
	++ j
	nam "#" j toString join join -> n
    }
    n -> nam

    nam
;

( =====================================================================	)
( - resolveName		-- Find object given name			)

defgeneric: resolveName {[ $          $ ]} ;
defmethod:  resolveName { 't         't  } ]pop [ nil | ;
defmethod:  resolveName { 'roomCache 't  }
	|shift                           -> it
	|shift                           -> nam
	|length 0 = if -1 else |shift fi -> can
    ]pop

    ( Handle some standard special cases: )
    nam case{
    on: ""      [ it.room         it.roomCan | return
    on: "here"  [ it.room         it.roomCan | return
    on: "me"    [ it.us           it.us.can  | return
    on: "home"  [ it.us.homeRoom  0          | return
    on: "isle"  [ it.us.homeIsle  0          | return
    }

    ( Search for exact match on name: )
    it.name foreach key val do{
	val nam =-ci if
	    can it.can[key] logand 0 != if
		[ it.object[key] it.can[key] | return
	fi  fi
    }

    ( Should do a secondary search for partial matches here... )

    [ nil nil |
;
'resolveName export

( =====================================================================	)
( - confirmRoomObject	-- Room and object agree object is present	)

defgeneric: confirmRoomObject {[ $          $    $    $    $      $    ]} ;
defmethod:  confirmRoomObject { 't         't   't   't   't     't     } ;
defmethod:  confirmRoomObject { 'roomCache 't   't   't   't     't     }
    {[                          'it        'obj 'can 'nam 'short 'from ]}

    ( Ignore unless we already have the object: )
    it.object obj  getKey? -> i not if [ nil | return fi

    ( Ignore unless it is a ghost: )
    it.ghost[i] not if [ nil | return fi

    ( Impose sanity on names: )
    nam it normalizeName it uniquifyName -> nam

    ( Store it: )
    nam   --> it.name[i]
    nil   --> it.ghost[i]
    can   --> it.can[i]
    short --> it.short[i]

    ( If object is local, record rank of owner: )
    obj can rankOf --> it.rank[i]

    can CAN_AVATAR logand 0 != if
	obj remote? not if
	    obj$s.owner -> owner
	    owner user? if
		owner$s.rank --> it.rank[i]
    fi	fi  fi

    [ nam |
;
'confirmRoomObject export

( =====================================================================	)
( - forgetRoomObject	-- Remove room object				)

defgeneric: forgetRoomObject {[ $          $   ]} ;
defmethod:  forgetRoomObject { 't         't    } ;
defmethod:  forgetRoomObject { 'roomCache 't    }
    {[                         'it        'obj ]}

    ( Ignore unless we have the object: )
    it.object obj  getKey? -> i not if
	[ | return
    fi

    it.object i deleteBth
    it.name   i deleteBth
    it.short  i deleteBth
    it.key    i deleteBth
    it.rank   i deleteBth
    it.ghost  i deleteBth
    it.can    i deleteBth

    [ |
;
'forgetRoomObject export

( =====================================================================	)
( - allRoomObjects -- Return all confirmed objects in room		)

defgeneric: allRoomObjects {[ $         ]} ;
defmethod:  allRoomObjects { 't          } ;
defmethod:  allRoomObjects { 'roomCache  }
    {[                       'it        ]}

    [ |

    it.ghost -> ghost
    it.object foreach i o do{
	ghost[i] not if o |push fi
    }
;
'allRoomObjects export

( =====================================================================	)
( - roomObjectInfo -- Return info on given object			)

defgeneric: roomObjectInfo {[ $          $   ]} ;
defmethod:  roomObjectInfo { 't         't    } ;
defmethod:  roomObjectInfo { 'roomCache 't    }
    {[                       'it        'obj ]}

    ( Error if we don't have object: )
    it.object   obj  getKey? -> i not if [ :name nil | return fi
    it.ghost[i]                       if [ :name nil | return fi

    [ :name it.name[i] :short it.short[i] :key it.key[i] :rank it.rank[i] :can it.can[i] |
;
'roomObjectInfo export

( =====================================================================	)
( - hasRoomObject -- Test for presence of object			)

defgeneric: hasRoomObject {[ $          $   ]} ;
defmethod:  hasRoomObject { 't         't    } ;
defmethod:  hasRoomObject { 'roomCache 't    }
    {[                      'it        'obj ]}

    ( All NILs if we don't have object: )
    it.object   obj  getKey? -> i not if [ nil | return fi
    it.ghost[i]                        if [ nil | return fi

    [ :name it.name[i] :short it.short[i] :key it.key[i] :rank it.rank[i] :can it.can[i] |
;
'hasRoomObject export

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

