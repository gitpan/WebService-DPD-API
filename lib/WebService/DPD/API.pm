package WebService::DPD::API;
use strict;
use warnings;
use Carp;
use Moo;
use LWP::UserAgent;
use HTTP::Request::Common;
use URI::Escape;
use Data::Dumper;
use JSON;
use MIME::Base64;
use namespace::clean;

# ABSTRACT: communicates with DPD API

our $VERSION = '0.001_03';

 
=head1 NAME

WebService::DPD::API

=head1 SYNOPSIS


=head1 DESCRIPTION

This module provides a simple wrapper around DPD delivery service API. This is a work in progress and contains incomplete test code, methods are likely to be refactored, you have been warned.

=head1 CONFIGURATION AND ENVIRONMENT
 
-
 
=head1 SEE ALSO
 
-
 
=head1 LICENSE AND COPYRIGHT
 
Copyright (c) 2014 Richard Newsham, Pryanet Ltd
 
This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
 
=head1 BUGS AND LIMITATIONS
 
See rt.cpan.org for current bugs, if any.
 
=head1 INCOMPATIBILITIES
 
None known.
 
=head1 DIAGNOSTICS

-
 
=head1 DEPENDENCIES

Carp
Moo
LWP::UserAgent
HTTP::Request::Common
URI::Escape
Data::Dumper
JSON
MIME::Base64
namespace::clean

=cut

has username => (
	is => 'ro',
	required => 1,
);

has password => (
	is => 'ro',
	required => 1,
);

has url => ( is => 'ro',
			 default => 'https://api.dpd.co.uk'
			);

has host => ( is => 'ro',
				lazy => 1,
			 default => sub { 
			 					my $self=shift; 
								my $url = $self->url; 
								$url =~ s/^https{0,1}.:\/\///; 
								return $url; },
			);

has ua => (
	is => 'rw',
);

has geoSession => (
	is => 'rw',
);

has errstr => (
	is => 'rw',
	default => '',
);

sub BUILD 
{
	my $self = shift;
	$self->ua( LWP::UserAgent->new );
	$self->ua->agent("Perl_WebService::DPD::API/$VERSION");
	$self->ua->cookie_jar({});
}

sub login
{
	my $self = shift;
	
	my $authorisation = encode_base64($self->username . ':' . $self->password, '');
	
	my $req = HTTP::Request->new(POST => $self->url . '/user/?action=login');
	$req->header( Host => $self->host );
	$req->protocol('HTTP/1.1');
	$req->content_type('application/json');
	$req->header( Accept => 'application/json' );
	$req->header( Authorization =>  "Basic $authorisation" );
	$req->header( GEOClient =>  'thirdparty/Pryanet' ); #FIXME needs to be configurable

	my $response = $self->ua->request($req);
	if ( $response->is_success )
	{
		my $result;
		eval{ $result = JSON->new->utf8->decode($response->content) };
		die "Server response was invalid" if $@;
		die "Error: $result->{error}" if $result->{error};
		$result->{response} = $response;
		$self->geoSession( $result->{data}->{geoSession} );
		return $result;
	}
	else
	{
		die 'Unable to initialise api session: ' . $response->status_line;
	}
}

sub call
{
	my ($self, $path, $data) = @_;
	my $req;
	if ( $data )
	{
		$req = HTTP::Request->new(POST => $self->url . $path);
	#	my $content = to_json( $data );
	#	$content =~ s/"null"/null/gi;
	#	$content =~ s/"false"/false/gi;
	#	$content =~ s/"true"/true/gi;
	#	$req->content( $content );
		$req->content($data);
	}
	else
	{
		$req = HTTP::Request->new(GET => $self->url . $path);	
	}
	$req->header( Host => $self->host );
	$req->protocol('HTTP/1.1');
	$req->content_type('application/json');
	$req->header( Accept => 'application/json' );
	$req->header( GEOSession =>  $self->geoSession );
	$req->header( GEOClient =>  'thirdparty/Pryanet' ); #FIXME needs to be configurable

	#warn $req->as_string;
	
	warn $req->as_string if $data;
	my $response = $self->ua->request($req);
	if ( $response->is_success )
	{
		my $result;
		eval{ $result = JSON->new->utf8->decode($response->content) };
		$self->errstr = "Server response was invalid\n" & return if $@;
		if ( $result->{error} )
		{
			$self->errstr( $result->{error}->{errorType} . ' error : ' . $result->{error}->{obj} . ' : ' . $result->{error}->{errorCode} . ' : ' . $result->{error}->{errorMessage} . "\n" );
			warn Dumper( $result->{error} );
			return;
		}
		$result->{response} = $response;
		return $result->{data};
	}
	else
	{
		warn "Error in call to $path " . $response->status_line . '' .  $self->errstr;
		return;
	}
}

sub get_country
{
	my ( $self, $code ) = @_;
	return $self->call('/shipping/country/' . $code);
}

sub get_services
{
	my ( $self, $shipping ) = @_;
	return $self->call('/shipping/network/?' . $self->_to_query_params($shipping) );
}

sub get_service
{
	my ( $self, $geoServiceCode ) = @_;
	return $self->call( "/shipping/network/$geoServiceCode/" );
}

sub create_shipment
{
	my ( $self, $data ) = @_;
	return $self->call('/shipping/shipment',  $data);
}

sub list_countries
{
	my $self = shift;
	my $countries = $self->call('/shipping/country');
	return $countries;
}

sub _to_query_params
{
	my ( $self, $data ) = @_;
	my @params;
	my $sub;
	$sub = sub {
					my ( $name, $data ) = @_;
					for ( keys %$data )
					{
						if ( ref $data->{$_} eq 'HASH' )
						{
							$sub->( "$name.$_", $data->{$_} );
						}
						else
						{
							push @params, { key => "$name.$_", value => $data->{$_} };
						}
					}
				};
	$sub->( '', $data);
	my $query;
	for ( @params )
	{
		$_->{key} =~ s/^\.//;
		$query .= $_->{key} . '='.  uri_escape( $_->{value} ) . '&';
	}
	$query =~ s/&$//;
	return $query;
}

1;


