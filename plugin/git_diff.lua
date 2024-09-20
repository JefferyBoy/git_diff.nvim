-- Git diff工具

local M = {}

-- 获取git项目根目录
local function get_git_project_path()
	local repo_root_command = "git rev-parse --show-toplevel"
	local repo_root = vim.fn.system(repo_root_command)
	repo_root = repo_root:gsub("\n$", "")
	return repo_root
end

-- 运行命令并在当前buffer的下面显示结果
local function run_cmd_and_show_result(cmd)
	local output = vim.fn.systemlist(cmd)
	if #output > 0 then
		-- 在当前buffer的下面拆分创建新的buffer
		-- vim.api.nvim_command("botright new")
		local file = vim.api.nvim_buf_get_name(0)
		file = string.match(file, "([^/]+)$") or ""
		local bufid = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_command("buffer " .. bufid)
		vim.api.nvim_buf_set_name(bufid, "Log:" .. file)
		vim.api.nvim_buf_set_lines(bufid, 0, -1, false, output)
		vim.api.nvim_buf_set_option(bufid, "buftype", "nofile")
		-- vim.api.nvim_buf_set_option(0, "bufhidden", "delete")
		vim.api.nvim_buf_set_option(bufid, "swapfile", false)
		vim.api.nvim_buf_set_option(bufid, "buflisted", true)
		vim.api.nvim_buf_set_option(bufid, "filetype", "git")
		vim.api.nvim_buf_set_option(bufid, "readonly", true)
		vim.api.nvim_buf_set_option(bufid, "modifiable", false)
	else
		vim.api.nvim_echo({ { "Error output is empty", "ErrorMsg" } }, true, {})
	end
end

-- 显示当前文件的修改历史记录
function M.show_git_file_history()
	local file_path = vim.fn.expand("%:p")
	local repo_root = get_git_project_path()
	if repo_root == "" or repo_root == "fatal: Not a git repository (or any of the parent directories): ." then
		vim.api.nvim_echo(
			{ { "Not in a Git repository or unable to find the repository root.", "WarningMsg" } },
			true,
			{}
		)
		return
	end
	file_path = string.gsub(file_path, repo_root, ".", 1)
	local command = string.format('git -C "%s" log --patch "%s"', repo_root, file_path)
	run_cmd_and_show_result(command)
end

-- 显示当前文件的修改对比
function M.show_git_file_diff()
	local file_path = vim.fn.expand("%:p")
	local repo_root = get_git_project_path()
	if repo_root == "" or repo_root == "fatal: Not a git repository (or any of the parent directories): ." then
		vim.api.nvim_echo(
			{ { "Not in a Git repository or unable to find the repository root.", "WarningMsg" } },
			true,
			{}
		)
		return
	end
	file_path = string.gsub(file_path, repo_root, ".", 1)
	local command = string.format('git -C "%s" diff "%s"', repo_root, file_path)
	run_cmd_and_show_result(command)
end

function M.show_diff_by_branch_internal(bufid, winid)
	local branch = vim.api.nvim_buf_get_text(bufid, 0, 0, 0, -1, {})
	vim.api.nvim_win_close(winid, true)
	local repo_root = get_git_project_path()
	if repo_root == "" then
		vim.api.nvim_echo({ { "Not in a Git repository", "WarningMsg" } }, true, {})
		return
	end
	local file_path = string.gsub(vim.fn.expand("%:p"), repo_root, ".", 1)
	local cmd = string.format('git -C "%s" diff "%s" "%s"', repo_root, branch[1], file_path)
	run_cmd_and_show_result(cmd)
end

-- 对比另一个分支的相同文件
function M.show_diff_by_branch()
	local repo_root = get_git_project_path()
	if repo_root == "" then
		vim.api.nvim_echo({ { "Not in a Git repository", "WarningMsg" } }, true, {})
		return
	end
	-- 窗口属性
	local win_width = 30
	local win_height = 2
	local win_opts = {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = 10,
		col = math.ceil((vim.api.nvim_get_option("columns") - win_width) / 2),
		border = "single",
		focusable = true,
		title = "Diff branch",
	}
	-- 创建buffer，并把buffer绑定到窗口
	local bufid = vim.api.nvim_create_buf(true, true)
	local winid = vim.api.nvim_open_win(bufid, true, win_opts)
	-- 进入插入模式
	vim.cmd("normal w")
	vim.cmd("startinsert")

	-- 在buffer中映射快捷键
	local map_opts = { noremap = true, silent = true }
	vim.api.nvim_buf_set_keymap(0, "i", "<Esc>", "<cmd>stopinsert | q!<CR>", map_opts)
	vim.api.nvim_buf_set_keymap(0, "n", "<Esc>", "<cmd>stopinsert | q!<CR>", map_opts)
	vim.api.nvim_buf_set_keymap(
		0,
		"i",
		"<CR>",
		"<cmd>stopinsert | lua require('plugins.gitbox').show_diff_by_branch_internal("
			.. bufid
			.. ", "
			.. winid
			.. ")<CR>",
		map_opts
	)
end

vim.api.nvim_create_user_command(
  "GitDiffFileHistory",
  M.show_git_file_history,
  {
    nargs = 0,
    desc = "Show git log for current file",
  }
)
vim.api.nvim_create_user_command(
  "GitDiffFileChanges",
  M.show_git_file_diff,
  {
    nargs = 0,
    desc = "Show git diff for current file",
  }
)
vim.api.nvim_create_user_command(
  "GitDiffFileByBranch",
  M.show_diff_by_branch,
  {
    nargs = 0,
    desc = "Show git diff for current file with another branch",
  }
)
return M
