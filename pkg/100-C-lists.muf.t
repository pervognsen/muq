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

( - 100-C-lists.muf -- Core Lisp-inspired functions on Lists.		)
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
(		For Firiss:  Aefrit, a friend.				)
(									)
(  -------------------------------------------------------------------  )

(  -------------------------------------------------------------------  )
( Author:       Jeff Prothero						)
( Created:      94Nov05							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1995, by Jeff Prothero.				)
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
(  -------------------------------------------------------------------	)

( =====================================================================	)
( - Epigram.								)

( Internet is the question;                               		)
( Muq is the answer. *grin*                                    		)

( =====================================================================	)

( - Public fns								)

"muf" inPackage

( =====================================================================	)
( - ] -- Construct a list.						)
( : ] { -> ] ! } )

(    nil    -> result )
(    do{ )
(        dup [? until )
(	result cons -> result )
(    } )
(    pop )

(    result )
( ;  )
( '] export )

( =====================================================================	)
( - ]l -- Construct a list.						)
: ]l { -> ] ! }

    nil    -> result
    do{
        dup [? until
	result cons -> result
    }
    pop

    result
;
']l export

( =====================================================================	)
( - ] -- Construct a vector.						)
:   ] { -> ] ! }
    depth -> n
    for i from 1 upto n do{
	i dupNth [? if
	    i 1 - -> size
	    0  size  makeVector -> v
	    size 1 - -> lim
	    for j from lim downto 0 do{
		--> v[j]
	    }
	    pop
	    v return
	fi
    }
;
'] export

( =====================================================================	)
( - ]i08 -- Construct a vector of uchars.				)
:   ]i08 { -> ] ! }
    depth -> n
    for i from 1 upto n do{
	i dupNth [? if
	    i 1 - -> size
	    0  size  makeVectorI08 -> v
	    size 1 - -> lim
	    for j from lim downto 0 do{
		--> v[j]
	    }
	    pop
	    v return
	fi
    }
;
']i08 export

( =====================================================================	)
( - ]i16 -- Construct a vector of shorts.				)
:   ]i16 { -> ] ! }
    depth -> n
    for i from 1 upto n do{
	i dupNth [? if
	    i 1 - -> size
	    0  size  makeVectorI16 -> v
	    size 1 - -> lim
	    for j from lim downto 0 do{
		--> v[j]
	    }
	    pop
	    v return
	fi
    }
;
']i16 export

( =====================================================================	)
( - ]i32 -- Construct a vector of ints.					)
:   ]i32 { -> ] ! }
    depth -> n
    for i from 1 upto n do{
	i dupNth [? if
	    i 1 - -> size
	    0  size  makeVectorI32 -> v
	    size 1 - -> lim
	    for j from lim downto 0 do{
		--> v[j]
	    }
	    pop
	    v return
	fi
    }
;
']i32 export

( =====================================================================	)
( - ]f32 -- Construct a vector of floats.				)
:   ]f32 { -> ] ! }
    depth -> n
    for i from 1 upto n do{
	i dupNth [? if
	    i 1 - -> size
	    0.0  size  makeVectorF32 -> v
	    size 1 - -> lim
	    for j from lim downto 0 do{
		--> v[j]
	    }
	    pop
	    v return
	fi
    }
;
']f32 export

( =====================================================================	)
( - ]f64 -- Construct a vector of doubles.				)
:   ]f64 { -> ] ! }
    depth -> n
    for i from 1 upto n do{
	i dupNth [? if
	    i 1 - -> size
	    0.0  size  makeVectorF64 -> v
	    size 1 - -> lim
	    for j from lim downto 0 do{
		--> v[j]
	    }
	    pop
	    v return
	fi
    }
;
']f64 export

( =====================================================================	)
( - append -- Append two lists.						)
: append   { $ $ -> $ }   -> b   -> a

    a list? not
    b list? not
        or if "append args must be lists" simpleError
    fi

    a not if b return fi

    ( Copy all the cons cells in 'a': )
    a car   b   cons -> result  ( We'll return this. )
    result           -> prev	( Last cell copied.  )
    a cdr            -> this	( Next cell to copy. )	
    do{
	( Done if no more cells to copy from 'a': )
        this while

	( Make copy 'c' of 'this': )
	this car   b   cons   -> c

	( Append 'c' to accumulating copy of 'a': )
	prev c rplacd

	( Step to next cell: )
	c        -> prev
        this cdr -> this
    }

    result
;
'append export

( =====================================================================	)
( - assoc -- Search an association list.				)
: assoc  { $ $ -> $ }   -> list   -> key

    do{
	( Done if no more cells to check: )
        list while

	( Done if key matches: )
        list car -> this
        this car    key =   if this return fi

	( Step to next cell: )
        list cdr -> list
    }

    nil
;
'assoc export

( =====================================================================	)
( - rassoc -- find Reverse ASSOCiation in an association list.		)
: rassoc  { $ $ -> $ }   -> list   -> val

    do{
	( Done if no more cells to check: )
        list while

	( Done if val matches: )
        list car -> this
        this cdr    val =   if this return fi

	( Step to next cell: )
        list cdr -> list
    }

    nil
;
'rassoc export

( =====================================================================	)
( - caar &tc -- compositions of up to four car or cdr functions.	)

: caar    car car         ; 'caar   export
: cadr    car cdr         ; 'cadr   export
: cdar    cdr car         ; 'cdar   export
: cddr    cdr cdr         ; 'cddr   export

: caaar   car car car     ; 'caaar  export
: caadr   car car cdr     ; 'caadr  export
: cadar   car cdr car     ; 'cadar  export
: caddr   car cdr cdr     ; 'caddr  export
: cdaar   cdr car car     ; 'cdaar  export
: cdadr   cdr car cdr     ; 'cdadr  export
: cddar   cdr cdr car     ; 'cddar  export
: cdddr   cdr cdr cdr     ; 'cdddr  export

: caaaar  car car car car ; 'caaaar export
: caaadr  car car car cdr ; 'caaadr export
: caadar  car car cdr car ; 'caadar export
: caaddr  car car cdr cdr ; 'caaddr export

: cadaar  car cdr car car ; 'cadaar export
: cadadr  car cdr car cdr ; 'cadadr export
: caddar  car cdr cdr car ; 'caddar export
: cadddr  car cdr cdr cdr ; 'cadddr export

: cdaaar  cdr car car car ; 'cdaaar export
: cdaadr  cdr car car cdr ; 'cdaadr export
: cdadar  cdr car cdr car ; 'cdadar export
: cdaddr  cdr car cdr cdr ; 'cdaddr export

: cddaar  cdr cdr car car ; 'cddaar export
: cddadr  cdr cdr car cdr ; 'cddadr export
: cdddar  cdr cdr cdr car ; 'cdddar export
: cddddr  cdr cdr cdr cdr ; 'cddddr export

( =====================================================================	)
( - second third fourth ... -- Get item from a list.			)
( first is implemented in muf.c )
: second  cdr car ;   'second export
: third   cdr cdr car ;   'third export
: fourth  cdr cdr cdr car ;   'fourth export
: fifth   cdr cdr cdr cdr car ;   'fifth export
: sixth   cdr cdr cdr cdr cdr car ;   'sixth export
: seventh cdr cdr cdr cdr cdr cdr car ;   'seventh export
: eighth  cdr cdr cdr cdr cdr cdr cdr car ;   'eighth export
: ninth   cdr cdr cdr cdr cdr cdr cdr cdr car ;   'ninth export
: tenth   cdr cdr cdr cdr cdr cdr cdr cdr cdr car ;   'tenth export

( =====================================================================	)
( - nthcdr -- Return nth cons cell from a list.				)
: nthcdr  { $ $ -> $ }   -> list   -> n
    for i from 0 below n do{ list cdr -> list }
    list
;
'nthcdr export

( =====================================================================	)
( - nth -- Return nth val from a list.					)
: nth nthcdr car ;   'nth export

( =====================================================================	)
( - copyAlist -- Copy an association list.				)
: copyAlist  { $ -> $ }   -> list

    ( Need to specialCase nil list: )
    list null? if nil return fi

    "copyAlist: invalid association list." -> errmsg

    ( Sanity checks: )
    list    cons? not if errmsg simpleError fi
    list car -> listcar
    listcar cons? not if errmsg simpleError fi

    ( Construct first return keyval pair: )
    listcar car   listcar cdr   cons   -> copycar
    copycar nil cons -> result

    ( Duplicate remainder of alist: )
    result -> tail
    do{
        list cdr -> list
	list cons? while
        list car -> listcar
        listcar cons? not if errmsg simpleError fi
        listcar car   listcar cdr   cons   -> copycar
        copycar nil cons -> temp
	tail temp rplacd
	temp -> tail
    }

    result
;
'copyAlist export

( =====================================================================	)
( - copyList -- Copy top level of a list.				)
: copyList  { $ -> $ }   -> list

    ( Need to specialCase nil list: )
    list null? if nil return fi

    ( Sanity check: )
    list cons? not if "copyList arg must be a list." simpleError fi

    ( Construct first cell of return value: )
    list car   nil   cons -> result

    ( Duplicate remainder of list: )
    result -> tail
    do{
        list cdr -> list
	list cons? while
        list car   nil   cons -> temp
	tail temp rplacd
	temp -> tail
    }

    result
;
'copyList export

( =====================================================================	)
( - copyTree -- Copy all contiguously reachable cons cells.		)
: copyTree  { $ -> $ ! }   -> list   ( Need '!' because of recursion. )

    ( Leaf case in recursion: )
    list cons? not if list return fi

    ( Construct first cell of return value: )
    list car copyTree   nil   cons -> result

    ( Duplicate remainder of list: )
    result -> tail
    do{
        list cdr -> list
	list cons? while
        list car copyTree   nil   cons -> temp
	tail temp rplacd
	temp -> tail
    }

    result
;
'copyTree export

( =====================================================================	)
( - listDelete -- Destructively remove an item from a list.		)
:   listDelete  { $ $ -> $ }   -> list   -> key

    ( This function is called by the 'delete' )
    ( prim if the second argument is a list.  )         

    ( Step past all leading instances of 'key': )
    do{
        list cons?     while
        list car key = while
        list cdr -> list
    }

    ( Need to specialCase nil list: )
    list null? if nil return fi

    ( Remember return value: )
    list -> result

    ( Splice out all remaining instances of 'key': )
    list     -> prev
    list cdr -> list
    do{
        list while
	list car key = if
	    list cdr -> list
	    prev list rplacd
	else
	    list     -> prev
	    list cdr -> list
	fi
    }

    result
;
'delete export

( =====================================================================	)
( - deleteIf -- Destructively remove items from a list.			)
: deleteIf  { $ $ -> $ }   -> list   -> fn

    ( Step past all vals satisfying 'fn': )
    do{
        list cons?                 while
        list car fn call{ $ -> $ } while
        list cdr -> list
    }

    ( Need to specialCase nil list: )
    list null? if nil return fi

    ( Remember return value: )
    list -> result

    ( Splice out all remaining vals satisfying 'fn': )
    list     -> prev
    list cdr -> list
    do{
        list while
	list car fn call{ $ -> $ } if
	    list cdr -> list
	    prev list rplacd
	else
	    list     -> prev
	    list cdr -> list
	fi
    }

    result
;
'deleteIf export

( =====================================================================	)
( - deleteIfNot -- Destructively remove items from a list.		)
: deleteIfNot  { $ $ -> $ }   -> list   -> fn

    ( Step past all vals not satisfying 'fn': )
    do{
        list cons?                 while
        list car fn call{ $ -> $ } until
        list cdr -> list
    }

    ( Need to specialCase nil list: )
    list null? if nil return fi

    ( Remember return value: )
    list -> result

    ( Splice out all remaining vals not satisfying 'fn': )
    list     -> prev
    list cdr -> list
    do{
        list while
	list car fn call{ $ -> $ } not if
	    list cdr -> list
	    prev list rplacd
	else
	    list     -> prev
	    list cdr -> list
	fi
    }

    result
;
'deleteIfNot export

( =====================================================================	)
( - equal -- Compare lists by value.					)
: equal  { $ $ -> $ ! }   -> b   -> a   ( '!' needed because of recursion )

    do{
	a cons? not if a b = return fi
	b cons? not if a b = return fi

	a car   b car   equal   not if nil return fi

        a cdr -> a
        b cdr -> b
    }
;
'equal export

( =====================================================================	)
( - getprop -- Get a property from a symbol's property list.		)
: getprop   { $ $ -> $ }   -> key   -> sym

    sym symbol? not if
        "getprop arg must be symbol" simpleError
    fi

    sym symbolPlist -> this

    do{
        this cons? while
        this cdr -> next
	next cons? while
	this car key = if
	    next car return
	    return
	fi
	next cdr -> this
    }

    nil
;
'getprop export

( =====================================================================	)
( - listLength -- Compute length of possibly circular list.		)
: listLength { $ -> $ }   -> list

    list -> rat	( Steps one cons every       cycle. )
    list -> cat ( Steps one cons every other cycle. )
    0    -> len ( Length of list.                   )
    do{
        rat cons? while
	len 1 + -> len
	rat cdr -> rat
	rat cat = if nil return fi	( Circular list. )

        rat cons? while
	len 1 + -> len
	rat cdr -> rat
	cat cdr -> cat
	rat cat = if nil return fi	( Circular list. )
    }

    len
;
'listLength export

( =====================================================================	)
( - length -- Compute length of list/string/stack...			)
: length { $ -> $ }   -> list

    ( We want to compute the length of a list in a  )
    ( muf loop because this may take an arbitrarily )
    ( long time, and we don't want the interpreter  )
    ( locked up in a C loop for an indefinite time: )
    list list? if list listLength return fi

    ( Length of anything else can be computed using )
    ( constant time, so we use a C-coded primitive: )
    list length2
;
'length export


( =====================================================================	)
( - last -- Return last N conses in a list.				)
: last { $ $ -> $ }   -> n   -> list

    list list? not if "last: 'list' must be a list."       simpleError fi
    list listLength -> len
    len not if        "last: Can't handle circular lists." simpleError fi
    n len >= if list return fi
    n 0 <   if        "last: 'n' must be nonnegative."     simpleError fi

    ( N==0 means return terminating atom in list: )
    n 0 = if
        do{
	    list cons? not if list return fi
	    list cdr -> list
	}
    fi

    ( Main case, 0 < n < len: )
    for i from n below len do{ list cdr -> list }

    list
;
'last export

( =====================================================================	)
( - member? -- Find an entry in a list.					)
: member?  { $ $ -> $ }   -> list   -> val
    list listfor v c do{ v val = if c return fi }
    nil
;
'member? export

( =====================================================================	)
( - nconc -- DESTRUCTIVELY append two lists.				)
: nconc   { $ $ -> $ }   -> b   -> a

    a list?
    b list?
    and not if
        "nconc args must be lists" simpleError
    fi

    a not if b return fi

    ( Find the last cell in 'a': )
    a -> last
    do{
        last cdr -> next
	next cons? while
        next -> last
    }

    ( Point last cell in 'a' to 'b': )
    last b rplacd
    
    a
;
'nconc export

( =====================================================================	)
( - nreverse -- Destructively reverse a list.				)
: nreverse   { $ -> $ }   -> list

    list cons? not if list return fi
    nil -> prev
    do{
        list cdr -> next
        list prev rplacd
        next cons? while
        list -> prev
	next -> list
    }
    list
;
'nreverse export

( =====================================================================	)
( - nsublis -- Destructively substitute alist values in a tree.		)
: nsublis { $ $ -> $ ! }   -> list   -> alist   ( '!' for recursion )
    list -> result
    do{
	list cons? while
        list car -> listcar
	listcar cons? if alist listcar nsublis -> listcar fi
        listcar alist assoc -> cell
        cell if   list   cell cdr   rplaca fi
	list cdr -> list
    }
    result
;
'nsublis export

( =====================================================================	)
( - nsubst -- Destructively substitute values in a tree.		)
: nsubst { $ $ $ -> $ ! }   -> list   -> old   -> new ( '!' for recursion )
    list -> result
    do{
	list cons? while
        list car -> listcar
	listcar cons? if new old listcar nsubst -> listcar fi
        listcar old = if list new rplaca fi
	list cdr -> list
    }
    result
;
'nsubst export

( =====================================================================	)
( - nsubstIf -- Destructively substitute values in a tree.		)
: nsubstIf { $ $ $ -> $ ! }   -> list   -> fn   -> new  ( '!' for recursion )
    list -> result
    do{
	list cons? while
        list car -> listcar
	listcar cons? if
            new fn listcar nsubstIf -> listcar
	else
            listcar fn call{ $ -> $ } if list new rplaca fi
        fi
	list cdr -> list
    }
    result
;
'nsubstIf export

( =====================================================================	)
( - nsubstIfNot -- Destructively substitute values in a tree.		)
: nsubstIfNot { $ $ $ -> $ ! }   -> list   -> fn   -> new ( '!': recursion )
    list -> result
    do{
	list cons? while
        list car -> listcar
	listcar cons? if
            new fn listcar nsubstIfNot -> listcar
	else
            listcar fn call{ $ -> $ } not if list new rplaca fi
        fi
	list cdr -> list
    }
    result
;
'nsubstIfNot export

( =====================================================================	)
( - printList -- Produce a printable representation of a list.		)
: printList { $ -> $ ! } -> list  ( '!' for recursion )
    [   "[ "
        list listfor e do{
	    e   e cons? if printList else toDelimitedString fi
            " "
        }
        "]l"
    | ]join
;
'printList export

( =====================================================================	)
( - putprop -- Add a property to a symbol's property list.		)
: putprop   { $ $ $ -> }   -> key   -> val   -> sym

    sym symbol? not if
        "putprop arg must be symbol" simpleError
    fi

    sym symbolPlist -> plist

    ( If 'key' is already on the )
    ( property list, just change )
    ( the associated value:      )
    plist -> this
    do{
        this cons? while
        this cdr -> next
	next cons? while
	this car key = if
	    next val rplaca
	    return
	fi
	next cdr -> this
    }

    ( Add a new keyVal entry: )
    val plist cons -> plist
    key plist cons -> plist

    plist sym setSymbolPlist
;
'putprop export

( =====================================================================	)
( - remove -- Nondestructively remove an item from a list.		)
: remove  { $ $ -> $ }   -> list   -> key

    ( Step past all leading instances of 'key': )
    do{
        list cons?     while
        list car key = while
        list cdr -> list
    }

    ( Need to specialCase nil list: )
    list null? if nil return fi

    ( Remember return value: )
    list car   nil   cons   -> result

    ( Copy all remaining cells not containing 'key': )
    result   -> prev
    list cdr -> list
    do{
        list while
	list car -> keyx
	keyx key = if
	    list cdr -> list
	else
	    keyx nil cons -> this
	    prev this rplacd
	    this     -> prev
	    list cdr -> list
	fi
    }

    result
;
'remove export

( =====================================================================	)
( - removeIf -- Nondestructively remove items from a list.		)
: removeIf  { $ $ -> $ }   -> list   -> fn

    ( Step past all elements satisfying 'fn': )
    do{
        list cons?     while
        list car fn call{ $ -> $ } while
        list cdr -> list
    }

    ( Need to specialCase nil list: )
    list null? if nil return fi

    ( Remember return value: )
    list car   nil   cons   -> result

    ( Copy all remaining cells not satisfying 'fn': )
    result   -> prev
    list cdr -> list
    do{
        list while
	list car -> keyx
	keyx fn call{ $ -> $ } if
	    list cdr -> list
	else
	    keyx nil cons -> this
	    prev this rplacd
	    this     -> prev
	    list cdr -> list
	fi
    }

    result
;
'removeIf export



( =====================================================================	)
( - removeIfNot -- Nondestructively remove items from a list.		)
: removeIfNot  { $ $ -> $ }   -> list   -> fn

    ( Step past all elements not satisfying 'fn': )
    do{
        list cons?                 while
        list car fn call{ $ -> $ } until
        list cdr -> list
    }

    ( Need to specialCase nil list: )
    list null? if nil return fi

    ( Remember return value: )
    list car   nil   cons   -> result

    ( Copy all remaining cells satisfying 'fn': )
    result   -> prev
    list cdr -> list
    do{
        list while
	list car -> keyx
	keyx fn call{ $ -> $ } not if
	    list cdr -> list
	else
	    keyx nil cons -> this
	    prev this rplacd
	    this     -> prev
	    list cdr -> list
	fi
    }

    result
;
'removeIfNot export

( =====================================================================	)
( - remprop -- Remove a property from a symbol's property list.		)
: remprop   { $ $ -> }   -> key   -> sym

    sym symbol? not if
        "remprop arg must be symbol" simpleError
    fi

    sym symbolPlist -> this

    ( Specialcase null property list: )
    this null? if return fi
    this cdr -> next
    next null? if return fi

    ( Specialcase first property: )
    this car key = if
        next cdr sym setSymbolPlist
	return
    fi

    ( Search rest of list: )
    next     -> prev
    prev cdr -> this
    do{
        this cons? while
        this cdr -> next
	next cons? while
	this car key = if
	    prev   next cdr   rplacd
	    return
	fi
	next     -> prev
	next cdr -> this
    }
;
'remprop export

( =====================================================================	)
( - reverse -- Nondestructively reverse a list.				)
: reverse   { $ -> $ }   -> list

    nil -> result
    do{
        list cons? while
        list car   result   cons   -> result
        list cdr -> list
    }
    result
;
'reverse export

( =====================================================================	)
( - sublis -- Nondestructively substitute alist values in a tree.	)
: sublis { $ $ -> $ ! }   -> list   -> alist  ( '!' for recursion )

    ( Leaf case in recursion: )
    list cons? not if
        list alist assoc -> cell
        cell if cell cdr else list fi    return
    fi

    ( Construct first cell of return value: )
    alist list car sublis   nil   cons -> result

    ( Duplicate remainder of list: )
    result -> tail
    do{
        list cdr -> list
	list cons? while
        alist list car sublis   nil   cons -> temp
	tail temp rplacd
	temp -> tail
    }

    result
;
'sublis export

( =====================================================================	)
( - subseq -- Copy a sublist of given list.				)
: subseq { $ $ $ -> $ }   -> end   -> start   -> list

    start integer? not if
        "subseq: 'start' must be an integer" simpleError
    fi
    end   integer? not if
          "subseq: 'end' must be an integer" simpleError
    fi
    list list? not if
             "subseq: 'list' must be a list" simpleError
    fi

    ( This will work with circular lists: )
    0   -> loc
    nil -> result
    list listfor e do{

	loc end < while

        loc start = if
            e nil cons -> result
	    result     -> tail
	fi

	loc start > if
	    e nil cons -> temp
	    tail temp rplacd
	    temp -> tail
	fi

        loc 1 + -> loc
    }

    loc end   = if
	result return
    fi

    "subseq: list was too short" simpleError
;
'subseq export

( =====================================================================	)
( - subst -- Nondestructively substitute values in a tree.		)
: subst { $ $ $ -> $ ! }   -> list   -> old   -> new ( '!' for recursion )

    ( Leaf case in recursion: )
    list cons? not if
        list old =    if new else list fi    return
    fi

    ( Construct first cell of return value: )
    new old list car subst   nil   cons -> result

    ( Duplicate remainder of list: )
    result -> tail
    do{
        list cdr -> list
	list cons? while
        new old list car subst   nil   cons -> temp
	tail temp rplacd
	temp -> tail
    }

    result
;
'subst export

( =====================================================================	)
( - substIf -- Nondestructively substitute values in a tree.		)
: substIf { $ $ $ -> $ ! }   -> list   -> fn   -> new ( '!' for recursion )

    ( Leaf case in recursion: )
    list cons? not if
        list fn call{ $ -> $ }    if new else list fi    return
    fi

    ( Construct first cell of return value: )
    new fn list car substIf   nil   cons -> result

    ( Duplicate remainder of list: )
    result -> tail
    do{
        list cdr -> list
	list cons? while
        new fn list car substIf   nil   cons -> temp
	tail temp rplacd
	temp -> tail
    }

    result
;
'substIf export

( =====================================================================	)
( - substIfNot -- Nondestructively substitute values in a tree.		)
: substIfNot { $ $ $ -> $ ! }   -> list   -> fn   -> new ( '!': recursion )

    ( Leaf case in recursion: )
    list cons? not if
        list fn call{ $ -> $ }   if list else new fi    return
    fi

    ( Construct first cell of return value: )
    new fn list car substIfNot   nil   cons -> result

    ( Duplicate remainder of list: )
    result -> tail
    do{
        list cdr -> list
	list cons? while
        new fn list car substIfNot   nil   cons -> temp
	tail temp rplacd
	temp -> tail
    }

    result
;
'substIfNot export

( =====================================================================	)
( - mapc -- Apply a function to successive CARs of N lists.		)

: mapc { [] $ -> ! } -> fn

    ( Do preliminary pass to see if )
    ( any argument is NIL or !cons: )
    |for e do{
        e list? not if "mapc: all args must be lists" simpleError fi
        e null? if ]pop return fi
    }

    ( Until one list goes null: )
    t -> notDone
    do{  notDone while

        ( Push one element from each list: )
	|for e do{

	    ( Push one element from this list: )
	    e car

	    ( Advance down this list: )
	    e cdr -> e

	    ( If that was last element in this list, )
            ( remember that this is last iteration:  )
	    e cons?   notDone   and   -> notDone
	}

	( Call the function on the list: )
	fn call{ -> ? }
    }
    ]pop
;
'mapc export

( =====================================================================	)
( - mapcan -- Same, NCONC results together.				)

: mapcan { [] $ -> $ ! } -> fn

    ( Do preliminary pass to see if )
    ( any argument is NIL or !cons: )
    |for e do{
        e list? not if "mapcan: all args must be lists" simpleError fi
        e null? if ]pop nil return fi
    }

    ( Until one list goes null: )
    nil -> result
    t   -> notDone
    do{  notDone while

        ( Push one element from each list: )
	|for e do{

	    ( Push one element from this list: )
	    e car

	    ( Advance down this list: )
	    e cdr -> e

	    ( If that was last element in this list, )
            ( remember that this is last iteration:  )
	    e cons?   notDone   and   -> notDone
	}

	( Call the function on the list: )
	fn call{ -> ? }   result swap nconc -> result
    }
    ]pop
    result
;
'mapcan export

( =====================================================================	)
( - mapcar -- Same, LIST results together.				)

: mapcar { [] $ -> $ ! } -> fn

    ( Do preliminary pass to see if )
    ( any argument is NIL or !cons: )
    |for e do{
        e list? not if "mapcar: all args must be lists" simpleError fi
        e null? if ]pop nil return fi
    }

    ( Until one list goes null: )
    nil -> result
    nil -> tail
    t   -> notDone
    do{  notDone while

        ( Push one element from each list: )
	|for e do{

	    ( Push one element from this list: )
	    e car

	    ( Advance down this list: )
	    e cdr -> e

	    ( If that was last element in this list, )
            ( remember that this is last iteration:  )
	    e cons?   notDone   and   -> notDone
	}

	( Call the function on the list: )
	fn call{ -> ? }    -> fnResult
        fnResult nil cons -> newTail
        tail if
            tail newTail rplacd
        else
            newTail -> result
        fi
        newTail -> tail        
    }
    ]pop
    result
;
'mapcar export

( =====================================================================	)
( - mapl -- Apply a function to successive cons cells of N lists.	)

: mapl { [] $ -> ! } -> fn

    ( Do preliminary pass to see if )
    ( any argument is NIL or !cons: )
    |for e do{
        e list? not if "mapl: all args must be lists" simpleError fi
        e null? if ]pop return fi
    }

    ( Until one list goes null: )
    t -> notDone
    do{  notDone while

        ( Push one element from each list: )
	|for e do{

	    ( Push one cons cell from this list: )
	    e

	    ( Advance down this list: )
	    e cdr -> e

	    ( If that was last element in this list, )
            ( remember that this is last iteration:  )
	    e cons?   notDone   and   -> notDone
	}

	( Call the function on the list: )
	fn call{ -> ? }
    }
    ]pop
;
'mapl export

( =====================================================================	)
( - maplist -- Same, LIST results together.				)

: maplist { [] $ -> ! } -> fn

    ( Do preliminary pass to see if )
    ( any argument is NIL or !cons: )
    |for e do{
        e list? not if "maplist: all args must be lists" simpleError fi
        e null? if ]pop nil return fi
    }

    ( Until one list goes null: )
    t   -> notDone
    nil -> result
    nil -> tail
    do{  notDone while

        ( Push one element from each list: )
	|for e do{

	    ( Push one cons cell from this list: )
	    e

	    ( Advance down this list: )
	    e cdr -> e

	    ( If that was last element in this list, )
            ( remember that this is last iteration:  )
	    e cons?   notDone   and   -> notDone
	}

	( Apply the function to the arguments: )
	fn call{ -> ? }   -> fnResult

	( Add fnResult to result list: )
        fnResult nil cons   ->  newTail
	tail if
	    tail newTail rplacd
        else
	    newTail -> result
        fi
        newTail -> tail
    }
    ]pop

    result
;
'maplist export

( =====================================================================	)
( - mapcon -- Same, NCONC results together.				)

: mapcon { [] $ -> ! } -> fn

    ( Do preliminary pass to see if )
    ( any argument is NIL or !cons: )
    |for e do{
        e list? not if "mapcon: all args must be lists" simpleError fi
        e null? if ]pop nil return fi
    }

    ( Until one list goes null: )
    t   -> notDone
    nil -> result
    do{  notDone while

        ( Push one element from each list: )
	|for e do{

	    ( Push one cons cell from this list: )
	    e

	    ( Advance down this list: )
	    e cdr -> e

	    ( If that was last element in this list, )
            ( remember that this is last iteration:  )
	    e cons?   notDone   and   -> notDone
	}

	( Call the function on the list: )
	fn call{ -> ? }   -> fnResult

        result fnResult nconc -> result
    }
    ]pop

    result
;
'mapcon export

( =====================================================================	)
( - product -- Product of elements in a vector.				)
:   product { $ -> $ }
    -> v

    1 -> p
    v length2 -> i
    do{ -- i   i 0 < until
	v[i] p * -> p
    }

    p
;
'product export

( =====================================================================	)
( - sum -- Sum of elements in a vector.					)
:   sum { $ -> $ }
    -> v

    0 -> s
    v length2 -> i
    do{ -- i   i 0 < until
	v[i] s + -> s
    }

    s
;
'sum export

( =====================================================================	)
( - union -- Union of two Index or Set objects.				)
:   union { $ $ -> $ }
    -> b
    -> a

    a set?
    b set?
    and if   makeSet   -> c
    else     makeIndex -> c fi

    b foreach key val do{ val --> c[key] }
    a foreach key val do{ val --> c[key] }

    b foreachHidden key val do{ val --> c$hidden[key] }
    a foreachHidden key val do{ val --> c$hidden[key] }

    c
;
'union export

( =====================================================================	)
( - intersection -- Intersection of two Index or Set objects.		)
:   intersection { $ $ -> $ }
    -> b
    -> a

    a set?
    b set?
    and if   makeSet   -> c
    else     makeIndex -> c fi

    a set? if

	b foreach key val do{
	    a key get? swap pop  if  val --> c[key]   fi
	}

	b foreachHidden key val do{
	    a key hiddenGet? swap pop  if  val --> c$hidden[key]   fi
	}
    else
	b foreach key val do{
	    a key get? -> val  if  val --> c[key]   fi
	}

	b foreachHidden key val do{
	    a key hiddenGet? -> val  if  val --> c$hidden[key]   fi
	}
    fi

    c
;
'intersection export

( =====================================================================	)
( - setDifference -- Set difference of two Index or Set objects.	)
:   setDifference { $ $ -> $ }
    -> b
    -> a

    a set?
    b set?
    and if   makeSet   -> c
    else     makeIndex -> c fi

    a set? if

	a foreach key val do{
	    b key get? swap pop not if  val --> c[key]   fi
	}

	a foreachHidden key val do{
	    b key hiddenGet? swap pop not if  val --> c$hidden[key]   fi
	}
    else
	a foreach key val do{
	    b key get? pop not  if  val --> c[key]   fi
	}

	a foreachHidden key val do{
	    b key hiddenGet? pop not  if  val --> c$hidden[key]   fi
	}
    fi

    c
;
'setDifference export


( =====================================================================	)
( - ]index -- Create an Index from a block.				)
:   ]index   { [] -> $ }
    makeIndex -> s
    |forPairs k v do{ v --> s[k] }
    ]pop
    s
;
']index export

( =====================================================================	)
( - ]set -- Create a Set from a block.					)
:   ]set   { [] -> $ }
    makeSet -> s
    |for k do{ t --> s[k] }
    ]pop
    s
;
']set export

( =====================================================================	)

( - coming soon! :) )
( sublis )
( subseq )
( subst )

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
 
@end example
