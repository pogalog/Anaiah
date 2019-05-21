-- Primary entry point for game loop and initial setup
require( "flow/timer" );

_G.Global_time = 0;
_G.Global_clock = 0;
_G.Global_dt = 0;
_G.Global_T0 = 0;
_G.Global_Latency_Offset = 0;

function Game_init( time )
	Global_T0 = time;
end

GC_Timer = createTimer( 1.0, collectgarbage );

function Game_main( time )
	Global_clock = time;
	local t = (time - Global_T0)*1e-9;
	Global_dt = t - Global_time;
	Global_time = t;
	GC_Timer.step( Global_dt );
	
	-- Animation
	LevelMap.animateUnits();
	Overlay.updateDamageDisplays();
	
	-- Asynchronous Tasks
	ATS.executeTasks();
	
	LevelMap.cursor.update();
	LevelMap.updateCamera();
	ActionQueue.execute();
	RemoteQueue.execute();
	AIQueue.execute();
	
	-- Flow Control
	updateFlow();
	
	local data = Network_receive( Network.userdata );
	net.processString( data );
end