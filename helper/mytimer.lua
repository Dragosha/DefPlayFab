local M = {}

function M.create()
	local q={}
	local timers={}

	function timers:once(seconds, callback)
		table.insert(q,{seconds = seconds,callback=callback})
	end

	function timers:update(dt)
		for i,v in ipairs(q) do
            v.seconds = v.seconds - dt
			if v.seconds<=0 then
                if v.callback then v.callback(self) end
                table.remove(q,i)
                --print("timer cb", i, #q)
            end
		end
	end

    function timers:resetAll()
        q={}
    end

	return timers
end

return M
