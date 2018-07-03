use warnings;
use strict;
use File::Temp qw(tempfile tempdir);
use Test::More tests => 1;

package MyDumbbench;
use parent 'Dumbbench';

sub new {
    my ( $class, @args ) = @_;
    my $self = $class->SUPER::new(@args);
    return $self;
}

sub report_as_text {
    my ($self) = @_;
    my $formatted;

    foreach my $instance ( $self->instances ) {
        my $result     = $instance->result;
        my $result_str = Dumbbench::unscientific_notation($result);

        my $mean  = $result->raw_number;
        my $sigma = $result->raw_error->[0];
        my $name  = $instance->_name_prefix;
        $formatted .= sprintf(
            "%sRan %u iterations (%u outliers).\n",
            $name,
            scalar( @{ $instance->timings } ),
            scalar( @{ $instance->timings } ) - $result->nsamples
        );

        $formatted .=
          sprintf( "%sRounded run time per iteration: %s (%.1f%%)\n",
            $name, $result_str, $sigma / $mean * 100 );
    }

    return $formatted;
}

package main;
use Dumbbench;
use constant BATCH_SIZE  => 1000;
use constant TOTAL_FILES => 10;

my $bench = MyDumbbench->new(
    target_rel_precision => 0.005,
    initial_runs         => BATCH_SIZE,
);

my $dir = tempdir( CLEANUP => 1 );
my $template = 'foobar-XXXXXXXX';
for ( 1 .. TOTAL_FILES ) {
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
diag( $bench->report_as_text );
pass('Performance test for Tar::Archive::Wrapper::write()');
