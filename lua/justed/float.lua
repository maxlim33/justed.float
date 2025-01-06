local JustedFloat = {}
local _H = {}

JustedFloat.setup = function(config)
  vim.validate({ config = { config, 'table', true } })
  config = vim.tbl_deep_extend('force', vim.deepcopy(JustedFloat.config), config or {})

  vim.validate({ match_normal_highlight = { config.match_normal_highlight, 'boolean' } })
  JustedFloat.config = config
  _H.apply_config(config)
  _H.create_user_commands()
end

-- Default values:
JustedFloat.config = {
  match_normal_highlight = true,
}

_H.state = {
  floating = {
    buf = -1,
    win = -1,
  }
}

_H.create_floating_window = function(opts)
  opts = opts or {}

  local screen_width = vim.o.columns
  local screen_height = vim.o.lines

  local width = opts.width or math.floor(screen_width * 0.8)
  local height = opts.height or math.floor(screen_height * 0.8)

  local row = math.floor((screen_height - height) / 2)
  local col = math.floor((screen_width - width) / 2)

  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true) -- false for listed, true for scratch
  end

  local win_opts = {
      relative = 'editor',
      width = width,
      height = height,
      row = row,
      col = col,
      style = 'minimal',
      border = 'rounded',
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)
  vim.api.nvim_win_set_option(win, 'winhighlight', 'NormalFloat:Normal')

  -- Set some buffer options
  -- vim.bo[buf].bufhidden = 'wipe' -- Automatically wipe the buffer when the window is closed

  return { buf = buf, win = win }
end

local toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = create_floating_window({ buf = state.floating.buf })
    if vim.bo[state.floating.buf].buftype ~= 'terminal' then
      vim.cmd.terminal()
    end
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

vim.api.nvim_create_user_command('JustedFloat', toggle_terminal, {})
