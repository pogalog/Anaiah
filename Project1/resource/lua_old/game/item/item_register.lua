

function Item_Potion( unit, target )
	local healAmount = 30;
	Overlay.createDamageDisplay( target, healAmount );
	target.changeHP( healAmount );
end

function Item_Tonic( unit, target )
	print( "TONIC!!" );
end


function Item_Tar( unit, target )
	print( "TARBALL!!" );
end


