#pragma once


#include "lua/lua_util.h"
#include "network/Server.h"
#include "network/Client.h"
#include "network/NetworkListener.h"

#include <boost/asio.hpp>
#include <iostream>
#include <array>

namespace lua_network
{
	using namespace boost::asio;
	using namespace boost::asio::ip;
	using namespace std;


	class LuaNetwork : public NetworkListener
	{
	public:
		LuaNetwork( lua_State *L ) : L(L) {}

		void connectionEstablished( string ipAddress )
		{
			connected = true;
			error = false;
			this->ipAddress = ipAddress;
		}

		void connectionFailed( const boost::system::error_code &ec )
		{
			error = true;
			connected = false;
			errorMessage = ec.message();
		}

		lua_State* getLuaState() { return L; }
		bool isConnected() { return connected; }
		bool hasError() { return error; }
		string getIPAddress() { return ipAddress; }
		string getErrorMessage() { return errorMessage; }

	private:
		lua_State *L;
		bool connected, error;
		string ipAddress, errorMessage;
	};


	int serverListen( lua_State *L )
	{
		int port = lua_tonumber( L, 1 );
		Server *server = new Server( port );
		LuaNetwork *listener = new LuaNetwork( L );
		server->addListener( listener );
		server->listen();

		lua_pushlightuserdata( L, server );
		return 1;
	}


	int clientConnect( lua_State *L )
	{
		string address = string( lua_tostring( L, 1 ) );
		int port = lua_tonumber( L, 2 );
		Client *client = new Client();
		LuaNetwork *listener = new LuaNetwork( L );
		client->addListener( listener );
		client->connect( address, port );

		lua_pushlightuserdata( L, client );
		return 1;
	}

	int send( lua_State *L )
	{
		NetworkNode *node = (NetworkNode*)lua_touserdata( L, 1 );
		size_t len = lua_rawlen( L, 2 );
		const char *data = lua_tolstring( L, 2, &len );
		if( node == NULL ) return 0;
		node->send( data, len );

		return 0;
	}

	int receive( lua_State *L )
	{
		NetworkNode *node = (NetworkNode*)lua_touserdata( L, 1 );
		if( node == NULL || node->isBufferChecked() )
		{
			lua_pushnil( L );
			return 1;
		}
		char *data = node->getData();

		lua_pushlstring( L, data, node->getReadSize() );
		return 1;
	}

	int checkConnection( lua_State *L )
	{
		NetworkNode *node = (NetworkNode*)lua_touserdata( L, 1 );
		if( node == NULL ) return 0;

		for( vector<NetworkListener*>::iterator it = node->getListeners().begin(); it != node->getListeners().end(); ++it )
		{
			NetworkListener *nl = *it;
			LuaNetwork *ln = (LuaNetwork*)nl;
			if( ln->isConnected() )
			{
				lua_getglobal( L, "Network" );
				lua_getfield( L, -1, "connectionEstablished" );
				lua_pushstring( L, ln->getIPAddress().c_str() );
				lua_call( L, 1, 0 );
			}
			else
			{
				if( ln->hasError() )
				{
					lua_getglobal( L, "Network" );
					lua_getfield( L, -1, "connectionFailed" );
					lua_pushstring( L, ln->getErrorMessage().c_str() );
					lua_call( L, 1, 0 );
				}
			}
		}

		return 0;
	}

	int getType( lua_State *L )
	{
		NetworkNode *node = (NetworkNode*)lua_touserdata( L, 1 );
		if( node == NULL )
		{
			lua_pushnumber( L, -1 );
			return 1;
		}

		lua_pushnumber( L, node->getType() );
		return 1;
	}


	void registerFunctions( lua_State *L )
	{
		lua::registerLuacFunction( L, "Server_listen", serverListen );
		lua::registerLuacFunction( L, "Client_connect", clientConnect );
		lua::registerLuacFunction( L, "Network_send", send );
		lua::registerLuacFunction( L, "Network_receive", receive );
		lua::registerLuacFunction( L, "Network_checkConnection", checkConnection );
		lua::registerLuacFunction( L, "Network_getType", getType );
	}
}