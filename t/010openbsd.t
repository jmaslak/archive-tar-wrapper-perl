use warnings;
use strict;
use Test::More;
use Archive::Tar::Wrapper;
use File::Spec;

my $tar =
  Archive::Tar::Wrapper->new( osname => 'openbsd', tar_read_options => 'p' );

is( $tar->{tar_read_options},
    '-p', 'tar parameters on OpenBSD have a "-" prefix' );
ok( $tar->_is_openbsd(), 'correctly identify the OS' );
is_deeply(
    $tar->_read_openbsd_opts('z'),
    [ '/bin/tar', '-z', '-x', '-p' ],
    'got correct options for gziped tarball'
) or diag( explain( $tar->_read_openbsd_opts('z') ) );
is_deeply(
    $tar->_read_openbsd_opts('j'),
    [ '/bin/tar', '-j', '-x', '-p' ],
    'got correct options for bziped tarball'
) or diag( explain( $tar->_read_openbsd_opts('j') ) );

for my $file (qw(bar.tar foo.tgz foo.tar.bz2)) {
    ok( $tar->read( File::Spec->catfile( 't', 'data', $file ) ),
        "read tarball $file" );
}

done_testing;
