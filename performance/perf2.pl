use warnings;
use strict;
use Dumbbench;
use File::Temp qw(tempfile tempdir);

my $bench = Dumbbench->new(
    target_rel_precision => 0.005,    # seek ~0.5%
    initial_runs         => 1000,     # the higher the more reliable
);

my $dir = tempdir( CLEANUP => 1 );
my $template = 'foobar-XXXXXXXX';
for ( 1 .. 1000 ) {
    my ( $fh, $filename ) = tempfile( $template, DIR => $dir );
    print $fh rand();
    close($fh);
}

$bench->add_instances(
    Dumbbench::Instance::PerlSub->new(
        name => 'skipping with grep',
        code => sub {
            opendir my $dir_h, $dir or die "Cannot open $dir: $!";
            my @top_entries = grep { $_ !~ /^\.\.?$/ } readdir $dir_h;
            closedir($dir_h);
        }
    ),
    Dumbbench::Instance::PerlSub->new(
        name => 'sort and shift',
        code => sub {
            opendir( my $dir_h, $dir ) or die "Cannot open $dir: $!";
            my @top_entries = readdir($dir_h);
            closedir($dir_h);
            @top_entries = sort(@top_entries);

            # removing the '.' and '..' entries
            shift(@top_entries);
            shift(@top_entries);
        }
    ),
);

$bench->run;
$bench->report;
