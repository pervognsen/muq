"xy-oldmud2 starting...\n" log,
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
( safe than sorry -- we may be running oldmud2 )
( all by itself:                               )
"xy-oldmud2.muf: Installing new longNames...\n" log,
rootIssueNewLongnamesToAllNatives

"xy-oldmud2 listing folkBy.hashName:\n" ,
.folkBy.hashName ls
.folkBy.nickName ls

( If foregroundRoot or foregroundMuqnet are in		)
( .folkBy.nickName (left over from x[xy]-muqnet)	)
( then delete them, since renumbering has invalidated	)
( them: 						)
.folkBy.nickName "foregroundRoot" get? -> r if
    r$s.hashName -> h
    delete: .folkBy.nickName["foregroundRoot"]
    delete: .folkBy.hashName[h]
    "Deleted foregroundRoot (" , h , ") from .folkBy\n" ,
fi
.folkBy.nickName "foregroundMuqnet" get? -> r if
    r$s.hashName -> h
    delete: .folkBy.nickName["foregroundMuqnet"]
    delete: .folkBy.hashName[h]
    "Deleted foregroundMuqnet (" , h , ") from .folkBy\n" ,
fi


"xy-oldmud2.muf: Starting muqnet...\n" log,
muqnet:rootStart



"xy-oldmud2.muf: Making sample isle...\n" log,
"Backisle" oldmud:makeIsle --> oldmudVars:_isle
[ oldmudVars:_isle "Backisle" | muqnet:rootRegisterIsle ]pop

( oldmud:makeSampleIsle )



( Create a pair of test users, backplay and backstay: )

"backplaybackplay" vals[
(    'z' |unshift )
(    'z' |unshift )
    |secureHash
    |secureHash 
]join --> _myEncryptedPassphrase

[ oldmudVars:_isle "backplay" "backplay" _myEncryptedPassphrase |
    rootOldmud:rootCreateMudUser
]--> _backplay

"backstaybackstay" vals[
(    'z' |unshift )
(    'z' |unshift )
    |secureHash
    |secureHash 
]join --> _myEncryptedPassphrase

[ oldmudVars:_isle "backstay" "backstay" _myEncryptedPassphrase |
    rootOldmud:rootCreateMudUser
]--> _backstay

"_backplay = " d, _backplay d, "\n" d,
"_backstay = " d, _backstay d, "\n" d,



"xy-oldmud2.muf: Starting isle daemons...\n" log,
rootOldmud:rootStartSampleOldmudIsleDaemons
"xy-oldmud2.muf: Started isle daemons...\n" log,

"xy-oldmud2.muf: Accepting logins...\n" log,
rootAcceptLogins



( Snooze peacefully until killed by signal: )
for i from 0 below 3000 do{
(    "\nxy-oldmud2 listing all jobs:\n" , )
(    rootPrintJobs )
(    "xy-oldmud2 done listing all jobs.\n" , )
    2000 sleepJob
}

"xy-oldmud2.muf: Exiting\n" log,
"xy-oldmud2 Done.\n" log,
