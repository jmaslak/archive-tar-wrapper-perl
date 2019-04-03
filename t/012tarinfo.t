use warnings;
use strict;
use Test::More tests => 11;
use Archive::Tar::Wrapper;

my $arch = Archive::Tar::Wrapper->new();

# don't use those methods yourself outside these tests!
$arch->_acquire_tar_info();
ok( $arch->{version_info}, 'has version_info' );
is( $arch->{tar_exit_code}, 0, 'has the expected exit code' );
ok( defined( $arch->is_gnu ), 'is_gnu is defined' );
ok( defined( $arch->is_bsd ), 'is_bsd is defined' );
note('Faking error when executing tar');
$arch->{tar_exit_code} = 42;
$arch->_acquire_tar_info(1);
is(
    $arch->{version_info},
    'Information not available. Search for errors',
    'on error has no version information'
);
is( $arch->is_gnu, 0, 'is not GNU tar' );
is( $arch->is_bsd, 0, 'is not BSD tar' );
note('Testing GNU');
$arch->{tar_exit_code} = 0;
$arch->{version_info}  = 'yada yada GNU yada yada';
$arch->_acquire_tar_info(1);
ok( $arch->is_gnu,  'tar is GNU' );
ok( !$arch->is_bsd, 'tar is not BSD' );
note('Testing BSD');
$arch->{version_info} = 'yada yada yada yada';
$arch->{tar}          = '/usr/bin/bsdtar';
$arch->_acquire_tar_info(1);
ok( !$arch->is_gnu, 'tar is not GNU' );
ok( $arch->is_bsd,  'tar is BSD' );
