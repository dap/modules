#!/usr/bin/perl

use strict;
use warnings;

use File::Spec;
use FindBin qw($Bin);
use LaTeX::TOM;
use Test::More tests => 1;

$^W = 0;

my $tex = do { local $/; <DATA> };
my $texfile = File::Spec->catfile($Bin, 'data', 'tex.in');

my $parser = LaTeX::TOM->new;
my $tree_string = $parser->parse($tex);
my $tree_file = $parser->parseFile($texfile);

is_deeply($tree_string, $tree_file, 'Tree read from string equals tree read from file');

__DATA__
\NeedsTeXFormat{LaTeX2e}
\documentclass[11pt]{article}
\title{Some Test Doc}
\begin{document}
    \maketitle
\end{document}
