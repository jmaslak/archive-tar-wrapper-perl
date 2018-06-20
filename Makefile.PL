use warnings;
use strict;
use ExtUtils::MakeMaker;
use File::Which;

if ($^O eq 'MSWin32') {
    require Win32;
    my $full_name = Win32::GetOSName();
    my ($osvername, $major, $minor, $id) = Win32::GetOSVersion();

    if ($major < 10) {
        die "OS unsupported\n";
    } else {
        print "Running on $full_name - $major $minor $id\n";
    }

    # double quoting is required on Windows if there are spaces in the path
    my $test1 = qq(which('bsdtar.exe'));

    if ($test1 ne '') {
        my $version_info = `$test1 --version`;
        print "Using bstar $version_info\n";
    } else {
        my $test2 = qq(which('tar.exe'));

        if ($test2 ne '') {
            my $version_info = `$test2 --version`;

            if ($version_info =~ /GNU/) {
                warn "GNU tar is not supported on Microsoft Windows. Install a BSD tar or check your PATH configuration\n";
                die "OS unsupported\n";
            } else {
                print "Using tar $version_info\n";
            }
        } else {
            warn "No tar program available\n";
            die "OS unsupported\n";
        }
    }
}

my %WriteMakefileArgs = (
    'NAME'             => 'Archive::Tar::Wrapper',
    'VERSION_FROM'     => 'lib/Archive/Tar/Wrapper.pm',
    'MIN_PERL_VERSION' => 5.008001,
    'PREREQ_PM'        => {
        'File::Temp'    => 0,
        'Cwd'           => 0,
        'Log::Log4perl' => 0,
        'IPC::Run'      => 0,
        'File::Which'   => 0
    },
);

if ( $ExtUtils::MakeMaker::VERSION >= 6.50 ) {
    $WriteMakefileArgs{META_MERGE} = {
        'resources' => {
            'type' => 'git',
            'url'  => 'https://github.com/glasswalk3r/archive-tar-wrapper-perl',
            'repository' =>
              'https://github.com/glasswalk3r/archive-tar-wrapper-perl.git',
            'bugtracker' =>
              'https://github.com/glasswalk3r/archive-tar-wrapper-perl/issues'
        },
    };
}

# Test::More::is_deeply is required for testing
if ( $ExtUtils::MakeMaker::VERSION >= 6.64 ) {
    $WriteMakefileArgs{TEST_REQUIRES} = { 'Test::Simple' => 1.302073 };
}
else {
    $WriteMakefileArgs{PREREQ_PM} = { 'Test::Simple' => 1.302073 };
}

if ( $] >= 5.005 ) {
    $WriteMakefileArgs{ABSTRACT_FROM} = 'lib/Archive/Tar/Wrapper.pm';
    $WriteMakefileArgs{AUTHOR}        = [
        'Mike Schilli <cpan@perlmeister.com>',
        'Alceu Rodrigues de Freitas Junior <arfreitas@cpan.org>'
    ];
}

$WriteMakefileArgs{LICENSE} = 'gpl_3'
  if ( $ExtUtils::MakeMaker::VERSION >= 6.3002 );
WriteMakefile(%WriteMakefileArgs);
