use warnings;
use strict;
use Test::More;
use Archive::Tar::Wrapper;

my $tar = Archive::Tar::Wrapper->new(osname => 'openbsd');

diag(explain($tar));

done_testing;
