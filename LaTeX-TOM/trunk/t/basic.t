#!/usr/bin/perl

use strict;
use warnings;

use LaTeX::TOM;
use Test::More tests => 28;

$^W = 0;

my $tex = do { local $/; <DATA> };

my $parser = LaTeX::TOM->new;
ok($parser->isa('LaTeX::TOM::Parser'), 'Parser object is-a LaTeX::TOM::Parser object');
my $tree = $parser->parse($tex);
ok($tree, 'Parser returned a defined tree');

my @expected = (
    [ 'TEXT', ''                    ],
    [ 'COMMAND', 'NeedsTeXFormat'   ],
    [ 'TEXT', 'LaTeX2e'             ],
    [ 'TEXT', "\n"                  ],
    [ 'COMMAND', 'documentclass'    ],
    [ 'TEXT', 'article'             ],
    [ 'TEXT', "\n"                  ],
    [ 'COMMAND', 'title'            ],
    [ 'TEXT', 'Some Test Doc'       ],
    [ 'TEXT', "\n"                  ],
    [ 'ENVIRONMENT', 'document'     ],
    [ 'TEXT', "\n    \\maketitle\n" ],
    [ 'TEXT', "\n"                  ],
);

foreach my $node (@{$tree->getAllNodes}) {
    my $node_type = $node->getNodeType;
    my $expected = shift @expected;

    my $desc = $expected->[1];

    my $cnt = 0;
    $cnt++ while $desc =~ /\n/g;

    if (!length $desc) {
        $desc = 'undef';
    }
    elsif ($cnt >= 1 && $desc !~ /\w/) {
        $desc = 'newline';
        $desc .= 's' if $cnt > 1;
    }
    else {
        $desc =~ s/\n//g;
        $desc =~ tr/ //d;
    }

    if (my ($type) = $node_type =~ /^(TEXT|COMMENT)$/) {
        ok($expected->[0] =~ $type, $type);
        ok($expected->[1] eq $node->getNodeText, $desc);
    }
    elsif ($node_type =~ /^ENVIRONMENT$/) {
        ok($expected->[0] =~ $node_type, $node_type);
        ok($expected->[1] eq $node->getEnvironmentClass, $desc);
    }
    elsif ($node_type =~ /^COMMAND$/) {
        ok($expected->[0] =~ $node_type, $node_type);
        ok($expected->[1] =~ $node->getCommandName, $desc);
    }
}

__DATA__
\NeedsTeXFormat{LaTeX2e}
\documentclass[11pt]{article}
\title{Some Test Doc}
\begin{document}
    \maketitle
\end{document}
