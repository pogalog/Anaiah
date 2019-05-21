-- Matrix, for use in OpenGL
-- No (or minimal) matrix math will be done here.


function createMat3( data )
	local m = {};
	
	if( data == nil ) then
		for i = 1, 9 do
			m[i] = 0.0;
		end
		m[1] = 1.0;
		m[5] = 1.0;
		m[9] = 1.0;
	else
		for i = 1, 9 do
			m[i] = data[i];
		end
	end
	
	return m;
end



function createMat4( data )
	local m = {};
	
	if( data == nil ) then
		for i = 1, 16 do
			m[i] = 0.0;
		end
		m[1] = 1.0;
		m[6] = 1.0;
		m[11] = 1.0;
		m[16] = 1.0;
	else
		for i = 1, 16 do
			m[i] = data[i];
		end
	end
	
	
	return m;
end


function ortho( left, right, bottom, top )
	local data = Render_getOrthoMatrix( left, right, bottom, top );
	local m = createMat4( data );
	
	return m;
end


function perspective( fov, aspect, zNear, zFar )
	local data = Render_getPerspectiveMatrix( fov, aspect, zNear, zFar );
	local m = createMat4( data );
	
	return m;
end