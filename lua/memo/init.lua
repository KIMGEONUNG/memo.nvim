Memo = {}
local M = {}

local default_options = {
  type = "markdown",
}
for k, v in pairs(default_options) do M[k] = v end

M.setup = function(opts) for k, v in pairs(opts) do M[k] = v end end

-- make new file with name newfile.tex if file doesn't exist
local function make_new_file(path)
  local file = io.open(path, "w")
  file:close()
end

local function file_exists(file)
  local f = io.open(file, "r")
  if f then
    io.close(f)
    return true
  else
    return false
  end
end

local function gotomemo()
  local path = vim.fn.expand('%:p:h')
  local name = vim.fn.expand('%:p:t')
  local path_memo = path .. "/." .. name .. ".memo"

  -- Create a new floating window
  local width = vim.o.columns
  local height = vim.o.lines
  local ratio = 0.8
  local win_height = math.ceil(height * ratio - 4)
  local win_width = math.ceil(width * ratio - 4)

  -- Calculate window position
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2 - 1)

  local bufnr = vim.api.nvim_create_buf(false, true)
  local win_id = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    -- focusable = true,
    style = "minimal",
    border = 'rounded',
  })

  -- keymap

  function Memo.Out()
    vim.api.nvim_command("write")
    vim.api.nvim_win_close(win_id, true)
  end

  local opt = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, "n", "q", '<cmd>lua Memo.Out()<cr>', opt)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<ESC>", '<cmd>lua Memo.Out()<cr>', opt)

  -- Load the contents of File A into the buffer
  vim.api.nvim_buf_set_option(bufnr, "buftype", "")
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
  vim.api.nvim_buf_set_name(bufnr, path_memo)
  vim.api.nvim_command("edit " .. path_memo)
  vim.api.nvim_buf_set_option(bufnr, "filetype", M.type)

end

vim.api.nvim_create_user_command('Memo', function(args) gotomemo() end, {})

return M
