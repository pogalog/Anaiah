-- Game System
Game = {};


require("game.camera.main");
require("game.event.encounter");
require("game.cursor");
require("game.player");
require("game.team");
require("game.unit");
require("game.unit_path");
require("game.map.grid");
require("game.map.level_map");
require("game.map.tile");
require("game.map.tile_range");
require("game.camera.main");
require("game.item.main");
require("game.ai.main");
require("executive.main");



Game.LevelMaps = createList();



function Game.lookupMap(mapName)
	for i = 1, Game.LevelMaps.length() do
		local map = Game.LevelMaps.get(i);
		
		if( map.name == mapName ) then
			return map;
		end
	end
	
	return nil;
end



function InitGame()
	Exec.initTaskSequence();
end