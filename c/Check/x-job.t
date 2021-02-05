@example  @c
/*--   x-job.c -- eXerciser for job.c.					*/
/* This file is formatted for emacs' outline-minor-mode.		*/




/************************************************************************/
/*-    Dedication and Copyright.					*/
/************************************************************************/

/************************************************************************/
/*									*/
/*		For Firiss:  Aefrit, a friend.				*/
/*									*/
/************************************************************************/

/************************************************************************/
/* Author:       Jeff Prothero						*/
/* Created:      93Feb15						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1993-1995, by Jeff Prothero.				*/
/*									*/
/* This program is free software; you may use, distribute and/or modify	*/
/* it under the terms of the GNU Library General Public License as      */
/* published by	the Free Software Foundation; either version 2, or (at  */
/* your option)	any later version FOR NONCOMMERCIAL PURPOSES.		*/
/*									*/
/*  COMMERCIAL operation allowable at $100/CPU/YEAR.			*/
/*  COMMERCIAL distribution (e.g., on CD-ROM) is UNRESTRICTED.		*/
/*  Other commercial arrangements NEGOTIABLE.				*/
/*  Contact cynbe@eskimo.com for a COMMERCIAL LICENSE.			*/
/*									*/
/*   This program is distributed in the hope that it will be useful,	*/
/*   but WITHOUT ANY WARRANTY; without even the implied warranty of	*/
/*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the	*/
/*   GNU Library General Public License for more details.		*/
/*									*/
/*   You should have received the GNU Library General Public License	*/
/*   along with this program (COPYING.LIB); if not, write to:		*/
/*      Free Software Foundation, Inc.					*/
/*      675 Mass Ave, Cambridge, MA 02139, USA.				*/
/*									*/
/* Jeff Prothero DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,	*/
/* INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN	*/
/* NO EVENT SHALL JEFF PROTHERO BE LIABLE FOR ANY SPECIAL, INDIRECT OR	*/
/* CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS	*/
/* OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,		*/
/* NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION	*/
/* WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.			*/
/*									*/
/* Please send bug reports/fixes etc to bugs@muq.org.			*/
/************************************************************************/




/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* What to do on fatal error:						*/
#ifndef JOB_FATAL
#define JOB_FATAL(x) {fprintf(stderr, (x));abort();}
#endif

/* Size for the buffers we put code/string in: */
#define BUF_MAX (0x8000)



/************************************************************************/
/*-    Types								*/
/************************************************************************/

struct Buf_rec {
    Vm_Chr  byte0[ BUF_MAX ];
    Vm_Chr* bytei;
};
typedef struct Buf_rec A_Buf;
typedef struct Buf_rec*  Buf;



/************************************************************************/
/*-    Globals								*/
/************************************************************************/



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

static void put_byte(Buf,Vm_Int);
static void startup(  void );
void usage( void );
static void muq_shutdown( void );	/* NEXTSTEP preempts 'shutdown' */
static void test1(FILE*);




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    main								*/
/************************************************************************/

Vm_Int   main_ArgC;
Vm_Uch** main_ArgV;

int
main(
    int     argC,
    char**  argV
) {
    main_ArgV = (Vm_Uch**)argV;
    main_ArgC =           argC;

    if (argC != 1)   usage();

    startup();
    test1( stdout );
    muq_shutdown();

    exit(0);
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    put_byte -- Deposit one byte in buf.				*/
/************************************************************************/

static void put_byte(
    Buf    b,
    Vm_Int c
) {
    if (b->bytei >= &b->byte0[ BUF_MAX ])   JOB_FATAL("buffer overflow");
    *b->bytei++ = (Vm_Chr) c;
}



/************************************************************************/
/*-    startup								*/
/************************************************************************/

static void startup( void ) {

    job_Startup();
    job_Linkup();
}



/************************************************************************/
/*-    muq_shutdown							*/
/************************************************************************/

static void muq_shutdown(void) {

    job_Shutdown();
}



/************************************************************************/
/*-    test1 -- Basic instruction dis/assembly.				*/
/************************************************************************/

static void test_assembly(
    FILE* f,

    /* Instruction to assemble: */
    Vm_Unt  op,
    Vm_Unt  l0,  Vm_Unt offset0,
    Vm_Unt  l1,  Vm_Unt offset1,
    Vm_Unt  l2,  Vm_Unt offset2,

    /* Expected result: */
    Vm_Chr* stg
) {
    /* A buffer to     assemble code into: */
    A_Buf obj_buf;

    /* A buffer to dis-assemble code into: */
    A_Buf stg_buf;

    /* Assemble an instruction into 'obj_buf': */
    Vm_Chr* errmsg;
    obj_buf.bytei = obj_buf.byte0;
    errmsg	  = job_Deposit_Instruction(
	/* Continuation to feed bytes to: */
	put_byte, &obj_buf,

	/* Specs for instruction to assemble: */
	op,  l0,offset0, l1,offset1, l2,offset2
    );
    if (errmsg)   err(f,"","FAILED TO ASSEMBLE","(%s)\n",errmsg);

    /* Disassemble an instruction into 'stg_buf': */
    stg_buf.bytei = stg_buf.byte0;
    job_Disassemble_Codebuf(
        /* Continuation to feed string to: */
        put_byte, &stg_buf,

        /* Buf to disassemble: */
        obj_buf.byte0,	/* First byte     to disassemble.	*/
	obj_buf.bytei	/* First byte not to disassemble.	*/
    );
    put_byte( &stg_buf, 0 );

    /* Check that disassembly matches what we expected: */
    if (strcmp( stg, stg_buf.byte0 )) {
	err(f,"MIS-ASSEMBLED","Got %snot %s\n",stg_buf.byte0,stg);
    }
}    

static void test1(
    FILE* f
) {
    /* Create a job: */
    Vm_Obj j = job_Alloc();



    /************************************/
    /* Test that various instructions	*/
    /* assemble->disassemble as we	*/
    /* as we expect them to:		*/
    /************************************/

#undef  s
#define s JOB_LOC_s
#undef  p
#define p JOB_LOC_p
#undef  v
#define v JOB_LOC_v
#undef  V
#define V JOB_LOC_V
#undef  k
#define k JOB_LOC_k



    /*************************/
    /* Arithmetics on stack: */
    /*************************/

    test_assembly(f, JOB_OP_ADD, s,0,s,0,s,0, "ADD\ts[-1], s[0] -> s[-1]\n" );
    test_assembly(f, JOB_OP_SUB, s,0,s,0,s,0, "SUB\ts[-1], s[0] -> s[-1]\n" );
    test_assembly(f, JOB_OP_MUL, s,0,s,0,s,0, "MUL\ts[-1], s[0] -> s[-1]\n" );
    test_assembly(f, JOB_OP_DIV, s,0,s,0,s,0, "DIV\ts[-1], s[0] -> s[-1]\n" );



    /**************/
    /* Stack ops: */
    /**************/

    test_assembly(f, JOB_OP_POP,  0,0,0,0,s,0,	"POP\ts[0]\n"    	     );
    test_assembly(f, JOB_OP_DUP,  s,0,0,0,s,0,	"DUP\ts[0] -> s[1]\n"	     );
    test_assembly(f, JOB_OP_OVER, s,0,s,0,s,0,	"OVER\ts[-1], s[0] -> s[1]\n");
    /* Disassembler doesn't really grok SWAP: */
    test_assembly(f, JOB_OP_SWAP, s,0,s,0,s,0,	"SWAP\ts[-1], s[0] -> s[0]\n");



    /***************/
    /* Branch ops: */
    /***************/

    test_assembly(f, JOB_OP_BRA, p,   0,0,0,0,0, "BRA\tpc += 0\n"	);
    test_assembly(f, JOB_OP_BRA, p,  -1,0,0,0,0, "BRA\tpc += -1\n"	);
    test_assembly(f, JOB_OP_BRA, p,   1,0,0,0,0, "BRA\tpc += 1\n"	);
    test_assembly(f, JOB_OP_BRA, p, 127,0,0,0,0, "BRA\tpc += 127\n"	);
    test_assembly(f, JOB_OP_BRA, p,-128,0,0,0,0, "BRA\tpc += -128\n"	);
    test_assembly(f, JOB_OP_BRA, p, 128,0,0,0,0, "BRA\tpc += 128\n"	);
    test_assembly(f, JOB_OP_BRA, p,-129,0,0,0,0, "BRA\tpc += -129\n"	);

    test_assembly(f, JOB_OP_BEQ, p,   0,0,0,s,0, "BEQ\ts[0] -> pc += 0\n"    );
    test_assembly(f, JOB_OP_BEQ, p,  -1,0,0,s,0, "BEQ\ts[0] -> pc += -1\n"   );
    test_assembly(f, JOB_OP_BEQ, p,   1,0,0,s,0, "BEQ\ts[0] -> pc += 1\n"    );
    test_assembly(f, JOB_OP_BEQ, p, 127,0,0,s,0, "BEQ\ts[0] -> pc += 127\n"  );
    test_assembly(f, JOB_OP_BEQ, p,-128,0,0,s,0, "BEQ\ts[0] -> pc += -128\n" );
    test_assembly(f, JOB_OP_BEQ, p, 128,0,0,s,0, "BEQ\ts[0] -> pc += 128\n"  );
    test_assembly(f, JOB_OP_BEQ, p,-129,0,0,s,0, "BEQ\ts[0] -> pc += -129\n" );

    test_assembly(f, JOB_OP_BEQ, p,   0,0,0,s,0, "BEQ\ts[0] -> pc += 0\n"    );
    test_assembly(f, JOB_OP_BGE, p,   0,0,0,s,0, "BGE\ts[0] -> pc += 0\n"    );
    test_assembly(f, JOB_OP_BGT, p,   0,0,0,s,0, "BGT\ts[0] -> pc += 0\n"    );
    test_assembly(f, JOB_OP_BLE, p,   0,0,0,s,0, "BLE\ts[0] -> pc += 0\n"    );
    test_assembly(f, JOB_OP_BLT, p,   0,0,0,s,0, "BLT\ts[0] -> pc += 0\n"    );
    test_assembly(f, JOB_OP_BNE, p,   0,0,0,s,0, "BNE\ts[0] -> pc += 0\n"    );



    /****************/
    /* Get/set ops: */
    /****************/

    test_assembly(f, JOB_OP_GET, s,0,0,0,k,  0, "GET\tk[0] -> s[1]\n"    );
    test_assembly(f, JOB_OP_GET, s,0,0,0,v,  0, "GET\tv[0] -> s[1]\n"    );
    test_assembly(f, JOB_OP_GET, s,0,0,0,V,  0, "GET\tV[0] -> s[1]\n"    );

    test_assembly(f, JOB_OP_GET, s,0,0,0,k,  1, "GET\tk[1] -> s[1]\n"    );
    test_assembly(f, JOB_OP_GET, s,0,0,0,k,255, "GET\tk[255] -> s[1]\n"  );
    test_assembly(f, JOB_OP_GET, s,0,0,0,k,256, "GET\tk[256] -> s[1]\n"  );

    test_assembly(f, JOB_OP_SET, v,  0,0,0,s,0, "SET\ts[0] -> v[0]\n"    );
    test_assembly(f, JOB_OP_SET, V,  0,0,0,s,0, "SET\ts[0] -> V[0]\n"    );

    test_assembly(f, JOB_OP_SET, v,  1,0,0,s,0, "SET\ts[0] -> v[1]\n"    );
    test_assembly(f, JOB_OP_SET, v,255,0,0,s,0, "SET\ts[0] -> v[255]\n"  );
    test_assembly(f, JOB_OP_SET, v,256,0,0,s,0, "SET\ts[0] -> v[256]\n"  );



    /* Recycle our job: */
    job_Free( j );

    printf("test1: Done.\n");
}



/************************************************************************/
/*-    usage								*/
/************************************************************************/

void usage(void) {

    fprintf( stderr, "usage: x_job\n" );
    exit(1);
}




/************************************************************************/
/*-    File variables							*/
/************************************************************************/
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

@end example
