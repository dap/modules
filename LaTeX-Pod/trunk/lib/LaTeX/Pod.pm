package LaTeX::Pod;

use strict;
use warnings;

use Carp qw(croak);
use LaTeX::TOM;

our $VERSION = '0.09_01';

sub new {
    my ($self, $file) = @_;

    my $class = ref($self) || $self;
    croak "$file: $!" unless -f $file;

    return bless _init_self({ file => $file }), $class;
}

sub convert {
    my $self = shift;

    my $nodes = $self->_init_tom;

    foreach my $node (@$nodes) {
        $self->{current_node} = $node;
        my $type = $node->getNodeType;

        if ($type =~ /TEXT|COMMENT/) {
            next if $node->getNodeText !~ /\w+/
                 or $node->getNodeText =~ /^\\\w+$/m
                 or $self->_process_directives;

            my $dispatched;
            foreach my $dispatch (@{$self->{dispatch_text}}) {
                if (eval $dispatch->[0]) {
                    eval $dispatch->[1];
                    $dispatched++;
               }
            }
        } elsif ($type =~ /ENVIRONMENT/) {
            $self->_process_verbatim;
        } elsif ($type =~ /COMMAND/) {
            $self->_unregister_previous('verbatim');
            my $cmd_name = $node->getCommandName;

            foreach my $dispatch (@{$self->{dispatch_command}}) {
                if (eval $dispatch->[0]) {
                    eval $dispatch->[1];
                }
            }
        }
    }

    $self->_pod_finalize;

    return $self->_pod_get;
}

sub _init_self {
    my $opts = shift;

    my %opts;

    $opts{file}      = $opts->{file};
    $opts{title_inc} = 1;

    @{$opts{dispatch_text}} = (
        [ q{$self->_is_set_node('title')},    q{$self->_process_text_title}     ],
        [ q{$self->_is_set_node('verbatim')}, q{$self->_process_text_verbatim}  ],
        [ q{$node->getNodeText =~ /\\\item/}, q{$self->_process_text_item}      ],
        [ q{$self->_is_set_node('textbf')},   q{$self->_process_tags('textbf')} ],
        [ q{$self->_is_set_node('textsf')},   q{$self->_process_tags('textsf')} ],
        [ q{$self->_is_set_node('emph')},     q{$self->_process_tags('emph')}   ],
        [ q{!$dispatched},                    q{$self->_process_text}           ],
    );

    @{$opts{dispatch_command}} = (
        [ q{$self->_is_set_previous('item')},                   q{$self->_process_item}               ],
        [ q{$cmd_name eq 'chapter'},                            q{$self->_process_chapter}            ],
        [ q{$cmd_name eq 'section'},                            q{$self->_process_section}            ],
        [ q{$cmd_name =~ /subsection/},                         q{$self->_process_subsection}         ],
        [ q{$cmd_name =~ /documentclass|usepackage|pagestyle/}, q{$self->_register_node('directive')} ],
        [ q{$cmd_name eq 'title'},                              q{$self->_register_node('doctitle')}  ],
        [ q{$cmd_name eq 'author'},                             q{$self->_register_node('docauthor')} ],
        [ q{$cmd_name =~ /textbf|textsf|emph/},                 q{$self->_register_node($cmd_name)}   ],
    );

    return \%opts;
}

sub _init_tom {
    my $self = shift;

    # silently discard warnings about unparseable latex
    my $parser = LaTeX::TOM->new(2);
    my $document = $parser->parseFile($self->{file});
    my $nodes = $document->getAllNodes;

    return $nodes;
}

sub _process_directives {
    my $self = shift;

    if ($self->_is_set_node('directive')) {
        $self->_unregister_node('directive');
        return 1;
    } elsif ($self->_is_set_node('doctitle')) {
        $self->_unregister_node('doctitle');
        $self->_pod_add("=head1 ".$self->{current_node}->getNodeText);
        $self->{title_inc}++;
        return 1;
    } elsif ($self->_is_set_node('docauthor')) {
        $self->_unregister_node('docauthor');
        return 1;
    }

    return 0;
}

sub _process_text_title {
    my $self = shift;

    if ($self->_is_set_previous('item')) {
        $self->_pod_add("=back\n\n");
    }

    my $text = $self->{current_node}->getNodeText;

    $self->_process_spec_chars(\$text);

    $self->_pod_add("$text\n");

    $self->_unregister_node('title');
    $self->_register_previous('title');
}

sub _process_text_verbatim {
    my $self = shift;

    my $text = $self->{current_node}->getNodeText;

    unless ($self->_is_set_previous('verbatim')) {
        $text =~ s/^\n//s;
        $text =~ s/\n$//s if $text =~ /\n{2,}$/;
    }

    unless ($self->_is_set_previous([qw(verbatim item text)])) {
        $text .= "\n";
    }

    if ($self->_is_set_previous('text')) {
        $text =~ s/^(.*)$/\ $1/gm;
    } else {
        $text =~ s/(.*)/\n$1/;
    }

    $self->_process_spec_chars(\$text);

    $self->_pod_add("$text\n");

    $self->_unregister_node('verbatim');
    $self->_unregister_previous('title');
    $self->_register_previous('verbatim');
}

sub _process_text_item {
    my $self = shift;

    unless ($self->_is_set_previous('item')) {
        $self->_pod_add("\n\n=over 4\n\n");
    }

    my $text = $self->{current_node}->getNodeText;

    if ($text =~ /\\item\s*\[.*?\]/) {
        $text =~ s/\\item\s*\[(.*?)\](.*)/\=item $1\n$2/g;
    } else {
        $text =~ s/\\item\s*(.*)/\=item \n\n$1/g;
    }

    $text =~ s/^(?:\n)|(?:\n)$//g;

    $self->_process_spec_chars(\$text);
    $self->_pod_add($text);
    $self->_register_previous('item');
}

sub _process_text {
    my $self = shift;

    my $text = $self->{current_node}->getNodeText;

    $self->_process_spec_chars(\$text);
    $self->_pod_add($text);
    $self->_register_previous('text');
}

sub _process_verbatim {
    my $self = shift;

    $self->_unregister_previous('verbatim');

    if ($self->{current_node}->getEnvironmentClass eq 'verbatim') {
        $self->_register_node('verbatim');
    }
}

sub _process_item {
    my $self = shift;

    unless ($self->{current_node}->getCommandName eq 'mbox') {
        if ($self->_is_set_previous('item')) {
            $self->_pod_add("\n=back\n");
        }

        $self->_pod_add("\n");
        $self->_unregister_previous('item');
    }
}

sub _process_chapter {
    my $self = shift;

    if ($self->_is_set_previous('title')) {
        $self->_unregister_previous('title');
    }

    $self->{title_inc}++;

    $self->_pod_add("\n\n=head1 ");
    $self->_register_node('title');
}

sub _process_section {
    my $self = shift;

    if ($self->_is_set_previous([qw(title item text)])) {
        $self->_pod_add("\n\n");
        $self->_unregister_previous([qw(title item text)]);
    }

    $self->_pod_add("\n\n=head".$self->{title_inc}.' ');
    $self->_register_node('title');
}

sub _process_subsection {
    my $self = shift;

    my $sub_often;
    my $var = $self->{current_node}->getCommandName;

    while ($var =~ s/sub(.*)/$1/g) {
        $sub_often++;
    }

    if ($self->_is_set_previous([qw(title text verbatim)])) {
        $self->_pod_add("\n");
        $self->_unregister_previous([qw(title text verbatim)]);
    }

    $self->_pod_add("\n\n=head".($self->{title_inc} + $sub_often).' ');
    $self->_register_node('title');
}

sub _process_spec_chars {
    my ($self, $text) = @_;

    my %umlauts = (a => 'ä',
                   A => 'Ä',
                   u => 'ü',
                   U => 'Ü',
                   o => 'ö',
                   O => 'Ö');

    while (my ($from, $to) = each %umlauts) {
        $$text =~ s/\\\"$from/$to/g;
    }

    $$text =~ s/\\_/\_/g;
    $$text =~ s/\\\$/\$/g;

    $$text =~ s/\\verb(.)(.*?)\1/C<$2>/g;
    $$text =~ s/\\newline//g;
}

sub _process_tags {
    my ($self, $tag) = @_;

    my $text = $self->{current_node}->getNodeText;

    my %tags = (textbf => 'B',
                textsf => 'C',
                emph   => 'I');

    $self->_pod_add("$tags{$tag}<$text>");
    $self->_unregister_node($tag);
}

sub _pod_add {
    my ($self, $content) = @_;
    $self->{pod} .= $content;
}

sub _pod_finalize {
    my $self = shift;

    $self->_pod_add('=cut');

    my $pod = $self->_pod_get;
    $pod =~ s/\n{2,}/\n\n/g;
    $self->_pod_set($pod);
}

sub _pod_get {
    my $self = shift;
    return $self->{pod};
}

sub _pod_set {
    my ($self, $pod) = @_;
    $self->{pod} = $pod;
}

sub _register_node {
    my ($self, $item) = @_;
    $self->{node}{$item} = 1;
}

sub _is_set_node {
    my ($self, $item) = @_;
    return $self->{node}{$item} ? 1 : 0;
}

sub _unregister_node {
    my ($self, $item) = @_;
    delete $self->{node}{$item};
}

sub _register_previous {
    my ($self, $item) = @_;
    $self->{previous}{$item} = 1;
}

sub _is_set_previous {
    my ($self, $item) = @_;
    my @items = ref($item) eq 'ARRAY' ? @$item : ($item);
    foreach my $item_single (@items) {
        if ($self->{previous}{$item_single}) {
            return 1;
        }
    }
    return 0;
}

sub _unregister_previous {
    my ($self, $item) = @_;
    my @items = ref($item) eq 'ARRAY' ? @$item : ($item);
    foreach my $item_single (@items) {
        if ($self->{previous}{$item_single}) {
            delete $self->{previous}{$item_single};
        }
    }
}

=head1 NAME

LaTeX::Pod - Transform LaTeX source files to POD (Plain old documentation)

=head1 SYNOPSIS

 use LaTeX::Pod;

 my $parser = LaTeX::Pod->new('/path/to/latex/source');
 print $parser->convert;

=head1 DESCRIPTION

C<LaTeX::Pod> converts LaTeX sources to Perl's POD (Plain old documentation)
format. Currently only a subset of the available LaTeX language is suppported -
see below for detailed information.

=head1 CONSTRUCTOR

=head2 new

The constructor requires that the path to the latex source must be declared:

 $parser = LaTeX::Pod->new('/path/to/latex/source');

Returns the parser object.

=head1 METHODS

=head2 convert

There is only one public method available, C<convert>:

 $parser->convert;

Returns the POD document as string.

=head1 SUPPORTED LANGUAGE SUBSET

It's not much, but there's more to come:

=over 4

=item * chapters

=item * sections/subsections/subsub...

=item * verbatim blocks

=item * itemized lists

=item * plain text

=item * bold/italic/code font tags

=item * umlauts

=back

=head1 IMPLEMENTATION DETAILS

The current implementation is a bit I<flaky> because C<LaTeX::TOM>, the framework
being used for parsing the LaTeX nodes, makes a clear distinction between various
types of nodes. As example, an \item directive has quite often a separate text which
is associated with former one. And they can't be detected without some kind of
sophisticated "lookahead".

I tried to implement a I<context-sensitive> awareness for C<LaTeX::Pod>. I did so
by setting which node has been seen before the current one in order to be able to
call the appropriate routine for a LaTeX directive with two or more nodes.
Furthermore, C<LaTeX::Pod> registers which node it has previously encountered
and unregisters this information when it made use of it.

Considering that the POD language has a limited subset of commands, the overhead
of keeping track of node occurences seems almost bearable. The POD generated 
may consist of too many newlines (because we can't always predict the unpredictable?)
before undergoing the final scrubbing where more than two subsequent newlines
will be truncated.

=head1 SEE ALSO

L<LaTeX::TOM>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
