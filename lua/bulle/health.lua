local M = {}

local config = require("bulle.config")
local spool = require("bulle.spool")

function M.check()
  vim.health.start("bulle.nvim")

  if vim.fn.has("nvim-0.10") == 1 then
    vim.health.ok("Neovim " .. tostring(vim.version()))
  else
    vim.health.error("Neovim 0.10 or newer is required", { "Upgrade Neovim" })
  end

  if vim.fn.exists(":terminal") == 2 then
    vim.health.ok("`:terminal` is available for `:KoriStart`")
  end

  if vim.fn.executable("bulle") == 1 then
    vim.health.ok("bulle found at " .. vim.fn.exepath("bulle"))
  else
    vim.health.warn("bulle is not on $PATH", { "Install bulle: https://github.com/FacileStudio/bulle" })
  end

  if vim.fn.executable("bulle-nvim") == 1 then
    vim.health.ok("bulle-nvim shim found at " .. vim.fn.exepath("bulle-nvim"))
  else
    vim.health.error("bulle-nvim shim is not on $PATH", {
      "The shim is what bulle's hook runs to report edits.",
      "Add the repository's bin/ directory to $PATH, or symlink bin/bulle-nvim into ~/.local/bin.",
    })
  end

  local dir = spool.dir(config.get())
  if vim.fn.isdirectory(dir) == 1 then
    local perm = vim.fn.getfperm(dir)
    if perm:sub(4) == "------" then
      vim.health.ok("spool directory " .. dir .. " (" .. perm .. ")")
    else
      vim.health.warn("spool directory " .. dir .. " is " .. perm, {
        "The spool holds file content that bulle edited.",
        "It should be private to you: chmod 700 " .. dir,
      })
    end
  else
    vim.health.info("spool directory " .. dir .. " does not exist yet")
  end

  local hooks = vim.fn.expand("~/.bulle.yml")
  if vim.fn.filereadable(hooks) == 1 then
    local body = table.concat(vim.fn.readfile(hooks), "\n")
    if body:find("bulle.nvim", 1, true) or body:find("bulle%-nvim") then
      vim.health.ok("~/.bulle.yml mentions the bulle.nvim hook")
    else
      vim.health.warn("~/.bulle.yml has no bulle.nvim hook", {
        "Add the hooks block from the bulle.nvim README, or nothing will be reported.",
        "Hooks are trusted per project: bulle will ask before running one for the first time.",
      })
    end
    if body:find("before_tool_call", 1, true) then
      vim.health.ok("the before_tool_call hook is configured")
    else
      vim.health.warn("~/.bulle.yml has no before_tool_call hook", {
        "Without it, write_file and run_command on a file you never opened are",
        "reported with no line ranges and no marks.",
        "Add the second hooks entry from the README, with async: false.",
      })
    end
  else
    vim.health.info("no ~/.bulle.yml found")
  end
end

return M
