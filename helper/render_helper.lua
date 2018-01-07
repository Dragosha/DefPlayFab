local M = {}

function M.action_to_position(action)
	return vmath.vector3((M.xoffset or 0) + action.screen_x / (M.zoom_factor or 1), (M.yoffset or 0) + action.screen_y / (M.zoom_factor or 1), 0)
end


M.clear_color=vmath.vector4(14/255, 22/255, 24/255, 0)
M.view = vmath.matrix4()
M.proj = vmath.matrix4()

M.window_res = vmath.vector3()
M.window_halfres = vmath.vector3()
M.original_height=0
M.original_width=0

M.isOrthographic=false
function M.cameraOrthographic(bool)
	if bool then
		msg.post("@render:", "set_view_projection", {id = go.get_id(), view = vmath.matrix4(),projection=vmath.matrix4() })
		M.isOrthographic=true
	else
		M.isOrthographic=false
	end
end

--########################################  Set Window Resolution  ########################################
function M.set_window_res(x, y)
	--if x~= M.window_res.x or y~=M.window_res.y then	end
	M.window_res.x = x;  M.window_res.y = y
	M.window_halfres.x = x * 0.5;  M.window_halfres.y = y * 0.5

	M.original_width = render.get_width()
	M.original_height = render.get_height()
	local zoom_factor = math.min(x/ M.original_width, y / M.original_height)
	M.zoom_factor = zoom_factor
end

function M.fpsInit()
	M.frame_count = 0
	M.fps_start = socket.gettime()
end
function M.fpsDraw()
	M.frame_count = M.frame_count + 1
    local fps = M.frame_count / (socket.gettime() - M.fps_start)
    msg.post("@render:", "draw_text", { text = ("FPS: %d"):format(fps), position = vmath.vector3(M.window_res.x-120, M.window_res.y - 20, 0) } )
end

function M.set_fixed_aspect_ratio(view, x, y, width, height, self)
	M.set_window_res(width,height)

	render.set_viewport(x, y, width, height)
	render.set_view(view)

	-- center (and zoom out if needed)
	local original_width = render.get_width()
	local original_height = render.get_height()
	local zoom_factor = math.min(width / original_width, height / original_height)
	local projected_width = width / zoom_factor
	local projected_height = height / zoom_factor
	local xoffset = -(projected_width - original_width) / 2
	local yoffset = -(projected_height - original_height) / 2

	--if self.projection==nil then
	if M.isOrthographic then
		render.set_projection(vmath.matrix4_orthographic(xoffset, xoffset + projected_width, yoffset, yoffset + projected_height, -1000, 1000))
	else
	-- set the projection from the camera instead of the default orthographic projection
		render.set_projection(self.projection)
	end

	--if self.projection then msg.post("@render:", "draw_text", { text = "projection: "..self.projection, position = vmath.vector3(10, 840, 0) } ) end
	-- store zoom and offset for use when translating touch events to positions
	M.zoom_factor = zoom_factor
	M.xoffset = xoffset
	M.yoffset = yoffset
end



local nearz = 100
local farz = 1000
local abs_nearz = nearz -- absolute nearz and farz
local abs_farz = farz -- regular nearz and farz are relative to camera z
local world_plane_z = 0
local campos = vmath.vector3(0, 0, 1000)


--########################################  Screen to World  ########################################
function M.screen_to_world(x, y)
	local m = vmath.inv(M.proj * M.view)

	-- Remap coordinates to range -1 to 1
	local x1 = (x - M.window_res.x * 0.5) / M.window_res.x * 2
	local y1 = (y - M.window_res.y * 0.5) / M.window_res.y * 2

	local np = m * vmath.vector4(x1, y1, -1, 1)
	local fp = m * vmath.vector4(x1, y1, 1, 1)
	np = np * (1/np.w)
	fp = fp * (1/fp.w)

	local t = (world_plane_z - abs_nearz) / (abs_farz - abs_nearz)
	local worldpos = vmath.lerp(t, np, fp)
	return vmath.vector3(worldpos.x, worldpos.y, worldpos.z)
end

--########################################  World to Screen  ########################################
function M.world_to_screen(pos)
	local m = M.proj * M.view
	pos = vmath.vector4(pos.x, pos.y, pos.z, 1)

	pos = m * pos
	pos = pos * (1/pos.w)
	pos.x = (pos.x / 2 + 0.5) * M.window_res.x
	pos.y = (pos.y / 2 + 0.5) * M.window_res.y

	return vmath.vector3(pos.x, pos.y, 0)
end



--########################################  Set Camera  ########################################
function M.set_camera(pos, near, far) -- near & far args are optional
	nearz = near or nearz
	farz = far or farz

	campos = pos
	abs_nearz = campos.z - nearz
	abs_farz = campos.z - farz
end

return M
