local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local transform_mod = require("telescope.actions.mt").transform_mod
local tmux_cmds = require("telescope._extensions.tmuxdir.tmux_cmds")
local utils = require("telescope._extensions.tmuxdir.utils")

local M = {}

M.setup = function(opts)
    local base_dirs = opts["base_dirs"] or {}
    if type(base_dirs) ~= "table" then
        error("base_dirs var is supposed to be a table")
    end
    vim.api.nvim_set_var("tmuxdir_base_dirs", base_dirs)

    local find_cmd = opts["find_cmd"] or {"fd", "-HI", "^.git$", "-d", "2"}
    if type(find_cmd) ~= "table" then
        error("find_cmd var is supposed to be a table")
    end
    vim.api.nvim_set_var("tmuxdir_find_cmd", find_cmd)
end

M.sessions = function(opts)
    utils.assert_is_attached()

    local listed_sessions = tmux_cmds.list_sessions()

    local custom_actions = transform_mod({
        delete_session = function(prompt_bufnr)
            local entry = action_state.get_selected_entry()
            local session = entry.value
            local confirmation = vim.fn.input("Kill session '" .. session .. "'? [y/n] ")
            if string.lower(confirmation) ~= "y" then
                return
            end
            tmux_cmds.kill_session(session)
            actions.close(prompt_bufnr)
        end,
    })

    pickers.new(opts, {
        prompt_title = "Sessions",
        finder = finders.new_table {
            results = listed_sessions,
            entry_maker = function(result)
                return {
                    value = result,
                    display = result,
                    ordinal = result,
                    valid = true,
                }
            end
        },
        sorter = sorters.get_generic_fuzzy_sorter(),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local entry = action_state.get_selected_entry()
                local session = entry.value
                tmux_cmds.switch_client(session)
                actions.close(prompt_bufnr)
            end)
            actions.close:enhance({
                post = function ()
                    if opts.quit_on_select then
                        vim.cmd("q!")
                    end
                end
            })

            map("i", "<C-d>", custom_actions.delete_session)
            map("n", "d", custom_actions.delete_session)

            return true
        end,
    }):find()
end

M.dirs = function(opts)
    utils.assert_is_attached()

    local results = {}
    local base_dirs = vim.api.nvim_get_var("tmuxdir_base_dirs")
    local find_cmd = vim.api.nvim_get_var("tmuxdir_find_cmd")
    -- make a copy of cmd since get_os_command_output mutates it
    local cmd = {}
    for _i, v in ipairs(find_cmd) do
        table.insert(cmd, v)
    end
    for _i, base_dir in ipairs(base_dirs) do
        for _j, dir in ipairs(utils.find_git_repos(cmd, utils.ensures_trailing_sep(base_dir))) do
            table.insert(results, dir)
        end
    end

    local custom_actions = transform_mod({
        create_extra_session = function(prompt_bufnr)
            local entry = action_state.get_selected_entry()
            local input = vim.fn.input("Enter an identifier, it'll be '1' by default: ")
            if input == "" then
                input = "1"
            end
            local session = utils.replace_dots(entry.value .. input)
            tmux_cmds.new_session(session, {start_dir=entry.value})
            tmux_cmds.switch_client(session)
            actions.close(prompt_bufnr)
        end,
    })

    pickers.new(opts, {
        prompt_title = 'Dirs',
        finder = finders.new_table {
            results = results,
            entry_maker = function(result)
                return {
                    value = result,
                    display = result,
                    ordinal = result,
                    valid = true
                }
            end
        },
        sorter = sorters.get_generic_fuzzy_sorter(),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local entry = action_state.get_selected_entry()
                local session = utils.replace_dots(entry.value)
                tmux_cmds.new_session(session, {start_dir=entry.value})
                tmux_cmds.switch_client(session)
                actions.close(prompt_bufnr)
            end)
            actions.close:enhance({
                post = function ()
                    if opts.quit_on_select then
                        vim.cmd('q!')
                    end
                end
            })

            map("i", "<C-e>", custom_actions.create_extra_session)
            map("n", "e", custom_actions.create_extra_session)

            return true
        end,
    }):find()
end

return M
