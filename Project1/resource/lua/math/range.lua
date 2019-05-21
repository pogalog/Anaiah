-- Range

function createRange( low, high )
	local range = {};
	range.low = low;
	range.high = high;

	function range.withinRangeInclusive( r )
		return r >= range.low and r <= range.high;
	end

	function range.withinRangeExclusive( r )
		return r > range.low and r < range.high;
	end

	return range;
end

function round( x, nd )
  local mult = 10^(nd or 0);
  return math.floor( x * mult + 0.5 ) / mult;
end