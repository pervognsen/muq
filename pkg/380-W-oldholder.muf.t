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

( - 380-W-oldholder.muf -- Containers for rooms-and-exits islekit.	)
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
( Created:      97Jul10, from 33-W-oldmud.t				)
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
( - Package 'oldmud' --							)

"oldmud" inPackage


( =====================================================================	)

( - Functions -								)






( =====================================================================	)

( - Classes -								)

( =====================================================================	)
( - HOLDER and HOLDABLE -- Mixins for container/contained objects.	)

( 'holding' is used by rooms to contain avatars, avatars to contain	)
( carried goods, &tc.	In our model, an object A is considered to be	)
( contained in another object B only if both agree:  A must be HOLDING	)
( B -and- B must be HELD-BY A.						)
(									)  
( Note that in our model, an object may be HELD-BY more than one	)
( other object.  For example, we allow an avatar to be in more than	)
( one room at a time.							)
(									)  
( The value of the :HOLDING and :HELD-BY slots are both stacks in	)
( general, to allow multiple links, but to reduce db bloat, we do	)
( not create those stacks unless we really need them, and when we	)
( have a single link, we store it directly in the slot instead of	)
( using a stack.							)
(									)  
( We do not restrict holders to holding only holdables, or vice		)  
( versa, partly as an efficiency hack to avoid the roundTrip packet	)
( exchanges which would be needed to verify class type in a distributed	)
( setting, and partly to avoid questions of whether a HOLDABLE mixin	)
( on one server is a good enough approximation to that on another.	)

defclass: holder
    :export  t
    :is 'live
    :slot :holding		:prot "rwr-r-"	:initval nil
;

defclass: holdable
    :export  t
    :is 'live
    :slot :heldBy		:prot "rwr-r-"	:initval nil

    :slot :can   :prot "rwr-r-"   :initval 0	( Sum of CAN-* bitflags	)
    :slot :name  :prot "rwr-r-"   :initval ""	( Name for user display	)
    :slot :short :prot "rwr-r-"   :initval nil	( Short (<32 char) description	)
;

( =====================================================================	)
( - holdIt heldIt -- Per-daemon state for our ]daemon shell.		)

defclass: holdIt
    :export t

    :slot :lastEnholdingTo	     :prot "rw----"
    :slot :lastEnholdingThat         :prot "rw----"

;
defclass: heldIt
    :export t

    :slot :lastEnheldByTo           :prot "rw----"
    :slot :lastEnheldByThat         :prot "rw----"
;



( =====================================================================	)

( - Holder Generic Functions -						)

( =====================================================================	)
( - numberHolding -- Return count of objects held.			)

defgeneric: numberHolding {[ $     ]} ;
defmethod:  numberHolding { 't      } "numberHolding" gripe ;
defmethod:  numberHolding { 'holder }
    {[                      'h     ]}

    h.holding -> n
    n not if
        0 -> count
    else
        n stack? not if
            1 -> count
        else
	    n length -> count
    fi  fi

    [ count |
;
'numberHolding export


( =====================================================================	)
( - nthHolding -- Return nth object being held.				)

defgeneric: nthHolding {[ $       $ ]} ;
defmethod:  nthHolding { 't      't  } "nthHolding" gripe ;
defmethod:  nthHolding { 'holder 't  }
    {[                   'me     'n ]}

    nil -> err
    me.holding -> h
    n integer? not if
        "N must be an integer" -> err
    else
	n 0 < if
            "N must be non-negative" -> err
    fi  fi

    err not if
	h stack? not if
	    n 0 = if
		h    -> val
	    else
		nil  -> val
		"N too big"  -> err
	    fi
	else
	    n   h length >= if
		"N too big" -> err
	    else
	        h[n] -> val
	    fi
	fi
    fi

    [ err val |
;
'nthHolding export

( =====================================================================	)

( - Holder Server Functions -						)

( =====================================================================	)
( - dontEnhold -- Decide whether to accept an object.			)

( This generic implements policy as to which objects			)
( are willing to hold which other objects.  Default			)
( policy is to accept anything, and may be overridden			)
( be defining new methods:						)

defgeneric: dontEnhold {[ $    $       $  $     ]} ;
defmethod:  dontEnhold { 't   't      't  't     } "dontEnhold" gripe ;
defmethod:  dontEnhold { 't   'holder 't  't     }
    {[                    'who 'me     'av 'that ]}

    [ nil |
;

( =====================================================================	)
( - enhold -- Add object to set being held.				)

:   enhold { $ $ -> }
( .sys.muqPort d, "(380)<" d, @ d, ">enhold/aaa...\n" d, )
    -> that
( .sys.muqPort d, "(380)<" d, @ d, ">enhold that=" d, that d, "\n" d, )
    -> me
( .sys.muqPort d, "(380)<" d, @ d, ">enhold me=" d, me d, "\n" d, )

    ( We avoid creating a stack unless really needed: )
    me.holding -> h
    h not if
( .sys.muqPort d, "(380)<" d, @ d, ">enhold storing that as sole holding\n" d, )
	that --> me.holding
    else
	h stack? if
	    ( Push on stack unless already in it: )
( .sys.muqPort d, "(380)<" d, @ d, ">enhold maybe adding to stack\n" d, )
	    h that getKey? pop not if
( .sys.muqPort d, "(380)<" d, @ d, ">enhold actually adding to stack\n" d, )
		that h push
	    fi
	else
	    h that != if
( .sys.muqPort d, "(380)<" d, @ d, ">enhold making a new stack and adding to it\n" d, )
		makeStack -> s
		h    s push
		that s push
		s --> me.holding
	    fi
	fi
    fi
( .sys.muqPort d, "(380)<" d, @ d, ">enhold/zzz...\n" d, )
;
'enhold export

( =====================================================================	)
( - doReqEnholding -- Add object to set being held.			)

( This operation may be invoked from anywhere.  (I.e., not just our own	)
( user.)  								)

defgeneric: doReqEnholding {[ $       $   $   $   $   $     $   $  ]} ;
defmethod:  doReqEnholding { 't      't  't  't  't  't    't  't   } "doReqEnhold" gripe ;
defmethod:  doReqEnholding { 'holder 't  't  't  't  't    't  't   }
    {[                       'me     'it 'hu 'av 'id 'that 'a1 'a2 ]}
( .sys.muqPort d, "(380)<" d, @ d, ">doReqEnholding/aaa...\n" d, )

    [ hu me av that | dontEnhold ]-> err

    ( Just to avoid confusion: )
    that remote? not if
	that stack?  if
	    "Can't hold a stack." -> err
    fi	fi

    err not if me that enhold fi

    [ err me.can me.name me.short |
( .sys.muqPort d, "(380)<" d, @ d, ">doReqEnholding/zzz...\n" d, )
;
'doReqEnholding export


( =====================================================================	)
( - dontDehold -- Decide whether to release an object.			)

( This generic implements policy as to which objects			)
( are willing to release which other objects.  Default			)
( policy is to release anything, and may be overridden			)
( be defining new methods:						)

defgeneric: dontDehold {[ $    $       $  ]} ;
defmethod:  dontDehold { 't   't      't   } "dontDehold" gripe ;
defmethod:  dontDehold { 't   'holder 't   }
    {[                   'who 'me     'av ]}

    [ nil |
;

( =====================================================================	)
( - deholding -- Remove object from set of held objects.		)

:   deholding { $ $ -> $ }
    -> he
    -> me

    nil -> didDelete

    me.holding -> h
    h stack? if
	h he getKey? -> index if
	    h index deleteBth
	    t -> didDelete
	fi
    else
	h he = if
	    nil --> me.holding
	    t -> didDelete
	fi
    fi

    didDelete
;
'deholding export

( =====================================================================	)
( - doReqDeholding -- Remove object from set being held.		)

( This operation may be invoked from anywhere.  (I.e., not just our own	)
( user.)  								)

defgeneric: doReqDeholding {[ $       $   $   $   $   $   $   $  ]} ;
defmethod:  doReqDeholding { 't      't  't  't  't  't  't  't   } "doReqDehold" gripe ;
defmethod:  doReqDeholding { 'holder 't  't  't  't  't  't  't   }
    {[                       'me     'it 'hu 'av 'id 'he 'a1 'a2 ]}

    [ hu me av | dontDehold ]-> err

    err not if me he deholding -> didDelete fi

    [ err didDelete |
;
'doReqDeholding export


( =====================================================================	)
( - dontListHolding -- Decide whether to release list of objects.	)

( This generic implements policy as to which objects			)
( are willing to release which other objects.  Default			)
( policy is to release anything, and may be overridden			)
( be defining new methods:						)

defgeneric: dontListHolding {[ $    $       $  ]} ;
defmethod:  dontListHolding { 't   't      't   } "dontListHolding" gripe ;
defmethod:  dontListHolding { 't   'holder 't   }
    {[                        'who 'me     'av ]}

    [ nil |
;

( =====================================================================	)
( - doReqNumberHolding -- Return nth object holding us.			)

( This operation may be invoked from anywhere.  (I.e., not just our own	)
( user.)  								)

defgeneric: doReqNumberHolding {[ $       $   $   $   $   $   $   $  ]} ;
defmethod:  doReqNumberHolding { 't      't  't  't  't  't  't  't   } "doReqNumberHolding" gripe ;
defmethod:  doReqNumberHolding { 'holder 't  't  't  't  't  't  't   }
    {[                           'me     'it 'hu 'av 'id 'a0 'a1 'a2 ]}

    [ me | numberHolding
    nil |unshift
;
'doReqNumberHolding export

( =====================================================================	)
( - doReqNthHolding -- Return nth object being held.			)

( This operation may be invoked from anywhere.  (I.e., not just our own	)
( user.)  								)

defgeneric: doReqNthHolding {[ $       $   $   $   $   $   $   $  ]} ;
defmethod:  doReqNthHolding { 't      't  't  't  't  't  't  't   } "doReqNthHolding" gripe ;
defmethod:  doReqNthHolding { 'holder 't  't  't  't  't  't  't   }
    {[                        'me     'it 'hu 'av 'id 'n  'a1 'a2 ]}

    [ hu me av | dontListHolding ]-> err
    err if  [ err nil | return fi
    [ me n | nthHolding
;
'doReqNthHolding export

( =====================================================================	)
( - doReqIsHolding -- Check for set membership.				)

( This operation may be invoked from anywhere.  (I.e., not just our own	)
( user.)  								)

defgeneric: doReqIsHolding {[ $       $   $   $   $   $   $   $  ]} ;
defmethod:  doReqIsHolding { 't      't  't  't  't  't  't  't   } "doReqIsHolding" gripe ;
defmethod:  doReqIsHolding { 'holder 't  't  't  't  't  't  't   }
    {[                       'me     'it 'hu 'av 'id 'he 'a1 'a2 ]}

    nil -> isHolding

    me.holding -> h
    h stack? if
	h he getKey? -> index if
	    t -> isHolding
	fi
    else
	h he = if
	    t -> isHolding
	fi
    fi

    [ nil isHolding |
;
'doReqIsHolding export

( =====================================================================	)
( - enterHoldingServerFunctions -- 					)

:   enterHoldingServerFunctions { $ $ $ -> }
    -> c
    -> f
    -> n
    REQ_ENHOLDING  'doReqEnholding  nil   n f c enterOp
    REQ_DEHOLDING  'doReqDeholding  nil   n f c enterOp
    REQ_IS_HOLDING 'doReqIsHolding nil   n f c enterOp
    REQ_NUMBER_HOLDING 'doReqNumberHolding nil   n f c enterOp
    REQ_NTH_HOLDING 'doReqNthHolding nil   n f c enterOp
;
'enterHoldingServerFunctions export



( =====================================================================	)

( - For now, at least, the heldBy code is exactly identical to above.	)

( =====================================================================	)

( - Holdable Generic Functions -					)

( =====================================================================	)
( - numberHeldBy -- Return count of objects holding us.			)

defgeneric: numberHeldBy {[ $       ]} ;
defmethod:  numberHeldBy { 't        } "numberHeldBy" gripe ;
defmethod:  numberHeldBy { 'holdable }
    {[                     'h       ]}

    h.heldBy -> n
    n not if
        0 -> count
    else
        n stack? not if
            1 -> count
        else
	    n length -> count
    fi  fi

    [ count |
;
'numberHeldBy export


( =====================================================================	)
( - nthHeldBy -- Return nth object being held by.			)

defgeneric: nthHeldBy {[ $       $ ]} ;
defmethod:  nthHeldBy { 't      't  } "nthHeldBy" gripe ;
defmethod:  nthHeldBy { 'holder 't  }
    {[                  'me     'n ]}

    nil -> err
    nil -> val
    me.heldBy -> h
    n integer? not if
        "N must be an integer" -> err
    else
	n 0 < if
            "N must be nonnegative" -> err
    fi  fi

    err not if
	h stack? not if
	    n 0 = if
		h    -> val
		nil  -> err
	    else
		nil  -> val
		"N too large" -> err
	    fi
	else
	    n   h length >= if
		"N too large" -> err
	    else
	        h[n] -> val
	    fi
	fi
    fi

    [ err val |
;
'nthHeldBy export

( =====================================================================	)

( - Holdable Server Functions -						)

( =====================================================================	)
( - dontEnheldBy -- Decide whether to enter an object.			)

( This generic implements policy as to which objects			)
( are willing to be held by which other objects.  Default		)
( policy is to enter anything, and may be overridden			)
( be defining new methods:						)

defgeneric: dontEnheldBy {[ $    $         $  $     ]} ;
defmethod:  dontEnheldBy { 't   't        't  't     } "dontEnheldBy" gripe ;
defmethod:  dontEnheldBy { 't   'holdable 't  't     }
    {[                     'who 'me       'av 'that ]}

    [ nil |
;

( =====================================================================	)
( - enheldBy -- Add object to set of holders.				)

:   enheldBy { $ $ -> }
    -> that
    -> me

    ( We avoid creating a stack unless really needed: )
    me.heldBy -> h
    h not if
	that --> me.heldBy
    else
	h stack? if
	    ( Push on stack unless already in it: )
	    h that getKey? pop not if
		that h push
	    fi
	else
	    h that != if
		makeStack -> s
		h    s push
		that s push
		s --> me.heldBy
	    fi
	fi
    fi
;

( =====================================================================	)
( - doReqEnheldBy -- Add object to set of holders.			)

( This operation may be invoked from anywhere.  (I.e., not just our own	)
( user.)  								)

defgeneric: doReqEnheldBy {[ $         $   $   $   $   $     $   $  ]} ;
defmethod:  doReqEnheldBy { 't        't  't  't  't  't    't  't   } "doReqEnheldBy" gripe ;
defmethod:  doReqEnheldBy { 'holdable 't  't  't  't  't    't  't   }
    {[                      'me       'it 'hu 'av 'id 'that 'a1 'a2 ]}

    [ hu me av that | dontEnheldBy ]-> err

    ( Just to avoid confusion: )
    that remote? not if
	that stack?  if
	    "Can't enheldBy a stack" -> err
    fi	fi

    err not if me that enheldBy fi

    [ err |
;
'doReqEnheldBy export


( =====================================================================	)
( - dontDeheldBy -- Decide whether to release an object.		)

( This generic implements policy as to which objects			)
( are willing to release which other objects.  Default			)
( policy is to release anything, and may be overridden			)
( be defining new methods:						)

defgeneric: dontDeheldBy {[ $    $         $  ]} ;
defmethod:  dontDeheldBy { 't   't        't   } "dontDeheldBy" gripe ;
defmethod:  dontDeheldBy { 't   'holdable 't   }
    {[                     'who 'me       'av ]}

    [ t |
;

( =====================================================================	)
( - deheldBy -- Remove object from set of holders.			)

:   deheldBy { $ $ -> $ }
    -> he
    -> me

    nil -> didDelete

    me.heldBy -> h
    h stack? if
	h he getKey? -> index if
	    h index deleteBth
	    t -> didDelete
	fi
    else
	h he = if
	    nil --> me.heldBy
	    t -> didDelete
	fi
    fi

    didDelete
;
'deheldBy export

( =====================================================================	)
( - doReqDeheldBy -- Remove object from set holding us.			)

( This operation may be invoked from anywhere.  (I.e., not just our own	)
( user.)  								)

defgeneric: doReqDeheldBy {[ $         $   $   $   $   $   $   $  ]} ;
defmethod:  doReqDeheldBy { 't        't  't  't  't  't  't  't   } "doReqDeheldBy" gripe ;
defmethod:  doReqDeheldBy { 'holdable 't  't  't  't  't  't  't   }
    {[                      'me       'it 'hu 'av 'id 'he 'a1 'a2 ]}

    [ hu me av | dontDeheldBy ]-> err
    nil -> didDelete

    err not if me he deheldBy -> didDelete fi

    [ err didDelete |
;
'doReqDeheldBy export

( =====================================================================	)
( - dontListHeldBy -- Decide whether to release list of objects.	)

( This generic implements policy as to which objects			)
( are willing to release which other objects.  Default			)
( policy is to release anything, and may be overridden			)
( be defining new methods:						)

defgeneric: dontListHeldBy {[ $    $       $  ]} ;
defmethod:  dontListHeldBy { 't   't      't   } "dontListHeldBy" gripe ;
defmethod:  dontListHeldBy { 't   'holder 't   }
    {[                       'who 'me     'av ]}

    [ nil |
;

( =====================================================================	)
( - doReqNumberHeldBy -- Return nth object heldBy us.			)

( This operation may be invoked from anywhere.  (I.e., not just our own	)
( user.)  								)

defgeneric: doReqNumberHeldBy {[ $       $   $   $   $   $   $   $  ]} ;
defmethod:  doReqNumberHeldBy { 't      't  't  't  't  't  't  't   } "doReqNumberHeldBy" gripe ;
defmethod:  doReqNumberHeldBy { 'holder 't  't  't  't  't  't  't   }
    {[                          'me     'it 'hu 'av 'id 'a0 'a1 'a2 ]}

    [ me | numberHeldBy
    nil |unshift
;
'doReqNumberHeldBy export

( =====================================================================	)
( - doReqNthHeldBy -- Return nth object heldBy us.			)

( This operation may be invoked from anywhere.  (I.e., not just our own	)
( user.)  								)

defgeneric: doReqNthHeldBy {[ $       $   $   $   $   $   $   $  ]} ;
defmethod:  doReqNthHeldBy { 't      't  't  't  't  't  't  't   } "doReqNthHeldBy" gripe ;
defmethod:  doReqNthHeldBy { 'holder 't  't  't  't  't  't  't   }
    {[                       'me     'it 'hu 'av 'id 'n  'a1 'a2 ]}

    [ hu me av | dontListHeldBy ]-> err
    err if [ err nil |	return fi
    [ me n | nthHeldBy
;
'doReqNthHeldBy export

( =====================================================================	)
( - doReqIsHeldBy -- Check for set membership.				)

( This operation may be invoked from anywhere.  (I.e., not just our own	)
( user.)  								)

defgeneric: doReqIsHeldBy {[ $         $   $   $   $   $   $   $  ]} ;
defmethod:  doReqIsHeldBy { 't        't  't  't  't  't  't  't   } "doReqIsHeldBy" gripe ;
defmethod:  doReqIsHeldBy { 'holdable 't  't  't  't  't  't  't   }
    {[                      'me       'it 'hu 'av 'id 'he 'a1 'a2 ]}

    nil -> isHeldBy

    me.heldBy -> h
    h stack? if
	h he getKey? -> index if
	    t -> isHeldBy
	fi
    else
	h he = if
	    t -> isHeldBy
	fi
    fi

    ( Dig out short description: )
    [ me nil @ av id nil nil nil |
        doReqShortView
        |shift -> err
        |shift -> short
    ]pop
    err               if nil -> short fi
    short string? not if nil -> short fi

    [ nil isHeldBy me.can me.name short | 
;
'doReqIsHeldBy export

( =====================================================================	)
( - enterHeldByServerFunctions -- 					)

:   enterHeldByServerFunctions { $ $ $ -> }
    -> c
    -> f
    -> n

    REQ_ENHELD_BY  'doReqEnheldBy  nil   n f c enterOp
    REQ_DEHELD_BY  'doReqDeheldBy  nil   n f c enterOp
    REQ_IS_HELD_BY 'doReqIsHeldBy nil   n f c enterOp
    REQ_NUMBER_HELD_BY 'doReqNumberHeldBy nil   n f c enterOp
    REQ_NTH_HELD_BY 'doReqNthHeldBy nil   n f c enterOp
;
'enterHeldByServerFunctions export

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example

