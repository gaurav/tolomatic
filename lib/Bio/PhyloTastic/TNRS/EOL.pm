=head1 NAME

Bio::PhyloTastic::TNRS::EOL - A TNRS for EOL

=head1 SYNOPSIS

    use Bio::PhyloTastic::TNRS::EOL;

    my $eol = Bio::PhyloTastic::TNRS::EOL->new;
    my $results = $eol->taxon2scname("Panthera tigris");
    print "Obtained $results{'scname'} with a score of $results{'score'} (from 0-1).";

=cut

package Bio::PhyloTastic::TNRS::EOL;

use Bio::PhyloTastic::TNRS::Interface;

use Bio::Phylo::Factory;
use Bio::Phylo::Util::Logger ':levels';

use LWP::UserAgent;
use JSON;
use URI::Escape;
use Data::Dumper;

our @ISA = ('Bio::PhyloTastic::TNRS::Interface');

sub new {
    my ($class) = @_;

    my $self = {};
    bless $self, $class;

    # Set up a logger for us to use.
    my $biophyfac = Bio::Phylo::Factory->new;
    $self->{'logger'} = $biophyfac->create_logger;

    return $self;
}

=item taxon2scname

See L<Bio::PhyloTastic::TNRS::Interface/taxon2scname>.

=cut

sub taxon2scname {
    my ( $self, $taxon ) = @_;

    use Data::Dumper;
    my $logger = $self->{'logger'} or die("Could not read the logger from this TNRS interface!");

    # Make an HTTP call to EOL to retrieve the closest name match.
    my $lwp = LWP::UserAgent->new;
    my $response = $lwp->get('http://eol.org/api/search/1.0/' . uri_escape($taxon) . ".json");
    unless($response->is_success) {
        return { 
            error => "Could not make the 'search' API call to eol.org: " . $response->status_line,
            retry => 1
        };
    }

    my $json = decode_json($response->decoded_content);
    unless(defined $json->{'results'}[0]) {
        return {
            error => "No names matched taxon '$taxon' on EOL.",
            retry => 0
        };
    }

    my $id = $json->{'results'}[0]{'id'};
    my $uri = $json->{'results'}[0]{'link'};

    # Look up the scientific name for this entry.
    $response = $lwp->get('http://eol.org/api/pages/1.0/' . uri_escape($id) . ".json");
    unless($response->is_success) {
        return { 
            error => "Could not make the 'pages' API call to eol.org: " . $response->status_line,
            retry => 1
        };
    }

    $json = decode_json($response->decoded_content);
    unless(defined $json->{'taxonConcepts'}[0]) {
        return {
            error => "No TaxonConcepts found for EOL id $id (taxon $taxon)",
            retry => 0
        };
    }

    # For now, we'll just take the first taxon concept EOL provides with us.
    # TODO: Make that a bit more sophisticated.

    my $scname = $json->{'taxonConcepts'}[0]{'scientificName'};
    my $score = 0.5;    # Default EOL score.
    
    # If EOL gives us the same name we have, assume a perfect match.
    if(lc($scname) eq lc($taxon)) {
        $score = 1.0;
    }

    # If we're looking for a binomial and EOL gives us the same text after
    # the binomial, assume it's a good match.
    elsif($taxon =~ /^[A-Z][a-z]+ [a-z]+$/) {
        my @words = split(/ /, $scname);
        if(lc($words[0] . ' ' . $words[1]) eq $taxon) {
            $score = 0.8;
        }
    }

    # TODO: Use String::Approx to check how far enough the name is from the input taxon name.

    # Finished
    $logger->info("Converted '$taxon' to '$scname' via $self: score = $score");

    return {
        scname =>   $scname,
        score =>    $score,
        uri =>      $uri
    };
}

1;

