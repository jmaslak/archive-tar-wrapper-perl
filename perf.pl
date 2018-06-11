use warnings;
use strict;
use Dumbbench;

my $bench = Dumbbench->new(
    target_rel_precision => 0.010,    # seek ~0.5%
    initial_runs         => 1000,      # the higher the more reliable
);

my @entries = qw(.SomeFile .SomeOtherFile .ADir .AnotherDir);

$bench->add_instances(
    Dumbbench::Instance::PerlSub->new(
        name => 'replacement with regex',
        code => sub {
            for my $entry (@entries) {
                $entry =~ s#^\.##o;
            }
        }
    ),
    Dumbbench::Instance::PerlSub->new(
        name => 'replacement with substr',
        code => sub {
            for my $entry (@entries) {
                if ( index( $entry, '.' ) == 0 ) {
                    $entry = substr( $entry, 1 );
                }
            }
        }
    )
);

$bench->run;
$bench->report;
