-- Network System
-- Maintains core networking structures
Network = {};
Network.SERVER_TYPE = 0;
Network.CLIENT_TYPE = 1;


require( "binaryio.processing" );
require( "network.processing" );
require( "network.latency" );
require( "network.exec" );

require( "network.delay" );
require( "structure.queue" );
Network.DelayBuffer = createQueue();


Network.Established = false;
Network.Buffer = Binary.createBuffer();



function Network.sendString( buffer )
	buffer.finalize();
	Network_send( Network.userdata, buffer.data );
end


function Network.send()
	Network.Buffer.finalize();
	Network_send( Network.userdata, Network.Buffer.data );
	Network.Buffer.reset();
end


-- For the DelayBuffer
local function checkDelayBuffer()
	for i = Network.DelayBuffer.length(), 1, -1 do
		local delay = Network.DelayBuffer.peek(i);
		delay.update();
		if( delay.finished() ) then
			Network.DelayBuffer.data.removeIndex(i);
		end
	end
end

function Network.receive()
--	checkDelayBuffer();
	
	local data = Network_receive( Network.userdata );
--	if( data == nil or string.len( data ) == 0 ) then return; end
	
--	local delay = createDelay( data );
--	Network.DelayBuffer.enqueue( delay );
	Network.processString( data );
end





function Network.createNetwork( userdata )
	Network.userdata = userdata;
	Network.Established = true;
	Network.type = Network_getType( userdata );
end


function Network.isServer()
	return Network.type == Network.SERVER_TYPE;
end


function Network.isAIEligible()
	return Network.type == Network.SERVER_TYPE or Network.type == -1;
end


function Network.checkNetwork()
	if( Network.Established == false ) then return; end
	Network_checkConnection( Network.userdata );
end


function Network.connectionEstablished( remoteIP )
	print( "Connected to " .. remoteIP );
	UI.getActiveMenu().callback_Single();
end

function Network.connectionFailed( message )
	print( "Connection failed: " .. message );
end