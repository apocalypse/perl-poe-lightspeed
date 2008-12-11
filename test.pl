# Debugging stuff
sub POE::Component::Lightspeed::Server::DEBUG () { 1 }
sub POE::Component::Lightspeed::Router::DEBUG () { 1 }
sub POE::Kernel::ASSERT_DEFAULT () { 1 }
sub POE::Session::ASSERT_DEFAULT () { 1 }

use lib './lib';
use POE;

$|++;

# Load the required components
require POE::Component::Lightspeed::Server;
	
# Initializes it
POE::Component::Lightspeed::Server->spawn( 'SSLKEYCERT' => [ 'public-key.pem', 'public-cert.pem' ], 'AUTHCLIENT' => \&AuthClient, 'PASSWORD' => 'baz', 'KERNEL' => 'MainServer', 'ADDRESS' => 'localhost' );

use Carp 'confess'; $SIG{__DIE__} = \&confess;

# Start POE
POE::Kernel->run();

sub AuthClient {
	my( $localaddr, $localport, $remoteaddr, $remoteport ) = @_;
	
	print "AUTH REQ: $localaddr/$localport FROM $remoteaddr/$remoteport\n";
	
	return 1;
}
