local uv = vim.uv or vim.loop
local state_file = vim.env.CODEX_NVIM_STATE_FILE
local initial_mode = vim.env.CODEX_NVIM_INITIAL_MODE or ""
local closing = false
local next_open_seq = 0

local function ensure_parent_dir(path)
  local parent = vim.fn.fnamemodify(path, ":h")
  if parent ~= nil and parent ~= "" then
    vim.fn.mkdir(parent, "p")
  end
end

local function absolute_path(path)
  return vim.fn.fnamemodify(path, ":p")
end

local function is_managed_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) or vim.fn.buflisted(buf) ~= 1 then
    return false
  end
  if vim.bo[buf].buftype ~= "" then
    return false
  end
  return vim.api.nvim_buf_get_name(buf) ~= ""
end

local function managed_buffers()
  local items = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_managed_buffer(buf) then
      items[#items + 1] = {
        buf = buf,
        changed = vim.bo[buf].modified and 1 or 0,
        name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p"),
        open_seq = vim.b[buf].codex_managed_open_seq or 0,
      }
    end
  end
  return items
end

local function listed_named_buffers()
  local items = managed_buffers()
  table.sort(items, function(a, b)
    return a.name < b.name
  end)
  return items
end

local function mark_buffer_opened(buf)
  if not is_managed_buffer(buf) then
    return
  end
  next_open_seq = next_open_seq + 1
  vim.b[buf].codex_managed_open_seq = next_open_seq
end

local function is_preview_buffer(buf)
  return is_managed_buffer(buf) and vim.b[buf].codex_managed_preview == 1
end

local function set_preview_buffer(buf, preview)
  if not is_managed_buffer(buf) then
    return
  end
  vim.b[buf].codex_managed_preview = preview and 1 or nil
end

local function listed_buffer_for_path(path)
  local buf = vim.fn.bufnr(path)
  if buf == -1 or not vim.api.nvim_buf_is_valid(buf) or vim.fn.buflisted(buf) ~= 1 then
    return nil
  end
  return buf
end

local function newest_other_buffer(current)
  local items = managed_buffers()
  table.sort(items, function(a, b)
    if a.open_seq == b.open_seq then
      return a.buf > b.buf
    end
    return a.open_seq > b.open_seq
  end)
  for _, item in ipairs(items) do
    if item.buf ~= current then
      return item
    end
  end
end

local function write_state()
  if not state_file or state_file == "" then
    return
  end

  local lines = {}
  for _, item in ipairs(listed_named_buffers()) do
    lines[#lines + 1] = string.format("%d\t%s", item.changed, item.name)
  end

  ensure_parent_dir(state_file)
  local tmp = string.format("%s.%d.tmp", state_file, vim.fn.getpid())
  vim.fn.writefile(lines, tmp)
  assert(uv.fs_rename(tmp, state_file))
end

local function only_empty_scratch()
  local current = vim.api.nvim_get_current_buf()
  if vim.fn.buflisted(current) ~= 1 then
    return false
  end
  if vim.api.nvim_buf_get_name(current) ~= "" then
    return false
  end
  if vim.bo[current].modified then
    return false
  end
  local lines = vim.api.nvim_buf_get_lines(current, 0, -1, false)
  return #lines == 1 and lines[1] == ""
end

local function maybe_quit()
  if closing then
    return
  end
  if #listed_named_buffers() > 0 then
    return
  end
  if not only_empty_scratch() then
    return
  end
  closing = true
  vim.schedule(function()
    pcall(vim.cmd, "qa")
  end)
end

local function refresh()
  write_state()
  maybe_quit()
end

local function managed_quit(force)
  local current = vim.api.nvim_get_current_buf()
  local target = newest_other_buffer(current)

  if not target then
    vim.cmd(force and "quit!" or "quit")
    return
  end

  if not force and vim.bo[current].modified then
    return
  end

  vim.cmd("buffer " .. target.buf)
  local ok, err = pcall(vim.api.nvim_buf_delete, current, { force = force })
  if not ok then
    pcall(vim.cmd, "buffer " .. current)
    error(err)
  end
  vim.schedule(refresh)
end

local function managed_write_quit(force, always_write)
  if always_write or vim.bo.modified then
    vim.cmd(force and "write!" or "write")
  end
  managed_quit(force)
end

function _G.CodexManagedOpen(path)
  local target_path = absolute_path(path)
  local previous = vim.api.nvim_get_current_buf()
  local previous_is_reusable_preview = is_preview_buffer(previous)
    and not vim.bo[previous].modified
    and absolute_path(vim.api.nvim_buf_get_name(previous)) ~= target_path

  vim.cmd("drop " .. vim.fn.fnameescape(target_path))

  local current = vim.api.nvim_get_current_buf()
  set_preview_buffer(current, false)
  mark_buffer_opened(current)

  if previous_is_reusable_preview and previous ~= current then
    pcall(vim.api.nvim_buf_delete, previous, { force = false })
  end

  vim.schedule(refresh)
  return 1
end

function _G.CodexManagedPreview(path)
  local target_path = absolute_path(path)
  local previous = vim.api.nvim_get_current_buf()
  local existing = listed_buffer_for_path(target_path)
  local existing_is_preview = existing ~= nil and is_preview_buffer(existing)
  local previous_is_reusable_preview = is_preview_buffer(previous)
    and not vim.bo[previous].modified
    and absolute_path(vim.api.nvim_buf_get_name(previous)) ~= target_path

  vim.cmd("drop " .. vim.fn.fnameescape(target_path))

  local current = vim.api.nvim_get_current_buf()
  if existing == nil or existing_is_preview then
    set_preview_buffer(current, true)
  end
  mark_buffer_opened(current)

  if previous_is_reusable_preview and previous ~= current then
    pcall(vim.api.nvim_buf_delete, previous, { force = false })
  end

  vim.schedule(refresh)
  return 1
end

vim.api.nvim_create_user_command("ManagedQuit", function(opts)
  managed_quit(opts.bang)
end, { bang = true })

vim.api.nvim_create_user_command("ManagedWriteQuit", function(opts)
  managed_write_quit(opts.bang, true)
end, { bang = true })

vim.api.nvim_create_user_command("ManagedExit", function(opts)
  managed_write_quit(opts.bang, false)
end, { bang = true })

local enter_rewrites = {
  q = "ManagedQuit",
  ["q!"] = "ManagedQuit!",
  quit = "ManagedQuit",
  ["quit!"] = "ManagedQuit!",
  wq = "ManagedWriteQuit",
  ["wq!"] = "ManagedWriteQuit!",
  x = "ManagedExit",
  ["x!"] = "ManagedExit!",
  xit = "ManagedExit",
  ["xit!"] = "ManagedExit!",
}

vim.keymap.set("c", "<CR>", function()
  if vim.fn.getcmdtype() ~= ":" then
    return "<CR>"
  end
  local rewrite = enter_rewrites[vim.fn.getcmdline()]
  if not rewrite then
    return "<CR>"
  end
  return "<C-U>" .. rewrite .. "<CR>"
end, { expr = true })

vim.keymap.set("n", "ZZ", "<Cmd>ManagedWriteQuit<CR>", { silent = true })
vim.keymap.set("n", "ZQ", "<Cmd>ManagedQuit!<CR>", { silent = true })

vim.api.nvim_create_autocmd({
  "BufAdd",
  "BufDelete",
  "BufEnter",
  "BufFilePost",
  "BufModifiedSet",
  "BufWritePost",
  "VimEnter",
}, {
  callback = function(args)
    if args.event == "VimEnter" then
      if initial_mode == "preview" then
        set_preview_buffer(vim.api.nvim_get_current_buf(), true)
      end
      mark_buffer_opened(vim.api.nvim_get_current_buf())
    end
    vim.schedule(refresh)
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    if state_file and state_file ~= "" then
      ensure_parent_dir(state_file)
      vim.fn.writefile({}, state_file)
    end
  end,
})

vim.schedule(refresh)
