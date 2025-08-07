local M = {}

local api = require("claude_plugin.api_python")
local chat_buf = nil
local chat_win = nil
local input_buf = nil
local input_win = nil

local chat_history = {}

function M.open(model)
  -- Create chat buffer and window (history)
  chat_buf = vim.api.nvim_create_buf(false, true)
  local width = 60
  local height = 15
  local chat_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = 2,
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  }
  chat_win = vim.api.nvim_open_win(chat_buf, false, chat_opts)
  vim.api.nvim_buf_set_option(chat_buf, "modifiable", false)

  -- Create input buffer and window (for typing)
  input_buf = vim.api.nvim_create_buf(false, true)
  local input_opts = {
    relative = "editor",
    width = width,
    height = 3,
    row = chat_opts.row + height,
    col = chat_opts.col,
    style = "minimal",
    border = "rounded",
  }
  input_win = vim.api.nvim_open_win(input_buf, true, input_opts)
  vim.api.nvim_buf_set_option(input_buf, "modifiable", true)
  vim.api.nvim_buf_set_option(input_buf, "buftype", "prompt") -- nicer prompt

  -- Set prompt text
  vim.fn.prompt_setprompt(input_buf, "> ")

  -- Keymap: submit input on Enter in insert mode
  vim.api.nvim_buf_set_keymap(
    input_buf,
    "i",
    "<CR>",
    [[<Cmd>lua require('claude_plugin.chat_window').submit()<CR>]],
    { noremap = true, silent = true }
  )

  -- Keymaps: close windows on 'q' or 'Esc' in normal mode
  local close_cmd = "<cmd>close<CR><cmd>close<CR>"
  vim.api.nvim_buf_set_keymap(chat_buf, "n", "q", close_cmd, { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(input_buf, "n", "q", close_cmd, { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(chat_buf, "n", "<Esc>", close_cmd, { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(input_buf, "n", "<Esc>", close_cmd, { noremap = true, silent = true })

  -- Initialize chat history with model info
  table.insert(chat_history, "AI Plugin Window - Model: " .. model)
  table.insert(chat_history, "")
  M.update_chat()
end

function M.update_chat()
  vim.api.nvim_buf_set_option(chat_buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(chat_buf, 0, -1, false, chat_history)
  vim.api.nvim_buf_set_option(chat_buf, "modifiable", false)
end

function M.submit()
  -- Get input text
  local lines = vim.api.nvim_buf_get_lines(input_buf, 0, -1, false)
  local input = table.concat(lines, "\n")

  if input ~= "" then
    -- Append user input to chat history
    table.insert(chat_history, "> " .. input)

    -- Clear input buffer for next input
    vim.api.nvim_buf_set_option(input_buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, {})
    vim.api.nvim_buf_set_option(input_buf, "modifiable", false)

    -- Send input to Python script asynchronously
    api.send_with_python(input, function(err, response)
      if err then
        table.insert(chat_history, "❌ Error: " .. err)
      else
        table.insert(chat_history, "🤖 " .. response)
      end

      -- Update chat window with new messages
      M.update_chat()
    end)
  end
end

return M
