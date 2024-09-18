local M = {}
function M.appearance()
    local handle = assert(io.popen('defaults read -g AppleInterfaceStyle 2>&1', 'r'))
    local result = assert(handle:read('*a'))
    handle:close()
    return result:find("^Dark") and "dark" or "light"
end

return M
