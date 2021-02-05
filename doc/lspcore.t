@c  -*-texinfo-*-

@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c ---^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)

@node Core Lisp, Core Lisp Overview, Top, Top
@chapter Core Lisp
@menu
* Core Lisp Overview::
* Function Documentation Conventions::
* low-level lisp functions::
* Core Lisp Wrapup::
@end menu


@c
@node Core Lisp Overview, Function Documentation Conventions, Core Lisp, Core Lisp
@section Core Lisp Overview
@cindex Core Lisp


@c
@node Function Documentation Conventions, low-level lisp functions, Core Lisp Overview, Core Lisp, Core Lisp
@section Function Documentation Conventions
@cindex Function documentation conventions

A typical function definition looks like

@quotation
@example
(strcat string string -> string )
File: job.t
Status: alpha
@end example

The @code{strcat} function concatenates two strings and
returns the resulting string.
@end quotation

The first line gives the name of the function followed by
the the number of values it accepts and returns, separated
by @code{->}.  There may be more than one line like this if
the function does several distinct tasks depending on the
types of its parameters.  Groups of related functions may
also be listed one per line here.  Operators other than
functions (such as function definition, variable assignment,
and control structure operators) give a synoptic usage
example rather than a simple argsIn/argsOut declaration.

The second line gives the source file implementing the
function.

The third line will be one of:

@table @samp
@item Status: temporary
This function is needed at the moment but is scheduled to be
replaced by something better.  releases.

@item Status: tentative
The function is offered for discussion and perhaps
experimentation, but is very likely to change in future
releases.

@item Status: alpha
The function is in useful form, but is subject to change if
any possible improvement becomes evident.

@item Status: beta
The function is thought to be final form, but is subject to
change if significant problems are identified in actual use.

@item Status: production
The function is baselined for general use, and incompatible
changes will be made only as a last resort.  (Compatible
extensions, such as allowing additional argument types, may
still be considered.)
@end table

@c
@node low-level lisp functions, low-level lisp overview, Function Documentation Conventions, Core Lisp
@section low-level lisp functions
@cindex Low-level lisp functions

Low level functions used in implementing the
lisp compiler and runtimes.

@menu
* low-level lisp overview::
* applyReadLambdaList::
* applyPrintLambdaList::
* |dropSingleQuotes::
* |scanLispToken::
* |classifyLispToken::
* |scanLispStringToken::
* getMacroCharacter::
* setMacroCharacter::
* explodeNumber[::
* explodeSymbol[::
* explodeBoundedStringLine[::
* low-level lisp wrapup::
@end menu

@c
@node  low-level lisp overview, applyReadLambdaList, low-level lisp functions, low-level lisp functions
@subsection low-level lisp overview

The functions in this section constitute the
C-coded Muq server support for the Muq lisp
compiler and runtimes.  They are not normally used
directly by application programmers, but may be of
interest to people writing Muq compilers.


@c
@node  applyReadLambdaList, applyPrintLambdaList, low-level lisp overview, low-level lisp functions
@subsection applyReadLambdaList
@defun applyReadLambdaList @{ [raw-args] -> [cooked-args] @}
@display
@exdent file: job.t
@exdent package: lisp
@exdent status: alpha
@end display

This is a very specialCase hack implementing the
lambda list for the lisp @code{read} function in
hardcoded fashion. We do this because @code{read}
is likely to be a performance hot-spot for the
lisp compiler (the char-by-char input code is a
hotspot for most compilers) and because @code{read}
calls are likely to usually default the input stream,
which would usually require invoking an initform
function, which I think is too slow here.

@end defun


@c
@node  applyPrintLambdaList, |dropSingleQuotes, applyReadLambdaList, low-level lisp functions
@subsection applyPrintLambdaList
@defun applyPrintLambdaList @{ [raw-args] -> [cooked-args] @}
@display
@exdent file: job.t
@exdent package: lisp
@exdent status: alpha
@end display

This is a very specialCase hack implementing the
lambda list for the lisp @code{print} function
(and related functions like @code{princ}, @code{prin1}
&tc) in
hardcoded fashion. We do this because @code{print}
is likely to be a performance hot-spot for some
lisp programs and because @code{print}
calls are likely to usually default the output stream,
which would usually require invoking an initform
function, which I think is too slow here.

@end defun


@c
@node  |dropSingleQuotes, |scanLispToken, applyPrintLambdaList, low-level lisp functions
@subsection |dropSingleQuotes
@defun |dropSingleQuotes @{ [chars] -> [chars] @}
@display
@exdent file: job.t
@exdent package: lisp
@exdent status: alpha
@end display

This function is a little speed hack for the
@code{readLispString} function:  It runs
through a block of characters dropping all
singleQuote chars not preceded by another
singleQuote char.

@end defun


@c
@node  |scanLispToken, |classifyLispToken, |dropSingleQuotes, low-level lisp functions
@subsection |scanLispToken
@defun |scanLispToken @{ [mss] -> [mss start stop line typ] @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|scanLispToken} function is
a special hack implementing the heart of the
Lisp Reader.  The return values are as for
the other @code{|scan-token-*} functions,
except for the @code{typ} return value,
which on return will be one of:

@table @code
@item lisp:stateMacro
A macro character has been encountered.
The corresponding macro function should be called.

@item lisp:stateWhitespace
A token consisting of whitespace
has been encountered.

@item lisp:stateSymbol
A token with the syntax of a lisp symbol,
potnum or dot has been encountered.
@end table


@end defun

@c
@node  |classifyLispToken, |scanLispStringToken, |scanLispToken, low-level lisp functions
@subsection |classifyLispToken
@defun |classifyLispToken @{ [chars] -> [ints] typ @}
@display
@exdent file: job.t
@exdent package: muf
@exdent status: alpha
@end display

The @code{|classifyLispToken} function is
intended to be called when
@code{|scanLispToken} returns
@code{lisp:stateSymbol}.  It accepts
a block of characters (normally obtained
via @code{|readTokenChars} and returns
a block of integers together with the
@code{typ} value, which will be one of:

@table @code
@item lisp:stateDot
The token consists of a single dot.

@item lisp:statePotnum
Thetoken has the syntax of a lisp
potential number.

@item lisp:stateSymbol
Neither of the above: The token is presumably a
vanilla lisp symbol.  In this case, in the return
block quote characters (such as '|' and '\') have
been removed, case conversion has been done as
requested by
@code{@@$S.readtable$S.readtableCase}, and any
quoted characters have bit @code{0x1000} set on
them: Converting the integer block back to
characters via @code{|intChar} will strip these
bits.

@end table




@end defun

@c
@node  |scanLispStringToken, getMacroCharacter, |classifyLispToken, low-level lisp functions
@subsection |scanLispStringToken
@defun |scanLispStringToken @{ [mss endchar] -> [mss start stop line] @}
@display
@exdent file: job.t
@exdent package: lisp
@exdent status: alpha
@end display

The @code{|scanLispStringToken} prim is a hardcoded
speed hack intended to put the inner loop of
locating the end of a lisp string down in C.

It is called with the desired string termination
character and stream (quotation within the
string is controlled by the current lisp
readtable, @code{@@$s.readtable}) and returns
the usual @code{|scan-token-*} result block
suitable for passing to @code{|readTokenChars}
once the @code{line} value is popped.

@end defun


@c
@node  getMacroCharacter, setMacroCharacter, |scanLispStringToken, low-level lisp functions
@subsection getMacroCharacter
@defun getMacroCharacter @{ [ char &optional readtable ] -> [ cfn nontermp ] @}
@display
@exdent file: job.t
@exdent package: lisp
@exdent status: alpha
@end display

The @code{getMacroCharacter} prim is the
CommonLisp-defined mechanism for reading
the macro function associated with a
given @code{char} in the given @code{readtable}
(which defaults to @code{@@$S.readtable}).

The @code{cfn} return value is the macro
function (else nil), and the @code{nontermp}
return value is @sc{nil} until it is a
nonterminating macro.

@end defun


@c
@node  setMacroCharacter, explodeNumber[, getMacroCharacter, low-level lisp functions
@subsection setMacroCharacter
@defun setMacroCharacter @{ [chr cfn &optional nontermp readtable] -> [t] @}
@display
@exdent file: job.t
@exdent package: lisp
@exdent status: alpha
@end display

The @code{setMacroCharacter} prim is the
CommonLisp-defined way to set a macro
function in the specified @code{readtable}
(default @code{@@$S.readtable}).  

The @code{chr} argument must be a character.

The @code{cfn} argument will normally be the
macro compiledFunction.

If @code{nontermp} is non-@sc{nil}, the
macro will be nonterminating.

@end defun


@c
@node  explodeNumber[, explodeSymbol[, setMacroCharacter, low-level lisp functions
@subsection explodeNumber[
@defun explodeNumber[ @{ number -> [chars] @}
@display
@exdent file: job.t
@exdent package: lisp
@exdent status: alpha
@end display

The @code{explodeNumber[} prim is a support
function for the lisp printer: It accepts a
numeric argument and returns a printable
representation of that number as a block of
characters.

@end defun


@c
@node  explodeSymbol[, explodeBoundedStringLine[, explodeNumber[, low-level lisp functions
@subsection explodeSymbol[
@defun explodeSymbol[ @{ symbol -> [chars] @}
@display
@exdent file: job.t
@exdent package: lisp
@exdent status: alpha
@end display

The @code{explodeSymbol[} prim is a support
function for the lisp printer: It accepts a symbol
argument and returns a printable representation of
that symbol as a block of characters.

@end defun


@c
@node  explodeBoundedStringLine[, low-level lisp wrapup, explodeSymbol[, low-level lisp functions
@subsection explodeSymbol[
@defun explodeBoundedStringLine[ @{ string start maxlen -> [chars] chars-read @}
@display
@exdent file: job.t
@exdent package: lisp
@exdent status: alpha
@end display

The @code{explodeBoundedStringLine[} prim is a support
function for the lisp printer: It accepts a string,
an integer offset within that string, and an
integer line length limit, and returns a printable
representation of that the line starting at that
offset, up to an including the next newline (but
reading at most maxline chars from the string),
plus an integer count of chars read from the
string.

Note: In the return block, double-quotes (") and
backslashes (\) are preceded by a backslash,
so in general @code{chars-read} need not
equal the size of @code{[chars]}.

@end defun


@c
@node  low-level lisp wrapup, Core Lisp Wrapup, explodeBoundedStringLine[, low-level lisp functions
@subsection low-level lisp wrapup


@c
@node Core Lisp Wrapup, Function Index, low-level lisp wrapup, Core Lisp
@section Core Lisp Wrapup

This concludes the Core Lisp chapter.

@c --    File variables                                                 */

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:

