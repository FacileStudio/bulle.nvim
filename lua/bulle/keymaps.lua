local M = {}

local function jump(marks, direction, label)
  return function()
    if not marks.jump(0, direction) then
      vim.notify("bulle.nvim: no bulle edits in this buffer", vim.log.levels.INFO)
    end
  end
end

local function apply(map, lhs, rhs, desc)
  if vim.fn.maparg(lhs, "n") ~= "" then
    return
  end
  map(lhs, rhs, desc)
end

--- Install the plugin's default mappings, never replacing one that exists.
--- @param actions table handlers supplied by the caller
--- @return nil
function M.install(actions)
  local cfg = require("bulle.config").get()
  if not cfg.keymaps then
    return
  end

  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { desc = desc })
  end

  apply(map, "]r", jump(actions.marks, 1), "bulle: next edit")
  apply(map, "[r", jump(actions.marks, -1), "bulle: previous edit")
  apply(map, "<leader>ko", actions.toggle, "bulle: toggle chat pane")
  apply(map, "<leader>kc", actions.changes, "bulle: changes")
  apply(map, "<leader>kp", actions.peek, "bulle: peek last edit")
  apply(map, "<leader>kr", actions.revert, "bulle: revert the edit here")
  apply(map, "<leader>ks", actions.send, "bulle: send selection to bulle")
end

return M