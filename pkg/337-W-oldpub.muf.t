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

( - 337-W-oldpub.muf -- String server.					)
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
( Created:      97Sep28							)
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
( - Overview -								)





( =====================================================================	)
( - Package 'pub' --							)

"PUB" rootValidateDbfile pop
[ "pub" .db["PUB"] | ]inPackage



( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - home -- State record for daemons supporting string service.		)

( PUB-MAX-STRINGS is max # of strings to publish at any given time.	)
(		  When exceeded, strings are deleted oldestFirst.	)
(									)
( PUB-MAX-BYTES is max # of stringbytes to publish at a given time.	)
(		  When exceeded, strings are deleted oldestFirst.	)
(									)
( PUB-MAX-SUBSTRING is max # of bytes to return for a single request.	)
(		  Currently set to 450, partly to keep load on the	)
(		  server reasonable, partly so packets will fit in	)
(		  the 576 (?) byte typical PPP maximum transmission	)
(		  unit, avoiding the inefficiencies associated with	)
(		  packet fragmentation.					)
(									)
( PUB-NOW-BYTES is current number of stringbytes published.		)
(									)
( PUB-JOB is daemon job currently animating us.				)
(									)
( PUB-STATE is state record of daemon job currently animating us.	)
(									)
( PUB-NEXT-ID is next string id to issue, an integer.			)
(									)
( PUB-ID is a stream of string IDs, useful for deleting a task.		)
(									)
( PUB-FN is a stream of requestOk functions to invoke.			)
(       FN is currently invoked with [ :FA FA :AV AV | where		)
(           FA is following arbitrary user-supplied state, and		)
(	    AV is avatar trying to read string.				)
(	FN should accept blocks with additional keyword/value pairs,	)
(	    since future releases may wish to supply additional		)
(	    information useful for deciding whether to grant read	)
(	    privileges to the string.					)
(	FN return value will be:					)
(           [ T   | if avatar is     permitted to read string,		)
(           [ NIL | if avatar is not permitted to read string.		)
(	   								)
(	   								)
( PUB-FA is a stream of states for the PUB-FN functions.		)
(									)
( PUB-STRING is the stream of published strings.			)
(									)
( PUB-MIMETYPE is the stream of published string types,			)
(	typically "plain", "html" or "vrml"				)
(									)
( PUB-LEN holds the lengths of the  strings.				)
(									)

defclass: home
    :export  t

    :slot :pubLock	:prot "rw----"	 :initform :: makeLock  ;

    :slot :pubMaxStrings	:prot "rw----"	 :initval  128
    :slot :pubMaxSubstring	:prot "rw----"	 :initval  450	( Fit in 576-byte PPP packet )
    :slot :pubMaxBytes	:prot "rw----"	 :initval  65536
    :slot :pubNowBytes	:prot "rw----"	 :initval  0

    :slot :pubJob	:prot "rw----"	 :initval  nil
    :slot :pubState	:prot "rw----"	 :initval  nil
    :slot :pubNextId	:prot "rw----"	 :initval  1

    :slot :pubId	:prot "rw----"	 :initform :: makeStream ;
    :slot :pubFn	:prot "rw----"	 :initform :: makeStream ;
    :slot :pubFa	:prot "rw----"	 :initform :: makeStream ;
    :slot :pubString	:prot "rw----"	 :initform :: makeStream ;
    :slot :pubMimetype	:prot "rw----"	 :initform :: makeStream ;
    :slot :pubLen	:prot "rw----"	 :initform :: makeStream ;
;
 
( =====================================================================	)

( - Generic Functions -							)

( =====================================================================	)
( - dropOldestString -- Remove one string.				)

defgeneric: dropOldestString {[ $    ]} ;
defmethod:  dropOldestString { 't     } ;
defmethod:  dropOldestString { 'home  }
    ]-> us
    
    us.pubLock withLockDo{

	( Drop oldest entry: )
	us.pubLen      pull -> len
	us.pubId       pull pop
	us.pubFn       pull pop
	us.pubFa       pull pop
	us.pubString   pull pop
	us.pubMimetype pull pop

	( Restore invariants: )
	us.pubNowBytes len - --> us.pubNowBytes
    }
;

( =====================================================================	)
( - unpublishAllStrings -- Clear all pending strings.			)

defgeneric: unpublishAllStrings {[ $    ]} ;
defmethod:  unpublishAllStrings { 't     } ;
defmethod:  unpublishAllStrings { 'home  }
    {[              'us      ]}

    us.pubLock withLockDo{
	us.pubId       reset
	us.pubFn       reset
	us.pubFa       reset
	us.pubString   reset
	us.pubMimetype reset
	us.pubLen      reset
        0 --> us.pubNowBytes 
    }

    [ |
;
'unpublishAllStrings export

( =====================================================================	)
( - publishString -- Post a string for public access.			)

( PUBLISH-STRING args are:						)
(    US       pub:home instance.					)
(    STRING   string to be published.					)
(    MIMETYPE Text type for STRING: "plain", "html" or "vrml".		)
(    FN       Function controlling who can access string.		)
(    FA       State argument for FN.					)
(									)
( TASK returns a block containing the integer string ID.  String ids	)
(	  are generated by incrementing a counter starting at zero.	)

defgeneric: publishString {[ $     $  $  $  $ ]} ;
defmethod:  publishString { 't    't 't 't 't  } ;
defmethod:  publishString { 'home 't 't 't 't  }
    |shift -> us
    |shift -> str
    |shift -> typ
    |shift -> fn
    |shift -> fa
    ]pop

    ( Sanity checks: )
    fn compiledFunction?
    fn symbol?
    or not if "pub:publishString fn must be a compiledFunction (or symbol)" simpleError fi
    ( buggo: Oddly, changing above check to 'callable?' doesn't work -- we must   )
    ( be entering a symbol before we bind a function to it, somewhere? 98Aug21CrT )
    str string? not if "pub:publishString string must be a string" simpleError fi
    typ string? not if "pub:publishString mimetype must be a string" simpleError fi

    ( How long is the string? )
    str length -> len

    ( Save everything: )
    us.pubLock withLockDo{

        ( A small optimization: if current entry is same   )
        ( as last entry, just return index for last entry: )
        us.pubString length 1- -> d
        nil -> match 
        d 0 >= if 
            t -> match 
	    us.pubString[d]   str != if nil -> match fi
	    us.pubMimetype[d] typ != if nil -> match fi
	    us.pubFn[d]       fn  != if nil -> match fi
	    us.pubFa[d]       fa  != if nil -> match fi
	fi
	match if
            [ us.pubId[d] | return
        fi

        ( Allocate a new string id: )
	us.pubNextId -> id
        id 1 + --> us.pubNextId

        ( Save new string: )
	id    us.pubId       push
	str   us.pubString   push
	typ   us.pubMimetype push
	fn    us.pubFn       push
	fa    us.pubFa       push
	len   us.pubLen      push

        us.pubNowBytes len + --> us.pubNowBytes
    }



    ( Restore invariants by dropping old strings as necessary: )

    ( Don't exceed max bytes to post: )
    do{
        us.pubNowBytes us.pubMaxBytes < until
	us.pubString length 1 = until	( But leave at least one string )
	[ us | dropOldestString ]pop
    }

    ( Don't exceed max strings to post: )
    do{
        us.pubString length us.pubMaxStrings < until
	[ us | dropOldestString ]pop
    }

    [ id |
;
'publishString export

( =====================================================================	)
( - getStringSegment -- Return substring of published string + length	)

( GET-STRING-SEGMENT args are:						)
(    US      pub:home instance.						)
(    ID      integer id of string.					)
(    AV      avatar making the request.					)
(    OFFSET  location of substring withing string.			)
(    LEN     length of substring.					)
(									)
( If string is no longer available, return block is [ nil nil |		)
( If access is refused, return block is [ nil t |			)
( Otherwise, return block is   [ OK TYP LEN chars |   where:		)
(    OK	     T or NIL per whether substring read was permitted.		)
(    TYP     mime text type of string: "plain" or "html" or "vrml" ...	)
(    LEN     length of entire string.					)
(    chars   Zero or more chars comprising requested substring		)
( Number of chars returned may be less than requested, either because	)
( more were not available, or because server chooses not to supply	)
( more than some maximum per request.					)

defgeneric: getStringSegment {[ $     $   $  $  $  ]} ;
defmethod:  getStringSegment { 't    't  't 't 't   } ;
defmethod:  getStringSegment { 'home 't  't 't 't   }
    |shift -> us
    |shift -> id
    |shift -> av
    |shift -> offset
    |shift -> reqlen
    ]pop

    ( Sanity checks: )
    id integer? not if
        [ "strId must be an integer" nil nil | return
    fi

    ( Find string with given id: )
    us.pubLock withLockDo{
	us.pubId  -> ids
	ids length -> len
	for w from 0 below len do{
	    ids[w] id = until
	}
	w len = if
            [ "strId expired" nil nil | return
        fi

	( Fetch string info: )
	us.pubLen[w]      -> strlen
	us.pubString[w]   -> str
	us.pubMimetype[w] -> typ
	us.pubFn[w]       -> fn
	us.pubFa[w]       -> fa
    }

    ( Maybe check permissions: )
    fn if 
	[ fa av | fn call{ [] -> [] } ]-> ok
        ok not if [ "read permission refused" t nil |
            return
        fi
    fi

    ( Fetch requested substring, or an approximation: )
    reqlen us.pubMaxSubstring > if us.pubMaxSubstring -> reqlen fi   
    offset strlen > if
        [ nil typ strlen | return
    fi
    offset reqlen + strlen > if strlen offset - -> reqlen fi
    str offset offset reqlen + substring[
        strlen |unshift
        typ    |unshift
        nil    |unshift
    return
;
'getStringSegment export

( =====================================================================	)
( - unpublishString -- Delete string with given id.			)

defgeneric: unpublishString {[ $     $  ]} ;
defmethod:  unpublishString { 't    't   } ;
defmethod:  unpublishString { 'home 't   }
    {[                         'us   'id ]}

    ( Sanity check: )
    id integer? not if [ nil | return fi

    ( Find string with given id: )
    us.pubLock withLockDo{
	us.pubId    -> ids
	ids length -> len
	for w from 0 below len do{
	    ids[w] id = until
	}
	w len = if [ nil | return fi

	( Delete selected string: )
	us.pubLen[w] -> len

	us.pubId      w deleteBth
	us.pubLen     w deleteBth
	us.pubString  w deleteBth
	us.pubFn      w deleteBth
	us.pubFa      w deleteBth

        us.pubNowBytes len - --> us.pubNowBytes
    }

    [ t |
;
'unpublishString export

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

