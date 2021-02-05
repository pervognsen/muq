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

( =====================================================================	)
( - Epigram.								)

(   When murder is outlawed, only outlaws will murder.			)
(   Won't you feel safer around your inlaws, then? :)			)

( - 000-C-version.muf -- Check library/server versions match.		)

( =====================================================================	)

( Reduce space between garbage collects while building )
( libraries, to reduce waste spacein them:             )
100000 --> .muq.bytesBetweenGarbageCollects

: checkVersion

    ( PATCH THE FOLLOWING LINE AFTER EACH NEW RELEASE )
    "0.0.0" -> libraryVersion

    .muq.version libraryVersion != if
	"***** LIBRARY VERSION (" ,
	libraryVersion ,
	") DOES NOT MATCH SERVER VERSION (" ,
	.muq.version ,
	")!\n" ,
    fi

    ( Should have Muq exit with nonzero status here, )
    ( but don't have a hack for that yet. Buggo.     )
;

checkVersion

( - File variables							)

( Local variables:							)
( mode: outline-minor							)
( outline-regexp: "( -+"						)
( End:									)

@end example
