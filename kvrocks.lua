-- local log = function(...)
--   local li = {}
--   for _, v in ipairs({ ... }) do
--     table.insert(li, cjson.encode(v))
--   end
--   redis.log(redis.LOG_NOTICE, unpack(li))
-- end

-- -- 用来获取登录的用户，用户 id - 最后登录时间的时间戳，已经退出登录的用户积分是负数
-- function zumax(KEYS)
--   -- flags no-writes
--   local zset = unpack(KEYS)
--   local max = redis.call("ZRANGE", zset, 0, 0, "REV", "WITHSCORES")
--   if #max > 0 then
--     max = max[1]
--     if max[2].double > 0 then
--       return max[1]
--     end
--   end
-- end

local ZADD = function(key, score, member)
	return redis.call("ZADD", key, score, member)
end

local ZSCORE = function(key, member)
	local r = redis.call("ZSCORE", key, member)
	if r then
		return r.double
	end
end

function zsetId(KEYS, ARGS)
	local zset = KEYS[1]
	local key = ARGS[1]
	local id = ZSCORE(zset, key)
	if id then
		return id
	end
	id = redis.call("ZREVRANGE", zset, 0, 0, "WITHSCORES")[1]
	if id then
		id = 1 + id[2].double
	else
		id = 33
	end

	ZADD(zset, id, key)
	return id
end
