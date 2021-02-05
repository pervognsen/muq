( - xx-oldmud2.muf -- Test code for oldmud code.			)
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


t --> .muq.logWarnings
"xx-oldmud2 starting...\n" log,
"xx-oldmud2.muf: pid = " .sys.pid toString join "\n" join d,
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

"xx-oldmud2 listing folkBy.hashName:\n" ,
.folkBy.hashName ls
.folkBy.nickName ls

( If backgroundRoot or backgroundMuqnet are in		)
( .folkBy.nickName (left over from x[xy]-muqnet)	)
( then delete them, since renumbering has invalidated	)
( them: 						)
.folkBy.nickName "backgroundRoot" get? -> r if
    r$s.hashName -> h
    delete: .folkBy.nickName["backgroundRoot"]
    delete: .folkBy.hashName[h]
    "Deleted backgroundRoot (" , h , ") from .folkBy\n" ,
fi
.folkBy.nickName "backgroundMuqnet" get? -> r if
    r$s.hashName -> h
    delete: .folkBy.nickName["backgroundMuqnet"]
    delete: .folkBy.hashName[h]
    "Deleted backgroundMuqnet (" , h , ") from .folkBy\n" ,
fi

( Enter our background server as a well-known server.  )
( This will give us one responding 'well-known" server )
( even when testing on a non-networked machine:        )
[ 127 0 0 1 40000 | muqnet:registerWellKnownServer ]pop



( =====================================================================	)
( - start muqnet							)

"xx-oldmud2.muf: Starting muqnet...\n" log,
muqnet:rootStart



( =====================================================================	)
( - make sample isle							)

"xx-oldmud2.muf: Making sample isle...\n" log,
"Foreisle" oldmud:makeIsle --> oldmudVars:_isle
[ oldmudVars:_isle "Foreisle" | muqnet:rootRegisterIsle ]pop



( =====================================================================	)
( - make sample users							)

"xx-oldmud2.muf: Making sample users...\n" log,


( Create a pair of test users, foreplay and forestay: )

"foreplayforeplay" vals[
(    'z' |unshift )
(    'z' |unshift )
    |secureHash
    |secureHash 
]join --> _myEncryptedPassphrase

[ oldmudVars:_isle "foreplay" "foreplay" _myEncryptedPassphrase |
    rootOldmud:rootCreateMudUser
]--> _foreplay

"forestayforestay" vals[
(    'z' |unshift )
(    'z' |unshift )
    |secureHash
    |secureHash 
]join --> _myEncryptedPassphrase

[ oldmudVars:_isle "forestay" "forestay" _myEncryptedPassphrase |
    rootOldmud:rootCreateMudUser
]--> _forestay

"_foreplay = " d, _foreplay d, "\n" d,
"_forestay = " d, _forestay d, "\n" d,



( =====================================================================	)
( - start isle daemons							)

"xx-oldmud2.muf: Starting isle daemons...\n" log,

( Give background server a decent chance to get started: )
5000 sleepJob
"xx-oldmud2.muf: Done 5-sec sleep...\n" log,

rootOldmud:rootStartSampleOldmudIsleDaemons
"xx-oldmud2.muf started isle daemons...\n" log,

"xx-oldmud2.muf: Accepting logins...\n" log,
rootAcceptLogins

( Give foreground server daemons a decent chance to get started: )
for i from 0 below 3 do{
(    "\nxx-oldmud2 listing all jobs:\n" , )
(    rootPrintJobs )
(    "xx-oldmud2 done listing all jobs.\n" , )
    2000 sleepJob
}
"\n" ,

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
( - checkGetMuqnetUser -- Ask for background server's muqnet user		)

( This check is a duplicate of the matching one in xx-muqnet2.muf --	)
( We need it to ensure that we have up-to-date info in			)
( .folkBy.nickName["backgroundMuqnet"]					)

( Set up a stream and job to receive network replies: )
0  --> _resentPackets
0  --> _repliesReceived
30 --> _packetsToSend

:   checkGetMuqnetUser { -> }
    "t24" forkJob if
	( We're the parent job.  )
	( Wait for replies to straggle in: )
	for i from 1 below 100 do{
	    _repliesReceived 0 != if loopFinish fi
	    1000 sleepJob
	}
    else 
	( We're the child.  Since this is just a test hack  )
	( we'll omit the usual shell armor-plating designed )
	( to keep us running after errors, defeat spoofers  )
	( and other such good stuff:                        )
	2000   -> millisecsToWait
	t   -> noFragments	( Complete packets only, please. )

	0 -> replies-received
	makeMessageStream -> replyStream

	[   replyStream
	    .sys.ip0
	    .sys.ip1
	    .sys.ip2
	    .sys.ip3
	    40000
	    1
	|   muqnet:sendGetMuqnetUserInfo ]pop

	0 -> lastReply
	do{
	    ( Read a packet: )
	    [ replyStream | noFragments millisecsToWait
		|readAnyStreamPacket
		-> stream
		-> who
		-> tag
		stream not if
		    ]pop
		    ++ _resentPackets
		    [   replyStream
			.sys.ip0
			.sys.ip1
			.sys.ip2
			.sys.ip3
			40000
			lastReply 1 +
		    |   muqnet:sendGetMuqnetUserInfo ]pop
		    loopNext
		else
		fi
		|shift -> seq
	    ]pop	

	    ( Ignore duplicates due to  )
	    ( premature retransmission: )
	    seq lastReply <= if loopNext fi
	    seq -> lastReply

	    ++ _repliesReceived

	    nil endJob
	}
    fi
;
:: checkGetMuqnetUser ; shouldWork
:: _repliesReceived 1 = ; shouldBeTrue
:: .folkBy.nickName["backgroundMuqnet"] guest? ; shouldBeTrue



( Ask how many worlds we have on other side: )
makeMessageStream --> _replyStream

nil --> _isleCount
1   --> _lastReply

[   _replyStream
    .folkBy.nickName["backgroundMuqnet"]
    _lastReply
| muqnet:sendIsles ]pop

do{
    5000   -> millisecsToWait
    t   -> noFragments		( Complete packets only.	)

    ( Read a packet: )
    [ _replyStream | noFragments millisecsToWait
	|readAnyStreamPacket
	-> stream
	-> who
	-> tag
	stream not if
	    ]pop
	    ++ _lastReply
	    [   _replyStream
		.folkBy.nickName["backgroundMuqnet"]
		_lastReply
	    | muqnet:sendIsles ]pop

	    loopNext
	fi
	|shift -> seq
	:isles |get --> _isleCount
    ]pop	
    loopFinish
}
:: _isleCount ; shouldBeTrue
:: _isleCount 1 = ; shouldBeTrue


( Get name and pointer for each world: )
nil --> _isleName
nil --> _isle
for i from 0 below _isleCount do{
    [   _replyStream
	.folkBy.nickName["backgroundMuqnet"]
        _lastReply
        i
    |   muqnet:sendIsle ]pop

    do{
	5000   -> millisecs-to-wait
	t   -> noFragments		( Complete packts only.	)

	( Read a packet: )
	[   _replyStream | noFragments millisecs-to-wait
	    |readAnyStreamPacket
	    -> stream
	    -> who
	    -> tag
	    stream not if
		]pop
		++ _lastReply
		[   _replyStream
		    .folkBy.nickName["backgroundMuqnet"]
		    _lastReply
		    i
		| muqnet:sendIsle ]pop

		loopNext
	    fi
	    |shift -> seq
	    :name   |get --> _isleName
	    :isle   |get --> _isle
	]pop	
	loopFinish
    }
}
:: _isleName         ; shouldBeTrue
:: _isle             ; shouldBeTrue
:: _isleName string? ; shouldBeTrue
:: _isle     remote? ; shouldBeTrue



( LOOKS LIKE THE NEXT STEP is to set up so that we can do  )
( ]request calls conveniently -- this may mean setting our )
( @.taskHome or some such global variables? -- and then  )
( working our way through the various ]requests which we   )
( can make on objects. xx-oldmud2.muf.soon has some old    )
( examples, such as req-nexus (i.e., REQ_ISLE_QUAY), and   )
( after that we can just work through the list in          )
( 330-W-oldmud.                                            )

(  We'll probably need to log in a test pair of characters )
( before we get too far along, so we can verify that they  )
( get appropriate messages and so forth.                   )

(  As a separate later phase, we should exercise the UI    )
( itself, as opposed to the ]requests.                     )

(  As a separate still later phase, we should write a user )
( simulator so we can stress-test the system by running    )
( 100-1000 simulated users simultaneously and see what our )
( capacity is, and also what breaks when we reach it.      )



( =====================================================================	)
( - report -- Convenience fn to report test success.failure.		)

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
    .sys.muqPort , "(xx-)<" , @ , ">'expect' sent: " , cmd ,
    cmd if cmd who.in writeStream fi

    .sys.muqPort , "(xx-)<" , @ , ">'expect' want: " , line ,

    do{
	[ stream oob | t 50000
	   |readAnyStreamPacket
	   -> istream
	   -> iwho
	   -> itag
	]join --> iline
        .sys.muqPort , "(xx-)<" , @ , ">'expect' read: " , iline ,

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

        .sys.muqPort , "(xx-)<" , @ , ">'expect' done.\n" ,
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
	"\n" ,
	.sys.muqPort , "(xx-)<" , @ , ">'rexpect' sent: " , cmd ,
    fi

    do{
	[ stream oob | t 50000
	   |readAnyStreamPacket
	   -> istream
	   -> iwho
	   -> itag
	]join --> iline
        .sys.muqPort , "(xx-)<" , @ , ">'rexpect' read: " , iline ,

        ( Ignore out-of-band data: )
	istream oob = if loopNext fi

	( Fail if we timed out: )
	istream not if
	    ]pop
	    nil report
	    return
        fi 

	t -> noMatch
	|for rex iii do{
	    rex callable? if
	        iline rex call{ $ -> $ } if
		    .sys.muqPort , "(xx-)<" , @ , ">'rexpect' matched on: " , rex , "\n" ,
		    iii |popNth pop
		    nil -> noMatch
		    loopFinish
		fi
	    else
		iline rex = if
		    .sys.muqPort , "(xx-)<" , @ , ">'rexpect' matched on: " , rex , "\n" ,
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

	"\n" ,
        .sys.muqPort , "(xx-)<" , @ , ">'rexpect' succeeded on: " , cmd , "\n" ,
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
	.sys.muqPort , "(xx-)<" , @ , ">'rexpect2' sent: " , cmd ,
    fi

    required length -> matchesNeeded
    do{
	[ stream oob | t 50000
	   |readAnyStreamPacket
	   -> istream
	   -> iwho
	   -> itag
	]join --> iline
        .sys.muqPort , "(xx-)<" , @ , ">'rexpect2' read: " , iline ,

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
			.sys.muqPort , "(xx-)<" , @ , ">'rexpect2' matched on: " , rex , "\n" ,
			-- matchesNeeded
			loopFinish
		    fi
		else
		    iline rex = if
			.sys.muqPort , "(xx-)<" , @ , ">'rexpect2' matched on: " , rex , "\n" ,
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
			.sys.muqPort , "(xx-)<" , @ , ">'rexpect2' matched on FORBIDDEN pattern: " , rex , "\n" ,
			nil report
			loopFinish
		    fi
		else
		    iline rex = if
			.sys.muqPort , "(xx-)<" , @ , ">'rexpect2' matched on FORBIDDEN pattern: " , rex , "\n" ,
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
        .sys.muqPort , "(xx-)<" , @ , ">'rexpect2' succeeded on: " , cmd , "\n" ,
	return
    }
;


( =====================================================================	)
( - log_in_user -- A convenience function to log a user in.		)

:   log_in_user { $ $ $ -> $ }
    -> pw
    -> name
    -> port

    name "\n" join --> _namenl_
    pw   "\n" join --> _pwnl_

    ( Tests -: Open a client connection to oldmud: )
    :: makeSocket --> _sock1_ ; shouldWork
    :: makeMessageStream --> _sock1_.in ; shouldWork
    :: makeMessageStream --> _sock1_.out ; shouldWork
    :: makeMessageStream --> _sock1_.oob ; shouldWork
    :: makeMessageStream --> _sock1_.oobInput ; shouldWork
    :: _sock1_.in        --> _sock1_.standardInput ; shouldWork
    :: _sock1_.out       --> _sock1_.standardOutput ; shouldWork
    :: _sock1_.oobInput  --> _sock1_.outOfBandInput  ; shouldWork
    :: _sock1_.oob       --> _sock1_.outOfBandOutput ; shouldWork
    [   :socket _sock1_
	:port port
	:protocol :stream
    | ]openSocket

    ( Test : Set client for TELNET support: )
    :: t --> _sock1_.telnetProtocol ; shouldWork

    ( Tests : Read login prompt from oldmud: )
    nil "login:\n" _sock1_ demand

    ( Tests : Read passphrase prompt from oldmud: )
    _namenl_ "passphrase:\n" _sock1_ demand

    ( Tests : Read welcome blurb from oldmud: )
    _pwnl_ "Welcome to the Muq oldmud shell!  (Do 'help' for help.)\n" _sock1_ demand

    _sock1_
;

( =====================================================================	)
( - log in four test users.						)

"\n\nxx-oldmud2.muf: << logging in forestay... >>\n" ,
30023 "forestay" "forestay" log_in_user --> _forestay

"\n\nxx-oldmud2.muf: << logging in foreplay... >>\n" ,
30023 "foreplay" "foreplay" log_in_user --> _foreplay

"\n\nxx-oldmud2.muf: << logging in backstay... >>\n" ,
40023 "backstay" "backstay" log_in_user --> _backstay_

"\n\nxx-oldmud2.muf: << logging in backplay... >>\n" ,
40023 "backplay" "backplay" log_in_user --> _backplay_

( =====================================================================	)
( - basic test of mufshell						)

t --> .muq.logBytecodes
"\n\nxx-oldmud2.muf: << putting 'forestay' in mufshell... >>\n" ,
"@muf\n" "forestay: \n" _forestay expect

"\n\nxx-oldmud2.muf: << doing '2 2 +' in 'forestay'... >>\n" ,
"2 2 +\n" "forestay: 4\n" _forestay expect

"\n\nxx-oldmud2.muf: << returning 'forestay' to mudshell... >>\n" ,
"exitShell\n" "Returning to oldmsh shell.\n" _forestay expect
nil --> .muq.logBytecodes

( =====================================================================	)
( - set short descriptions on test users				)

"\n\nxx-oldmud2.muf: << Setting short descriptions... >>\n" ,
"@short me=a foreground stay-at-home\n" "* Set. *\n" _forestay expect
"@short me=a foreground traveller\n"    "* Set. *\n" _foreplay expect
"@short me=a background stay-at-home\n" "* Set. *\n" _backstay_ expect
"@short me=a background traveller\n"    "* Set. *\n" _backplay_ expect

( =====================================================================	)
( - set outside descriptions on test users				)

"\n\nxx-oldmud2.muf: << Setting outside descriptions... >>\n" ,
"@outside me=a dapper foreground stay-at-home\n" "* Set. *\n" _forestay expect
"@outside me=a dapper foreground traveller\n"    "* Set. *\n" _foreplay expect
"@outside me=a dapper background stay-at-home\n" "* Set. *\n" _backstay_ expect
"@outside me=a dapper background traveller\n"    "* Set. *\n" _backplay_ expect

( =====================================================================	)
( - set doing fields on test users					)

"\n\nxx-oldmud2.muf: << Setting doing fields... >>\n" ,
"@doing foregroundish homework\n" "* Set. *\n" _forestay expect
"@doing foregroundish play\n"     "* Set. *\n" _foreplay expect
"@doing backgroundish homework\n" "* Set. *\n" _backstay_ expect
"@doing backgroundish play\n"     "* Set. *\n" _backplay_ expect

( =====================================================================	)
( - basic test of @who							)

"\n\nxx-oldmud2.muf: << Trying @who... >>\n" ,
rex: forestayrex /^\s*\d+\s+\d+\s+forestay #1001\s+foregroundish homework\n$/
rex: foreplayrex /^\s*\d+\s+\d+\s+foreplay #1000\s+foregroundish play\n$/
rex: backstayrex /^\s*\d+\s+\d+\s+backstay.Backisle\s+backgroundish homework\n$/
rex: backplayrex /^\s*\d+\s+\d+\s+backplay.Backisle\s+backgroundish play\n$/
[  'forestayrex
   'foreplayrex
   'backstayrex
   'backplayrex
| "@who\n" _forestay rexpect

( =====================================================================	)
( - basic test of @hide on/off						)

"\n\nxx-oldmud2.muf: << Trying @hide on/off... >>\n" ,
"@hide on\n"  "* You now DO NOT appear on @who listings. *\n" _forestay expect
"@hide on\n"  "* You now DO NOT appear on @who listings. *\n" _backstay_ expect

"\n\nxx-oldmud2.muf: << Trying @who... >>\n" ,
rex: forestayrex /^\s*\d+\s+\d+\s+forestay #1001\s+foregroundish homework\n$/
rex: foreplayrex /^\s*\d+\s+\d+\s+foreplay #1000\s+foregroundish play\n$/
rex: backstayrex /^\s*\d+\s+\d+\s+backstay.Backisle\s+backgroundish homework\n$/
rex: backplayrex /^\s*\d+\s+\d+\s+backplay.Backisle\s+backgroundish play\n$/

( Use rexpect2 so we can check both that the expected )
( response lines are present, and that the two hidden )
( players do not show up.  The test ends when the two )
( unhidden players have both been seen, so if the two )
( hidden ones happen to both list after the other two )
( we lose.  I'm not losing any sleep over that...     )
[  'foreplayrex
   'backplayrex
|  ( Required  patterns )
[  'forestayrex
   'backstayrex
|  ( Forbidden patterns )
"@who\n" _forestay rexpect2

"@hide off\n" "* You now DO appear on @who listings. *\n"     _forestay expect
"@hide off\n" "* You now DO appear on @who listings. *\n"     _backstay_ expect

rex: forestayrex /^\s*\d+\s+\d+\s+forestay #1001\s+foregroundish homework\n$/
rex: foreplayrex /^\s*\d+\s+\d+\s+foreplay #1000\s+foregroundish play\n$/
rex: backstayrex /^\s*\d+\s+\d+\s+backstay.Backisle\s+backgroundish homework\n$/
rex: backplayrex /^\s*\d+\s+\d+\s+backplay.Backisle\s+backgroundish play\n$/
[  'forestayrex
   'foreplayrex
   'backstayrex
   'backplayrex
| "@who\n" _forestay rexpect

( =====================================================================	)
( - basic test of 'look' with no args					)

"\n\nxx-oldmud2.muf: << Trying 'look'... >>\n" ,

rex: roomrex /^You see the_Foreisle_Nursery, birthroom of new avatars.\s+\(go-able\)\n$/
rex: exitrex /^In the_Foreisle_Nursery you see\s+N,\s+a path leading to the Quay.\s+\(exit\)\n$/
rex: avatrex /^In the_Foreisle_Nursery you see\s+foreplay.\s+\(avatar; hears; notes; #1000\)\n$/

[  'roomrex
   'exitrex
   'avatrex
| "look\n" _forestay rexpect

( =====================================================================	)
( - basic test of 'look' ing at an avatar				)

rex: avatrex /^You see foreplay, a dapper foreground traveller\n$/
[  'avatrex
| "look foreplay\n" _forestay rexpect

( =====================================================================	)
( - basic test of 'look' ing at an exit					)

rex: exitrex /^You see n, a path leading to the Quay.\n$/
[  'exitrex
| "look N\n" _forestay rexpect

( =====================================================================	)
( - basic test of 'say'							)

rex: talkrex /^You say "hot enough for you\?"\n$/
[  'talkrex
| "say hot enough for you?\n" _forestay rexpect

rex: hearrex /^forestay says, "hot enough for you\?"\n$/
[  'hearrex
| nil _foreplay rexpect

( =====================================================================	)
( - basic test of 'whisper'						)

rex: talkrex /^You whisper "hot enough for you\?"\n$/
[  'talkrex
| "w foreplay=hot enough for you?\n" _forestay rexpect

rex: hearrex /^forestay whispers, "hot enough for you\?"\n$/
[  'hearrex
| nil _foreplay rexpect

( =====================================================================	)
( - test of 'say' with backquotes					)

rex: talkrex /^You say "4"\n$/
[  'talkrex
| "say `2+2;`\n" _forestay rexpect

rex: hearrex /^forestay says, "4"\n$/
[  'hearrex
| nil _foreplay rexpect

( =====================================================================	)
( - basic tests of 'go' ing through an exit, part I			)

rex: trex /^You enter the_Foreisle_Quay, with boat service to other isles.\s*\(go-able\)\n$/
rex: srex /^In the_Foreisle_Quay you see\s+S,\s+a path leading to the Nursery.\s+\(exit\)\n$/
rex: erex /^In the_Foreisle_Quay you see\s+E,\s+a road leading to the Crossroads.\s+\(exit\)\n$/
rex: nrex /^In the_Foreisle_Quay you see\s+N,\s+a path leading to the BadLands.\s+\(exit\)\n$/
rex: brex /^In the_Foreisle_Quay you see\s+Backisle,\s+a proa leaving for Backisle.\s+\(exit\)\n$/
[  'trex
   'srex
   'erex
   'nrex
   'brex
| "go N\n" _foreplay rexpect

rex: goingrex /^foreplay goes 'N'\n$/
rex: gone_rex /^\* foreplay has left the_Foreisle_Nursery\.\n$/
[  'goingrex
   'gone_rex
| nil _forestay rexpect

( =====================================================================	)
( - basic test of 'page' ing avatar outside room			)

rex: pagerex /^You page "far enough for you\?"\n$/
[  'pagerex
| "pa foreplay=far enough for you?\n" _forestay rexpect

rex: hearrex /^forestay pages, "far enough for you\?"\n$/
[  'hearrex
| nil _foreplay rexpect

( =====================================================================	)
( - basic test of 'page' ing avatar outside room cross-server		)

rex: pagerex /^You page "fur enough for you\?"\n$/
[  'pagerex
| "pa backplay.Backisle=fur enough for you?\n" _forestay rexpect

rex: hearrex /^forestay.Foreisle pages, "fur enough for you\?"\n$/
[  'hearrex
| nil _backplay_ rexpect

( =====================================================================	)
( - basic test of '@gag'						)



( Establish two gags: )

rex: pagerex /^\* @gag: backplay.Backisle is now gagged\. \*\n$/
[  'pagerex
| "@gag backplay.Backisle=on\n" _forestay rexpect

rex: pagerex /^\* @gag: foreplay is now gagged\. \*\n$/
[  'pagerex
| "@gag foreplay=on\n" _forestay rexpect



( List our gags: )

rex: forerex /^\* @gag: foreplay is gagged\. \*\n$/
rex: backrex /^\* @gag: backplay.Backisle is gagged\. \*\n$/
rex: totrex  /^\* @gag: 2 people gagged\. \*\n$/
[  'forerex
   'backrex
   'totrex
| "@gag\n" _forestay rexpect



( Test the two gags: )

rex: pagerex /^You page "test1"\n$/
[  'pagerex
| "pa forestay=test1\n" _foreplay rexpect

rex: pagerex /^You page "test2"\n$/
[  'pagerex
| "pa forestay.Foreisle=test2\n" _backplay_ rexpect

rex: pagerex /^You page "test3"\n$/
[  'pagerex
| "pa forestay.Foreisle=test3\n" _backstay_ rexpect

rex: hearrex1 /^foreplay pages, "test1"\n$/
rex: hearrex2 /^backplay.Backisle pages, "test2"\n$/
rex: hearrex3 /^backstay.Backisle pages, "test3"\n$/
[  'hearrex3	( Required patterns )
|
[  'hearrex1	( Forbidden patterns )
   'hearrex2
| nil _forestay rexpect2



( Clear the two gags: )

rex: pagerex /^\* @gag: backplay.Backisle is now ungagged\. \*\n$/
[  'pagerex
| "@gag backplay.Backisle=off\n" _forestay rexpect

rex: pagerex /^\* @gag: foreplay is now ungagged\. \*\n$/
[  'pagerex
| "@gag foreplay=off\n" _forestay rexpect



( List our gags: )

rex: forerex /^\* @gag: foreplay is gagged\. \*\n$/
rex: backrex /^\* @gag: backplay.Backisle is gagged\. \*\n$/
rex: totrex  /^\* @gag: 0 people gagged\. \*\n$/
[  'totrex	( Required patterns )
|
[  'forerex	( Forbidden patterns )
   'backrex
| "@gag\n" _forestay rexpect2




( Test the two gags are no longer operating: )

rex: pagerex /^You page "testy1"\n$/
[  'pagerex
| "pa forestay=testy1\n" _foreplay rexpect

rex: pagerex /^You page "testy2"\n$/
[  'pagerex
| "pa forestay.Foreisle=testy2\n" _backplay_ rexpect

rex: pagerex /^You page "testy3"\n$/
[  'pagerex
| "pa forestay.Foreisle=testy3\n" _backstay_ rexpect

rex: hearrex1 /^foreplay pages, "testy1"\n$/
rex: hearrex2 /^backplay.Backisle pages, "testy2"\n$/
rex: hearrex3 /^backstay.Backisle pages, "testy3"\n$/
[  'hearrex1
   'hearrex2
   'hearrex3
| nil _forestay rexpect



( =====================================================================	)
( - basic test of '@ban'						)



( Shouldn't be able to ban higher-ranking user: )

rex: pagerex /^\* @ban: May not do that: foreplay outranks you \(1000 to 1001\)\. \*\n$/
[  'pagerex
| "@ban foreplay=on\n" _forestay rexpect





( Establish two bans: )

rex: pagerex /^\* @ban: backplay.Backisle is now banned\. \*\n$/
[  'pagerex
| "@ban backplay.Backisle=on\n" _foreplay rexpect

rex: pagerex /^\* @ban: forestay is now banned\. \*\n$/
[  'pagerex
| "@ban forestay=on\n" _foreplay rexpect



( List our bans: )

rex: forerex /^\* @ban: forestay is banned\. \*\n$/
rex: backrex /^\* @ban: backplay.Backisle is banned\. \*\n$/
rex: totrex  /^\* @ban: 2 people banned\. \*\n$/
[  'forerex
   'backrex
   'totrex
| "@ban\n" _foreplay rexpect



( Test the two bans: )

rex: pagerex /^You page "tess1"\n$/
[  'pagerex
| "pa foreplay=tess1\n" _forestay rexpect

rex: pagerex /^You page "tess2"\n$/
[  'pagerex
| "pa foreplay.Foreisle=tess2\n" _backplay_ rexpect

rex: pagerex /^You page "tess3"\n$/
[  'pagerex
| "pa foreplay.Foreisle=tess3\n" _backstay_ rexpect

rex: hearrex1 /^forestay pages, "tess1"\n$/
rex: hearrex2 /^backplay.Backisle pages, "tess2"\n$/
rex: hearrex3 /^backstay.Backisle pages, "tess3"\n$/
[  'hearrex1	( Required patterns )
   'hearrex3
|
[  'hearrex2	( Forbidden patterns )
| nil _foreplay rexpect2



( Clear the two bans: )

rex: pagerex /^\* @ban: backplay.Backisle is now unbanned\. \*\n$/
[  'pagerex
| "@ban backplay.Backisle=off\n" _foreplay rexpect

rex: pagerex /^\* @ban: forestay is now unbanned\. \*\n$/
[  'pagerex
| "@ban forestay=off\n" _foreplay rexpect



( List our bans: )

rex: forerex /^\* @ban: forestay is banned\. \*\n$/
rex: backrex /^\* @ban: backplay.Backisle is banned\. \*\n$/
rex: totrex  /^\* @ban: 0 people banned\. \*\n$/
[  'totrex	( Required patterns )
|
[  'forerex	( Forbidden patterns )
   'backrex
| "@ban\n" _foreplay rexpect2



( Test the two bans are no longer operating: )

rex: pagerex /^You page "testes1"\n$/
[  'pagerex
| "pa foreplay=testes1\n" _forestay rexpect

rex: pagerex /^You page "testes2"\n$/
[  'pagerex
| "pa foreplay.Foreisle=testes2\n" _backplay_ rexpect

rex: pagerex /^You page "testes3"\n$/
[  'pagerex
| "pa foreplay.Foreisle=testes3\n" _backstay_ rexpect

rex: hearrex1 /^forestay pages, "testes1"\n$/
rex: hearrex2 /^backplay.Backisle pages, "testes2"\n$/
rex: hearrex3 /^backstay.Backisle pages, "testes3"\n$/
[  'hearrex1
   'hearrex2
   'hearrex3
| nil _foreplay rexpect



( =====================================================================	)
( - basic tests of 'go' ing through an exit, part II			)

rex: trex /^You enter the_Foreisle_Quay, with boat service to other isles.\s*\(go-able\)\n$/
rex: srex /^In the_Foreisle_Quay you see\s+S,\s+a path leading to the Nursery.\s+\(exit\)\n$/
rex: erex /^In the_Foreisle_Quay you see\s+E,\s+a road leading to the Crossroads.\s+\(exit\)\n$/
rex: nrex /^In the_Foreisle_Quay you see\s+N,\s+a path leading to the BadLands.\s+\(exit\)\n$/
rex: brex /^In the_Foreisle_Quay you see\s+Backisle,\s+a proa leaving for Backisle.\s+\(exit\)\n$/
rex: arex /^In the_Foreisle_Quay you see\s+foreplay,\s+a foreground traveller.\s+\(avatar; hears; notes; #1000\)\n$/
[  'trex
   'srex
   'erex
   'nrex
   'brex
   'arex
| "go N\n" _forestay rexpect

rex: come_rex /^\* forestay has arrived in the_Foreisle_Quay\.\s+forestay is a foreground stay-at-home\.\s+\(avatar; hears; notes; #1001\)\n$/
[  'come_rex
| nil _foreplay rexpect


( =====================================================================	)
( - same basic tests of 'go' ing through an exit, on background muq	)

rex: trex /^You enter the_Backisle_Quay, with boat service to other isles.\s*\(go-able\)\n$/
rex: srex /^In the_Backisle_Quay you see\s+S,\s+a path leading to the Nursery.\s+\(exit\)\n$/
rex: erex /^In the_Backisle_Quay you see\s+E,\s+a road leading to the Crossroads.\s+\(exit\)\n$/
rex: nrex /^In the_Backisle_Quay you see\s+N,\s+a path leading to the BadLands.\s+\(exit\)\n$/
rex: brex /^In the_Backisle_Quay you see\s+Foreisle,\s+a proa leaving for Foreisle.\s+\(exit\)\n$/
[  'trex
   'srex
   'erex
   'nrex
   'brex
| "go N\n" _backplay_ rexpect


rex: goingrex /^backplay goes 'N'\n$/
rex: gone_rex /^\* backplay has left the_Backisle_Nursery\.\n$/
[  'goingrex
   'gone_rex
| nil _backstay_ rexpect


( =====================================================================	)
( - basic tests of 'go' ing through a cross-server exit			)

rex: trex /^You enter the_Backisle_Quay, with boat service to other isles.\s*\(go-able\)\n$/
rex: srex /^In the_Backisle_Quay you see\s+S,\s+a path leading to the Nursery.\s+\(exit\)\n$/
rex: erex /^In the_Backisle_Quay you see\s+E,\s+a road leading to the Crossroads.\s+\(exit\)\n$/
rex: nrex /^In the_Backisle_Quay you see\s+N,\s+a path leading to the BadLands.\s+\(exit\)\n$/
rex: brex /^In the_Backisle_Quay you see\s+Foreisle,\s+a proa leaving for Foreisle.\s+\(exit\)\n$/
rex: arex /^In the_Backisle_Quay you see\s+backplay,\s+a background traveller\.\s+\(avatar; hears; notes\)\n$/
[  'trex
   'srex
   'erex
   'nrex
   'brex
   'arex
| "go Backisle\n" _foreplay rexpect


rex: goingrex /^foreplay goes 'Backisle'\n$/
rex: gone_rex /^\* foreplay has left the_Foreisle_Quay\.\n$/
[  'goingrex
   'gone_rex
| nil _forestay rexpect

rex: come_rex /^\* foreplay has arrived in the_Backisle_Quay\.\s+foreplay is a foreground traveller\.\s+\(avatar; hears; notes\)\n$/
[  'come_rex
| nil _backplay_ rexpect

( =====================================================================	)
( - basic test of 'look' ing at an avatar cross-server			)

rex: avatrex /^You see backplay, a dapper background traveller\n$/
[  'avatrex
| "look backplay\n" _foreplay rexpect

( =====================================================================	)
( - basic test of 'look' ing at an exit	cross-server			)

rex: exitrex /^You see n, a path leading to the BadLands\.\n$/
[  'exitrex
| "look N\n" _foreplay rexpect

( =====================================================================	)
( - basic test of 'say'	cross-server					)

rex: talkrex /^You say "hot enough for you\?"\n$/
[  'talkrex
| "say hot enough for you?\n" _foreplay rexpect

rex: hearrex /^foreplay says, "hot enough for you\?"\n$/
[  'hearrex
| nil _backplay_ rexpect

( =====================================================================	)
( - basic test of 'whisper' cross-server				)

rex: talkrex /^You whisper "hot enough for you\?"\n$/
[  'talkrex
| "w backplay=hot enough for you?\n" _foreplay rexpect

rex: hearrex /^foreplay whispers, "hot enough for you\?"\n$/
[  'hearrex
| nil _backplay_ rexpect


( =====================================================================	)
( - basic tests of 'go' ing back through a cross-server exit		)

rex: trex /^You enter the_Foreisle_Quay, with boat service to other isles.\s*\(go-able\)\n$/
rex: srex /^In the_Foreisle_Quay you see\s+S,\s+a path leading to the Nursery.\s+\(exit\)\n$/
rex: erex /^In the_Foreisle_Quay you see\s+E,\s+a road leading to the Crossroads.\s+\(exit\)\n$/
rex: nrex /^In the_Foreisle_Quay you see\s+N,\s+a path leading to the BadLands.\s+\(exit\)\n$/
rex: brex /^In the_Foreisle_Quay you see\s+Backisle,\s+a proa leaving for Backisle.\s+\(exit\)\n$/
rex: arex /^In the_Foreisle_Quay you see\s+forestay,\s+a foreground stay-at-home\.\s+\(avatar; hears; notes; #1001\)\n$/
[  'trex
   'srex
   'erex
   'nrex
   'brex
   'arex
| "go Foreisle\n" _foreplay rexpect


rex: goingrex /^foreplay goes 'Foreisle'\n$/
rex: gone_rex /^\* foreplay has left the_Backisle_Quay\.\n$/
[  'goingrex
   'gone_rex
| nil _backplay_ rexpect

rex: come_rex /^\* foreplay has arrived in the_Foreisle_Quay\.\s+foreplay is a foreground traveller\.\s+\(avatar; hears; notes; #1000\)\n$/
[  'come_rex
| nil _forestay rexpect

( =====================================================================	)
( - 'go' to foreground crossroads					)

rex: trex /^You enter the_Foreisle_Crossroads, with roads to user-built areas.\s+\(go-able; dig-ok\)\n$/
rex: srex /^In the_Foreisle_Crossroads you see\s+W,\s+a road leading to the Quay\.\s+\(exit\)\n$/
[  'trex
   'srex
| "go E\n" _foreplay rexpect


rex: goingrex /^foreplay goes 'E'\n$/
rex: gone_rex /^\* foreplay has left the_Foreisle_Quay\.\n$/
[  'goingrex
   'gone_rex
| nil _forestay rexpect

rex: trex /^You enter the_Foreisle_Crossroads, with roads to user-built areas.\s+\(go-able; dig-ok\)\n$/
rex: srex /^In the_Foreisle_Crossroads you see\s+W,\s+a road leading to the Quay\.\s+\(exit\)\n$/
rex: arex /^In the_Foreisle_Crossroads you see\s+foreplay,\s+a foreground traveller\.\s+\(avatar; hears; notes; #1000\)\n$/
[  'trex
   'srex
   'arex
| "go E\n" _forestay rexpect

rex: come_rex /^\* forestay has arrived in the_Foreisle_Crossroads\.\s+forestay is a foreground stay-at-home\.\s+\(avatar; hears; notes; #1001\)\n$/
[  'come_rex
| nil _foreplay rexpect


( =====================================================================	)
( - basic tests of 'dig' ging a room					)

rex: trex /^\* @dig complete \*\n$/
rex: srex /^\* N has arrived in the_Foreisle_Crossroads\.  \(exit\)\n$/
[  'trex
   'srex
| "@dig N=S=a_grassy_knoll\n" _foreplay rexpect

[  'srex
| nil _forestay rexpect

( =====================================================================	)
( - basic tests of describing a new exit				)

rex: trex /^\* Set\. \*\n$/
[  'trex
| "@short N=a winding path leading to a grassy knoll\n" _foreplay rexpect

rex: trex /^\* Set\. \*\n$/
[  'trex
| "@outside N=a long and winding path leading to a grassy knoll.\n" _foreplay rexpect

rex: exitrex /^You see n, a long and winding path leading to a grassy knoll\.\n$/
[  'exitrex
| "look N\n" _foreplay rexpect

( =====================================================================	)
( - 'go' to new room							)

rex: trex /^You enter a_grassy_knoll\.\s+\(go-able\)\n$/
rex: srex /^In a_grassy_knoll you see\s+S\.\s+\(exit\)\n$/
[  'trex
   'srex
| "go N\n" _foreplay rexpect

rex: goingrex /^foreplay goes 'N'\n$/
rex: gone_rex /^\* foreplay has left the_Foreisle_Crossroads\.\n$/
[  'goingrex
   'gone_rex
| nil _forestay rexpect

( =====================================================================	)
( - describe new room's exit						)

rex: trex /^\* Set\. \*\n$/
[  'trex
| "@outside S=a long and winding path leading to the crossroads.\n" _foreplay rexpect

rex: exitrex /^You see s, a long and winding path leading to the crossroads\.\n$/
[  'exitrex
| "look S\n" _foreplay rexpect

rex: trex /^\* Set\. \*\n$/
[  'trex
| "@short S=a winding path leading to the crossroads\n" _foreplay rexpect

( =====================================================================	)
( - describe new room proper						)

rex: trex /^\* Set\. \*\n$/
[  'trex
| "@short here=with suspicious impressions in the grass\n" _foreplay rexpect

rex: trex /^\* Set\. \*\n$/
[  'trex
| "@inside here=with suspicious impressions in the grass and a scattering of spent shell casings.\n" _foreplay rexpect

rex: hererex /^You see a_grassy_knoll \(go-able\)\, with suspicious impressions in the grass and a scattering of spent shell casings\.\n$/
rex: exitrex /^In a_grassy_knoll you see\s+S\,\s+a winding path leading to the crossroads\.\s+\(exit\)\n$/
[  'hererex
   'exitrex
| "look\n" _foreplay rexpect



( =====================================================================	)
( - 'go' back to crossroads						)

rex: trex /^You enter the_Foreisle_Crossroads, with roads to user-built areas\.\s+\(go-able; dig-ok\)\n$/
rex: srex /^In the_Foreisle_Crossroads you see\s+W,\s+a road leading to the Quay\.\s+\(exit\)\n$/
rex: nrex /^In the_Foreisle_Crossroads you see\s+N\,\s+a winding path leading to a grassy knoll.\s+\(exit\)\n$/
rex: arex /^In the_Foreisle_Crossroads you see\s+forestay,\s+a foreground stay-at-home\.\s+\(avatar; hears; notes; #1001\)\n$/
[  'trex
   'srex
   'nrex
   'arex
| "go S\n" _foreplay rexpect

rex: come_rex /^\* foreplay has arrived in the_Foreisle_Crossroads\.\s+foreplay is a foreground traveller\.\s+\(avatar; hears; notes; #1000\)\n$/
[  'come_rex
| nil _forestay rexpect


( =====================================================================	)
( - 'go' again to new room						)

rex: hererex /^You enter a_grassy_knoll, with suspicious impressions in the grass\.\s+\(go-able\)\n$/
rex: exitrex /^In a_grassy_knoll you see\s+S,\s+a winding path leading to the crossroads\.\s+\(exit\)\n$/
[  'hererex
   'exitrex
| "go N\n" _foreplay rexpect

rex: goingrex /^foreplay goes 'N'\n$/
rex: gone_rex /^\* foreplay has left the_Foreisle_Crossroads\.\n$/
[  'goingrex
   'gone_rex
| nil _forestay rexpect

rex: hererex /^You see a_grassy_knoll \(go-able\), with suspicious impressions in the grass and a scattering of spent shell casings\.\n$/
rex: exitrex /^In a_grassy_knoll you see\s+S,\s+a winding path leading to the crossroads\.\s+\(exit\)\n$/
[  'hererex
   'exitrex
| "look\n" _foreplay rexpect

rex: hererex /^You see a_grassy_knoll \(go-able\), with suspicious impressions in the grass and a scattering of spent shell casings\.\n$/
rex: exitrex /^In a_grassy_knoll you see\s+S,\s+a winding path leading to the crossroads\.\s+\(exit\)\n$/
[  'hererex
   'exitrex
| "look here\n" _foreplay rexpect


( =====================================================================	)
( - Have forestay 'go' to new room					)

rex: hererex /^You enter a_grassy_knoll, with suspicious impressions in the grass\.\s+\(go-able\)\n$/
rex: exitrex /^In a_grassy_knoll you see\s+S,\s+a winding path leading to the crossroads\.\s+\(exit\)\n$/
rex: playrex /^In a_grassy_knoll you see\s+foreplay,\s+a foreground traveller\.\s+\(avatar; hears; notes; #1000\)\n$/
[  'hererex
   'exitrex
   'playrex
| "go N\n" _forestay rexpect

rex: come_rex /^\* forestay has arrived in a_grassy_knoll\.\s+forestay is a foreground stay-at-home\.\s+\(avatar; hears; notes; #1001\)\n$/
[  'come_rex
| nil _foreplay rexpect



( =====================================================================	)
( - Have foreplay @eject forestay from new room				)

rex: hererex /^\* Ejecting forestay \*\n$/
[  'hererex
| "@eject forestay\n" _foreplay rexpect




( =====================================================================	)
( - 'go' back again to crossroads					)

# rex: trex /^You enter the_Foreisle_Crossroads, with roads to user-built areas\.\s+\(go-able; dig-ok\)\n$/
# rex: srex /^In the_Foreisle_Crossroads you see\s+W,\s+a road leading to the Quay\.\s+\(exit\)\n$/
# rex: nrex /^In the_Foreisle_Crossroads you see\s+N\,\s+a winding path leading to a grassy knoll.\s+\(exit\)\n$/
# rex: arex /^In the_Foreisle_Crossroads you see\s+forestay,\s+a foreground stay-at-home\.\s+\(avatar; hears; notes; #1001\)\n$/
# [  'trex
#    'srex
#    'nrex
#    'arex
# | "go S\n" _foreplay rexpect
# 
# rex: come_rex /^\* foreplay has arrived in the_Foreisle_Crossroads\.\s+foreplay is a foreground traveller\.\s+\(avatar; hears; notes; #1000\)\n$/
# [  'come_rex
# | nil _forestay rexpect



( =====================================================================	)
( - wrapup								)


"xx-oldmud2.muf Done.\n" log,

( =====================================================================	)

( - File variables							)


( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

