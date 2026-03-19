local map = vim.keymap.set

local function close_buffer()
  if vim.fn.exists(":ManagedQuit") == 2 then
    vim.cmd("ManagedQuit")
    return
  end
  vim.cmd("bdelete")
end

local function telescope_builtin(name, opts)
  return function()
    require("telescope.builtin")[name](opts or {})
  end
end

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true })

map("n", "<C-h>", "<C-w>h", { silent = true })
map("n", "<C-j>", "<C-w>j", { silent = true })
map("n", "<C-k>", "<C-w>k", { silent = true })
map("n", "<C-l>", "<C-w>l", { silent = true })

map("n", "<leader>w", "<cmd>write<CR>", { silent = true, desc = "Save buffer" })
map("n", "<leader>bd", close_buffer, { silent = true, desc = "Close buffer" })
map("n", "<leader>-", "<cmd>split<CR>", { silent = true, desc = "Split below" })
map("n", "<leader>|", "<cmd>vsplit<CR>", { silent = true, desc = "Split right" })

map("n", "<S-h>", "<cmd>bprevious<CR>", { silent = true, desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { silent = true, desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<CR>", { silent = true, desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<CR>", { silent = true, desc = "Next buffer" })

map("n", "<leader><leader>", telescope_builtin("buffers"), { desc = "Switch buffer" })
map("n", "<leader>ff", telescope_builtin("find_files", { hidden = true }), { desc = "Find files" })
map("n", "<leader>fg", telescope_builtin("live_grep"), { desc = "Live grep" })
map("n", "<leader>fb", telescope_builtin("buffers"), { desc = "Find buffers" })
map(
  "n",
  "<leader>/",
  function()
    require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
      previewer = false,
      winblend = 0,
    }))
  end,
  { desc = "Search in buffer" }
)

map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "J", "mzJ`z")

map("v", "<", "<gv")
map("v", ">", ">gv")
