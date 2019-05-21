-- warning

_G.Warnings = {};
_G.UseProactiveWarnings = true;

function generateWarning( message, location )
	local warning = {};
	warning.message = message;
	warning.location = location;
	
	function warning.tostring()
		return "WARNING at " .. warning.location .. ": " .. warning.message;
	end
	
	-- add warning to global table
	_G.Warnings[#_G.Warnings+1] = warning;
	
	-- TODO: need to send warnings to a message center (to perhaps be displayed in-game)
	if( _G.UseProactiveWarnings ) then
		print( warning.tostring() );
	end
	
	return warning;
end