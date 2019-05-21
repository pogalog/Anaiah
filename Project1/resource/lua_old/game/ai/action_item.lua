-- action_item

function createActionItem( mainFunc )
  local item = {};
  
  function item.execute()
    -- this needs to be overridden
    print( 'oops! you were supposed to override this function!' );
  end
  
  if( mainFunc ~= nil ) then
    item.execute = mainFunc;
  end
  
  
  return item;
end
