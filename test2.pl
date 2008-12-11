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
POE::Component::Lightspeed::Client->spawn( 'USESSL' => 1, 'PASSWORD' => 'baz', 'KERNEL' => 'MainServer-Client1', 'ADDRESS' => 'localhost', 'CONNECTED' => 'poe://*/TEST/post1' );

use Carp 'confess'; $SIG{__DIE__} = \&confess;

# Start POE
POE::Kernel->run();
