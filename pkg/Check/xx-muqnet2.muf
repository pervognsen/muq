( - xx-muqnet2.muf -- Test code for muqnet code.			)
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


"xx-muqnet2 starting...\n" log,

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

"foreground" --> .muq.serverName

rootUpdateIPAddressesOfAllNatives

muqnet:rootStart


"\n" ,
"dbBufSize = " , .muq.dbBufSize , "\n" ,
"dbLoads = " , .muq.dbLoads , "\n" ,
"dbMakes = " , .muq.dbMakes , "\n" ,
"dbSaves = " , .muq.dbSaves , "\n" ,
"bytesInFreeBlocks = " , .muq.bytesInFreeBlocks , "\n" ,
"bytesInUsefulData = " , .muq.bytesInUsefulData , "\n" ,
"bytesLostInUsedBlocks = " , .muq.bytesLostInUsedBlocks , "\n" ,
"freeBlocks = " , .muq.freeBlocks , "\n" ,
"usedBlocks = " , .muq.usedBlocks , "\n" ,
"garbageCollects = " , .muq.garbageCollects , "\n" ,
"bytesRecoveredInLastGarbageCollect = " , .muq.bytesRecoveredInLastGarbageCollect , "\n" ,
"blocksRecoveredInLastGarbageCollect = " , .muq.blocksRecoveredInLastGarbageCollect , "\n" ,
"bytesBetweenGarbageCollects = " , .muq.bytesBetweenGarbageCollects , "\n" ,

( Give ourselves a nice big ram buffer )
( to avoid dealing with swapping or    )
( garbage collects during testruns:    )
20000000 --> .muq.dbBufSize


( Space garbage collects well out: )
10000000 --> .muq.bytesBetweenGarbageCollects

( Give background server a decent chance to get started: )
5000 sleepJob



( =====================================================================	)
( - Test authentication-related muqnet mechanisms			)

( =====================================================================	)
( - checkGetMuqnetUser -- Ask for background server's muqnet user		)


( Set up a stream and job to receive network replies: )
0  --> _resentPackets
0  --> _repliesReceived
30 --> _packetsToSend

:   checkGetMuqnetUser { -> }
( .sys.muqPort , "(xx-)<" , @ , ">checkGetMuqnetUser.aaa\n" , )

    "t16" forkJob if
( .sys.muqPort , "(xx-)<" , @ , ">checkGetMuqnetUser.parent.aaa\n" , )
	( We're the parent job.  )
        ( Wait for replies to straggle in: )
        for i from 1 below 100 do{
	    _repliesReceived 0 != if loopFinish fi
	    1000 sleepJob
        }
( .sys.muqPort , "(xx-)<" , @ , ">checkGetMuqnetUser.parent.zzz\n" , )
    else 
( .sys.muqPort , "(xx-)<" , @ , ">checkGetMuqnetUser.child.aaa\n" , )
	( We're the child.  Since this is just a test hack  )
	( we'll omit the usual shell armor-plating designed )
	( to keep us running after errors, defeat spoofers  )
	( and other such good stuff:                        )
	2000   -> millisecsToWait
	t   -> noFragments	( Complete packets only, please. )

	0 -> replies-received
	makeMessageStream -> replyStream

( .sys.muqPort , "(xx-)<" , @ , ">checkGetMuqnetUser.child.bbb -- calling sendGetMuqnetUserInfo\n" , )
	[   replyStream
	    .sys.ip0
	    .sys.ip1
	    .sys.ip2
	    .sys.ip3
	    40000
	    1
	|   muqnet:sendGetMuqnetUserInfo ]pop
( .sys.muqPort , "(xx-)<" , @ , ">checkGetMuqnetUser.child.ccc -- called  sendGetMuqnetUserInfo\n" , )

	0 -> lastReply
	do{
( .sys.muqPort , "(xx-)<" , @ , ">checkGetMuqnetUser.child.ddd -- luptop\n" , )
	    ( Read a packet: )
	    [ replyStream | noFragments millisecsToWait
		|readAnyStreamPacket
		-> stream
		-> who
		-> tag
( .sys.muqPort , "(xx-)<" , @ , ">checkGetMuqnetUser.child.eee -- who = " , who , " tag = " , tag , "\n" , )
( .sys.muqPort , "(xx-)<" , @ , ">checkGetMuqnetUser.child.eee -- stream = " , stream , "\n" , )
( .sys.muqPort , "(xx-)<" , @ , ">sendIsle argblock is:\n" , )
( |for val iii do{ .sys.muqPort , "(xx-) #" , iii , ": " , val , "\n" , } )
( .sys.muqPort , "(xx-)<" , @ , ">sendisle done listing argblock\n" , )
		stream not if
( .sys.muqPort , "(xx-)<" , @ , ">checkGetMuqnetUser.child.fff -- recalling sendGetMuqnetUserInfo\n" , )
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
( .sys.muqPort , "(xx-)<" , @ , ">checkGetMuqnetUser.child.ggg -- recalled  sendGetMuqnetUserInfo\n" , )
		    loopNext
		else
( .sys.muqPort , "(xx-)<" , @ , ">checkGetMuqnetUser.child.ggg -- recalling sendGetMuqnetUserInfo\n" , )
		fi
		|shift -> seq
	    ]pop	

	    ( Ignore duplicates due to  )
	    ( premature retransmission: )
	    seq lastReply <= if loopNext fi
	    seq -> lastReply

	    ++ _repliesReceived

( .sys.muqPort , "(xx-)<" , @ , ">checkGetMuqnetUser.child.zzz\n" , )
	    nil endJob
	}
    fi
;
:: checkGetMuqnetUser ; shouldWork
:: _repliesReceived 1 = ; shouldBeTrue
:: .folkBy.nickName["backgroundMuqnet"] guest? ; shouldBeTrue


( =====================================================================	)
( - checkTestPacket -- logic to automatically query for unknown users	)

( Set up a stream and job to receive network replies: )
0   --> _resentPackets
0   --> _repliesReceived
30  --> _packetsToSend
nil --> _otherServersRootObject

:   checkTestPacket { -> }

    "t17" forkJob if
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

	replyStream
(	.folkBy.nickName["muqnet2"] )
	.folkBy.nickName["backgroundMuqnet"]
	1
	muqnet:sendTestPacket

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
		    _resentPackets _packetsToSend = if loopFinish fi

		    replyStream
(		    .folkBy.nickName["muqnet2"] )
		    .folkBy.nickName["backgroundMuqnet"]
		    lastReply 1 +
		    muqnet:sendTestPacket

		    loopNext
		else
		    :object |get -> obj
		    :seq    |get -> seq
		    ]pop	

		    ( Ignore duplicates due to  )
		    ( premature retransmission: )
		    seq lastReply 1 + != if loopNext fi
		    seq -> lastReply

		    obj --> _otherServersRootObject
		    ++ _repliesReceived
		    loopFinish
		fi
	    ]pop	

	}
	nil endJob
    fi
;

( :: .folkBy.nickName "root2" get? pop ; shouldBeFalse )
:: .folkBy.nickName "backgroundRoot" get? pop ; shouldBeFalse
:: checkTestPacket ; shouldWork
:: _repliesReceived 1 = ; shouldBeTrue
( :: .folkBy.nickName "root2" get? pop ; shouldBeTrue )
:: .folkBy.nickName "backgroundRoot" get? pop ; shouldBeTrue
( :: .folkBy.nickName["root2"] guest? ; shouldBeTrue )
:: .folkBy.nickName["backgroundRoot"] guest? ; shouldBeTrue


( =====================================================================	)
( - checkSetUser -- Test writing local user to background server	)

( Create a user which won't be on the background server: )
:: "kim" rootMakeAUser ;   shouldWork

.u["kim"]$s.hashName --> _hashName
0  --> _resentPackets
0  --> _repliesReceived
30 --> _packetsToSend

:   checkSetUser { -> }
    "t18" forkJob if
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
	0 -> lastReply

	.u["kim"]
        rootAsUserDo{
	    replyStream
	    lastReply 1 +
(	    .folkBy.nickName["muqnet2"] )
	    .folkBy.nickName["backgroundMuqnet"]
	    muqnet:sendSetUserInfo
	}

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

		    .u["kim"] rootAsUserDo{
			replyStream
			lastReply 1 +
(			.folkBy.nickName["muqnet2"] )
			.folkBy.nickName["backgroundMuqnet"]
			muqnet:sendSetUserInfo
		    }
		    loopNext
		else
		fi
		:seq |get -> seq
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
:: checkSetUser ; shouldWork
:: _repliesReceived 1 = ; shouldBeTrue

( =====================================================================	)
( - checkReadUserHash -- Read hash for "terry" from background server	)

nil --> _terrysHashName
0   --> _resentPackets
0   --> _repliesReceived
30  --> _packetsToSend

:   checkReadUserHash { -> }
    "t19" forkJob if
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
	0 -> lastReply

	replyStream
	lastReply 1 +
	"terry"
(        .folkBy.nickName["muqnet2"] )
        .folkBy.nickName["backgroundMuqnet"]
	muqnet:sendGetUserHash

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

		    replyStream
		    lastReply 1 +
		    "terry"
(		    .folkBy.nickName["muqnet2"] )
		    .folkBy.nickName["backgroundMuqnet"]
		    muqnet:sendGetUserHash

		    loopNext
		else
		fi
		:seq      |get -> seq
		:hashName |get -> terryshashname
	    ]pop	

	    ( Ignore duplicates due to  )
	    ( premature retransmission: )
	    seq lastReply <= if loopNext fi
	    seq -> lastReply
	    terryshashname --> _terrysHashName

	    ++ _repliesReceived

	    nil endJob
	}
    fi
;
:: checkReadUserHash ; shouldWork
:: _repliesReceived 1 = ; shouldBeTrue
:: _terrysHashName integer? ; shouldBeTrue


( =====================================================================	)
( - checkReadUserInfo -- Read info for "terry" from background server	)

nil --> _terrysLongName
0   --> _resentPackets
0   --> _repliesReceived
30  --> _packetsToSend

:   checkReadUserInfo { -> }
    "t20" forkJob if
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
	0 -> lastReply

	replyStream
	lastReply 1 +
	_terrysHashName
(        .folkBy.nickName["muqnet2"] )
        .folkBy.nickName["backgroundMuqnet"]
	muqnet:sendGetUserInfo

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

		    replyStream
		    lastReply 1 +
		    _terrysHashName
(		    .folkBy.nickName["muqnet2"] )
		    .folkBy.nickName["backgroundMuqnet"]
		    muqnet:sendGetUserInfo

		    loopNext
		else
		fi
		:seq      |get -> seq
  	        :longName |get -> terryslongname
	    ]pop	

	    ( Ignore duplicates due to  )
	    ( premature retransmission: )
	    seq lastReply <= if loopNext fi
	    seq -> lastReply
	    terryslongname --> _terrysLongName

	    ++ _repliesReceived

	    nil endJob
	}
    fi
;
:: checkReadUserInfo ; shouldWork
:: _repliesReceived 1 = ; shouldBeTrue
:: _terrysLongName bignum? ; shouldBeTrue



( =====================================================================	)
( - checkGetVal -- Test ability to read a value from an object		)

nil --> _xyMuqnet2TestStream

:   checkGetVal { -> }
    _otherServersRootObject.twelve --> _twelve
    _otherServersRootObject :thirteen get? --> _thirteen --> _gotThirteen
    _otherServersRootObject :fourteen get? --> _fourteen --> _gotFourteen
    _otherServersRootObject.xyMuqnet2TestStream --> _xyMuqnet2TestStream

;


:: checkGetVal ; shouldWork
:: _twelve 12 = ; shouldBeTrue
:: _thirteen 13 = ; shouldBeTrue
:: _gotThirteen ; shouldBeTrue
:: _fourteen 14 = ; shouldBeFalse
:: _gotFourteen ; shouldBeFalse
:: _xyMuqnet2TestStream ; shouldBeTrue

( =====================================================================	)
( - checkGetVal_OfUser -- Test that users become guests, not proxies	)

:   checkGetVal_OfUser { -> }
    _otherServersRootObject.u --> _otherServersU
    _otherServersU["root"] --> _otherServersRoot
;

:: checkGetVal_OfUser ; shouldWork
:: _otherServersRoot guest? ; shouldBeTrue

( =====================================================================	)
( - checkMaybeWriteStreamPacket -- Test transparent packet forwarding	)

0   --> _resentPackets
0   --> _repliesReceived
30  --> _packetsToSend
nil --> _datum1

:   checkMaybeWriteStreamPacket { -> }
    "t21" forkJob if
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
	makeMessageStream --> _replyStream
	0 -> lastReply

        [ _replyStream | "txt" t _xyMuqnet2TestStream |maybeWriteStreamPacket pop pop ]pop

	do{
	    ( Read a packet: )
	    [ _replyStream | noFragments millisecsToWait
		|readAnyStreamPacket
		-> stream
		-> who
		-> tag
		stream not if
		    ]pop
		    ++ _resentPackets

	            [ _replyStream | "txt" t _xyMuqnet2TestStream |maybeWriteStreamPacket pop pop ]pop

		    loopNext
		else
		fi
		|pop --> _datum1
	    ]pop	

	    ++ _repliesReceived

	    nil endJob
	}
    fi
;
:: checkMaybeWriteStreamPacket ; shouldWork
:: _replyStream _datum1 = ; shouldBeTrue



( =====================================================================	)
( - Test ping performance under various loads				)

( Set up a stream and job to receive network replies: )
0  --> _resentPackets
0  --> _mainJobRepliesReceived
0  --> _totalRepliesReceived
30 --> _packetsToSend



( =====================================================================	)
( - do100 -- Run ping-performance test, one job.			)

:   do100 { $ -> }
    -> me

    "t22" forkJob not if

	( We're the child.  Since this is just a test hack  )
	( we'll omit the usual shell armor-plating designed )
	( to keep us running after errors, defeat spoofers  )
	( and other such good stuff:                        )
	2000   -> millisecsToWait
	t   -> noFragments	( Complete packets only, please. )

	0 -> replies-received
	makeMessageStream -> replyStream

	replyStream
(	.folkBy.nickName["muqnet2"] )
	.folkBy.nickName["backgroundMuqnet"]
	1
	muqnet:sendPing

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
		    replyStream
(		    .folkBy.nickName["muqnet2"] )
		    .folkBy.nickName["backgroundMuqnet"]
		    lastReply 1 +
		    muqnet:sendPing
		    loopNext
		fi
		:seq |get -> seq
	    ]pop	

	    ( Ignore duplicates due to  )
	    ( premature retransmission: )
	    seq lastReply <= if loopNext fi
	    seq -> lastReply

	    ++ _totalRepliesReceived
	    me 1 = if ++ _mainJobRepliesReceived fi

	    lastReply _packetsToSend = if
		nil endJob
	    fi

	    replyStream
(	    .folkBy.nickName["muqnet2"]  )
	    .folkBy.nickName["backgroundMuqnet"]
	    lastReply 1 +
	    muqnet:sendPing
	}
    fi
;


( =====================================================================	)
( - _testRun -- Run ping-performance test with N jobs			)

: _testRun { $ -> }
    -> jobs


    ( Force a garbage-collect to prevent gc in the middle )
    ( of a run from disrupting our statistics:            )
    rootCollectGarbage pop

    0 --> _mainJobRepliesReceived
    0 --> _totalRepliesReceived

    .sys.millisecsSince1970 --> *date-millisecs1*
    *date-millisecs1* 1000 / --> *date-secs1*
    .sys.dateMicroseconds --> *date-usecs1*

    .muq.dateOfLastGarbageCollect -> lastGc

    for i from 1 upto jobs do{ i do100 }

    ( Wait for replies to straggle in: )
    for i from 1 below 100 do{
	_mainJobRepliesReceived _packetsToSend = if loopFinish fi
	1000 sleepJob
    }

    .sys.millisecsSince1970 --> *date-millisecs2*
    *date-millisecs2* 1000 / --> *date-secs2*
    .sys.dateMicroseconds --> *date-usecs2*

    *date-secs2*  *date-secs1*  - 1.0 *
    *date-usecs2* *date-usecs1* - 0.000001 *   +  -> _elapsedSecs



    [ "%4d  " jobs | ]print ,
    [ "%5d  " _packetsToSend | ]print ,
    [ "%7d  " jobs _packetsToSend * | ]print ,
    [ "%7d  " _totalRepliesReceived | ]print ,

    [ "%-8.5g "   _elapsedSecs | ]print ,
    [ "%-11.5g  " _elapsedSecs _packetsToSend / | ]print ,
    [ "%-11.5g  "   _elapsedSecs _totalRepliesReceived / | ]print ,
    [ "%4d" _resentPackets | ]print ,

    .muq.dateOfLastGarbageCollect lastGc != if " [gc]" , fi

    "\n" ,
;

( =====================================================================	)
( - Print header to output						)

"\n\n\n" ,
"  Statistics on how long it takes two Muq servers to exchange\n" ,
"  roundTrip packets as a function of the number of Muq jobs\n" ,
"  competing simultaneously.  Decreasing values of Amortized\n" ,
"  Roundtrip Time may indicate inefficiency in process switching\n" ,
"  between the two Muq servers:\n\n" ,
"                               Total    Absolute     Amortized\n" ,
"      Round  Expected Actual   Elapsed  Roundtrip    Roundtrip  Packets\n" ,
"Jobs  trips  Replies  Replies  Seconds  Time         Time       Resent\n" ,
"----  -----  -------  -------  -------  -----------  ---------- ------\n" ,



( =====================================================================	)
( - Do the actual test runs on ping performance				)

   1 _testRun
   2 _testRun
   4 _testRun
   8 _testRun
  16 _testRun
  32 _testRun

( 64 _testRun )
( 128 _testRun )
( 256 _testRun )


:: _totalRepliesReceived 0 > ; shouldBeTrue
"xx-muqnet2 done.\n" log,

( =====================================================================	)

( - File variables							)


( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

