use strict;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Plack::Builder;

use SiTeWiki::Web;
use SiTeWiki;
use Plack::Session::Store::File;
use Plack::Session::State::Cookie;

builder {
    enable 'Plack::Middleware::Static',
        path => qr{^(?:/static/)},
        root => File::Spec->catdir(dirname(__FILE__));
    enable 'Plack::Middleware::Static',
        path => qr{^(?:/robots\.txt|/favicon\.ico)$},
        root => File::Spec->catdir(dirname(__FILE__), 'static');
    enable 'Plack::Middleware::ReverseProxy';
    enable 'Plack::Middleware::Session',
        store => Plack::Session::Store::File->new(
            dir => File::Spec->catdir(dirname(__FILE__), 'tmp', 'sessions'),
        ),
        state => Plack::Session::State::Cookie->new(
            httponly => 1,
        );
    SiTeWiki::Web->to_app();
};
