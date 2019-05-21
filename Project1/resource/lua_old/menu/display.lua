-- displays

-- create main displays
function initializeDisplays()
  local context = _G.gameContext;
  
  tileDisplay = PF.create2DDisplay( 0, 0.75, 0.15, 0.2 );
  local tileName = PF.addTextToJDisplay( tileDisplay, "Tile", "tile_name", 0, 0.75, 0.25 );
  local atkMod = PF.addTextToJDisplay( tileDisplay, "ATK: ", "atk_mod", 0, 0.50, 0.25 );
  local defMod = PF.addTextToJDisplay( tileDisplay, "DEF: ", "def_mod", 0, 0.25, 0.25 );
  
  unitDisplay = PF.create2DDisplay( 0.75, 0.75, 0.25, 0.2 );
  local unitName = PF.addTextToJDisplay( unitDisplay, "Unit", "unit_name", 0, 0.75, 0.25 );
  local unitHP = PF.addTextToJDisplay( unitDisplay, "HP", "unit_hp", 0, 0.5, 0.25 );
  local unitAP = PF.addTextToJDisplay( unitDisplay, "AP", "unit_ap", 0, 0.25, 0.25 );
  
  damageDisplay = PF.create3DDisplay( 1, 1 );
  local damageText = PF.addTextToJDisplay( damageDisplay, "DMG", "damage", 0, 0, 1.3, 1.3 );
  PF.setTextColor( damageText, 1, 0.1, 0.3, 1 );
  
  counterDisplay = PF.create3DDisplay( 1, 1 );
  local counterText = PF.addTextToJDisplay( counterDisplay, "DMG", "damage", 0, 0, 1.3, 1.3 );
  PF.setTextColor( counterText, 1.0, 0.1, 0.3, 1 );
  
  healDisplay = PF.create3DDisplay( 1, 1 );
  local healText = PF.addTextToJDisplay( healDisplay, "heal", "heal", 0, 0, 1.3, 1.3 );
  PF.setTextColor( healText, 0.0, 0.9, 0.2, 1 );
end


-- update displays
function updateTileDisplay()
  local map = _G.currentMap;
  local tile = map.getSelectedTile();
  if( tile == nil ) then return; end
  if( tile.exists == false ) then return; end
  
  local txt = tile.address.x..", "..tile.address.y;
  PF.updateJTextFromHandle( tileDisplay, "tile_name", txt );
  txt = "ATK: "..tile.modifiers.atk;
  PF.updateJTextFromHandle( tileDisplay, "atk_mod", txt );
  txt = "DEF: "..tile.modifiers.def;
  PF.updateJTextFromHandle( tileDisplay, "def_mod", txt );
  
end

function updateUnitDisplay()
  local map = _G.currentMap;
  local unit = map.getUnitOnCursor();
  local vis = (unit~=nil) or (map.selectedUnit~=nil);
  if( unit == nil ) then unit = map.selectedUnit; end
  PF.setDisplayVisible( unitDisplay, vis );
  if( vis == false ) then return; end
  
  PF.updateJTextFromHandle( unitDisplay, "unit_name", unit.name );
  local txt = "HP "..unit.stat.hp.." / "..unit.stat.maxHP;
  PF.updateJTextFromHandle( unitDisplay, "unit_hp", txt );
  local ap = round( unit.stat.ap, 1 );
  --local ap = math.floor( 10.0*unit.stat.ap ) / 10.0;
  txt = string.format( 'AP %.1f / %.1f', ap, unit.stat.maxAP );
  PF.updateJTextFromHandle( unitDisplay, "unit_ap", txt );
end

function displayHealing( data )
  local txt = '+'..data.healAmount;
  PF.updateJTextFromHandle( healDisplay, "heal", txt );
  PF.activateDisplay( healDisplay, 1.5, data.target, data.unit );
end

function displayDamage( data )
  local txt = nil;
  local hitText = nil;
  
  if( data.attackSuccess ) then
    hitText = "Hit!";
    if( data.critical ) then
      hitText = "Critical!";
    end
    if( data.damage == 0 ) then
      txt = "No Damage!";
    else
      txt = hitText..'\n-'..tostring( data.damage );
    end
  else
    txt = "Miss!";
  end
  PF.updateJTextFromHandle( damageDisplay, "damage", txt );
  PF.activateDisplay( damageDisplay, 1.5, data.target, data.attacker );
  
  txt = nil;
  hitText = nil;
  if( data.didCounter ) then
    local cd = data.counterData;
    if( cd.attackSuccess ) then
      hitText = "Hit!";
      if( cd.critical ) then
        hitText = "Critical!";
      end
      if( cd.damage == 0 ) then
        txt = "No Damage!";
      else
        txt = hitText..'\n-'..tostring( cd.damage );
      end
    else
      txt = "Miss!";
    end
    PF.updateJTextFromHandle( counterDisplay, "damage", txt );
    PF.activateDisplay( counterDisplay, 1.5, data.attacker, data.target );
  end
  
end



