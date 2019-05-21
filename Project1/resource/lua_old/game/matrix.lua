require( "game.vector" );

-- matrix, data format is column major; {a, b, c, d} are rows
-- mat2
function createMat2( a1, a2,
					  b1, b2 )
	local mat = {};
	mat.a1 = a1;
	mat.b1 = b1;
	mat.a2 = a2;
	mat.b2 = b2;
	mat.data = {a1, b1, a2, b2};

	function mat.mul( v )
		return createVec2( a1*v.x + a2*v.y, b1*v.x + b2*v.y );
	end

	function mat.mul( m )
		A1 = a1 * m.a1 + a2 * m.b1;
		A2 = a1 * m.a2 + a2 * m.b2;
		B1 = b1 * m.a1 + b2 * m.b1;
		B2 = b1 * m.a2 + b2 * m.b2;
		return createMat2( A1, A2, B1, B2 );
	end

	return mat;
end

-- mat3
function createMat3( a1, a2, a3,
					  b1, b2, b3,
					  c1, c2, c3 )
	local mat = {};
	mat.a1 = a1;
	mat.b1 = b1;
	mat.c1 = c1;
	mat.a2 = a2;
	mat.b2 = b2;
	mat.c2 = c2;
	mat.a3 = a3;
	mat.b3 = b3;
	mat.c3 = c3;
	mat.data = {a1, b1, c1, a2, b2, c2, a3, b3, c3};

	return mat;
end

function createMat4( a1, a2, a3, a4,
					  b1, b2, b3, b4,
					  c1, c2, c3, c4,
					  d1, d2, d3, d4 )
	local mat = {};
	mat.a1 = a1;
	mat.b1 = b1;
	mat.c1 = c1;
	mat.d1 = d1;
	mat.a2 = a2;
	mat.b2 = b2;
	mat.c2 = c2;
	mat.d2 = d2;
	mat.a3 = a3;
	mat.b3 = b3;
	mat.c3 = c3;
	mat.d3 = d3;
	mat.a4 = a4;
	mat.b4 = b4;
	mat.c4 = c4;
	mat.d4 = d4;
	mat.data = {a1, b1, c1, d1, a2, b2, c2, d2, a3, b3, c3, d3, a4, b4, c4, d4};

	return mat;
end

mat = createMat2( 1, 2, 3, 4 );
