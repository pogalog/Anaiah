require( "game.unit_path" );


-- Network Processing Center
_G.net = {};


-- Processing constants
net.LATENCY = 1;
net.LATENCY_RESPONSE = 2;
net.LATENCY_REPORT = 3;
net.TIMER_RESET = 4;
net.ACTION_REQUESTED = 5;
net.ACTION_DENIED = 6;
net.ACTION_APPROVED = 7;
net.ACTION_STARTED = 8;
net.ACTION_COMPLETED = 9;
net.PHASE_CHANGE = 10;

net.SERVER_TYPE = 0;
net.CLIENT_TYPE = 1;

function net.createNetwork( userdata )
	local network = {};
	network.userdata = userdata;
	network.type = Network_getType( userdata );
	
	function network.isServer()
		return network.type == net.SERVER_TYPE;
	end
	
	function network.isAIEligible()
		return network.type == net.SERVER_TYPE or network.type == -1;
	end
	
	return network;
end

	


function net.createBuffer()
	local buffer = {};
	buffer.data = "";
	
	return buffer;
end

-- CONNECT Functions
function checkNetwork()
	if( Network == nil ) then return; end
	Network_checkConnection( Network.userdata );
end

function connectionEstablished( remoteIP )
	print( "Connected to " .. remoteIP );
	UIReg.activeUI.menu.callback_Single();
end

function connectionFailed( message )
	print( "Connection failed: " .. message );
end


-- RECEIVE Functions
function net.processString( string )
	if( string == nil ) then return; end
	if( string.len( string ) == 0 ) then return; end
	
	io_reset();
	local messageType = readByte( string );
	if( messageType == net.LATENCY ) then
		net.sendLatencyResponse();
		return;
	elseif( messageType == net.LATENCY_RESPONSE ) then
		net.responded = true;
		return;
	elseif( messageType == net.LATENCY_REPORT ) then
		net.reported = true;
		return;
	elseif( messageType == net.TIMER_RESET ) then
		net.timerReset(0);
		return;
	elseif( messageType == net.ACTION_REQUESTED ) then
		net.processRequest( string );
		return;
	elseif( messageType == net.ACTION_DENIED ) then
		local actionID = readInt( string );
		actionDenied( actionID );
		return;
	elseif( messageType == net.ACTION_APPROVED ) then
		local actionID = readInt( string );
		actionApproved( actionID );
		return;
	elseif( messageType == net.ACTION_STARTED ) then
		net.processActionStart( string );
		return;
	elseif( messageType == net.ACTION_COMPLETED ) then
		remoteActionFinished();
		return;
	elseif( messageType == net.PHASE_CHANGE ) then
		net.processPhaseChange( string );
		return;
	end
end

-- only the server should ever have a non-zero offset
function net.timerReset( latencyOffset )
	Global_T0 = Global_clock;
	Global_time = t - latencyOffset;
end

function net.processRequest( string )
	local unitID = readInt( string );
	local timestamp = readFloat( string );
	processRequest( unitID, timestamp );
end

function net.processActionStart( string )
	remoteActionStarted();
	
	local containsMove = readBool( string );
	if( containsMove ) then
		local data = {};
		data.unitID = readInt( string );
		data.unit = LevelMap.getUnitByID( data.unitID );
		if( data.unit == nil ) then
			generateWarning( "Received (network) invalid unit ID (" .. data.unitID .. ")", "network::net_proc.lua::net::processUnitMove" );
			return;
		end

		local pathLen = readInt( string );
		data.path = createPath();

		for i = 1, pathLen do
			local address = readVec2i( string );
			local pvd = unpackInt( string );
			local tile = LevelMap.grid.getTile( address );
			if( tile == nil ) then
				generateWarning( "Received (network) invalid tile address for path (" .. address.x .. ", " .. address.y .. ")", "network::net_proc.lua::net::processUnitMove" );
				return;
			end
			data.path.addTileRemote( tile, pvd );
		end

		local unitPath = createUnitPath( data.unit, data.path );
		local action = createRemoteMoveAction( unitPath );
		RemoteQueue.enqueue( action );
	end
	
	local containsAction = readBool( string );
	if( containsAction ) then
		local actionID = readByte( string );
		local unitID = readInt( string );
		local targetID = readInt( string );
		local unit = LevelMap.getUnitByID( unitID );
		local target = LevelMap.getUnitByID( targetID );
		
		local hasError = false;
		if( unit == nil ) then
			generateWarning( "Received instruction for invalid unitID (" .. unitID .. ")", "network/net_proc.lua::processActionStart" );
			hasError = true;
		end
		if( target == nil ) then
			generateWarning( "Received instruction for invalid targetID (" .. targetID .. ")", "network/net_proc.lua::processActionStart" );
			hasError = true;
		end
		if( hasError ) then
			return;
		end
		
		local action = nil;
		if( actionID == ACTION_ATTACK ) then
			local atkSuccess = readBool( string );
			local timeConsumed = readFloat( string );
			local atkDamage = readInt( string );
			print( "RX ATTACK! " .. tostring( atkSuccess ) .. ", " .. tostring( atkDamage ) );
			local atkData = {};
			atkData.damage = atkDamage;
			atkData.success = atkSuccess;
			atkData.unit = unit;
			atkData.target = target;
			atkData.timeConsumed = timeConsumed;
			action = createRemoteAttackAction( atkData );
		elseif( actionID == ACTION_ITEM ) then
			local itemID = readInt( string );
			local itemSuccess = readBool( string );
			local timeConsumed = readFloat( string );
			if( itemSuccess ) then
				local itemData = {};
				itemData.item = Items[itemID];
				itemData.unit = unit;
				itemData.target = target;
				itemData.timeConsumed = timeConsumed;
				action = createRemoteItemAction( itemData );
				action.events.add( createActionEvent( action, 2.8, action.useFunc ) );
			end
		else
			generateWarning( "Received non-existant action type (" .. actionID .. ")", "network/net_proc.lua::processActionStart" );
			return;
		end
		
		
		RemoteQueue.enqueue( action );
	end
	
	RemoteQueue.commit();
end



function net.processPhaseChange( string )
	
end

-- Construct binary string from packet data
-- Data from packet are interpreted to determine its structure
function net.createBinaryString( packet )
	local data = "";
	data = data .. string.char( packet.messageType );
	return data;
end



-- SEND Functions
function net.sentLatencyRequest()
	local buffer = net.createBuffer();
	writeByte( buffer, net.LATENCY );
	net.sendString( buffer );
end

function net.sendLatencyResponse()
	local buffer = net.createBuffer();
	writeByte( buffer, net.LATENCY_RESPONSE );
	net.sendString( buffer );
end


function net.sendUnitMove( unit, path )
	local buffer = net.createBuffer();
	writeByte( buffer, net.UNIT_MOVED );
	writeInt( buffer, unit.unitID );
	writeInt( buffer, path.vpath.length() );
	for i = 1, path.vpath.length() do
		local address = path.vpath.get(i);
		local tile = path.path.get(i);
		writeVec2i( buffer, address );
		writeInt( buffer, tile.pathValDir );
	end
	
	net.sendString( buffer );
end

function net.sendActionRequest( id, timestamp )
	print( "tx ACTION_REQUESTED" );
	local buffer = net.createBuffer();
	writeByte( buffer, net.ACTION_REQUESTED );
	writeInt( buffer, id );
	writeFloat( buffer, timestamp );
	net.sendString( buffer );
end

function net.sendActionDenial( actionID )
	print( "tx ACTION_DENIED" );
	local buffer = net.createBuffer();
	writeByte( buffer, net.ACTION_DENIED );
	writeInt( buffer, actionID );
	net.sendString( buffer );
end

function net.sendActionApproval( actionID )
	print( "tx ACTION_APPROVED" );
	local buffer = net.createBuffer();
	writeByte( buffer, net.ACTION_APPROVED );
	writeInt( buffer, actionID );
	net.sendString( buffer );
end

function net.sendActionStart( actionSet )
	print( "tx ACTION_STARTED" );
	local buffer = net.createBuffer();
	writeByte( buffer, net.ACTION_STARTED );
	local hasMove = actionSet.move ~= nil;
	writeBool( buffer, hasMove );
	if( hasMove ) then
		local unit = actionSet.move.unit;
		local path = actionSet.move.unitPath.path;
		writeInt( buffer, unit.unitID );
		writeInt( buffer, path.vpath.length() );
		for i = 1, path.vpath.length() do
			local address = path.vpath.get(i);
			local tile = path.path.get(i);
			writeVec2i( buffer, address );
			writeInt( buffer, tile.pathValDir );
		end
	end
	
	local hasAction = actionSet.action ~= nil;
	writeBool( buffer, hasAction );
	if( hasAction ) then
		local action = actionSet.action;
		writeByte( buffer, action.type );
		writeInt( buffer, action.unit.unitID );
		writeInt( buffer, action.targetUnit.unitID );
		if( action.type == ACTION_ATTACK ) then
			writeBool( buffer, action.data.success );
			writeFloat( buffer, action.data.timeConsumed );
			writeInt( buffer, action.data.damage );
		elseif( action.type == ACTION_ITEM ) then
			writeInt( buffer, action.item.id );
			writeBool( buffer, action.data.success );
			writeFloat( buffer, action.data.timeConsumed );
		end
	end
	net.sendString( buffer );
end

function net.sendActionCompleted()
	print( "tx ACTION_COMPLETED" );
	local buffer = net.createBuffer();
	writeByte( buffer, net.ACTION_COMPLETED );
	net.sendString( buffer );
end

function net.sendString( bin )
	finalizeBuffer( bin );
	Network_send( Network.userdata, bin.data );
end




