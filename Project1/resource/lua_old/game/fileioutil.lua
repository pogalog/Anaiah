-- binary IO util

-- constants and global util values
BIG_ENDIAN = 1;
LITTLE_ENDIAN = 2;
Byte_Order = LITTLE_ENDIAN;
Int_Size = 4;
Float_Size = 4;
Byte_Size = 1;

File_Pos = 1;


function getPosition()
	return File_Pos;
end

function io_reset()
	File_Pos = 1;
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
function readString( data )
	local len = readInt( data );
	val = readString_m( data, len );
	return val;
end

function readVec2( data )
	return createVec2( readFloat( data ), readFloat( data ) );
end

function readVec2i( data )
	local x = readInt( data );
	local y = readInt( data );
	return createVec2( x, y );
end

function readVec3( data )
	return createVec3( readFloat( data ), readFloat( data ), readFloat( data ) );
end

function readVec3i( data )
	return createVecc3( readInt( data ), readInt( data ), readInt( data ) );
end

function readVec4( data )
	return createVec4( readFloat( data ), readFloat( data ), readFloat( data ), readFloat( data ) );
end

function readVec4i( data )
	return createVec4( readInt( data ), readInt( data ), readInt( data ), readInt( data ) );
end

function readBool( data )
	local b = string.byte( data, File_Pos );
	File_Pos = File_Pos + 1;
	if( b == 0 ) then return false;
	else return true;
	end
end



-- Mid Level Functions
function readByte( data )
	local b = string.sub( data, File_Pos, File_Pos+1 );
	File_Pos = File_Pos + 1;
	return string.byte( b );
end

function readInt( data )
	local b = string.sub( data, File_Pos, File_Pos+Int_Size-1 );
	if( Byte_Order == LITTLE_ENDIAN ) then
		b = string.reverse( b );
	end

	File_Pos = File_Pos + Int_Size;
	return byteArrayToInt( b );
end


function readFloat( data )
	local b = string.sub( data, File_Pos, File_Pos+Float_Size-1 );
	if( Byte_Order == LITTLE_ENDIAN ) then
		b = string.reverse( b );
	end

	File_Pos = File_Pos + Float_Size;
	return byteArrayToFloat( b );
end

function readString_m( data, len )
	local c = string.sub( data, File_Pos, File_Pos+len-1 );
	File_Pos = File_Pos + len;
	return c;
end


-- Lower Level Functions
function resetPosition()
	File_Pos = 1;
end

function byteArrayToFloat( bytes )
	local bits = 0;
	for i = 1, 4 do
		local power = 8*(4-i);
		local val = string.byte( bytes, i ) * 2^power;
		bits = bits + val;
	end
	return intBitsToFloat( bits );
end

function byteArrayToInt( bytes )
	local MASK = 0x000000ff;
	local value = 0;
	for i = 1, 4 do
		local shift = (4-i) * 8;
		local v = (string.byte( bytes, i ) & MASK) << shift;
		value = value + v;
	end
	return value;
end


function intToByteArray( param )
	local result = string.pack( "i4", param );
	return result;
end

function floatToByteArray( param )
	local result = string.pack( "f", param );
	return result;
end


function writeByte( buffer, byte )
	table.insert( buffer, string.char( byte ) );
--	buffer.data = buffer.data .. string.char( byte );
end

function writeBool( buffer, bool )
	if( bool ) then
		writeByte( buffer, 1 );
	else
		writeByte( buffer, 0 );
	end
end

function writeInt( buffer, int )
	local iba = intToByteArray( int );
	table.insert( buffer, iba );
--	buffer.data = buffer.data .. iba;
end

function writeFloat( buffer, float )
	local fba = floatToByteArray( float );
	table.insert( buffer, fba );
--	buffer.data = buffer.data .. fba;
end

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
	table.insert( buffer, s );
--	buffer.data = buffer.data .. s;
end

function finalizeBuffer( buffer )
	buffer.data = table.concat( buffer );
end

function unpackInt( data )
	local int = string.unpack( "i4", data, File_Pos );
	File_Pos = File_Pos + 4;
	return int;
end

function unpackFloat( data )
	local float = string.unpack( "f", data, File_Pos );
	File_Pos = File_Pos + 4;
	return float;
end

function unpackVec2i( data )
	local v = createVec2( unpackInt( data ), unpackInt( data ) );
	return v;
end


function createBuffer()
	local buffer = {};
	buffer.data = {};
	return buffer;
end


-- according to IEEE 754
function intBitsToFloat( bits )
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
