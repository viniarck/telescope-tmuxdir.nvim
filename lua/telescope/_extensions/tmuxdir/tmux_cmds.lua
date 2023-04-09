local tutils = require("telescope.utils")

local M = {}

M.list_sessions = function()
    local cmd = {"tmux", "list-sessions", "-F", "#S"}
    return tutils.get_os_command_output(cmd)
end

M.new_session = function(name, opts)
    local cmd = {"tmux", "new-session", "-d", "-s", name}

    if opts["start_dir"] ~= nil then
        table.insert(cmd, "-c")
        table.insert(cmd, vim.fn.expand(opts["start_dir"]))
    end

    if opts["shell_cmd"] ~= nil then
        table.insert(cmd, opts["shell_cmd"])
    else
        table.insert(cmd, "nvim -c 'e .'")
    end

    return tutils.get_os_command_output(cmd)
end

M.kill_session = function(name)
    local cmd = {"tmux", "kill-session", "-t", name}
    return tutils.get_os_command_output(cmd)
end

M.switch_client = function(name)
    local cmd = {"tmux", "switch-client", "-t", name}
    return tutils.get_os_command_output(cmd)
end

M.mapped_sessions = function()
    local sessions = {}
    for _index, value in ipairs(M.list_sessions()) do
        sessions[value] = value
    end
    return sessions
end

return M
