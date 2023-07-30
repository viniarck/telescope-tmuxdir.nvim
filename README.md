<div align="center">
  <h1><code>telescope-tmuxdir.nvim</code></h1>

  <strong>📁⚡tmux session workspace plugin for nvim.</strong> (ported from <a href="https://github.com/viniarck/tmuxdir.nvim">tmuxdir.nvim</a>)

</div>


## telescope-tmuxdir workflow

- You can manage tmux sessions and projects from nvim.
- A project directory is identified with a root marker in a set of base directories (e.g.,`~/repos/`).
- Each project is mapped to a tmux session, so a tmux session acts as a workspace.
- You can have additional tmux sessions mapped to the same project if you want.

## Installation

- telescope-tmuxdir requires [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- telescope-tmuxdir optionally uses [fd](https://github.com/sharkdp/fd)

If you use **vim-plug**:

```viml
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'viniarck/telescope-tmuxdir.nvim'
```

## Configuration

You need to set `base_dirs` and `find_cmd`:

```
telescope.setup{
  extensions = {
   tmuxdir = {
     base_dirs = {"~/repos"},
     find_cmd = {"fd", "-HI", "^.git$", "-d", "2"},
   }
  }
}
```

## How to use

```
:Telescope tmuxdir sessions
```

```
:Telescope tmuxdir dirs
```
