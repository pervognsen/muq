@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)
@example  @c

( - 190-C-muqnet.muf -- Transparent inter-MUQ networking support.	)
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
( - Dedication and Copyright.						)

(  -------------------------------------------------------------------  )
(									)
(		For Firiss:  Aefrit, a friend.				)
(									)
(  -------------------------------------------------------------------  )

(  -------------------------------------------------------------------  )
( Author:       Jeff Prothero						)
( Created:      96Dec31							)
( Modified:								)
( Language:     MUF							)
( Package:      N/A							)
( Status:       							)
( 									)
(  Copyright (c) 1997, by Jeff Prothero.				)
( 									)
(  This program is free software; you may use, distribute and/or modify	)
(  it under the terms of the GNU Library General Public License as      )
(  published by	the Free Software Foundation; either version 2, or at   )
(  your option	any later version FOR NONCOMMERCIAL PURPOSES.		)
(									)
(  COMMERCIAL operation allowable at $100/CPU/YEAR.			)
(  COMMERCIAL distribution (e.g., on CD-ROM) is UNRESTRICTED.		)
(  Other commercial arrangements NEGOTIABLE.				)
(  Contact cynbe@@eskimo.com for a COMMERCIAL LICENSE.			)
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
( NO EVENT SHALL JEFF PROTHERO BE LIABLE FOR ANY SPECIAL, INDIRECT OR	)
( CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS	)
( OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,		)
( NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION	)
( WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.				)
( 									)
( Please send bug reports/fixes etc to bugs@@muq.org.			)
(  -------------------------------------------------------------------	)

( =====================================================================	)
( - Quip								)
(									)
(   No Muq is an island, sufficient unto itself.			)

( =====================================================================	)
( - Hint								)
(									)
(   When doing down-and-dirty debugging on the networking logic,	)
(   involving several Muq servers each running several daemons,		)
(   what I do is have all the servers log to the same logfile		)
(   and then insert debugging printout lines like			)
(									)
(       [ "190-C-muqnet.sendIle.aaa: arg = %s" arg | ]logPrint		)
(									)
(   These lines will all be written to the logfile in correct order,	)
(   labelled by process, job and time.					)
(									)
(   A 1600-pixel wide screen or better is a help when reading the	)
(   logfile!								)
(									)
(   Note that the logfile format is designed to make it easy to grep	)
(   or otherwise automatically process:  Do so!				)


( =====================================================================	)
( - Package declaration							)

"muqnet" inPackage

( =====================================================================	)
( - Muqnet overview							)
(									)
( Muqnet exists to facilitate implementation of distributed		)
( applications across multiple Muq servers:  The ultimate		)
( goal is to approach as closely as practical to merging		)
( multiple Muq servers into a single computing environment		)
( which looks so seamless to the application programmer			)
( that only the REMOTE? predicate can distinguish which			)
( objects are on the local server and which on other servers.		)
( 									)
( The primary implementation strategy is keep each object		)
( on its home server, but to provide "proxies" for it on		)
( other servers which look local but transparently communicate		)
( with the home server when accessed.					)
( 									)
( The Muqnet daemon and package formats exist to implement		)
( this transparent communication in support of proxy objects.		)
( 									)
( Muqnet uses UDP packets rather than TCP streams because		)
( in a system of thousands of Muq servers containing millions		)
( of proxy objects, the communication pattern is likely to be		)
( many short exchanges often consisting of a single round trip,		)
( much different from the TCP model of a long-lasting virtual		)
( connection carrying a steady data stream.  HTTP suffers		)
( considerably from abusing TCP in this fashion, and I'd like		)
( to avoid repeating that mistake with Muqnet.				)
( 									)
( Thus, the fundamental Muqnet operation is transmission,		)
( receipt and processing of a packet (datagram).			)
( 									)
( The Muq |enbyte and |debyte prims provide support for			)
( converting most Muq values to and from a portable bytestream		)
( format suitable for transmission over the Internet.  (Muq		)
( types not supported are those whose transmission doesn't		)
( really make sense, such as the special blockDelimiter		)
( values.)								)
( 									)
( Muqnet packets begin with a char opcode.  The rest			)
( of the packet format is opcode-specific:				)
( 									)
( 									)
( 									)
(   Op 0:  OP-PING.							)
(   int:   i0, i1, i2	# From object					)
(   int:   seq		# Arbitrary integer				)
( 									)
( OP-PING requests a PING be sent to given address.			)
( 									)
( 									)
( 									)
(   Op 1:  PING.							)
(   int:   ti0,  ti1, ti2	# To-object				)
(   int:   seq			# From OP-PING				)
( 									)
( PING packets are sent in response to DO-PING packets.			)


( =====================================================================	)
( - Constants								)


( If you update the following constants, remember to )
( make the corresponding changes to _dispatchVector: )

 0         -->constant REQ_GET_MUQNET_USER_INFO_I	'REQ_GET_MUQNET_USER_INFO_I  export
 0 intChar -->constant REQ_GET_MUQNET_USER_INFO		'REQ_GET_MUQNET_USER_INFO    export
 1 intChar -->constant ACK_GET_MUQNET_USER_INFO		'ACK_GET_MUQNET_USER_INFO    export

 2         -->constant REQ_GET_USER_INFO_I	'REQ_GET_USER_INFO_I  export
 2 intChar -->constant REQ_GET_USER_INFO	'REQ_GET_USER_INFO    export
 3 intChar -->constant ACK_GET_USER_INFO	'ACK_GET_USER_INFO    export

( Ops above this point require special handling in )
( muqnet:run; those below are handled uniformly:   )
 4 intChar -->constant FIRST_VANILLA_REQ_OP 'FIRST_VANILLA_REQ_OP export

 4 intChar -->constant REQ_PING			'REQ_PING export
 5 intChar -->constant ACK_PING			'ACK_PING export

 6 intChar -->constant REQ_ISLES		'REQ_ISLES export
 7 intChar -->constant ACK_ISLES		'ACK_ISLES export

 8 intChar -->constant REQ_ISLE			'REQ_ISLE  export
 9 intChar -->constant ACK_ISLE			'ACK_ISLE  export

10 intChar -->constant REQ_GET_VAL		'REQ_GET_VAL export
11 intChar -->constant ACK_GET_VAL		'ACK_GET_VAL export

12 intChar -->constant REQ_TEST_PACKET		'REQ_TEST_PACKET    export
13 intChar -->constant ACK_TEST_PACKET		'ACK_TEST_PACKET    export

14 intChar -->constant REQ_GET_USER_HASH	'REQ_GET_USER_HASH  export
15 intChar -->constant ACK_GET_USER_HASH	'ACK_GET_USER_HASH  export

16 intChar -->constant REQ_MAYBE_WRITE_STREAM_PACKET 'REQ_MAYBE_WRITE_STREAM_PACKET export
17 intChar -->constant ACK_MAYBE_WRITE_STREAM_PACKET 'ACK_MAYBE_WRITE_STREAM_PACKET export

18 intChar -->constant REQ_SET_USER_INFO	'REQ_SET_USER_INFO  export
19 intChar -->constant ACK_SET_USER_INFO	'ACK_SET_USER_INFO  export

20 intChar -->constant REQ_VALIDATE_NAME_CHANGE	'REQ_VALIDATE_NAME_CHANGE export
21 intChar -->constant ACK_VALIDATE_NAME_CHANGE	'ACK_VALIDATE_NAME_CHANGE export

22 intChar -->constant REQ_GET_KEY		'REQ_GET_KEY export
23 intChar -->constant ACK_GET_KEY		'ACK_GET_KEY export

24 intChar -->constant REQ_GET_NEXT_KEY		'REQ_GET_NEXT_KEY export
25 intChar -->constant ACK_GET_NEXT_KEY		'ACK_GET_NEXT_KEY export

( If you add/remove opcodes above, remember to update "opname" below! )



( =====================================================================	)
( - opname -- map opcode to symbol					)

:   opname { $ -> $ }
    -> op

    op fixnum? if op intChar -> op fi

    ( This fn is strictly debug support, )
    ( so efficiency isn't a big deal:    )

    op case{

    on: REQ_GET_MUQNET_USER_INFO 'REQ_GET_MUQNET_USER_INFO
    on: ACK_GET_MUQNET_USER_INFO 'ACK_GET_MUQNET_USER_INFO

    on: REQ_GET_USER_INFO        'REQ_GET_USER_INFO
    on: ACK_GET_USER_INFO        'ACK_GET_USER_INFO

    on: REQ_PING                 'REQ_PING
    on: ACK_PING                 'ACK_PING

    on: REQ_ISLES                'REQ_ISLES
    on: ACK_ISLES                'ACK_ISLES

    on: REQ_ISLE                 'REQ_ISLE
    on: ACK_ISLE                 'ACK_ISLE

    on: REQ_GET_VAL              'REQ_GET_VAL
    on: ACK_GET_VAL              'ACK_GET_VAL

    on: REQ_TEST_PACKET          'REQ_TEST_PACKET
    on: ACK_TEST_PACKET          'ACK_TEST_PACKET

    on: REQ_GET_USER_HASH        'REQ_GET_USER_HASH
    on: ACK_GET_USER_HASH        'ACK_GET_USER_HASH

    on: REQ_MAYBE_WRITE_STREAM_PACKET 'REQ_MAYBE_WRITE_STREAM_PACKET
    on: ACK_MAYBE_WRITE_STREAM_PACKET 'ACK_MAYBE_WRITE_STREAM_PACKET

    on: REQ_SET_USER_INFO	'REQ_SET_USER_INFO
    on: ACK_SET_USER_INFO	'ACK_SET_USER_INFO

    on: REQ_VALIDATE_NAME_CHANGE	'REQ_VALIDATE_NAME_CHANGE
    on: ACK_VALIDATE_NAME_CHANGE	'ACK_VALIDATE_NAME_CHANGE

    on: REQ_GET_KEY		'REQ_GET_KEY
    on: ACK_GET_KEY		'ACK_GET_KEY

    on: REQ_GET_NEXT_KEY	'REQ_GET_NEXT_KEY
    on: ACK_GET_NEXT_KEY	'ACK_GET_NEXT_KEY

    else: nil
    }
;

( =====================================================================	)
( - argname -- maybe map hashname to textname				)

:   argname { $ -> $ }
    -> arg

    arg fixnum? not if arg return fi

    .folkBy.hashName arg get? -> name if name return fi

    arg
;
'argname export


( =====================================================================	)
( - Server name								)

.muq.serverName not if   .sys.hostName --> .muq.serverName   fi



( =====================================================================	)
( - Globals (muqnetVars)						)

"muqnetVars" inPackage

0 --> _count
'_count export

'_isles export
'_isles bound? not if makeStack --> _isles fi

'_isleNames export
'_isleNames bound? not if makeStack --> _isleNames fi

500 --> _retryMilliseconds
'_retryMilliseconds export

15 --> _maxRetries
'_maxRetries export


( =====================================================================	)
( - Store for addresses of well-known/major Muq  servers		)

'_ip0  export
'_ip1  export
'_ip2  export
'_ip3  export
'_port export
'_lock export

"muqnet" inPackage

( =====================================================================	)
( - clearWellKnownServerRegister -- function to reset it		)

:   clearWellKnownServerRegister
    muqnetVars:_lock withLockDo{
	muqnetVars:_ip0		reset
	muqnetVars:_ip1		reset
	muqnetVars:_ip2		reset
	muqnetVars:_ip3		reset
	muqnetVars:_port	reset
    }
;
'clearWellKnownServerRegister export

( =====================================================================	)
( - registerWellKnownServer -- function to add another			)

:   registerWellKnownServer { [] -> [] }
    |shift -> ip0
    |shift -> ip1
    |shift -> ip2
    |shift -> ip3
    |shift -> port
    ]pop

    muqnetVars:_lock withLockDo{
	ip0  muqnetVars:_ip0	push
	ip1  muqnetVars:_ip1	push
	ip2  muqnetVars:_ip2	push
	ip3  muqnetVars:_ip3	push
	port muqnetVars:_port	push
    }

    [ |
;
'registerWellKnownServer export

( =====================================================================	)
( - actual list of default well-known servers				)

'muqnetVars:_ip0 bound? not if

    makeLock  --> muqnetVars:_lock

    makeStack --> muqnetVars:_ip0
    makeStack --> muqnetVars:_ip1
    makeStack --> muqnetVars:_ip2
    makeStack --> muqnetVars:_ip3

    makeStack --> muqnetVars:_port

    ( For now, just the main donna.muq.org servers: )
"190-C-muqnet: NOT INSTALLING WELL KNOWN SERVERS FOR NOW\n" d,
(    [ 128 83 194 21 30000 | registerWellKnownServer ]pop )
(    [ 128 83 194 21 32000 | registerWellKnownServer ]pop )
(    [ 128 83 194 21 34000 | registerWellKnownServer ]pop )
(    [ 128 83 194 21 36000 | registerWellKnownServer ]pop )
fi

( =====================================================================	)

( - Packet handler functions requiring special handling in muqnet:run	)

( =====================================================================	)
( - doReqGetMuqnetUserInfo -- Handle REQ_GET_MUQNET_USER_INFO from net.	)

:   doReqGetMuqnetUserInfo { [] $ $ $ $ $ $ $ $ $ -> }
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo/aaa\n" d, )
    -> io
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo io=" d, io d, "\n" d, )
    -> port
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo port=" d, port d, "\n" d, )
    -> ip3
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo ip3=" d, ip3 d, "\n" d, )
    -> ip2
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo ip2=" d, ip2 d, "\n" d, )
    -> ip1
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo ip1=" d, ip1 d, "\n" d, )
    -> ip0
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo ip0=" d, ip0 d, "\n" d, )
    -> to
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo to=" d, to d, "\n" d, )
    -> fromversion
    -> from
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo from=" d, from d, "\n" d, )

    |length 5 != if ]pop return fi

    |pop -> fromlong	fromlong bignum? not if ]pop return fi
    |pop -> seq		seq      fixnum? not if ]pop return fi
    |pop -> i2		i2       fixnum? not if ]pop return fi
    |pop -> i1		i1       fixnum? not if ]pop return fi
    |pop -> i0		i0       fixnum? not if ]pop return fi
    ]pop



    ( Gather muqnet user information: )

    .u["muqnet"] -> u

    u$s.hashName -> hashname
    u$s.longName -> longname
    u$s.nickName -> localNickname

    u$s.originalNickName -> nickname

    ( Avoid filling .folksBy.nickName with  )
    ( "muqnet2" "muqnet3" ... by making the )
    ( nickname more meaningful:             )
    localNickname "muqnet" = if
	.muq.serverName if
            .muq.serverName "Muqnet" join -> nickname
	else
            .sys.hostName "Muqnet" join -> nickname
	fi
    fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo nickname=" d, nickname d, "\n" d, )

    u$s.lastLongName -> lastlongname
    u$s.lastHashName -> lasthashname
     
    u$s.dateOfLastNameChange -> lastnamechange
    u$s.userVersion          -> userversion
     
    u$s.userServer0 -> userserver0
    u$s.userServer1 -> userserver1
    u$s.userServer2 -> userserver2
    u$s.userServer3 -> userserver3
    u$s.userServer4 -> userserver4
     
    u$s.ip0  -> uip0
    u$s.ip1  -> uip1
    u$s.ip2  -> uip2
    u$s.ip3  -> uip3
    u$s.port -> uport

    u$s.doing        -> doing
    u$s.doNotDisturb ->	donotdisturb
    u$s.email	     ->	email
    u$s.homepage     -> homepage
    u$s.pgpKeyprint  ->	pgpkeyprint



    ( --------------------------------------- )
    ( REQ_GET_MUQNET_USER_INFO is an odd-ball )
    ( requests which can't be handled by      )
    ( our vanilla packet authentication logic )
    ( without risking an infinite regression: )
    ( We have to sign the packet ourself here )
    ( rather than  using the usual muqnet:run )
    ( logic:                                  )
    ( --------------------------------------- )

    ( Find/compute shared secret.  Doing this )
    ( inline avoids creating a function that  )
    ( might be too easy to call, and hence a  )
    ( very minor security weakening:          )
    rootOmnipotentlyDo{
	u$s.sharedSecrets from get? -> ss not if
	    fromlong     -> k0
            u$s.trueName -> k1
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo making shared secret...\n" d, )
	    k0 k1 dh:p generateDiffieHellmanSharedSecret -> ss
	fi
    }
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo ss=" d, ss d, "\n" d, )

    ( Fire back the return packet: )
    [   :ip0  ip0
	:ip1  ip1
	:ip2  ip2
	:ip3  ip3
	:port port
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo/mmm\n" d, )
        |   [
            longname
	    hashname		( from		)
	    userversion		( fromVersion	)
	    from		( to		)
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo/nnn\n" d, )
	    trulyRandomFixnum	( randompad	)
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo/ooo\n" d, )
	    ACK_GET_MUQNET_USER_INFO
	    i0 i1 i2
	    seq

	    hashname
	    longname
	    nickname

	    lastlongname
	    lasthashname

	    lastnamechange
	    userversion

	    userserver0
	    userserver1
	    userserver2
	    userserver3
	    userserver4

	    uip0
	    uip1
	    uip2
	    uip3
	    uport

	    doing
	    donotdisturb
	    email
	    homepage
	    pgpkeyprint

            |
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo/ppp\n" d, )
	    |enbyte
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo/qqq\n" d, )
            ss |signedDigest
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo/rrr\n" d, )
	]|join
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo/sss\n" d, )
	"txt" t io |maybeWriteStreamPacket pop pop
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo/ttt\n" d, )
    ]pop
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetMuqnetUserInfo/zzz\n" d, )
;

( =====================================================================	)
( - doAckGetMuqnetUserInfo -- Handle ACK_GET_MUQNET_USER_INFO from net	)

:   doAckGetMuqnetUserInfo { [] $ $ $ $ $ $ $ $ $ -> }
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetMuqnetUserInfo/aaa\n" d, )
    -> io
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetMuqnetUserInfo io = " d, io d, "\n" d, )
    -> port
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetMuqnetUserInfo port = " d, port d, "\n" d, )
    -> ip3
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetMuqnetUserInfo ip3 = " d, ip3 d, "\n" d, )
    -> ip2
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetMuqnetUserInfo ip2 = " d, ip2 d, "\n" d, )
    -> ip1
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetMuqnetUserInfo ip1 = " d, ip1 d, "\n" d, )
    -> ip0
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetMuqnetUserInfo ip0 = " d, ip0 d, "\n" d, )
    -> to
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetMuqnetUserInfo to = " d, to d, "\n" d, )
    -> fromversion
    -> from
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetMuqnetUserInfo from = " d, from d, "\n" d, )

    |length 26 != if ]pop return fi

    |pop -> pgpkeyprint
    |pop -> homepage
    |pop -> email
    |pop -> donotdisturb
    |pop -> doing

    |pop -> uport
    |pop -> uip3
    |pop -> uip2
    |pop -> uip1
    |pop -> uip0

    |pop -> userserver4
    |pop -> userserver3
    |pop -> userserver2
    |pop -> userserver1
    |pop -> userserver0

    |pop -> userversion
    |pop -> lastnamechange

    |pop -> lasthashname
    |pop -> lastlongname

    |pop -> nickname
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetMuqnetUserInfo nickname = " d, nickname d, "\n" d, )
    |pop -> longname
    |pop -> hashname
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetMuqnetUserInfo hashname = " d, hashname d, "\n" d, )

    |pop -> seq		seq integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetMuqnetUserInfo seq = " d, seq d, "\n" d, )
    |pop -> i2		i2  integer? not if ]pop return fi
    |pop -> i1		i1  integer? not if ]pop return fi
    |pop -> i0		i0  integer? not if ]pop return fi
    ]pop
( BUGGO! Shouldn't we be checking that from == hashname, to validate the packet? )
( and maybe that hashname is indeed the hash of longname?  Although rootNoteGuest )
( is supposed to handle that for us... )

    longname hash hashname != if return fi

    ( Enter user into db: )

    ( BUGGO!  We're wide open for various sorts of abuse )
    ( here, including flood attacks spamming the db with )
    ( garbage until the disk fills up:                   )

    ( BUGGO!  At present, we've no validation, so we can )
    ( trivially be spoofed into clobbering good guest    )
    ( records:					     )

    ( Get/create guest record: )
    nickname longname hashname rootNoteGuest -> u	

    ( Ignore attempts to update native records via net.  )
    ( For now, these are probably malicious.  Later, we  )
    ( may want to allow this:                            )
    u guest? not if return fi
    rootOmnipotentlyDo{

	[ "muqnet/doAckGetMuqnetUserInfo: Updating muqnet hashname %d\n" hashname | ]logPrint

	lasthashname   --> u$s.lastHashName
	lastlongname   --> u$s.lastLongName

	lastnamechange --> u$s.dateOfLastNameChange

	userserver0    --> u$s.userServer0
	userserver1    --> u$s.userServer1
	userserver2    --> u$s.userServer2
	userserver3    --> u$s.userServer3
	userserver4    --> u$s.userServer4

	uip0           --> u$s.ip0
	uip1           --> u$s.ip1
	uip2           --> u$s.ip2
	uip3           --> u$s.ip3
	uport          --> u$s.port

	userversion    --> u$s.userVersion
    }

    ( Reconstruct destination stream from i0/i1/i2: )

    i0 i1 i2 ints3ToDbref -> tio not if return fi
    tio remote? if return fi
    tio messageStream? not if return fi

    ( Write reply packet to given stream: )
    u rootAsUserDo{		( Set 'user -> who' on mss packet.	)
	[   seq	( MUST BE FIRST, to ensure delivery via task mechanism. )

	    :hashName hashname
	    :longName longname
	    :nickName nickname

	    :lastLongName lastlongname
	    :lastHashName lasthashname

	    :lastNameChange lastnamechange
	    :userVersion    userversion

	    :userServer0    userserver0
	    :userServer1    userserver1
	    :userServer2    userserver2
	    :userServer3    userserver3
	    :userServer4    userserver4

	    :userIp0    uip0
	    :userIp1    uip1
	    :userIp2    uip2
	    :userIp3    uip3
	    :userPort   uport

	    :doing	    	doing
	    :doNotDisturb	donotdisturb
	    :email		email
	    :homepage		homepage
	    :pgpKeyprint	pgpkeyprint

	    |
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetMuqnetUserInfo writing to stream = " d, tio d, "\n" d, )
	    "ack" t tio |maybeWriteStreamPacket	pop pop
	]pop
    }
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetMuqnetUserInfo/zzz\n" d, )
;

( =====================================================================	)
( - sendGetMuqnetUserInfo -- User-callable fn to get server's muqnet user	)

:   sendGetMuqnetUserInfo { [] -> [] }
( .sys.muqPort d, "(190)<" d, @ d, ">sendGetMuqnetUserInfo/aaa\n" d, )
    |shift -> replyStream	replyStream isAMessageStream
( .sys.muqPort d, "(190)<" d, @ d, ">sendGetMuqnetUserInfo replyStream = " d, replyStream d, "\n" d, )
    |shift -> ip0
( .sys.muqPort d, "(190)<" d, @ d, ">sendGetMuqnetUserInfo ip0 = " d, ip0 d, "\n" d, )
    |shift -> ip1
( .sys.muqPort d, "(190)<" d, @ d, ">sendGetMuqnetUserInfo ip1 = " d, ip1 d, "\n" d, )
    |shift -> ip2
( .sys.muqPort d, "(190)<" d, @ d, ">sendGetMuqnetUserInfo ip2 = " d, ip2 d, "\n" d, )
    |shift -> ip3
( .sys.muqPort d, "(190)<" d, @ d, ">sendGetMuqnetUserInfo ip3 = " d, ip3 d, "\n" d, )
    |shift -> port
( .sys.muqPort d, "(190)<" d, @ d, ">sendGetMuqnetUserInfo port = " d, port d, "\n" d, )
    |shift -> seq		seq isAnInteger
( .sys.muqPort d, "(190)<" d, @ d, ">sendGetMuqnetUserInfo seq = " d, seq d, "\n" d, )
    ]pop

    .muq.muqnetIo -> mio

    @.actingUser$s.longName    -> longname
    @.actingUser$s.hashName    -> hashname
    @.actingUser$s.userVersion -> userversion

    mio messageStream? if
	[   :ip0  ip0
	    :ip1  ip1
	    :ip2  ip2
	    :ip3  ip3
	    :port port
	    |   [
		    hashname		 ( from		)
		    userversion		 ( fromVersion	)
		    0	     		 ( to -- dummy	)
		    trulyRandomFixnum    ( randompad	)
		    REQ_GET_MUQNET_USER_INFO
		    replyStream dbrefToInts3
		    seq
		    longname
		|
		|enbyte
	    ]|join
	    "txt" t mio |writeStreamPacket pop pop
	]pop
    fi

    [ |
( .sys.muqPort d, "(190)<" d, @ d, ">sendGetMuqnetUserInfo/zzz\n" d, )
;
'sendGetMuqnetUserInfo export

( =====================================================================	)
( - doReqGetUserInfo -- Handle REQ_GET_USER_INFO packet from net.	)

:   doReqGetUserInfo { [] $ $ $ $ $ $ $ $ $ -> }
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetUserInfo/aaa\n" d, )
    -> io
    -> port
    -> ip3
    -> ip2
    -> ip1
    -> ip0
    -> to
    -> fromversion
    -> from

    ( ============================================================= )
    ( doReqGetUserInfo is unique in that the request may have       )
    ( been forwarded to us.  This means that we can NOT in general  )
    ( presume that the reply should go to the address from which    )
    ( we received the request -- ip[0-3],port above, which comes    )
    ( ultimately from the UDP packet header.  Instead, we reply to  )
    ( the return address provided in the packet body, extracted	    )
    ( below as rip[0-3],rport.					    )
    ( ============================================================= )

    |length 10 != if ]pop return fi
    |pop -> rport       rport    fixnum? not if ]pop return fi
    |pop -> rip3        rip3     fixnum? not if ]pop return fi
    |pop -> rip2        rip2     fixnum? not if ]pop return fi
    |pop -> rip1        rip1     fixnum? not if ]pop return fi
    |pop -> rip0        rip0     fixnum? not if ]pop return fi

    |pop -> fromlong 	fromlong bignum? not if ]pop return fi
    |pop -> seq		seq      fixnum? not if ]pop return fi
    |pop -> i2		i2       fixnum? not if ]pop return fi
    |pop -> i1		i1       fixnum? not if ]pop return fi
    |pop -> i0		i0       fixnum? not if ]pop return fi
    ]pop

    ( Gather user information: )
    .folkBy.hashName to get? -> user not if
	( Drop the packet.   We couldn't )
	( authenticate the reply anyhow. ) 
	return
    fi

    user guest? if
	( User is a Guest, so 				    )
	( forward the request to the user's home server instead )
	( of replying ourselves.  Among other things, this lets )
	( the reply be properly signed by the actual user, and  )
	( allows the home server to ignore some requests if it  )
	( so chooses.					    )
      ( buggo?  If user has changed to another IP address, )
      ( how will that get detected here?  Do we need to    )
      ( forward to one of the user's userservers instead   )
      ( with, say, 1/4 probability?                        )
	user$s.ip0  -> ip0
	user$s.ip1  -> ip1
	user$s.ip2  -> ip2
	user$s.ip3  -> ip3
	user$s.port -> port
	[   :ip0  ip0
	    :ip1  ip1
	    :ip2  ip2
	    :ip3  ip3
	    :port port
	    |   [
		    from        	( from		)
		    fromversion        	( fromVersion	)
		    to			( to		)
		    trulyRandomFixnum	( randompad	)
		    REQ_GET_USER_INFO
		    i0 i1 i2
		    seq
		    fromlong
		    rip0
		    rip1
		    rip2
		    rip3
		    rport
		|
		|enbyte
	    ]|join
	    "txt" t io |maybeWriteStreamPacket pop pop
	]pop
	return
    fi

    user$s.hashName -> hashname
    user$s.longName -> longname
    user$s.nickName -> localNickname

    user$s.originalNickName -> nickname

    ( Avoid filling .folksBy.nickName with  )
    ( "muqnet2" "muqnet3" ... by making the )
    ( nickname more meaningful:             )
    localNickname "muqnet" = if
	.muq.serverName if
	    .muq.serverName "Muqnet" join -> nickname
	else
	    .sys.hostName "Muqnet" join -> nickname
	fi
    fi
    localNickname "root" = if
	.muq.serverName if
	    .muq.serverName "Root" join -> nickname
	else
	    .sys.hostName "Root" join -> nickname
	fi
    fi



    user$s.lastLongName -> lastlongname
    user$s.lastHashName -> lasthashname

    user$s.dateOfLastNameChange -> lastnamechange
    user$s.userVersion          -> userversion

    user$s.userServer0 -> userserver0
    user$s.userServer1 -> userserver1
    user$s.userServer2 -> userserver2
    user$s.userServer3 -> userserver3
    user$s.userServer4 -> userserver4

    user$s.ip0  -> uip0
    user$s.ip1  -> uip1
    user$s.ip2  -> uip2
    user$s.ip3  -> uip3
    user$s.port -> uport

    user$s.doing        -> doing
    user$s.doNotDisturb -> donotdisturb
    user$s.email        -> email
    user$s.homepage     -> homepage
    user$s.pgpKeyprint  -> pgpkeyprint

    ( --------------------------------------- )
    ( REQ_GET_USER_INFO is  one of those odd- )
    ( ball requests which can't be handled by )
    ( our vanilla packet authentication logic )
    ( without risking an infinite regression: )
    ( We have to sign the packet ourself here )
    ( rather than  using the usual muqnet:run )
    ( logic:                                  )
    ( --------------------------------------- )

    ( Find/compute shared secret.  Doing this )
    ( inline avoids creating a function that  )
    ( might be too easy to call, and hence a  )
    ( very minor security weakening:          )
    rootOmnipotentlyDo{
	user$s.sharedSecrets from get? -> ss not if
	    fromlong        -> k0
            user$s.trueName -> k1
	    k0 k1 dh:p generateDiffieHellmanSharedSecret -> ss
	fi
    }


    ( Fire back the return packet: )
    [   :ip0  rip0	( Note that since request may have been )
	:ip1  rip1	( forwarded via a 3rd party, we cannot  )
	:ip2  rip2	( use the ip0.ip1.ip2.ip3.port return	)
	:ip3  rip3	( address as we normally do -- instead	)
	:port rport	( we use return address from message.	)
        |   [
            longname
	    to	    		( from	    )
	    userversion		( fromVersion )
	    from    		( to	    )
	    trulyRandomFixnum	( randompad )
	    ACK_GET_USER_INFO
	    i0 i1 i2
	    seq

	    hashname
	    longname
	    nickname

	    lastlongname
	    lasthashname

	    lastnamechange
	    userversion

	    userserver0
	    userserver1
	    userserver2
	    userserver3
	    userserver4

	    uip0
	    uip1
	    uip2
	    uip3
	    uport

	    doing
	    donotdisturb
	    email
	    homepage
	    pgpkeyprint

            |
	    |enbyte
            ss |signedDigest
	]|join
	"txt" t io |maybeWriteStreamPacket	pop pop
    ]pop
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetUserInfo/zzz\n" d, )
;

( =====================================================================	)
( - doAckGetUserInfo -- Handle ACK_GET_USER_INFO packet from net	)

:   doAckGetUserInfo { [] $ $ $ $ $ $ $ $ $ -> }
    -> io
    -> port
    -> ip3
    -> ip2
    -> ip1
    -> ip0
    -> to
    -> fromversion
    -> from

    |length 26 != if ]pop return fi

    |pop -> pgpkeyprint
    |pop -> homepage
    |pop -> email
    |pop -> donotdisturb
    |pop -> doing

    |pop -> uport
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo uport = " d, uport d, "\n" d, )
    |pop -> uip3
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo uip3 = " d, uip3 d, "\n" d, )
    |pop -> uip2
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo uip2 = " d, uip2 d, "\n" d, )
    |pop -> uip1
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo uip1 = " d, uip1 d, "\n" d, )
    |pop -> uip0
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo uip0 = " d, uip0 d, "\n" d, )

    |pop -> userserver4
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo userserver4 = " d, userserver4 d, "\n" d, )
    |pop -> userserver3
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo userserver3 = " d, userserver3 d, "\n" d, )
    |pop -> userserver2
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo userserver2 = " d, userserver2 d, "\n" d, )
    |pop -> userserver1
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo userserver1 = " d, userserver1 d, "\n" d, )
    |pop -> userserver0
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo userserver0 = " d, userserver0 d, "\n" d, )

    |pop -> userversion
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo usersversion = " d, userversion d, "\n" d, )
    |pop -> lastnamechange
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo lastnamechange = " d, lastnamechange d, "\n" d, )

    |pop -> lasthashname
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo lasthashname = " d, lasthashname d, "\n" d, )
    |pop -> lastlongname
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo lastlongname = " d, lastlongname d, "\n" d, )

    |pop -> nickname
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo nickname = " d, nickname d, "\n" d, )
    |pop -> longname
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo longname = " d, longname d, "\n" d, )
    |pop -> hashname
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo hashname = " d, hashname d, "\n" d, )

    |pop -> seq		seq integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo seq = " d, seq d, "\n" d, )
    |pop -> i2		i2  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo i2 = " d, i2 d, "\n" d, )
    |pop -> i1		i1  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo i1 = " d, i1 d, "\n" d, )
    |pop -> i0		i0  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo i0 = " d, i0 d, "\n" d, )
    ]pop

    longname hash hashname = if
	( Enter user into db: )
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo longname DOES hash to hashname...\n" d, )

	( BUGGO!  We're wide open for various sorts of abuse )
	( here, including flood attacks spamming the db with )
	( garbage until the disk fills up:                   )

	( BUGGO!  At present, we've no validation, so we can )
	( trivially be spoofed into clobbering good user     )
	( records:						 )

	( Get/create guest record: )
	nickname longname hashname rootNoteGuest -> u	
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo u = " d, u d, "\n" d, )

	( Ignore attempts to update native records via net.  )
	( For now, these are probably malicious.  Later, we  )
	( may want to allow this:                            )
	u guest? if
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo u IS a guest...\n" d, )
	    rootOmnipotentlyDo{

		( Sanity check: don't downgrade versions: )
		userversion u$s.userVersion < if return fi

		[   "muqnet/doAckGetUserInfo: Updating guest %s %s from v %d to %d\n"
		   nickname
		   hashname
		   u$s.userVersion
		   userversion
		| ]logPrint

		lasthashname   --> u$s.lastHashName
		lastlongname   --> u$s.lastLongName

		lastnamechange --> u$s.dateOfLastNameChange

		userserver0    --> u$s.userServer0
		userserver1    --> u$s.userServer1
		userserver2    --> u$s.userServer2
		userserver3    --> u$s.userServer3
		userserver4    --> u$s.userServer4

		uip0           --> u$s.ip0
		uip1           --> u$s.ip1
		uip2           --> u$s.ip2
		uip3           --> u$s.ip3
		uport          --> u$s.port

		doing	       --> u$s.doing
		donotdisturb   --> u$s.doNotDisturb
		email          --> u$s.email
		homepage       --> u$s.homepage
		pgpkeyprint    --> u$s.pgpKeyprint

		( Update user version last because    )
		( above assignments implicitly update )
		( it:                                 )
		userversion    --> u$s.userVersion
	    }
	fi
    fi


    ( Reconstruct destination stream from i0/i1/i2: )

    i0 i1 i2 ints3ToDbref -> tio not if
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo NO tio, aborting.\n" d, )
        return
    fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo tio = " d, tio d, "\n" d, )
    tio remote? if return fi
    tio messageStream? not if return fi

    ( Write reply packet to given stream: )
( buggo, should probably have SEQ first here to allow use via task mechanism: )
    [	:op   ACK_GET_USER_INFO
  	:ip0  ip0
  	:ip1  ip1
  	:ip2  ip2
  	:ip3  ip3
  	:port port
        :seq  seq

  	:hashName hashname
  	:longName longname
  	:nickName nickname

  	:lastLongName lastlongname
  	:lastHashName lasthashname

  	:lastNameChange lastnamechange
  	:userVersion    userversion

  	:userServer0    userserver0
  	:userServer1    userserver1
  	:userServer2    userserver2
  	:userServer3    userserver3
  	:userServer4    userserver4

  	:userIp0    uip0
  	:userIp1    uip1
  	:userIp2    uip2
  	:userIp3    uip3
  	:userPort   uport

	:doing	    	doing
	:doNotDisturb	donotdisturb
	:email		email
	:homepage	homepage
	:pgpKeyprint	pgpkeyprint

        |
  	"txt" t tio |maybeWriteStreamPacket	pop pop
    ]pop
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetUserInfo/zzz\n" d, )
;

( =====================================================================	)
( - sendGetUserInfo -- User-callable fn to get server's info on a user	)

:   sendGetUserInfo { $ $ $ $ -> }
( .sys.muqPort d, "(190)<" d, @ d, ">sendGetUserInfo/aaa\n" d, )
    -> server           			( Muqserver to query.	)
    -> hash		hash isAnInteger
    -> seq		seq  isAnInteger
    -> replyStream	replyStream isAMessageStream

    server$s.ip0  -> ip0
    server$s.ip1  -> ip1
    server$s.ip2  -> ip2
    server$s.ip3  -> ip3
    server$s.port -> port

    .muq.muqnetIo -> mio

    @.actingUser$s.longName    -> longname
    @.actingUser$s.hashName    -> hashname
    @.actingUser$s.userVersion -> userversion

    mio messageStream? if
	[   :ip0  ip0
	    :ip1  ip1
	    :ip2  ip2
	    :ip3  ip3
	    :port port
	    |   [
		    hashname		( from 		)
		    userversion		( fromVersion	)
		    hash		( to		)
		    trulyRandomFixnum	( randompad	)
		    REQ_GET_USER_INFO
		    replyStream dbrefToInts3
		    seq
		    longname
		    .sys.ip0
		    .sys.ip1
		    .sys.ip2
		    .sys.ip3
		    .sys.muqPort
		|
		|enbyte
	    ]|join
	    "txt" t mio |writeStreamPacket pop pop
	]pop
    fi
( .sys.muqPort d, "(190)<" d, @ d, ">sendGetUserInfo/zzz\n" d, )
;
'sendGetUserInfo export

( =====================================================================	)

( - Packet handler functions requiring vanilla handling in muqnet:run	)

( =====================================================================	)

( - Packet handler functions which are tested by x[xy]-muqnet2:		)

( =====================================================================	)
( - doReqTestPacket -- Handle REQ_TEST_PACKET packet from net.		)

:   doReqTestPacket { [] $ $ $ $ $ $ $ $ $ -> }
    -> io
    -> port
    -> ip3
    -> ip2
    -> ip1
    -> ip0
    -> to
    -> fromversion
    -> from

    |length 4 != if ]pop return fi

    |pop -> seq		seq integer? not if ]pop return fi
    |pop -> i2		i2  integer? not if ]pop return fi
    |pop -> i1		i1  integer? not if ]pop return fi
    |pop -> i0		i0  integer? not if ]pop return fi
    ]pop

    ( Main point of this function is to allow self-test suite )
    ( code to easily generate a packet containing a proxy for )
    ( an unknown hashName:  We do this by returning the .     )
    ( for the system, which is owned by root, which in the    )
    ( test suite at least will be an unknown foriegn user.    )
    (   This allows the test suite to test automatic querying )
    ( of a remote server for information on an unfamiliar     )
    ( hashName.                                               )

    ( Locate caller and callee: )
    .folkBy.hashName from get? -> guest not if return fi    guest guest? not if return fi
    .folkBy.hashName to   get? -> user  not if return fi    user  folk?  not if return fi

    ( Fire back the return packet: )
    user rootAsUserDo{		( Set 'user -> who' on mss packet.	)
	[   :to   guest
	    :ip0  ip0
	    :ip1  ip1
	    :ip2  ip2
	    :ip3  ip3
	    :port port
	    |   [
		ACK_TEST_PACKET
		i0 i1 i2
		seq

		.
		|
		|enbyte
	    ]|join
	    "txt" t io |maybeWriteStreamPacket	pop pop
	]pop
    }
;

( =====================================================================	)
( - doAckTestPacket -- Handle ACK_TEST_PACKET packet from net		)

:   doAckTestPacket { [] $ $ $ $ $ $ $ $ $ -> }
    -> io
    -> port
    -> ip3
    -> ip2
    -> ip1
    -> ip0
    -> to
    -> fromversion
    -> from

    |length 5 != if ]pop return fi

    |pop -> obj

    |pop -> seq		seq integer? not if ]pop return fi
    |pop -> i2		i2  integer? not if ]pop return fi
    |pop -> i1		i1  integer? not if ]pop return fi
    |pop -> i0		i0  integer? not if ]pop return fi
    ]pop


    ( Reconstruct destination stream from i0/i1/i2: )

    i0 i1 i2 ints3ToDbref -> tio not if return fi
    tio remote? if return fi
    tio messageStream? not if return fi

    ( Write reply packet to given stream: )
    [	:op   ACK_TEST_PACKET
  	:ip0  ip0
 	:ip1  ip1
 	:ip2  ip2
 	:ip3  ip3
 	:port port
 	:seq  seq

 	:object   obj
    |
 	"txt" t tio |maybeWriteStreamPacket	pop pop
    ]pop
;

( =====================================================================	)
( - sendTestPacket -- User-callable fn asking for test packet		)

:   sendTestPacket { $ $ $ -> }
    -> seq		seq isAnInteger
    -> server
    -> replyStream	replyStream isAMessageStream

    .muq.muqnetIo -> mio

    mio messageStream? if
	[   :to   server
	    |   [
		    REQ_TEST_PACKET
		    replyStream dbrefToInts3
		    seq
		|
		|enbyte
	    ]|join
	    "txt" t mio |writeStreamPacket pop pop
	]pop
    fi
;
'sendTestPacket export

( =====================================================================	)
( - doReqGetUserHash -- Handle REQ_GET_USER_HASH packet from net.	)

:   doReqGetUserHash { [] $ $ $ $ $ $ $ $ $ -> }
    -> io
    -> port
    -> ip3
    -> ip2
    -> ip1
    -> ip0
    -> to
    -> fromversion
    -> from

    |length 5 != if ]pop return fi

    |pop -> nick	nick string?  not if ]pop return fi
    |pop -> seq		seq  integer? not if ]pop return fi
    |pop -> i2		i2   integer? not if ]pop return fi
    |pop -> i1		i1   integer? not if ]pop return fi
    |pop -> i0		i0   integer? not if ]pop return fi
    ]pop



    ( Gather user information: )
    .folkBy.nickName nick get? -> user not if return fi
    user folk? not if return fi

    user$s.hashName -> hashname

    ( Locate caller's object: )
    .folkBy.hashName from get? -> guest not if return fi
    guest guest? not if return fi

    user rootAsUserDo{		( Set 'user -> who' on mss packet.	)
	( Fire back the return packet: )
	[   :to   guest
	    :ip0  ip0
	    :ip1  ip1
	    :ip2  ip2
	    :ip3  ip3
	    :port port
	    |   [
		ACK_GET_USER_HASH
		i0 i1 i2
		seq
		|
		|enbyte
	    ]|join
	    "txt" t io |maybeWriteStreamPacket	pop pop
	]pop
    }
;

( =====================================================================	)
( - doAckGetUserHash -- Handle ACK_GET_USER_HASH packet from net	)

:   doAckGetUserHash { [] $ $ $ $ $ $ $ $ $ -> }
    -> io
    -> port
    -> ip3
    -> ip2
    -> ip1
    -> ip0
    -> to
    -> fromversion
    -> from

    |length 4 != if ]pop return fi

    |pop -> seq		seq integer? not if ]pop return fi
    |pop -> i2		i2  integer? not if ]pop return fi
    |pop -> i1		i1  integer? not if ]pop return fi
    |pop -> i0		i0  integer? not if ]pop return fi
    ]pop


    ( Reconstruct destination stream from i0/i1/i2: )

    i0 i1 i2 ints3ToDbref -> tio not if return fi
    tio remote? if return fi
    tio messageStream? not if return fi

    ( Write reply packet to given stream: )
    [	:op   ACK_GET_USER_HASH
  	:ip0  ip0
  	:ip1  ip1
  	:ip2  ip2
  	:ip3  ip3
  	:port port
        :seq  seq

  	:hashName from
        |
  	"txt" t tio |maybeWriteStreamPacket	pop pop
    ]pop
;

( =====================================================================	)
( - sendGetUserHash -- User-callable fn to map nickName to hashName	)

( This operation is included mostly for the benefit of the		)
( self-test code, although it might have some other use.		)
(									)
( Note that lookup is done on the server-local hashName,		)
( not on the originalHashName (which might be ambiguous):		)
( This probably restricts the general usefulness of this op.		)

:   sendGetUserHash { $ $ $ $ -> }
    -> server           			( Muqserver to update.	)
    -> nick		nick        isAString	( User name to send.	)
    -> seq		seq         isAnInteger
    -> replyStream	replyStream isAMessageStream

    server$s.ip0  -> ip0
    server$s.ip1  -> ip1
    server$s.ip2  -> ip2
    server$s.ip3  -> ip3
    server$s.port -> port

    .muq.muqnetIo -> mio

    mio messageStream? if
	[   :to server
	    |   [
		    REQ_GET_USER_HASH
		    replyStream dbrefToInts3
		    seq
		    nick
		|
		|enbyte
	    ]|join
	    "txt" t mio |writeStreamPacket pop pop
	]pop
    fi
;
'sendGetUserHash export

( =====================================================================	)
( - doReqSetUserInfo -- Handle REQ_SET_USER_INFO packet from net.	)

:   doReqSetUserInfo { [] $ $ $ $ $ $ $ $ $ -> }
    -> io
    -> port
    -> ip3
    -> ip2
    -> ip1
    -> ip0
    -> to
    -> fromversion
    -> from

    nil -> fail

    |length 26 != if
        ]pop
(       "bad packet len" -> fail )
	return
    else

	|pop -> pgpkeyprint
	|pop -> homepage
	|pop -> email
	|pop -> donotdisturb
	|pop -> doing

	|pop -> uport
	|pop -> uip3
	|pop -> uip2
	|pop -> uip1
	|pop -> uip0

	|pop -> userserver4
	|pop -> userserver3
	|pop -> userserver2
	|pop -> userserver1
	|pop -> userserver0

	|pop -> userversion
	|pop -> lastnamechange

	|pop -> lasthashname
	|pop -> lastlongname

	|pop -> nickname    nickname string?  not if ]pop return fi
	|pop -> longname    longname bignum?  not if ]pop return fi
	|pop -> hashname    hashname integer? not if ]pop return fi

	|pop -> seq		seq  integer? not if ]pop return fi
	|pop -> i2		i2   integer? not if ]pop return fi
	|pop -> i1		i1   integer? not if ]pop return fi
	|pop -> i0		i0   integer? not if ]pop return fi
        ]pop

        longname hash hashname = if
	    ( Enter user into db: )

	    ( BUGGO!  We're wide open for various sorts of abuse )
	    ( here, including flood attacks spamming the db with )
	    ( garbage until the disk fills up:                   )

	    ( BUGGO!  At present, we've no validation, so we can )
	    ( trivially be spoofed into clobbering good user     )
	    ( records:						 )

	    ( Get/create guest record: )
	    nickname longname hashname rootNoteGuest -> u	

	    ( Ignore attempts to update native records via net.  )
	    ( For now, these are probably malicious.  Later, we  )
	    ( may want to allow this:                            )
	    u guest? if
		rootOmnipotentlyDo{

		    [   "doReqSetUserInfo: Updating %s from userVersion %d to %d\n"
		        nickname
		        userversion
		        u$s.userVersion
		    |  ]logPrint

		    lasthashname   --> u$s.lastHashName
		    lastlongname   --> u$s.lastLongName

		    lastnamechange --> u$s.dateOfLastNameChange

		    userserver0    --> u$s.userServer0
		    userserver1    --> u$s.userServer1
		    userserver2    --> u$s.userServer2
		    userserver3    --> u$s.userServer3
		    userserver4    --> u$s.userServer4

		    uip0           --> u$s.ip0
		    uip1           --> u$s.ip1
		    uip2           --> u$s.ip2
		    uip3           --> u$s.ip3
		    uport          --> u$s.port

		    pgpkeyprint    --> u$s.pgpKeyprint
		    homepage       --> u$s.homepage
		    email          --> u$s.email
		    donotdisturb   --> u$s.doNotDisturb
		    doing          --> u$s.doing

		    ( Update user version last because    )
		    ( above assignments implicitly update )
		    ( it:                                 )
		    userversion    --> u$s.userVersion
		}
	    fi
	fi
    fi

    ( Fire back the return packet: )
    [   :to   u
        |   [
	    ACK_SET_USER_INFO
	    i0 i1 i2
	    seq
	    fail
            |
	    |enbyte
	]|join
	"txt" t io |maybeWriteStreamPacket	pop pop
    ]pop
;

( =====================================================================	)
( - doAckSetUserInfo -- Handle ACK_SET_USER_INFO packet from net	)

:   doAckSetUserInfo { [] $ $ $ $ $ $ $ $ $ -> }
    -> io
    -> port
    -> ip3
    -> ip2
    -> ip1
    -> ip0
    -> to
    -> fromversion
    -> from

    |length 5 != if ]pop return fi

    |pop -> ack

    |pop -> seq		seq integer? not if ]pop return fi
    |pop -> i2		i2  integer? not if ]pop return fi
    |pop -> i1		i1  integer? not if ]pop return fi
    |pop -> i0		i0  integer? not if ]pop return fi
    ]pop

    ( Reconstruct destination stream from i0/i1/i2: )

    i0 i1 i2 ints3ToDbref -> tio not if return fi
    tio remote? if return fi
    tio messageStream? not if return fi

    ( Write reply packet to given stream: )
    [	:op   ACK_SET_USER_INFO
  	:ip0  ip0
  	:ip1  ip1
  	:ip2  ip2
  	:ip3  ip3
  	:port port
  	:seq  seq

  	:ack  ack
        |
  	"txt" t tio |maybeWriteStreamPacket	pop pop
    ]pop
;

( =====================================================================	)
( - sendSetUserInfo -- User-callable fn to set server's info on user	)

:   sendSetUserInfo { $ $ $ -> }
    -> server           			( Muqserver to update.	)
    -> seq		seq         isAnInteger
    -> replyStream	replyStream isAMessageStream

    asMeDo{
        rootOmnipotentlyDo{
	    server$s.ip0  -> ip0
	    server$s.ip1  -> ip1
	    server$s.ip2  -> ip2
	    server$s.ip3  -> ip3
	    server$s.port -> port

	    server$s.hashName -> serverhash
	    server$s.longName -> serverlong

	    @.actingUser  -> user

	    user$s.hashName -> hashname
	    user$s.longName -> longname
	    user$s.nickName -> nickname
	    user$s.trueName -> truename

	    user$s.lastLongName -> lastlongname
	    user$s.lastHashName -> lasthashname

	    user$s.dateOfLastNameChange -> lastnamechange
	    user$s.userVersion          -> userversion

	    user$s.userServer0  -> userserver0
	    user$s.userServer1  -> userserver1
	    user$s.userServer2  -> userserver2
	    user$s.userServer3  -> userserver3
	    user$s.userServer4  -> userserver4

	    user$s.ip0          -> uip0   
	    user$s.ip1          -> uip1   
	    user$s.ip2          -> uip2   
	    user$s.ip3          -> uip3   
	    user$s.port         -> uport  

	    user$s.email        -> email
	    user$s.homepage     -> homepage
	    user$s.pgpKeyprint  -> pgpkeyprint
	    user$s.doNotDisturb -> donotdisturb
	    user$s.doing        -> doing

	    .muq$s.muqnetIo -> mio

	    ( ----------------------------------------- )
	    ( sendSetUserInfo is a special case because )
	    ( we do not wish to assume that the server  )
	    ( has heard of us before, hence we need to  )
	    ( include our longname in the header, which )
	    ( the standard muqnet:run logic will not do )
	    ( for us.  Hence, we construct a raw packet )
	    ( ourselves here.                           )
	    ( ----------------------------------------- )

	    ( Find/compute shared secret.  Doing this )
	    ( inline avoids creating a function that  )
	    ( might be too easy to call, and hence a  )
	    ( very minor security weakening:          )
	    server$s.sharedSecrets hashname get? -> ss not if
		( Should be symmetric, but check anyhow: )
		user$s.sharedSecrets serverhash get? -> ss if
		    ss --> server$s.sharedSecrets[hashname]
		else
		    serverlong -> k0
		    truename   -> k1
		    k0 k1 dh:p generateDiffieHellmanSharedSecret -> ss
		    ( Store only on local users -- minor space efficiency hack: )
		    user   user? if ss -->   user$s.sharedSecrets[serverhash] fi
		    server user? if ss --> server$s.sharedSecrets[hashname]   fi
		fi
	    fi
	}
    }

    mio messageStream? if
	[   :ip0  ip0
	    :ip1  ip1
	    :ip2  ip2
	    :ip3  ip3
	    :port port
	    |   [
		    longname		( 'cause server won't know us )
		    hashname		( from )
		    userversion		( fromVersion )
		    serverhash		( to   )
		    trulyRandomFixnum	( padding )
		    REQ_SET_USER_INFO
		    replyStream dbrefToInts3
		    seq

		    hashname
		    longname
		    nickname

		    lastlongname
		    lasthashname

		    lastnamechange
		    userversion

		    userserver0
		    userserver1
		    userserver2
		    userserver3
		    userserver4

		    uip0   
		    uip1   
		    uip2   
		    uip3   
		    uport  

		    doing
		    donotdisturb
		    email
		    homepage
		    pgpkeyprint
		|
		|enbyte

		( Sign the packet: )
		ss |signedDigest
	    ]|join
	    "txt" t mio |writeStreamPacket pop pop
	]pop
    fi
;
'sendSetUserInfo export

( =====================================================================	)
( - doReqPing -- Handle REQ_PING packet from net.			)

:   doReqPing { [] $ $ $ $ $ $ $ $ $ -> }
    -> io
    -> port
    -> ip3
    -> ip2
    -> ip1
    -> ip0
    -> to
    -> fromversion
    -> from

    |length 4 != if ]pop return fi

    |pop -> seq		seq integer? not if ]pop return fi
    |pop -> i2		i2  integer? not if ]pop return fi
    |pop -> i1		i1  integer? not if ]pop return fi
    |pop -> i0		i0  integer? not if ]pop return fi
    ]pop

    ( Locate caller and callee: )
    .folkBy.hashName from get? -> guest not if return fi    guest guest? not if return fi
    .folkBy.hashName to   get? -> user  not if return fi    user  folk?  not if return fi

    ( Fire back the return packet: )
    user rootAsUserDo{		( Set 'user -> who' on mss packet.	)
	[   :to   guest
	    :ip0  ip0
	    :ip1  ip1
	    :ip2  ip2
	    :ip3  ip3
	    :port port
	    |   [   ACK_PING
		    i0 i1 i2
		    seq
		|
		|enbyte
	    ]|join
	    "txt" t io |maybeWriteStreamPacket	pop pop
	]pop
    }
;

( =====================================================================	)
( - doAckPing -- Handle ACK_PING packet from net			)

:   doAckPing { [] $ $ $ $ $ $ $ $ $ -> }
    -> io
    -> port
    -> ip3
    -> ip2
    -> ip1
    -> ip0
    -> to
    -> fromversion
    -> from

    |length 4 != if ]pop return fi

    |pop -> seq		seq integer? not if ]pop return fi
    |pop -> i2		i2  integer? not if ]pop return fi
    |pop -> i1		i1  integer? not if ]pop return fi
    |pop -> i0		i0  integer? not if ]pop return fi
    ]pop

    ( Reconstruct destination stream from i0/i1/i2: )

    i0 i1 i2 ints3ToDbref -> tio not if return fi
    tio remote? if return fi
    tio messageStream? not if return fi

    ( Write reply packet to given stream: )
    ( Locate caller and callee: )
    .folkBy.hashName from get? -> guest not if return fi    guest guest? not if return fi
    .folkBy.hashName to   get? -> user  not if return fi    user  folk?  not if return fi

    ( Write reply packet to given stream: )
    guest rootAsUserDo{		( Set 'user -> who' on mss packet.	)
	[   :op   ACK_PING
	    :ip0  ip0
	    :ip1  ip1
	    :ip2  ip2
	    :ip3  ip3
	    :port port
	    :seq  seq
	    |
	    "txt" t tio |maybeWriteStreamPacket	pop pop
	]pop
    }
;

( =====================================================================	)
( - sendPing -- User-callable fn to ping a server			)

:   sendPing { $ $ $ -> }
    -> seq            seq isAnInteger
    -> server
    -> replyStream    replyStream isAMessageStream

    .muq.muqnetIo -> mio

    mio messageStream? if
	[   :to   server
	    |   [   REQ_PING
		    replyStream dbrefToInts3
		    seq
		|
		|enbyte
	    ]|join
	    "txt" t mio |writeStreamPacket pop pop
	]pop
    fi
;
'sendPing export

( =====================================================================	)
( - doReqGetVal --							)

:   doReqGetVal { [] $ $ $ $ $ $ $ $ $ -> }
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/aaa\n" d, )
    -> io
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal io=" d, io d, "\n" d, )
    -> port
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal port=" d, port d, "\n" d, )
    -> ip3
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal ip3=" d, ip3 d, "\n" d, )
    -> ip2
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal ip2=" d, ip2 d, "\n" d, )
    -> ip1
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal ip1=" d, ip1 d, "\n" d, )
    -> ip0
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal ip0=" d, ip0 d, "\n" d, )
    -> to
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal to=" d, to d, "\n" d, )
    -> fromversion
    -> from
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal from=" d, from d, "\n" d, )
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal |length=" d, |length d, "\n" d, )

    |length 7 < if ]pop return fi

    |pop -> propdir	propdir integer?  not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal propdir=" d, propdir d, "\n" d, )
    |pop -> key
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal key=" d, key d, "\n" d, )
    |pop -> obj
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal obj=" d, obj d, "\n" d, )
    |pop -> seq		seq integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal seq=" d, seq d, "\n" d, )
    |pop -> i2		i2  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal i2=" d, i2 d, "\n" d, )
    |pop -> i1		i1  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal i1=" d, i1 d, "\n" d, )
    |pop -> i0		i0  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal i0=" d, i0 d, "\n" d, )
    ]pop

    ( Locate caller and callee: )
    .folkBy.hashName from get? -> guest not if return fi    guest guest? not if return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal guest=" d, guest d, "\n" d, )
    .folkBy.hashName to   get? -> user  not if return fi    user  folk?  not if return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal user=" d, user d, "\n" d, )

    ( Do the requested data fetch: )
    guest rootAsUserDo{		( Do read under appropriate privilege restrictions )
        obj key propdir muqnetGet? -> val -> found
    }
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal val=" d, val d, "\n" d, )
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal found=" d, found d, "\n" d, )

    ( Fire value back to sender: )
    user rootAsUserDo{		( Set 'user -> who' on mss packet.	)
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/ggg\n" d, )
	[   :to   guest
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/hhh\n" d, )
	    :ip0  ip0
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/iii\n" d, )
	    :ip1  ip1
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/jjj\n" d, )
	    :ip2  ip2
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/kkk\n" d, )
	    :ip3  ip3
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/lll\n" d, )
	    :port port
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/mmm\n" d, )
	    |
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/nnn\n" d, )
	        [   ACK_GET_VAL
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/ooo\n" d, )
		    i0 i1 i2
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/ppp\n" d, )
		    seq
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/qqq\n" d, )
		    found
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/rrr\n" d, )
		    val
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/sss\n" d, )
		|
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/ttt\n" d, )
		|enbyte
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/uuu\n" d, )
	    ]|join
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/vvv\n" d, )
	    "txt" t io |maybeWriteStreamPacket	pop pop
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/www\n" d, )
	]pop
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/xxx\n" d, )
    }
( .sys.muqPort d, "(190)<" d, @ d, ">doReqGetVal/zzz\n" d, )
;

( =====================================================================	)
( - doAckGetVal --							)

:   doAckGetVal { [] $ $ $ $ $ $ $ $ $ -> }
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetVal/aaa\n" d, )
    -> io
    -> port
    -> ip3
    -> ip2
    -> ip1
    -> ip0
    -> to
    -> fromversion
    -> from

    |length 6 != if ]pop return fi

    |pop -> val
    |pop -> found
    |pop -> seq		seq integer? not if ]pop return fi
    |pop -> i2		i2  integer? not if ]pop return fi
    |pop -> i1		i1  integer? not if ]pop return fi
    |pop -> i0		i0  integer? not if ]pop return fi
    ]pop

    ( Reconstruct destination stream from i0/i1/i2: )
    i0 i1 i2 ints3ToDbref -> tio not if return fi
    tio remote? if return fi
    tio messageStream? not if return fi

    ( Locate caller and callee: )
    .folkBy.hashName from get? -> guest not if return fi    guest guest? not if return fi
    .folkBy.hashName to   get? -> user  not if return fi    user  folk?  not if return fi

    ( Write reply packet to given stream: )
    guest rootAsUserDo{		( Set 'user -> who' on mss packet.	)
	[   ACK_GET_VAL
	    seq
	    val
	    found
	|
	    "txt" t tio |maybeWriteStreamPacket	pop pop
	]pop
    }
( .sys.muqPort d, "(190)<" d, @ d, ">doAckGetVal/zzz\n" d, )
;

( =====================================================================	)
( - getVal -- Transparent networking support				)

( This function is invoked by the server when it detects that		)
( the target of a getVal operation is a proxy object			)

:   getVal { $ $ $ -> $ }
( .sys.muqPort d, "(190)<" d, @ d, ">getVal/aaa\n" d, )
    -> propdir
    -> key
    -> obj
    getMuqnetIo -> replyStream

    obj proxyInfo
    -> yy
    -> xx
    -> i2
    -> i1
    -> i0
    -> guest

    ( Buggo, should have a lock on _count: )
    ++ muqnetVars:_count
    muqnetVars:_count -> seq

    guest  folk?  not if
	[   "muqnet: getVal: proxy %s invalid value %s in .folkBy.hashName"
	    obj guest
	|   ]print simpleError
    fi

    .muq.muqnetIo -> mio
    mio messageStream? if
	muqnetVars:_maxRetries -> retriesLeft
	do{
( .sys.muqPort d, "(190)<" d, @ d, ">getVal/bbb\n" d, )
	    retriesLeft 0 = if
		[   "muqnet: getVal: remote user %s not responding"
		    guest
		|   ]print simpleError
	    fi

	    ( Fire off request for value: )
( .sys.muqPort d, "(190)<" d, @ d, ">getVal/ccc\n" d, )
	    [   :to   guest
		|   [   REQ_GET_VAL
			replyStream dbrefToInts3
			seq
			obj
			key
			propdir
		    |
		    |enbyte
		]|join
		"txt" t mio |writeStreamPacket pop pop
	    ]pop
( .sys.muqPort d, "(190)<" d, @ d, ">getVal/ddd\n" d, )

	    ( Wait for reply: )
	    ( Read a packet: )
	    t   -> noFragments		( Complete packets only.	)
	    [ replyStream | noFragments muqnetVars:_retryMilliseconds
		|readAnyStreamPacket
( .sys.muqPort d, "(190)<" d, @ d, ">getVal/eee\n" d, )
		-> stream
		-> who
		-> tag
		stream not if
( .sys.muqPort d, "(190)<" d, @ d, ">getVal/fff\n" d, )
		    -- retriesLeft
		    ]pop
		    loopNext
		fi
( .sys.muqPort d, "(190)<" d, @ d, ">getVal/ggg\n" d, )
		who guest !=		  if ]pop loopNext fi
		|length 4 !=		  if ]pop loopNext fi
		|pop -> found
		|pop -> val
		|pop    seq	!=		  if ]pop loopNext fi
		|pop ACK_GET_VAL !=		  if ]pop loopNext fi
	    ]pop	
( .sys.muqPort d, "(190)<" d, @ d, ">getVal/hhh\n" d, )
	    found not if
		[ "No such property: %s" key | ]print simpleError
	    fi
( .sys.muqPort d, "(190)<" d, @ d, ">getVal/iii\n" d, )
	    val
	    loopFinish
	}
    else
        nil
    fi
( .sys.muqPort d, "(190)<" d, @ d, ">getVal/zzz\n" d, )
;
'getVal export

( =====================================================================	)
( - getValP -- Transparent networking support				)

( This function is invoked by the server when it detects that		)
( the target of a getValP operation is a proxy object			)

:   getValP { $ $ $ -> $ $ }
    -> propdir
    -> key
    -> obj
    getMuqnetIo -> replyStream

    obj proxyInfo
    -> yy
    -> xx
    -> i2
    -> i1
    -> i0
    -> guest

    ( Buggo, should have a lock on _count: )
    ++ muqnetVars:_count
    muqnetVars:_count -> seq

    guest  folk?  not if
	[   "muqnet: getValP: proxy %s invalid value %s in .folkBy.hashName"
	    obj guest
	|   ]print simpleError
    fi

    .muq.muqnetIo -> mio
    mio messageStream? if
	muqnetVars:_maxRetries -> retriesLeft
	do{
	    retriesLeft 0 = if
		[   "muqnet: getValP: remote user %s not responding"
		    guest
		|   ]print simpleError
	    fi

	    ( Fire off request for value: )
	    [   :to   guest
		|   [   REQ_GET_VAL
			replyStream dbrefToInts3
			seq
			obj
			key
			propdir
		    |
		    |enbyte
		]|join
		"txt" t mio |writeStreamPacket pop pop
	    ]pop

	    ( Wait for reply: )
	    ( Read a packet: )
	    t   -> noFragments		( Complete packets only.	)
	    [ replyStream | noFragments muqnetVars:_retryMilliseconds
		|readAnyStreamPacket
		-> stream
		-> who
		-> tag
		stream not if
		    -- retriesLeft
		    ]pop
		    loopNext
		fi
		who guest !=		  if ]pop loopNext fi
		|length 4 !=		  if ]pop loopNext fi
		|pop -> found
		|pop -> val
		|pop    seq	!=		  if ]pop loopNext fi
		|pop ACK_GET_VAL !=		  if ]pop loopNext fi
	    ]pop	
	    found
	    val
	    loopFinish
	}
    else
        nil nil
    fi
;
'getValP export

( =====================================================================	)
( - doReqMaybeWriteStreamPacket --					)

:   doReqMaybeWriteStreamPacket { [] $ $ $ $ $ $ $ $ $ -> }
    -> io
    -> port
    -> ip3
    -> ip2
    -> ip1
    -> ip0
    -> to
    -> fromversion
    -> from

    |length 6 < if ]pop return fi

    |pop -> done
    |pop -> tag
    |pop -> seq		seq integer? not if ]pop return fi
    |pop -> i2		i2  integer? not if ]pop return fi
    |pop -> i1		i1  integer? not if ]pop return fi
    |pop -> i0		i0  integer? not if ]pop return fi

    ( Locate caller and callee: )
    .folkBy.hashName from get? -> guest not if ]pop return fi    guest guest? not if ]pop return fi
(   .folkBy.hashName to   get? -> user  not if ]pop return fi    user  folk?  not if ]pop return fi )

( buggo? Are additional authentication checks needed here? )
( In particular, that destination is owned by 'to'? )
( Are we bypassing any write restrictions that would )
( have been enforced if this write had been in-db? )
    ( Reconstruct destination stream from i0/i1/i2: )
    i0 i1 i2 ints3ToDbref -> tio not if ]pop return fi
    tio remote? if ]pop return fi
    ( Hack so we can mail to av and have it go to )
    ( av.io -- this saves a network roundTrip to )
    ( fetch io from av a lot of the time:	  )
    tio messageStream? not if
        tio :io get? -> tio not if
            ]pop return
	fi
        tio messageStream? not if
            ]pop return
    fi  fi

    ( Write given packet to given stream: )
    tag done guest tio |rootMaybeWriteStreamPacket pop pop

    ]pop
;

( =====================================================================	)
( - doAckMaybeWriteStreamPacket --					)

:   doAckMaybeWriteStreamPacket { [] $ $ $ $ $ $ $ $ $ -> }
    -> io
    -> port
    -> ip3
    -> ip2
    -> ip1
    -> ip0
    -> to
    -> fromversion
    -> from

    ( At present we never generate an ACK_MAYBE_WRITE_STREAM_PACKET	)
    ( so we ignore any which are recieved.  One of these days we	)
    ( may generate them on reciept and retransmit the REQ if we		)
    ( fail to get an ACK soon enough.  Meantime, this fn serves		)
    ( as a placeholder.							)
    ]pop
;

( =====================================================================	)
( - maybeWriteStreamPacket -- Function to send packet overseas		)

( This function is invoked by the server when it detects that		)
( the target of a |maybeWriteStreamPacket operation is a		)
( proxy object rather than an inserver message stream, as is		)
( normally the case.							)

:   maybeWriteStreamPacket { [] $ $ $ -> [] $ $ ! }
    -> stream
    -> done
    -> tag

    stream remote? not if
        |length pop ( Keep arityChecker happy )
    else
	stream proxyInfo pop pop
	-> i2
	-> i1
	-> i0
	-> guest

	guest  folk?  not if
	    [   "muqnet: maybeWriteStreamPacket: proxy %s invalid value %s in .folkBy.hashName"
		stream guest
	    |   ]print simpleError
	fi

        .muq.muqnetIo -> mio
	mio messageStream? if

	    ( Buggo, should have a lock on _count: )
	    ++ muqnetVars:_count
	    |dup[
		REQ_MAYBE_WRITE_STREAM_PACKET |unshift
		i0                |push
		i1                |push
		i2                |push
		muqnetVars:_count |push
		tag               |push
		done              |push
		|enbyte
		( buggo, faster to push than unshift: )
		guest |unshift :to   |unshift
		"txt" t mio |maybeWriteStreamPacket pop pop
	    ]pop
	fi
    fi
    tag done
;
'maybeWriteStreamPacket export

( =====================================================================	)

( - Packet handler functions which are tested by x[xy]-oldmud2:		)

( =====================================================================	)
( - doReqIsles -- Handle REQ_ISLES packet from net.			)

:   doReqIsles { [] $ $ $ $ $ $ $ $ $ -> }
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsles/aaa...\n" d, )
    -> io
    -> port
    -> ip3
    -> ip2
    -> ip1
    -> ip0
    -> to
    -> fromversion
    -> from
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsles to = " d, to d, "\n" d, )
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsles from = " d, from d, "\n" d, )
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsles ip0 = " d, ip0 d, "\n" d, )
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsles ip1 = " d, ip1 d, "\n" d, )
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsles ip2 = " d, ip2 d, "\n" d, )
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsles ip3 = " d, ip3 d, "\n" d, )
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsles port = " d, port d, "\n" d, )
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsles |length = " d, |length d, "\n" d, )

    |length 4 != if ]pop return fi

    |pop -> seq		seq integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsles seq = " d, seq d, "\n" d, )
    |pop -> i2		i2  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsles i2 = " d, i2 d, "\n" d, )
    |pop -> i1		i1  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsles i1 = " d, i1 d, "\n" d, )
    |pop -> i0		i0  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsles i0 = " d, i0 d, "\n" d, )
    ]pop

    ( Locate caller and callee: )
    .folkBy.hashName from get? -> guest not if return fi    guest guest? not if return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsles guest = " d, guest d, "\n" d, )
    .folkBy.hashName to   get? -> user  not if return fi    user  folk?  not if return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsles user  = " d, user  d, "\n" d, )
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsles muqnetVars:_isleNames length  = " d, muqnetVars:_isleNames length d, "\n" d, )

    ( Fire back the return packet: )
    user rootAsUserDo{		( Set 'user -> who' on mss packet.	)
	[   :to   guest
	    :ip0  ip0
	    :ip1  ip1
	    :ip2  ip2
	    :ip3  ip3
	    :port port
	    |   [   ACK_ISLES
		    i0 i1 i2
		    seq
		    muqnetVars:_isleNames length
		|
		|enbyte
	    ]|join
	    "txt" t io |maybeWriteStreamPacket	pop pop
	]pop
    }
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsles/zzz...\n" d, )
;

( =====================================================================	)
( - doAckIsles -- Handle ACK_ISLES packet from net			)

:   doAckIsles { [] $ $ $ $ $ $ $ $ $ -> }
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles/aaa...\n" d, )
    -> io
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles io = " d, io d, "\n" d, )
    -> port
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles port = " d, port d, "\n" d, )
    -> ip3
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles ip3 = " d, ip3 d, "\n" d, )
    -> ip2
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles ip2 = " d, ip2 d, "\n" d, )
    -> ip1
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles ip1 = " d, ip1 d, "\n" d, )
    -> ip0
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles ip = " d, ip0 d, "\n" d, )
    -> to
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles to = " d, to d, "\n" d, )
    -> fromversion
    -> from
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles from = " d, from d, "\n" d, )
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles |length = " d, |length d, "\n" d, )

    |length 5 != if ]pop return fi

    |pop -> num		num integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles num = " d, num d, "\n" d, )
    |pop -> seq		seq integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles seq = " d, seq d, "\n" d, )
    |pop -> i2		i2  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles i2 = " d, i2 d, "\n" d, )
    |pop -> i1		i1  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles i1 = " d, i1 d, "\n" d, )
    |pop -> i0		i0  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles i0 = " d, i0 d, "\n" d, )
    ]pop

    ( Reconstruct destination stream from i0/i1/i2: )
    i0 i1 i2 ints3ToDbref -> tio not if return fi
    tio remote? if return fi
    tio messageStream? not if return fi

    ( Locate caller and callee: )
    .folkBy.hashName from get? -> guest not if return fi    guest guest? not if return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles guest = " d, guest d, "\n" d, )
    .folkBy.hashName to   get? -> user  not if return fi    user  folk?  not if return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles user = " d, user d, "\n" d, )

    ( Write reply packet to given stream: )
    guest rootAsUserDo{		( Set 'user -> who' on mss packet.	)
	[   seq	 ( MUST BE FIRST, to ensure delivery via task mechanism. )
	    :isles num
        | "ack" t tio |maybeWriteStreamPacket pop pop ]pop
    }
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsles/zzz...\n" d, )
;

( =====================================================================	)
( - sendIsles -- User-callable fn to ask for islecount from a server	)

:   sendIsles { [] -> [] }
( .sys.muqPort d, "(190)<" d, @ d, ">sendIsles/aaa...\n" d, )
    |pop -> seq		seq isAnInteger
( .sys.muqPort d, "(190)<" d, @ d, ">sendIsles/bbb...\n" d, )
    |pop -> server
( .sys.muqPort d, "(190)<" d, @ d, ">sendIsles/ccc...\n" d, )
    |pop -> replyStream
( .sys.muqPort d, "(190)<" d, @ d, ">sendIsles seq = " d, seq d, "\n" d, )
( .sys.muqPort d, "(190)<" d, @ d, ">sendIsles server = " d, server d, "\n" d, )
( .sys.muqPort d, "(190)<" d, @ d, ">sendIsles replyStream = " d, replyStream d, "\n" d, )
	replyStream isAMessageStream
( .sys.muqPort d, "(190)<" d, @ d, ">sendIsles/ddd...\n" d, )
    ]pop

    .muq.muqnetIo -> mio
( .sys.muqPort d, "(190)<" d, @ d, ">sendIsles mio = " d, mio d, "\n" d, )

    mio messageStream? if
	[   :to   server
	    |   [   REQ_ISLES
		    replyStream dbrefToInts3
		   seq
		|
		|enbyte
	    ]|join
	    "txt" t mio |writeStreamPacket pop pop
	]pop
    fi

    [ |
( .sys.muqPort d, "(190)<" d, @ d, ">sendIsles/zzz.\n" d, )
;
'sendIsles export

( =====================================================================	)
( - doReqIsle -- Handle REQ_ISLE packet from net.			)

:   doReqIsle { [] $ $ $ $ $ $ $ $ $ -> }
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsle/aaa\n" d, )
    -> io
( .sys.muqPort d, "(190)<" d, @ d, ">doReqISLE io = " d, io d, "\n" d, )
    -> port
( .sys.muqPort d, "(190)<" d, @ d, ">doReqISLE port = " d, port d, "\n" d, )
    -> ip3
( .sys.muqPort d, "(190)<" d, @ d, ">doReqISLE ip3 = " d, ip3 d, "\n" d, )
    -> ip2
( .sys.muqPort d, "(190)<" d, @ d, ">doReqISLE ip2 = " d, ip2 d, "\n" d, )
    -> ip1
( .sys.muqPort d, "(190)<" d, @ d, ">doReqISLE ip1 = " d, ip1 d, "\n" d, )
    -> ip0
( .sys.muqPort d, "(190)<" d, @ d, ">doReqISLE ip0 = " d, ip0 d, "\n" d, )
    -> to
( .sys.muqPort d, "(190)<" d, @ d, ">doReqISLE to = " d, to d, "\n" d, )
    -> fromversion
    -> from
( .sys.muqPort d, "(190)<" d, @ d, ">doReqISLE from = " d, from d, "\n" d, )

    |length 5 != if ]pop return fi

    |pop -> num		num integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqISLE num = " d, num d, "\n" d, )
    |pop -> seq		seq integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqISLE seq = " d, seq d, "\n" d, )
    |pop -> i2		i2  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqISLE i2 = " d, i2 d, "\n" d, )
    |pop -> i1		i1  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqISLE i1 = " d, i1 d, "\n" d, )
    |pop -> i0		i0  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqISLE i0 = " d, i0 d, "\n" d, )
    ]pop

    num 0 <                   if return fi
    num muqnetVars:_isleNames length >= if return fi

    ( Locate caller and callee: )
    .folkBy.hashName from get? -> guest not if return fi    guest guest? not if return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqISLE guest = " d, guest d, "\n" d, )
    .folkBy.hashName to   get? -> user  not if return fi    user  folk?  not if return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doReqISLE user = " d, user d, "\n" d, )
( .sys.muqPort d, "(190)<" d, @ d, ">doReqISLE muqnetVars:_isleNames[num]  = " d, muqnetVars:_isleNames[num]  d, "\n" d, )
( .sys.muqPort d, "(190)<" d, @ d, ">doReqISLE muqnetVars:_isles[num]  = " d, muqnetVars:_isles[num]  d, "\n" d, )

    ( Fire back the return packet: )
    user rootAsUserDo{		( Set 'user -> who' on mss packet.	)
	[   :to   guest
	    :ip0  ip0
	    :ip1  ip1
	    :ip2  ip2
	    :ip3  ip3
	    :port port
	    |   [   ACK_ISLE
		    i0 i1 i2
		    seq
		    muqnetVars:_isleNames[num]
		    muqnetVars:_isles[num]
		|
		|enbyte
	    ]|join
	    "txt" t io |maybeWriteStreamPacket	pop pop
	]pop
    }
( .sys.muqPort d, "(190)<" d, @ d, ">doReqIsle/zzz\n" d, )
;

( =====================================================================	)
( - doAckIsle -- Handle ACK_ISLE packet from net			)

:   doAckIsle { [] $ $ $ $ $ $ $ $ $ -> }
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsle/aaa\n" d, )
    -> io
( .sys.muqPort d, "(190)<" d, @ d, ">doAckISLE io = " d, io d, "\n" d, )
    -> port
( .sys.muqPort d, "(190)<" d, @ d, ">doAckISLE port = " d, port d, "\n" d, )
    -> ip3
( .sys.muqPort d, "(190)<" d, @ d, ">doAckISLE ip3 = " d, ip3 d, "\n" d, )
    -> ip2
( .sys.muqPort d, "(190)<" d, @ d, ">doAckISLE ip2 = " d, ip2 d, "\n" d, )
    -> ip1
( .sys.muqPort d, "(190)<" d, @ d, ">doAckISLE ip1 = " d, ip1 d, "\n" d, )
    -> ip0
( .sys.muqPort d, "(190)<" d, @ d, ">doAckISLE ip0 = " d, ip0 d, "\n" d, )
    -> to
( .sys.muqPort d, "(190)<" d, @ d, ">doAckISLE to = " d, to d, "\n" d, )
    -> fromversion
    -> from
( .sys.muqPort d, "(190)<" d, @ d, ">doAckISLE from = " d, from d, "\n" d, )

    |length 6 != if ]pop return fi

    |pop -> w		( This will be a proxy for the isle proper    )
( .sys.muqPort d, "(190)<" d, @ d, ">doAckISLE w = " d, w d, "\n" d, )
    |pop -> name	name string? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckISLE name = " d, name d, "\n" d, )
    |pop -> seq		seq integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckISLE seq = " d, seq d, "\n" d, )
    |pop -> i2		i2  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckISLE i2 = " d, i2 d, "\n" d, )
    |pop -> i1		i1  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckISLE i1 = " d, i1 d, "\n" d, )
    |pop -> i0		i0  integer? not if ]pop return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckISLE i0 = " d, i0 d, "\n" d, )
    ]pop

    ( Reconstruct destination stream from i0/i1/i2: )
    i0 i1 i2 ints3ToDbref -> tio not if return fi
    tio remote? if return fi
    tio messageStream? not if return fi

    ( Locate caller and callee: )
    .folkBy.hashName from get? -> guest not if return fi    guest guest? not if return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckISLE guest = " d, guest d, "\n" d, )
    .folkBy.hashName to   get? -> user  not if return fi    user  folk?  not if return fi
( .sys.muqPort d, "(190)<" d, @ d, ">doAckISLE user = " d, user d, "\n" d, )

    ( Write reply packet to given stream: )
(    [	:op     ACK_ISLE )
(	:ip0    ip0 )
(	:ip1    ip1 )
(	:ip2    ip2 )
(	:ip3    ip3 )
(	:port   port )
(        :seq    seq )
(        :name   name )
(        :isle  w )
(        | )
(	"txt" t tio |maybeWriteStreamPacket	pop pop )
(    ]pop )

( buggo? Shouldn't this be maybeWriteStreamPacket? )
( seems like otherwise one uncooperative user can stop the muqnet daemon )
    guest rootAsUserDo{		( Set 'user -> who' on mss packet.	)
        [  seq	( MUST BE FIRST, to ensure delivery via task mechanism. )
           :isle w
           :name name
        | "ack" t tio |maybeWriteStreamPacket pop pop ]pop
    }
( .sys.muqPort d, "(190)<" d, @ d, ">doAckIsle/zzz\n" d, )
;

( =====================================================================	)
( - sendIsle -- User-callable fn to ask for isle name and io		)

:   sendIsle { [] -> [] }
( .sys.muqPort d, "(190)<" d, @ d, ">sendIsle/aaa\n" d, )
( .sys.muqPort d, "(190)<" d, @ d, ">sendIsle argblock is:\n" d, )
( |for val iii do{ .sys.muqPort d, "(190) #" d, iii d, ": " d, val d, "\n" d, } )
( .sys.muqPort d, "(190)<" d, @ d, ">sendisle done listing argblock\n" d, )
    |pop -> num		num isAnInteger
( .sys.muqPort d, "(190)<" d, @ d, ">sendIsle/bbb num = " d, num d, "\n" d, )
    |pop -> seq		seq isAnInteger
( .sys.muqPort d, "(190)<" d, @ d, ">sendIsle/bbb seq = " d, seq d, "\n" d, )
    |pop -> to
( .sys.muqPort d, "(190)<" d, @ d, ">sendIsle/bbb to  = " d, to d, "\n" d, )
    |pop -> replyStream	replyStream isAMessageStream
( .sys.muqPort d, "(190)<" d, @ d, ">sendIsle/bbb replyStream  = " d, replyStream d, "\n" d, )
    ]pop

    .muq.muqnetIo -> mio
    mio messageStream? if
	[   :to   to
	    |   [   REQ_ISLE
		    replyStream dbrefToInts3
		    seq
		    num
		|
		|enbyte
	    ]|join
	    "txt" t mio |writeStreamPacket pop pop
	]pop
    fi

    [ |
( .sys.muqPort d, "(190)<" d, @ d, ">sendIsle/zzz\n" d, )
;
'sendIsle export



( =====================================================================	)

( - Packet handler functions which still need testing and/or writing	)

( =====================================================================	)
( - rootClearIsleRegister -- Fn to clear isle register			)

:   rootClearIsleRegister { -> }
    muqnetVars:_isles     reset
    muqnetVars:_isleNames reset
;
'rootClearIsleRegister export

( =====================================================================	)
( - rootRegisterIsle -- Fn to register a isle				)

:   rootRegisterIsle { [] -> [] }
( .sys.muqPort d, "(190)<" d, @ d, ">rootRegisterIsle/aaa\n" d, )
    |shift -> w
    |shift -> isleName	isleName isAString
    ]pop

    ( Search for isle by that name: )
    isleName vals[ muqnetVars:_isleNames |positionInStack? -> pos -> found ]pop
    found if
	w    --> muqnetVars:_isles[pos]
    else
	isleName muqnetVars:_isleNames push
	w        muqnetVars:_isles   push
    fi

    [ |
( .sys.muqPort d, "(190)<" d, @ d, ">rootRegisterIsle/zzz\n" d, )
;
'rootRegisterIsle export

( =====================================================================	)
( - delKey -- Transparent networking support				)

( This function is invoked by the server when it detects that		)
( the target of a public/...-del-key operation is a proxy object.	)

:   delKey { [] $ $ $ -> [] $ $ ! }
"muqnet: delKey of remote object not yet supported" simpleError
    pop
;
'delKey export

( =====================================================================	)
( - delKeyP -- Transparent networking support				)

( This function is invoked by the server when it detects that		)
( the target of a public/...-del-key-p operation is a proxy object.	)

:   delKeyP { [] $ $ $ -> [] $ $ ! }
"muqnet: delKeyP of remote object not yet supported" simpleError
    pop
;
'delKeyP export

( =====================================================================	)
( - getKeyP -- Transparent networking support				)

( This function is invoked by the server when it detects that		)
( the target of a getKeyP operation is a proxy object.		)

:   getKeyP { [] $ $ $ -> [] $ $ ! }
"muqnet: getKeyP of remote object not yet supported\n" simpleError
    pop
;
'getKeyP export

( =====================================================================	)
( - getFirstKey? -- Transparent networking support			)

( This function is invoked by the server when it detects that		)
( the target of a getFirstKey? operation is a proxy object.		)

:   getFirstKey? { [] $ $ $ -> [] $ $ ! }
"muqnet: getFirstKey? remote object not yet supported\n" simpleError
    pop
;
'getFirstKey? export

( =====================================================================	)
( - getKeysByPrefix -- Transparent networking support			)

( This function is invoked by the server when it detects that		)
( the target of a getKeysByPrefix operation is a proxy object.	)

:   getKeysByPrefix { [] $ $ $ -> [] $ $ ! }
"muqnet: getKeysByPrefix of remote object not yet supported\n" simpleError
    pop
;
'getKeysByPrefix export

( =====================================================================	)
( - getNextKey? -- Transparent networking support			)

( This function is invoked by the server when it detects that		)
( the target of a getNextKey? operation is a proxy object.		)

:   getNextKey? { [] $ $ $ -> [] $ $ ! }
"muqnet: getNextKey? of remote object not yet supported\n" simpleError
    pop
;
'getNextKey? export

( =====================================================================	)
( - keysBlock -- Transparent networking support				)

( This function is invoked by the server when it detects that		)
( the target of a keysvalsBlock operation is a proxy object		)

:   keysBlock { [] $ $ $ -> [] $ $ ! }
"muqnet: keysBlock of remote object not yet supported\n" simpleError
    pop
;
'keysBlock export

( =====================================================================	)
( - keysvalsBlock -- Transparent networking support			)

( This function is invoked by the server when it detects that		)
( the target of a keysvalsBlock operation is a proxy object		)

:   keysvalsBlock { [] $ $ $ -> [] $ $ ! }
"muqnet: keysvalsBlock of remote object not yet supported\n" simpleError
    pop
;
'keysvalsBlock export

( =====================================================================	)
( - setFromBlock -- Transparent networking support			)

( This function is invoked by the server when it detects that		)
( the target of a setFromBlock operation is a proxy object		)

:   setFromBlock { [] $ $ $ -> [] $ $ ! }
"muqnet: setFromBlock of remote object not yet supported\n" simpleError
    pop
;
'setFromBlock export

( =====================================================================	)
( - setFromKeysvalsBlock -- Transparent networking support		)

( This function is invoked by the server when it detects that		)
( the target of a setFromKeysvalsBlock operation is a proxy object	)

:   setFromKeysvalsBlock { [] $ $ $ -> [] $ $ ! }
"muqnet: setFromKeysvalsBlock of remote object not yet supported\n" simpleError
    pop
;
'setFromKeysvalsBlock export

( =====================================================================	)
( - setVal -- Transparent networking support				)

( This function is invoked by the server when it detects that		)
( the target of a setVal operation is a proxy object			)

:   setVal { [] $ $ $ -> [] $ $ ! }
"muqnet: setVal of remote object not yet supported\n" simpleError
    pop
;
'setVal export

( =====================================================================	)
( - valsBlock -- Transparent networking support				)

( This function is invoked by the server when it detects that		)
( the target of a valsBlock operation is a proxy object		)

:   valsBlock { [] $ $ $ -> [] $ $ ! }
"muqnet: valsBlock of remote object not yet supported\n" simpleError
    pop
;
'valsBlock export

( =====================================================================	)

( - Dispatch vector							)

( _dispatchVector maps the opcodes REQ_GET_VAL &tc defined )
( in the constants section to matching handler functions:  )

[   'doReqGetMuqnetUserInfo		'doAckGetMuqnetUserInfo
    'doReqGetUserInfo			'doAckGetUserInfo
    'doReqPing				'doAckPing
    'doReqIsles				'doAckIsles
    'doReqIsle				'doAckIsle
    'doReqGetVal			'doAckGetVal
    'doReqTestPacket			'doAckTestPacket
    'doReqGetUserHash			'doAckGetUserHash
    'doReqMaybeWriteStreamPacket	'doAckMaybeWriteStreamPacket
    'doReqSetUserInfo           	'doAckSetUserInfo
|   ]makeVector --> _dispatchVector

( =====================================================================	)

( - run	-- Muqnet daemon main function         				)

:   run { [] -> @ }

    ( Read port to run on: )
    :port nil |ged -> port
    port integer? not if nil endJob fi
    port 256 % intChar -> portlo
    port 256 / intChar -> porthi
    
    ( Discard argblock: )
    ]pop

    ( Write error msgs to logfile, but don't echo them )
    ( to stdout, since nobody is reading it anyhow:    )
    'muf:logEvent      --> @.reportEvent

    ( Create our socket: )
    makeSocket          -> socket
    t		       --> socket.passNonprintingFromNet
    t		       --> socket.passNonprintingToNet
    makeMessageStream   -> fromNetStream
    makeMessageStream   -> toNetStream
    makeMessageStream   -> fromDbStream
    toNetStream        --> socket.standardInput
    fromNetStream      --> socket.standardOutput
    socket             --> .muq.muqnetSocket
    @                  --> .muq.muqnetJob
    fromDbStream       --> .muq.muqnetIo
    t		       --> fromDbStream.allowWrites

    .folkBy.nickName["muqnet"] -> muqnetUser
    muqnetUser$s.hashName      -> muqnetsHashname
    muqnetUser$s.longName      -> muqnetsLongname

    nil --> @.breakEnable

    ( Find/create table of users banned by our server: )
    .muq.banned -> banned
    banned hash? not if
	makeHash   -> banned
	banned    --> .muq.banned
    fi

    ( Open datagram socket: )
    [   :socket socket
	:port   .sys.muqPort
	:protocol :datagram
    | ]listenOnSocket

    ( Preserve datagram boundaries: )
    nil --> socket$s.inputByLines

    ( Locate dispatch vector: )
    _dispatchVector -> dispatchVector

    ( Remember length of dispatch vector: )
    dispatchVector length -> dispatchVectorLength

    (      -- BEGIN BOILERPLATE --        )
    ( Establish a restart letting users   )
    ( kill the job from the debugger:	  )
    [   :function :: { -> ! } nil endJob ;
        :name 'endJob
        :reportFunction "Terminate job."
    | ]withRestartDo{               ( 1 )

    ( Establish a handler letting users   )
    ( terminate a job with a signal       )
    ( -- via 'killJob' say:              )
    [ .e.kill :: { [] -> [] ! } :why |get endJob ;
    | ]withHandlerDo{               ( 2 )

    ( Establish a restart letting users   )
    ( return to the main shell prompt     )
    ( from the debugger:                  )
    [   :function :: { -> ! }  'muf:abrt goto ;
	:name 'abort
	:reportFunction "Return to main mufShell prompt."
    | ]withRestartDo{               ( 3 )

    ( Establish a handler letting users   )
    ( abort a job with a signal           )
    ( -- via 'abortJob' say:             )
    [ .e.abort :: { [] -> [] ! } 'abort invokeRestart ;
    | ]withHandlerDo{               ( 4 )

    ( Establish a handler that will kill  )
    ( us if we lose the net link:         )
    [ .e.brokenPipeWarning :: { [] -> [] ! } nil endJob ;
    | ]withHandlerDo{               ( 5 )

    [ "muqnet.run: PID = %s" @.pid | ]logPrint

    "muqnet:run Starting up.\n" log,
    withTag muf:abrt do{       ( 6 ) ( Trap compile errs etc    )
    abrt                          ( Continuation from errors )
    (       -- END BOILERPLATE --         )

    ( Infinite loop processing packets: )
    nil -> millisecsToWait
    t   -> noFragments
    do{
	( Read a packet: )
	[ fromNetStream fromDbStream | noFragments millisecsToWait
	    |readAnyStreamPacket
            -> stream
	    -> who
	    -> tag
( .sys.muqPort d, "(190)<" d, @ d, ">run/luptop\n" d, )

	    ++ muqnetVars:_count


	    stream fromDbStream = if
( .sys.muqPort d, "(190)<" d, @ d, ">run/fromDbStream\n" d, )

		( ---------------------------------- )
		( Packet is from a local user.	     )
		( ---------------------------------- )

		( We have two kinds of packets here: )
                (				     )	
		( (1) Raw packets with headers like  )
	        (       :ip0    128		     )
	        (       :ip1     95		     )
	        (       :ip2    112		     )
	        (       :ip3     36		     )
	        (       :port 30000		     )
		(     These we simply pass direct to )
                (     the socket which delivers them )
                (     to given address.              )
                (				     )	
		( (2) Cooked packets with headers    )
	        (       :to #<Guest 874abd0f>        )
                (     For these we need to:          )
                (     FROM_FIELD = who.hashName      )
                (     TO_FIELD = to.hashName         )
                (     SHARED_SECRET_FIELD = shared   )
                (       secret for 'who' and 'to'.   )
                (     RANDOM_FIELD = 8 bytes true    )
                (       random padding.              )
                (     Sign packet with shared secret )
                (     Compress packet                )
                (     Extract ip[0-3]+port from the  )
                (       'to' Guest record, and use   )
                (     them to construct a raw packet )
                (     header as in (1), which can    )
		(     then be sent to the socket.    )
		:ip0  nil |ged -> ip0
		:ip1  nil |ged -> ip1
		:ip2  nil |ged -> ip2
		:ip3  nil |ged -> ip3
		:port nil |ged -> port
		:to   nil |ged -> dst

		who user?
		dst guest?
		and not if

		    ( Raw packet, just stuff it out the socket:     )
		    "txt" t toNetStream |writeStreamPacket pop pop
		    ]pop loopNext
		else
		    ( Cooked packet. )

		    ( Find/compute shared secret.  Doing this )
		    ( inline avoids creating a function that  )
		    ( might be too easy to call, and hence a  )
                    ( very minor security weakening:          )
		    who$s.hashName    -> whoHashName
		    who$s.userVersion -> whoVersion
		    dst$s.hashName    -> dstHashName
		    rootOmnipotentlyDo{
			who$s.sharedSecrets dstHashName get? -> ss not if
			    ( Should be symmetric, but check anyhow: )
			    dst$s.sharedSecrets whoHashName get? -> ss if
				( Store only on local users -- minor space efficiency hack: )
			        who user? if ss --> who$s.sharedSecrets[dstHashName] fi
			    else
				dst$s.longName -> k0
				who$s.trueName -> k1
				k0 k1 dh:p generateDiffieHellmanSharedSecret -> ss
				( Store only on local users -- minor space efficiency hack: )
			        who user? if ss --> who$s.sharedSecrets[dstHashName] fi
			        dst user? if ss --> dst$s.sharedSecrets[whoHashName] fi
			    fi
			fi
		    }

		    ( Drop the   :to xx   entry in packet: )
		    |deleteNonchars

		    ( Add the from/fromVersion/to/randompad prefix: )
		    [ whoHashName whoVersion dstHashName trulyRandomFixnum | |enbyte ||swap ]|join

		    ( Only for debugging, extract opcode from header: )
		    |debyteMuqnetHeader
		    -> op
		    -> fromLongName 
		    -> to
		    -> from
		    -> fromVersion
		    -> err

		    ( Sign the packet: )
		    ss |signedDigest

		    ( Construct raw packet prefix: )
		    [   :ip0  ip0  if ip0  else dst$s.ip0  fi
			:ip1  ip1  if ip1  else dst$s.ip1  fi
			:ip2  ip2  if ip2  else dst$s.ip2  fi
			:ip3  ip3  if ip3  else dst$s.ip3  fi
			:port port if port else dst$s.port fi
		    | ||swap ]|join

		    ( Stuff packet out the socket:     )
		    ( Following logPrint is useful when debugging muqnet base level protocol problems: )
                    ( [ "muqnet.run put packet: %s from %s to %s" op opname whoHashName argname dstHashName argname | ]logPrint )
		    "txt" t toNetStream |writeStreamPacket pop pop
		    ]pop loopNext
		fi
	    fi



	    stream fromNetStream = if
( .sys.muqPort d, "(190)<" d, @ d, ">run/fromNetStream\n" d, )
		( --------------------------------------------- )
		( Packet is from another Muq server via network )
		( --------------------------------------------- )

		( Remember where request came from: )
		:ip0  |get -> ip0
		:ip1  |get -> ip1
		:ip2  |get -> ip2
		:ip3  |get -> ip3
		:port |get -> port


		( Drop above address info from block: )
		|deleteNonchars

		( Extract the muqnet header.  This leaves   )
		( the actual packet contents unchanged:	    )	
		|debyteMuqnetHeader
		-> op
		-> fromLongName 
		-> to
		-> from
		-> fromVersion
		-> err
		( Following logPrint is useful when debugging muqnet base level protocol problems: )
                ( [ "muqnet.run got packet: %s from %s to %s" op opname from argname to argname | ]logPrint )

		( Ignore/refuse packets from banned players: )
		banned from get? pop if
		    ( tag case{  )
		    ( on: "req"  )
			( Maybe should fire back "ack" packet )
			( here, with err value of "ban"?      )
		    ( } )
		    [ "muqnet: ***** Ignoring net packet from banned hashName %d\n" from | ]logPrint
		    ]pop loopNext
		fi

		( Ignore uninterpretable headers:           )
		err if
		    "muqnet: ***** Ignoring net packet with uninterpretable header\n" log,
		    ]pop loopNext
		fi

		( fromLongName non-NIL is a special case:   )
		fromLongName if

		    ( ------------------------------------- )
		    ( This case is used for bootstrap	    )
		    ( interactions in which we can't	    )
		    ( count on having 'from' in .folkBy	    )
		    ( and can't ask sender for 'from info   )	 
		    ( without falling into infinite regress )
		    ( ------------------------------------- )

		    ( Verify fromLongName matches 'from':   )
        	    fromLongName hash from != if ]pop loopNext fi


		    ( Find/compute shared secret.  Doing this )
		    ( inline avoids creating a function that  )
		    ( might be too easy to call, and hence a  )
		    ( very minor security weakening:          )
		    rootOmnipotentlyDo{
			.folkBy.hashName to get? -> toUser not if
			    ( To bogeaux user -- drop packet: )
			    ]pop loopNext
			fi
			toUser user? not if
			    ( To bogeaux user -- drop packet: )
			    ]pop loopNext
			fi
			toUser$s.sharedSecrets from get? -> ss not if
			    fromLongName      -> k0
			    toUser$s.trueName -> k1
			    k0 k1 dh:p generateDiffieHellmanSharedSecret -> ss
			fi
		    }

		    ( Verify signature on packet: )
		    ss |signedDigestCheck |pop if
			]pop loopNext
		    fi

		    ( Convert packet from net to native format, )
		    ( discarding it if conversion fails:        )
		    |debyte -> err

		    ( If conversion failed due to an unknown    )
		    ( hashName, we should ask the other end     )
		    ( to send us the info on that hashName;     )
		    err fixnum? if

			[   :ip0  ip0
			    :ip1  ip1
			    :ip2  ip2
			    :ip3  ip3
			    :port port
			    |   [
				    muqnetsHashname		( from		)
				    muqnetUser$s.userVersion	( fromVersion	)
				    err	    			( to		)
				    trulyRandomFixnum		( randompad	)
				    REQ_GET_USER_INFO
				    0 0 0 			( no replyStream )
				    0     			( no seq         )
				    muqnetsLongname		( longname  )
				    .sys.ip0
				    .sys.ip1
				    .sys.ip2
				    .sys.ip3
				    .sys.muqPort
				|
				|enbyte
			    ]|join
			    "txt" t toNetStream |writeStreamPacket pop pop
			]pop
			[ "muqnet: Unknown hashname %d, dropping packet & requesting info\n" err | ]logPrint
			]pop loopNext
		    fi

		    ( If conversion failed with a string value )
		    ( for err, the string is a diagnostic. For )
		    ( now, at least, we ignore the diagnostic: )
		    err if
			[ "muqnet: ***** Packet conversion failed: %s" err | ]logPrint
			]pop loopNext
		    fi

		    ( Drop the extra leading longName on the   )
		    ( packet:  				       )
		    |shift pop

		    |length 5 <                 if ]pop loopNext fi
		    |shift -> from      	( hashName for source user )
		    |shift -> fromversion      	( userversion for src user )
		    |shift -> to        	( hashName for dst user    )
		    |shift -> randompad	     	( to confuse eavesdroppers )
		    |shift -> charOp
		    op 0 <                      if
			[ "muqnet: Unsupported packet op: %d. Dropping packet.\n" op | ]logPrint
			]pop loopNext
		    fi
		    op dispatchVectorLength >=  if
			[ "muqnet: Unsupported packet op: %d. Dropping packet.\n" op | ]logPrint
			]pop loopNext
		    fi

		    from fromversion to
		    ip0 ip1 ip2 ip3 port
	            fromDbStream
		    dispatchVector[op] call{ [] $ $ $ $ $ $ $ $ $ -> }

		    loopNext
		else

		    ( There are two completely unauthenticated ops, )
		    ( REQ_GET_MUQNET_USER_INFO REQ_GET_USER_INFO -- )
		    ( they are used to bootstrap the shared state   )
		    ( needed to to packet authentication. All other )
		    ( packets get authenticated at this point:      )
		    op REQ_GET_MUQNET_USER_INFO_I !=
		    op        REQ_GET_USER_INFO_I != and
		    if

			( Find/compute shared secret.  Doing this )
			( inline avoids creating a function that  )
			( might be too easy to call, and hence a  )
			( very minor security weakening:          )
			rootOmnipotentlyDo{
			    .folkBy.hashName to get? -> toUser not if
				( To bogeaux user -- drop packet: )
				"muqnet: ***** Packet to bogus user, dropping it\n" log,
				]pop loopNext
			    fi
			    toUser user? not if
				( To bogeaux user -- drop packet: )
				"muqnet: ***** Packet to bogus user, dropping it\n" log,
				]pop loopNext
			    fi

			    .folkBy.hashName from get? -> fromUser not if
				( From unknown user -- ask for )
				( user info and drop packet:   )
				[ "muqnet: Packet from unknown hashname %d, dropping packet & requesting info\n" from | ]logPrint
				[   :ip0  ip0
				    :ip1  ip1
				    :ip2  ip2
				    :ip3  ip3
				    :port port
				    |   [
					    muqnetsHashname		( from		)
					    muqnetUser$s.userVersion	( fromVersion	)
					    from	    		( to		)
					    trulyRandomFixnum	( randompad	)
					    REQ_GET_USER_INFO
					    0 0 0 		( no replyStream )
					    0     		( no seq         )
					    muqnetsLongname	( longname  )
					    .sys.ip0
					    .sys.ip1
					    .sys.ip2
					    .sys.ip3
					    .sys.muqPort
					|
					|enbyte
				    ]|join
				    "txt" t toNetStream |writeStreamPacket pop pop
				]pop
				]pop loopNext
			    fi

			    ( Sanity check: Check that fromUser is a Guest )
			    ( before depending on that assumption:         )
			    fromUser guest? not if
				( This shouldn't happen!?   Drop packet: )
				"muqnet: ***** Packet not from a guest?! Dropping it.\n" log,
				]pop loopNext
			    fi

			    ( If userVersion doesn't match our local value, )
			    ( request an update on user information:        )
			    fromUser$s.userVersion fromVersion < if
				[   "muqnet: Outdated userVersion (%d vs %d) for %s, requesting update\n"
				    fromVersion	
				    fromUser$s.userVersion
				    fromUser$s.nickName
				| ]logPrint
				[   :ip0  ip0
				    :ip1  ip1
				    :ip2  ip2
				    :ip3  ip3
				    :port port
				    |   [
					    muqnetsHashname		( from		)
					    muqnetUser$s.userVersion	( fromVersion	)
					    from	    		( to		)
					    trulyRandomFixnum		( randompad	)
					    REQ_GET_USER_INFO
					    0 0 0 			( no replyStream )
					    0     			( no seq         )
					    muqnetsLongname		( longname  )
					    .sys.ip0
					    .sys.ip1
					    .sys.ip2
					    .sys.ip3
					    .sys.muqPort
					|
					|enbyte
				    ]|join
				    "txt" t toNetStream |writeStreamPacket pop pop
				]pop
			    fi

			    toUser$s.sharedSecrets from get? -> ss not if
				fromUser$s.longName -> k0
				toUser$s.trueName   -> k1
				k0 k1 dh:p generateDiffieHellmanSharedSecret -> ss
				( Store only on local users -- minor space efficiency hack: )
				fromUser user? if ss --> fromUser$s.sharedSecrets[to]   fi
				toUser   user? if ss -->   toUser$s.sharedSecrets[from] fi
			    fi
			}

			( Verify signature on packet: )
			ss |signedDigestCheck |pop if
			    "muqnet: ***** Packet signature invalid?! Dropping it.\n" log,
			    ]pop loopNext
			fi
		    fi

		    ( Convert packet from net to native format, )
		    ( discarding it if conversion fails:        )
		    |debyte -> err

		    ( If conversion failed due to an unknown    )
		    ( hashName, we should ask the other end     )
		    ( to send us the info on that hashName;     )
		    err fixnum? if
			[ "muqnet: Packet mentions unknown hashname %d, dropping packet & requesting info\n" err | ]logPrint

			[   :ip0  ip0
			    :ip1  ip1
			    :ip2  ip2
			    :ip3  ip3
			    :port port
			    |   [
				    muqnetsHashname		( from		)
				    muqnetUser$s.userVersion	( fromVersion	)
				    err	    			( to		)
				    trulyRandomFixnum		( randompad	)
				    REQ_GET_USER_INFO
				    0 0 0 			( no replyStream )
				    0     			( no seq         )
				    muqnetsLongname		( longname  )
				    .sys.ip0
				    .sys.ip1
				    .sys.ip2
				    .sys.ip3
				    .sys.muqPort
				|
				|enbyte
			    ]|join
			    "txt" t toNetStream |writeStreamPacket pop pop
			]pop
			]pop loopNext
		    fi

		    ( If conversion failed with a string value )
		    ( for err, the string is a diagnostic:     )
		    err if
			[ "muqnet: ***** Packet conversion failed: %s" err | ]logPrint
			]pop loopNext
		    fi
		fi
	    fi

	    |length 5 <                  if
		"muqnet: ***** Ignoring undersize packet." log,
		]pop loopNext
	    fi
	    |shift -> from      	     ( hashName for source user )
	    |shift -> fromVersion      	     ( version  for source user )
	    |shift -> to        	     ( hashName for dst user    )
	    |shift -> randompad	     ( to confuse eavesdroppers )
	    |shift -> charOp
	    charOp char? not             if
		"muqnet: ***** Packet op not a char. Dropping packet.\n" log,
		]pop loopNext
	    fi
	    charOp charInt -> op
	    op 0 <                       if
		[ "muqnet: ***** Unsupported packet op: %d. Dropping packet.\n" op | ]logPrint
		]pop loopNext
	    fi
	    op dispatchVectorLength >=   if
		[ "muqnet: Unsupported packet op: %d. Dropping packet.\n" op | ]logPrint
		]pop loopNext
	    fi

( .sys.muqPort d, "(190)<" d, @ d, ">run/dispatching\n" d, )
	    from fromversion to
	    ip0 ip1 ip2 ip3 port
	    fromDbStream
	    dispatchVector[op] call{ [] $ $ $ $ $ $ $ $ $ -> }
	    loopNext

	]pop
    }
    "muqnet:run Shutting down.\n" log,

    } ( 6 )
    } ( 5 )
    } ( 4 )
    } ( 3 )
    } ( 2 )
    } ( 1 )
;
'run export

( =====================================================================	)

( - rootStart			             				)

:   rootStart { -> ! }

    "muqnet" forkJobset not if
        [ :port .sys.muqPort | 'muqnet:run ]exec
    fi
;
'rootStart export


( =====================================================================	)
( - rc2D entry			             				)


( Set Muq to accept muqnet packets when Muq starts in daemon mode: )
'muqnet:rootStart --> .etc.rc2D.s51EnableMuqnetDaemon


( =====================================================================	)


( - File variables							)


( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example




