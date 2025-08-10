local M = {}

function M.send_with_python(input, callback)
  --local current_file = vim.api.nvim_buf_get_name(0)
  --local current_dir = vim.fn.fnamemodify(current_file, ":h")
  --

  local chat_win_module = require("claude_plugin.chat_window")
  local current_file = chat_win_module.current_file or ""
  local current_dir = chat_win_module.current_dir or "."

  print("Current file: " .. current_file)
  print("Current dir: " .. current_dir)

  local cmd = {
    "python3",
    vim.fn.stdpath("config") .. "/lua/claude_plugin/chat_request.py",
    current_dir,
    current_file,
  }

  local output = {}
  local handle = vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    stdin = "pipe",

    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          table.insert(output, line)
        end
      end
    end,

    on_stderr = function(_, data)
      if data and data[1] ~= "" then
        table.insert(output, "❌ Error: " .. table.concat(data, "\n"))
      end
    end,

    on_exit = function(_, code)
      if code ~= 0 then
        callback("❌ Python script failed", nil)
      else
        callback(nil, table.concat(output, "\n"))
      end
    end,
  })

  -- Write to stdin of the Python script
  vim.fn.chansend(handle, input .. "\n")
  vim.fn.chanclose(handle, "stdin")
end

return M
