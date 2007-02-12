###############################################################################
#
# LaTeX::TOM (TeX Object Model)
#
# Version 0.05_02
#
# ----------------------------------------------------------------------------
#
# by Aaron Krowne (akrowne@vt.edu)
# July 2002
#
# Virginia Polytechnic Institute and State University
# Department of Computer Science
# Digital Libraries Research Laboratory
#
# ----------------------------------------------------------------------------
#
# This module provides some decent semantic handling of LaTeX documents. It is
# inspired by XML::DOM, so users of that module should be able to acclimate
# themselves to this one quickly.  Basically the subroutines in this package
# allow you to parse a LaTeX document into its logical structure, including
# groupings, commands, environments, and comments.  These all go into a tree
# which is built as arrays of Perl hashes.
#
###############################################################################

package LaTeX::TOM;

use strict;
use vars qw{%INNERCMDS %MATHENVS %MATHBRACKETS %MATHBRACKETS
            %BRACELESS %TEXTENVS $PARSE_ERRORS_FATAL};

use base qw(LaTeX::TOM::Parser);

our $VERSION = '0.5_02';

# BEGIN CONFIG SECTION ########################################################

# these are commands that can be "embedded" within a grouping to alter the
# environment of that grouping. For instance {\bf text}.  Without listing the 
# command names here, the parser will treat such sequences as plain text.
#
%INNERCMDS = (
 'bf' => 1, 
 'md' => 1, 
 'em' => 1, 
 'up' => 1, 
 'sl' => 1, 
 'sc' => 1, 
 'sf' => 1, 
 'rm' => 1, 
 'it' => 1, 
 'tt' => 1, 
 'noindent' => 1,
 'mathtt' => 1,
 'mathbf' => 1,
 'tiny' => 1,
 'scriptsize' => 1,
 'footnotesize' => 1,
 'small' => 1,
 'normalsize' => 1,
 'large' => 1,
 'Large' => 1,
 'LARGE' => 1,
 'huge' => 1,
 'Huge' => 1,
 'HUGE' => 1,
 );

# these commands put their environments into math mode
#
%MATHENVS = (
  'align' => 1,
  'equation' => 1, 
  'eqnarray' => 1, 
  'displaymath' => 1, 
  'ensuremath' => 1,
  'math' => 1,
  '$$' => 1, 
  '$' => 1, 
  '\[' => 1,
  '\(' => 1,
  );

# these commands/environments put their children in text (non-math) mode
#
%TEXTENVS = (
 'tiny' => 1,
 'scriptsize' => 1,
 'footnotesize' => 1,
 'small' => 1,
 'normalsize' => 1,
 'large' => 1,
 'Large' => 1,
 'LARGE' => 1,
 'huge' => 1,
 'Huge' => 1,
 'HUGE' => 1,
 'text' => 1, 
 'textbf' => 1, 
 'textmd' => 1, 
 'textsc' => 1, 
 'textsf' => 1, 
 'textrm' => 1, 
 'textsl' => 1, 
 'textup' => 1, 
 'texttt' => 1, 
 'mbox' => 1, 
 'fbox' => 1, 
 'section' => 1,
 'subsection' => 1,
 'subsubsection' => 1,
 'em' => 1,
 'bf' => 1,
 'emph' => 1,
 'it' => 1,
 'enumerate' => 1,
 'description' => 1,
 'itemize' => 1,
 'trivlist' => 1,
 'list' => 1,
 'proof' => 1,
 'theorem' => 1,
 'lemma' => 1,
 'thm' => 1,
 'prop' => 1,
 'lem' => 1,
 'table' => 1,
 'tabular' => 1,
 'tabbing' => 1,
 'caption' => 1,
 'footnote' => 1,
 'center' => 1,
 'flushright' => 1,
 'document' => 1,
 'article' => 1,
 'titlepage' => 1,
 'title' => 1,
 'author' => 1,
 'titlerunninghead' => 1,
 'authorrunninghead' => 1,
 'affil' => 1,
 'email' => 1,
 'abstract' => 1,
 'thanks' => 1,
 'algorithm' => 1,
 'nonumalgorithm' => 1,
 'references' => 1,
 'thebibliography' => 1,
 'bibitem' => 1,
 'verbatim' => 1,
 'verbatimtab' => 1,
 'quotation' => 1,
 'quote' => 1,
 );

# these form sets of simple mode delimiters
#
%MATHBRACKETS = (
    '$$' => '$$',
    '$' => '$',
# '\[' => '\]',   # these are problematic and handled separately now
# '\(' => '\)',
);

# these commands require no braces, and their parameters are simply the 
# "word" following the command declaration
#
%BRACELESS = (
 'oddsidemargin' => 1,
 'evensidemargin' => 1,
 'topmargin' => 1,
 'headheight' => 1,
 'headsep' => 1,
 'textwidth' => 1,
 'textheight' => 1,
 'input' => 1
);

# default value controlling how fatal parse errors are
#
#  0 = warn, 1 = die, 2 = silent
#
$PARSE_ERRORS_FATAL = 0;

# END CONFIG SECTION ##########################################################

sub new {
    my $self = shift;
    my $obj  = LaTeX::TOM::Parser->new(@_);

    $obj->{config}{BRACELESS}          = \%BRACELESS;
    $obj->{config}{INNERCMDS}          = \%INNERCMDS;
    $obj->{config}{MATHENVS}           = \%MATHENVS;
    $obj->{config}{MATHBRACKETS}       = \%MATHBRACKETS;
    $obj->{config}{PARSE_ERRORS_FATAL} = $PARSE_ERRORS_FATAL;
    $obj->{config}{TEXTENVS}           = \%TEXTENVS;

    return $obj;
}

1;

=head1 NAME

LaTeX::TOM - A module for parsing, analyzing, and manipulating LaTeX documents.

=head1 SYNOPSIS

  use LaTeX::TOM;

  my $parser = LaTeX::TOM->new;

  my $document = $parser->parseFile('mypaper.tex');

  my $latex = $document->toLaTeX;

  my $specialnodes = $document->getNodesByCondition(
    '$node->getNodeType eq \'TEXT\' && 
     $node->getNodeText =~ /magic string/');

  my $sections = $document->getNodesByCondition(
    '$node->getNodeType eq \'COMMAND\' &&
     $node->getCommandName =~ /section$/');

  my $indexme = $document->getIndexableText;

  $document->print;

=head1 DESCRIPTION

This module provides a parser which parses and interprets (though not fully)
LaTeX documents and returns a tree-based representation of what it finds.
This tree is a LaTeX::TOM::Tree.  The tree contains LaTeX::TOM:Node nodes.

This module should be especially useful to anyone who wants to do processing
of LaTeX documents that requires extraction of plain-text information, or
altering of the plain-text components (or alternatively, the math-text
components).

=head1 COMPONENTS

=head2 LaTeX::TOM::Parser

The parser recognizes 3 parameters upon creation.  The parameters, in order, are 

=over 4

=item parse error handling (= B<0> || 1 || 2)

Determines what happens when a parse error is encountered.  0 results in a
warning.  1 results in a die.  2 results in silence.  Note that particular
groupings in LaTeX (i.e. newcommands and the like) contain invalid TeX or
LaTeX, so you nearly always need this parameter to be 0 or 2 to completely
parse the document.

=item read inputs flag (= 0 || B<1>)

This flag determines whether a scan for \input and \input-like commands is
performed, and the resulting called files parsed and added to the parent
parse tree.  0 means no, 1 means do it.  Note that this will happen recursively
if it is turned on.  Also, bibliographies (.bbl files) are detected and
included.

=item apply mappings flag (= 0 || B<1>)

This flag determines whether (most) user-defined mappings are applied.  This
means \defs, \newcommands, and \newenvironments.  This is critical for properly
analyzing the content of the document, as this must be phrased in terms of the
semantics of the original TeX and LaTeX commands, not ad hoc user macros.  So,
for instance, do not expect plain-text extraction to work properly with this
option off.

=back

The parser returns a LaTeX::TOM::Tree ($document in the SYNOPSIS).

=head2 LaTeX::TOM::Node

Nodes may be of the following types:

=over 4 

=item TEXT 

TEXT nodes can be thought of as representing the plain-text portions of the
LaTeX document.  This includes math and anything else that is not a recognized
TeX or LaTeX command, or user-defined command.  In reality, TEXT nodes contain
commands that this parser does not yet recognize the semantics of.

=item COMMAND

A COMMAND node represents a TeX command.  It always has child nodes in a tree,
though the tree might be empty if the command operates on zero parameters. An
example of a command is

  \textbf{blah}

This would parse into a COMMAND node for I<textbf>, which would have a subtree
containing the TEXT node with text ``blah.''

=item ENVIRONMENT

Similarly, TeX environments parse into ENVIRONMENT nodes, which have metadata
about the environment, along with a subtree representing what is contained in
the environment.  For example,

  \begin{equation}
    r = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
  \end{equation}

Would parse into an ENVIRONMENT node of the class ``equation'' with a child 
tree containing the result of parsing ``r = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}.''

=item GROUP

A GROUP is like an anonymous COMMAND.  Since you can put whatever you want in
curly-braces ({}) in TeX in order to make semantically isolated regions, this
separation is preserved by the parser.  A GROUP is just the subtree of the
parsed contents of plain curly-braces.

It is important to note that currently only the first GROUP in a series of
GROUPs following a LaTeX command will actually be parsed into a COMMAND node.
The reason is that, for the initial purposes of this module, it was not
necessary to recognize additional GROUPs as additional parameters to the
COMMAND.  However, this is something that this module really should do
eventually.  Currently if you want all the parameters to a multi-parametered
command, you'll need to pick out all the following GROUP nodes yourself.

Eventually this will become something like a list which is stored in the 
COMMAND node, much like XML::DOM's treatment of attributes.  These are, in a
sense, apart from the rest of the document tree.  Then GROUP nodes will become
much more rare.

=item COMMENT

A COMMENT node is very similar to a TEXT node, except it is specifically for 
lines beginning with ``%'' (the TeX comment delimeter) or the right-hand 
portion of a line that has ``%'' at some internal point.

=back

=head2 LaTeX::TOM::Trees

As mentioned before, the Tree is the return result of a parse.

The tree is nothing more than an arrayref of Nodes, some of which may contain
their own trees.  This is useful knowledge at this point, since the user isn't
provided with a full suite of convenient tree-modification methods.  However,
Trees do already have some very convenient methods, described in the next
section.

=head1 METHODS

=head2 LaTeX::TOM

=over 4

=item new

Instantiate a new parser object.

=back

In this section all of the methods for each of the components are listed and
described.

=head2 LaTeX::TOM::Parser

The methods for the parser (aside from the constructor, discussed above) are :

=over 4

=item parseFile (filename)

Read in the contents of I<filename> and parse them, returning a LaTeX::TOM:Tree.

=item parse (string)

Parse the string I<string> and return a LaTeX::TOM::Tree.

=back

=head2 LaTeX::TOM::Tree

This section contains methods for the Trees returned by the parser.

=over 4

=item copy

Duplicate a tree into new memory.

=item print

A debug print of the structure of the tree.

=item plainText

Returns an arrayref which is a list of strings representing the text of all
getNodePlainTextFlag = 1 TEXT nodes, in an inorder traversal.

=item indexableText

A method like the above but which goes one step further; it cleans all of the
returned text and concatenates it into a single string which one could consider
having all of the standard information retrieval value for the document,
making it useful for indexing.

=item toLaTeX

Return a string representing the LaTeX encoded by the tree.  This is especially
useful to get a normal document again, after modifying nodes of the tree.

=item getTopLevelNodes

Return an arrayref which is a list of LaTeX::TOM::Nodes at the top level of
the Tree.

=item getAllNodes

Return an arrayref with B<all> nodes of the tree.  This "flattens" the tree.

=item getCommandNodesByName (name)

Return an arrayref with all COMMAND nodes in the tree which have a name
matching I<name>.

=item getEnvironmentsByName (name)

Return an arrayref with all ENVIRONMENT nodes in the tree which have a class
matching I<name>.

=item getNodesByCondition (expression)

This is a catch-all search method which can be used to pull out nodes that
match pretty much any perl expression, without manually having to traverse the
tree.  I<expression> is a valid perl expression which makes reference to the
perl variable B<$node> when testing something about the currently scrutinized
node of the tree.  See the SYNOPSIS for examples.

=back

=head2 LaTeX::TOM::Node

This section contains the methods for nodes of the parsed Trees.

=over 4

=item getNodeType

Returns the type, one of 'TEXT', 'COMMAND', 'ENVIRONMENT', 'GROUP', or 'COMMENT', 
as described above.

=item getNodeText

Applicable for TEXT or COMMENT nodes; this returns the document text they contain.  
This is undef for other node types.

=item setNodeText

Set the node text, also for TEXT and COMMENT nodes.

=item getNodeStartingPosition

Get the starting character position in the document of this node.  For TEXT
and COMMENT nodes, this will be where the text begins.  For ENVIRONMENT,
COMMAND, or GROUP nodes, this will be the position of the I<last> character of
the opening identifier.

=item getNodeEndingPosition

Same as above, but for last character.  For GROUP, ENVIRONMENT, or COMMAND 
nodes, this will be the I<first> character of the closing identifier.

=item getNodeOuterStartingPosition

Same as getNodeStartingPosition, but for GROUP, ENVIRONMENT, or COMMAND nodes,
this returns the I<first> character of the opening identifier.

=item getNodeOuterEndingPosition

Same as getNodeEndingPosition, but for GROUP, ENVIRONMENT, or COMMAND nodes,
this returns the I<last> character of the closing identifier.

=item getNodeMathFlag

This applies to any node type.  It is 1 if the node sets, or is contained
within, a math mode region.  0 otherwise.  TEXT nodes which have this flag as 1
can be assumed to be the actual mathematics contained in the document.

=item getNodePlainTextFlag

This applies only to TEXT nodes.  It is 1 if the node is non-math B<and> is
visible (in other words, will end up being a part of the output document). One
would only want to index TEXT nodes with this property, for information 
retrieval purposes.

=item getEnvironmentClass

This applies only to ENVIRONMENT nodes.  Returns what class of environment the
node represents (the X in \begin{X} and \end{X}).

=item getCommandName

This applies only to COMMAND nodes.  Returns the name of the command (the X in
\X{...}).

=item getChildTree

This applies only to COMMAND, ENVIRONMENT, and GROUP nodes: it returns the
LaTeX::TOM::Tree which is ``under'' the calling node.

=item getFirstChild

This applies only to COMMAND, ENVIRONMENT, and GROUP nodes: it returns the
first node from the first level of the child subtree.

=item getLastChild

Same as above, but for the last node of the first level.

=item getPreviousSibling

Return the prior node on the same level of the tree.

=item getNextSibling 

Same as above, but for following node.

=item getParent

Get the parent node of this node in the tree.

=item getNextGroupNode

This is an interesting function, and kind of a hack because of the way the
parser makes the current tree.  Basically it will give you the next sibling
that is a GROUP node, until it either hits the end of the tree level, a TEXT
node which doesn't match /^\s*$/, or a COMMAND node.

This is useful for finding all GROUPed parameters after a COMMAND node (see
comments for 'GROUP' in the 'COMPONENTS' / 'LaTeX::TOM::Node' section).  You
can just have a while loop that calls this method until it gets 'undef', and
you'll know you've found all the parameters to a command.

Note: this may be bad, but TEXT Nodes matching /^\s*\[[0-9]+\]$/ (optional
parameter groups) are treated as if they were 'blank'.

=back

=head1 CAVEATS

Due to the lack of tree-modification methods, currently this module is
mostly useful for minor modifications to the parsed document, for instance,
altering the text of TEXT nodes but not deleting the nodes.  Of course, the
user can still do this by breaking abstraction and directly modifying the Tree.

Also note that the parsing is not complete.  This module was not written with
the intention of being able to produce output documents the way ``latex'' does.
The intent was instead to be able to analyze and modify the document on a 
logical level with regards to the content; it doesn't care about the document
formatting and outputting side of TeX/LaTeX.

There is much work still to be done.  See the TODO list in the TOM.pm source.

=head1 BUGS

Probably plenty.  However, this module has performed fairly well on a set of
~1000 research publications from the Computing Research Repository, so I
deemed it ``good enough'' to use for purposes similar to mine.

Please let me know of parser errors if you discover any.

=head1 AUTHOR

Written by Aaron Krowne <akrowne@vt.edu>

Maintained by Steven Schubiger <schubiger@cpan.org>

=head1 WEB SITE

Please see http://br.endernet.org/~akrowne/elaine/latex_tom/ for this 
module's home on the WWW.

=cut
