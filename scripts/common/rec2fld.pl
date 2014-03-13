#!/usr/bin/env perl
use strict;
if (scalar @ARGV != 1) { die "usage: $0 <sep>"; }
my $arg = $ARGV[0];
my $sep = "";
while (<STDIN>) {
  chomp;
  print ($sep . $_);
  $sep = $arg;
}
print "\n";
