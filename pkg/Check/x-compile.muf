( --------------------------------------------------------------------- )
(			x-compile.muf				    CrT )
( Exercise Muq compiler support stuff.					)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      96May19							)
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
(  Contact cynbe@eskimo.com for a COMMERCIAL LICENSE.			)
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
( NO EVENT SHALL Jeff Prothero BE LIABLE FOR ANY SPECIAL, INDIRECT OR	)
( CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS	)
( OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,		)
( NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION	)
( WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.				)
( 									)
( Please send bug reports/fixes etc to bugs@@muq.org.			)
( ---------------------------------------------------------------------	)
( --------------------------------------------------------------------- )
(                              history                              CrT )
(                                                                       )
( 96May19 jsp	Created.						)
( --------------------------------------------------------------------- )

"Compile support tests\n" log,
"\nCompile support tests:" ,




( ===================================================================== )
( -Tests 1-47: Basic [un]readTokenChar stuff: )

( Set up some chars in a message stream: )
::  makeMessageStream --> _mss ; shouldWork
::  [ 'a' 'b' '\n' 'm' | "txt" t _mss
    |writeStreamPacket pop pop ]pop
; shouldWork

( Read, unread and reread first char: )
::  [ _mss | |readTokenChar
    |pop --> _line
    |pop --> _byte
    |pop --> _char
    ]pop
; shouldWork
::   _char 'a'  = ; shouldBeTrue
::   _line 0    = ; shouldBeTrue
::   _byte 0    = ; shouldBeTrue
::   [ _mss | |unreadTokenChar |pop --> _char ]pop ; shouldWork
::   _char 'a'  = ; shouldBeTrue
::  [ _mss | |readTokenChar
    |pop --> _line
    |pop --> _byte
    |pop --> _char
    ]pop
; shouldWork
::   _char 'a'  = ; shouldBeTrue
::   _line 0    = ; shouldBeTrue
::   _byte 0    = ; shouldBeTrue


( Read, unread and reread second char: )
::  [ _mss | |readTokenChar
    |pop --> _line
    |pop --> _byte
    |pop --> _char
    ]pop
; shouldWork
::   _char 'b'  = ; shouldBeTrue
::   _line 0    = ; shouldBeTrue
::   _byte 1    = ; shouldBeTrue
::   [ _mss | |unreadTokenChar |pop --> _char ]pop ; shouldWork
::   _char 'b'  = ; shouldBeTrue
::  [ _mss | |readTokenChar
    |pop --> _line
    |pop --> _byte
    |pop --> _char
    ]pop
; shouldWork
::   _char 'b'  = ; shouldBeTrue
::   _line 0    = ; shouldBeTrue
::   _byte 1    = ; shouldBeTrue

( Read, unread and reread third char: )
::  [ _mss | |readTokenChar
    |pop --> _line
    |pop --> _byte
    |pop --> _char
    ]pop
; shouldWork
::   _char '\n' = ; shouldBeTrue
::   _line 0    = ; shouldBeTrue
::   _byte 2    = ; shouldBeTrue
::   [ _mss | |unreadTokenChar |pop --> _char ]pop ; shouldWork
::   _char '\n' = ; shouldBeTrue
::  [ _mss | |readTokenChar
    |pop --> _line
    |pop --> _byte
    |pop --> _char
    ]pop
; shouldWork
::   _char '\n' = ; shouldBeTrue
::   _line 0    = ; shouldBeTrue
::   _byte 2    = ; shouldBeTrue

( Read, unread and reread fourth char: )
::  [ _mss | |readTokenChar
    |pop --> _line
    |pop --> _byte
    |pop --> _char
    ]pop
; shouldWork
::   _char 'm'  = ; shouldBeTrue
::   _line 1    = ; shouldBeTrue
::   _byte 3    = ; shouldBeTrue
::   [ _mss | |unreadTokenChar |pop --> _char ]pop ; shouldWork
::   _char 'm'  = ; shouldBeTrue
::  [ _mss | |readTokenChar
    |pop --> _line
    |pop --> _byte
    |pop --> _char
    ]pop
; shouldWork
::   _char 'm'  = ; shouldBeTrue
::   _line 1    = ; shouldBeTrue
::   _byte 3    = ; shouldBeTrue

( Read token chars: )
::  [ _mss  0 4 | |readTokenChars ]join "ab\nm" = ; shouldBeTrue
::  [ _mss  0 5 | |readTokenChars ; shouldFail
::  [ _mss -1 0 | |readTokenChars ; shouldFail
::  [ _mss  3 2 | |readTokenChars ; shouldFail
::  [ _mss  1 3 | |readTokenChars ]join "b\n" = ; shouldBeTrue



( ===================================================================== )
( -Tests 48-61: |scanTokenToChar without quote: )

( Set up some chars in a message stream: )
::  makeMessageStream --> _mss ; shouldWork
::  [ 'a' '\\' '"' '"' 'a' '\\' '"' '"' | "txt" t _mss
    |writeStreamPacket pop pop ]pop
; shouldWork
::  [ _mss '"' | |scanTokenToChar
    |pop --> _line
    |pop --> _stop
    |pop --> _start
    |pop --> _retMss
    ]pop
; shouldWork
::  _line 0 = ; shouldBeTrue
::  _retMss _mss = ; shouldBeTrue
::  _start 0 = ; shouldBeTrue
::  _stop  3 = ; shouldBeTrue
::  [ _retMss _start _stop |
    |readTokenChars ]join "a\\\"" =
; shouldBeTrue
::  [ _mss '"' | |scanTokenToChar
    |pop --> _line
    |pop --> _stop
    |pop --> _start
    |pop --> _retMss
    ]pop
; shouldWork
::  _line 0 = ; shouldBeTrue
::  _retMss _mss = ; shouldBeTrue
::  _start 3 = ; shouldBeTrue
::  _stop  4 = ; shouldBeTrue
::  [ _retMss _start _stop |
    |readTokenChars ]join "\"" =
; shouldBeTrue



( ===================================================================== )
( -Tests 62-75: |scanTokenToChar with quote: )

( Set up some chars in a message stream: )
::  makeMessageStream --> _mss ; shouldWork
::  [ 'a' '\\' '"' '"' 'a' '\\' '"' '"' | "txt" t _mss
    |writeStreamPacket pop pop ]pop
; shouldWork
::  [ _mss '"' '\\' | |scanTokenToChar
    |pop --> _line
    |pop --> _stop
    |pop --> _start
    |pop --> _retMss
    ]pop
; shouldWork
::  _line 0 = ; shouldBeTrue
::  _retMss _mss = ; shouldBeTrue
::  _start 0 = ; shouldBeTrue
::  _stop  4 = ; shouldBeTrue
::  [ _retMss _start _stop |
    |readTokenChars ]join "a\\\"\"" =
; shouldBeTrue
::  [ _mss '"' '\\' | |scanTokenToChar
    |pop --> _line
    |pop --> _stop
    |pop --> _start
    |pop --> _retMss
    ]pop
; shouldWork
::  _line 0 = ; shouldBeTrue
::  _retMss _mss = ; shouldBeTrue
::  _start 4 = ; shouldBeTrue
::  _stop  8 = ; shouldBeTrue
::  [ _retMss _start _stop |
    |readTokenChars ]join "a\\\"\"" =
; shouldBeTrue



( ===================================================================== )
( -Tests 76-89: |scanTokenToCharPair without quote: )

( Set up some chars in a message stream: )
::  makeMessageStream --> _mss ; shouldWork
::  [ 'a' '\\' '*' '/' '*' '/' 'a' '\\' '*' '/' '*' '/' | "txt" t _mss
    |writeStreamPacket pop pop ]pop
; shouldWork
::  [ _mss '*' '/' | |scanTokenToCharPair
    |pop --> _line
    |pop --> _stop
    |pop --> _start
    |pop --> _retMss
    ]pop
; shouldWork
::  _line 0 = ; shouldBeTrue
::  _retMss _mss = ; shouldBeTrue
::  _start 0 = ; shouldBeTrue
::  _stop  4 = ; shouldBeTrue
::  [ _retMss _start _stop |
    |readTokenChars ]join "a\\*/" =
; shouldBeTrue
::  [ _mss '*' '/' | |scanTokenToCharPair
    |pop --> _line
    |pop --> _stop
    |pop --> _start
    |pop --> _retMss
    ]pop
; shouldWork
::  _line 0 = ; shouldBeTrue
::  _retMss _mss = ; shouldBeTrue
::  _start 4 = ; shouldBeTrue
::  _stop  6 = ; shouldBeTrue
::  [ _retMss _start _stop |
    |readTokenChars ]join "*/" =
; shouldBeTrue



( ===================================================================== )
( -Tests 90-103: |scanTokenToCharPair with quote: )

( Set up some chars in a message stream: )
::  makeMessageStream --> _mss ; shouldWork
::  [ 'a' '\\' '*' '/' '*' '/' 'a' '\\' '*' '/' '*' '/' | "txt" t _mss
    |writeStreamPacket pop pop ]pop
; shouldWork
::  [ _mss '*' '/' '\\' | |scanTokenToCharPair
    |pop --> _line
    |pop --> _stop
    |pop --> _start
    |pop --> _retMss
    ]pop
; shouldWork
::  _line 0 = ; shouldBeTrue
::  _retMss _mss = ; shouldBeTrue
::  _start 0 = ; shouldBeTrue
::  _stop  6 = ; shouldBeTrue
::  [ _retMss _start _stop |
    |readTokenChars ]join "a\\*/*/" =
; shouldBeTrue
::  [ _mss '*' '/' '\\' | |scanTokenToCharPair
    |pop --> _line
    |pop --> _stop
    |pop --> _start
    |pop --> _retMss
    ]pop
; shouldWork
::  _line 0 = ; shouldBeTrue
::  _retMss _mss = ; shouldBeTrue
::  _start 6 = ; shouldBeTrue
::  _stop 12 = ; shouldBeTrue
::  [ _retMss _start _stop |
    |readTokenChars ]join "a\\*/*/" =
; shouldBeTrue



( ===================================================================== )
( -Tests 104-117: |scanTokenToWhitespace without quote: )

( Set up some chars in a message stream: )
::  makeMessageStream --> _mss ; shouldWork
::  [ 'a' '\\' ' ' ' ' 'a' '\\' ' ' ' ' | "txt" t _mss
    |writeStreamPacket pop pop ]pop
; shouldWork
::  [ _mss | |scanTokenToWhitespace
    |pop --> _line
    |pop --> _stop
    |pop --> _start
    |pop --> _retMss
    ]pop
; shouldWork
::  _line 0 = ; shouldBeTrue
::  _retMss _mss = ; shouldBeTrue
::  _start 0 = ; shouldBeTrue
::  _stop  2 = ; shouldBeTrue
::  [ _retMss _start _stop |
    |readTokenChars ]join "a\\" =
; shouldBeTrue
::  [ _mss | |scanTokenToWhitespace
    |pop --> _line
    |pop --> _stop
    |pop --> _start
    |pop --> _retMss
    ]pop
; shouldWork
::  _line 0 = ; shouldBeTrue
::  _retMss _mss = ; shouldBeTrue
::  _start 2 = ; shouldBeTrue
::  _stop  2 = ; shouldBeTrue
::  [ _retMss _start _stop |
    |readTokenChars ]join "" =
; shouldBeTrue



( ===================================================================== )
( -Tests 118-132: |scanTokenToWhitespace with quote: )

( Set up some chars in a message stream: )
::  makeMessageStream --> _mss ; shouldWork
::  [ 'a' '\\' ' ' ' ' 'a' '\\' ' ' ' ' | "txt" t _mss
    |writeStreamPacket pop pop ]pop
; shouldWork
::  [ _mss '\\' | |scanTokenToWhitespace
    |pop --> _line
    |pop --> _stop
    |pop --> _start
    |pop --> _retMss
    ]pop
; shouldWork
::  _line 0 = ; shouldBeTrue
::  _retMss _mss = ; shouldBeTrue
::  _start 0 = ; shouldBeTrue
::  _stop  3 = ; shouldBeTrue
::  [ _retMss _start _stop |
    |readTokenChars ]join "a\\ " =
; shouldBeTrue
::  [ _mss | |readTokenChar ]pop ; shouldWork
::  [ _mss '\\' | |scanTokenToWhitespace
    |pop --> _line
    |pop --> _stop
    |pop --> _start
    |pop --> _retMss
    ]pop
; shouldWork
::  _line 0 = ; shouldBeTrue
::  _retMss _mss = ; shouldBeTrue
::  _start 4 = ; shouldBeTrue
::  _stop  7 = ; shouldBeTrue
::  [ _retMss _start _stop |
    |readTokenChars ]join "a\\ " =
; shouldBeTrue



( ===================================================================== )
( -Tests 133-147: |scanTokenToNonwhitespace: )

( Set up some chars in a message stream: )
::  makeMessageStream --> _mss ; shouldWork
::  [ ' ' 'a' ' ' ' ' 'b' | "txt" t _mss
    |writeStreamPacket pop pop ]pop
; shouldWork
::  [ _mss | |scanTokenToNonwhitespace
    |pop --> _seenEoln
    |pop --> _line
    |pop --> _stop
    |pop --> _start
    |pop --> _retMss
    ]pop
; shouldWork
::  _line 0 = ; shouldBeTrue
::  _retMss _mss = ; shouldBeTrue
::  _start 0 = ; shouldBeTrue
::  _stop  1 = ; shouldBeTrue
::  [ _retMss _start _stop |
    |readTokenChars ]join " " =
; shouldBeTrue
::  [ _mss | |readTokenChar ]pop ; shouldWork
::  [ _mss | |scanTokenToNonwhitespace
    |pop --> _seenEoln
    |pop --> _line
    |pop --> _stop
    |pop --> _start
    |pop --> _retMss
    ]pop
; shouldWork
::  _line 0 = ; shouldBeTrue
::  _retMss _mss = ; shouldBeTrue
::  _start 2 = ; shouldBeTrue
::  _stop  4 = ; shouldBeTrue
::  [ _retMss _start _stop |
    |readTokenChars ]join "  " =
; shouldBeTrue



( ===================================================================== )
( -Tests 148-158: |scanLispToken on simple number: )

( Set up some chars in a message stream: )
::  makeMessageStream --> _mss ; shouldWork
::  "123.45\n" _mss writeStream ; shouldWork
::  [ _mss | lisp:|scanLispToken
    |pop --> _type
    |pop --> _line
    |pop --> _stop
    |pop --> _start
    |pop --> _retMss
    ]pop
; shouldWork
::  _type lisp:stateSymbol =  ; shouldBeTrue
::  _line 0 =  ; shouldBeTrue
::  _retMss _mss = ; shouldBeTrue
::  _start 0 = ; shouldBeTrue
::  _stop  6 = ; shouldBeTrue
::  [ _retMss _start _stop |
    |readTokenChars ]join "123.45" =
; shouldBeTrue
::  [ _retMss _start _stop |
    |readTokenChars lisp:|classifyLispToken --> _type ]pop
; shouldWork
::  _type lisp:statePotnum =  ; shouldBeTrue



( ===================================================================== )
( -Tests 159-168: |scanLispToken on non/numbers: )

: tok { $ -> $ } -> stg
    makeMessageStream --> _mss
    stg _mss writeStream
    [ _mss | lisp:|scanLispToken
    |pop pop |pop pop
    |readTokenChars
    lisp:|classifyLispToken -> typ
    ]pop 
    typ
;

( Must start with [0-9\+\-.^_]: )
:: "1.2e4\n"  tok lisp:statePotnum = ; shouldBeTrue
:: "e1.2e4\n" tok lisp:stateSymbol = ; shouldBeTrue

( May not have two consecutive letters: )
:: "1.2ee4\n" tok lisp:stateSymbol = ; shouldBeTrue

( May not end with a sign: )
:: "+1\n"     tok lisp:statePotnum = ; shouldBeTrue
:: "1+\n"     tok lisp:stateSymbol = ; shouldBeTrue

( May not contain any backquoted chars: )
:: "\\+1\n"   tok lisp:stateSymbol = ; shouldBeTrue
:: "+\\1\n"   tok lisp:stateSymbol = ; shouldBeTrue

( May not contain any barquoted chars: )
:: "|+|1\n"   tok lisp:stateSymbol = ; shouldBeTrue
:: "+|1|\n"   tok lisp:stateSymbol = ; shouldBeTrue
:: "|+1|\n"   tok lisp:stateSymbol = ; shouldBeTrue




( ===================================================================== )
( -Tests 169-178: Check integer conversions: )

: num-val { $ -> $ } -> stg
    makeMessageStream --> _mss
    stg _mss writeStream
    [ _mss | lisp:|scanLispToken
    |pop pop |pop pop
    |readTokenChars
    lisp:|classifyLispToken -> typ
    ]makeNumber -> val -> typ
    val
;
: num-typ { $ -> $ } -> stg
    makeMessageStream --> _mss
    stg _mss writeStream
    [ _mss | lisp:|scanLispToken
    |pop pop |pop pop
    |readTokenChars
    lisp:|classifyLispToken -> typ
    ]makeNumber -> val -> typ
    typ
;

:: "0\n"         num-typ lisp:lispFixnum = ; shouldBeTrue
:: "0\n"         num-val 0                = ; shouldBeTrue

:: "-23\n"       num-typ lisp:lispFixnum = ; shouldBeTrue
:: "-23\n"       num-val -23              = ; shouldBeTrue

:: "123\n"       num-typ lisp:lispFixnum = ; shouldBeTrue
:: "123\n"       num-val 123              = ; shouldBeTrue

:: "123456\n"    num-typ lisp:lispFixnum = ; shouldBeTrue
:: "123456\n"    num-val 123456           = ; shouldBeTrue

:: "123456789\n" num-typ lisp:lispFixnum = ; shouldBeTrue
:: "123456789\n" num-val 123456789        = ; shouldBeTrue




( ===================================================================== )
( -Tests 179-200: Check float conversions: )

:: ".1\n"        num-typ lisp:lispShortFloat = ; shouldBeTrue
:: ".1\n"        num-val 0.1                   = ; shouldBeTrue

:: "1.0\n"       num-typ lisp:lispShortFloat = ; shouldBeTrue
:: "1.0\n"       num-val 1.0                   = ; shouldBeTrue

:: "12.34\n"     num-typ lisp:lispShortFloat = ; shouldBeTrue
:: "12.34\n"     num-val 12.34                 = ; shouldBeTrue

:: "-.23\n"      num-typ lisp:lispShortFloat = ; shouldBeTrue
:: "-.23\n"      num-val -0.23                 = ; shouldBeTrue

:: "0.2e1\n"     num-typ lisp:lispShortFloat = ; shouldBeTrue
:: "0.2e1\n"     num-val 2.0                   = ; shouldBeTrue

:: "0.2s1\n"     num-typ lisp:lispShortFloat = ; shouldBeTrue
:: "0.2s1\n"     num-val 2.0                   = ; shouldBeTrue

:: "0.2f1\n"     num-typ lisp:lispShortFloat = ; shouldBeTrue
:: "0.2f1\n"     num-val 2.0                   = ; shouldBeTrue

:: "0.2d1\n"     num-typ lisp:lispShortFloat = ; shouldBeTrue
:: "0.2d1\n"     num-val 2.0                   = ; shouldBeTrue

:: "0.2l1\n"     num-typ lisp:lispShortFloat = ; shouldBeTrue
:: "0.2l1\n"     num-val 2.0                   = ; shouldBeTrue

:: "0.2e-1\n"    num-typ lisp:lispShortFloat = ; shouldBeTrue
:: "0.2e-1\n"    num-val 0.02                  = ; shouldBeTrue

:: "0.2e-12\n"   num-typ lisp:lispShortFloat = ; shouldBeTrue
:: "0.2e-12\n"   num-val 0.2e-12               = ; shouldBeTrue



( ===================================================================== )
( -Tests 201-204: Check dot translation: )

:: ".\n"         tok lisp:stateDot    = ; shouldBeTrue
:: "\\.\n"       tok lisp:stateSymbol = ; shouldBeTrue
:: "..\n"        tok lisp:stateSymbol = ; shouldFail
:: "|..|\n"      tok lisp:stateSymbol = ; shouldBeTrue



( ===================================================================== )
( -Tests 205-214: Check colon syntax: )

: sym { $ -> $ } -> stg
    makeMessageStream --> _mss
    stg _mss writeStream
    [ _mss | lisp:|scanLispToken
    |pop pop |pop pop
    |readTokenChars
    lisp:|classifyLispToken -> typ
    lisp:nil ]makeSymbol
;

:: ":\n"         sym :x    = ; shouldBeFalse
:: "::\n"        sym :x    = ; shouldBeFalse
:: "x:\n"        sym :x    = ; shouldBeFalse
:: ":x\n"        sym :x    = ; shouldBeTrue
:: "::x\n"       sym :x    = ; shouldFail
:: "x:::y\n"     sym :x    = ; shouldFail
:: "x:y:z\n"     sym :x    = ; shouldFail
:: "x\n"         sym 'x    = ; shouldBeTrue

( Create a p:x )
@$s.package$s.name
"p" muf:inPackage
'x muf:export
muf:inPackage

:: "p::x\n"      sym 'p::x = ; shouldBeTrue
:: "p:x\n"       sym 'p:x  = ; shouldBeTrue



( ===================================================================== )
( - Tests 215-220: Check read function proper on numbers and symbols: )

: test-read { $ -> $ } -> stg
    makeMessageStream --> _mss
    stg _mss writeStream
    [ _mss | lisp:read |pop -> val ]pop
    val
;

:: "1\n"     test-read 1      = ; shouldBeTrue
:: "1.2\n"   test-read 1.2    = ; shouldBeTrue
:: ":xyz\n"  test-read :xyz   = ; shouldBeTrue
:: "xyz\n"   test-read 'xyz   = ; shouldBeTrue
:: "p:x\n"   test-read 'p:x   = ; shouldBeTrue
:: "p::x\n"  test-read 'p::x  = ; shouldBeTrue



( ===================================================================== )
( - 221-228 Check read function proper on lists: )

:: "()\n"          test-read             ; shouldBeFalse
:: "( )\n"         test-read             ; shouldBeFalse
:: "( a 1 1.2 )\n" test-read car  'a   = ; shouldBeTrue
:: "( a 1 1.2 )\n" test-read cdar  1   = ; shouldBeTrue
:: "( a 1 1.2 )\n" test-read cddar 1.2 = ; shouldBeTrue
::  "(a 1 1.2)\n"  test-read car  'a   = ; shouldBeTrue
::  "(a 1 1.2)\n"  test-read cdar  1   = ; shouldBeTrue
::  "(a 1 1.2)\n"  test-read cddar 1.2 = ; shouldBeTrue


( ===================================================================== )
( - 229-242 Also test dotted lists: )

:: "( . a b )\n"   test-read           ; shouldFail
:: "( a b . )\n"   test-read           ; shouldFail

:: "( a . b )\n"   test-read cons?     ; shouldBeTrue
:: "( a . b )\n"   test-read car 'a =  ; shouldBeTrue
:: "( a . b )\n"   test-read cdr 'b =  ; shouldBeTrue

:: "( a b . c )\n" test-read car  'a = ; shouldBeTrue
:: "( a b . c )\n" test-read cdar 'b = ; shouldBeTrue
:: "( a b . c )\n" test-read cddr 'c = ; shouldBeTrue

::  "(a . b)\n"    test-read cons?     ; shouldBeTrue
::  "(a . b)\n"    test-read car 'a =  ; shouldBeTrue
::  "(a . b)\n"    test-read cdr 'b =  ; shouldBeTrue

::  "(a b . c)\n"  test-read car  'a = ; shouldBeTrue
::  "(a b . c)\n"  test-read cdar 'b = ; shouldBeTrue
::  "(a b . c)\n"  test-read cddr 'c = ; shouldBeTrue



( ===================================================================== )
( - 243-250 Nested lists: )

:: "(().())\n" test-read car          ; shouldBeFalse
:: "(().())\n" test-read cdr          ; shouldBeFalse

:: "(a . (b . c))\n" test-read car  'a = ; shouldBeTrue
:: "(a . (b . c))\n" test-read cdar 'b = ; shouldBeTrue
:: "(a .(b . c))\n"  test-read cddr 'c = ; shouldBeTrue

:: "((a . b). c)\n"  test-read caar 'a = ; shouldBeTrue
:: "((a . b) . c)\n" test-read cadr 'b = ; shouldBeTrue
:: "((a . b). c)\n"  test-read cdr  'c = ; shouldBeTrue


( ===================================================================== )
( - 251-252 Comments: )

:: "(;xx\na;yy\n.;zz\n1.2;\n);\n" test-read car 'a  = ; shouldBeTrue
:: "(;xx\na;yy\n.;zz\n1.2;\n);\n" test-read cdr 1.2 = ; shouldBeTrue



( ===================================================================== )
( - 253-254 Strings: )

:: "\"\"\n"           test-read "" =         ; shouldBeTrue
:: "(\"\\\"\\\\\")\n" test-read car "\"\\" = ; shouldBeTrue



( ===================================================================== )
( - 255-256 Single quote: )

:: "'a\n"           test-read car  'lisp:quote = ; shouldBeTrue
:: "'a\n"           test-read cdar 'a          = ; shouldBeTrue

( ===================================================================== )
( - 257-266 |scan-muf-tic-token: )


( : tic { $ -> $ } -> stg  )
(     makeMessageStream --> _mss )
(     stg _mss writeStream )
(     [ _mss | |scan-muf-tic-token )
(     |pop --> _isChr )
(     |pop --> _line )
(     |readTokenChars )
(     ]join )
( ; )


( :: "a' " tic "a'" = ; shouldBeTrue )
( :: _isChr ; shouldBeTrue )

( :: " ' " tic " '" = ; shouldBeTrue )
( :: _isChr ; shouldBeTrue )

( :: "\\'' " tic "\\''" = ; shouldBeTrue )
( :: _isChr ; shouldBeTrue )

( :: "\\\\' " tic "\\\\'" = ; shouldBeTrue )
( :: _isChr ; shouldBeTrue )

( :: "abc " tic "abc" = ; shouldBeTrue )
( :: _isChr ; shouldBeFalse )



( ===================================================================== )
( - 267-276 |positionInStack?: )

:: makeStack -->  _stk ; shouldWork
::   17 _stk push    "def"  _stk push ; shouldWork
::   13 _stk push    "abc"  _stk push ; shouldWork
::   11 _stk push    "ghij" _stk push ; shouldWork
:: [ 'a' 'b' 'c' |
   |charInt
   _stk |positionInStack? --> _pos
; shouldBeTrue
:: _pos 1- -> pos _stk[pos] 13 = ; shouldBeTrue
:: [ 'd' 'e' 'f' |
   |charInt
   _stk |positionInStack? --> _pos
; shouldBeTrue
:: _pos 1- -> pos _stk[pos] 17 = ; shouldBeTrue
:: [ 'g' 'h' 'i' 'j' |
   |charInt
   _stk |positionInStack? --> _pos
; shouldBeTrue
:: _pos 1- -> pos _stk[pos] 11 = ; shouldBeTrue


( ===================================================================== )
( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
