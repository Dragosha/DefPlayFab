local M={}
M.tweens={}
function M.go(url, property, playback, to, easing, duration, delay, complete_function)
    local a=M.tweens[url]
    if a then
        M.tweens[url]=nil
        go.cancel_animations(url, a.property)
        if a.property=="position" then       go.set_position(a.to, url)
        elseif a.property=="position.z" then go.set(url, "position.z", a.to)
        elseif a.property=="position.x" then go.set(url, "position.x", a.to)
        elseif a.property=="position.y" then go.set(url, "position.y", a.to)
        elseif a.property=="euler.y" then go.set(url, "euler.y", a.to)
        elseif a.property=="euler.x" then go.set(url, "euler.x", a.to)
        elseif a.property=="euler.z" then go.set(url, "euler.z", a.to)
        end
        if a.complete_function then a.complete_function(url) end
    end

    a={property=property, to=to, complete_function=complete_function}
    M.tweens[url]=a
    local function boo()
        M.tweens[url]=nil
        if complete_function then complete_function(url) end
    end
    go.animate(url, property, playback, to, easing, duration, delay, boo)
end

function M:timer(name, duration, complete_function)
    if not self.__timers then self.__timers={} end
    local n="__timers."..name
    local t=self.__timers[name]
    if t then
        go.cancel_animations("#", n)
    end
    self.__timers[name]=0
    go.animate("#", n, go.PLAYBACK_ONCE_FORWARD, 1, go.EASING_LINEAR, duration, 0, function()
        self.__timers[name]=nil
        complete_function(self)
    end)
end

return M
