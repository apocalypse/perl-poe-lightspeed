# Debugging stuff
#sub POE::Component::Lightspeed::Client::DEBUG () { 1 }
sub POE::Component::Lightspeed::Router::DEBUG () { 1 }
sub POE::Kernel::ASSERT_DEFAULT () { 1 }
sub POE::Session::ASSERT_DEFAULT () { 1 }

use lib './lib';
use POE;

# Load the required components
use POE::Component::Lightspeed::Client;

# Initializes it
POE::Component::Lightspeed::Client->spawn( 'PASSWORD' => 'baz', 'USESSL' => 1, 'KERNEL' => 'MainServer-Client2', 'ADDRESS' => 'localhost' );

use Carp 'confess'; $SIG{__DIE__} = \&confess;

# Client-HTTP testing
use HTTP::Request;
use HTTP::Response;

# Authenticate incoming client_http requests
use POE::Component::Lightspeed::Authentication qw( auth_register );
auth_register( 'post', \&AuthPost );
auth_register( 'call', \&AuthPost );
auth_register( 'callreply', \&AuthPost );

$|++;

sub AuthPost {
	my( $type, $ses, $state, $remote_ses ) = @_;
	
	print "Received $type request from " . $remote_ses->ID . " -> $ses / $state\n";
	
	# Allow only client_http requests
	if ( $state eq 'client_http' ) {
		return 1;
	} else {
		return 0;
	}
}	

# Create our own session for message-passing
POE::Session->create(
	'inline_states'	=>	{
		'_start'	=>	sub {
			$_[KERNEL]->alias_set( 'TEST' );
			$_[KERNEL]->delay_set( 'doit', 2 );
		},
		'_stop'		=>	sub {},
		'doit'		=>	sub {
			$_[KERNEL]->post( 'poe://SecondServer-Client1/TEST/post1', 'floo' );
			$_[KERNEL]->call( 'poe://SecondServer-Client1/TEST/call1', 'poe://MainServer-Client2/TEST/post1', 'foobarz' );

			# Client::HTTP test
			$_[KERNEL]->post( 'poe://SecondServer-Client1/ua/request', 'client_http', HTTP::Request->new( 'GET', 'http://192.168.1.1' ) );
		},
		'post1'		=>	sub {
			my( @args ) = @_[ ARG0 .. $#_ ];
			print "post1 from " . $_[SENDER]->ID . " -> @args\n";
			return 1;
		},
		'call1'		=>	sub {
			my( @args ) = @_[ ARG0 .. $#_ ];
			print "call1 from " . $_[SENDER]->ID . " -> @args\n";
			return ( 'foo', 'bar' );
		},
		'client_http'	=>	\&response_handler,
	},
);

  # This is the sub which is called when the session receives a
  # 'response' event.
  sub response_handler {
    my ($request_packet, $response_packet) = @_[ARG0, ARG1];

    # HTTP::Request
    my $request_object  = $request_packet->[0];

    # HTTP::Response
    my $response_object = $response_packet->[0];

    my $stream_chunk;
    if (! defined($response_object->content)) {
      $stream_chunk = $response_packet->[1];
    }

    print( "*" x 78, "\n",
           "*** my request:\n",
           "-" x 78, "\n",
           $request_object->as_string(),
           "*" x 78, "\n",
           "*** their response:\n",
           "-" x 78, "\n",
           $response_object->as_string(),
         );

    if (defined $stream_chunk) {
      print( "-" x 40, "\n",
             $stream_chunk, "\n"
           );
    }

    print "*" x 78, "\n";
    
    # Do it all over again!
    #$_[KERNEL]->yield( 'doit' );
  }

# Start POE
POE::Kernel->run();
