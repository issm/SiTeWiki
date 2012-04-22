use File::Spec;
use File::Basename qw(dirname);
my $basedir = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $dbpath;
if ( -d '/home/dotcloud/') {
    $dbpath = "/home/dotcloud/development.db";
} else {
    $dbpath = File::Spec->catfile($basedir, 'db', 'development.db');
}
+{
    editable => 1,

    basedir => $basedir,
    datadir => undef,

    'Text::Textile::Pluggable' => {
        plugins => [qw/
            +SiTeWiki::TextilePlugin::HTMLFilter
        /],
    },

    'DBI' => [
        "dbi:SQLite:dbname=$dbpath",
        '',
        '',
        +{
            sqlite_unicode => 1,
        }
    ],

    'Text::Xslate' => {
        syntax => 'Kolon',
        module => [
            'Text::Xslate::Bridge::Star',
        ],
    },
};
