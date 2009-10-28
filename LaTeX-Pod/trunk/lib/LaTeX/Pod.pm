package LaTeX::Pod;

use strict;
use warnings;
use boolean qw(true false);

use Carp qw(croak);
use LaTeX::TOM ();
use Params::Validate ':all';

our $VERSION = '0.20';

validation_options(
    on_fail => sub
{
    my ($error) = @_;
    chomp $error;
    croak $error;
},
    stack_skip => 2,
);

sub new
{
    my $class = shift;

    my $self = bless {}, ref($class) || $class;

    $self->_init_check(@_);
    $self->_init(@_);

    return $self;
}

sub convert
{
    my $self = shift;

    my $nodes = $self->_init_tom;

    foreach my $node (@$nodes) {
        $self->{current_node} = $node;
        my $type = $node->getNodeType;

        if ($type =~ /^(?:TEXT|COMMENT)$/) {
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
        }
        elsif ($type eq 'ENVIRONMENT') {
            $self->_process_verbatim;
        }
        elsif ($type eq 'COMMAND') {
            $self->_unregister_previous('verbatim');
            my $cmd_name = $node->getCommandName;

            foreach my $dispatch (@{$self->{dispatch_command}}) {
                if (eval $dispatch->[0]) {
                    eval $dispatch->[1];
                }
            }
        }
    }

    return $self->_pod_finalize;
}

sub _init_check
{
    my $self = shift;

    validate_pos(@_, { type => SCALAR });

    my ($file) = @_;
    my $error = sub
    {
        return 'does not exist' unless -e shift;
        return 'is not a file'  unless -f _;
        return 'is empty'       unless -s _;
        return                            undef;

    }->($file);

    defined $error and croak "Cannot open `$file': $error";
}

sub _init
{
    my $self = shift;
    my ($file) = @_;

    $self->{file} = $file;
    $self->{title_inc} = 1;

    @{$self->{dispatch_text}} = (
        [ q{$self->_is_set_node('title')},    q{$self->_process_text_title}     ],
        [ q{$self->_is_set_node('verbatim')}, q{$self->_process_text_verbatim}  ],
        [ q{$node->getNodeText =~ /\\\item/}, q{$self->_process_text_item}      ],
        [ q{$self->_is_set_node('textbf')},   q{$self->_process_tags('textbf')} ],
        [ q{$self->_is_set_node('textsf')},   q{$self->_process_tags('textsf')} ],
        [ q{$self->_is_set_node('emph')},     q{$self->_process_tags('emph')}   ],
        [ q{!$dispatched},                    q{$self->_process_text}           ],
    );

    @{$self->{dispatch_command}} = (
        [ q{$self->_is_set_previous('item')},                   q{$self->_process_item}               ],
        [ q{$cmd_name eq 'chapter'},                            q{$self->_process_chapter}            ],
        [ q{$cmd_name eq 'section'},                            q{$self->_process_section}            ],
        [ q{$cmd_name =~ /subsection/},                         q{$self->_process_subsection}         ],
        [ q{$cmd_name =~ /documentclass|usepackage|pagestyle/}, q{$self->_register_node('directive')} ],
        [ q{$cmd_name eq 'title'},                              q{$self->_register_node('doctitle')}  ],
        [ q{$cmd_name eq 'author'},                             q{$self->_register_node('docauthor')} ],
        [ q{$cmd_name =~ /textbf|textsf|emph/},                 q{$self->_register_node($cmd_name)}   ],
    );
}

sub _init_tom
{
    my $self = shift;

    # silently discard warnings about unparseable LaTeX
    my $parser   = LaTeX::TOM->new(2);
    my $document = $parser->parseFile($self->{file});
    my $nodes    = $document->getAllNodes;

    return $nodes;
}

sub _process_directives
{
    my $self = shift;

    foreach my $node qw(directive docauthor) {
        if ($self->_is_set_node($node)) {
            $self->_unregister_node($node);

            return true;
        }
    }

    if ($self->_is_set_node('doctitle')) {
        $self->_unregister_node('doctitle');

        $self->_pod_add('=head1 '.$self->{current_node}->getNodeText);
        $self->{title_inc}++;

        return true;
    }

    return false;
}

sub _process_text_title
{
    my $self = shift;

    if ($self->_is_set_previous('item')) {
        $self->_pod_add('=back');
    }

    my $text = $self->{current_node}->getNodeText;

    $self->_process_spec_chars(\$text);

    $self->_pod_append($text);

    $self->_unregister_node('title');
    $self->_register_previous('title');
}

sub _process_text_verbatim
{
    my $self = shift;

    my $text = $self->{current_node}->getNodeText;

    my $len;
    while ($text =~ /^(\ *?)\w/gm) {
        $len = length $1;
        last if $len >= 0;
    }

    if ($self->_is_set_previous('text')) {
        $self->_pod_scrub_whitespaces(\$text);

        if ($len) {
            $text = ' ' x $len . $text;
        }
        else {
            $text =~ s/^(.*)$/\ $1/gm;
        }
    }
    else {
        $self->_pod_scrub_newlines(\$text);
    }

    $self->_process_spec_chars(\$text);

    $self->_pod_add($text);

    $self->_unregister_node('verbatim');
    $self->_unregister_previous('title');
    $self->_unregister_previous('text');
    $self->_register_previous('verbatim');
}

sub _process_text_item
{
    my $self = shift;

    unless ($self->_is_set_previous('item')) {
        $self->_pod_add('=over 4');
    }

    my $text = $self->{current_node}->getNodeText;

    if ($text =~ /\\item\s*\[(.*?)\]/) {
        $self->_pod_add("=item $1");
    }
    else {
        $self->_pod_add('=item');
    }

    $self->_pod_scrub_newlines(\$text);
    $self->_process_spec_chars(\$text);

    $self->_register_previous('item');
}

sub _process_text
{
    my $self = shift;

    my $text = $self->{current_node}->getNodeText;

    $self->_process_spec_chars(\$text);

    $self->_pod_scrub_newlines(\$text);
    $self->_pod_add($text);

    $self->_register_previous('text');
}

sub _process_verbatim
{
    my $self = shift;

    $self->_unregister_previous('verbatim');

    if ($self->{current_node}->getEnvironmentClass eq 'verbatim') {
        $self->_register_node('verbatim');
    }
}

sub _process_item
{
    my $self = shift;

    unless ($self->{current_node}->getCommandName eq 'mbox') {
        if ($self->_is_set_previous('item')) {
            $self->_pod_add('=back');
        }

        $self->_unregister_previous('item');
    }
}

sub _process_chapter
{
    my $self = shift;

    $self->{title_inc}++;

    $self->_pod_add('=head1 ');
    $self->_register_node('title');
}

sub _process_section
{
    my $self = shift;

    $self->_pod_add('=head'.$self->{title_inc}.' ');
    $self->_register_node('title');
}

sub _process_subsection
{
    my $self = shift;

    my $sub_often;
    my $var = $self->{current_node}->getCommandName;

    while ($var =~ s/sub(.*)/$1/g) {
        $sub_often++;
    }

    $self->_pod_add('=head'.($self->{title_inc} + $sub_often).' ');
    $self->_register_node('title');
}

sub _process_spec_chars
{
    my $self = shift;
    my ($text) = @_;

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

sub _process_tags
{
    my $self = shift;
    my ($tag) = @_;

    my $text = $self->{current_node}->getNodeText;

    my %tags = (textbf => 'B',
                textsf => 'C',
                emph   => 'I');

    $self->{append_following} = true;

    $self->_pod_append("$tags{$tag}<$text>");
    $self->_unregister_node($tag);
}

sub _pod_add
{
    my $self = shift;
    my ($content) = @_;

    if (!$self->{append_following}) {
        push @{$self->{pod}}, $content;
    }
    else {
        $self->_pod_append($content);
        $self->{append_following} = false;
    }
}

sub _pod_append
{
    my $self = shift;
    my ($content) = @_;

    $self->{pod}->[-1] .= $content;
}

sub _pod_scrub_newlines
{
    my $self = shift;
    my ($text) = @_;

    $$text =~ s/^\n*//;
    $$text =~ s/\n*$//;
}

sub _pod_scrub_whitespaces
{
    my $self = shift;
    my ($text) = @_;

    $$text =~ s/^\s*//;
    $$text =~ s/\s*$//;
}

sub _pod_get
{
    my $self = shift;

    return $self->{pod};
}

sub _pod_finalize
{
    my $self = shift;

    $self->_pod_add("=cut\n");

    return join "\n\n", @{$self->_pod_get};
}

sub _register_node
{
    my $self = shift;
    my ($item) = @_;

    $self->{node}{$item} = true;
}

sub _is_set_node
{
    my $self = shift;
    my ($item) = @_;

    return $self->{node}{$item} ? true : false;
}

sub _unregister_node
{
    my $self = shift;
    my ($item) = @_;

    delete $self->{node}{$item};
}

sub _register_previous
{
    my $self = shift;
    my ($item) = @_;

    $self->{previous}{$item} = true;
}

sub _is_set_previous
{
    my $self = shift;
    my ($item) = @_;

    my @items = ref $item eq 'ARRAY' ? @$item : ($item);

    foreach my $item_single (@items) {
        if ($self->{previous}{$item_single}) {
            return true;
        }
    }

    return false;
}

sub _unregister_previous
{
    my $self = shift;
    my ($item) = @_;

    my @items = ref $item eq 'ARRAY' ? @$item : ($item);

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

 $parser = LaTeX::Pod->new('/path/to/source');
 print $parser->convert;

=head1 DESCRIPTION

C<LaTeX::Pod> converts LaTeX sources to Perl's POD (Plain old documentation)
format. Currently only a subset of the available LaTeX language is supported;
see below for further information.

=head1 CONSTRUCTOR

=head2 new

The constructor requires that the path to the LaTeX source must be defined:

 $parser = LaTeX::Pod->new('/path/to/source');

Returns the parser object.

=head1 METHODS

=head2 convert

There is only one public method available, namely C<convert()>:

 $parser->convert;

Returns the computed POD document as string.

=head1 SUPPORTED LANGUAGE SUBSET

Currently supported:

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
types of nodes. As example, an \item directive has quite often a separate text
associated with it as its content. Such directives and their expected converted
relatives within the output stream possibly cannot be easily detected without
some kind of sophisticated "look-behind" mechanism, which is how C<LaTeX::Pod>
internally functions.

C<LaTeX::Pod> was designed with the intention to be I<context-sensitive> aware.
This is being achieved by setting which node has been seen before the current one in
order to be able to call the appropriate routine for a LaTeX directive with two or
more nodes. Furthermore, C<LaTeX::Pod> registers which node it has previously
encountered and unregisters this information when it made use of it.

Considering that the POD documentation format has a limited subset of directives,
the overhead of keeping track of node occurences appears to be bearable. The POD
computed may consist of too many newlines before undergoing a transformation
where leading and trailing newlines will be truncated.

=head1 SEE ALSO

L<LaTeX::TOM>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://dev.perl.org/licenses/>

=cut
