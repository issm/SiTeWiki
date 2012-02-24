package SiTeWiki::Web::Dispatcher;
use 5.10.0;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::Lite;
use File::Basename qw/dirname/;
use File::Spec;
use File::Path qw/make_path remove_tree/;
use Encode;
use Encode::UTF8Mac;
use Text::Textile qw/textile/;
use Text::Xslate qw/mark_raw unmark_raw/;
use Data::Dumper;


get '/api/load' => sub {
    my ($c) = @_;
    my $req = $c->req;
    my ($path, $datadir, $datafile);

    $path = Encode::decode_utf8( $req->param('path') // '' );
    $path = '_default'  if $path eq '';

    $datadir = $c->config->{datadir} // $c->config->{basedir} . '/data';

    $datafile = File::Spec->catfile( $datadir, $path ) . '.textile';
    $datafile =~ s{/+$}{};

    my ($data, $data_html, $status);

    if ( -f ( my $_f = _f($datafile) ) ) {
        local $/;
        open my $fh, '<', $_f  or die "$datafile: $!";
        $data = Encode::decode_utf8( <$fh> );
        close $fh;
        $data_html = _html_filter( textile $data );
        $status = 200;
    }
    else {
        $status = 404;
    }
    $data //= '';
    $status = 404  if $data eq '';


    my $res = $c->render_json({
        path      => $path,
        datadir   => $datadir,
        data      => $data,
        data_html => $data_html,#mark_raw( $data_html ),
    });
    $res->status($status);
    return $res;
};


any '/api/textile' => sub {
    my ($c) = @_;
    my $req = $c->req;
    my $data = Encode::decode_utf8( $req->param('data') // '' );
    my $data_html = _html_filter( textile $data );

    $c->render_json({
        data_html => $data_html,
    });
};


post '/api/save' => sub {
    my ($c) = @_;
    my $req = $c->req;

    my ($path, $data, $data_html, $datadir, $datafile);

    $path = $req->param('path') // '';
    $path = '_default'  if $path eq '';

    $data = Encode::decode_utf8( $req->param('data') // '' );

    $datadir = $c->config->{datadir} // $c->config->{basedir} . '/data';

    $datafile = File::Spec->catfile( $datadir, $path ) . '.textile';
    $datafile =~ s{/+$}{};

    unless ( -d ( my $dir = dirname($datafile) ) ) {
        make_path($dir)  or  die "$dir: could not directory. ($!)";
    }

    {
        open my $fh, '>', $datafile  or die "$datafile: $!";
        print $fh Encode::encode_utf8($data);
        close $fh;
    };

    $data_html = _html_filter( textile $data );

    $c->render_json({
        path      => $path,
        datadir   => $datadir,
        data      => $data,
        data_html => $data_html,
    });
};


get '/{path:.*}' => sub {
    my ($c, $args) = @_;
    my $path = Encode::decode_utf8( $args->{path} // '' );
    $path = '_default'  if $path eq '';

    $c->render('index.tx', {
        path => $path,
    });
};


##
## utilities
##
sub _f {
    my ($f) = @_;
    given ( lc($^O) ) {
        when ('linux') {
            $f = Encode::encode('utf-8', $f);
        }
        when ('darwin') {
            #$f = Encode::encode('utf-8-mac', $f);
        }
        when ('mswin32') {
            $f = Encode::encode('utf-8', $f);
        }
    }
    return $f;
}


sub _html_filter {
    my ($html) = @_;
    $html =~ s/\&amp;/&/g;
    return $html;
}


1;
