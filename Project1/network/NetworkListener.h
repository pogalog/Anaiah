#pragma once
#include <string>

class NetworkListener
{

public:
	virtual void connectionEstablished( std::string ipAddress ) = 0;
	virtual void connectionFailed( const boost::system::error_code &ec ) = 0;
};