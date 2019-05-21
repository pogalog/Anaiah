#pragma once

#include <boost/asio.hpp>
#include <boost/bind.hpp>
#include <array>
#include <vector>
#include <string>
#include <iostream>


enum NodeType
{
	SERVER_TYPE = 0,
	CLIENT_TYPE = 1
};

class NetworkListener;
class NetworkNode
{
public:
	NetworkNode( NodeType type );
	~NetworkNode();

	void send( const char *data, size_t numBytes );
	void receive();


	// mutator
	void addListener( NetworkListener *listener ) { listeners.push_back( listener ); }

	// accessor
	NodeType getType() { return type; }
	int getPort() { return port; }
	int getReadSize() { return readSize; }
	char* getData();
	bool isBufferChecked() { return bufferChecked; }
	std::vector<NetworkListener*>& getListeners() { return listeners; }


protected:

	void connectHandler( const boost::system::error_code &ec );
	void readHandler( const boost::system::error_code &ec, size_t bytesTransferred );
	void writeHandler( const boost::system::error_code &ec, size_t bytesTransferred );

	NodeType type;
	int port;

	size_t readSize;
	bool bufferChecked;
	boost::asio::io_service service;
	boost::asio::ip::tcp::socket socket;
	std::array<char, 4096> bytes;
	std::vector<NetworkListener*> listeners;
};

