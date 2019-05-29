-- Render Pipeline
-- Maintains a group of Render Units and manages all rendering parameters for a scene

require( "render.main" );
require( "structure.list" );


function Render.createPipeline()
	local pipeline = {};
	pipeline.units = createList();
	
	function pipeline.addUnit( unit )
		pipeline.units.add( unit );
		Render_addRenderUnit( GameInstance, unit.userdata );
	end
	
	function pipeline.addUnits( ... )
		for i, v in ipairs( {...} ) do
			pipeline.addUnit( v );
		end
	end
	
	function pipeline.init()
		-- probably do something in here
	end
	
	function pipeline.clearBufferBits( ... )
		for i, v in ipairs( {...} ) do
			v.clearBufferBits();
		end
	end
	
	return pipeline;
end