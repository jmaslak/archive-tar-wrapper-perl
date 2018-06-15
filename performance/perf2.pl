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

my $regex = qr/^\.\.?$/;

$bench->add_instances(
    Dumbbench::Instance::PerlSub->new(
        name => 'with grep',
        code => sub {
            opendir my $dir_h, $dir or die "Cannot open $dir: $!";
            my @top_entries = grep { $_ !~ /^\.\.?$/ } readdir $dir_h;
            closedir($dir_h);
        }
    ),
    Dumbbench::Instance::PerlSub->new(
        name => 'with grep and compiled regex',
        code => sub {
            opendir my $dir_h, $dir or die "Cannot open $dir: $!";
            my @top_entries = grep { $_ !~ $regex } readdir $dir_h;
            closedir($dir_h);
        }
    ),
    Dumbbench::Instance::PerlSub->new(
        name => 'with eq',
        code => sub {
            opendir my $dir_h, $dir or die "Cannot open $dir: $!";
            my @temp = readdir($dir_h);
            closedir($dir_h);
            my @top_entries;
            for (@temp) {
                next if ( ( $_ eq '.' ) or ( $_ eq '..' ) );
                push( @top_entries, $_ );
            }
        }
    ),
    Dumbbench::Instance::PerlSub->new(
        name => 'with enhanced eq',
        code => sub {
            opendir my $dir_h, $dir or die "Cannot open $dir: $!";
            my @temp = readdir($dir_h);
            closedir($dir_h);
            my @top_entries;
            for (@temp) {
                next
                  if (  ( length($_) <= 2 )
                    and ( ( $_ eq '.' ) or ( $_ eq '..' ) ) );
                push( @top_entries, $_ );
            }
        }
    ),
    Dumbbench::Instance::PerlSub->new(
        name => 'with enhanced eq mark2',
        code => sub {
            opendir my $dir_h, $dir or die "Cannot open $dir: $!";
            my @temp = readdir($dir_h);
            closedir($dir_h);
            my @top_entries;
            my $counter = 0;
            my $found   = 0;

            for (@temp) {
                $counter++;

                if (    ( length($_) <= 2 )
                    and ( ( $_ eq '.' ) or ( $_ eq '..' ) ) )
                {
                    $found++;
                    if ( $found < 2 ) {
                        next;
                    }
                    else {
                        push( @top_entries, splice( @temp, $counter ) );
                        last;
                    }

                }
                push( @top_entries, $_ );
            }
        }
    ),
    Dumbbench::Instance::PerlSub->new(
        name => 'with enhanced eq mark3',
        code => sub {
            opendir my $dir_h, $dir or die "Cannot open $dir: $!";
            my @temp = readdir($dir_h);
            closedir($dir_h);
            my ( $first, $second );
            my $index = 0;
            my $found = 0;

            for (@temp) {

                if (    ( length($_) <= 2 )
                    and ( ( $_ eq '.' ) or ( $_ eq '..' ) ) )
                {
                    if ( $found < 1 ) {
                        $first = $index;
                        $found++;
                        $index++;
                        next;
                    }
                    else {
                        $second = $index;
                        last;
                    }

                }
                else {
                    $index++;
                }
            }

            splice( @temp, $first,  1, 1 );
            splice( @temp, $second, 1, 1 );
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
