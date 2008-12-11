# Debugging stuff
sub POE::Component::Lightspeed::Client::DEBUG () { 1 }
sub POE::Component::Lightspeed::Router::DEBUG () { 1 }
sub POE::Kernel::ASSERT_DEFAULT () { 1 }
sub POE::Session::ASSERT_DEFAULT () { 1 }

use lib './lib';
use POE;

# Load the required components
require POE::Component::Lightspeed::Client;
	
# Initializes it
POE::Component::Lightspeed::Client->spawn( 'KERNEL' => 'LinkClient', 'ADDRESS' => 'localhost', 'PORT' => 5555 );
POE::Component::Lightspeed::Client->spawn( 'USESSL' => 1, 'PASSWORD' => 'baz', 'KERNEL' => 'LinkClient', 'ADDRESS' => 'localhost' );

# Connect to the main server after 3 seconds
POE::Session->create(
	'inline_states'		=>	{
		'_start'	=>	sub {
#			$_[KERNEL]->delay_set( 'connect', 3 );
		},
		'_child'	=>	sub {},
		'_stop'		=>	sub {},
		'connect'	=>	sub {	POE::Component::Lightspeed::Client->spawn( 'KERNEL' => 'LinkClient', 'ADDRESS' => 'localhost' ); },
	},
);

use Carp 'confess'; $SIG{__DIE__} = \&confess;

# Start POE
POE::Kernel->run();
