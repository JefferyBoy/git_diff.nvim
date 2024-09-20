# git_diff.nvim

This is a Neovim plugin that provides a git diff window for the current file.

- Show diff changes for the current file.
![git_diff_change](./assets/git_diff_change.gif)

- Show diff changes for the current file with a specific branch.
![git_diff_branch](./assets/git_diff_branch.gif)

- Show diff history for the current file.
![git_diff_log](./assets/git_diff_log.gif)

## Install

Using vim-plug:
```
Plug 'JefferyBoy/git_diff.nvim'
```
Using lazy.nvim
```
use {'JefferyBoy/gif_diff.nvim'}
```

## Commands

- `GitDiffFileHistory` - Show git log history for the current file.
- `GitDiffFileChanges` - show git diff for the current file.
- `GitDiffFileByBranch` - Show git diff for the current file with a specific branch.
