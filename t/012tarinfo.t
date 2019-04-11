use warnings;
use strict;
use Test::More tests => 14;
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
like(
    $arch->{version_info},
    qr/^Information not available/,
    'on error has no version information'
);
is( $arch->is_gnu, 0, 'is not GNU tar' );
is( $arch->is_bsd, 0, 'is not BSD tar' );
note('Testing as GNU tar');
$arch->{tar_exit_code} = 0;
$arch->{version_info}  = 'yada yada GNU yada yada';
$arch->_acquire_tar_info(1);
ok( $arch->is_gnu,  'tar is GNU' );
ok( !$arch->is_bsd, 'tar is not BSD' );
note('Testing as BSD tar');
$arch->{tar_exit_code} = 1;
$arch->{version_info} = 'bsdtar 2.4.12 - libarchive 2.4.12';
$arch->{tar}          = '/usr/bin/bsdtar';
$arch->_acquire_tar_info(1);
ok( !$arch->is_gnu, 'tar is not GNU' );
ok( $arch->is_bsd,  'tar is BSD' );
note('Now testing as on OpenBSD');

SKIP: {
	skip 'Not running on BSD', 3 unless ($^O eq 'opensd');
	$arch = Archive::Tar::Wrapper->new();
	ok( !$arch->is_gnu, 'tar is not GNU' );
	ok( $arch->is_bsd,  'tar is BSD' );
	like(
		$arch->{version_info},
		qr/^Information not available/,
		'on error has no version information'
	);
}