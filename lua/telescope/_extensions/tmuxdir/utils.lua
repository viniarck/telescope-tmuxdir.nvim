local tutils = require("telescope.utils")

local M = {}

-- Find git repos
M.find_git_repos = function(base_dir)
    -- TODO add support for find too
    local dirs = tutils.get_os_command_output({"fd", "-HI", "^.git$", "-d", "2"}, base_dir)
    local res = {}
    for _i, value in ipairs(dirs) do
        local s, c = string.gsub(value, ".git/", "")
        table.insert(res, base_dir .. s)
    end
    return res
end

-- Ensures a dir has a trailing separator to normalize
M.ensures_trailing_sep = function(dir)
    if string.match(dir, "/$") == "/" then
        return dir
    else
        return dir .. "/"
    end
end

-- Replace dots since it's not allowed on tmux session names
M.replace_dots = function(name)
   return string.gsub(name, "%.", "-")
end

-- Assert a tmux is attached or error out
M.assert_is_attached = function()
    if vim.fn.getenv("TMUX") == vim.NIL then
        error("This plugin requires that you initially have a tmux attached session")
    end
end

return M
