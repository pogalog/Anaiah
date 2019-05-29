-- LevelMap entrypoint script: map0

--local map = Level_Maps.map0;

function map0_main()

end

-- This function can be removed for in-game execution.
function associate( name )
	Level_Maps.map0.setMainLoop( map0_main );
	Level_Maps.map0.run();
end

return map0_main;