local M={}
M.fb_name=""

function M.getName(self, callback)
    local token = facebook.access_token()
    local url = "https://graph.facebook.com/me/?access_token=" .. token
    http.request(url, "GET",
        function(self, id, response)
         local me=json.decode(response.response)
          M.fb_name=me.name
          callback(self, true, M.fb_name)
        end)
end

function M.login(self, callback)
    local permissions = {"public_profile", "email", "user_friends"}
    if facebook then
        print("Facebook login:")
        facebook.login_with_read_permissions(permissions, function(self, data)
            if (data.status == facebook.STATE_OPEN and data.error == nil) then
                print("Successfully logged into Facebook")
                pprint(facebook.permissions())

                local token = facebook.access_token()
                local url = "https://graph.facebook.com/me/?access_token=" .. token
                http.request(url, "GET",
                    function(self, id, response)

                     local me=json.decode(response.response)
                      pprint(me)
                      print(type(me))
                      M.fb_name=me.name
                      callback(self, true, M.fb_name)
                    end)

            else
                print("Failed to get permissions (" .. data.status .. ")")
                pprint(data)
                callback(self, false)
            end
        end)
    end
end


return M
