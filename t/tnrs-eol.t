#!/usr/bin/perl -w
#
# Checks to see if the TNRS interface can be reached.
#

use strict;
use warnings;

use Bio::PhyloTastic::TNRS::EOL;
use Data::Dumper;
use Test::More tests => 4;

my $interface = Bio::PhyloTastic::TNRS::EOL->new;

sub test_name($) {
    my $name = shift;

    my $result = $interface->taxon2scname($name);
    if(defined $result->{'error'}) {
        fail("Error converting '$name': $result->{'error'}");
    } else {
        diag("EOL converts name '$name' to '$result->{'scname'}' (score: $result->{'score'}, uri: $result->{'uri'})");
        pass("Name '$name' converted, apparently successfully.");
    }
}

sub test_name_expect_fail($) {
    my $name = shift;

    my $result = $interface->taxon2scname($name);
    if(defined $result->{'error'}) {
        pass("Error converting '$name': $result->{'error'}");
    } else {
        fail("Name '$name' unexpectedly converted, apparently successfully.");
        diag("EOL converts name '$name' to '$result->{'scname'}' (score: $result->{'score'}, uri: $result->{'uri'})");
    }
}

test_name("Panthera tigris");
test_name("Hoopoe");
test_name("Sunflower");
test_name_expect_fail("Panthera igris");

1;
