-- Camera System
-- Control of camera
require( "math.vector" );


Camera = {};
Camera.forward = Vec2_new( 0, -1 );
Camera.right = Vec2_new( 1, 0 );


function Camera.cursorMoved( tile )
	Camera.lookDownAtTile( tile );
end



function Camera.move( movement )
	local fv = Camera_move( GameInstance, movement );
	Camera.computeLocalVectors( fv );
end

function Camera.moveTo( position )
	local fv = Camera_moveTo( GameInstance, position );
	Camera.computeLocalVectors( fv );
end

function Camera.orbitX( angle )
	local fv = Camera_orbitX( GameInstance, angle );
	Camera.computeLocalVectors( fv );
end

function Camera.orbitY( angle )
	local fv = Camera_orbitY( GameInstance, angle );
	Camera.computeLocalVectors( fv );
end

function Camera.rotateX( angle )
	local fv = Camera_rotateX( angle );
	Camera.computeLocalVectors( fv );
end

function Camera.rotateY( angle )
	local fv = Camera_rotateY( angle );
	Camera.computeLocalVectors( fv );
end

function Camera.rotateZ( angle )
	local fv = Camera_rotateZ( angle );
	Camera.computeLocalVectors( fv );
end

function Camera.lookDownAtTile( tile )
	local fv = Camera_lookDownAtTile( GameInstance, tile.userdata );
	Camera.computeLocalVectors( fv );
end

function Camera.lookDownAtPosition( position )
	local fv = Camera_lookDownAtPosition( GameInstance, position );
	Camera.computeLocalVectors( fv );
end



-- Utiltiy
function Camera.computeLocalVectors( fv )
	local xz = Vec2_new( fv.x, fv.z );
	Vec2_normalize( xz );
	Camera.forward = xz;
	Vec2_set( Camera.right, -Camera.forward.y, Camera.forward.x );
end

