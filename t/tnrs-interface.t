#!/usr/bin/perl -w
#
# Checks to see if the TNRS interface can be reached.
#

use strict;
use warnings;

use Bio::PhyloTastic::TNRS::Interface;
use Test::More tests => 2;

my $interface = Bio::PhyloTastic::TNRS::Interface->new;
my $result = $interface->taxon2scname("ABCdef");

is($result->{'scname'}, 'ABCdef', 
    "TNRS::Interface should return the provided value");
is($result->{'score'}, 0, 
    "TNRS::Interface should return a score of zero");

1;
