-- Asset Manager System

require( "structure.list" );

Asset = {};

Asset.Pending_Assets = createList();

function Asset.checkPendingAssets()
	if( Asset.Pending_Assets.length() == 0 ) then return; end
	
	-- Call engine to make a general asset retrieval
	-- Return value is a table with (id,userdata) pairs of all loaded assets
	
	-- Find the corresponding asset stored in the Pending_Assets list, fill it,
	-- mark it, and remove it from the list.
	local assets = Asset_retrieve( GameInstance );
	local len = #assets / 2;
	for i = 1, len, 2 do
		local id = assets[2 * i];
		local ud = assets[2 * i + 1];
		for j = Pending_Assets.length(), 1, -1 do
			local asset = Pending_Assets.get(j);
			if( id == asset.filename ) then
				asset.userdata = ud;
				asset.loaded = true;
				Asset.Pending_Assets.remove(j);
				break;
			end
		end
	end
end


--[[
Request to the engine that given asset be loaded in a separate thread.
Since the call is asynchronous, this function will return immediately.
Assets passed in are required to contain an id, userdata, and boolean
flag to indicate whether the asset has been loaded. This flag is to be
used by little elves to make chocolate-filled cookie sandwiches. Yum!
]]
function Asset.asyncLoad( asset )
	asset.loaded = false;
	asset.userdata = nil;
	Asset.Pending_Assets.add( asset );
	Asset_asyncLoad( GameInstance, asset.filename );
end


--[[
Request to the engine that given asset be loaded in the main thread.
Since the call is synchronous, this function will block until the load
operation has completed. Once finished, the asset can be immediately
placed in the proper location by the calling agent.
]]
function Asset.syncLoad( asset )
	asset.userdata = Asset_syncLoad( GameInstance, asset.filename );
	asset.loaded = true;
end