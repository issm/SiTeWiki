use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'SiTeWiki',
    AUTHOR        => 'Some Person <person@example.com>',
    VERSION_FROM  => 'lib/SiTeWiki.pm',
    PREREQ_PM     => {
        'Amon2'                           => '3.32',
        'Text::Xslate'                    => '1.5006',
        'Test::More'                      => '0.98',
        'JSON'                            => '2.50',
        'Plack::Middleware::ReverseProxy' => '0.09',
        'Plack::Middleware::Session'      => '0',
        'Plack::Session'                  => '0.14',
        'Test::WWW::Mechanize::PSGI'      => '0',
        'Time::Piece'                     => '1.20',

        'Server::Starter'                 => '0.11',
        'Encode::UTF8Mac'                 => '0.03',
        'Text::Textile::Pluggable'        => '0.03',
        'File::Path'                      => '2.08',
    },
    MIN_PERL_VERSION => '5.008001',
    (-d 'xt' and $ENV{AUTOMATED_TESTING} || $ENV{RELEASE_TESTING}) ? (
        test => {
            TESTS => 't/*.t xt/*.t',
        },
    ) : (),
);
