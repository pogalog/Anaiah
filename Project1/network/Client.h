#pragma once


#include "Network.h"
#include "NetworkNode.h"
#include <conio.h>
#include <string>
#include <array>


class Client : public NetworkNode
{
public:
	Client();
	~Client();

	void connect( std::string address, int port );
	void disconnect();

protected:

	void resolveHandler( const boost::system::error_code &ec, boost::asio::ip::tcp::resolver::iterator it );


	bool handshake;
	std::string address;

};
