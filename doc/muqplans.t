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

@node Muq Plans, Function Index, Core Muf Wrapup, Top
@chapter Muq Plans

This short chapter is included primarily for legal reasons.

Ideas I have considered for inclusion in future releases of Muq
prior to March 1, 1997 include:

@itemize @bullet
@item
Improvement of the current in-db transparent world networking support,
possibly to the point of full network transparency at the application
user level:  Users seeing a world seamlessly distributed across multiple
servers at the LAN and/or WAN level.

@item
Radical improvement of existing semitransparent inserver networking
possibly to the point of full network transparency at the application
programmer level.

@item
Implementation of three-dimensional graphics worlds of the VRML or
OpenGL sort, based on added inserver graphics support and/or a separate
graphics coprocess.

@item
Implementation of such worlds based on heavily procedural world
definitions, with actual geometry, textures and/or other graphics
elements generated on the fly rather than stored statically.

@item
Use of a single underlying world definition, static or procedural,
to drive both VRML/OpenGL style interactive graphics, and also
photorealistic rendering, most likely at noninteractive rates.

@item
Use of cone-casting or the like (as opposed to classical raytracing)
to allow relatively efficient rendering of scenes in large and/or
complex virtual worlds/universes.

@item
Use of "textures" or similar facilities as caches to re-use parts of
the scene rendering, perhaps those changing most slowly or most
distant:  One might render distant parts of the scene into texture
buffers and render those parts quite efficiently using many fewer
polygons than would otherwise be needed, recomputing the cache
textures and polygons periodically as required by changes in the
viewpoint and/or the background itself.

@item
Extension of such partly or wholly procedural world definitions to
describe very large universes, perhaps having billions or trillions
or more of galaxies, each perhaps containing similar numbers of worlds,
each perhaps containing similar numbers of nonplayer characters or other
inhabitants, and/or extension of world detail to very small scales,
potentially atomic or smaller.

@item
Similar construction of universes of other geometry but of similar scale.

@item
Extension partly or wholly procedural world definitions to time, such
that one can potentially travel freely through both time and space, and
find substantially the same scene at a given spacetime coordinate on
each visit.

@item
Extension of such procedural world definitions to include such
nongeometric world aspects as language, culture and literature.

@item
Use of permutation functions, spline functions, cyclic functions or the
like to allow motion of large numbers of objects in large and/or complex
procedurally defined universes while retaining the ability to render
local scenes relatively efficiently, in particular by locating the set
of objects within a restricted volume in time more like O(1) or O(logN)
than O(N).

@item
Construction of virtual worlds mirroring actual pre/history and/or geography.

@item
Political structuring of large virtual online communities as
heterogeneous trees, lattices or graphs.  The B-tree might
be particularly useful.  "CommuniTree" might be recycled as
a name for such a structure.

@item
Partial or wholly automating some administrative, legislative,
judicial and/or police functions (or the like) in online virtual
communities, such as by automating some portion of something like
Roberts Rules of Order, or providing copbots or such.

@item
Extending the mud concept to a heavily or wholly HTML (or similar
rich text format, or perhaps VRML or such) substrates (as opposed
to conventional plain text), perhaps via MIME or the like.

@item
Using the web as an interface to the mud, possibly via Java-based
mudclients:  mudserver as webserver.

@item
Similarly, using web facilities to store/generate some or all of a world
definition (or avatars or such):  mudserver as webclient.  E.g., virtual
libraries could be based on online resources such as the Gutenberg
Project, either delivered straight or perhaps processed so as to give
(say) the impression of a large library in an alien language.

@item
Introduction of neural-net style computations, perhaps to provide better
nonplayer characters or 'bots;  More generally, application of AI
concepts and tecniques virtual worlds and their contents.

@item
Use of hash functions as implicit representation of neural net
interconnects, perhaps to economize on time or space.

@item
Use of long scalar vectors to represent knowledge more robustly
than do classical boolean AI approaches, the scalars in question
being anything from bits through bytes and integers and floats
to complex or quaternion values, vector length optionally scaled
to unity or a similar standard values.

@item
Similar use of extremely long sparse vectors.

@item
Use of dotproduct (or similar, in particular linear) distance metric on
such or similar vector spaces, rather than the classical Euclidean
distance metric, perhaps to emphasize commonalities over differences in
the comnparison.

@item
Semi/balanced tree storage of such vectors, allowing storage
and/or retrieval of vectors in roughly log(N) time, and/or
retrieval of close match(es) to a query vector.

@item
Use of principal component analysis or the like to improve such
semi/balanced tree storage.

@item
Representation of the short-term memory of an automaton as such
vectors, optionally stored in such trees.

@item
Regular storage of such short-term states, perhaps in such a
tree, perhaps to provide automatic short-circuit of infinite
loops via recognition of recently visited states, or to
otherwise guide computation in the automaton.

@item
Understanding of relationship between data compression and
pattern recognition, in particular informed by information
theory.

@item
Understanding of pattern recognition as procedural data
compression, and in particular the quantitative application
of information-theoretic concepts and analysis.

@item
Application of such procedural data compression / pattern recognition to
knowledge bases and/or data bases, and in particular to such vector
databases -- and understanding of storing experience to memory as an
active computational task involving search and/or optimization, rather
than a passive recording task.

@item
Construction of an automaton using above-sketched sort of
compressed and/or processed vector db of past states under
dotproduct metric or the like to partly or wholly guide 
state transitions, perhaps to achieve flexible and/or robust
computation based on past experience.

@item
Induction of "midpoint" subgoal production rules in such a
context, to allow long-range plan construction in logarithmic
rather than linear time.

@item
Introduction of hardwired goal/happiness functions to supply
motivation to such or similar automata, perhaps as distinguished
input values in the input vector.

@item
Encoding of "motor" (effector, in the broad sense) outputs as distinguished
elements of the state vector, fitting output naturally into the central
state-transition mechanism of the automaton.

@item
Application of such automata to virtual worlds and/or
communities, possibly as nonplayer characters, impartial
authorities, help facilities or the like.

@item
Aggressive expansion of the existing exception-handling system into
a facility for routinely inspecting and guiding large and/or long-lived
computations, even in the absence of anything which would normally be
considered an error or exception, perhaps in the context of adaptation
of Muq to be a high-level framework for organizing such computations.

@item
Introduction of constructs midway between conventional avatars and
nonplayer characters: A user/visitor can "occupy" them and see the world
through their eyes, but has sharply limited control over their actions.
E.g., the construct might be driven by nondeterministic code defining
what its allowable ("in-character") behavior is, with the user allowed
to control/influence the nondeterministic choices made. 

@item
Understanding that any and all free parameters in virtual world
construction may be used symbolically as well as literally. For
example, any visible property whatever may be used to distinguish
a given object from its surroundings, drawing the user's attention
to it if the world designer so desires:  Hue, saturation, intensity,
level of detail, motion, specularity, opacity -- @emph{anything}.

@item
Understanding that apparent information flow is in general minimum
after initial noise and redundancy are removed from raw user input
and rise steadily thereafter, and hence that to maximize realtime
multiuser interaction rates in the face of communication bandwidth
bottlenecks, that the local world context needs to be duplicated
on each user-local machine, and communication largely limited to
propagation of lightly processed user input from other users in
the vicinity.

@item
Understanding that in general the Net is effectively special
relativistic:  "Simultaneous" doesn't exist except for events
physically close to each other, and software designs must
recognize this.

@item
Defining user identity directly in terms of a public key:  That
user -is- everyone who can sign messages relative to that key.

@end itemize


@c --    File variables                                                 */

@c Local variables:
@c mode: outline-minor
@c outline-regexp: "\\(@node +\\|@c -+\\)"
@c End:

