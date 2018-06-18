use warnings;
use strict;
use ExtUtils::MakeMaker;

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
