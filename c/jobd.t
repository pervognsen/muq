@example  @c
/*--   job.c -- Multithreaded-processes / bytecode-intepreter.          */
/*- This file is formatted for outline-minor-mode in emacs19.           */
/*-^C^O^A shows All of file.                                            */
/* ^C^O^Q Quickfolds entire file. (Leaves only top-level headings.)     */
/* ^C^O^T hides all Text. (Leaves all headings.)                        */
/* ^C^O^I shows Immediate children of node.                             */
/* ^C^O^S Shows all of a node.                                          */
/* ^C^O^D hiDes all of a node.                                          */
/* ^HFoutline-mode gives more details.                                  */
/* (Or do ^HI and read emacs:outline mode.)                             */

/************************************************************************/
/*-    Dedication and Copyright.                                        */
/************************************************************************/

/************************************************************************/
/*                                                                      */
/*              For Firiss:  Aefrit, a friend.                          */
/*                                                                      */
/************************************************************************/

/************************************************************************/
/* Author:       Jeff Prothero                                          */
/* Created:      98Oct15 from job.t code.                               */
/* Modified:                                                            */
/* Language:     C                                                      */
/* Package:      N/A                                                    */
/* Status:                                                              */
/*                                                                      */
/* Copyright (c) 1999, by Jeff Prothero.                                */
/*                                                                      */
/* This program is free software; you may use, distribute and/or modify */
/* it under the terms of the GNU Library General Public License as      */
/* published by the Free Software Foundation; either version 2, or (at  */
/* your option) any later version FOR NONCOMMERCIAL PURPOSES.           */
/*                                                                      */
/*  COMMERCIAL operation allowable at $100/CPU/YEAR.                    */
/*  COMMERCIAL distribution (e.g., on CD-ROM) is UNRESTRICTED.          */
/*  Other commercial arrangements NEGOTIABLE.                           */
/*  Contact cynbe@@eskimo.com for a COMMERCIAL LICENSE.                 */
/*                                                                      */
/*   This program is distributed in the hope that it will be useful,    */
/*   but WITHOUT ANY WARRANTY; without even the implied warranty of     */
/*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the      */
/*   GNU Library General Public License for more details.               */
/*                                                                      */
/*   You should have received the GNU Library General Public License    */
/*   along with this program (COPYING.LIB); if not, write to:           */
/*      Free Software Foundation, Inc.                                  */
/*      675 Mass Ave, Cambridge, MA 02139, USA.                         */
/*                                                                      */
/* Jeff Prothero DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, */
/* INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN  */
/* NO EVENT SHALL JEFF PROTHERO BE LIABLE FOR ANY SPECIAL, INDIRECT OR  */
/* CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS  */
/* OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,           */
/* NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION */
/* WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.                        */
/*                                                                      */
/* Please send bug reports/fixes etc to bugs@@muq.org.                  */
/************************************************************************/

/************************************************************************/
/*-    #includes                                                        */
/************************************************************************/

#include "All.h"
#include "jobprims.h"

/* This is a hack to make Crypto/platform.h do the right */
/* thing without editing it (so as to enable users to    */
/* drop in new twofish releases without having to hand-  */
/* edit them):                                           */
#ifndef WORDS_BIGENDIAN
#define _M_IX86 300
#endif

/* Compile the twofish code inline.  This avoids having  */
/* to modify our makefiles when switching between the    */
/* secure and exportable versions of the source code:    */
#include "Crypto/twofish2.c"

/************************************************************************/
/*-    Here(), a dummy function so twofish2.c will link unmodified      */
/************************************************************************/

unsigned long
Here(
    unsigned long x
) {
    unsigned int mask=~0U;
    return (* (((DWORD *)&x)-1)) & mask;
}

/************************************************************************/
/*-    Static fns                                                       */
/************************************************************************/

 /***********************************************************************/
 /*-    get_binary_twofish_key                                          */
 /***********************************************************************/

static void
get_binary_twofish_key(
    Vm_Uch result_buffer[32],
    Vm_Obj shared_secret
) {
    int   i;
    int   k = 0;
    Bnm_P s = BNM_P(shared_secret);
    for (i = 0;  i < 32;   ++i)   result_buffer[i] = 0;
    for (i = 0;  i < 32/VM_INTBYTES && i < s->length;    ++i) {
        Vm_Unt u = s->slot[i];
        int  j;
        for (j = 0;   j < VM_INTBYTES;  ++j) {
            result_buffer[k++] = (u >> (j*8)) & 0xFF;
        }
    }
}

 /***********************************************************************/
 /*-    binary_to_hex                                                   */
 /***********************************************************************/

static void
binary_to_hex(
    Vm_Uch* result_buffer,
    Vm_Uch* binary_buffer,
    Vm_Int  length
) {
    static  Vm_Uch tab[16] = "0123456789abcdef";
    Vm_Uch* src = binary_buffer;
    Vm_Uch* dst = result_buffer;
    int     i;
    for (i = length;  i --> 0; ) {
        Vm_Uch b = *src++;
        *dst++   = tab[ b & 0xF ];
        *dst++   = tab[ b >>  4 ];
    }
    *dst = '\0';
}

/************************************************************************/
/*-    Public fns, true prims for jobprims.c                            */
/************************************************************************/

 /***********************************************************************/
 /*-    job_P_Signed_Digest_Block -- "|signedDigest" operator.          */
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

/******************************************************************/
/* Note that we currently have no defense against replay attacks. */
/* I'm not sure just what is best to do about this, given that    */
/* resends are normal when a UDP packet gets dropped.             */
/*                                                                */
/* Possibly this issue should be dealt with by protocol handlers  */
/* where it is an issue, rather than burdening all protocol       */
/* packets with it?                                               */
/******************************************************************/

void
job_P_Signed_Digest_Block(
    void
) {
    /* Get size of block, verify stack holds that much: */
    Vm_Uch buffer[ MAX_STRING + 128 ];  /* 128==slop. 16 would suffice. */
    Vm_Uch srcbuf[ MAX_STRING + 128 ];
    Vm_Uch dstbuf[ MAX_STRING + 128 ];
    Vm_Int block_size = OBJ_TO_BLK( jS.s[-1] );
    Vm_Obj sharedSecret = jS.s[0];

    job_Guarantee_N_Args(           2 );
    job_Guarantee_Blk_Arg(         -1 );
    job_Guarantee_N_Args(    block_size+3 );
    if (!OBJ_IS_BIGNUM(sharedSecret)
    || BNM_P(sharedSecret)->private != BNM_DIFFIE_HELLMAN_SHARED_SECRET
    ){
        MUQ_WARN("signature argument must be a #<DiffieHellmanSharedSecret>");
    }
 
    if (block_size > MAX_STRING) {
        MUQ_WARN("|signedDigest: Block too long");
    }

    /* Make sure stack has room to add  */
    /* 20 bytes of digest plus up to 16 */
    /* bytes of padding:                */
    /* initialization vector:               */
    job_Guarantee_Headroom( 20+16 );

    {   /* Load stackblock into buffer,      */
        /* meanwhile converting stackblock   */
        /* to chars-only form, whic is what  */
        /* job_Debyte_Muqnet_Header() wants: */
        Vm_Obj*b = &jS.s[ (-block_size)-1 ]; /* Base of our block. */
        Vm_Int header_length = 0;
        Vm_Int bytes_of_padding;
        {   Vm_Int i;
            for   (i = 0;   i < block_size;   ++i) {
                Vm_Obj c = b[i];
                if        (OBJ_IS_CHAR(c)) {
                    buffer[ i ] = OBJ_TO_CHAR(c);
                } else if (OBJ_IS_INT( c)) {
                    buffer[ i ] = OBJ_TO_INT(c);
                    b[i] = OBJ_FROM_CHAR( buffer[i] );
                } else {
                    MUQ_WARN("|signedDigest accepts only chars and fixnums");
                }
            }
        }

        /* Figure length of header -- we have    */
        /* to avoid encrypting the header, since */
        /* the recipient needs the header info   */
        /* in order to construct the decrypt key */
        --jS.s; /* job_Debyte_Muqnet_Header expects block */
                /* to be at top of stack.                 */
        {   Vm_Obj to;
            Vm_Obj from;
	    Vm_Obj fromVersion;
            Vm_Obj opcode;
            Vm_Obj randompad;
            Vm_Int bignum_offset;
            Vm_Int bignum_length;
            job_Debyte_Muqnet_Header(
                &to,
                &from,
		&fromVersion,
                &opcode,
                &randompad,
                &header_length,
                &bignum_offset,
                &bignum_length
            );
        }
        ++jS.s;
        
        /* Twofish encrypts in 128-bit (16-byte) units, */
        /* so pad to-be-encrypted part of message:      */
        {
            /* Figure number of bytes to be encrypted: */
            Vm_Int bytes_of_payload = block_size - header_length;

            /* Figure number of bytes of padding to add. */
            /* Must be at least one byte, so that the    */
            /* final byte can contain count of padbytes: */
            Vm_Int oddbytes  = bytes_of_payload & 0xF;
            bytes_of_padding = oddbytes ? 16-oddbytes: 16;

            /* Add the padding: */
            {   Vm_Int i;
                for   (i = 0;   i < bytes_of_padding;   ++i) {
                    buffer[ block_size + i ] = bytes_of_padding;
        }   }   }


        {   Vm_Uch digest[     20 ];
            Vm_Uch signature[  64 ];    /* 512 bits, SHA block size.    */
            int k   = 0;
            {   Bnm_P s = BNM_P(sharedSecret);
                int  i;
                for (i = 0;  i < 64;   ++i)   signature[i] = 0;
                for (i = 0;  i < 64/VM_INTBYTES && i < s->length;    ++i) {
                    Vm_Unt u = s->slot[i];
                    int  j;
                    for (j = 0;   j < VM_INTBYTES;  ++j) {
                        signature[k++] = (u >> (j*8)) & 0xFF;
                    }
                }
            }

            sha_SignedDigest(
                digest,
                signature,
                buffer,
                block_size + bytes_of_padding
            );

            {   Vm_Uch binarysecret[  32 ]; /* 256 bits, twofish key size.  */
                Vm_Uch asciizsecret[  68 ]; /* Can hold above as asciz hex. */
                Vm_Uch binaryvector[  20 ];
                Vm_Uch asciizvector[  36 ]; /* Can hold above as asciz hex. */
                keyInstance    key;
                cipherInstance cipher;
                int errcode;

                /* Turn sharedSecret into key: */
                get_binary_twofish_key( binarysecret, sharedSecret     );
                binary_to_hex(          asciizsecret, binarysecret, 32 );
                errcode = makeKey(
                    &key,           /* Returns result here. */
                    DIR_ENCRYPT,    /* We're encrypting, not decrypting. */
                    256,            /* key length in bits.               */
                    asciizsecret    /* key as null-terminated hex ascii. */
                );
                if (errcode != TRUE) {
                    MUQ_WARN("|signedDigest: makeKey failed, err %d",errcode);
                }


                /* Set up twofish module: */

                /* Convert 16-byte initialization vector */
                /* to null-terminated ASCII form (asciz) */
                /* that the twofish code wants.  We take */
                /* as our initialization vector a header */
                /* chunk including the randompad if we   */
                /* have a normal muqnet packet otherwise */
                /* a string of zero bytes:               */
                if (header_length <= 16) {
                    int i; for (i = 16; i --> 0;) binaryvector[i]=0;
                    binary_to_hex( asciizvector, &binaryvector[ 0        ], 16 );
                } else {
                    binary_to_hex( asciizvector, &buffer[header_length-16], 16 );
                }
                errcode = cipherInit(
                    &cipher,            /* Result gets returned here    */
                    MODE_CBC,           /* Cipher Block Chaining        */
                    asciizvector        /* Initialization Vector        */
                );
                if (errcode != TRUE) {
                    MUQ_WARN("|signedDigest: cipherInit failed, err %d",errcode);
                }

                /* Encrypt the block payload -- everything */
                /* but header and signature:               */
                {   int bytes_to_encrypt = (block_size + bytes_of_padding) - header_length;
                    int bits_encrypted;
                    int i;
		    /* blockEncrypt needs input to be    */
		    /* quadbyte aligned, except on i86,  */
		    /* so copy payload to srcbuf:        */
		    for (i = bytes_to_encrypt;   i --> 0;   ) {
			srcbuf[i] = buffer[i+header_length];
		    }
                    bits_encrypted = blockEncrypt(
                        &cipher,
                        &key,
                        srcbuf,                 /* Input data      */
                        bytes_to_encrypt << 3,  /* Bits to encrypt */
                        dstbuf
                    );
                    if (bits_encrypted < 0) {
                        MUQ_WARN("|signedDigest: blockEncrypt failed, err %d",bits_encrypted);
                    }

                    {   int  i;
                        for (i = 0;   i < bytes_to_encrypt;   ++i) {
                            buffer[ header_length + i ] = dstbuf[ i ];
            }   }   }   }

            /* Revalidate 'b', which may have been trashed by */
            /* above BNP_P() and/or get_binary_twofish_key(): */
            b = &jS.s[ (-block_size)-1 ]; /* Base of block.   */

            /* Copy results from buffer[] back to stack: */
            {   /* Copy block proper, plus padding: */
                int  i;
                for (i = 0;   i < block_size+bytes_of_padding;   ++i) {
                    b[ i ] = OBJ_FROM_CHAR( buffer[i] );
                }
                /* Append the digest: */
                for (i = 0;   i < 20;   ++i) {
                    b[ block_size+bytes_of_padding +i ] = OBJ_FROM_CHAR(digest[i]);
                }
            }
            jS.s += bytes_of_padding+19; /* +19 not +20 cause we drop secret */
           *jS.s  = OBJ_FROM_BLK( block_size + 20 + bytes_of_padding );
        }
    }
}

 /***********************************************************************/
 /*-    job_P_Signed_Digest_Check_Block -- "|signedDigestCheck" fn      */
 /***********************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Signed_Digest_Check_Block(
    void
) {
    Vm_Int header_length = 0;

    /* Get size of block, verify stack holds that much: */
    Vm_Uch buffer[ MAX_STRING + 128 ];
    Vm_Uch srcbuf[ MAX_STRING + 128 ];
    Vm_Uch dstbuf[ MAX_STRING + 128 ];
    Vm_Int block_size = OBJ_TO_BLK( jS.s[-1] );
    Vm_Obj sharedSecret = jS.s[0];

    job_Guarantee_N_Args(               2 );
    job_Guarantee_Blk_Arg(             -1 );
    job_Guarantee_N_Args(    block_size+3 );
    if (block_size > MAX_STRING) {
        MUQ_WARN("|signedDigestCheck: Block too long");
    }
    if (block_size < 20) {
        MUQ_WARN("|signedDigestCheck: Block too short");
    }
    if (!OBJ_IS_BIGNUM(sharedSecret)
    || BNM_P(sharedSecret)->private != BNM_DIFFIE_HELLMAN_SHARED_SECRET
    ){
        MUQ_WARN("signature argument must be a #<DiffieHellmanSharedSecret>");
    }

    {   Vm_Obj* b = &jS.s[ (-block_size)-1 ]; /* Base of our block. */
        Vm_Uch old_digest[ 20 ];
        Vm_Int i;
        Vm_Uch signature[  64 ];        /* 512 bits, SHA block size.    */
        int k   = 0;
        {   Bnm_P s = BNM_P(sharedSecret);
            for (i = 0;  i < 64;   ++i)   signature[i] = 0;
            for (i = 0;  i < 64/VM_INTBYTES && i < s->length;    ++i) {
                Vm_Unt u = s->slot[i];
                int  j;
                for (j = 0;   j < VM_INTBYTES;  ++j) {
                    signature[k++] = (u >> (j*8)) & 0xFF;
                }
            }
        }
        for   (i = 0;   i < 20;   ++i) {
            Vm_Int j = (block_size-20)+i;
            Vm_Obj c = b[j];
            if        (OBJ_IS_CHAR(c)) {
                old_digest[ i ] = OBJ_TO_CHAR(c);
            } else if (OBJ_IS_INT( c)) {
                old_digest[ i ] = OBJ_TO_INT(c);
            } else {
                MUQ_WARN("|signedDigestCheck accepts only chars and ints");
            }
        }

        for   (i = 0;   i < block_size-20;   ++i) {
            Vm_Obj c = b[i];
            if        (OBJ_IS_CHAR(c)) {
                buffer[ i ] = OBJ_TO_CHAR(c);
            } else if (OBJ_IS_INT( c)) {
                buffer[ i ] = OBJ_TO_INT(c);
            } else {
                MUQ_WARN("|signedDigestCheck accepts only chars and ints");
            }
        }

        /* Figure length of header -- we have    */
        /* to avoid encrypting the header, since */
        /* the recipient needs the header info   */
        /* in order to construct the decrypt key */
        --jS.s; /* job_Debyte_Muqnet_Header expects block */
                /* to be at top of stack.                 */
        {   Vm_Obj to;
            Vm_Obj from;
	    Vm_Obj fromVersion;
            Vm_Obj opcode;
            Vm_Obj randompad;
            Vm_Int bignum_offset;
            Vm_Int bignum_length;
            job_Debyte_Muqnet_Header(
                &to,
                &from,
		&fromVersion,
                &opcode,
                &randompad,
                &header_length,
                &bignum_offset,
                &bignum_length
            );
        }
        ++jS.s;

        {   Vm_Uch binarysecret[  32 ]; /* 256 bits, twofish key size.  */
            Vm_Uch asciizsecret[  68 ]; /* Can hold above as asciz hex. */
            Vm_Uch binaryvector[  20 ];
            Vm_Uch asciizvector[  36 ]; /* Can hold above as asciz hex. */
            keyInstance    key;
            cipherInstance cipher;
            int errcode;

            /* Turn sharedSecret into key: */
            get_binary_twofish_key( binarysecret, sharedSecret     );
            binary_to_hex(          asciizsecret, binarysecret, 32 );
            errcode = makeKey(
                &key,           /* Returns result here. */
                DIR_DECRYPT,    /* We're decrypting, not encrypting. */
                256,            /* key length in bits.           */
                asciizsecret    /* key as null-terminated hex ascii. */
            );
            if (errcode != TRUE) {
                MUQ_WARN("|signedDigestCheck: makeKey failed, err %d",errcode);
            }


            /* Set up twofish module: */

            /* Convert 16-byte initialization vector */
            /* to null-terminated ASCII form (asciz) */
            /* that the twofish code wants.  We take */
            /* as our initialization vector a header */
            /* chunk including the randompad if we   */
            /* have a normal muqnet packet otherwise */
            /* a string of zero bytes:               */
            if (header_length <= 16) {
                int i; for (i = 16; i --> 0;) binaryvector[i]=0;
                binary_to_hex( asciizvector, &binaryvector[ 0        ], 16 );
            } else {
                binary_to_hex( asciizvector, &buffer[header_length-16], 16 );
            }
            errcode = cipherInit(
                &cipher,                /* Result gets returned here    */
                MODE_CBC,               /* Cipher Block Chaining        */
                asciizvector            /* Initialization Vector        */
            );
            if (errcode != TRUE) {
                MUQ_WARN("|signedDigestCheck: cipherInit failed, err %d",errcode);
            }

            /* Decrypt the block payload -- everything */
            /* but header and signature:               */
            {   int bytes_to_decrypt = block_size - (header_length+20);
                int bits_decrypted;
                int i;
		/* blockDecrypt needs input to be   */
		/* quadbyte aligned, except on i86, */
		/* so copy payload to srcbuf:       */
		for (i = bytes_to_decrypt;   i --> 0;   ) {
		    srcbuf[i] = buffer[i+header_length];
		}
                bits_decrypted = blockDecrypt(
                    &cipher,
                    &key,
                    &buffer[header_length],     /* Input data      */
                    bytes_to_decrypt << 3,      /* Bits to decrypt */
                    dstbuf
                );
                if (bits_decrypted < 0) {
                    MUQ_WARN("|signedDigestCheck: blockDecrypt failed, err %d",bits_decrypted);
                }
                {   int  i;
                    for (i = 0;   i < bytes_to_decrypt;   i++) {
                        buffer[ header_length + i ] = dstbuf[ i ];
        }   }   }   }

        /* Revalidate 'b', which may have been trashed */
        /* by above get_binary_twofish_key():          */
        b = &jS.s[ (-block_size)-1 ]; /* Base of our block. */

        /* Copy results from buffer[] back to stack: */
        {   /* Copy block proper, plus padding: */
            int  i;
            for (i = block_size-20;   i --> 0; ) {
                b[ i ] = OBJ_FROM_CHAR( buffer[i] );
        }   }

        {   Vm_Uch digest[ 20 ];
            Vm_Int differ = FALSE;
            sha_SignedDigest( digest, signature, buffer, block_size-20 );
            for (i = 0;   i < 20;   ++i) {
                differ |= (old_digest[i] != digest[i]);
            }

            /* Drop the 20-byte digest plus padding: */
            {   Vm_Unt bytes_of_padding = buffer[ block_size-21 ];

                /* Watch for maliciously broken packets: */
                if (bytes_of_padding > block_size-20) {
                    bytes_of_padding = block_size-20;
                }

                jS.s    -= 20 + bytes_of_padding;
                jS.s[ 0] = OBJ_FROM_BLK( block_size - (19+bytes_of_padding) );
                jS.s[-1] = OBJ_FROM_BOOL( differ );
            }
        }
    }
}

/************************************************************************/
/*-    File variables                                                   */
/************************************************************************/
/*

Local variables:
mode: c
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/


@end example
