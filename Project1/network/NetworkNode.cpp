#include "NetworkNode.h"
#include "NetworkListener.h"

using namespace std;
using namespace boost::asio;
using namespace boost::asio::ip;

NetworkNode::NetworkNode( NodeType type )
	:type( type ), service(), socket( boost::asio::ip::tcp::socket( service ) )
{

}

NetworkNode::~NetworkNode()
{

}

void NetworkNode::send( const char *data, size_t numBytes )
{
	async_write( socket, buffer( data, numBytes ), boost::bind( &NetworkNode::writeHandler, this, _1, _2 ) );
	//socket.async_write_some( buffer( data, numBytes ), boost::bind( &NetworkNode::writeHandler, this, _1, _2 ) );
}

void NetworkNode::receive()
{
	socket.async_read_some( buffer( bytes ), boost::bind( &NetworkNode::readHandler, this, _1, _2 ) );
}



char* NetworkNode::getData()
{
	char *dat = new char[readSize];
	std::memcpy( dat, bytes.data(), readSize );
	bytes = array<char, 4096>();
	bufferChecked = true;
	return dat;
}



// private
void NetworkNode::connectHandler( const boost::system::error_code &ec )
{
	if( !ec )
	{
		for( vector<NetworkListener*>::iterator it = listeners.begin(); it != listeners.end(); ++it )
		{
			NetworkListener *listener = *it;
			listener->connectionEstablished( socket.remote_endpoint().address().to_string() );
		}
		receive();
	}
	else
	{
		for( vector<NetworkListener*>::iterator it = listeners.begin(); it != listeners.end(); ++it )
		{
			NetworkListener *listener = *it;
			listener->connectionEstablished( socket.remote_endpoint().address().to_string() );
		}
	}
}

void NetworkNode::readHandler( const boost::system::error_code &ec, size_t bytesTransferred )
{
	if( !ec )
	{
		readSize = bytesTransferred;
		socket.async_read_some( buffer( bytes ), boost::bind( &NetworkNode::readHandler, this, _1, _2 ) );
		bufferChecked = false;
	}
	else
	{
		cout << "Socket Error: " << ec.message() << endl;
	}
}

void NetworkNode::writeHandler( const boost::system::error_code &ec, size_t bytesTransferred )
{
}