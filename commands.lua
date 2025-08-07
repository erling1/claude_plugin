local M = {}

local chat_window = require("claude_plugin.chat_window")

function M.setup()
  vim.api.nvim_create_user_command("AiPlugin", function(args)
    print("AiPlugin command called with model:", args.args)
    local model = args.args
    require("claude_plugin.chat_window").open(model)
  end, { nargs = 1 })
end

return M
