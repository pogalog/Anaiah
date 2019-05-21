-- key bindings

function createBinding( owner )
  local keys = {};
  keys.owner = owner;
  
  function keys.bindKey( keyCode, name, func, val )
  local binding = {};
  binding.code = keyCode;
  binding.name = name;
  binding.func = func;
  binding.val = val;
  keys[keyCode] = binding;
  return binding;
end
  
  return keys;
end