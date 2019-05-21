function math.sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

function math.clamp( x, low, high )
	return x<low and low or x>high and high or x;
end

math.old_acos = math.acos;
math.acos = function( x )
	return math.old_acos( math.clamp( x, -1, 1 ) );
end

math.round = function( x )
	return math.floor( x + 0.5 );
end

math.SQRT3 = math.sqrt(3);

-- vec2
function createVec2( x, y )
	local vec = {};
	vec.desc = "Vec2";
	vec.x = x;
	vec.y = y;
	function vec.length() return math.sqrt( vec.x*vec.x + vec.y*vec.y ); end
	function vec.lengthSqrd() return vec.x*vec.x + vec.y*vec.y; end
	function vec.set( x, y ) vec.x = x; vec.y = y; end
	function vec.addLocal( u ) vec.x = vec.x + u.x; vec.y = vec.y + u.y; end
	function vec.subLocal( u ) vec.x = vec.x - u.x; vec.y = vec.y - u.y; end
	function vec.add( u ) return createVec2( u.x + x, u.y + y ); end
	function vec.dot( u ) return vec.x*u.x + vec.y*u.y; end
	function vec.toString() return string.format( "[%d, %d]", vec.x, vec.y ); end
	function vec.print() print( vec.toString() ); end
	function vec.hexDistanceTo( u )
		return math.max( math.abs(vec.x-u.x), math.abs(vec.y-u.y) );
	end
	function vec.copy() return createVec2( vec.x, vec.y ); end

	return vec;
end

function copyVec2( rhs )
	if( rhs == nil ) then return nil; end
	return rhs.copy();
end


-- vec3
function createVec3( x, y, z )
	local vec = {};
	vec.desc = "Vec3";
	vec.x = x;
	vec.y = y;
	vec.z = z;
	function vec.length() return math.sqrt( vec.x*vec.x + vec.y*vec.y + vec.z*vec.z ); end
	function vec.lengthSqrd() return vec.x*vec.x + vec.y*vec.y + vec.z*vec.z; end
	function vec.normalize() local invLen = 1.0/vec.length(); vec.x = vec.x * invLen; vec.y = vec.y * invLen; vec.z = vec.z * invLen; end
	function vec.getUnit() local copy = createVec3( vec.x, vec.y, vec.z ); copy.normalize(); return copy; end
	function vec.set( x, y, z ) vec.x = x; vec.y = y; vec.z = z; end
	function vec.addLocal( u ) vec.x = vec.x + u.x; vec.y = vec.y + u.y; vec.z = vec.z + u.z; end
	function vec.subLocal( u ) vec.x = vec.x - u.x; vec.y = vec.y - u.y; vec.z = vec.z - u.z; end
	function vec.mulLocal( c ) vec.x = vec.x * c; vec.y = vec.y * c; vec.z = vec.z * c; end
	function vec.add( u ) return createVec3( vec.x + u.x, vec.y + u.y, vec.z + u.z ); end
	function vec.sub( u ) return createVec3( vec.x - u.x, vec.y - u.y, vec.z - u.z ); end
	function vec.mul( c ) return createVec3( c * vec.x, c * vec.y, c * vec.z ); end
	function vec.dot( u ) return vec.x*u.x + vec.y*u.y + vec.z*u.z; end
	function vec.toString() return string.format( "[%s, %s, %s]", vec.x, vec.y, vec.z ); end
	function vec.print() print( vec.toString() ); end
	function vec.copy() return createVec3( vec.x, vec.y, vec.z ); end
	function vec.cross( v )
		local xc = vec.y * v.z - vec.z * v.y;
		local yc = vec.z * v.x - vec.x * v.z;
		local zc = vec.x * v.y - vec.y * v.x;
		return createVec3( xc, yc, zc );
	end

	return vec;
end

-- vec4
function createVec4( x, y, z, w )
	local vec = {};
	vec.x = x;
	vec.y = y;
	vec.z = z;
	vec.w = w;
	function vec.length() return math.sqrt( vec.x*vec.x + vec.y*vec.y + vec.z*vec.z + vec.w*vec.w ); end
	function vec.lengthSqrd() return vec.x*vec.x + vec.y*vec.y + vec.z*vec.z + vec.w*vec.w; end
	function vec.addLocal( u ) vec.x = vec.x + u.x; vec.y = vec.y + u.y; vec.z = vec.z + u.z; vec.w = vec.w + u.w; end
	function vec.subLocal( u ) vec.x = vec.x - u.x; vec.y = vec.y - u.y; vec.z = vec.z - u.z; vec.w = vec.w - u.w; end
	function vec.dot( u ) return vec.x*u.x + vec.y*u.y + vec.z*u.z; end
	function vec.toString() return string.format( "[%s, %s, %s, %s]", vec.x, vec.y, vec.z, vec.w ); end
	function vec.print() print( string.format( "[%s, %s, %s, %s]", vec.x, vec.y, vec.z, vec.w ) ); end

	return vec;
end

function createColor( r, g, b, a )
	local color = {};
	color.r = r;
	color.g = g;
	color.b = b;
	color.a = a;
	
	function color.toString() return string.format( "[%d, %d, %d, %d]", color.r, color.g, color.b, color.a ); end
	function color.print() print( color.toString() ); end
	
	return color;
end
	

-- range
function createRange( low, high )
	local range = {};
	range.low = low;
	range.high = high;

	function range.withinRangeInclusive( r )
		return r >= range.low and r <= range.high;
	end

	function range.withinRangeExclusive( r )
		return r > range.low and r < range.high;
	end

	return range;
end

function round( x, nd )
  local mult = 10^(nd or 0);
  return math.floor( x * mult + 0.5 ) / mult;
end

