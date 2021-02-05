
@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Muf Compiler, Muf Compiler Overview, Muq Internals Wrapup, Top
@chapter Muf Compiler

@menu
* Muf Compiler Overview::
* Muf Compiler Wrapup::
@end menu

@c
@node Muf Compiler Overview, Muf Compiler Wrapup, Muf Compiler, Muf Compiler
@section Muf Compiler Overview

This chapter documents the in-db (@sc{muf}) implementation
of the @sc{muf} compiler, and includes all the source.
You most definitely do not need to read or understand this chapter in order to
write application code in @sc{muf}, but you may find it
interesting if you are curious about the internals of
the @sc{muf} compiler, or are interested in writing a
Muq compiler of your own.


@example  @c
( This is not a test.  This is text. )
"root" inPackage
:   oldmud { $ $ -> }
    -> base
    -> name
    name oldmud:makeIsle --> oldmudVars:_isle
    [ oldmudVars:_isle name | muqnet:rootRegisterIsle ]pop
    base --> .sys$s.muqPort
    muqnet:rootStart
    oldmudVars:_isle rootOldmud:rootStartIsleDaemons
    [ base 23 + 'mufVars:_rootNewAccountFn | rootAcceptLoginsOn ]pop
    'rootOldmud:rootCreateNewMudUserAtLoginPrompt$s.function --> 'mufVars:_rootNewAccountFn$s.function
;
:   qw     { -> }    "QWest"  30000 oldmud    ;
:   qe     { -> }    "QEast"  32000 oldmud    ;
:   qn     { -> }    "QNorth" 34000 oldmud    ;
:   qs     { -> }    "QSouth" 36000 oldmud    ;
:   chee   { -> }    "Chee"   30000 oldmud    ;
:   chow   { -> }    "Chow"   40000 oldmud    ;
@end example

@c
@node Muf Compiler Wrapup, Function Index, Muf Compiler Overview, Muf Compiler
@section Muf Comp

This completes the in-db @sc{muf}-compiler chapter.  If you have
questions or suggestions, feel free to email cynbe@@sl.tcp.com.


