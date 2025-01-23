local map = require 'utils.map'

vim.g.mapleader = ' '

local api = require 'nvim-tree.api'

---------------------------------------
----- Create New File Properly --------
---------------------------------------

-- Define a function to create a new file at filetree caret position, prompt for name, and expand file tree
vim.keymap.set('n', '<leader>n', function()
  -- Get the current node under the cursor in NvimTree
  local current_node = api.tree.get_node_under_cursor()
  local target_directory = nil

  -- Determine the target directory for the new file
  if current_node and current_node.type == 'directory' then
    -- If the current node is a directory, use its path
    target_directory = current_node.absolute_path
  elseif current_node and current_node.absolute_path then
    -- If the current node is a file, use its parent directory
    target_directory = vim.fn.fnamemodify(current_node.absolute_path, ':h')
  else
    -- Default to the current working directory
    target_directory = vim.fn.getcwd()
  end

  -- Prompt the user to enter a new file name
  vim.ui.input({
    prompt = 'Enter new file name: ', -- Input prompt text
    relative = 'editor', -- Center input box relative to the editor
    width = 40, -- Width of the input box
    height = 1, -- Height of the input box
    row = math.floor((vim.o.lines - 2) * 0.5), -- Center vertically
    col = math.floor((vim.o.columns - 40) * 0.5), -- Center horizontally
  }, function(file_name)
    -- Proceed only if the user provides a valid file name
    if file_name and #file_name > 0 then
      local new_file_path = target_directory .. '/' .. file_name

      -- Open a new buffer for the file and save it to disk
      vim.cmd('edit ' .. new_file_path)
      vim.cmd 'write'

      -- If NvimTree is active, refresh and highlight the new file
      if api.tree.is_visible() then
        api.tree.find_file(new_file_path) -- Highlight the new file
        vim.cmd 'NvimTreeRefresh' -- Refresh NvimTree to reflect changes
      else
        -- Notify the user if NvimTree is not active
        print 'Error: NvimTree is not active'
      end

      -- Notify the user that the file was created successfully
      print('File created: ' .. new_file_path)
    else
      -- Notify the user if no file name was provided
      print 'No file name provided.'
    end
  end)
end, { desc = 'Prompt to create a new file in NvimTree under caret and refresh directory' })

---------------------------------------
----- Close a File Properly --------
---------------------------------------

vim.keymap.set('n', 'Q', function()
  -- Check if the current buffer has unsaved changes
  local buffer_is_modified = vim.bo.modified

  -- Handle unsaved changes
  if buffer_is_modified then
    -- Prompt the user with options to save, discard, or cancel
    local save_changes_message = 'Save changes before closing?'
    local save_changes_options = '&Yes\n&No\n&Cancel'
    local default_choice_is_yes = 1

    local user_choice = vim.fn.confirm(save_changes_message, save_changes_options, default_choice_is_yes)

    local SAVE_CHOICE = 1
    local CANCEL_CHOICE = 3

    if user_choice == SAVE_CHOICE then
      local save_buffer_command = 'write'
      vim.cmd(save_buffer_command) -- Save the current buffer
    elseif user_choice == CANCEL_CHOICE then
      return -- Exit the function if the user cancels
    end
  end

  -- Determine the appropriate close command based on buffer state
  local buffer_close_command = buffer_is_modified and 'bdelete!' or 'bdelete'
  vim.cmd(buffer_close_command) -- Close the buffer

  -- Retrieve all currently listed buffers
  local query_for_listed_buffers = { buflisted = 1 }
  local listed_buffers = vim.fn.getbufinfo(query_for_listed_buffers)

  -- Debug output: Show all listed buffers after deletion
  local debug_message_for_listed_buffers = 'Listed Buffers After Deletion:'
  print(debug_message_for_listed_buffers, vim.inspect(listed_buffers))

  -- Filter for valid buffers (must have a name and be listed)
  local buffer_is_valid = function(buffer)
    local buffer_has_name = buffer.name ~= ''
    local buffer_is_listed = buffer.listed == 1
    return buffer_has_name and buffer_is_listed
  end

  local valid_buffers = vim.tbl_filter(buffer_is_valid, listed_buffers)

  -- Debug output: Show valid buffers after filtering
  local debug_message_for_valid_buffers = 'Valid Buffers:'
  print(debug_message_for_valid_buffers, vim.inspect(valid_buffers))

  -- Check if there are no valid buffers remaining
  local no_valid_buffers_remain = #valid_buffers == 0

  if no_valid_buffers_remain then
    -- Notify the user and open NvimTree if no buffers remain
    local no_buffers_remaining_message = 'No valid buffers left. Opening NvimTree.'
    vim.notify(no_buffers_remaining_message, vim.log.levels.INFO)

    local nvim_tree_command_is_available = vim.fn.exists ':NvimTreeOpen' == 2

    if nvim_tree_command_is_available then
      local open_nvim_tree_command = 'NvimTreeOpen'
      vim.cmd(open_nvim_tree_command) -- Open NvimTree
    else
      -- Notify the user if NvimTree is not available
      local nvim_tree_not_found_message = 'NvimTree is not installed or unavailable.'
      vim.notify(nvim_tree_not_found_message, vim.log.levels.WARN)
    end
  end
end, { desc = 'Save and close file, open file tree if last buffer' })

--------------------------------------------
----- Create New Directory Properly --------
--------------------------------------------

vim.keymap.set('n', '<leader>nd', function()
  -- Get the current node under the cursor in NvimTree
  local current_node = api.tree.get_node_under_cursor()

  -- Define conditions for determining the target directory
  local current_node_is_directory = current_node and current_node.type == 'directory'
  local current_node_is_file = current_node and current_node.absolute_path and not current_node_is_directory
  local no_current_node = not current_node

  -- Determine the target directory path
  local target_directory_path
  if current_node_is_directory then
    -- Use the path of the directory node
    target_directory_path = current_node.absolute_path
  elseif current_node_is_file then
    -- Use the parent directory of a file node
    target_directory_path = vim.fn.fnamemodify(current_node.absolute_path, ':h')
  elseif no_current_node then
    -- Fallback to the current working directory
    target_directory_path = vim.fn.getcwd()
  end

  -- Prompt the user to enter the name of the new sub-directory
  vim.ui.input({
    prompt = 'Enter new sub-directory name: ', -- Text shown in the input prompt
    relative = 'editor', -- Place relative to the editor window
    width = 40, -- Width of the input box
    height = 1, -- Height of the input box
    row = math.floor((vim.o.lines - 2) * 0.5), -- Center vertically
    col = math.floor((vim.o.columns - 40) * 0.5), -- Center horizontally
  }, function(sub_directory_name)
    -- Ensure the user provided a valid sub-directory name
    local sub_directory_name_is_valid = sub_directory_name and #sub_directory_name > 0

    if sub_directory_name_is_valid then
      local new_directory_path = target_directory_path .. '/' .. sub_directory_name

      -- Check if the directory already exists
      local directory_already_exists = vim.fn.isdirectory(new_directory_path) == 1
      if directory_already_exists then
        -- Inform the user that the directory already exists
        local exists_message = 'You know "' .. sub_directory_name .. '" exists in this directory, right?'
        vim.notify(exists_message, vim.log.levels.WARN)
        return
      end

      -- Attempt to create the new sub-directory
      local creation_successful, creation_error = pcall(function()
        vim.fn.mkdir(new_directory_path, 'p') -- 'p' ensures parent directories are created if needed
      end)

      if creation_successful then
        print('Directory created: ' .. new_directory_path)

        -- Refresh and focus the new directory in NvimTree if it is visible
        local nvim_tree_is_visible = api.tree.is_visible()
        if nvim_tree_is_visible then
          api.tree.find_file(new_directory_path) -- Highlight the new directory
          vim.cmd 'NvimTreeRefresh' -- Refresh NvimTree to show the changes
        else
          print 'Note: NvimTree is not active'
        end
      else
        -- Handle errors during directory creation
        local error_message = creation_error or 'Unknown error'
        print('Error creating directory: ' .. error_message)
      end
    else
      -- Notify the user if no sub-directory name was provided
      print 'No directory name provided.'
    end
  end)
end, { desc = 'Prompt to create a new sub-directory in NvimTree under caret and refresh directory' })

-- Confirm save if trying to close file, open file tree if last buffer
vim.keymap.set('n', '<M-.>', '<Cmd>vertical resize -4<CR>', { noremap = true, silent = true }) -- Alt + ,
vim.keymap.set('n', '<M-,>', '<Cmd>vertical resize +4<CR>', { noremap = true, silent = true }) -- Alt + .

vim.keymap.set('n', '<M-->', '<Cmd>resize -2<CR>', { noremap = true, silent = true, desc = 'Shrink window vertically' })
vim.keymap.set('n', '<M-=>', '<Cmd>resize +2<CR>', { noremap = true, silent = true, desc = 'Expand window vertically' })

map({ 'n', 'i' }, '<C-A-o>', ':only<cr>', { desc = 'Pane becomes the only one', silent = true })
map({ 'n', 'i' }, '<C-A-w>', ':close<cr>', { desc = 'Pane Close', silent = true })
