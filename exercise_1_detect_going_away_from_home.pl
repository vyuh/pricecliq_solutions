use strict;
use warnings;
use autodie;

my $g_lat, $g_long;    # Globals

sub update_passenger_data {

    #passenger data passed as argument
    my $p_data = shift;

    #home coordinates
    my ( $p_lat, $p_long ) =
      @{ $p_data->{home} }{qw(lat long)};

    #TODO update globals every second with some mock data
    #for testing

    # save current distance from home
    # in passenger data
    # prepend in distance array
    unshift
      @{ $p_data->{distance} },
      distance_between( $g_lat, $g_long, $p_lat, $p_long );

    #TODO handle other status changes like arrival

    #return
    $p_data;
}

sub going_away_from_home_v0 {

    my %DETOUR_THRESHOLD = (
        time     => 600,    #home distance not reduced in 10 minutes
        distance => 1000    #home distance inreased by 1km in one stretch
    );

    #passenger data passed as argument
    my $p_data = shift;

    # distance log every second
    my @distance                   = @{ $p_data->{distance} };
    my $no_distance_decrease_count = 0;

    # find the time distance has not decreased
    $no_distance_decrease_count++
      while (
        ( $no_distance_decrease_count < @distance )
        && ( $distance[$no_distance_decrease_count] >=
            $distance[ $no_distance_decrease_count + 1 ] )
      );

    #check with thresholds and return accordingly
    ( $no_distance_decrease_count >= $DETOUR_THRESHOLD{time} )
      || ( $distance[0] - $distance[ $no_distance_decrease_count - 1 ] >=
        $DETOUR_THRESHOLD{distance} );

}

sub going_away_from_home_v1 {

    #TODO moving average over various windows
    #with thresholds for each average
}

#Test with example data
sub test_going_away_from_home_v0 {

    #some mock data
    my $passenger_data = {
        home => {
            lat  => 28.644800,
            long => 77.216721
        },
        distance => [],
        arrived  => undef
    };
    unless ( $passenger_data->{arrived} ) {
        sleep 60;
        update_passenger_data $passenger_data;
        going_away_from_home_v2 $passenger_data;
    }
}
