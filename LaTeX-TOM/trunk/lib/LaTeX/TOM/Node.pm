###############################################################################
#
# LaTeX::TOM::Node
#
# This package defines an object for nodes in the TOM tree, and methods to go
# with them.
#
###############################################################################

package LaTeX::TOM;

use strict;

# Make a new Node: turn input hash into object.
#
sub Node::new {
    my $class = shift; 
    my $node = shift || {};

    return bless $node, $class;
}

# "copy constructor"
#
sub Node::copy {
    my $node = shift;

    my $copynode = {%$node}; # copy the memory contents and get a pointer

    return bless $copynode;
}

# Split a text node into two text nodes, with the first ending before point a,
# and the second starting after point b. actually returns NEW nodes, does not
# alter the input node.
#
# Note: a and b are relative to the contents of the node, not the original
# document.
#
# Note2: a and b are not jointly constrained. You can split after location x
# without losing any characters by setting a = x + 1 and b = x.
#
sub Node::split {
    my $node = shift;
    my $a = shift;
    my $b = shift;

    return (undef, undef) if ($node->{type} ne 'TEXT');

    my $lefttext = substr $node->{content}, 0, $a;
    my $righttext = substr $node->{content}, $b + 1, length($node->{content}) - $b;

    my $leftnode = Node->new(
        {type => 'TEXT',
         start => $node->{start},
         end => $node->{start} + $a -1,
         content => $lefttext});

    my $rightnode = Node->new(
        {type => 'TEXT',
         start => $node->{start} + $b + 1,
         end => $node->{start} + length($node->{content}),
         content => $righttext});

    return ($leftnode, $rightnode);
}

#
# accessor methods
#

sub Node::getNodeType {
    my $node = shift;

    return $node->{type};
}

sub Node::getNodeText {
    my $node = shift;

    return $node->{content};
}

sub Node::setNodeText {
    my $node = shift;
    my $text = shift;

    $node->{content} = $text;
}

sub Node::getNodeStartingPosition {
    my $node = shift;

    return $node->{start};
}

sub Node::getNodeEndingPosition {
    my $node = shift;

    return $node->{end};
}

sub Node::getNodeMathFlag {
    my $node = shift;

    return $node->{math} ? 1 : 0;
}

sub Node::getNodePlainTextFlag {
    my $node = shift;

    return $node->{plaintext} ? 1 : 0;
}

sub Node::getNodeOuterStartingPosition {
    my $node = shift;

    return (defined $node->{ostart} ? $node->{ostart} : $node->{start});
}

sub Node::getNodeOuterEndingPosition {
    my $node = shift;

    return (defined $node->{oend} ? $node->{oend} : $node->{end});
}

sub Node::getEnvironmentClass {
    my $node = shift;

    return $node->{class};
}

sub Node::getCommandName {
    my $node = shift;

    return $node->{command};
}

#
# linked-list accessors
#

sub Node::getChildTree {
    my $node = shift;

    return $node->{children};
}

sub Node::getFirstChild {
    my $node = shift;

    if ($node->{children}) {
        return $node->{children}->[0];
    }

    return undef;
}

sub Node::getLastChild {
    my $node = shift;

    if ($node->{children}) {
        return $node->{children}->[scalar @{$node->{children}} - 1];
    }

    return undef;
}

sub Node::getPreviousSibling {
    my $node = shift;

    return $node->{prev};
}

sub Node::getNextSibling {
    my $node = shift;

    return $node->{'next'};
}

sub Node::getParent {
    my $node = shift;

    return $node->{parent};
}

# This is an interesting function, and kind of a hack because of the way the
# parser makes the current tree. Basically it will give you the next sibling
# that is a GROUP node, until it either hits the end of the tree level, a TEXT
# node which doesn't match /^\s*$/, or a COMMAND node.
#
# This is useful for finding all GROUPed parameters after a COMMAND node. You
# can just have a while loop that calls this method until it gets 'undef'.
#
# Note: this may be bad, but TEXT Nodes matching /^\s*\[[0-9]+\]$/ (optional
# parameter groups) are treated as if they were whitespace.
#
sub Node::getNextGroupNode {
    my $node = shift;

    my $next = $node;
    while ($next = $next->{'next'}) {

        # found a GROUP node.
        if ($next->{type} eq 'GROUP') {
            return $next;
        }

        # see if we should skip a node
        elsif ($next->{type} eq 'COMMENT' ||
                ($next->{type} eq 'TEXT' &&
                ($next->{content} =~ /^\s*$/ ||
                 $next->{content} =~ /^\s*\[\s*[0-9]+\s*\]\s*$/
                ))) {

            next;
        }

        else {
            return undef;
        }
    }

    return undef;
}

1;
