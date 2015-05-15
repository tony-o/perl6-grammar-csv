#!/usr/bin/env perl6

use lib 'lib';
use Grammar::CSV;

my @proms; 

@proms.push: start { 
  my $*EOL    = "\n";
  my $*SEP    = ',';
  my $*QUOTE  = '"';
  my $*ESCAPE = '\\';
  my $ecoli = Grammar::CSV.parse('a,"a", "\"ask\""');

  $ecoli<line>[0]<value>.join("\n").say;
};

await Promise.allof(@proms);
