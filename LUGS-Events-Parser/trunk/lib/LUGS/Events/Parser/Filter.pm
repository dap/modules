package LUGS::Events::Parser::Filter;

use strict;
use warnings;
use boolean qw(true);

use HTML::Entities qw(decode_entities);
use HTML::Parser ();

our $VERSION = '0.02';

my (@tags, @stack);

sub _init_parser
{
    my $self = shift;

    my $parser = HTML::Parser->new(
        api_version => 3,
        start_h     => [ \&_start_tag, 'tagname,attr,attrseq' ],
        text_h      => [ \&_text_tag,  'text'                 ],
        end_h       => [ \&_end_tag,   'tagname'              ],
    );

    return $parser;
}

sub _parse_html
{
    my $self = shift;
    my ($chunk, $html) = @_;

    $self->{parser}->parse($chunk);

    undef @stack;

    return unless @tags;

    @$html = @tags;
    undef @tags;
}

sub _eof_parser
{
    my $self = shift;

    $self->{parser}->eof;
}

sub _start_tag
{
    my ($tagname, $attr, $attrseq) = @_;

    push @stack, { name => $tagname, attr => $attr, attrseq => $attrseq };
}

sub _text_tag
{
    my ($text) = @_;

    return unless @stack;

    $stack[-1]->{text} = $text;
}

sub _end_tag
{
    my ($tagname) = @_;

    return unless @stack;

    if ($stack[-1]->{name} eq $tagname) {
        push @tags, {
            $tagname => {
                map { $_ => $stack[-1]->{$_} }
                  qw(text attr attrseq),
            },
        };
        pop @stack;
    }
}

sub _rewrite_tags
{
    my $self = shift;
    my ($fields) = @_;

    foreach my $field (keys %{$fields->{_html}}) {
        my %rewritten;
        foreach my $html (@{$fields->{_html}->{$field}}) {
            foreach my $tag (keys %$html) {
                my @tagnames;
                if (%{$html->{$tag}->{attr}}) {
                    foreach my $attr (keys %{$html->{$tag}->{attr}}) {
                        if (exists $self->{Tag_handlers}->{"$tag $attr"}) {
                            push @tagnames, "$tag $attr";
                        }
                    }
                }
                else {
                    if (exists $self->{Tag_handlers}->{$tag}) {
                        push @tagnames, $tag;
                    }
                }
                foreach my $tagname (@tagnames) {
                    foreach my $handler (@{$self->{Tag_handlers}->{$tagname}}) {
                        if ($self->_field_rewrite($field, $handler)) {
                            unless (exists $rewritten{$tagname}) {
                                $rewritten{$tagname} = true;
                            }
                            my $subst = $handler->{rewrite};
                            foreach my $subst_item ($self->_subst_data($html, $tag)) {
                                next unless defined $subst_item->[1];
                                my ($identifier, $replacement) = @$subst_item;
                                my $place_holder = uc $identifier;
                                $subst =~ s/\$$place_holder/$replacement/;
                            }
                            my $re = $self->_subst_pattern($html, $tag);
                            my ($text) = $fields->{$field} =~ $re;
                            my $replace = defined $html->{$tag}->{text} ? $subst : $text;
                            $fields->{$field} =~ s{$re}{$replace};
                        }
                    }
                }
            }
        }
        foreach my $tagname (grep !$rewritten{$_}, keys %{$self->{Tag_handlers}}) {
            foreach my $handler (@{$self->{Tag_handlers}->{$tagname}}) {
                if ($self->_field_rewrite($field, $handler)) {
                    if ($tagname !~ /\b\s+?\b/
                        && $fields->{$field} =~ m{<$tagname>}
                        && $fields->{$field} !~ m{</$tagname>}
                    ) {
                        my $subst = $handler->{rewrite};
                        $fields->{$field} =~ s{<$tagname>}{$subst}g;
                    }
                }
            }
        }
    }
}

sub _strip_text
{
    my $self = shift;
    my ($fields) = @_;

    foreach my $field (grep !/^\_/, keys %$fields) {
        foreach my $item (@{$self->{Strip_text}}) {
            $fields->{$field} =~ s/\Q$item\E//gi;
        }
    }
}

sub _decode_entities
{
    my $self = shift;
    my ($fields) = @_;

    foreach my $field (grep !/^\_/, keys %$fields) {
        decode_entities($fields->{$field});
    }
}

sub _field_rewrite
{
    my $self = shift;
    my ($field, $handler) = @_;

    my %rewrite = map { $_ => true } @{$handler->{fields}};

    return ($rewrite{$field} || $rewrite{'*'});
}

sub _subst_data
{
    my $self = shift;
    my ($html, $tag) = @_;

    return (map {
        [ $_ => $html->{$tag}->{attr}->{$_} ]
    } keys %{$html->{$tag}->{attr}}),
           (map {
        [ $_ => $html->{$tag}->{$_} ]
    } grep /^(?:text)$/, keys %{$html->{$tag}});
}

sub _subst_pattern
{
    my $self = shift;
    my ($html, $tag) = @_;

    if (@{$html->{$tag}->{attrseq}}) {
        my $attr = join ' ',
          map "${_}=\"$html->{$tag}->{attr}->{$_}\"",
          @{$html->{$tag}->{attrseq}};
        my $text = $html->{$tag}->{text};
        return defined $text
          ? qr{<$tag\s+?\Q$attr\E>$text</$tag>}
          : qr{<$tag\s+?\Q$attr\E>(.*?)</$tag>};
    }
    else {
        return qr{<$tag>(.*?)</$tag>};
    }
}

1;
