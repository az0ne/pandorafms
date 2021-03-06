package PandoraFMS::GIS;
##########################################################################
# GIS Pandora FMS functions.
# Pandora FMS. the Flexible Monitoring System. http://www.pandorafms.org
##########################################################################
# Copyright (c) 2005-2010 Artica Soluciones Tecnologicas S.L
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License
# as published by the Free Software Foundation; version 2
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
##########################################################################

=head1 NAME 

PandoraFMS::GIS - Geographic Information System functions of Pandora FMS

=head1 VERSION

Version 3.1

=head1 SYNOPSIS

 use PandoraFMS::GIS;

=head1 DESCRIPTION

This module contains the B<GIS> (Geographic Information System) related  functions of B<Pandora FMS>

=head2 Interface
Exported Functions:

=over

=item * C<distance_moved>

=item * C<get_reverse_geoip_sql>

=item * C<get_reverse_geoip_file>

=item * C<get_random_close_point>

=back

=head1 METHODS

=cut

use strict;
use warnings;

# Default lib dir for RPM and DEB packages
use lib '/usr/lib/perl5';

use PandoraFMS::DB;
use PandoraFMS::Tools;
# TODO:Test if is instaled 

my $geoIPPurePerlavilable= (eval 'use  PandoraFMS::GeoIP; 1') ? 1 : 0;


require Exporter;

our @ISA = ("Exporter");
our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw( 	
	distance_moved
	get_reverse_geoip_sql
	get_reverse_geoip_file
	get_random_close_point
	);
# Some intenrnal constants

my $earth_radius_in_meters = 6372797.560856;
my $pi =  4*atan2(1,1);
my $to_radians= $pi/180;
my $to_half_radians= $pi/360;
my $to_degrees = 180/$pi;

##########################################################################
=head2 C<< distance_moved (I<$pa_config>, I<$last_longitude>, I<$last_latitude>, I<$last_altitude>, I<$longitude>, I<$latitude>, I<$altitude>) >> 

Measures the distance between the last position and the previous one taking in acount the earth curvature
The distance is based on Havesine formula and so far doesn't take on account the altitude

B<< Refferences (I<Theory>): >>
 * L<http://franchu.net/2007/11/16/gis-calculo-de-distancias-sobre-la-tierra/>
 * L<http://en.wikipedia.org/wiki/Haversine_formula>

B<< References (I<C implementation>): >>
 * L<http://blog.julien.cayzac.name/2008/10/arc-and-distance-between-two-points-on.html>

=cut
##########################################################################
sub distance_moved ($$$$$$$) {
	my ($pa_config, $last_longitude, $last_latitude, $last_altitude, $longitude, $latitude, $altitude) = @_;


	my $long_difference = $last_longitude - $longitude;
	my $lat_difference = $last_latitude - $latitude;
	#my $alt_difference = $last_altitude - $altitude;
   

	my $long_aux = sin ($long_difference*$to_half_radians);
	my $lat_aux = sin ($lat_difference*$to_half_radians);
	$long_aux *= $long_aux;
	$lat_aux *= $lat_aux;
	# Temporary value to make sorter the asin formula.
	my $asinaux = sqrt($lat_aux + cos($last_latitude*$to_radians) * cos($latitude*$to_radians) * $long_aux );
	# Assure the aux value is not greater than 1 
	if ($asinaux > 1) { $asinaux = 1; }
	# We use: asin(x)  = atan2(x, sqrt(1-x*x))
	my $dist_in_rad = 2.0 * atan2($asinaux, sqrt (1 - $asinaux * $asinaux));
	my $dist_in_meters = $earth_radius_in_meters * $dist_in_rad;
		
	logger($pa_config, "Distance moved:" . $dist_in_meters ." meters", 10);

	return $dist_in_meters;
}

##########################################################################
=head2 C<< get_revesrse_geoip_sql (I<$pa_config>, I<$ip_addr>, I<$dbh>) >> 

Gets the GIS information obtained from the B<SQL> Database:

B<Returns>: I<undef> if there is not information available or a B<hash> with:
 * I<country_code>
 * I<country_code3>
 * I<country_name>
 * I<region>
 * I<city>
 * I<postal_code>
 * I<longitude>
 * I<latitude>
 * I<metro_code>
 * I<area_code>

=cut
##########################################################################
sub get_reverse_geoip_sql($$$) {
	my ($pa_config,$ip_addr, $dbh) = @_;
	
	my $id_range =  get_db_value($dbh,
		'SELECT ' . $RDBMS_QUOTE . 'id_range' . $RDBMS_QUOTE . '
		FROM tgis_reverse_geoip_ranges
		WHERE INET_ATON(?) >=  ' . $RDBMS_QUOTE . 'first_IP_decimal' . $RDBMS_QUOTE . '
			AND INET_ATON(?) <=  ' . $RDBMS_QUOTE . 'last_IP_decimal ' . $RDBMS_QUOTE . '
			LIMIT 1', $ip_addr, $ip_addr);
	
	if (defined($id_range)) {
		logger($pa_config,"Range id of '$ip_addr' is '$id_range'", 8);
		my $region_info = get_db_single_row($dbh,
			'SELECT *
			FROM tgis_reverse_geoip_info
			WHERE  ' . $RDBMS_QUOTE . 'id_range ' . $RDBMS_QUOTE . ' = ?',
			$id_range);
		
		logger($pa_config, "region info of id_range '$id_range' is: country:".$region_info->{'country_name'}." region:".$region_info->{'region'}." city:".$region_info->{'city'}." longitude:".$region_info->{'longitude'}." latitude:".$region_info->{'longitude'}, 8);
		
		return $region_info;
	}
	return undef;
}

##########################################################################
=head2 C<< get_reverse_geoip_file (I<$pa_config>, I<$ip_addr>) >> 

Gets GIS information from the MaxMind GeooIP database on file using the
GPL perl API from MaxMindGeoIP

B<Returns>: I<undef> if there is not information available or a B<hash> with:
 * I<country_code>
 * I<country_code3>
 * I<country_name>
 * I<region>
 * I<city>
 * I<postal_code>
 * I<longitude>
 * I<latitude>
 * I<metro_code>
 * I<area_code>

=cut
##########################################################################
sub get_reverse_geoip_file($$) {
	my ($pa_config,$ip_addr) = @_;
	if ($geoIPPurePerlavilable == 1) {
		my $geoipdb = PandoraFMS::GeoIP->open( $pa_config->{'recon_reverse_geolocation_file'}); 
		if (defined($geoipdb)) {
    		my $region_info = $geoipdb->get_city_record_as_hash($ip_addr);	
    		logger($pa_config, "Region info found for IP '$ip_addr' is: country:".$region_info->{'country_name'}." region:".$region_info->{'region'}." city:".$region_info->{'city'}." longitude:".$region_info->{'longitude'}." latitude:".$region_info->{'latitude'}, 8);
			return $region_info;
		}
		else {
    		logger($pa_config, "WARNING: Can't open reverse geolocation file ($pa_config->{'recon_reverse_geolocation_file'}) :$!",8);
		}
	}

	return undef;
}

##########################################################################
=head2 C<< get_random_close_point(I<$pa_config>, I<$center_longitude>, I<$center_latitude>) >> 

Gets the B<Longitude> and the B<Laitiutde> of a random point in the surroundings of the 
coordintaes received (I<$center_longitude>, I<$center_latitude>).

Returns C<< (I<$longitude>, I<$laitiutde>) >>
=cut
##########################################################################
sub get_random_close_point ($$$) {
	my ($pa_config, $center_longitude, $center_latitude) = @_;
	
	my $sign = int rand(2);
	my $longitude = ($sign*(-1)+(1-$sign)) * rand($pa_config->{'recon_location_scatter_radius'}/$earth_radius_in_meters)*$to_degrees;
	logger($pa_config,"Longitude random offset '$longitude' ", 8);
	$longitude += $center_longitude;
	logger($pa_config,"Longitude with random offset '$longitude' ", 8);
	$sign = int rand(2);
	my $latitude = ($sign*(-1)+(1-$sign)) * rand($pa_config->{'recon_location_scatter_radius'}/$earth_radius_in_meters)*$to_degrees;
	logger($pa_config,"Longitude random offset '$latitude' ", 8);
	$latitude += $center_latitude;
    logger($pa_config,"Latiitude with random offset '$latitude' ", 8);
	return ($longitude, $latitude);
}

# End of function declaration
# End of defined Code

1;
__END__

=head1 DEPENDENCIES

L<PandoraFMS::DB>, L<PandoraFMS::Tools> (Optional L<Geo::IP::PurePerl> to use file reverse geolocation database that is faster than the SQL)

=head1 LICENSE

This is released under the GNU Lesser General Public License.

=head1 SEE ALSO

L<PandoraFMS::DB>, L<PandoraFMS::Tools>

=head1 COPYRIGHT

Copyright (c) 2005-2010 Artica Soluciones Tecnologicas S.L

=cut
