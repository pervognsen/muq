( --------------------------------------------------------------------- )
(			x-dh.muf				    CrT )
( Exercise public-key signature related stuff.				)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      99Jul12							)
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
( 99Jul12 jsp	Created.						)
( --------------------------------------------------------------------- )

"Public key signature support function tests\n" log,
"\nPublic key signature support function tests:" ,

(          -k                                                )
(    r = mg   mod p                                          )
(                                                            )
(   s = k - r'x mod q                                        )
(                                                            )
( with the signature verification scheme for recovering m as )
(                                                            )
(        s r'                                                )
(   m = g y  r mod p                                         )
(                                                            )
( Table 20.4 defines r' as r mod q                           )

( So, let's prototype sign and unsign functions and see if   )
( we have the idea right:                                    )

: signIt  { $ $ -> $ $ }
    -> m  ( Message to sign )
    -> x  ( private key, less than q )

    0 -> r
    0 -> s

    ( Generate a random k less than q: )
    158 trulyRandomInteger -> k
"signIt: k=" , k , "\n" ,

    ( I'm taking '-k' to mean p-k: )
    diffieHellman:p k -  -> negk
"signIt: negk=" , negk , "\n" ,

    diffieHellman:g negk diffieHellman:p exptmod m * diffieHellman:p % -> r
"signIt: r=" , r , "\n" ,

    r diffieHellman:q % -> rprime
"signIt: rprime=" , r , "\n" ,

    k rprime x *  - diffieHellman:q % -> s
"signIt: s=" , s , "\n" ,

    
    
    s r
;


: unsignIt  { $ $ $ -> $ }
    -> s  ( signature, second half )
    -> r  ( signature, first  half )
    -> y  ( public key             )

    r diffieHellman:q % -> rprime
"unsignIt: rprime=" , r , "\n" ,

    diffieHellman:g s      diffieHellman:p exptmod
    y               rprime diffieHellman:p exptmod
    *                      diffieHellman:p %
    r *                    diffieHellman:p %
;
