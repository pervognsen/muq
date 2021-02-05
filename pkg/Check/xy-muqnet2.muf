"xy-muqnet2 starting...\n" log,

12 --> .twelve
13 --> .thirteen

.sys  --> s
  127 --> s.ip0 ( 127.0.0.1 is the	    )
    0 --> s.ip1 ( standard loopback	    )
    0 --> s.ip2 ( address.		    )
    1 --> s.ip3
40000 --> s.muqPort

.folkBy.nickName["muqnet"] --> s
rootOmnipotentlyDo{
  127 --> s.ip0 ( 127.0.0.1 is the	    )
    0 --> s.ip1 ( standard loopback	    )
    0 --> s.ip2 ( address.		    )
    1 --> s.ip3
40000 --> s.port
}

rootUpdateIPAddressesOfAllNatives

"background" --> .muq.serverName

"xy-muqnet2.muf installing new longNames...\n" ,
rootIssueNewLongnamesToAllNatives

( Create a user which won't be on the foreground server: )
:: "terry" rootMakeAUser ;   shouldWork


( Start up a stream echo server so main server can test MaybeWriteStream: )
"t23" forkJob not if
    ( We're the child.  Since this is just a test hack  )
    ( we'll omit the usual shell armor-plating designed )
    ( to keep us running after errors, defeat spoofers  )
    ( and other such good stuff:                        )
    2000000   -> millisecsToWait
    t   -> noFragments	( Complete packets only, please. )

    0 -> replies-received
    makeMessageStream -> ourStream
    ourStream --> .xyMuqnet2TestStream

    do{
	( Read a packet: )
	[ ourStream | noFragments millisecsToWait
	    |readAnyStreamPacket
	    -> stream
	    -> who
	    -> tag

	    stream not if   ]pop loopNext   fi

	    |dup -> replyStream

	    tag t replyStream |maybeWriteStreamPacket pop pop
	]pop	
    }
fi



muqnet:rootStart
600000 sleepJob
"xy-muqnet2.muf exiting\n" ,
"xy-muqnet2 done.\n" log,
