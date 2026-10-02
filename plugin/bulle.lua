if vim.g.loaded_bulle_nvim == 1 then
  return
end
vim.g.loaded_bulle_nvim = 1

if vim.g.bulle_nvim_no_defaults then
  return
end

local ok, bulle = pcall(require, "bulle")
if not ok then
  vim.notify("bulle.nvim: " .. tostring(bulle), vim.log.levels.ERROR)
  return
end

bulle.setup()

local function warn(msg)
  vim.notify("bulle.nvim: " .. msg, vim.log.levels.WARN)
end

vim.api.nvim_create_user_command("KoriToggle", function()
  bulle.toggle()
end, { desc = "bulle: toggle the chat pane" })

vim.api.nvim_create_user_command("KoriStart", function(args)
  local argv = vim.split(args.args, "%s+", { trim = true })
  bulle.start(#argv > 0 and argv or nil)
end, { nargs = "*", desc = "bulle: open the chat pane, optionally with another command" })

vim.api.nvim_create_user_command("KoriChanges", function()
  bulle.changes()
end, { desc = "bulle: files and hunks bulle changed" })

vim.api.nvim_create_user_command("KoriPeek", function()
  require("bulle.ui").peek(
    require("bulle.context").path(),
    (require("bulle.marks").of(require("bulle.context").path()) or { ranges = {} }).ranges
  )
end, { desc = "bulle: peek the last edit in this buffer" })

vim.api.nvim_create_user_command("KoriRevert", function()
  local done, reason = bulle.revert()
  if not done then
    warn(tostring(reason))
  end
end, { desc = "bulle: revert the bulle edit under the cursor" })

vim.api.nvim_create_user_command("KoriRevertAll", function()
  local path = require("bulle.context").path()
  if path == "" then
    warn("this buffer has no file to revert")
    return
  end
  local count, reason = require("bulle.revert").all(path)
  if count == 0 then
    warn(tostring(reason))
    return
  end
  vim.notify(("bulle.nvim: reverted %d hunk(s)"):format(count), vim.log.levels.INFO)
end, { desc = "bulle: revert every bulle edit in this file" })

vim.api.nvim_create_user_command("KoriSend", function(args)
  bulle.send(args.args ~= "" and args.args or nil, false)
end, { nargs = "?", desc = "bulle: send the selection and context to the session" })

vim.api.nvim_create_user_command("KoriAsk", function(args)
  bulle.send(args.args ~= "" and args.args or nil, true)
end, { nargs = "?", desc = "bulle: send this buffer and context to the session" })

vim.api.nvim_create_user_command("KoriOpen", function()
  bulle.open()
end, { desc = "bulle: ask the session to scroll its view to this line" })

vim.api.nvim_create_user_command("KoriCancel", function()
  bulle.cancel()
end, { desc = "bulle: cancel the run in progress" })

vim.api.nvim_create_user_command("KoriAttach", function()
  bulle.attach()
end, { desc = "bulle: attach to a bulle session over the IDE socket" })

vim.api.nvim_create_user_command("KoriDetach", function()
  bulle.detach()
end, { desc = "bulle: stop reconnecting and drop the IDE socket" })

vim.api.nvim_create_user_command("KoriStatus", function()
  local state = bulle._runtime()
  local session = state.session
  local tool = state.tool and ("%s/%s"):format(state.tool.name or "?", state.tool.status or "?") or "-"
  print(("bulle.nvim: pane=%s session=%s root=%s turn=%s tool=%s"):format(
    bulle.is_open() and "open" or "closed",
    bulle.connected() and "attached" or "detached",
    session and (session.root or "") or "none",
    state.turn and tostring(state.turn) or "-",
    tool
  ))
end, { desc = "bulle: report the pane, the session and the root" })

vim.api.nvim_create_user_command("KoriClear", function()
  bulle.clear()
end, { desc = "bulle: forget every recorded edit" })

vim.api.nvim_create_user_command("KoriHealth", function()
  require("bulle.health").check()
end, { desc = "bulle: run the health check" })
