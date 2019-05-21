-- Shader
require( "render.main" );
require( "util.string" );

Render.Shader = {};
local shaderPath = "resource/shader/";
Render.BindingPoint = 0;

function Render.newBindingPoint()
	Render.BindingPoint = Render.BindingPoint + 1;
	return Render.BindingPoint;
end


function Render.createShader( vertPath, fragPath )
	local shader = {};
	shader.vertexPath = vertPath;
	shader.fragmentPath = fragPath;
	shader.uniforms = {};
	shader.types = {};
	shader.constVars = {};
	
	function shader.getStruct( typeName )
		for k, v in pairs( shader.types ) do
			if( v.name == typeName ) then
				return v;
			end
		end
		
		return nil;
	end
	
	function shader.getConstVar( name )
		for k, v in pairs( shader.constVars ) do
			if( v.name == name ) then
				return v.value;
			end
		end
		
		return nil;
	end
	
	-- compile
	shader.vertexSource = Render.Shader.readSource( shaderPath..vertPath );
	shader.fragmentSource = Render.Shader.readSource( shaderPath..fragPath );
	shader.userdata = Shader_withSource( shader.vertexSource, shader.fragmentSource );
	
	-- store uniform variables for reference
	Render.Shader.findConstVars( shader, shader.vertexSource );
	Render.Shader.findConstVars( shader, shader.fragmentSource );
	Render.Shader.findStructs( shader, shader.vertexSource );
	Render.Shader.findStructs( shader, shader.fragmentSource );
	local v_uni = Render.Shader.findUniformVars( shader, shader.vertexSource );
	local f_uni = Render.Shader.findUniformVars( shader, shader.fragmentSource );
	
	
	
	for k,v in pairs( v_uni ) do
		shader.uniforms[v.name] = v;
	end
	
	for k,v in pairs( f_uni ) do
		shader.uniforms[v.name] = v;
	end
	
	
	-- functions
	function shader.getUniform( name )
		return shader.uniforms[name];
	end
	
	function shader.setUniform( name, value )
		if( value == nil ) then return; end
		
		local uniform = shader.getUniform( name );
		if( uniform.type == "int" ) then
			if( type( value ) ~= "number" ) then
				shader.uniformTypeWarning( uniform, "int" );
				return;
			end
			
			uniform.setInt( value );
		elseif( uniform.type == "float" ) then
			if( type( value ) ~= "number" ) then
				shader.uniformTypeWarning( uniform, "float" );
				return;
			end
			
			uniform.setFloat( value );
		else
			if( shader.testUniformType( uniform, value.type ) == false ) then return; end
			
			if( uniform.type == "vec2" ) then
				uniform.setVec2( value );
			elseif( uniform.type == "vec3" ) then
				uniform.setVec3( value );
			elseif( uniform.type == "vec4" ) then
				uniform.setVec4( value );
			elseif( uniform.type == "mat3" ) then
				uniform.setMat3( value );
			elseif( uniform.type == "mat4" ) then
				uniform.setMat4( value );
			end
		end
	end
	
	
	
	function shader.uniformTypeWarning( uniform, setType )
		local w = string.format( "Warning: Attempt to set shader uniform '%s' (type %s) with data of type %s", uniform.name, uniform.type, setType );
		print( w );
	end
	
	function shader.testUniformType( uniform, setType )
		if( value.type ~= uniform.type ) then
			shader.uniformTypeWarning( uniform, uniform.type );
			return false;
		end
		return true;
	end
	
	return shader;
end



-- Render.Shader functions
Render.Shader.create = Render.createShader;



function Render.Shader.createVariable( shader, varType, varName, arraySize )
	local var = {};
	var.shader = shader;
	var.type = varType;
	var.name = varName;
	var.arraySize = arraySize;
	var.value = 0;
	
	function var.computeSize()
		local multiplier = (arraySize == 0 or arraySize == nil) and 1 or arraySize;
		if( var.type == "float" ) then return 4 * multiplier;
			elseif( var.type == "int" ) then return 4 * multiplier;
			elseif( var.type == "vec2" ) then return 8 * multiplier;
			elseif( var.type == "vec3" ) then return 12 * multiplier;
			elseif( var.type == "vec4" ) then return 16 * multiplier;
			elseif( var.type == "ivec2" ) then return 8 * multiplier;
			elseif( var.type == "ivec3" ) then return 12 * multiplier;
			elseif( var.type == "ivec4" ) then return 16 * multiplier;
		end
	end
	
	var.size = var.computeSize();
	
	return var;
end


function Render.Shader.createUniform( shader, uniType, uniName, arraySize, block )
	local uniform = Render.Shader.createVariable( shader, uniType, uniName, arraySize );
	uniform.shader = shader;
	
	function uniform.equals( u )
		if( uniform.name ~= u.name ) then return false; end
		if( uniform.type ~= u.type ) then return false; end
		
		return true;
	end
	
	-- Uniform objects are also used in Models, in which case we shouldn't try to pass to the Shader
	if( shader ~= nil ) then
		if( block ~= nil ) then
			uniform.userdata = Uniform_newBlockUniform( block.userdata, uniType, uniName );
		else
			uniform.userdata = Uniform_new( shader.userdata, uniType, uniName );
		end
	end
	
	function uniform.setInt( data )
		Uniform_setInt( shader.userdata, data );
	end
	
	function uniform.setFloat( data )
		Uniform_setFloat( shader.userdata, data );
	end
	
	function uniform.setVec2( data )
		Uniform_setVec2( shader.userdata, data );
	end
	
	function uniform.setVec3( data )
		Uniform_setVec3( shader.userdata, data );
	end
	
	function uniform.setVec4( data )
		Uniform_setVec4( shader.userdata, data );
	end
	
	function uniform.setMat3( data )
		Uniform_setMat3( shader.userdata, data );
	end
	
	function uniform.setMat4( data )
		Uniform_setMat4( shader.userdata, data );
	end
	
	function uniform.setTexture( data )
		Uniform_setTexture( data );
	end
	
	function uniform.setFramebuffer( data )
		Uniform_setFramebuffer( data );
	end
	
	
	
	return uniform;
end


function Render.Shader.createUniformBlock( shader, name )
	local block = {};
	block.shader = shader;
	block.name = name;
	block.vars = {};
	block.userdata = Uniform_newBlock( shader.userdata, name );
	block.size = 0;
	block.buffer = nil;
	
	function block.setLocations()
		Uniform_setBlockLocations( block.userdata );
	end
	
	function block.computeSize()
		for k,var in pairs( block.vars ) do
			print( "NEW VAR: " .. var.name .. " of size " .. var.size );
			block.size = block.size + var.size;
		end
	end
	
	function block.createBuffer()
		local buffer = {};
		block.bindingPoint = Render.newBindingPoint();
		buffer.userdata = Uniform_newBuffer( block.size, block.bindingPoint );
		Uniform_bindBuffer( block.userdata, buffer.userdata );
		
		block.buffer = buffer;
	end
	
	
	return block;
end


function Render.Shader.createStruct( shader, name )
	local struct = {};
	struct.name = name;
	struct.vars = {};
	struct.size = 0;
	
	function struct.computeSize()
		for k,var in pairs( struct.vars ) do
			struct.size = struct.size + var.size;
		end
	end
	
	return struct;
end


function Render.Shader.findConstVars( shader, source )
	local start = 1;
	local a = 1;
	local b = 1;
	while( true ) do
		a, b = string.find( source, "const", start );
		if( a == nil ) then break; end
		
		local sa, sb = string.find( source, ";", b );
		local line = string.sub( source, b+1, sa-1 );
		local vars = Render.Shader.parseAssignment( shader, line );
		for k, v in pairs( vars ) do
			table.insert( shader.constVars, var );
		end
		
		start = sb + 1;
	end
end


function Render.Shader.findUniformVars( shader, source )
	local vars = {};
	
	local start = 1;
	local a = 1;
	local b = 1;
	while( true ) do
		a, b = string.find( source, "uniform%s", start );
		if( a == nil ) then break; end
		
		local semicolon = string.find( source, ";", b );
		local line = string.sub( source, b+1, semicolon-1 );
		local openBrace = string.find( source, "{", b );
		if( openBrace ~= nil and openBrace < semicolon ) then
			-- this is a block uniform, parse member info
			local blockName =  string.trim( string.sub( source, b+1, openBrace-1 ) );
			local closeBrace = string.find( source, "}", openBrace+1 );
			local blockSource = string.sub( source, openBrace+1, closeBrace-1 );
			semicolon = string.find( source, ";", closeBrace );
			local block = Render.Shader.createUniformBlock( shader, blockName );
			Render.Shader.parseBlockUniform( shader, blockSource, block );
			block.setLocations();
			block.computeSize();
			block.createBuffer();
		else
			-- standard uniform declaration
			local uniType, uniNames, arrSizes = Render.Shader.parseDeclaration( shader, line );
		
			for i = 1, #uniNames do
				local struct = shader.getStruct( uniType );
				if( struct ~= nil ) then
					for k, var in pairs( struct.vars ) do
						local name = uniNames[i] .. "." .. var.name;
						local uniform = Render.Shader.createUniform( shader, var.type, name, arrSizes[i] );
						table.insert( vars, uniform );
					end
				else
					local uniform = Render.Shader.createUniform( shader, uniType, uniNames[i], arrSizes[i] );
					table.insert( vars, uniform );
				end
			end
		end
		
		start = semicolon + 1;
	end
	
	return vars;
end


function Render.Shader.parseBlockUniform( shader, source, block )
	local start = 1;
	
	while( true ) do
		local semicolon = string.find( source, ";", start );
		if( semicolon == nil ) then return; end
		
		local line = string.sub( source, start, semicolon-1 );
		local uniType, uniNames, arrSizes = Render.Shader.parseDeclaration( shader, line );
		
		for i = 1, #uniNames do
			local struct = shader.getStruct( uniType );
			if( struct ~= nil ) then
				for k, var in pairs( struct.vars ) do
					local name = uniNames[i] .. "." .. var.name;
					local uniform = Render.Shader.createUniform( shader, var.type, name, arrSizes[i], block );
					table.insert( block.vars, uniform );
				end
			else
				local uniform = Render.Shader.createUniform( shader, uniType, uniNames[i], arrSizes[i], block );
				table.insert( block.vars, uniform );
			end
		end
		
		start = semicolon + 1;
	end
end


function Render.Shader.findStructs( shader, source )
	local start = 1;
	local a = 1;
	local b = 1;
	
	while( true ) do
		local 
		a, b = string.find( source, "struct%s", start );
		if( a == nil ) then break; end
		
		local openA, openB = string.find( source, "{", b );
		local typeName = string.trim( string.sub( source, b+1, openA-1 ) );
		local closeA, closeB = string.find( source, "}", openB+1 );
		local struct = Render.Shader.createStruct( shader, typeName );
		Render.Shader.findStructMembers( struct, source, openA, closeB );
		table.insert( shader.types, struct );
		
		start = closeB + 1;
	end
end


function Render.Shader.findStructMembers( struct, source, openIndex, closeIndex )
	local start = openIndex;
	while( true ) do
		local sa, sb = string.find( source, ";", start );
		local line = string.sub( source, start+1, sa-1 );
		local varType, varNames, arrSizes = Render.Shader.parseDeclaration( shader, line );
		
		for i = 1, #varNames do
			local var = Render.Shader.createVariable( shader, varType, varNames[i], arrSizes[i] );
			table.insert( struct.vars, var );
		end
		struct.computeSize();
		
		start = sb + 1;
		if( start >= closeIndex ) then break; end
	end
end



function Render.Shader.readSource( path )
	local file = io.open( path, "r" );
	io.input( file );
	local source = io.read( "*all" );
	io.close( file );
	return source;
end


function Render.Shader.parseDeclaration( shader, dec )
	local _type = "";
	local _names = {}
	local _sizes = {};
	
	-- Remove all commas
	local s = string.gsub( dec, ",", " " );
	
	local tokens = {};
	
	for token in string.gmatch( s, "%S+" ) do
		table.insert( tokens, token );
	end
	_type = tokens[1];
	
	for i = 2, #tokens do
		local name, size = Render.Shader.getArraySize( shader, tokens[i] );
		_names[i-1] = name;
		_sizes[i-1] = size;
	end
	
	return _type, _names, _sizes;
end


function Render.Shader.parseAssignment( shader, cas )
	local varType = "";
	local _vars = {};
	
	-- remove commas
	local s = string.gsub( cas, ",", " " );
	
	-- extract type from the first assignment
	local tokens = {};
	for token in string.gmatch( s, "%S+" ) do
		table.insert( tokens, token );
	end
	local varType = tokens[1];
	
	for i = 2, #tokens, 3 do
		local name = tokens[i];
		local value = tokens[i+2];
		local var = Render.Shader.createVariable( shader, varType, name, 0 );
		var.value = tonumber( value );
		table.insert( shader.constVars, var );
	end
	
	return _vars;
end


function Render.Shader.getArraySize( shader, name )
	-- check for array brackets []
	local openBracket = string.find( name, "%[" );
	if( openBracket ~= nil ) then
		local closeBracket = string.find( name, "%]", openBracket+1 );
		local sizeString = string.sub( name, openBracket+1, closeBracket-1 );
		local arrSize = tonumber( sizeString );
		if( arrSize == nil ) then
			arrSize = shader.getConstVar( sizeString );
		end
		
		local arrName = string.sub( name, 1, openBracket-1 );
		return arrName, arrSize;
	end
	
	return name, 0;
end

