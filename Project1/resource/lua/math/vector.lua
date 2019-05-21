-- Vector, used in game logic and OpenGL
-- Provides a full library of rank 1 tensor math

-- math package add-ons
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

function math.atan2( y, x )
	if( x == 0 and y == 0 ) then
		return 0;
	end
	
	local absy = math.abs(y);
	local absx = math.abs(x);
	local val = 0;
	
	if( absy - absx == absy ) then
		return y < 0 and -0.5*math.pi or 0.5*math.pi;
	end
	
	if( absx - absy == absx ) then
		val = 0.0;
	else
		val = math.atan( y/x );
	end
	
	if( x > 0 ) then
		return val;
	end
	
	if( y < 0 ) then
		return val - math.pi;
	end
	
	return val + math.pi;
end

-- Cludge: use 0.49 to avoid irritating issues with the cursor when the camera's
-- forward vector is exactly <0,0,-1>.
math.round = function( x )
	return math.floor( x + 0.49 );
end

math.SQRT3 = math.sqrt(3);



-- Vec2 functions
function Vec2_new( x, y )
	local vec = {};
	vec.desc = "Vec2";
	vec.x = x;
	vec.y = y;

	return vec;
end

function Vec2_length( v ) return math.sqrt( v.x*v.x + v.y*v.y ); end
function Vec2_lengthSqrd( v ) return v.x*v.x + v.y*v.y; end
function Vec2_normalize( v ) local invLen = 1.0/Vec2_length(v); v.x = v.x * invLen; v.y = v.y * invLen; end
function Vec2_getUnit( v ) local copy = Vec2_new( v.x, v.y ); Vec2_normalize(v); return copy; end
function Vec2_set( v, x, y ) v.x = x; v.y = y; end
function Vec2_addLocal( v, u ) v.x = v.x + u.x; v.y = v.y + u.y; end
function Vec2_subLocal( v, u ) v.x = v.x - u.x; v.y = v.y - u.y; end
function Vec2_add( v, u ) return Vec2_new( u.x + v.x, u.y + v.y ); end
function Vec2_sub( v, u ) return Vec2_new( v.x - u.x, v.y - u.y ); end
function Vec2_dot( v, u ) return v.x*u.x + v.y*u.y; end
function Vec2_mul( v, c ) return Vec2_new( c * v.x, c * v.y ); end
function Vec2_tostring( v ) return string.format( "[%.3f, %.3f]", v.x, v.y ); end
function Vec2_print( v ) print( Vec2_tostring(v) ); end
function Vec2_hexDistanceTo( v, u ) return math.max( math.abs(v.x-u.x), math.abs(v.y-u.y) ); end
function Vec2_copy( v )
	if( v == nil ) then return nil; end
	return Vec2_new( v.x, v.y );
end

function Vec2_rotate( v, rotation )
	local X = v.x;
	local Y = -v.y;
	
	for i = 0, rotation-1 do
		-- convert to 3-tuple coordinate system
		local x = X - (Y - Y&1) / 2;
		local z = Y;
		local y = -x - z;
		
		-- rotate
		local x1 = -y;
		local y1 = -x - z;
		local z1 = -x;
		x = x1;
		y = y1;
		z = z1;
		
		-- convert back to 2-tuple system
		X = x + (z - z&1) / 2;
		Y = z;
	end
	
	return Vec2_new( X, -Y );
end


-- Vec3 functions
function Vec3_new( x, y, z )
	local vec = {};
	vec.desc = "Vec3";
	vec.x = x;
	vec.y = y;
	vec.z = z;

	return vec;
end

function Vec3_length(v) return math.sqrt( v.x*v.x + v.y*v.y + v.z*v.z ); end
function Vec3_lengthSqrd(v) return v.x*v.x + v.y*v.y + v.z*v.z; end
function Vec3_normalize(v) local invLen = 1.0/Vec3_length(v); v.x = v.x * invLen; v.y = v.y * invLen; v.z = v.z * invLen; end
function Vec3_getUnit(v) local copy = Vec3_copy(v); Vec3_normalize(copy); return copy; end
function Vec3_set( v, x, y, z ) v.x = x; v.y = y; v.z = z; end
function Vec3_addLocal( v, u ) v.x = v.x + u.x; v.y = v.y + u.y; v.z = v.z + u.z; end
function Vec3_subLocal( v, u ) v.x = v.x - u.x; v.y = v.y - u.y; v.z = v.z - u.z; end
function Vec3_mulLocal( v, c ) v.x = v.x * c; v.y = v.y * c; v.z = v.z * c; end
function Vec3_add( v, u ) return Vec3_new( v.x + u.x, v.y + u.y, v.z + u.z ); end
function Vec3_sub( v, u ) return Vec3_new( v.x - u.x, v.y - u.y, v.z - u.z ); end
function Vec3_mul( v, c ) return Vec3_new( c * v.x, c * v.y, c * v.z ); end
function Vec3_dot( v, u ) return v.x*u.x + v.y*u.y + v.z*u.z; end
function Vec3_tostring(v) return string.format( "[%s, %s, %s]", v.x, v.y, v.z ); end
function Vec3_print(v) print( Vec3_tostring(v) ); end
function Vec3_copy(v) return Vec3_new( v.x, v.y, v.z ); end
function Vec3_cross( v, u )
	local xc = u.y * v.z - u.z * v.y;
	local yc = u.z * v.x - u.x * v.z;
	local zc = u.x * v.y - u.y * v.x;
	return Vec3_new( xc, yc, zc );
end

-- vec4
function Vec4_new( x, y, z, w )
	local vec = {};
	vec.desc = "Vec4";
	vec.x = x;
	vec.y = y;
	vec.z = z;
	vec.w = w;

	return vec;
end

function Vec4_length(v) return math.sqrt( v.x*v.x + v.y*v.y + v.z*v.z + v.w*v.w ); end
function Vec4_lengthSqrd(v) return v.x*v.x + v.y*v.y + v.z*v.z + v.w*v.w; end
function Vec4_addLocal( v, u ) v.x = v.x + u.x; v.y = v.y + u.y; v.z = v.z + u.z; v.w = v.w + u.w; end
function Vec4_subLocal( v, u ) v.x = v.x - u.x; v.y = v.y - u.y; v.z = v.z - u.z; v.w = v.w - u.w; end
function Vec4_dot( v, u ) return v.x*u.x + v.y*u.y + v.z*u.z; end
function Vec4_tostring(v) return string.format( "[%s, %s, %s, %s]", v.x, v.y, v.z, v.w ); end
function Vec4_print(v) print( string.format( "[%s, %s, %s, %s]", v.x, v.y, v.z, v.w ) ); end


function Color_new( r, g, b, a )
	local color = {};
	color.desc = "Color4";
	color.r = r;
	color.x = r;
	color.g = g;
	color.y = g;
	color.b = b;
	color.z = b;
	color.a = a;
	color.w = a;
	
	function color.toString() return string.format( "[%d, %d, %d, %d]", color.r, color.g, color.b, color.a ); end
	function color.print() print( color.toString() ); end
	
	return color;
end
function Color_tostring(c) return string.format( "[%s, %s, %s, %s]", c.r, c.g, c.b, c.a ); end



