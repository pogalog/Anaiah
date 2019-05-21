require( "game.list" );

HINT_ITEM_UNIT = 0;
HINT_ITEM_TILE = 1;

-- AI hint
function createAIHint()
  local hint = {};
  
  -- a list of tiles from which this hint may be used
  hint.activationTiles = createList();
  hint.target = nil;
  hint.relative = false;
  
  -- function that will perform any actions associated with using this hint
  function hint.activate( unit )
    if( hint.isExpired() ) then return; end
    hint.activationCount = hint.activationCount + 1;
    if( hint.activateFunc == nil ) then return; end
    hint.activateFunc( unit );
  end
  
  -- Sets the activation function. This is done so that hint.activate() can stay in place, performing basic functions.
  function hint.setActivationFunc( func )
    hint.activateFunc = func;
  end
  
  -- a priority value used for AI action priorities
  hint.priority = 0;
  
  -- the plain text name of this hint
  hint.name = "Generic Hint";
  
  -- a boolean flag that indicates how many times this hint has been activated
  -- the maximum number of times this hint can be activated (0 means unlimited)
  -- boolean flag that determines whether this hint automatically activates, or if it must be done manually
  hint.activationCount = 0;
  hint.maxActivations = 0;
  hint.automatic = false;
  
  -- exclude teams and units from this hint
  hint.excludedTeams = createList();
  hint.excludedUnits = createList();
  
  -- tells whether the hint has been used up already
  function hint.isExpired()
    return hint.activationCount >= hint.maxActivations;
  end
  
  return hint;
end
