( - xxx-oldmud3.muf -- Test code for oldmud code.			)
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
( - Initialization							)


"xxx-oldmud3 starting...\n" log,
"xxx-oldmud3.muf: pid = " .sys.pid toString join "\n" join d,
( 1000 --> _nextUserRank )
100000 --> .muq.nextGuestRank
1000   --> .muq.nextUserRank

( This hack lets us complete the test suite )
( without "Network Unreachable" errors even )
( if the host system is offnet:             )

.sys --> s
 127 --> s.ip0 ( 127.0.0.1 is the	    )
   0 --> s.ip1 ( standard loopback	    )
   0 --> s.ip2 ( address.		    )
   1 --> s.ip3

rootOmnipotentlyDo{
   .folkBy.nickName["muqnet"] --> s
 127 --> s.ip0 ( 127.0.0.1 is the	    )
   0 --> s.ip1 ( standard loopback	    )
   0 --> s.ip2 ( address.		    )
   1 --> s.ip3
}

rootUpdateIPAddressesOfAllNatives

"foreground" --> .muq.serverName

"xxx-oldmud3 listing folkBy.hashName:\n" log,
.folkBy.hashName foreach key val do{ [ "\t%s\t%s" key val | ]logPrint }

( Delete any unwanted old folk invalidated by renumbering: )
[   "backgroundRoot" "backgroundMuqnet"
    "downgroundRoot" "downgroundMuqnet"
    "foreplay" "forestay"
    "backplay" "backstay"
    "downplay" "downstay"
    "nano1"    "nano2"
    "kim"      "terry"
|
    |for name do{
        .folkBy.nickName name get? -> r if
            r$s.hashName -> h
            delete: .folkBy.nickName[name]
            delete: .folkBy.hashName[h]
            [ "Deleted %s (\"%s\") from .folkBy\n" name h | ]logPrint
        fi
        .u name get? -> r if
            delete: .u[name]
            [ "Deleted %s from .u\n" name | ]logPrint
        fi
    }
]pop

"xxx-oldmud3 listing folkBy.hashName:\n" log,
.folkBy.hashName foreach key val do{ [ "\t%s\t%s" key val | ]logPrint }

"xxx-oldmud3 listing u:\n" log,
.u foreach key val do{ [ "\t%s\t%s" key val | ]logPrint }

muqnet:rootClearIsleRegister
muqnet:clearWellKnownServerRegister
nil --> oldmudVars:_isle
nil --> _foreplay
nil --> _forestay
nil --> _backplay
nil --> _backstay
nil --> _downplay
nil --> _downstay

( Enter our background servers as well-known servers.   )
( This will give us two responding 'well-known" servers )
( even when testing on a non-networked machine:         )
[ 127 0 0 1 40000 | muqnet:registerWellKnownServer ]pop
[ 127 0 0 1 50000 | muqnet:registerWellKnownServer ]pop



( =====================================================================	)
( - start muqnet							)

"xxx-oldmud3.muf: Starting muqnet...\n" log,
muqnet:rootStart



( =====================================================================	)
( - make sample isle							)

"xxx-oldmud3.muf: Making sample isle...\n" log,
"Foreisle" oldmud:makeIsle --> oldmudVars:_isle
[ oldmudVars:_isle "Foreisle" | muqnet:rootRegisterIsle ]pop



( =====================================================================	)
( - make sample users							)

"xxx-oldmud3.muf: Making sample users...\n" log,


( Create a pair of test users, foreplay and forestay: )

.folkBy.nickName "foreplay" get? --> _foreplay not if
    "foreplayforeplay" vals[
    (    'z' |unshift )
    (    'z' |unshift )
	|secureHash
	|secureHash 
    ]join --> _myEncryptedPassphrase

    [ oldmudVars:_isle "foreplay" "foreplay" _myEncryptedPassphrase |
	rootOldmud:rootCreateMudUser
    ]--> _foreplay
fi

.folkBy.nickName "forestay" get? --> _forestay not if
    "forestayforestay" vals[
    (    'z' |unshift )
    (    'z' |unshift )
	|secureHash
	|secureHash 
    ]join --> _myEncryptedPassphrase

    [ oldmudVars:_isle "forestay" "forestay" _myEncryptedPassphrase |
	rootOldmud:rootCreateMudUser
    ]--> _forestay
fi

"_foreplay = " d, _foreplay d, "\n" d,
"_forestay = " d, _forestay d, "\n" d,



( =====================================================================	)
( - start isle daemons							)

"xxx-oldmud3.muf: Starting isle daemons...\n" log,

( Give background server a decent chance to get started: )
5000 sleepJob
"xxx-oldmud3.muf: Done 5-sec sleep...\n" log,

rootOldmud:rootStartSampleOldmudIsleDaemons
"xxx-oldmud3.muf started isle daemons...\n" log,

"xxx-oldmud3.muf: Accepting logins...\n" log,
rootAcceptLogins

( Give background server daemons a decent chance to get started: )
for i from 0 below 3 do{
    "\nxxx-oldmud3 listing all jobs:\n" ,
    rootPrintJobs
    "xxx-oldmud3 done listing all jobs.\n" ,
    2000 sleepJob
}
"\n" ,

( =====================================================================	)
( - report -- Convenience fn to report test success/failure.		)

:   report { $ -> }
    ++ _testNumber  
    if regressionTestSucc else "Didn't return TRUE value" regressionTestFail fi
;


( =====================================================================	)
( - demand -- Issue command, verify response.				)

( A convenience function to issue command and verify response: )
:   demand { $ $ $ -> }
    -> who
    -> line
    -> cmd
    who.oob -> oob
    who.out -> stream

    cmd if cmd who.in writeStream fi

    do{
	[ stream oob | t 50000
	   |readAnyStreamPacket
	   -> istream
	   -> iwho
	   -> itag
	]join --> iline

        ( Ignore out-of-band data: )
	istream oob = if loopNext fi

	( Fail if we timed out: )
	istream not if
	    nil report
	    return
        fi 

        istream stream = report
        iwho    who    = report
        itag    "txt"  = report
        iline   line   = report

	return
    }
;


( =====================================================================	)
( - expect -- 'demand' that ignores unexpected output.			)

( 'expect' is like 'demand' except extra output can precede result: )
:   expect { $ $ $ -> }
    -> who
    -> line
    -> cmd
    who.oob -> oob
    who.out -> stream

    "\n" ,
    .sys.muqPort , "(xxx-)<" , @ , ">'expect' sent: " , cmd ,
    cmd if cmd who.in writeStream fi

    .sys.muqPort , "(xxx-)<" , @ , ">'expect' want: " , line ,

    do{
	[ stream oob | t 50000
	   |readAnyStreamPacket
	   -> istream
	   -> iwho
	   -> itag
	]join --> iline
        .sys.muqPort , "(xxx-)<" , @ , ">'expect' read: " , iline ,

        ( Ignore out-of-band data: )
	istream oob = if loopNext fi

	( Fail if we timed out: )
	istream not if
	    nil report
	    return
        fi 

        iline   line  != if loopNext fi

        istream stream = report
        iwho    who    = report
        itag    "txt"  = report

        .sys.muqPort , "(xxx-)<" , @ , ">'expect' done.\n" ,
	return
    }
;



( =====================================================================	)
( - rexpect -- 'expect' with multiple regex patterns.			)

( 'rexpect' is like 'expect' except multiple patterns are )
( allowed, and they may include regular expressions. The  )
( call doesn't succeed until all patterns have been       )
( matched:                                                )
:   rexpect { [] $ $ -> }
    -> who
    -> cmd
    who.oob -> oob
    who.out -> stream

    cmd if
	cmd who.in writeStream
	[ "rexpect sent: '%s'" cmd | ]logPrint 
    fi

    do{
	[ stream oob | t 50000
	   |readAnyStreamPacket
	   -> istream
	   -> iwho
	   -> itag
	]join --> iline
        [ "rexpect: Read: '%s'" iline | ]logPrint

        ( Ignore out-of-band data: )
	istream oob = if
            "rexpect: Ignoring above as out-of-band data" log,
	    loopNext
	fi

	( Fail if we timed out: )
	istream not if
	    ]pop
            [ "rexpect: **** timing out on '%s'" cmd | ]logPrint
	    nil report
	    return
        fi 

	t -> noMatch
	|for rex iii do{
	    rex callable? if
	        iline rex call{ $ -> $ } if
		    [ "rexpect: Matched on: '%s'" rex | ]logPrint
		    iii |popNth pop
		    nil -> noMatch
		    loopFinish
		fi
	    else
		iline rex = if
		    [ "rexpect: Matched on: '%s'" rex | ]logPrint
		    iii |popNth pop
		    nil -> noMatch
		    loopFinish
		fi
	    fi
	}
	noMatch      if loopNext fi
	|length 0 != if loopNext fi
	]pop

        istream stream = report
        iwho    who    = report
        itag    "txt"  = report

	[ "rexpect: Succeeded on: '%s'" cmd | ]logPrint
	return
    }
;


( =====================================================================	)
( - rexpect2 -- 'rexpect' with both required and forbidden regexes.	)

:   rexpect2 { [] [] $ $ -> }
    -> who
    -> cmd
    who.oob -> oob
    who.out -> stream
    ]makeVector -> forbidden
    ]makeVector -> required

    cmd if
	cmd who.in writeStream
	"\n" ,
	.sys.muqPort , "(xxx-)<" , @ , ">'rexpect2' sent: " , cmd ,
    fi

    required length -> matchesNeeded
    do{
	[ stream oob | t 50000
	   |readAnyStreamPacket
	   -> istream
	   -> iwho
	   -> itag
	]join --> iline
        .sys.muqPort , "(xxx-)<" , @ , ">'rexpect2' read: " , iline ,

        ( Ignore out-of-band data: )
	istream oob = if loopNext fi

	( Fail if we timed out: )
	istream not if
	    nil report
	    return
        fi 

	( See if any of the required patterns match: )
	required vals[
	    |for rex iii do{
		rex callable? if
		    iline rex call{ $ -> $ } if
			.sys.muqPort , "(xxx-)<" , @ , ">'rexpect2' matched on: " , rex , "\n" ,
			-- matchesNeeded
			loopFinish
		    fi
		else
		    iline rex = if
			.sys.muqPort , "(xxx-)<" , @ , ">'rexpect2' matched on: " , rex , "\n" ,
			-- matchesNeeded
			loopFinish
		    fi
		fi
	    }
	]pop

	( See if any of the forbidden patterns match: )
	forbidden vals[
	    |for rex iii do{
		rex callable? if
		    iline rex call{ $ -> $ } if
			.sys.muqPort , "(xxx-)<" , @ , ">'rexpect2' matched on FORBIDDEN pattern: " , rex , "\n" ,
			nil report
			loopFinish
		    fi
		else
		    iline rex = if
			.sys.muqPort , "(xxx-)<" , @ , ">'rexpect2' matched on FORBIDDEN pattern: " , rex , "\n" ,
			nil report
			loopFinish
		    fi
		fi
	    }
	]pop

	matchesNeeded 0 != if loopNext fi

        istream stream = report
        iwho    who    = report
        itag    "txt"  = report

	"\n" ,
        .sys.muqPort , "(xxx-)<" , @ , ">'rexpect2' succeeded on: " , cmd , "\n" ,
	return
    }
;


( =====================================================================	)
( - log_in_user -- A convenience function to log a user in.		)

:   log_in_user { $ $ $ -> $ }
    -> pw
    -> name
    -> port

    name "\n" join --> _namenl
    pw   "\n" join --> _pwnl

    ( Tests -: Open a client connection to oldmud: )
    :: makeSocket --> _sock1 ; shouldWork
    :: makeMessageStream --> _sock1.in ; shouldWork
    :: makeMessageStream --> _sock1.out ; shouldWork
    :: makeMessageStream --> _sock1.oob ; shouldWork
    :: makeMessageStream --> _sock1.oobInput ; shouldWork
    :: _sock1.in        --> _sock1.standardInput ; shouldWork
    :: _sock1.out       --> _sock1.standardOutput ; shouldWork
    :: _sock1.oobInput  --> _sock1.outOfBandInput  ; shouldWork
    :: _sock1.oob       --> _sock1.outOfBandOutput ; shouldWork
    [   :socket _sock1
	:port port
	:protocol :stream
    | ]openSocket

    ( Test : Set client for TELNET support: )
    :: t --> _sock1.telnetProtocol ; shouldWork

    ( Tests : Read login prompt from oldmud: )
    nil "login:\n" _sock1 demand

    ( Tests : Read passphrase prompt from oldmud: )
    _namenl "passphrase:\n" _sock1 demand

    ( Tests : Read welcome blurb from oldmud: )
    _pwnl "Welcome to the Muq oldmud shell!  (Do 'help' for help.)\n" _sock1 demand

    _sock1
;

( =====================================================================	)
( - log in four test users.						)

"\n\nxxx-oldmud3.muf: << logging in forestay... >>\n" ,
30023 "forestay" "forestay" log_in_user --> _forestay

"\n\nxxx-oldmud3.muf: << logging in foreplay... >>\n" ,
30023 "foreplay" "foreplay" log_in_user --> _foreplay

"\n\nxxx-oldmud3.muf: << logging in backstay... >>\n" ,
40023 "backstay" "backstay" log_in_user --> _backstay

"\n\nxxx-oldmud3.muf: << logging in backplay... >>\n" ,
40023 "backplay" "backplay" log_in_user --> _backplay

"\n\nxxx-oldmud3.muf: << logging in downstay... >>\n" ,
50023 "downstay" "downstay" log_in_user --> _downstay

"\n\nxxx-oldmud3.muf: << logging in downplay... >>\n" ,
50023 "downplay" "downplay" log_in_user --> _downplay

( =====================================================================	)
( - set doing fields on test users					)

"\n\nxxx-oldmud3.muf: << Setting doing fields... >>\n" ,
"@doing foregroundish homework\n" "* Set. *\n" _forestay expect
"@doing foregroundish play\n"     "* Set. *\n" _foreplay expect
"@doing backgroundish homework\n" "* Set. *\n" _backstay expect
"@doing backgroundish play\n"     "* Set. *\n" _backplay expect
"@doing downgroundish homework\n" "* Set. *\n" _downstay expect
"@doing downgroundish play\n"     "* Set. *\n" _downplay expect

( =====================================================================	)
( - basic test of @who							)

"\n\nxxx-oldmud3.muf: << Trying @who... >>\n" ,
rex: forestayrex /^\s*\djoin\s+\d+\s+forestay #1001\s+foregroundish homework\n$/
rex: foreplayrex /^\s*\d+\s+\d+\s+foreplay #1000\s+foregroundish play\n$/
rex: backstayrex /^\s*\d+\s+\d+\s+backstay.Backisle\s+backgroundish homework\n$/
rex: backplayrex /^\s*\d+\s+\d+\s+backplay.Backisle\s+backgroundish play\n$/
rex: downstayrex /^\s*\d+\s+\d+\s+downstay.Downisle\s+downgroundish homework\n$/
rex: downplayrex /^\s*\d+\s+\d+\s+downplay.Downisle\s+downgroundish play\n$/
[  'forestayrex
   'foreplayrex
   'backstayrex
   'backplayrex
   'downstayrex
   'downplayrex
| "@who\n" _forestay rexpect

( =====================================================================	)
( - print random server stats						)

" usermode secs " .sys.usermodeCpuSeconds toString join "\n" join d,
" usermode nsecs " .sys.usermodeCpuNanoseconds toString join "\n" join d,
" sysmode secs " .sys.sysmodeCpuSeconds toString join "\n" join d,
" sysmode nsecs " .sys.sysmodeCpuNanoseconds toString join "\n" join d,
" maxRss " .sys.maxRss toString join "\n" join d,
" pageReclaims " .sys.pageReclaims toString join "\n" join d,
" pageFaults " .sys.pageFaults toString join "\n" join d,
" swapOuts " .sys.swapOuts toString join "\n" join d,
" blockReads " .sys.blockReads toString join "\n" join d,
" blockWrites " .sys.blockWrites toString join "\n" join d,
" voluntaryContextSwitches " .sys.voluntaryContextSwitches toString join "\n" join d,
" involuntaryContextSwitches " .sys.involuntaryContextSwitches toString join "\n" join d,


( =====================================================================	)
( - wrapup								)


"xxx-oldmud3.muf Done.\n" log,

( =====================================================================	)

( - File variables							)


( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

