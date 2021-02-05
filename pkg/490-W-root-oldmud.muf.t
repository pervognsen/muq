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

( - 490-W-oldroot.muf -- Root-privileged admin functions for oldmud.	)
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

( --------------------------------------------------------------------- )
(									)
(	For Mike Jittlov: A wiz of a wiz if ever there was!		)
(									)
( --------------------------------------------------------------------- )

( --------------------------------------------------------------------- )
( Author:       Jeff Prothero						)
( Created:      96Nov16, from bits and pieces				)
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
( ---------------------------------------------------------------------	)

( =====================================================================	)
( - Epigram								)
(									)
( "At present, television is a 'top-down' oligarchy.  There are few	)
(  stations, all very rich, and millions of receivers, most quite poor.	)
(  TV is thus a way of spreading the dreams of the rich.  In a thousand	)
(  subtle ways it invites its audience to yearn for an impossibly rich,	)
(  chic, exciting lifestyle.  Millions of viewers base their human	)
(  ideals on a few 'celebrities' -- a celebrity being someone on whom	)
(  a TV station is prepared to lavish its vast airTime costs.		)
(  [...]								)
( "The consequences [of Internet video] will be profound.  The rigidly	)
(  stylized TV dream-dictatorship, shaped by bigCompany advertising,	)
(  will be replaced by a chaotic uncensorable mass of video images,	)
(  shaped by individual greed, egotisim and missionary zeal.  It will	)
(  be wildly interactive.  Any viewer could reply to any programme,	)
(  or send in realTime suggestions or additions, or launch a rebuttal	)
(  or diversion."							)
(  [...]								)
(                 -- 97Jun26 Nature, Daedalus column (whimsy)		)
(									)
( =====================================================================	)

( =====================================================================	)
( - Overview -								)

( This file contains all the oldmud functions which			)
( require root privileges.  Neither the oldmud islekit			)
( nor the oldmsh shell need root privileges in normal			)
( operation:  They need not -- and probably should not --		)
( be owned by root.  There are, however, a few isle-related		)
( operations which need to be done by root, such as creating		)
( new accounts for mudusers, and starting up all the user daemons	)
( at server boot, and it makes sense to provide convenience		)
( functions to support these operations.				)


( =====================================================================	)
( - Package 'rootOldmud', exported symbols --				)

"rootOldmud" inPackage

( =====================================================================	)
( - Public functions							)

( =====================================================================	)
( - rootStartIsleDaemons -- 						)
:   rootStartIsleDaemons { $ -> }
    -> isle

    isle$s.owner rootAsUserDo{
        [ isle | oldmud:initializeIsle ]pop
	isle.daemonShell -> aShell
	( Kill any existing daemon: )
	isle.daemonJob -> j
	j jobIsAlive? if   j killJob   fi
    }

    "isled" forkJob not if
	[   isle$s.owner		( user          	)
	    aShell			( function to ]exec 	)
	    isle.io			( io queues to use	)
	    :home isle			( ]exec args		)
	| ]rootExecUserDaemon
    fi

    [ isle | oldmud:wakeLiveDaemon ]pop

    ( Make sure we start up user daemons for root and muqnet. )
    ( The immediate purpose of this is to ensure that if we   )
    ( restart at another IP address, change-of-address        )
    ( notifications get sent out for muqnet and root just as  )
    ( for other users.  This matters because external systems )
    ( know about both root and muqnet, and are likely to try  )
    ( communicating with them:                                )
    nil if
	[ .folkBy.nickName["root"] ( .folkBy.nickName["muqnet"] ) |
	    |for user do{
		user isle$s.owner != if

		    ( Locate I/O streams for user. )
		    ( May need to create them:     )
		    user$s.ioStream -> io
		    io messageStream? not if
			user rootAsUserDo{
			    makeBidirectionalMessageStream pop -> io
			    io --> user$s.ioStream
			}
		    fi

		    "sysd" forkJob not if
			[   user			( user          	)
			    aShell			( function to ]exec 	)
			    io			( io queues to use	)
			    :home isle		( ]exec args		)
			| ]rootExecUserDaemon
		    fi
		fi
	    }
	]pop
    fi

    isle.avatar foreach key val do{
	val$s.owner rootAsUserDo{
	    val.daemonShell -> aShell
	    ( Kill any existing daemon: )
	    val.daemonJob -> j
	    j jobIsAlive? if   j killJob   fi
	}
	"userd" forkJob not if
            [ "rootStartIsleDaemons: starting %s for %s as %s" aShell val$s.owner @ | ]logPrint
	    [   val$s.owner		( user          	)
		aShell			( function to ]exec 	)
		val.io			( io queues to use	)
		:home     val		( ]exec args		)
	    | ]rootExecUserDaemon
	fi

	[ val | oldmud:wakeLiveDaemon ]pop
    }
;
'rootStartIsleDaemons export

( =====================================================================	)
( - rootStartSampleOldmudIsleDaemons --					)
:   rootStartSampleOldmudIsleDaemons { -> }
    'oldmudVars:_isle bound? if
	oldmudVars:_isle rootStartIsleDaemons
    fi
;
( Set oldmud sample isle to be started when Muq starts in daemon mode: )
'rootStartSampleOldmudIsleDaemons --> .etc.rc2D.s80StartSampleOldmudIsleDaemons
'rootStartSampleOldmudIsleDaemons export

( =====================================================================	)
( - rootInitMudUser -- Noninteractive fn to create a new User.		)
:   rootInitMudUser { [] -> [] }
    |shift -> isle
    |shift -> name
    |shift -> lname
    ]pop

    .u[lname] -> user

    ( Ensure everything following gets   )
    ( created in appropriate package and )
    ( dbfile:                            )
    @.package              -> oldPkg	( Save current pkg )
    user$s.defaultPackage --> @.package ( Buggo, need 'inPackageDo{ ... }' )
    user rootAsUserDo{

        [ name isle | oldmud:makeAvatar ]-> avatar
        oldmsh:makeShellState --> avatar.shellState
	avatar.daemonShell -> aShell

	( Some users -- in particular root -- wind up with zero instead )
	( of NIL for missing servers, because they are created before   )
	( NIL is created.  Change zeros to NILs for consistency:        )
	user$s.userServer1 0 = if nil --> user$s.userServer1 fi
	user$s.userServer2 0 = if nil --> user$s.userServer2 fi
	user$s.userServer3 0 = if nil --> user$s.userServer3 fi
	user$s.userServer4 0 = if nil --> user$s.userServer4 fi
    }
    ( Restore our original lib.pkg: )
    oldPkg --> @.package

    avatar --> user$s.oldmudAvatar
    isle$s.owner rootAsUserDo{
        avatar --> isle.avatar[lname]
    }

    ( Set up as user "shell" a little )
    ( wrapper function which invokes  )
    ( the actual oldmsh shell:       )
    ::  { [] -> @ }
        ]pop 

	me$s.oldmudAvatar -> avatar

	[   :avatar avatar
	|   'oldmsh:]shell
        ]exec
    ; --> user$s.shell

    ( Start the user's avatar daemon running: )
    "avatard" forkJob not if
	[   avatar$s.owner	( user          	)
	    aShell		( function to ]exec 	)
	    avatar.io		( io queues to use	)
	    :home     avatar	( ]exec args		)
	| ]rootExecUserDaemon
    fi

    [ user |
;
'rootInitMudUser export

( =====================================================================	)
( - rootCreateMudUser -- Noninteractive fn to create a new User.	)
:   rootCreateMudUser { [] -> [] }
    |shift -> isle
    |shift -> name
    |shift -> lname
    |shift -> encryptedPassphrase
    ]pop

    name rootMakeAUser

    .u[lname] -> user
    encryptedPassphrase --> user$a.encryptedPassphrase
( t --> @.standardInput.twin.allowWrites )
( t --> @.standardInput.twin.allowReads )
( t --> @.standardInput.allowWrites )
( t --> @.standardInput.allowReads )

    [ isle name lname | rootInitMudUser
;
'rootCreateMudUser export

( =====================================================================	)
( - rootAddUser -- Interactive function to create a new User.		)
:   rootAddUser { -> }

    ( ===================================== )
    ( This function is an adaptation of the )
    ( standard 10-C-utils:rootAddUser fn. )
    ( ===================================== )

    @.actingUser root? not if
        "You must be root to add a user" ,
        return
    fi

    'oldmudVars:_isle bound? not if
        "You must create an isle before adding users to it\n" ,
	return
    else
	oldmudVars:_isle -> isle
    fi

    "Enter name for new user:\n" ,
    [ @.standardInput '\n' nil |
        |scanTokenToChar |popp
        |readTokenChars   |popp
    ]join -> name
    name stringDowncase -> lname
    .u lname get? pop if
        "You already have a user by that name\n" ,
	return
    fi

    "Enter passphrase for new user:\n" ,
    [ @.standardInput '\n' nil |
        |scanTokenToChar |popp
        |readTokenChars   |popp
	( Add a salt to slow down dictionary attacks: )
	lname vals[ ||swap ]|join
(	'z' |unshift )
(	'z' |unshift )
	|secureHash |secureHash
    ]join -> encryptedPassphrase

    [ isle name lname encryptedPassphrase | rootCreateMudUser ]pop

    "Done creating oldmud user.\n" ,
;
'rootAddUser export

( =====================================================================	)
( - rootConfigMenu 							)

:   rootConfigMenu { -> }

    "\n+--< Oldmud Root Config Options >--\n" ,
    'oldmudVars:_isle bound? not if
        "| i: create oldmud Isle\n" ,
    fi
    "| m: start Muqnet daemon\n" ,
    'oldmudVars:_isle bound? if
        "| d: start oldmud isle and user Daemons\n" ,
    fi
    "| l: start allowing telnet Logins\n" ,
    'oldmudVars:_isle bound? if
        "| u: add an oldmud User\n" ,
    fi
    'oldmudVars:_isle bound? if
        'mufVars:_rootNewAccountFn callable? if
            "| n: stop allowing New account creation at login prompt\n" ,
	else
            "| n: start allowing New account creation at login prompt\n" ,
	fi
    fi
    "| q: Quit this config menu\n" ,
    "+----------------------------------\n" ,
;

( =====================================================================	)
( - rootCreateNewMudUserAtLoginPrompt -- 				)
:   rootCreateNewMudUserAtLoginPrompt { [] -> [] }
    ]pop

    "Enter desired user name.  If you want caps, enter with caps.\n" ,
    "Please keep it under 32 chars and use only letters and underlines:\n" ,
    [ @.standardInput '\n' nil |
        |scanTokenToChar |popp
        |readTokenChars   |popp
    ]join -> name
    name stringDowncase -> lname
    .u lname get? pop if
        "You already have a user by that name\n" ,
	[ | return
    fi

    telnet:maybeWillEcho	( Try to suppress echoing during pw entry. )
    "Enter desired passphrase:\n" ,
    [ @.standardInput '\n' nil |
        |scanTokenToChar |popp
        |readTokenChars   |popp
	( Add a salt to slow down dictionary attacks: )
	lname vals[ ||swap ]|join
(	'z' |unshift )
(	'z' |unshift )
	|secureHash |secureHash
    ]join -> encryptedPassphrase
    "Re-enter desired passphrase:\n" ,
    [ @.standardInput '\n' nil |
        |scanTokenToChar |popp
        |readTokenChars   |popp
	( Add a salt to slow down dictionary attacks: )
	lname vals[ ||swap ]|join
(	'z' |unshift )
(	'z' |unshift )
	|secureHash |secureHash
    ]join -> encryptedPassphrase2
    telnet:maybeWontEcho	( Restore normal echoing.	)
    encryptedPassphrase encryptedPassphrase2 != if
        "Passphrases don't match!\n" ,
	[ | return
    fi

    [ "rootCreateNewMudUserAtLoginPrompt: Created '%s'.\n" name | ]logPrint
    [ oldmudVars:_isle name lname encryptedPassphrase | rootCreateMudUser ]-> user

    oldmudVars:_isle.welcomeMsg -> msg
    msg string? if
	msg ,
	( Quick hack to avoid bogus "YOUR AVATAR DAEMON IS DEAD" on login: )
	2000 sleepJob
    fi

    ( Shut down telnet daemon because  )
    ( it is running as root, and we'll )
    ( want one owned by the user:      )
    telnet:stop
    switchJob	( Give it time.  Another		)
    switchJob  ( race condition to fix someday.	)

    ( Convert to running as new user: )
    user rootBecomeUser	( Doesn't return.	)
;
'rootCreateNewMudUserAtLoginPrompt export

( =====================================================================	)
( - rootConfig -- Interactive re/configuration menu.			)
:   rootConfig { -> }

( Allow others to write to our instream: )
t --> @.standardInput.twin.allowWrites	( buggo! )
t --> @.standardInput.twin.allowReads	( buggo! )
t --> @.standardInput.allowWrites		( buggo! )
t --> @.standardInput.allowReads		( buggo! )
    rootConfigMenu
    do{
	readLine trimString -> choice

	choice case{

	on: ""

        on: "d"
	    .muq.muqnetIo messageStream? not if
		"Muqnet isn't running, you prolly want to start it first.\n" ,
		"If you REALLY want to start without muqnet up, do 'D'.\n" ,
	    else
		'oldmudVars:_isle bound? if
		    "( oldmudVars:_isle rootStartIsleDaemons )\n" ,
		    oldmudVars:_isle rootStartIsleDaemons
		    "Done.  (Don't forget to allow logins.)\n" ,
		fi
	    fi
	    rootConfigMenu

        on: "D"
	    'oldmudVars:_isle bound? if
	        "( oldmudVars:_isle rootStartIsleDaemons )\n" ,
	        oldmudVars:_isle rootStartIsleDaemons
		"Done.  (Don't forget to allow logins.)\n" ,
		rootConfigMenu
	    fi

	on: "l"
	    .sys.muqPort mufVars:_telnetPortOffset + -> port

	    [ "( [ %d 'mufVars:_rootNewAccountFn | rootAcceptLoginsOn ]pop )\n" port | ]print ,
	    [ port 'mufVars:_rootNewAccountFn | rootAcceptLoginsOn ]pop
	    [ "Now accepting telnet connections on port %d.\n" port | ]print ,
	    "You may wish to enable New account creation at login prompt.\n" ,
	    rootConfigMenu

	on: "m"
	    "( 'muqnet:rootStart )\n" ,
	    muqnet:rootStart
	    .sys.muqPort -> port
	    [ "Muqnet daemon started up on port %d\n" port | ]print ,
	    rootConfigMenu

	on: "u"
            "( rootOldmud:rootAddUser )\n" ,
            rootAddUser
            rootConfigMenu

        on: "i"
	    'oldmudVars:_isle bound? if
		"You've already created an isle\n" ,
	    else
		"Enter name for your isle:\n" ,
		[ @.standardInput '\n' nil |
		    |scanTokenToChar |popp
		    |readTokenChars   |popp
		]join -> name
		name "" = if "Anon" -> name fi

	        [ "( " name " oldmud:makeIsle --> oldmudVars:_isle )\n" | ]join ,
    		name oldmud:makeIsle --> oldmudVars:_isle
		[ oldmudVars:_isle name | muqnet:rootRegisterIsle ]pop

		"Select base TCP port (default 30,000; suggested alternates 32,000 34,000 ...):\n" ,
		[ @.standardInput '\n' nil |
		    |scanTokenToChar |popp
		    |readTokenChars   |popp
		    |for c do{
			c digitChar? not if   0 -> c   fi
		    }
		    |deleteNonchars
		]join -> portString
		"" portString = if 30000 else portString stringInt fi -> portNumber
		portNumber 8000  < if 30000 -> portNumber fi
		portNumber 62000 > if 62000 -> portNumber fi
		portNumber --> .sys.muqPort
		[ "( %d --> .sys.muqPort )\n" portNumber | ]print ,
		[ "Base port set to %d\n" portNumber | ]print ,
	        "(Don't forget to start the isle daemon.)\n" ,
	    fi
	    rootConfigMenu

	on: "q"
	    return

	on: "n"
            'mufVars:_rootNewAccountFn callable? if
		nil
	    else
		'rootCreateNewMudUserAtLoginPrompt.function
	    fi   --> 'mufVars:_rootNewAccountFn.function
	    "Done.\n" ,
	    rootConfigMenu

	else:
	    "Hrm? '" , choice , "'?\n" ,
        }
    }
;
'rootConfig export

( =====================================================================	)
( - Our config entry							)

"Oldmud Root Config Options" 'rootConfig addConfigFn




( =====================================================================	)

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example
