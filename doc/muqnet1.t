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

@node Muqnet Architecture, Muqnet Architecture Overview, Top, Top
@chapter Muqnet Architecture

This chapter documents the Muqnet softcode and hardcode for the benefit of
application programmers using or modifying it.

If you are not familiar with Muq programming, you may wish to first
read the @strong{Elementary MUF Tutorial} or the @strong{MUF for Hackers Tutorial}.

@menu
* Muqnet Architecture Overview::
* Muqnet Design Goals::
* Muqnet Components::
* Muqnet Architecture Wrapup::
@end menu
@c -*-texinfo-*-

@c {{{ Muqnet Architecture Overview
@c
@node Muqnet Architecture Overview, Muqnet Design Goals, Muqnet Architecture, Muqnet Architecture
@section Muqnet Architectecture Overview

The Muqnet software package is so named because it implements virtual worlds which may be distributed
seamlessly across a set of micros connected by the Internet, much as the Muqnet archipelago is a country
distributed across a set of isles connected by the Pacific.

We start by reviewing Muqnet's design goals (so you will know what it was -- and was
not! -- designed to do), then itemize its critical components, explore them in detail one by
one, and finally discuss the organization of the actual source code files.

@c {{{endfold}}}
@c {{{ Muqnet Design Goals
@c
@node Muqnet Design Goals, Muqnet Components, Muqnet Architecture Overview, Muqnet Architecture
@section Muqnet Design Goals

Security
Authentication
Scalability


@c {{{endfold}}}
@c {{{ Muqnet Components
@c
@node Muqnet Components, Muqnet Architecture Wrapup, Muqnet Design Goals, Muqnet Architecture
@section Muqnet Components

Muqnet Protocol
Muqnet Daemons
Muqnet Shell
Muqnet Classes

@c {{{endfold}}}
@c {{{ Muqnet Architecture Wrapup
@c
@node Muqnet Architecture Wrapup, Function Index, Muqnet Components, Muqnet Architecture
@section Muqnet Architecture Wrapup




@c {{{endfold}}}
@c --    File variables							*/

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:
