-- LevelMap entrypoint script: test

--local map = Level_Maps.test;

function test_main()

end

-- This function can be removed for in-game execution.
function associate( name )
	Level_Maps.test.setMainLoop( test_main );
	Level_Maps.test.run();
end

return test_main;