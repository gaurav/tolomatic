package Bio::PhyloTastic::TNRS::Interface;
use Bio::Phylo::Util::Logger ':levels';
use Data::Dumper;

my $logger = Bio::Phylo::Util::Logger->new( '-level' => INFO );

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

Output (as a hash):

    scname  The scientific name with author information. Set to
            undef if no scientific name could be determined from
            the input.
    score   A number indicating certainty of the translation, 
            ranging from 0 (complete uncertainty) to 1 
            (complete certainty).

=cut

sub taxon2scname {
    my ( $self, $taxon ) = @_;
    my $file = $ENV{'DATADIR'} . '/' . md5_hex($taxon);
    $logger->info("taxon: $taxon (file: $file)");
    open my $fh, '<', $file or die "Can't process taxon ${taxon} (${file}): $!";
    my @lines = <$fh>;
    my @fields = split /\t/, $lines[0];
    $logger->debug("path: @fields");
    for my $i ( 1 .. $#fields ) {
        $self->emit( $fields[$i], $fields[0] );        
    }
}

1;

