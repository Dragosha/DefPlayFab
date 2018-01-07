-- Small router for Defold window system messages
--
-- © 2017 Alexey Gulev.
-- https://agulev.com
-- https://github.com/AGulev/ag_window

local M = {}

M.FOCUS_LOST = hash("focus_lost_event")
M.FOCUS_GAINED = hash("focus_gained_event")
M.RESIZED = hash("resized_event")

local focus_listeners = {}
local resize_listeners = {}

-- Add listener for the focus events
function M.add_focus_listener(instance)
  table.insert(focus_listeners, instance)
end

-- Remove listener for the focus events
function M.remove_focus_listener(instance)
  for i = #focus_listeners,1,-1 do
     local v = focus_listeners[i]
     if v == instance then
       table.remove(focus_listeners, i)
     end
  end
end

-- Resend a focus system message to the listeners
function M.send_to_all_focus_listeners(event)
    for k,v in pairs(focus_listeners) do
      msg.post(v, event)
    end
end

-- Add listener for the resize event
function M.add_resize_listener(instance)
  table.insert(resize_listeners, instance)
end

-- Remove listener for the resize event
function M.remove_resize_listener(instance)
  for i = #resize_listeners,1,-1 do
     local v = resize_listeners[i]
     if v == instance then
       table.remove(resize_listeners, i)
     end
  end
end

-- Resend a resize system message to the listeners
function M.send_to_all_resize_listeners(event, data)
    for k,v in pairs(resize_listeners) do
      msg.post(v, event, data)
    end
end

return M
