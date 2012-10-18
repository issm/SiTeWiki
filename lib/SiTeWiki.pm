package SiTeWiki;
use strict;
use warnings;
use utf8;
use parent qw/Amon2/;
our $VERSION='0.01';
use 5.008001;

# setup textile class
use Text::Textile::Pluggable ();
{
    my $textile_conf = __PACKAGE__->config->{'Text::Textile::Pluggable'} || +{};
    my $textile = Text::Textile::Pluggable->new(
        plugins => $textile_conf->{plugins} || [],
    );
    sub textile { shift; $textile->textile(@_) }
};

1;
