#pragma once

#include <boost/asio.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/enable_shared_from_this.hpp>
#include <boost/shared_ptr.hpp>


using boost::uint64_t;
using boost::uint32_t;
using boost::uint16_t;
using boost::uint8_t;

using boost::int64_t;
using boost::int32_t;
using boost::int16_t;
using boost::int8_t;


class Hive;
class Connection;

class Acceptor : public boost::enable_shared_from_this<Acceptor>
{
	friend class Hive;

private:
	boost::shared_ptr<Hive> m_hive;
	boost::asio::ip::tcp::acceptor m_acceptor;
	boost::asio::strand m_io_strand;
	boost::asio::deadline_timer m_timer;
	boost::posix_time::ptime m_last_time;
	int32_t m_timer_interval;
	volatile uint32_t m_error_state;

private:
	Acceptor( const Acceptor & rhs );
	Acceptor & operator =( const Acceptor & rhs );
	void StartTimer();
	void StartError( const boost::system::error_code & error );
	void DispatchAccept( boost::shared_ptr<Connection> connection );
	void HandleTimer( const boost::system::error_code & error );
	void HandleAccept( const boost::system::error_code & error, boost::shared_ptr<Connection> connection );

protected:
	Acceptor( boost::shared_ptr< Hive > hive );
	virtual ~Acceptor();

private:
	// Called when a connection has connected to the server. This function 
	// should return true to invoke the connection's OnAccept function if the 
	// connection will be kept. If the connection will not be kept, the 
	// connection's Disconnect function should be called and the function 
	// should return false.
	virtual bool OnAccept( boost::shared_ptr<Connection> connection, const std::string & host, uint16_t port ) = 0;

	// Called on each timer event.
	virtual void OnTimer( const boost::posix_time::time_duration & delta ) = 0;

	// Called when an error is encountered. Most typically, this is when the
	// acceptor is being closed via the Stop function or if the Listen is 
	// called on an address that is not available.
	virtual void OnError( const boost::system::error_code & error ) = 0;

public:
	// Returns the Hive object.
	boost::shared_ptr<Hive> GetHive();

	// Returns the acceptor object.
	boost::asio::ip::tcp::acceptor & GetAcceptor();

	// Returns the strand object.
	boost::asio::strand & GetStrand();

	// Sets the timer interval of the object. The interval is changed after 
	// the next update is called. The default value is 1000 ms.
	void SetTimerInterval( int32_t timer_interval_ms );

	// Returns the timer interval of the object.
	int32_t GetTimerInterval() const;

	// Returns true if this object has an error associated with it.
	bool HasError();

public:
	// Begin listening on the specific network interface.
	void Listen( const std::string & host, const uint16_t & port );

	// Posts the connection to the listening interface. The next client that
	// connections will be given this connection. If multiple calls to Accept
	// are called at a time, then they are accepted in a FIFO order.
	void Accept( boost::shared_ptr< Connection > connection );

	// Stop the Acceptor from listening.
	void Stop();
};
