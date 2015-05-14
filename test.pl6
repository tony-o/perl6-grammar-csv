#!/usr/bin/env perl6

use lib 'lib';
use Grammar::CSV;

my @proms; 

@proms.push: start { 
  my $*EOL    = "\n";
  my $*SEP    = ',';
  my $*QUOTE  = '"';
  my $*ESCAPE = '\\';
  say Grammar::CSV.parse('a,"a", "\"ask\""').perl;
};

await Promise.allof(@proms);
