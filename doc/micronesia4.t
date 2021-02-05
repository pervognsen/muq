@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@c =============================================
@c TO DO:
@c Everything! :)
@c =============================================

@node Micronesia Architecture, Micronesia Architecture Overview, Micronesia Hacking Tutorial Wrapup, Top
@chapter Micronesia Architecture

This chapter documents the Micronesia code structure for the benefit of
application programmers customizing or extending it.

If you are not familiar with Muq programming, you may wish to first
read the @strong{Elementary MUF Tutorial} or the @strong{MUF for Hackers Tutorial}.

@menu
* Micronesia Architecture Overview::
* Micronesia Design Goals::
* Micronesia Components::
* Micronesia Source Files::
* Micronesia Architecture Wrapup::
@end menu
@c -*-texinfo-*-

@c {{{ Micronesia Architecture Overview
@c
@node Micronesia Architecture Overview, Micronesia Design Goals, Micronesia Architecture, Micronesia Architecture
@section Micronesia Architectecture Overview

The Micronesia software package is so named because it implements virtual worlds which may be distributed
seamlessly across a set of micros connected by the Internet, much as the Micronesia archipelago is a country
distributed across a set of isles connected by the Pacific.

We start by reviewing Micronesia's design goals (so you will know what it was -- and was
not! -- designed to do), then itemize its critical components, explore them in detail one by
one, and finally discuss the organization of the actual source code files.

@c {{{endfold}}}
@c {{{ Micronesia Design Goals
@c
@node Micronesia Design Goals, Micronesia Components, Micronesia Architecture Overview, Micronesia Architecture
@section Micronesia Design Goals

Security
Flexibility
Scalability
Familiarity


@c {{{endfold}}}
@c {{{ Micronesia Components
@c
@node Micronesia Components, Micronesia Source Files, Micronesia Design Goals, Micronesia Architecture
@section Micronesia Components

Micronesia Protocol
Micronesia Daemons
Micronesia Shell
Micronesia Classes

@c {{{endfold}}}
@c {{{ Micronesia Source Files
@c
@node Micronesia Source Files, Micronesia Architecture Wrapup, Micronesia Components, Micronesia Architecture
@section Micronesia Source Files


@c {{{endfold}}}
@c {{{ Micronesia Architecture Wrapup
@c
@node Micronesia Architecture Wrapup, Function Index, Micronesia Source Files, Micronesia Architecture
@section Micronesia Architecture Wrapup




@c {{{endfold}}}
@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
