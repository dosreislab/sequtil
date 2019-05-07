#! /usr/bin/perl
# Take a chunk of Newick trees and format them
# into a Nexus file (suitable for Mr. Bayes)
#
# 2008 (C) Mario dos Reis

use strict;
use warnings;

my $usage = "Usage: nexustrees.pl LABELS <TREESFILE";

unless (@ARGV > 0) {
    print $usage, "\n";
    exit -1;
}

my $labelsf = $ARGV[0];

open LABELS, $labelsf
    or die "Fatal: could not open $labelsf for reading: $!\n";
my @labels = <LABELS>;

my @trees = <STDIN>;

# Print header information in nexus file
print "#NEXUS\n";
print "begin trees;\n";
print "   translate\n";

# Print name translation table
my $j = 0;
foreach my $label (@labels) {
    $j++;
    chomp $label;

    my $sep = ",";
    if ($j == @labels) {
	$sep = ";";
    }

    print "\t$j $label$sep\n";
}

# Print trees
my $i = 0;
foreach my $tree (@trees) {
    $i++;
    print "  tree rep.$i = $tree"
}

print "end;\n";

close LABELS;

END;

