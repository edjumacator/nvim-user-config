vim.g.mapleader = ' '

-- Define a timeout for detecting double presses
vim.keymap.set('n', '<Space>', function()
  if vim.b.leader_double_press then
    -- Handle double press of Space (Global Leader)
    vim.b.leader_double_press = false
    vim.cmd "echo 'Double Space Leader Triggered!'"
  else
    -- Handle single press of Space
    vim.b.leader_double_press = true
    vim.defer_fn(function()
      vim.b.leader_double_press = false
    end, 300) -- Adjust timeout (300ms is reasonable)
  end
end, { desc = 'Double Space Leader Key' })

local api = require 'nvim-tree.api'

---------------------------------------
----- Create New File Properly --------
---------------------------------------

-- Define a function to create a new file at filetree caret position, prompt for name, and expand file tree

vim.keymap.set('n', '<C-n>', function()
  local node = api.tree.get_node_under_cursor()
  local directory_path = nil

  -- Determine the directory path based on the node
  if node and node.type == 'directory' then
    directory_path = node.absolute_path
  elseif node and node.absolute_path then
    directory_path = vim.fn.fnamemodify(node.absolute_path, ':h') -- Use parent directory
  else
    directory_path = vim.fn.getcwd() -- Fallback to current working directory
  end

  vim.ui.input({
    prompt = 'Enter new file name: ',
    relative = 'editor', -- Place relative to the entire editor window
    width = 40, -- Width of the input box
    height = 1, -- Height of the input box
    row = math.floor((vim.o.lines - 2) * 0.5), -- Center vertically
    col = math.floor((vim.o.columns - 40) * 0.5), -- Center horizontally
  }, function(input)
    if input and #input > 0 then
      local new_file_path = directory_path .. '/' .. input
      vim.cmd('edit ' .. new_file_path) -- Open the new buffer
      vim.cmd 'write' -- Write the file to disk

      -- Refresh and focus the new file in NvimTree
      if api.tree.is_visible() then
        api.tree.find_file(new_file_path) -- Highlight the new file
        vim.cmd 'NvimTreeRefresh' -- Refresh the tree to ensure changes are visible
      else
        print 'Error: NvimTree is not active'
      end

      print('File created: ' .. new_file_path)
    else
      print 'No file name provided.'
    end
  end)
end, { desc = 'Prompt to create a new file in NvimTree under caret and refresh directory' })

-- Confirm save if trying to close file, open file tree if last buffer

vim.keymap.set('n', 'Q', function()
  if vim.bo.modified then
    local choice = vim.fn.confirm('Save changes before closing?', '&Yes\n&No\n&Cancel', 1)
    if choice == 1 then
      vim.cmd 'write' -- Save changes
    elseif choice == 3 then
      return -- Cancel action
    end
  end

  -- Close the buffer
  vim.cmd 'bdelete'

  -- Check if there are any listed buffers left
  local listed_buffers = vim.fn.getbufinfo { buflisted = 1 }
  if #listed_buffers == 0 then
    -- Prevent `[No Name]` buffer from appearing
    vim.cmd 'NvimTreeOpen' -- Open the file tree
  end
end, { desc = 'Save and close file, open file tree if last buffer' })
