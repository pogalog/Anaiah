-- Binary IO Processing Utility
-- Provides low-level functions and utilities for reading and writing binary strings
Binary = {};


-- Constants and global util values
Binary.BIG_ENDIAN = 1;
Binary.LITTLE_ENDIAN = 2;
Binary.Int_Size = 4;
Binary.Float_Size = 4;
Binary.Byte_Size = 1;

-- local constants
local BIG_ENDIAN = Binary.BIG_ENDIAN;
local LITTLE_ENDIAN = Binary.LITTLE_ENDIAN;
local Int_Size = Binary.Int_Size;
local Float_Size = Binary.Float_Size;
local Byte_Size = Binary.Byte_Size;


-- Buffers are required for use of the herein defined utility functions
function Binary.createBuffer( data )
	local buffer = {};
	if( data == nil ) then
		buffer.data = {};
	else
		buffer.data = data;
	end
	buffer.table = {};
	buffer.pos = 1;
	buffer.byteOrder = Binary.LITTLE_ENDIAN;
	buffer.finalized = false;
	
	function buffer.advance( numBytes )
		buffer.pos = buffer.pos + numBytes;
	end
	
	function buffer.resetMarker()
		buffer.pos = 1;
	end
	
	function buffer.reset()
		buffer.table = {};
		buffer.data = "";
		buffer.resetMarker();
	end
	
	function buffer.setData( data )
		buffer.table = {};
		buffer.data = data;
		buffer.resetMarker();
	end
	
	function buffer.size()
		return buffer.finalized and string.len( buffer.data ) or 0;
	end
	
	function buffer.finalize()
		buffer.data = table.concat( buffer.table );
		buffer.finalized = true;
	end
	
	return buffer;
end


-- Utility Functions
function extractScriptName( filename )
	local msf = filename;
	local ls = 1;
	local lf = 1;
	while ls ~= nil do
		msf = string.sub( msf, lf+1 );
		ls, lf = string.find( msf, "/" )
	end
	return string.sub( msf, 1, -5 );
end


-- High Level Functions
function readString( buffer )
	local len = readInt( buffer );
	val = readString_m( buffer, len );
	return val;
end

function readVec2( buffer )
	return Vec2_new( readFloat( buffer ), readFloat( buffer ) );
end

function readVec2i( buffer )
	local x = readInt( buffer );
	local y = readInt( buffer );
	return Vec2_new( x, y );
end

function readVec3( buffer )
	return Vec3_new( readFloat( buffer ), readFloat( buffer ), readFloat( buffer ) );
end

function readVec3i( buffer )
	return Vec3_new( readInt( buffer ), readInt( buffer ), readInt( buffer ) );
end

function readVec4( buffer )
	return Vec4_new( readFloat( buffer ), readFloat( buffer ), readFloat( buffer ), readFloat( buffer ) );
end

function readVec4i( buffer )
	return Vec4_new( readInt( buffer ), readInt( buffer ), readInt( buffer ), readInt( buffer ) );
end

function readBool( buffer )
	local b = string.byte( buffer.data, buffer.pos );
	buffer.advance( Byte_Size );
	if( b == 0 ) then return false;
	else return true;
	end
end



-- Mid Level Functions
function readByte( buffer )
	local b = string.sub( buffer.data, buffer.pos, buffer.pos+1 );
	buffer.advance( Byte_Size );
	return string.byte( b );
end

function readInt( buffer )
	local b = string.sub( buffer.data, buffer.pos, buffer.pos+Int_Size-1 );

	buffer.advance( Int_Size );
	return Binary.byteArrayToInt( b );
end


function readFloat( buffer )
	local b = string.sub( buffer.data, buffer.pos, buffer.pos+Float_Size-1 );

	buffer.advance( Float_Size );
	return Binary.byteArrayToFloat( b );
end

function readString_m( buffer, len )
	local c = string.sub( buffer.data, buffer.pos, buffer.pos+len-1 );
	buffer.advance( len );
	return c;
end


-- Lower Level Functions
function Binary.byteArrayToFloat( bytes )
	local bits = 0;
	for i = 1, 4 do
		local power = 8*(4-i);
		local val = string.byte( bytes, 5-i ) * 2^power;
		bits = bits + val;
	end
	return Binary.intBitsToFloat( bits );
end


function Binary.byteArrayToInt( bytes )
	local MASK = 0x000000ff;
	local value = 0;
	for i = 1, 4 do
		local shift = (4-i) * 8;
		local v = (string.byte( bytes, 5-i ) & MASK) << shift;
		value = value + v;
	end
	
	return value;
end


function Binary.intToByteArray( param )
	local result = string.pack( "i4", param );
	return result;
end


function Binary.floatToByteArray( param )
	local result = string.pack( "f", param );
	return result;
end


-- Mid-level Output Functions
function writeByte( buffer, byte )
	table.insert( buffer.table, string.char( byte ) );
end

function writeBool( buffer, bool )
	if( bool ) then
		writeByte( buffer, 1 );
	else
		writeByte( buffer, 0 );
	end
end

function writeInt( buffer, int )
	local iba = Binary.intToByteArray( int );
	table.insert( buffer.table, iba );
end

function writeInts( buffer, ... )
	for k,v in pairs( {...} ) do
		writeInt( buffer, v );
	end
end

function writeFloat( buffer, float )
	local fba = Binary.floatToByteArray( float );
	table.insert( buffer.table, fba );
end


-- High-level Output Functions
function writeVec2i( buffer, v )
	writeInt( buffer, v.x );
	writeInt( buffer, v.y );
end

function writeVec2( buffer, v )
	writeFloat( buffer, v.x );
	writeFloat( buffer, v.y );
end

function writeString( buffer, s )
	writeInt( buffer, string.len( s ) );
	table.insert( buffer.table, s );
end



function Binary.finalizeBuffer( buffer )
	buffer.data = table.concat( buffer );
end


function unpackInt( buffer )
	local int = string.unpack( "i4", buffer.data, buffer.pos );
	buffer.advance( Int_Size );
	return int;
end

function unpackFloat( buffer )
	local float = string.unpack( "f", buffer.data, buffer.pos );
	buffer.advance( Float_Size );
	return float;
end

function unpackVec2i( buffer )
	local v = Vec2_new( unpackInt( buffer.data ), unpackInt( buffer.data ) );
	return v;
end



-- according to IEEE 754
function Binary.intBitsToFloat( bits )
	local s = bits >> 31;
	if( s == 0 ) then
		s = 1;
	else
		s = -1;
	end
	local e = (bits >> 23) & 0xff;
	local m;
	if( e == 0 ) then
		m = (bits & 0x7fffff) << 1;
	else
		m = (bits & 0x7fffff) | 0x800000;
	end
	return s * m * 2^(e-150);
end

