package SiTeWiki::TextilePlugin::HTMLFilter;
use strict;
use warnings;

sub post {
    my ($textile, $text) = @_;
    $text =~ s/\&amp;/&/g;
    return $text;
}

1;
