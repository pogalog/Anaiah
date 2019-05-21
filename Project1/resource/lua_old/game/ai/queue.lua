-- queue.lua
require( "game.list" );

function createQueue()
  local q = {};
  local list = createList();
  q.list = list;
  
  function q.queueItem( item )
    local priority = item.priority;
    if( priority == nil ) then return; end
    local ins = false;
    
    if( q.list.length() > 0 ) then
      -- insert item based on priority comparison
      for i = 1, q.list.length() do
        local ii = q.list.get(i);
        if( priority > ii.priority ) then
          q.list.insert( item, i );
          ins = true;
          break;
        end
      end
    end
    if( ins == false ) then
      q.list.add( item );
    end
    
  end
  
  function q.length()
    return q.list.length();
  end
  
  function q.print()
    print( 'queue length: '..tostring(q.list.length()) );
    for i = 1, q.list.length() do
      print( 'queue item '..tostring(i)..': '..tostring(q.list.get(i)) );
    end
  end
  
  function q.pop()
    local item = q.list.get(1);
    q.list.remove( item );
    return item;
  end
  
  function q.top()
    return q.list.get(1);
  end
  
  
  function q.clear()
    q.list.clear();
  end
  
  function q.get( index )
    return q.list.get( index );
  end
  
  return q;
end
