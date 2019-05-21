#include "Server.h"
#include <boost/thread/mutex.hpp>
#include <iostream>
#include <boost/bind.hpp>
#include <boost/thread.hpp>

using namespace std;
using namespace boost::asio;
using namespace boost::asio::ip;

Server::Server( int port )
	:NetworkNode( SERVER_TYPE ), endpoint( tcp::endpoint( tcp::v4(), port ) ),
	acceptor( tcp::acceptor( service, endpoint ) )
{
}


Server::~Server()
{
}

void Server::listen()
{
	acceptor = tcp::acceptor( service, endpoint );
	socket = tcp::socket( service );
	cout << "Listening carefully..." << endl;
	acceptor.listen();
	acceptor.async_accept( socket, boost::bind( &Server::connectHandler, this, _1 ) );
	boost::thread serviceThread( boost::bind( &boost::asio::io_service::run, &service ) );
}

void Server::disconnect()
{
}



