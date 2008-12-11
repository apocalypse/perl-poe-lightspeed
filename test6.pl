# Debugging stuff
#sub POE::Component::Lightspeed::Client::DEBUG () { 1 }
#sub POE::Component::Lightspeed::Router::DEBUG () { 0 }
sub POE::Kernel::ASSERT_DEFAULT () { 1 }
sub POE::Session::ASSERT_DEFAULT () { 1 }

use lib './lib';
use POE;

# Load the required components
require POE::Component::Lightspeed::Client;

# Initializes it
POE::Component::Lightspeed::Client->spawn( 'KERNEL' => 'SecondServer-Client1', 'ADDRESS' => 'localhost', 'PORT' => 5555 );

use Carp 'confess'; $SIG{__DIE__} = \&confess;
use Data::Dumper;

use POE::Component::Client::HTTP;
use HTTP::Request;
POE::Component::Client::HTTP->spawn(
    Alias     => 'ua',
);

# Fire up some introspection
use POE::Component::Lightspeed::Introspection qw( list_states list_kernels list_sessions );

# Create our own session for message-passing
POE::Session->create(
	'inline_states'	=>	{
		'_start'	=>	sub {
			$_[KERNEL]->alias_set( 'TEST' );
			$_[KERNEL]->delay_set( 'doit', 10 );
		},
		'_stop'		=>	sub {},
		'doit'		=>	sub {
			$_[KERNEL]->post( 'poe://MainServer-Client2/TEST/post1', 'floo' );
		},
		'post1'		=>	sub {
			my( @args ) = @_[ ARG0 .. $#_ ];
			print "post1 from " . $_[SENDER]->ID . " -> @args\n";
			
			# Checking out introspection
			print "Kernels:" . join( ' ,', @{ list_kernels() } ), "\n";
			list_sessions( $_[SENDER], 'poe://SecondServer-Client1/TEST/got_sessions' );
			list_states( 'poe://*/*', 'poe://SecondServer-Client1/TEST/got_states' );
			
			return 1;
		},
		'call1'		=>	sub {
			my( @args ) = @_[ ARG0 .. $#_ ];
			print "call1 from " . $_[SENDER]->ID . " -> @args\n";

			$_[KERNEL]->post( $_[SENDER], 'post1', 'RETURN FROM CALL' );
			$_[KERNEL]->post( $_[SENDER]->ID, 'post1', 'RETURN FROM CALL WITH ID' );

			return ( 'foo', 'barz' );
		},
		'got_sessions'	=>	sub {
			print "Got sessions from $_[ARG0]\n";
			print Data::Dumper::Dumper( $_[ARG1] );
		},
		'got_states'	=>	sub {
			print "Got states from $_[ARG0]\n";
			print Data::Dumper::Dumper( $_[ARG1] );
		},
	},
);

# Start POE
POE::Kernel->run();
