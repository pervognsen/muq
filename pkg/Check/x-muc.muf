( --------------------------------------------------------------------- )
(			x-muc.muf				    CrT )
( Exercise Muq "Multi-User C" compiler stuff.				)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      99Sep11							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 2000, by Jeff Prothero.				)
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
( 99Sep11 jsp	Created.						)
( --------------------------------------------------------------------- )

"Multi-User C compiler tests\n" log,
"\nMulti-User C compiler tests:" ,

"muc" inPackage

( Test basic arithmetic: )
::   "^2+3;"     evalString    5 = ; shouldBeTrue
::   "^2*3;"     evalString    6 = ; shouldBeTrue
::   "^7*(5-3);" evalString   14 = ; shouldBeTrue
::   "^9%2;"     evalString    1 = ; shouldBeTrue
::   "^9/2;"     evalString    4 = ; shouldBeTrue
::   "^-(2-4);"  evalString    2 = ; shouldBeTrue
::   "^2**10;"   evalString 1024 = ; shouldBeTrue
::   "^1<<10;"   evalString 1024 = ; shouldBeTrue
::   "^1<2;"     evalString        ; shouldBeTrue
::   "^1<=1;"    evalString        ; shouldBeTrue
::   "^2<=1;"    evalString        ; shouldBeFalse
::   "^1>=1;"    evalString        ; shouldBeTrue
::   "^1>=2;"    evalString        ; shouldBeFalse
::   "^6&3;"     evalString    2 = ; shouldBeTrue
::   "^7^2;"     evalString    5 = ; shouldBeTrue
::   "^5|2;"     evalString    7 = ; shouldBeTrue

( Try abs(): )
::   "{float f=-1.0; ^abs(f);}" evalString  1.0 = ; shouldBeTrue
::   "{float f=-1.0; ^|f;}"     evalString  1.0 = ; shouldBeTrue

( Test local variable declarations: )
::   "{obj  x=2;obj  y=10;obj  z=x**y;^z;}"  evalString 1024 = ; shouldBeTrue
::   "{bit  x=2;bit  y=10;bit  z=x**y;^z;}"  evalString 1024 = ; shouldBeTrue
::   "{byte x=2;byte y=10;byte z=x**y;^z;}"  evalString 1024 = ; shouldBeTrue
::   "{char x=2;char y=10;char z=x**y;^z;}"  evalString 1024 = ; shouldBeTrue
::   "{int  x=2;int  y=10;int  z=x**y;^z;}"  evalString 1024 = ; shouldBeTrue
::   "{float x=2.0;int y=10.0;float z=x**y;^z;}"  evalString 1024.0 = ; shouldBeTrue
::   "{double x=2.0;double y=10.0;double z=x**y;^z;}"  evalString 1024.0 = ; shouldBeTrue

( Test if-then: )
::   "{int a=2;int b=3;int z=4;if (a<b) z=5;^z;}" evalString 5 = ; shouldBeTrue
::   "{int a=3;int b=2;int z=4;if (a<b) z=5;^z;}" evalString 4 = ; shouldBeTrue

( Test if-then-else: )
::   "{int a=2;int b=3;int z=4;if (a<b) z=5;else z=6;^z;}" evalString 5 = ; shouldBeTrue
::   "{int a=3;int b=2;int z=4;if (a<b) z=5;else z=6;^z;}" evalString 6 = ; shouldBeTrue

( Test 'while', 'do' and 'for' loops: )
::   "{int a=4;int i=0;while (a>0) { a=a-1; i=i+1; } ^i;}" evalString 4 = ; shouldBeTrue
::   "{int a=4;int i=0;do { a=a-1; i=i+1; } while (a>0); ^i;}" evalString 4 = ; shouldBeTrue
::   "{int a;int i=0; for (a=4;a>0;a=a-1) { i=i+1; } ^i;}" evalString 4 = ; shouldBeTrue

( Test conditional expression: )
::   "{int i=(2<3) ? 4 : 5;^i;}" evalString 4 = ; shouldBeTrue
::   "{;int i=(3<2) ? 4 : 5;^i;}" evalString 5 = ; shouldBeTrue

( Test short-circuit expressions: )
::   "^ 2<3 && 3<4;" evalString ; shouldBeTrue
::   "^ 2<3 && 4<3;" evalString ; shouldBeFalse
::   "^ 3<2 && 3<4;" evalString ; shouldBeFalse
::   "^ 3<2 && 4<3;" evalString ; shouldBeFalse
::   "^ 2<3 || 3<4;" evalString ; shouldBeTrue
::   "^ 2<3 || 4<3;" evalString ; shouldBeTrue
::   "^ 3<2 || 3<4;" evalString ; shouldBeTrue
::   "^ 3<2 || 4<3;" evalString ; shouldBeFalse

( Test 'break': )
::   "{int i;for (i=0;i<10;i=i+1){if(i==5)break;}^i;}"   evalString 5 = ; shouldBeTrue
::   "{int i=0;while(i<10) {i=i+1;if(i==5)break;}^i;}"   evalString 5 = ; shouldBeTrue
::   "{int i=0;do{i=i+1;if(i==5)break;}while(i<10);^i;}" evalString 5 = ; shouldBeTrue

( Test 'continue': )
::   "{int i;for (i=0;i<10;i=i+1){if(i==5)break;continue;i=11;}^i;}"   evalString 5 = ; shouldBeTrue
::   "{int i=0;while(i<10){i=i+1;if(i==5)break;continue;i=11;}^i;}"    evalString 5 = ; shouldBeTrue
::   "{int i=0;do{i=i+1;if(i==5)break;continue;i=11;}while(i<10);^i;}" evalString 5 = ; shouldBeTrue

( Test 'return': )
::   "{int i;for(i=0;i<10;i=i+1){if(i==5)return 17;}^i;}"            evalString 17 = ; shouldBeTrue
::   "{int i;for(i=0;i<10;i=i+1){if(i==5)^17;}^i;}"                  evalString 17 = ; shouldBeTrue

( Test 'a.b': )
:: "{obj x=makeIndex();x.a=13;^x.a;}" evalString 13 = ; shouldBeTrue

( Test 'a[b]': )
:: "{obj x=makeIndex();x[7]=11;^x[7];}" evalString 11 = ; shouldBeTrue
:: "{obj x=makeIndex();x['a']='z';^x['a'];}" evalString 'z' = ; shouldBeTrue
:: "{int x[]=makeVector(10,10);x[3]=9;^x[3];}" evalString 9 = ; shouldBeTrue

( Test basic scoping: )
:: "{{int i=5;^i;}}" evalString 5 = ; shouldBeTrue
:: "{{int i=5;}^i;}" evalString 5 = ; shouldFail

( Test basic assign-ops: )
:: "{int i=3;i+=4;^i;}" evalString 7 = ; shouldBeTrue

( Test basic in/decrements: )
:: "{int i=3;i++;^i;}" evalString 4 = ; shouldBeTrue
:: "{int i=3;int j=i++ + i++;^j;}" evalString 6 = ; shouldBeTrue
:: "{int i=3;int j=++i + ++i;^j;}" evalString 10 = ; shouldBeTrue
:: "{int i;for (i=0;i<10;i++){if(i==5)break;}^i;}" evalString 5 = ; shouldBeTrue


( Test vector construction syntax: )

:: "^{1,2,3};"                evalString vector?    ; shouldBeTrue
:: "^(obj*){1,2,3};"          evalString vector?    ; shouldBeTrue
:: "^(char*){1,2,3};"         evalString vectorI08? ; shouldBeTrue
:: "^(short*){1,2,3};"        evalString vectorI16? ; shouldBeTrue
:: "^(int*){1,2,3};"          evalString vectorI32? ; shouldBeTrue
:: "^(float*){1.1,2.2,3.3};"  evalString vectorF32? ; shouldBeTrue
:: "^(double*){1.1,2.2,3.3};" evalString vectorF64? ; shouldBeTrue

:: "^{1,2,3};"                evalString length 3 = ; shouldBeTrue
:: "^(obj*){1,2,3};"          evalString length 3 = ; shouldBeTrue
:: "^(char*){1,2,3};"         evalString length 3 = ; shouldBeTrue
:: "^(short*){1,2,3};"        evalString length 3 = ; shouldBeTrue
:: "^(int*){1,2,3};"          evalString length 3 = ; shouldBeTrue
:: "^(float*){1.1,2.2,3.3};"  evalString length 3 = ; shouldBeTrue
:: "^(double*){1.1,2.2,3.3};" evalString length 3 = ; shouldBeTrue

( Test case-insensitive string compares: )
:: "^ \"abc\" eq \"ABC\";" evalString ; shouldBeTrue

( Test basic function definition syntax: )
:: "{int myfn(void){^13;} ^myfn();}" evalString 13 = ; shouldBeTrue
:: "{int myfn(a,b){^a+b;} ^myfn(3,4);}" evalString 7 = ; shouldBeTrue
:: "{int myfn(int a,int b){^a+b;} ^myfn(3,4);}" evalString 7 = ; shouldBeTrue



( Test basic vector functions: )

( Cross product: )
:: "{obj v = {1.0,0.0,0.0} >< {0.0,1.0,0.0}; ^v[0];}" evalString 0.0 = ; shouldBeTrue
:: "{obj v = {1.0,0.0,0.0} >< {0.0,1.0,0.0}; ^v[1];}" evalString 0.0 = ; shouldBeTrue
:: "{obj v = {1.0,0.0,0.0} >< {0.0,1.0,0.0}; ^v[2];}" evalString 1.0 = ; shouldBeTrue

( Dot product: )
:: "^ {2.0,2.0,2.0} ! {2.0,2.0,2.0};" evalString 12.0 = ; shouldBeTrue

( Magnitude: )
:: "^ magnitude( {1.0,1.0,1.0} );" evalString 1.732 > ; shouldBeTrue
:: "^ magnitude( {1.0,1.0,1.0} );" evalString 1.733 < ; shouldBeTrue

:: "{obj v = {1.0,1.0,1.0}; return =v;}" evalString 1.732 > ; shouldBeTrue
:: "{obj v = {1.0,1.0,1.0}; return =v;}" evalString 1.733 < ; shouldBeTrue

( Distance: )
:: "^ distance( {0.0,0.0,0.0}, {1.0,1.0,1.0} );"  evalString 1.732 > ; shouldBeTrue
:: "^ distance( {0.0,0.0,0.0}, {1.0,1.0,1.0} );"  evalString 1.733 < ; shouldBeTrue



( Normalize: )

:: "{obj v = normalize( {1.0,1.0,1.0} ); ^v[0];}"  evalString 0.577 > ; shouldBeTrue
:: "{obj v = normalize( {1.0,1.0,1.0} ); ^v[0];}"  evalString 0.578 < ; shouldBeTrue

:: "{obj v = normalize( {1.0,1.0,1.0} ); ^v[1];}"  evalString 0.577 > ; shouldBeTrue
:: "{obj v = normalize( {1.0,1.0,1.0} ); ^v[1];}"  evalString 0.578 < ; shouldBeTrue

:: "{obj v = normalize( {1.0,1.0,1.0} ); ^v[2];}"  evalString 0.577 > ; shouldBeTrue
:: "{obj v = normalize( {1.0,1.0,1.0} ); ^v[2];}"  evalString 0.578 < ; shouldBeTrue



( Approximate comparison: )

:: "^ 1.0      == 1.0;" evalString ; shouldBeTrue
:: "^ 1.0      ~  1.0;" evalString ; shouldBeTrue
:: "^ 1.000001 == 1.0;" evalString ; shouldBeFalse 
:: "^ 1.000001 ~  1.0;" evalString ; shouldBeTrue
:: "^ 1.000001 ~  2.0;" evalString ; shouldBeFalse



( Vector arithmetic: )

:: "{obj v = - {1.0,2.0,3.0}; ^v[0];}" evalString -1.0 = ; shouldBeTrue
:: "{obj v = - {1.0,2.0,3.0}; ^v[1];}" evalString -2.0 = ; shouldBeTrue
:: "{obj v = - {1.0,2.0,3.0}; ^v[2];}" evalString -3.0 = ; shouldBeTrue


:: "{obj v = 1.0 + {1.0,2.0,3.0}; ^v[0];}" evalString 2.0 = ; shouldBeTrue
:: "{obj v = 1.0 + {1.0,2.0,3.0}; ^v[1];}" evalString 3.0 = ; shouldBeTrue
:: "{obj v = 1.0 + {1.0,2.0,3.0}; ^v[2];}" evalString 4.0 = ; shouldBeTrue

:: "{obj v = {1.0,2.0,3.0} + 1.0; ^v[0];}" evalString 2.0 = ; shouldBeTrue
:: "{obj v = {1.0,2.0,3.0} + 1.0; ^v[1];}" evalString 3.0 = ; shouldBeTrue
:: "{obj v = {1.0,2.0,3.0} + 1.0; ^v[2];}" evalString 4.0 = ; shouldBeTrue

:: "{obj v = {1.0,2.0,3.0} + {2.0,4.0,6.0}; ^v[0];}" evalString 3.0 = ; shouldBeTrue
:: "{obj v = {1.0,2.0,3.0} + {2.0,4.0,6.0}; ^v[1];}" evalString 6.0 = ; shouldBeTrue
:: "{obj v = {1.0,2.0,3.0} + {2.0,4.0,6.0}; ^v[2];}" evalString 9.0 = ; shouldBeTrue


:: "{obj v = 2.0 * {1.0,2.0,3.0}; ^v[0];}" evalString 2.0 = ; shouldBeTrue
:: "{obj v = 2.0 * {1.0,2.0,3.0}; ^v[1];}" evalString 4.0 = ; shouldBeTrue
:: "{obj v = 2.0 * {1.0,2.0,3.0}; ^v[2];}" evalString 6.0 = ; shouldBeTrue

:: "{obj v = {1.0,2.0,3.0} * 2.0; ^v[0];}" evalString 2.0 = ; shouldBeTrue
:: "{obj v = {1.0,2.0,3.0} * 2.0; ^v[1];}" evalString 4.0 = ; shouldBeTrue
:: "{obj v = {1.0,2.0,3.0} * 2.0; ^v[2];}" evalString 6.0 = ; shouldBeTrue

:: "{obj v = {1.0,2.0,3.0} * {2.0,4.0,6.0}; ^v[0];}" evalString  2.0 = ; shouldBeTrue
:: "{obj v = {1.0,2.0,3.0} * {2.0,4.0,6.0}; ^v[1];}" evalString  8.0 = ; shouldBeTrue
:: "{obj v = {1.0,2.0,3.0} * {2.0,4.0,6.0}; ^v[2];}" evalString 18.0 = ; shouldBeTrue


:: "{obj v = 9.0 - {1.0,2.0,3.0}; ^v[0];}" evalString 8.0 = ; shouldBeTrue
:: "{obj v = 9.0 - {1.0,2.0,3.0}; ^v[1];}" evalString 7.0 = ; shouldBeTrue
:: "{obj v = 9.0 - {1.0,2.0,3.0}; ^v[2];}" evalString 6.0 = ; shouldBeTrue

:: "{obj v = {7.0,8.0,9.0} - 1.0; ^v[0];}" evalString 6.0 = ; shouldBeTrue
:: "{obj v = {7.0,8.0,9.0} - 1.0; ^v[1];}" evalString 7.0 = ; shouldBeTrue
:: "{obj v = {7.0,8.0,9.0} - 1.0; ^v[2];}" evalString 8.0 = ; shouldBeTrue

:: "{obj v = {7.0,8.0,9.0} - {5.0,4.0,3.0}; ^v[0];}" evalString  2.0 = ; shouldBeTrue
:: "{obj v = {7.0,8.0,9.0} - {5.0,4.0,3.0}; ^v[1];}" evalString  4.0 = ; shouldBeTrue
:: "{obj v = {7.0,8.0,9.0} - {5.0,4.0,3.0}; ^v[2];}" evalString  6.0 = ; shouldBeTrue


:: "{obj v = {2.0,4.0,6.0} / 2.0; ^v[0];}" evalString 1.0 = ; shouldBeTrue
:: "{obj v = {2.0,4.0,6.0} / 2.0; ^v[1];}" evalString 2.0 = ; shouldBeTrue
:: "{obj v = {2.0,4.0,6.0} / 2.0; ^v[2];}" evalString 3.0 = ; shouldBeTrue

:: "{obj v = 24.0 / {2.0,3.0,4.0}; ^v[0];}" evalString 12.0 = ; shouldBeTrue
:: "{obj v = 24.0 / {2.0,3.0,4.0}; ^v[1];}" evalString  8.0 = ; shouldBeTrue
:: "{obj v = 24.0 / {2.0,3.0,4.0}; ^v[2];}" evalString  6.0 = ; shouldBeTrue

:: "{obj v = {48.0,24.0,12.0} / {2.0,3.0,4.0}; ^v[0];}" evalString 24.0 = ; shouldBeTrue
:: "{obj v = {48.0,24.0,12.0} / {2.0,3.0,4.0}; ^v[1];}" evalString  8.0 = ; shouldBeTrue
:: "{obj v = {48.0,24.0,12.0} / {2.0,3.0,4.0}; ^v[2];}" evalString  3.0 = ; shouldBeTrue


:: "{obj v = {5.0,6.0,7.0} % 4.0; ^v[0];}" evalString 1.0 = ; shouldBeTrue
:: "{obj v = {5.0,6.0,7.0} % 4.0; ^v[1];}" evalString 2.0 = ; shouldBeTrue
:: "{obj v = {5.0,6.0,7.0} % 4.0; ^v[2];}" evalString 3.0 = ; shouldBeTrue

:: "{obj v = 7.0 % {2.0,4.0,5.0}; ^v[0];}" evalString  1.0 = ; shouldBeTrue
:: "{obj v = 7.0 % {2.0,4.0,5.0}; ^v[1];}" evalString  3.0 = ; shouldBeTrue
:: "{obj v = 7.0 % {2.0,4.0,5.0}; ^v[2];}" evalString  2.0 = ; shouldBeTrue

:: "{obj v = {7.0,8.0,9.0} % {2.0,3.0,4.0}; ^v[0];}" evalString 1.0 = ; shouldBeTrue
:: "{obj v = {7.0,8.0,9.0} % {2.0,3.0,4.0}; ^v[1];}" evalString 2.0 = ; shouldBeTrue
:: "{obj v = {7.0,8.0,9.0} % {2.0,3.0,4.0}; ^v[2];}" evalString 1.0 = ; shouldBeTrue


:: "^ {4.0,4.0,4.0} ~ 4.0;"      evalString ; shouldBeTrue
:: "^ {5.0,4.0,4.0} ~ 4.0;"      evalString ; shouldBeFalse
:: "^ {4.0,5.0,4.0} ~ 4.0;"      evalString ; shouldBeFalse
:: "^ {4.0,4.0,5.0} ~ 4.0;"      evalString ; shouldBeFalse
:: "^ {1.0,1.0,1.0} ~ 1.000001;" evalString ; shouldBeTrue

:: "^ 4.0      ~ {4.0,4.0,4.0};" evalString ; shouldBeTrue
:: "^ 4.0      ~ {5.0,4.0,4.0};" evalString ; shouldBeFalse
:: "^ 4.0      ~ {4.0,5.0,4.0};" evalString ; shouldBeFalse
:: "^ 4.0      ~ {4.0,4.0,5.0};" evalString ; shouldBeFalse
:: "^ 1.000001 ~ {1.0,1.0,1.0};" evalString ; shouldBeTrue

:: "^ {4.0,4.0,4.0} ~ {4.0,4.0,4.0};"      evalString ; shouldBeTrue
:: "^ {5.0,4.0,4.0} ~ {4.0,4.0,4.0};"      evalString ; shouldBeFalse
:: "^ {4.0,5.0,4.0} ~ {4.0,4.0,4.0};"      evalString ; shouldBeFalse
:: "^ {4.0,4.0,5.0} ~ {4.0,4.0,4.0};"      evalString ; shouldBeFalse
:: "^ {4.0,4.0,4.0} ~ {5.0,4.0,4.0};"      evalString ; shouldBeFalse
:: "^ {4.0,4.0,4.0} ~ {4.0,5.0,4.0};"      evalString ; shouldBeFalse
:: "^ {4.0,4.0,4.0} ~ {4.0,4.0,5.0};"      evalString ; shouldBeFalse
:: "^ {1.0,1.0,1.0} ~ {1.000001,1.000001,1.000001};"      evalString ; shouldBeTrue



( Basic ray-hits-sphere raytracing: )

:: [ 0.0 0.0 0.0 ]   [  0.0 1.0 0.0 ]   [ 3.0 0.0 0.0 ]   1.0   rayHitsSphereAt pop ; shouldBeFalse
:: [ 0.0 0.0 0.0 ]   [ -1.0 0.0 0.0 ]   [ 3.0 0.0 0.0 ]   1.0   rayHitsSphereAt pop ; shouldBeFalse

:: [ 0.0 0.0 0.0 ]   [  1.0 0.0 0.0 ]   [ 3.0 0.0 0.0 ]   1.0   rayHitsSphereAt pop -> v  v[0] 2.0 nearlyEqual ; shouldBeTrue
:: [ 0.0 0.0 0.0 ]   [  1.0 0.0 0.0 ]   [ 3.0 0.0 0.0 ]   1.0   rayHitsSphereAt pop -> v  v[1] 0.0 nearlyEqual ; shouldBeTrue
:: [ 0.0 0.0 0.0 ]   [  1.0 0.0 0.0 ]   [ 3.0 0.0 0.0 ]   1.0   rayHitsSphereAt pop -> v  v[2] 0.0 nearlyEqual ; shouldBeTrue






"muf" inPackage

( ===================================================================== )
( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
