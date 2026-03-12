vim.g.mapleader = ' '

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.updatetime = 200
vim.opt.completeopt = 'menu,menuone,noselect'
vim.opt.signcolumn = 'yes'

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { 'nvim-lua/plenary.nvim' },
  { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = {
        'bash',
        'javascript',
        'json',
        'lua',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
      },
      highlight = { enable = true },
      indent = { enable = true },
      sync_install = true,
      auto_install = false,
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
  { 'neovim/nvim-lspconfig' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-cmdline' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-path' },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        completion = { autocomplete = false },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
        }),
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' },
          { name = 'cmdline' },
        }),
      })
    end,
  },
})

local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

if vim.fn.executable('typescript-language-server') == 1 then
  lspconfig.ts_ls.setup({
    capabilities = capabilities,
  })
end

if vim.fn.executable('pyright') == 1 then
  lspconfig.pyright.setup({
    capabilities = capabilities,
  })
end

local function dedupe(items)
  local seen, out = {}, {}
  for _, item in ipairs(items) do
    if item and item ~= '' and not seen[item] then
      seen[item] = true
      table.insert(out, item)
    end
  end
  table.sort(out)
  return out
end

local function buffer_symbols()
  local out = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    for word in line:gmatch('[A-Za-z_][A-Za-z0-9_]*') do
      table.insert(out, word)
    end
  end
  return dedupe(out)
end

local function flatten_document_symbols(symbols, out)
  for _, sym in ipairs(symbols or {}) do
    if sym.name then
      table.insert(out, sym.name)
    end
    if sym.children then
      flatten_document_symbols(sym.children, out)
    end
  end
end

local function lsp_symbols()
  local params = { textDocument = vim.lsp.util.make_text_document_params() }
  local results = vim.lsp.buf_request_sync(0, 'textDocument/documentSymbol', params, 300)
  if not results then
    return {}
  end

  local out = {}
  for _, res in pairs(results) do
    if type(res.result) == 'table' then
      flatten_document_symbols(res.result, out)
    end
  end
  return dedupe(out)
end

function _G.CodexVimPromptComplete(_, _, _)
  local items = lsp_symbols()
  if #items == 0 then
    items = buffer_symbols()
  end
  return items
end

local function current_file_context()
  local path = vim.api.nvim_buf_get_name(0)
  local ft = vim.bo.filetype
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  return {
    path = path ~= '' and path or '[No Name]',
    filetype = ft ~= '' and ft or 'text',
    text = table.concat(lines, '\n'),
  }
end

local function current_visual_selection()
  local mode = vim.fn.mode()
  if mode ~= 'v' and mode ~= 'V' and mode ~= '\22' then
    return nil
  end

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local srow, scol = start_pos[2], start_pos[3]
  local erow, ecol = end_pos[2], end_pos[3]

  if srow > erow or (srow == erow and scol > ecol) then
    srow, erow = erow, srow
    scol, ecol = ecol, scol
  end

  local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
  if #lines == 0 then
    return nil
  end

  if #lines == 1 then
    lines[1] = string.sub(lines[1], scol, ecol)
  else
    lines[1] = string.sub(lines[1], scol)
    lines[#lines] = string.sub(lines[#lines], 1, ecol)
  end

  return {
    start_line = srow,
    end_line = erow,
    text = table.concat(lines, '\n'),
  }
end

local function open_floating_window(title, initial_lines)
  local width = math.max(60, math.floor(vim.o.columns * 0.72))
  local height = math.max(8, math.floor(vim.o.lines * 0.35))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'markdown'
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, initial_lines or {})

  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    border = 'rounded',
    style = 'minimal',
    title = title,
    title_pos = 'center',
  })

  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
  return buf
end

local function set_popup_lines(buf, lines)
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end
end

local function extract_result(text)
  local trimmed = vim.trim(text or '')
  if trimmed == '' then
    return ''
  end

  local lines = {}
  for line in trimmed:gmatch('[^\r\n]+') do
    table.insert(lines, vim.trim(line))
  end

  return vim.trim(table.concat(lines, '\n'))
end

local function apply_generated_command(command)
  if not command or command == '' then
    vim.notify('No generated command to apply', vim.log.levels.WARN)
    return
  end

  if command:match('^EX:') then
    local ex = vim.trim(command:gsub('^EX:%s*', ''))
    if ex:sub(1, 1) == ':' then
      ex = ex:sub(2)
    end
    vim.cmd(ex)
    return
  end

  if command:match('^NORMAL:') then
    local keys = vim.trim(command:gsub('^NORMAL:%s*', ''))
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'n', false)
    return
  end

  if command:sub(1, 1) == ':' then
    vim.cmd(command:sub(2))
    return
  end

  vim.cmd(command)
end

local function run_codex_prompt(prompt, title)
  local buf = open_floating_window(title or 'Codex', {
    'Running Codex...',
    '',
    'Press q to close this window.',
  })

  local stdout_chunks = {}
  local stderr_chunks = {}

  local job = vim.system(
    { 'codex', 'exec', '--skip-git-repo-check', '--sandbox', 'read-only', '--model', os.getenv('MODEL') or 'gpt-5.4', prompt },
    {
      text = true,
      stdout = function(_, data)
        if data then
          table.insert(stdout_chunks, data)
          local current = table.concat(stdout_chunks)
          vim.schedule(function()
            local lines = vim.split(current, '\n', { plain = true, trimempty = false })
            if #lines == 0 then
              lines = { current }
            end
            set_popup_lines(buf, lines)
          end)
        end
      end,
      stderr = function(_, data)
        if data then
          table.insert(stderr_chunks, data)
        end
      end,
    },
    function(obj)
      local output = extract_result(table.concat(stdout_chunks))
      local err = vim.trim(table.concat(stderr_chunks))
      vim.schedule(function()
        if obj.code ~= 0 then
          set_popup_lines(buf, {
            'Codex failed.',
            '',
            err ~= '' and err or ('Exit code: ' .. tostring(obj.code)),
          })
          vim.notify(err ~= '' and err or 'Codex request failed', vim.log.levels.ERROR)
          return
        end

        vim.g.codex_last_vim_result = output
        vim.fn.setreg('"', output)
        vim.fn.setreg('+', output)

        set_popup_lines(buf, {
          output,
          '',
          'Copied to unnamed register and system clipboard.',
          'Use <leader>ar to apply it.',
          'Press q to close.',
        })
      end)
    end
  )

  if not job then
    vim.notify('Failed to start codex exec', vim.log.levels.ERROR)
  end
end

local function prompt_input(prompt_text)
  return vim.fn.input({
    prompt = prompt_text,
    completion = 'customlist,v:lua.CodexVimPromptComplete',
  })
end

local function ask_vim_cmd()
  local request = prompt_input('Ask for Vim command: ')
  if not request or vim.trim(request) == '' then
    return
  end

  local file = current_file_context()
  local prompt = table.concat({
    'You are generating a Vim/Neovim command for a programmer.',
    'Return exactly one result in one of these formats only:',
    'EX:<one Ex command>',
    'NORMAL:<one normal-mode key sequence>',
    'Prefer EX whenever possible.',
    'No prose. No markdown. No fences. No backticks.',
    '',
    'Current file path:',
    file.path,
    '',
    'Current filetype:',
    file.filetype,
    '',
    'Current file contents:',
    file.text,
    '',
    'User request:',
    request,
  }, '\n')

  run_codex_prompt(prompt, 'Codex → Vim command')
end

local function ask_vim_macro()
  local selection = current_visual_selection()
  if not selection then
    vim.notify('Make a visual selection first', vim.log.levels.WARN)
    return
  end

  local request = prompt_input('Transform selection with Vim: ')
  if not request or vim.trim(request) == '' then
    return
  end

  local file = current_file_context()
  local prompt = table.concat({
    'You are generating a Vim/Neovim command for a programmer.',
    'The command must target the current visual selection if using EX range commands.',
    'Return exactly one result in one of these formats only:',
    "EX:'<,'><one command after the range>",
    'NORMAL:<one normal-mode key sequence>',
    'Prefer an EX range command whenever possible.',
    'No prose. No markdown. No fences. No backticks.',
    '',
    'Current file path:',
    file.path,
    '',
    'Current filetype:',
    file.filetype,
    '',
    'Selected line range:',
    tostring(selection.start_line) .. '-' .. tostring(selection.end_line),
    '',
    'Selected text:',
    selection.text,
    '',
    'Full file contents:',
    file.text,
    '',
    'Requested transformation:',
    request,
  }, '\n')

  run_codex_prompt(prompt, 'Codex → Vim selection command')
end

vim.api.nvim_create_user_command('AskVimCmd', ask_vim_cmd, {})
vim.api.nvim_create_user_command('AskVimMacro', ask_vim_macro, {})

vim.keymap.set('n', '<leader>ac', ask_vim_cmd, { desc = 'Ask Codex for a Vim command' })
vim.keymap.set('x', '<leader>am', function()
  vim.cmd('normal! gv')
  ask_vim_macro()
end, { desc = 'Ask Codex for a selection command' })
vim.keymap.set('n', '<leader>ar', function()
  apply_generated_command(vim.g.codex_last_vim_result)
end, { desc = 'Apply last generated Vim command' })

vim.keymap.set('n', '<leader>ft', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Live grep' })
