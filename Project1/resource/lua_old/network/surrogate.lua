-- Surrogate Networking (for single player)
_G.net = {};

net.processString = function( string )
end

net.createNetwork = function( userdata )
	local network = {};
	network.userdata = userdata;
	network.type = -1;
	
	function network.isServer()
		return true;
	end
	
	return network;
end
	


-- SEND Functions
net.sentLatencyRequest = function()
	net.responded = true;
end

net.sendActionRequest = function( id, timestamp )
	actionApproved( id );
end

net.sendActionStart = function( actionSet )
end

net.sendActionCompleted = function()
end
