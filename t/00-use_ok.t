#!/usr/bin/perl -w
#
# Use use_ok to load up the modules in this package
# to ensure that they can all be loaded.
#

use strict;
use warnings;
use Test::More tests => 1;

use_ok('Bio::PhyloTastic::TNRS::Interface');

1;
