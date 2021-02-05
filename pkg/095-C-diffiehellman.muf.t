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

( - 095-C-diffiehellman.muf -- 						)
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

(  -------------------------------------------------------------------	)
( Author:       Jeff Prothero						)
( Created:      98May15							)
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
( - Select MUF Package:							)

"DIFI" rootValidateDbfile pop
[ "diffieHellman" "dh" .db["DIFI"] | ]inPackage
( [ "diffieHellman" "dh" | ]inPackage )

( =====================================================================	)
( - Constants -								)

( Constants for Diffie-Hellman key distribution, also known as		)
( EKE -- Exponential Key Exchange.					)

( I generated these using cryptolib 1.2 and the C program		)
(									)
(   --------------------------------------------------------------	)
(   #include <stdio.h>							)
(   #include "../src/libcrypt.h"					)
(									)
(   /*									)
(     gcc test.c -L . -lcrypt ../src/longmult.o -o test			)
(   */									)
(									)
(   void								)
(   main(int argc, char**argv) {					)
(    DiffieHellmanSet* s = GenDiffieHellmanSet(1024, 160, NULL);	)
(    fprintf(stdout,"alpha\n");						)
(    fBigPrint(s->alpha,stdout);					)
(    fprintf(stdout,"p\n");						)
(    fBigPrint(s->p,stdout);						)
(    fprintf(stdout,"q\n");						)
(    fBigPrint(s->q,stdout);						)
(    fprintf(stdout,"Whee!\n");						)
(   }									)
(   --------------------------------------------------------------	)
(									)
( modulus1024 is the shared 1024-bit prime modulus for Muq		)
( Diffie-Hellman.  1024 bits is about the minimum size some authors	)
( are now comfortable with, and the maximum size allowed for a DSA	)
( (Digital Signature Algorithm) under the FIPS standard.  I'd like	)
( to leave open the option of using the same modulus for signatures.	)
(									)
( divisor160 is a 160-bit divisor of modulus1024-1.  This isn't needed	)
( for Diffie-Hellman, but would be needed for DSA.			)
(									)
( generator1024 is a generator to go with modulus1024: Various powers	)
( of generator1024 should produce all values from 1 to modulus1024-1	)
( inclusive								)

"0xfc00bec782591c33faebecdbfc3f2798863ba321" makeBignum --> divisor160
'divisor160 export

"0x9149fa7b0c00d8007e6df7ac707e93df9a496c5907e21e715bc0f006638706ef9bde83a927c886a4fc1f62a7788d8332ea4f95eae247383481af71196203ad98482a01a862991650d4d1ce39ccbdb3af3ea11634484bc20d82c89a5539bcb01d80540df2ff5b48bed1a62cce261a389544db9dd5e12bd07e7edf24d233d3c863" makeBignum --> modulus1024
'modulus1024 export

"0x16f3292812888f9139bddb7d1195013079eda50cbf7bcb665e7e8e835c9e39027351ae4e0517f7079407ee9bbee9cbf038bdece4cdd5ea10a11925757877e96762e1cf7badcbcbeb6cc9016b57736b3ee8437a79a76f277d0f799751f8ec686b82d58bbd3abe22c17267599fed231ba24ec780148baa686c5b3350c040ae9de8" makeBignum --> generator1024

( Shorter names for the above, for those as prefers them: )
divisor160    --> q        'q export
modulus1024   --> p        'p export
generator1024 --> g        'g export

( =====================================================================	)
( - functions:								)

( This is interim experimental stuff )

( Bruce Schneier, Applied Cryptography, p 498, gives the unpatented p-NEW )
( signature scheme as: )







( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example


