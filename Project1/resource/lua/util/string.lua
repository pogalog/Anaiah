-- Extended string utilities

function string.trim( s )
	return string.gsub( s, "^%s*(.-)%s*$", "%1" );
--  return (s:gsub("^%s*(.-)%s*$", "%1"));
end