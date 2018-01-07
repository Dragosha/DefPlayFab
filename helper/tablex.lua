local tablex={}

--- make a deep copy of a table, recursively copying all the keys and fields.
-- This will also set the copied table's metatable to that of the original.
-- @within Copying
-- @tab t A table
-- @return new table
function tablex.deepcopy(t)
    if type(t) ~= 'table' then return t end
    --assert_arg_iterable(1,t)
    local mt = getmetatable(t)
    local res = {}
    for k,v in pairs(t) do
        if type(v) == 'table' then
            v = tablex.deepcopy(v)
        end
        res[k] = v
    end
    setmetatable(res,mt)
    return res
end

--- return the index of a value in a list.
-- Like string.find, there is an optional index to start searching,
-- which can be negative.
-- @within Finding
-- @array t A list-like table
-- @param val A value
-- @int idx index to start; -1 means last element,etc (default 1)
-- @return index of value or nil if not found
-- @usage find({10,20,30},20) == 2
-- @usage find({'a','b','a','c'},'a',2) == 3
function tablex.find(t,val,idx)
    --assert_arg_indexable(1,t)
    idx = idx or 1
    if idx < 0 then idx = #t + idx + 1 end
    for i = idx,#t do
        if t[i] == val then return i end
    end
    return nil
end

--- return the index of a value in a list, searching from the end.
-- Like string.find, there is an optional index to start searching,
-- which can be negative.
-- @within Finding
-- @array t A list-like table
-- @param val A value
-- @param idx index to start; -1 means last element,etc (default 1)
-- @return index of value or nil if not found
-- @usage rfind({10,10,10},10) == 3
function tablex.rfind(t,val,idx)
    --assert_arg_indexable(1,t)
    idx = idx or #t
    if idx < 0 then idx = #t + idx + 1 end
    for i = idx,1,-1 do
        if t[i] == val then return i end
    end
    return nil
end

--- return the index (or key) of a value in a table using a comparison function.
-- @within Finding
-- @tab t A table
-- @func cmp A comparison function
-- @param arg an optional second argument to the function
-- @return index of value, or nil if not found
-- @return value returned by comparison function
function tablex.find_if(t,cmp,arg)
    --assert_arg_iterable(1,t)
    cmp = function_arg(2,cmp)
    for k,v in pairs(t) do
        local c = cmp(v,arg)
        if c then return k,c end
    end
    return nil
end

--- apply a function to all values of a table.
-- This returns a table of the results.
-- Any extra arguments are passed to the function.
-- @within MappingAndFiltering
-- @func fun A function that takes at least one argument
-- @tab t A table
-- @param ... optional arguments
-- @usage map(function(v) return v*v end, {10,20,30,fred=2}) is {100,400,900,fred=4}
function tablex.map(fun,t,...)
    --assert_arg_iterable(1,t)
    fun = function_arg(1,fun)
    local res = {}
    for k,v in pairs(t) do
        res[k] = fun(v,...)
    end
    return setmeta(res,t)
end

--- apply a function to all values of a list.
-- This returns a table of the results.
-- Any extra arguments are passed to the function.
-- @within MappingAndFiltering
-- @func fun A function that takes at least one argument
-- @array t a table (applies to array part)
-- @param ... optional arguments
-- @return a list-like table
-- @usage imap(function(v) return v*v end, {10,20,30,fred=2}) is {100,400,900}
function tablex.imap(fun,t,...)
    --assert_arg_indexable(1,t)
    fun = function_arg(1,fun)
    local res = {}
    for i = 1,#t do
        res[i] = fun(t[i],...) or false
    end
    return setmeta(res,t,'List')
end
--- apply a function to all elements of a table.
-- The arguments to the function will be the value,
-- the key and _finally_ any extra arguments passed to this function.
-- Note that the Lua 5.0 function table.foreach passed the _key_ first.
-- @within Iterating
-- @tab t a table
-- @func fun a function with at least one argument
-- @param ... extra arguments
function tablex.foreach(t,fun,...)
    --assert_arg_iterable(1,t)
    fun = function_arg(2,fun)
    for k,v in pairs(t) do
        fun(v,k,...)
    end
end

--- apply a function to all elements of a list-like table in order.
-- The arguments to the function will be the value,
-- the index and _finally_ any extra arguments passed to this function
-- @within Iterating
-- @array t a table
-- @func fun a function with at least one argument
-- @param ... optional arguments
function tablex.foreachi(t,fun,...)
    --assert_arg_indexable(1,t)
    fun = function_arg(2,fun)
    for i = 1,#t do
        fun(t[i],i,...)
    end
end
return tablex
