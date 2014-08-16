#!perl
use strict;
use warnings;

use Test::Simple tests => 5;
use lib 'lib';
use WebService::DPD::API;
use Data::Dumper;

my $username = 'TESTAPI';
my $password = 'APITEST';


my $api = WebService::DPD::API->new( 
									username => $username,
									password => $password,
									);

ok( $WebService::DPD::API::VERSION );
ok( defined($api) );
ok( $username eq $api->username );
ok( $password eq $api->password );
ok( $api->host );

#ok ( $api->login->{response}->code == 200 );
#ok ( $api->geoSession );
warn 'geoSession:' . $api->geoSession . "\n";

#my $country = $api->get_country('GB');
=head
country
	"countryCode":"GB",
	"countryName":"United Kingdom"
	"isoCode":"826"
	"isEUCountry":false
	"isLiabilityAllowed":true
	"liabilityMax":15000
	"isPostcodeRequired":true
=cut
#ok ( $country->{country}->{countryCode} eq 'GB' );

#warn Dumper( $country );

my $address = {
				countryCode		=> 'GB',
				county			=> 'West Midlands',
				locality		=> 'Birmingham',
				organisation	=> 'GeoPost',
				postcode		=> 'B661BY',
				property		=> 'GeoPost UK',
				street			=> 'Roebuck Ln',
				town			=> 'Smethwick',
				};

my $shipping = {
					collectionDetails 	=> {
												address => $address,
												},
					deliveryDetails		=> {
												address => $address,
												},
					deliveryDirection	=> 1,
					numberOfParcels		=> 1,
					totalWeight			=> 5,
					shipmentType		=> 0,
					};

#my $services = $api->get_services( $shipping );

#ok( $services->[0] ); 

#my $countries = $api->list_countries;
#ok( $countries );

#my $service = $api->get_service(812);
#ok( $service );
#ok( $service->{network}->[0]->{networkCode} );


my $shipment_data = {
						jobId => 'null',
						collectionOnDelivery =>  "false",
						invoice =>  "null",
						collectionDate =>  "2014-08-19T09:00:00",
						consolidate =>  "false",
						consignments => [
											{
												collectionDetails => {
																		contactDetails => {
																							contactName => "Mr David Smith",
																							telephone => "0121 500 2500"
																							},
																		address => $address,
																		},
												deliveryDetails => {
																		contactDetails => {
																							contactName => "Mr David Smith",
																							telephone => "0121 500 2500"
																											},
																		notificationDetails => {
																								mobile => "07921 123456",
																								email => 'david.smith@acme.com',
																								},
																		address => {
																					organisation => "ACME Ltd",
																					property => "Miles Industrial Estate",
																					street => "42 Bridge Road",
																					locality => "",
																					town => "Birmingham",
																					county => "West Midlands",
																					postcode => "B1 1AA",
																					countryCode => "GB",
																					}
																	},
												networkCode => "1^12",
												numberOfParcels => '1',
												totalWeight => '5',
												shippingRef1 => "Catalogue Batch 1",
												shippingRef2 => "Invoice 231",
												shippingRef3 => "",
												customsValue => '0',
												deliveryInstructions => "Please deliver to industrial gate A",
												parcelDescription => "",
												liabilityValue => '0',
												liability => "false",
												parcel => [],
											}
										]
					};

my $shipment_data_example = '{
	"test": true,
	"jobId": null,
	"collectionOnDelivery": false,
	"invoice": null,
	"collectionDate": "2014-08-19T09:00:00",
	"consolidate": false,
	"consignments": [{
		"collectionDetails":{
			"contactDetails":{
				"contactName":"Mr David Smith",
				"telephone":"0121 500 2500"
			},
			"address":{
				"organisation":"GeoPost UK Ltd",
				"property":"",
				"street":"Roebuck Lane",
				"locality":"Smethwick",
				"town":"Birmingham",
				"county":"West Midlands",
				"postcode":"B66 1BY",
				"countryCode":"GB",
			}
		},
		"deliveryDetails":{
			"contactDetails":{
				"contactName":"Mr David Smith",
				"telephone":"0121 500 2500"
			},
			"notificationDetails":{
				"mobile":"07921 123456"
				"email":"david.smith@acme.com"
			},
			"address":{
				"organisation":"ACME Ltd",
				"property":"Miles Industrial Estate",
				"street":"42 Bridge Road",
				"locality":"",
				"town":"Birmingham",
				"county":"West Midlands",
				"postcode":"B1 1AA",
				"countryCode":"GB",
			}
		},
		"networkCode":"1^12",
		"numberOfParcels":1,
		"totalWeight":5,
		"shippingRef1":"Catalogue Batch 1",
		"shippingRef2":"Invoice 231",
		"shippingRef3":"",
		"customsValue":0,
		"deliveryInstructions":"Please deliver to industrial gate A",
		"parcelDescription":"",
		"liabilityValue":0,
		"liability":false,
		"parcel":[]
	}]
}';

my $shipment_data_example2 = {};
#DPD are working to solve a problem causing this test failure.
#my $shipment = $api->create_shipment( $shipment_data_example ); 
#warn Dumper( $shipment );
#ok( $shipment );
