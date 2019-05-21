#pragma once

#include "network.h"
#include "NetworkNode.h"
#include <conio.h>


class Server : public NetworkNode
{
public:
	Server( int port );
	~Server();

	void listen();
	void disconnect();


	


protected:

	boost::asio::ip::tcp::endpoint endpoint;
	boost::asio::ip::tcp::acceptor acceptor;
};

