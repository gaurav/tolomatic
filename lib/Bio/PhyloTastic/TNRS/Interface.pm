package Bio::PhyloTastic::TNRS::Interface;
use Bio::Phylo::Factory;
use Bio::Phylo::Util::Logger ':levels';
use Data::Dumper;

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

Given a single taxon name as argument, this method converts it into
scientific name, as per Darwin Core (see L<http://rs.tdwg.org/dwc/terms/index.htm#scientificName>).
For instance,

    "Magnifera indica" -> "Magnifera indica L."
    "Panthera tigris" -> "Panthera tigris (Linnaeus, 1758)"

The input taxon name should be in Unicode, with spaces correctly coded
(i.e. there is no guarantee that "Magnifera+indica" or "Magnifera_indica"
will be correctly interpreted).

This interface makes no guarantee that common names will be translated
correctly. 

This interface assumes that each taxon name will be more or less unique 
for a given TNRS, so there must be at least two TNRSes (one for the ICZN,
one for the ICBN), and probably others depending on tree coverage in
the system (Bacteriological code, a TNRS optimized for translating names
in North America based on ITIS, one for marine animals based on WoRMS,
and so on). Since each TNRS can call any other, I can imagine a chain in
which more general TNRSes decide whether a taxon is "covered" by a more
specific TNRS and pass the decision on to them.

Input (as arguments):

    taxon   The taxon name you want to translate.

Output (as a hashref):

    scname  The scientific name with author information. Set to
            undef if no scientific name could be determined from
            the input.
    score   A number indicating certainty of the translation, 
            ranging from 0 (complete uncertainty) to 1 
            (complete certainty).

=cut

sub taxon2scname {
    my ( $self, $taxon ) = @_;

    use Data::Dumper;
    my $logger = $self->{'logger'} or die("Could not read the logger from this TNRS interface!");

    # We might eventually let the TNRS::Interface run ALL the TNRSes and
    # return the highest score, but it's not a big deal for now.
    $logger->error("Attempt to convert a taxon name to a scientificName is being handled by the TNRS Interface, which doesn't do anything.");
    $logger->error("Please choose a TNRS module and use that instead.");

    $logger->info("Converted '$taxon' to '$taxon' via $self: score = 0.0");

    return {
        scname =>   $taxon,
        score =>    0.0
    };
}

1;

