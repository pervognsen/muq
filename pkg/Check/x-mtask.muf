( --------------------------------------------------------------------- )
(			x-mtask.muf				    CrT )
( Exercise multithreading facilities.					)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      93Sep28							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1993-1995, by Jeff Prothero.				)
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
( 93Sep28 jsp	Created.						)
( --------------------------------------------------------------------- )

"Multi-thread facilities tests\n" log,
"\nMulti-thread facilities tests:" ,


( Test 1: )
( Create an object with a lock: )
makeIndex --> o    makeLock --> o.lock
( Define a function to monopolize it awhile: )
: x o.lock withLockDo{  5000 sleepJob  0 --> o.val } ;
: y "t3" forkJob dup if --> kidjob else pop x nil endJob fi ;
( Define a function which should be blocked by above: )
: x0 o.lock withLockDo{ 1 --> o.val } ;
( Start the blocking job: )
y
( Start the blocked job: )
x0
( Verify that the expected job ran second: )
:: o.val 1 = ; shouldBeTrue

( Test 2: )
( Test that we can re-acquire a lock we already hold ok: )
makeLock --> _myLock
:: _myLock withLockDo{ _myLock withLockDo{ } } ; shouldWork

( Tests 3-4: )
( Test that we can fork while holding a lock.   )
( Parent should wind up with lock, child should )
( not:                                          )
makeLock --> _myLock
::  _myLock withLockDo{
        "t4" forkJob if
	    2000 sleepJob
	    3 --> v3
        else
	    _myLock withLockDo{
		4 --> v3
	    }
	    nil endJob
        fi
    }
; shouldWork
5000 sleepJob
:: v3 4 = ; shouldBeTrue

( Tests 5-6: )
( Same test, just verifying that        )
( withParentLockDo{ is a synonym for )
( withLockDo{:                        )
( Parent should wind up with lock, child should )
( not:                                          )
makeLock --> _myLock
::  _myLock withParentLockDo{
        "t5" forkJob if
	    2000 sleepJob
	    3 --> v5
        else
	    _myLock withLockDo{
		4 --> v5
	    }
	    nil endJob
        fi
    }
; shouldWork
5000 sleepJob
:: v5 4 = ; shouldBeTrue

( Tests 7-8: )
( Similar test, but on           )
( withChildLockDo{ instead of )
( withParentLockDo{:          )
makeLock --> _myLock
::  _myLock withChildLockDo{
        "t6" forkJob if
            ( Parent, which should not )
	    ( inherit lock across fork )
	    ( hence should block here  )
	    ( until child 'endJob's:  )
	    _myLock withLockDo{
		4 --> v7
	    }
        else
            ( Child, which should inherit lock: )
	    2000 sleepJob
	    3 --> v7
	    nil endJob
        fi
    }
; shouldWork
5000 sleepJob
:: v7 4 = ; shouldBeTrue

( Tests 9-10: )
( Test that after forking in an after{...},  )
( the }alwaysDo{...} is executed only once: )

0 --> v9
::  after{
        "t7" forkJob -> kid
    }alwaysDo{
        v9 1 + --> v9
    }
    kid not if nil endJob fi
; shouldWork
2000 sleepJob
:: v9 1 = ; shouldBeTrue

( Tests 11-12: )
( Test that after forking in an afterChildDoes{...},  )
( the }alwaysDo{...} is executed only once: )

0 --> v11
::  afterChildDoes{
        "t8" forkJob -> kid
    }alwaysDo{
        v11 1 + --> v11
    }
    kid not if nil endJob fi
; shouldWork
2000 sleepJob
:: v11 1 = ; shouldBeTrue

( Test 13: )
( Test that "@ runJob" doesn't hang us, which it once did: )
:: @ runJob ; shouldWork

( Test 14: )
( This was crashing us in v -1.21.0 (test by PakRat): )
0 --> v14
: jobtest { -> }
  @ -> ojid
  "t26" copySession -> jid
  jid if
      after{
          jid runJob
          1 --> v14
          @ pauseJob
          1 --> v14
      }alwaysDo{
          3 --> v14
      }
  else
      after{
          1000 sleepJob
          nil endJob
      }alwaysDo{
          4 --> v14
          ojid runJob
         5 --> v14
      }
  fi
;
:: jobtest ; shouldWork

( These two tests killed because signal-job )
( no longer exists: )
( Test a: . )
( :: 12 --> .a ; --> @.sigusr1 )	( Set up a simple signal handler. )
( 10 --> .a )			( Initialize a db prop.           )
( @ "usr1" signal-job )	        ( Send signal to self.            )
( :: .a 12 = ; shouldBeTrue )	( Verify handler changed db prop. )


( Test b: )
( 10 --> .a )			( Re-initialize db prop.          )
( "t9" forkJob dup if --> kidjob else pop pauseJob nil endJob fi  )
( kidjob "usr1" signal-job )
( 2000 sleepJob )
( :: .a 12 = ; shouldBeTrue )	( Verify handler changed db prop. )



( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)
