local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("tmuxdir requires nvim-telescope/telescope.nvim")
end

local main = require("telescope._extensions.tmuxdir.main")

return telescope.register_extension({
    setup = main.setup,
    exports = {
        sessions = main.sessions,
        dirs = main.dirs,
    }
})
