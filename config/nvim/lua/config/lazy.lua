local uv = vim.uv or vim.loop
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup(require("plugins"), {
  defaults = {
    lazy = true,
  },
  install = {
    missing = true,
    colorscheme = { "tokyonight" },
  },
  checker = {
    enabled = false,
  },
  change_detection = {
    notify = false,
  },
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
})
