"xxz-oldmud3 starting...\n" log,
( 1000 --> _nextUserRank )
100000 --> .muq.nextGuestRank
1000   --> .muq.nextUserRank

.sys  --> s
  127 --> s.ip0 ( 127.0.0.1 is the	    )
    0 --> s.ip1 ( standard loopback	    )
    0 --> s.ip2 ( address.		    )
    1 --> s.ip3
50000 --> s.muqPort

.folkBy.nickName["muqnet"] --> s
rootOmnipotentlyDo{
  127 --> s.ip0 ( 127.0.0.1 is the	    )
    0 --> s.ip1 ( standard loopback	    )
    0 --> s.ip2 ( address.		    )
    1 --> s.ip3
50000 --> s.port
}

rootUpdateIPAddressesOfAllNatives

"downground" --> .muq.serverName

( This is redundant if we just ran muqnet2,    )
( which will normally be the case, but better  )
( safe than sorry -- we may be running oldmud3 )
( all by itself:                               )
"xxz-oldmud3.muf: Installing new longNames...\n" log,
rootIssueNewLongnamesToAllNatives

"xxz-oldmud3 listing folkBy.hashName:\n" log,
.folkBy.hashName foreach key val do{ [ "\t%s\t%s" key val | ]logPrint }

( Delete any unwanted old folk invalidated by renumbering: )
[   "foregroundRoot" "foregroundMuqnet"
    "backgroundRoot" "backgroundMuqnet"
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

"xxz-oldmud3 listing folkBy.hashName:\n" log,
.folkBy.hashName foreach key val do{ [ "\t%s\t%s" key val | ]logPrint }

"xxz-oldmud3 listing u:\n" log,
.u foreach key val do{ [ "\t%s\t%s" key val | ]logPrint }

muqnet:rootClearIsleRegister
muqnet:clearWellKnownServerRegister
nil --> oldmudVars:_isle

"xxz-oldmud3.muf: Starting muqnet...\n" log,
muqnet:rootStart



"xxz-oldmud3.muf: Making sample isle...\n" log,
"Downisle" oldmud:makeIsle --> oldmudVars:_isle
[ oldmudVars:_isle "Downisle" | muqnet:rootRegisterIsle ]pop

( oldmud:makeSampleIsle )



( Create a pair of test users, downplay and downstay: )

.folkBy.nickName "downplay" get? --> _downplay not if
    "downplaydownplay" vals[
    (    'z' |unshift )
    (    'z' |unshift )
	|secureHash
	|secureHash 
    ]join --> _myEncryptedPassphrase

    [ oldmudVars:_isle "downplay" "downplay" _myEncryptedPassphrase |
	rootOldmud:rootCreateMudUser
    ]--> _downplay
fi

.folkBy.nickName "downstay" get? --> _downstay not if
    "downstaydownstay" vals[
    (    'z' |unshift )
    (    'z' |unshift )
	|secureHash
	|secureHash 
    ]join --> _myEncryptedPassphrase

    [ oldmudVars:_isle "downstay" "downstay" _myEncryptedPassphrase |
	rootOldmud:rootCreateMudUser
    ]--> _downstay
fi

"_downplay = " d, _downplay d, "\n" d,
"_downstay = " d, _downstay d, "\n" d,



"xxz-oldmud3.muf: Starting isle daemons...\n" log,
rootOldmud:rootStartSampleOldmudIsleDaemons
"xxz-oldmud3.muf: Started isle daemons...\n" log,

"xxz-oldmud3.muf: Accepting logins...\n" log,
rootAcceptLogins



( Snooze peacefully until killed by signal: )
for i from 0 below 300 do{
    "\nxxz-oldmud3 listing all jobs:\n" ,
    rootPrintJobs
    "xxz-oldmud3 done listing all jobs.\n" ,
    10000 sleepJob
}

"xxz-oldmud3.muf: Exiting\n" log,
"xxz-oldmud3 Done.\n" log,
