-- Procedural Model Generation
-- Produces raw model data that can be passed into the host program as a binary string
require( "render.graphics" );
require( "binaryio.processing" );



Geom = {};


function Geom.createModel( userdata )
	local model = {};
	model.positionType = GL.FLOAT;
	model.uvType = GL.FLOAT;
	model.elementType = GL.UNSIGNED_INT;
	model.drawMode = GL.TRIANGLES;
	model.vaoName = 0;
	model.lineWidth = 1.0;
	model.visible = true;
	model.userdata = userdata;
	model.isLocal = userdata == nil;
	model.shader = nil;
	model.billboard = false;
	model.position = Vec3_new( 0, 0, 0 );
	model.scale = Vec3_new( 1, 1, 1 );
	model.uniforms = createList();
	model.textures = createList();
	
	-- data
	if( userdata == nil ) then
		model.positions = Binary.createBuffer();
		model.uv = Binary.createBuffer();
		model.normals = Binary.createBuffer();
		model.colors = Binary.createBuffer();
		model.elements = Binary.createBuffer();
	end
	
	model.hasUV = false;
	model.hasNormals = false;
	model.hasColors = false;
	
	-- transform functions
	function model.setPosition( pos )
		Vec3_set( model.position, pos.x, pos.y, pos.z );
		Model_setPosition( model.userdata, pos );
	end
	
	function model.move( move )
		Vec3_addLocal( model.position, move );
		Model_move( model.userdata, move );
	end
	
	function model.setScale( scale )
		model.scale = scale;
		Model_setScale( model.userdata, scale );
	end
	
	function model.setBillboard( bb )
		model.billboard = bb;
		Model_setBillboard( model.userdata, bb );
	end
	
	function model.setShader( shader )
		if( model.userdata == nil ) then return; end
		model.shader = shader;
		Model_setShader( model.userdata, shader.userdata );
	end
	
	function model.addTexture( name, texture )
		model.textures.add( texture );
		Model_addTexture( model.userdata, name, texture.userdata );
	end
	
	function model.addFramebuffer( name, framebuffer )
		model.textures.add( framebuffer );
		local textureUD = Model_addFramebuffer( model.userdata, name, framebuffer.userdata );
	end
	
	function model.setLineWidth( width )
		model.lineWidth = width;
		Model_setLineWidth( model.userdata, width );
	end
	
	function model.setVisible( vis )
		model.visible = vis;
		Model_setVisible( model.userdata, vis );
	end
	
	
	function model.setUniform( declaration, uniValue )
		local spaceIndex = string.find( declaration, " " );
		local uniType = string.sub( declaration, 1, spaceIndex-1 );
		local uniName = string.sub( declaration, spaceIndex+1, string.len( declaration ) );
		
		local newUniform = Render.Shader.createUniform( nil, uniType, uniName );
		local index = model.uniforms.find( newUniform );
		local uniform = nil;
		if( index > 0 ) then
			local existing = model.uniforms.get( index );
			existing.value = uniValue;
			uniform = existing;
		else
			-- make a new one
			model.uniforms.add( newUniform );
			uniform = newUniform;
		end
		
		if( uniform.type == "int" ) then
			Model_setIntUniform( model.userdata, uniName, uniValue );
		elseif( uniform.type == "float" ) then
			Model_setFloatUniform( model.userdata, uniName, uniValue );
		elseif( uniform.type == "vec2" ) then
			Model_setVec2Uniform( model.userdata, uniName, uniValue );
		elseif( uniform.type == "vec3" ) then
			Model_setVec3Uniform( model.userdata, uniName, uniValue );
		elseif( uniform.type == "vec4" ) then
			Model_setVec4Uniform( model.userdata, uniName, uniValue );
		elseif( uniform.type == "mat3" ) then
			Model_setMat3Uniform( model.userdata, uniName, uniValue );
		elseif( uniform.type == "mat4" ) then
			Model_setMat4Uniform( model.userdata, uniName, uniValue );
		elseif( uniform.type == "sampler2D" ) then
			if( type( uniValue ) == "number" ) then
				Model_setTextureUniform( model.userdata, uniName, uniValue );
			else
				-- This assumes that uniValue will be a Framebuffer Lua object
				Model_setFramebufferUniform( model.userdata, uniName, uniValue.userdata );
			end
		end
	end
	
	function model.setIntUniform( name, value )
		
	end
	
	
	function model.initUVBuffer()
		model.hasUV = true;
		model.uv = Binary.createBuffer();
	end
	
	function model.initNormalBuffer()
		model.hasNormals = true;
		model.normals = Binary.createBuffer();
	end
	
	function model.initColorBuffer()
		model.hasColors = true;
		model.colors = Binary.createBuffer();
	end
	
	function model.pushPosition( ... )
		for k,pos in pairs( {...} ) do
			writeFloat( model.positions, pos );
		end
	end
	
	function model.pushUV( ... )
		model.hasUV = true;
		for k,uv in pairs( {...} ) do
			writeFloat( model.uv, uv );
		end
	end
	
	function model.pushNormal( ... )
		model.hasNormals = true;
		for k,norm in pairs( {...} ) do
			writeFloat( model.normals, norm );
		end
	end
	
	function model.pushElement( ... )
		for k,elem in pairs( {...} ) do
			writeInt( model.elements, elem );
		end
	end
	
	local function commit()
		model.positions.finalize();
		model.elements.finalize();
		if( model.hasUV ) then model.uv.finalize(); end
		if( model.hasNormals ) then model.normals.finalize(); end
		if( model.hasColors ) then model.colors.finalize(); end
	end
	
	function model.build()
		if( model.isLocal ) then
			commit();
			model.userdata, model.vaoName = Model_build(	model.positions.size(), model.positions.data,
															model.uv.size(), model.uv.data,
															model.normals.size(), model.normals.data,
															model.colors.size(), model.colors.data,
															model.elements.size(), model.elements.data,
															model.drawMode );
		else
			model.vaoName = Model_buildVAO( model.userdata );
		end
		
		Model_setDrawMode( model.userdata, model.drawMode );
	end
	
	return model;
end



-- Debug drawing for islands
function Geom.createIslandBorder( edges )
	local model = Geom.createModel();
	model.drawMode = GL.LINES;
	
	local numSides = edges.length();
	local numElements = 2 * numSides;
	local PI3 = math.pi / 3.0;
	
	for i = 1, edges.length() do
		local edge = edges.get(i);
		local x0 = edge.tile.position.x;
		local z0 = edge.tile.position.z;
		
		local angle = PI3 * (edge.direction -1) + 0.5 * PI3;
		local sine = math.sin( angle );
		local cosine = math.cos( angle );
		
		model.pushPosition( x0 + cosine, 0.0, z0 - sine );
		
		angle = PI3 * (edge.direction - 0) + 0.5 * PI3;
		sine = math.sin( angle );
		cosine = math.cos( angle );
		
		model.pushPosition( x0 + cosine, 0.0, z0 - sine );
		
		-- OpenGL indicies start at 0
		local k = 2*(i-1);
		model.pushElement( k, k + 1 );
	end
	
	return model;
end


function Geom.createWireHexModel()
	local model = Geom.createModel();
	model.drawMode = GL.LINES;
	
	local numSides = 6;
	local numElements = 2 * numSides;
	local PI3 = math.pi / 3.0;
	
	for i = 1, numSides do
		local angle = PI3 * (i - 1) + 0.5 * PI3;
		local sine = math.sin( angle );
		local cosine = math.cos( angle );
		
		model.pushPosition( cosine, 0.0, sine );
		
		angle = PI3 * (i + 0.5);
		sine = math.sin( angle );
		cosine = math.cos( angle );
		
		model.pushPosition( cosine, 0.0, sine );
		
		local k = 2 * (i-1);
		model.pushElement( k, k + 1 );
	end
	
	return model;
end

function Geom.createCircularDisc( numSides )
	local model = Geom.createModel();
	local numElements = 3 * numSides;
	for i = 1, numSides do
		local angle = i * 2 * math.pi / numSides;
		local sine = math.sin( angle );
		local cosine = math.cos( angle );
		
		model.pushPosition( cosine, sine, 0.0 );
		
		angle = (i + 1) * 2 * math.pi / numSides;
		sine = math.sin( angle );
		cosine = math.cos( angle );
		
		model.pushPosition( cosine, sine, 0.0 );
		model.pushPosition( 0, 0, 0 );
		
		model.pushElement( 3*i, 3*i + 1, 3*i + 2 );
	end
	
	return model;
end


function Geom.createQuadModel()
	local model = Geom.createModel();
	model.drawMode = GL.TRIANGLES;
	
	model.pushPosition( -1, -1, 0, 1, -1, 0, 1, 1, 0, 1, 1, 0, -1, 1, 0, -1, -1, 0 );
	model.pushUV( 0, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 0 );
	model.pushElement( 0, 1, 2, 3, 4, 5 );
	
	return model;
end



