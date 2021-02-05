"xxy-oldmud3 starting...\n" log,
( 1000 --> _nextUserRank )
100000 --> .muq.nextGuestRank
1000   --> .muq.nextUserRank

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

( This is redundant if we just ran muqnet2,    )
( which will normally be the case, but better  )
( safe than sorry -- we may be running oldmud3 )
( all by itself:                               )
"xxy-oldmud3.muf: Installing new longNames...\n" log,
rootIssueNewLongnamesToAllNatives

"xxy-oldmud3 listing folkBy.hashName:\n" log,
.folkBy.hashName foreach key val do{ [ "\t%s\t%s" key val | ]logPrint }

( Delete any unwanted old folk invalidated by renumbering: )
[   "foregroundRoot" "foregroundMuqnet"
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

"xxy-oldmud3 listing folkBy.hashName:\n" log,
.folkBy.hashName foreach key val do{ [ "\t%s\t%s" key val | ]logPrint }

"xxy-oldmud3 listing u:\n" log,
.u foreach key val do{ [ "\t%s\t%s" key val | ]logPrint }

muqnet:rootClearIsleRegister
muqnet:clearWellKnownServerRegister
nil --> oldmudVars:_isle

"xxy-oldmud3.muf: Starting muqnet...\n" log,
muqnet:rootStart



"xxy-oldmud3.muf: Making sample isle...\n" log,
"Backisle" oldmud:makeIsle --> oldmudVars:_isle
[ oldmudVars:_isle "Backisle" | muqnet:rootRegisterIsle ]pop

( oldmud:makeSampleIsle )



( Create a pair of test users, backplay and backstay: )

.folkBy.nickName "backplay" get? --> _backplay not if
    "backplaybackplay" vals[
    (    'z' |unshift )
    (    'z' |unshift )
	|secureHash
	|secureHash 
    ]join --> _myEncryptedPassphrase

    [ oldmudVars:_isle "backplay" "backplay" _myEncryptedPassphrase |
	rootOldmud:rootCreateMudUser
    ]--> _backplay
fi

.folkBy.nickName "backstay" get? --> _backstay not if
    "backstaybackstay" vals[
    (    'z' |unshift )
    (    'z' |unshift )
	|secureHash
	|secureHash 
    ]join --> _myEncryptedPassphrase

    [ oldmudVars:_isle "backstay" "backstay" _myEncryptedPassphrase |
	rootOldmud:rootCreateMudUser
    ]--> _backstay
fi

"_backplay = " d, _backplay d, "\n" d,
"_backstay = " d, _backstay d, "\n" d,



"xxy-oldmud3.muf: Starting isle daemons...\n" log,
rootOldmud:rootStartSampleOldmudIsleDaemons
"xxy-oldmud3.muf: Started isle daemons...\n" log,

"xxy-oldmud3.muf: Accepting logins...\n" log,
rootAcceptLogins



( Snooze peacefully until killed by signal: )
for i from 0 below 300 do{
    "\nxxy-oldmud3 listing all jobs:\n" ,
    rootPrintJobs
    "xxy-oldmud3 done listing all jobs.\n" ,
    10000 sleepJob
}

"xxy-oldmud3.muf: Exiting\n" log,
"xxy-oldmud3 Done.\n" log,
