# Declare our package
package POE::Component::Lightspeed::Monitor;

# Standard stuff to catch errors
use strict qw(subs vars refs);				# Make sure we can't mess up
use warnings FATAL => 'all';				# Enable warnings to catch errors

# Initialize our version
our $VERSION = '1.' . sprintf( "%04d", (qw($Revision: 1082 $))[1] );

# Import what we need
use Carp qw( croak );

# Make sure the router instance is loaded no matter what
use POE::Component::Lightspeed::Router;

# Spawn the Router session to make sure :)
POE::Component::Lightspeed::Router->spawn();

# Set some constants
BEGIN {
	# Debug fun!
	if ( ! defined &DEBUG ) {
		eval "sub DEBUG () { 0 }";
	}
}

# We export some stuff
require Exporter;
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( monitor_register monitor_unregister );

# Our different "hooks"
our @HOOKS = qw( );

# End of module
1;
__END__
