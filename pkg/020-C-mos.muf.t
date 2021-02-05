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

( - 020-C-mos.muf -- Core support for the Muq Object System.		)
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
( Created:      96Feb25							)
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
(  -------------------------------------------------------------------	)

( =====================================================================	)
( - Epigram.								)

(   Why do hackers confuse Halloween with Christmas?			)
(   Because OCT 31 == DEC 25.						)
(                                              (Octal 31 == Decimal 25)	)
( =====================================================================	)


( =====================================================================	)

( - Standard classes representing classical lisp types			)

( These are taken from Common Lisp the Language 2nd Ed table 28-1 p783	)

"lisp" inPackage



( =====================================================================	)
( - t		t							)

't export
't.type mosClass? not if
    makeMosClass dup      --> 't.type
    0 0 0 1 0 0 0 0 0 makeMosKey --> 't.type.key

    't.type.key 0 't.type setMosKeyAncestor

    't.name --> 't.type.name
    't.name --> 't.type.key.name
fi


( =====================================================================	)
( - array	array t							)

( Buggo?  CLtLp783 tab 28-1 gives just "array t" )
( but comparison with other entries makes one    )
( wonder if "array sequence t" was intended?     )

'array export
'array.type mosClass? not if
    makeMosClass dup      --> 'array.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'array.type.key

    'array.type.key 0 'array.type setMosKeyAncestor
    'array.type.key 1     't.type setMosKeyAncestor

    'array.type.key 0     't.type setMosKeyParent

    'array.name --> 'array.type.name
    'array.name --> 'array.type.key.name

    t --> 'array.type.key.fertile
fi


( =====================================================================	)
( - character	character t						)

'character export
'character.type mosClass? not if
    makeMosClass dup      --> 'character.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'character.type.key

    'character.type.key 0 'character.type setMosKeyAncestor
    'character.type.key 1         't.type setMosKeyAncestor

    'character.type.key 0         't.type setMosKeyParent

    'character.name --> 'character.type.name
    'character.name --> 'character.type.key.name

    t --> 'character.type.key.fertile
fi


( =====================================================================	)
( - function	function t						)

'function export
'function.type mosClass? not if
    makeMosClass dup      --> 'function.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'function.type.key

    'function.type.key 0 'function.type setMosKeyAncestor
    'function.type.key 1        't.type setMosKeyAncestor

    'function.type.key 0        't.type setMosKeyParent

    "function" dup --> 'function.type.name
		   --> 'function.type.key.name

    t --> 'function.type.key.fertile
fi


( =====================================================================	)
( - hashTable	hashTable t						)

'hashTable export
'hashTable.type mosClass? not if
    makeMosClass dup      --> 'hashTable.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'hashTable.type.key

    'hashTable.type.key 0 'hashTable.type setMosKeyAncestor
    'hashTable.type.key 1          't.type setMosKeyAncestor

    'hashTable.type.key 0          't.type setMosKeyParent

    'hashTable.name --> 'hashTable.type.name
    'hashTable.name --> 'hashTable.type.key.name

    t --> 'hashTable.type.key.fertile
fi


( =====================================================================	)
( - number	number t						)

'number export
'number.type mosClass? not if
    makeMosClass dup      --> 'number.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'number.type.key

    'number.type.key 0 'number.type setMosKeyAncestor
    'number.type.key 1      't.type setMosKeyAncestor

    'number.type.key 0      't.type setMosKeyParent

    'number.name --> 'number.type.name
    'number.name --> 'number.type.key.name

    t --> 'number.type.key.fertile
fi

( =====================================================================	)
( - package	package t						)

'package export
'package.type mosClass? not if
    makeMosClass dup      --> 'package.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'package.type.key

    'package.type.key 0 'package.type setMosKeyAncestor
    'package.type.key 1       't.type setMosKeyAncestor

    'package.type.key 0       't.type setMosKeyParent

    'package.name --> 'package.type.name
    'package.name --> 'package.type.key.name

    t --> 'package.type.key.fertile
fi



( =====================================================================	)
( - pathname	pathname t						)

'pathname export
'pathname.type mosClass? not if
    makeMosClass dup      --> 'pathname.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'pathname.type.key

    'pathname.type.key 0 'pathname.type setMosKeyAncestor
    'pathname.type.key 1        't.type setMosKeyAncestor

    'pathname.type.key 0        't.type setMosKeyParent

    'pathname.name --> 'pathname.type.name
    'pathname.name --> 'pathname.type.key.name

    t --> 'pathname.type.key.fertile
fi


( =====================================================================	)
( - randomState randomState t						)

'randomState export
'randomState.type mosClass? not if
    makeMosClass dup      --> 'randomState.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'randomState.type.key

    'randomState.type.key 0 'randomState.type setMosKeyAncestor
    'randomState.type.key 1            't.type setMosKeyAncestor

    'randomState.type.key 0            't.type setMosKeyParent

    'randomState.name --> 'randomState.type.name
    'randomState.name --> 'randomState.type.key.name

    t --> 'randomState.type.key.fertile
fi



( =====================================================================	)
( - readtable	readtable t						)

'readtable export
'readtable.type mosClass? not if
    makeMosClass dup      --> 'readtable.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'readtable.type.key

    'readtable.type.key 0 'readtable.type setMosKeyAncestor
    'readtable.type.key 1         't.type setMosKeyAncestor

    'readtable.type.key 0         't.type setMosKeyParent

    'readtable.name --> 'readtable.type.name
    'readtable.name --> 'readtable.type.key.name

    t --> 'readtable.type.key.fertile
fi


( =====================================================================	)
( - sequence	sequence t						)

'sequence export
'sequence.type mosClass? not if
    makeMosClass dup      --> 'sequence.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'sequence.type.key

    'sequence.type.key 0 'sequence.type setMosKeyAncestor
    'sequence.type.key 1        't.type setMosKeyAncestor

    'sequence.type.key 0        't.type setMosKeyParent

    'sequence.name --> 'sequence.type.name
    'sequence.name --> 'sequence.type.key.name

    t --> 'sequence.type.key.fertile
fi


( =====================================================================	)
( - stream	stream t						)

'stream export
'stream.type mosClass? not if
    makeMosClass dup      --> 'stream.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'stream.type.key

    'stream.type.key 0 'stream.type setMosKeyAncestor
    'stream.type.key 1      't.type setMosKeyAncestor

    'stream.type.key 0      't.type setMosKeyParent

    'stream.name --> 'stream.type.name
    'stream.name --> 'stream.type.key.name

    t --> 'stream.type.key.fertile
fi


( =====================================================================	)
( - symbol	symbol t						)

'symbol export
'symbol.type mosClass? not if
    makeMosClass dup      --> 'symbol.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'symbol.type.key

    'symbol.type.key 0 'symbol.type setMosKeyAncestor
    'symbol.type.key 1      't.type setMosKeyAncestor

    'symbol.type.key 0      't.type setMosKeyParent

    'symbol.name --> 'symbol.type.name
    'symbol.name --> 'symbol.type.key.name

    t --> 'symbol.type.key.fertile
fi


( =====================================================================	)
( - complex	complex number t					)

'complex export
'complex.type mosClass? not if
    makeMosClass dup      --> 'complex.type
    0 0 1 3 0 0 0 0 0 makeMosKey --> 'complex.type.key

    'complex.type.key 0 'complex.type setMosKeyAncestor
    'complex.type.key 1  'number.type setMosKeyAncestor
    'complex.type.key 2       't.type setMosKeyAncestor

    'complex.type.key 0 'number.type setMosKeyParent

    'complex.name --> 'complex.type.name
    'complex.name --> 'complex.type.key.name

    t --> 'complex.type.key.fertile
fi


( =====================================================================	)
( - float	float number t						)

'float export
'float.type mosClass? not if
    makeMosClass dup      --> 'float.type
    0 0 1 3 0 0 0 0 0 makeMosKey --> 'float.type.key

    'float.type.key 0  'float.type setMosKeyAncestor
    'float.type.key 1 'number.type setMosKeyAncestor
    'float.type.key 2      't.type setMosKeyAncestor

    'float.type.key 0 'number.type setMosKeyParent

    'float.name --> 'float.type.name
    'float.name --> 'float.type.key.name

    t --> 'float.type.key.fertile
fi


( =====================================================================	)
( - rational	rational number t					)

'rational export
'rational.type mosClass? not if
    makeMosClass dup      --> 'rational.type
    0 0 1 3 0 0 0 0 0 makeMosKey --> 'rational.type.key

    'rational.type.key 0 'rational.type setMosKeyAncestor
    'rational.type.key 1   'number.type setMosKeyAncestor
    'rational.type.key 2        't.type setMosKeyAncestor

    'rational.type.key 0   'number.type setMosKeyParent

    'rational.name --> 'rational.type.name
    'rational.name --> 'rational.type.key.name

    t --> 'rational.type.key.fertile
fi


( =====================================================================	)
( - list	list sequence t						)

'list export
'list.type mosClass? not if
    makeMosClass dup      --> 'list.type
    0 0 1 3 0 0 0 0 0 makeMosKey --> 'list.type.key

    'list.type.key 0     'list.type setMosKeyAncestor
    'list.type.key 1 'sequence.type setMosKeyAncestor
    'list.type.key 2        't.type setMosKeyAncestor

    'list.type.key 0 'sequence.type setMosKeyParent

    'list.name --> 'list.type.name
    'list.name --> 'list.type.key.name

    t --> 'list.type.key.fertile
fi


( =====================================================================	)
( - integer	integer rational number t				)

'integer export
'integer.type mosClass? not if
    makeMosClass dup      --> 'integer.type
    0 0 1 4 0 0 0 0 0 makeMosKey --> 'integer.type.key

    'integer.type.key 0  'integer.type setMosKeyAncestor
    'integer.type.key 1 'rational.type setMosKeyAncestor
    'integer.type.key 2   'number.type setMosKeyAncestor
    'integer.type.key 3        't.type setMosKeyAncestor

    'integer.type.key 0   'rational.type setMosKeyParent

    'integer.name --> 'integer.type.name
    'integer.name --> 'integer.type.key.name

    t --> 'integer.type.key.fertile
fi


( =====================================================================	)
( - ratio	ratio rational number t					)

'ratio export
'ratio.type mosClass? not if
    makeMosClass dup      --> 'ratio.type
    0 0 1 4 0 0 0 0 0 makeMosKey --> 'ratio.type.key

    'ratio.type.key 0    'ratio.type setMosKeyAncestor
    'ratio.type.key 1 'rational.type setMosKeyAncestor
    'ratio.type.key 2   'number.type setMosKeyAncestor
    'ratio.type.key 3        't.type setMosKeyAncestor

    'ratio.type.key 0 'rational.type setMosKeyParent

    'ratio.name --> 'ratio.type.name
    'ratio.name --> 'ratio.type.key.name

    t --> 'ratio.type.key.fertile
fi


( =====================================================================	)
( - cons	cons list sequence t					)

'cons export
'cons.type mosClass? not if
    makeMosClass dup      --> 'cons.type
    0 0 1 4 0 0 0 0 0 makeMosKey --> 'cons.type.key

    'cons.type.key 0     'cons.type setMosKeyAncestor
    'cons.type.key 1     'list.type setMosKeyAncestor
    'cons.type.key 2 'sequence.type setMosKeyAncestor
    'cons.type.key 3        't.type setMosKeyAncestor

    'cons.type.key 0     'list.type setMosKeyParent

    'cons.name --> 'cons.type.name
    'cons.name --> 'cons.type.key.name

    t --> 'cons.type.key.fertile
fi


( =====================================================================	)
( - vector	vector array sequence t					)

'vector export
'vector.type mosClass? not if
    makeMosClass dup      --> 'vector.type
    0 0 1 4 0 0 0 0 0 makeMosKey --> 'vector.type.key

    'vector.type.key 0   'vector.type setMosKeyAncestor
    'vector.type.key 1    'array.type setMosKeyAncestor
    'vector.type.key 2 'sequence.type setMosKeyAncestor
    'vector.type.key 3        't.type setMosKeyAncestor

    'vector.type.key 0    'array.type setMosKeyParent

    'vector.name --> 'vector.type.name
    'vector.name --> 'vector.type.key.name

    t --> 'vector.type.key.fertile
fi


( =====================================================================	)
( - null	null symbol list sequence t				)

'null export
'null.type mosClass? not if
    makeMosClass dup      --> 'null.type
    0 0 2 5 0 0 0 0 0 makeMosKey --> 'null.type.key

    'null.type.key 0     'null.type setMosKeyAncestor
    'null.type.key 1   'symbol.type setMosKeyAncestor
    'null.type.key 2 'sequence.type setMosKeyAncestor
    'null.type.key 3     'list.type setMosKeyAncestor
    'null.type.key 4        't.type setMosKeyAncestor

    'null.type.key 0  'symbol.type setMosKeyParent
    'null.type.key 1    'list.type setMosKeyParent

    'null.name --> 'null.type.name
    'null.name --> 'null.type.key.name

    t --> 'null.type.key.fertile
fi


( =====================================================================	)
( - string	string vector array sequence t				)

'string export
'string.type mosClass? not if
    makeMosClass dup      --> 'string.type
    0 0 1 5 0 0 0 0 0 makeMosKey --> 'string.type.key

    'string.type.key 0   'string.type setMosKeyAncestor
    'string.type.key 1   'vector.type setMosKeyAncestor
    'string.type.key 2    'array.type setMosKeyAncestor
    'string.type.key 3 'sequence.type setMosKeyAncestor
    'string.type.key 4        't.type setMosKeyAncestor

    'string.type.key 0   'vector.type setMosKeyParent

    'string.name --> 'string.type.name
    'string.name --> 'string.type.key.name

    t --> 'string.type.key.fertile
fi


( =====================================================================	)
( - bitvector	bitvector vector array sequence t			)

'bitvector export
'bitvector.type mosClass? not if
    makeMosClass dup      --> 'bitvector.type
    0 0 1 5 0 0 0 0 0 makeMosKey --> 'bitvector.type.key

    'bitvector.type.key 0 'bitvector.type setMosKeyAncestor
    'bitvector.type.key 1    'vector.type setMosKeyAncestor
    'bitvector.type.key 2     'array.type setMosKeyAncestor
    'bitvector.type.key 3  'sequence.type setMosKeyAncestor
    'bitvector.type.key 4         't.type setMosKeyAncestor

    'bitvector.type.key 0    'vector.type setMosKeyParent

    'bitvector.name --> 'bitvector.type.name
    'bitvector.name --> 'bitvector.type.key.name

    t --> 'bitvector.type.key.fertile
fi




( =====================================================================	)

( - Nonstandard classes representing Muq types				)

"lisp" inPackage

( =====================================================================	)
( - stackBlock t							)

'stackBlock export
'stackBlock.type mosClass? not if
    makeMosClass dup      --> 'stackBlock.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'stackBlock.type.key

    'stackBlock.type.key 0 'stackBlock.type setMosKeyAncestor
    'stackBlock.type.key 1           't.type setMosKeyAncestor

    'stackBlock.type.key 0     't.type setMosKeyParent

    'stackBlock.name --> 'stackBlock.type.name
    'stackBlock.name --> 'stackBlock.type.key.name

    t --> 'stackBlock.type.key.fertile
fi

( =====================================================================	)
( - bottom t								)

'bottom export
'bottom.type mosClass? not if
    makeMosClass dup      --> 'bottom.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'bottom.type.key

    'bottom.type.key 0 'bottom.type setMosKeyAncestor
    'bottom.type.key 1      't.type setMosKeyAncestor

    'bottom.type.key 0     't.type setMosKeyParent

    'bottom.name --> 'bottom.type.name
    'bottom.name --> 'bottom.type.key.name

    t --> 'bottom.type.key.fertile
fi


( =====================================================================	)
( - compiledFunction t							)

'compiledFunction export
'compiledFunction.type mosClass? not if
    makeMosClass dup      --> 'compiledFunction.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'compiledFunction.type.key

    'compiledFunction.type.key 0 'compiledFunction.type setMosKeyAncestor
    'compiledFunction.type.key 1      't.type setMosKeyAncestor

    'compiledFunction.type.key 0     't.type setMosKeyParent

    'compiledFunction.name --> 'compiledFunction.type.name
    'compiledFunction.name --> 'compiledFunction.type.key.name

    t --> 'compiledFunction.type.key.fertile
fi


( =====================================================================	)
( - special t								)

'special export
'special.type mosClass? not if
    makeMosClass dup      --> 'special.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'special.type.key

    'special.type.key 0 'special.type setMosKeyAncestor
    'special.type.key 1       't.type setMosKeyAncestor

    'special.type.key 0       't.type setMosKeyParent

    'special.name --> 'special.type.name
    'special.name --> 'special.type.key.name

    t --> 'special.type.key.fertile
fi


( =====================================================================	)

( - Standard MOS classes						)


"lisp" inPackage


( =====================================================================	)
( - standardObject	standardObject t				)

'standardObject export
'standardObject.type mosClass? not if
    makeMosClass dup      --> 'standardObject.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'standardObject.type.key

    'standardObject.type.key 0 'standardObject.type setMosKeyAncestor
    'standardObject.type.key 1               't.type setMosKeyAncestor

    'standardObject.type.key 0               't.type setMosKeyParent

    'standardObject.name --> 'standardObject.type.name
    'standardObject.name --> 'standardObject.type.key.name

    t --> 'standardObject.type.key.fertile
fi


( =====================================================================	)
( - standardStructure	standardStructure t				)

'standardStructure export
'standardStructure.type mosClass? not if
    makeMosClass dup      --> 'standardStructure.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'standardStructure.type.key

    'standardStructure.type.key 0 'standardStructure.type setMosKeyAncestor
    'standardStructure.type.key 1               't.type setMosKeyAncestor

    'standardStructure.type.key 0               't.type setMosKeyParent

    'standardStructure.name --> 'standardStructure.type.name
    'standardStructure.name --> 'standardStructure.type.key.name

    t --> 'standardStructure.type.key.fertile
fi


( =====================================================================	)
( - standardClass	standardClass t				)

'standardClass export
'standardClass.type mosClass? not if
    makeMosClass dup      --> 'standardClass.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'standardClass.type.key

    'standardClass.type.key 0 'standardClass.type setMosKeyAncestor
    'standardClass.type.key 1              't.type setMosKeyAncestor

    'standardClass.type.key 0              't.type setMosKeyParent

    'standardClass.name --> 'standardClass.type.name
    'standardClass.name --> 'standardClass.type.key.name

    t --> 'standardClass.type.key.fertile
fi


( =====================================================================	)
( - structureClass	structureClass t				)

'structureClass export
'structureClass.type mosClass? not if
    makeMosClass dup      --> 'structureClass.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'structureClass.type.key

    'structureClass.type.key 0 'structureClass.type setMosKeyAncestor
    'structureClass.type.key 1               't.type setMosKeyAncestor

    'structureClass.type.key 0               't.type setMosKeyParent

    'structureClass.name --> 'structureClass.type.name
    'structureClass.name --> 'structureClass.type.key.name

    t --> 'structureClass.type.key.fertile
fi


( =====================================================================	)
( - builtInClass	builtInClass t				)

'builtInClass export
'builtInClass.type mosClass? not if
    makeMosClass dup      --> 'builtInClass.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'builtInClass.type.key

    'builtInClass.type.key 0 'builtInClass.type setMosKeyAncestor
    'builtInClass.type.key 1              't.type setMosKeyAncestor

    'builtInClass.type.key 0              't.type setMosKeyParent

    'builtInClass.name --> 'builtInClass.type.name
    'builtInClass.name --> 'builtInClass.type.key.name

    t --> 'builtInClass.type.key.fertile
fi


( =====================================================================	)
( - standardGenericFunction	standardGenericFunction t		)

'standardGenericFunction export
'standardGenericFunction.type mosClass? not if
    makeMosClass dup      --> 'standardGenericFunction.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'standardGenericFunction.type.key

    'standardGenericFunction.type.key 0 'standardGenericFunction.type setMosKeyAncestor
    'standardGenericFunction.type.key 1   't.type setMosKeyAncestor

    'standardGenericFunction.type.key 0   't.type setMosKeyParent

    'standardGenericFunction.name --> 'standardGenericFunction.type.name
    'standardGenericFunction.name --> 'standardGenericFunction.type.key.name

    t --> 'standardGenericFunction.type.key.fertile
fi


( =====================================================================	)
( - standardMethod	standardMethod t				)

'standardMethod export
'standardMethod.type mosClass? not if
    makeMosClass dup      --> 'standardMethod.type
    0 0 1 2 0 0 0 0 0 makeMosKey --> 'standardMethod.type.key

    'standardMethod.type.key 0 'standardMethod.type setMosKeyAncestor
    'standardMethod.type.key 1               't.type setMosKeyAncestor

    'standardMethod.type.key 0               't.type setMosKeyParent

    'standardMethod.name --> 'standardMethod.type.name
    'standardMethod.name --> 'standardMethod.type.key.name

    t --> 'standardMethod.type.key.fertile
fi


( =====================================================================	)

( - Public fns								)

"muf" inPackage


( =====================================================================	)
( - pclass -- print (view) a class.					)
:   pclass { $ -> }
    -> c

    c symbol? if c.type -> c fi

    c mosClass? if
        c.key -> c
    fi

    c mosKey? not if
        "pclass: Arg must name a class" simpleError
    fi

    "\nClass " , c.name , ": " , c , "\n" ,

    c.layout -> layout
    layout :structure != if
        "    layout: " , layout , "\n" ,
    fi

    c.newerKey -> newerKey
    newerKey if
        "    newerKey: " , newerKey , "\n" ,
    fi

    c.mosParents -> parents
    "    " , parents , " parents:\n" ,
    for i from 0 below parents do{
        "        " , c i getMosKeyParent , "\n" ,
    }

    c.mosAncestors -> ancestors
    "    " , ancestors , " classes in precedence list:\n" ,
    for i from 0 below ancestors do{
        "        " , c i getMosKeyAncestor , "\n" ,
    }

    c.initargs -> initargs
    "    " , initargs , initargs 0 = if " initargs.\n" else " initargs:\n" fi ,
    for i from 0 below initargs do{
        "        " , c i getMosKeyInitarg -> v , " " , v , "\n" ,
    }

    c.unsharedSlots -> unsharedSlots
    "    " , unsharedSlots , " unshared slots, " ,

    c.sharedSlots   -> sharedSlots
    sharedSlots ,

    unsharedSlots sharedSlots + -> totalSlots
    totalSlots 0 = if
	" shared slots.\n" ,
    else
	" shared slots:\n" ,
    fi

    for i from 0 below totalSlots do{
	"        " ,
	c :symbol i getMosKeySlotProperty ,


	" " ,
(	c :rootMayRead    i getMosKeySlotProperty if "r" else "-" fi , )
(	c :rootMayWrite   i getMosKeySlotProperty if "w" else "-" fi , )
	c :userMayRead    i getMosKeySlotProperty if "r" else "-" fi ,
	c :userMayWrite   i getMosKeySlotProperty if "w" else "-" fi ,
	c :classMayRead   i getMosKeySlotProperty if "r" else "-" fi ,
	c :classMayWrite  i getMosKeySlotProperty if "w" else "-" fi ,
	c :worldMayRead   i getMosKeySlotProperty if "r" else "-" fi ,
	c :worldMayWrite  i getMosKeySlotProperty if "w" else "-" fi ,

	c :allocation       i  getMosKeySlotProperty :instance = if
	    " (unshared)\n" ,
	else
	    c :inherited    i  getMosKeySlotProperty if
		" (shared, located in " ,
		c :initval  i  getMosKeySlotProperty ,
		" )" ,
	    else
		" (shared, value " ,
		c :initval  i  getMosKeySlotProperty ,
		" )" ,
	    fi
	    "\n" ,
	fi
    }

    c.objectMmethods   -> objectMmethods
    "    " ,   objectMmethods ,
    objectMmethods 0 = if " object methods.\n"
    else                  " object methods:\n" fi ,
    for i from 0 below objectMmethods do{
	"        " ,
	c i getMosKeyObjectMethod -> obj -> mtd -> gfn -> argno
	argno , ": " , gfn , " " , mtd , " " , obj , "\n" ,
    }

    c.classMethods   -> classMethods
    "    " , classMethods ,
    classMethods 0 = if " class methods.\n"
    else                 " class methods:\n" fi ,
    for i from 0 below classMethods do{
	"        " ,
	c i getMosKeyClassMethod -> mtd -> gfn -> argno
	argno , ": " , gfn , " " , mtd , "\n" ,
    }
;
'pclass export


( =====================================================================	)
( - pmethod -- print (view) a method.					)
:   pmethod { $ -> }
    -> m

    "\nMethod " , m.name , ":\n" ,
    "    qualifier: "         , m.qualifier            , "\n" ,
    "    methodFunction: "   , m.methodFunction      , "\n" ,
    "    genericFunction: "  , m.genericFunction     , "\n" ,
    "    lambdaList: "       , m.lambdaList          , "\n" ,
    "    requiredArgs: "     , m.requiredArgs -> a a , "\n" ,
    for i from 0 below a do{
	m i getMethodSlot -> arg -> op
	"        op == " , op , "   arg == " , arg , "\n" ,
    }
;
'pmethod export

( =====================================================================	)
( - plambda -- print (view) a lambdaList object.			)
:   plambda { $ -> }
    -> m

    "\nLambda " , m.name , ":\n" ,

    "    requiredArgs: "     , m.requiredArgs -> ra ra , "\n" ,
    for i from 0 below ra do{
	m :name i getLambdaSlotProperty -> nam
	"        " , nam , "\n" ,
    }

    "    optionalArgs: "     , m.optionalArgs -> oa oa , "\n" ,
    ra oa + -> hi
    for i from ra below hi do{
	m :name     i getLambdaSlotProperty -> nam
	m :initform i getLambdaSlotProperty -> val
	val not if
	    m :initval i getLambdaSlotProperty -> val
	fi
	"        " , nam , " " , val , "\n" ,
    }

    "    keywordArgs: "     , m.keywordArgs -> ka ka , "\n" ,
    ra oa + -> lo
    lo ka + -> hi
    for i from lo below hi do{
	m :name     i getLambdaSlotProperty -> nam
	m :initform i getLambdaSlotProperty -> val
	val not if
	    m :initval i getLambdaSlotProperty -> val
	fi
	"        " , nam , " " , val , "\n" ,
    }
;
'plambda export

( =====================================================================	)
( - |applyLambdaListSlowly --					)
:   |applyLambdaListSlowly { [] $ -> [] }

    ( The main |applyLambdaList prim is C-coded and )
    ( hence relatively fast, but when :initform slots )
    ( are filled, it punts and calls us.              )

    ( Save out lambdaList: )
    -> ll

    ( Unpack basic info from it: )
    ll isALambdaList
    ll.requiredArgs  -> REQ_ARGS
    ll.optionalArgs  -> optArgs
    ll.keywordArgs   -> kwArgs

    ( Initialize some local state: )
    REQ_ARGS optArgs + -> kwLoc ( First   keyword in lambdaList )
    kwLoc kwArgs    + -> kwLim ( 1+ last keyword in lambdaList )
    0 -> src ( Location in argblock )
    0 -> dst ( Location in result vector )
    |length -> blk ( Number of arguments supplied )
    blk REQ_ARGS < if "Missing required argument(s)" error fi
    'plugh kwLim makeEphemeralVector -> result

    ( Accept all supplied required arguments: )
    for i from 0 below REQ_ARGS do{
	src |dupNth --> result[dst]
	++ src
	++ dst
    }

    ( Accept all supplied optional arguments: )
    for i from 0 below optArgs do{
        src blk = if loopFinish fi
        src |dupNth --> result[dst]
	++ src
	++ dst
    }

    ( Supply defaults for all missing optional arguments: )
    for j from i below optArgs do{
	ll :initform REQ_ARGS j + getLambdaSlotProperty -> initform
        initform if
            initform call{ -> $ } --> result[dst]
	else
	    ll :initval REQ_ARGS j + getLambdaSlotProperty --> result[dst]
	fi
	++ dst
    }

    ( Accept all supplied keyword arguments: )
    for i from 0 below kwArgs do{
        src blk = if loopFinish fi
	src |dupNth -> key
	++ src
        src blk = if "Keyword has no value" error fi
	src |dupNth -> val
	++ src

	( Find key in lambdaList: )
        for j from kwLoc below kwLim do{
	    ll :name j getLambdaSlotProperty key = if
		result[j] 'plugh = if
                    val --> result[j]
                fi
		loopFinish
	    fi
	}
    }

    ( Provide defaults for all missing keyword arguments: )
    for j from kwLoc below kwLim do{
	result[j] 'plugh = if
            ll :initform j getLambdaSlotProperty -> initform
	    initform if
                initform call{ -> $ } --> result[j]
	    else
                ll :initval j getLambdaSlotProperty --> result[j]
	fi  fi
    }

    ( Pop input block: )
    ]pop

    ( Return result vector: )
    result vals[
;
'|applyLambdaListSlowly export

( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
 
@end example
