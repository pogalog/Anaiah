-- tactical strategy
-- The tactical strategy is used by teams to provide an overall, coherent
-- strategy to AI controlled units.

function createTacticalStrategy()
  local ts = {};
  ts.goal = 3;      -- range[0,5]; goal-mindedness of team
  ts.cluster = 5;   -- range[1,inf]; average desired distance between units
  ts.violence = 10;  -- range[-10,10]; will to attack
  ts.healing = 3;   -- range[-10,10]; will to heal allies
  ts.protect = 3;   -- range[-10,10]; desire to avoid damage
  ts.buff = 0;      -- range[-10,10]; desire to apply buffs to allies
  ts.debuff = 0;    -- range[-10,10]; desire to apply debuffs to enemies
  ts.explore = 1;   -- range[-10,10]; desire to explore and collect items
  
  return ts;
end
