( --------------------------------------------------------------------- )
(			x-rex.muf				    CrT )
( Exercise regular expression stuff.					)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      98May25							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1999, by Jeff Prothero.				)
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
( 98May25 jsp	Created.						)
( --------------------------------------------------------------------- )

"Rex tests\n" log,
"\nrex tests:\n" ,

( Tests 1-4: Begin/end regular expression matching: )

:: "abc"       rexBegin ; shouldWork
::             rexEnd   ; shouldWork

:: "abcdefghi" rexBegin ; shouldWork
::             rexEnd   ; shouldWork


( Tests 5-12: basic open/close: )

:: -1 rexOpenParen  ; shouldFail
::  0 rexOpenParen  ; shouldWork
::  9 rexOpenParen  ; shouldWork
:: 40 rexOpenParen  ; shouldFail

:: -1 rexCloseParen ; shouldFail
::  0 rexCloseParen ; shouldWork
::  9 rexCloseParen ; shouldWork
:: 40 rexCloseParen ; shouldFail



( Tests 13-25: basic string matches: )
:: "abc"       rexBegin ; shouldWork

:: rexGetCursor 0 = ; shouldBeTrue

:: "a" rexMatchString ; shouldBeTrue
:: rexGetCursor 1 = ; shouldBeTrue

:: "a" rexMatchString ; shouldBeFalse
:: rexGetCursor 1 = ; shouldBeTrue

:: "b" rexMatchString ; shouldBeTrue
:: rexGetCursor 2 = ; shouldBeTrue

:: rexDone? ; shouldBeFalse

:: "c" rexMatchString ; shouldBeTrue
:: rexGetCursor 3 = ; shouldBeTrue

:: rexDone? ; shouldBeTrue

::             rexEnd ; shouldWork



( Tests 26-43: basic char class matches: )

:: "abc"       rexBegin ; shouldWork

:: rexGetCursor 0 = ; shouldBeTrue

:: "b" rexMatchCharClass ; shouldBeFalse
:: rexGetCursor 0 = ; shouldBeTrue

:: "b-zA-Z" rexMatchCharClass ; shouldBeFalse
:: rexGetCursor 0 = ; shouldBeTrue

:: "a" rexMatchCharClass ; shouldBeTrue
:: rexGetCursor 1 = ; shouldBeTrue

:: "a" rexMatchCharClass ; shouldBeFalse
:: rexGetCursor 1 = ; shouldBeTrue

:: "a-b" rexMatchCharClass ; shouldBeTrue
:: rexGetCursor 2 = ; shouldBeTrue

:: "A-Z" rexMatchCharClass ; shouldBeFalse
:: rexGetCursor 2 = ; shouldBeTrue

:: "A-Zc-d" rexMatchCharClass ; shouldBeTrue
:: rexGetCursor 3 = ; shouldBeTrue

:: rexDone? ; shouldBeTrue

::             rexEnd ; shouldWork



( Tests 44-60: basic negated char class matches: )

:: "abc"       rexBegin ; shouldWork

:: rexGetCursor 0 = ; shouldBeTrue

:: "^a" rexMatchCharClass ; shouldBeFalse
:: rexGetCursor 0 = ; shouldBeTrue

:: "^a-zA-Z" rexMatchCharClass ; shouldBeFalse
:: rexGetCursor 0 = ; shouldBeTrue

:: "^B-Zb-z" rexMatchCharClass ; shouldBeTrue
:: rexGetCursor 1 = ; shouldBeTrue

:: "^B-Zb-z" rexMatchCharClass ; shouldBeFalse
:: rexGetCursor 1 = ; shouldBeTrue

:: "^c-zA-Z" rexMatchCharClass ; shouldBeTrue
:: rexGetCursor 2 = ; shouldBeTrue

:: "^c-zA-Z" rexMatchCharClass ; shouldBeFalse
:: rexGetCursor 2 = ; shouldBeTrue

:: "^A-Za-bd-zd" rexMatchCharClass ; shouldBeTrue
:: rexGetCursor 3 = ; shouldBeTrue

:: rexDone? ; shouldBeTrue

::             rexEnd ; shouldWork



( Tests 61-: Basic high-level functionality: )

( :: rex: my abc*[zA-Z][m-t]*|z* )
( ; shouldWork )



:: rex: my /^abc[def]/ ; shouldWork

:: "abcd" my ; shouldBeTrue
:: "abce" my ; shouldBeTrue
:: "abcf" my ; shouldBeTrue
:: "abc"  my ; shouldBeFalse
:: "abcg" my ; shouldBeFalse



:: rex: my /^abc[d-f]/ ; shouldWork

:: "abcd" my ; shouldBeTrue
:: "abce" my ; shouldBeTrue
:: "abcf" my ; shouldBeTrue
:: "abc"  my ; shouldBeFalse
:: "abcg" my ; shouldBeFalse



:: rex: my /^abc|def|ghi/ ; shouldWork

:: "abc" my ; shouldBeTrue
:: "def" my ; shouldBeTrue
:: "ghi" my ; shouldBeTrue
:: "jkl" my ; shouldBeFalse



:: rex: my /^ab*a/ ; shouldWork

:: "aa"         my ; shouldBeTrue
:: "aba"        my ; shouldBeTrue
:: "abba"       my ; shouldBeTrue
:: "abbbba"     my ; shouldBeTrue
:: "abbbbbbbba" my ; shouldBeTrue
:: "aac"        my ; shouldBeTrue
:: ""           my ; shouldBeFalse
:: "a"          my ; shouldBeFalse
:: "aca"        my ; shouldBeFalse



:: rex: my /^a[bc]*d/ ; shouldWork

:: "ad"         my ; shouldBeTrue
:: "abd"        my ; shouldBeTrue
:: "acd"        my ; shouldBeTrue
:: "abcd"       my ; shouldBeTrue
:: "acbd"       my ; shouldBeTrue
:: "acb"        my ; shouldBeFalse



:: rex: my /^a(b*)c/ ; shouldWork

:: "ac" my pop           ; shouldBeTrue
:: "ac" my swap pop "" = ; shouldBeTrue

:: "abc" my pop            ; shouldBeTrue
:: "abc" my swap pop "b" = ; shouldBeTrue

:: "abbc" my pop             ; shouldBeTrue
:: "abbc" my swap pop "bb" = ; shouldBeTrue

:: "adc" my pop           ; shouldBeFalse
:: "adc" my swap pop "" = ; shouldBeTrue



:: rex: my /^a.*b/ ; shouldWork

:: "ab"     my ; shouldBeTrue
:: "acb"    my ; shouldBeTrue
:: "accb"   my ; shouldBeTrue
:: "accccb" my ; shouldBeTrue
:: "ac"     my ; shouldBeFalse



:: rex: my /ghi/ ; shouldWork

:: "ghi"     my ; shouldBeTrue
:: "aaaghi"  my ; shouldBeTrue
:: "ghiaaa"  my ; shouldBeTrue
:: "aaa"     my ; shouldBeFalse



:: rex: my /^abc$/ ; shouldWork

:: "abc"     my ; shouldBeTrue
:: "abcd"    my ; shouldBeFalse



:: rex: my /^a\dc$/ ; shouldWork

:: "a0c"     my ; shouldBeTrue
:: "a9c"     my ; shouldBeTrue
:: "ac"      my ; shouldBeFalse
:: "a00c"    my ; shouldBeFalse
:: "axc"     my ; shouldBeFalse



:: rex: my /^a\Dc$/ ; shouldWork

:: "aac"     my ; shouldBeTrue
:: "a#c"     my ; shouldBeTrue
:: "a,c"     my ; shouldBeTrue
:: "ac"      my ; shouldBeFalse
:: "a0c"     my ; shouldBeFalse
:: "axac"    my ; shouldBeFalse



:: rex: my /^\S\s\S$/ ; shouldWork

:: "a c"     my ; shouldBeTrue
:: "aac"     my ; shouldBeFalse
:: "ac"      my ; shouldBeFalse
:: "a  c"    my ; shouldBeFalse



:: rex: my /^#\w*#$/ ; shouldWork

:: "##"      my ; shouldBeTrue
:: "#abc#"   my ; shouldBeTrue
:: "#ABC#"   my ; shouldBeTrue
:: "#A_C#"   my ; shouldBeTrue

:: "abc"     my ; shouldBeFalse
:: "#;#"     my ; shouldBeFalse



:: rex: my /^#\W*#$/ ; shouldWork

:: "##"      my ; shouldBeTrue
:: "#;;;#"   my ; shouldBeTrue

:: "#A#"     my ; shouldBeFalse
:: "#a#"     my ; shouldBeFalse
:: "#_#"     my ; shouldBeFalse
:: "abc"     my ; shouldBeFalse



:: rex: my /^ab?c$/ ; shouldWork

:: "ac"      my ; shouldBeTrue
:: "abc"     my ; shouldBeTrue
:: "abbc"    my ; shouldBeFalse
:: "ab"      my ; shouldBeFalse



:: rex: my /^ab+c$/ ; shouldWork

:: "ac"      my ; shouldBeFalse
:: "abc"     my ; shouldBeTrue
:: "abbc"    my ; shouldBeTrue
:: "ab"      my ; shouldBeFalse



:: rex: my /^(abc)\1$/ ; shouldWork

:: "abcabc" my pop ; shouldBeTrue
:: "abcacb" my pop ; shouldBeFalse



:: rex: my /^ab{2,4}c$/ ; shouldWork

:: "ac"      my ; shouldBeFalse
:: "abc"     my ; shouldBeFalse
:: "abbc"    my ; shouldBeTrue
:: "abbbc"   my ; shouldBeTrue
:: "abbbbc"  my ; shouldBeTrue
:: "abbbbbc" my ; shouldBeFalse



:: rex: my /^ab{2}c$/ ; shouldWork

:: "abc"     my ; shouldBeFalse
:: "abbc"    my ; shouldBeTrue
:: "abbbc"   my ; shouldBeFalse



:: rex: my /^ab{2,}c$/ ; shouldWork

:: "abc"       my ; shouldBeFalse
:: "abbc"      my ; shouldBeTrue
:: "abbbc"     my ; shouldBeTrue
:: "abbbbbbc"  my ; shouldBeTrue




( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
