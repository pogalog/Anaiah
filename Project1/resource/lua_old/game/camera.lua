-- Camera callbacks


function createCamera()
	local camera = {};
	
	function camera.cursorMoved( tile )
		Camera_lookDownAtTile( GameInstance, tile );
	end
	
	return camera;
end