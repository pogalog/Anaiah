#include "Client.h"
#include <boost/thread/mutex.hpp>
#include <boost/bind.hpp>
#include <boost/thread.hpp>
#include <cstdio>

using namespace std;
using namespace boost::asio;
using namespace boost::asio::ip;




//----Client--------------------
Client::Client()
	:NetworkNode( CLIENT_TYPE )
{
}

Client::~Client()
{
}


void Client::connect( string address, int port )
{
	this->address = address;
	this->port = port;
	string portNum = "" + boost::lexical_cast<string>(port);

	socket = tcp::socket( service );
	tcp::resolver res( service );
	tcp::resolver::query query( address, portNum );
	res.async_resolve( query, boost::bind( &Client::resolveHandler, this, _1, _2 ) );
	
	boost::thread serviceThread( boost::bind( &boost::asio::io_service::run, &service ) );
}


void Client::disconnect()
{
	socket.shutdown( tcp::socket::shutdown_send );
}



// private
void Client::resolveHandler( const boost::system::error_code &ec, tcp::resolver::iterator it )
{
	if( !ec )
	{
		socket.async_connect( *it, boost::bind( &Client::connectHandler, this, _1 ) );
	}
	else
	{
		cout << "Error: " << ec.message() << endl;
	}
}
