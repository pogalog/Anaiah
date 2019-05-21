-- control regime

-- Define a control regime which dictates primary input processing.
function createControlRegime()
  local cr = {};
  cr.keys = {};
  
  function cr.bindKey( keyCode, name, func, val )
    local binding = {};
    binding.code = keyCode;
    binding.name = name;
    binding.func = func;
    binding.val = val;
    cr.keys[keyCode] = binding;
    return binding;
  end
  
  function cr.keyPress( key, ... )
    local kbind = cr.keys[key];
    if( kbind == nil ) then return; end
    local kfunc = kbind.func;
    kfunc( kbind.val, ... );
  end
  
  return cr;
end