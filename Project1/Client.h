#pragma once

#ifndef CLIENT_H_
#define CLIENT_H_

#include "Network.h"
#include <conio.h>


class ClientConnection : public Connection
{
private:

private:
	void OnAccept( const std::string &host, uint16_t port );
	void OnConnect( const std::string &host, uint16_t port );
	void OnSend( const std::vector<uint8_t> &buffer );
	void OnRecv( std::vector<uint8_t> &buffer );
	void OnTimer( const boost::posix_time::time_duration &delta );
	void OnError( const boost::system::error_code &error );

public:
	ClientConnection( boost::shared_ptr<Hive> hive )
		: Connection( hive )
	{
	}

	~ClientConnection()
	{
	}
};

class Client
{
public:
	Client();
	~Client();

	void connect( const char *address, int port );
	void disconnect();

	boost::shared_ptr<Hive> hive;
	boost::shared_ptr<ClientConnection> connection;


private:

};

#endif