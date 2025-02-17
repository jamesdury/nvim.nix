{
  description = "Nix flake for nixvim with LSP, autocomplete, and Dracula theme";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim"; # Nixvim Flake
  };
  outputs = { self, nixpkgs, nixvim }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    # Allow `nix run .`
    apps.${system}.default = {
      type = "app";
      program = "${self.packages.${system}.default}/bin/nvim";
    };
    # The Neovim package with plugins
    packages.${system}.default = nixvim.legacyPackages.${system}.makeNixvim {
      extraConfigLua = ''
        vim.o.number = true
        vim.o.relativenumber = false
        vim.o.expandtab = true
        vim.o.shiftwidth = 2
        vim.o.tabstop = 2
        vim.opt.clipboard = "unnamedplus"  -- Use system clipboard
        vim.cmd.colorscheme("dracula")

        -- Set leader key to space
        vim.g.mapleader = " "

        -- Format on save
        vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]
        
        -- LSP hover documentation
        vim.o.updatetime = 100
        vim.o.signcolumn = "yes"
        
        -- Auto show diagnostic on hover
        vim.diagnostic.config({
          virtual_text = true,
          signs = true,
          underline = true,
          update_in_insert = false,
          severity_sort = false,
          float = {
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
          },
        })
        
        -- Show hover automatically
        vim.o.mousemoveevent = true
        vim.cmd [[
          autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
        ]]
        vim.api.nvim_set_keymap('n', 'K', ':lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', 'gd', ':lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', 'gr', ':lua vim.lsp.buf.references()<CR>', { noremap = true, silent = true })

        -- Telescope keymaps
        vim.api.nvim_set_keymap('n', '<Leader>ff', ':Telescope find_files<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<Leader>fg', ':Telescope live_grep<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<Leader>fb', ':Telescope buffers<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<Leader>fh', ':Telescope help_tags<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<Leader>fr', ':Telescope oldfiles<CR>', { noremap = true, silent = true })

        -- Gitsigns keymaps
        vim.api.nvim_set_keymap('n', '<Leader>gs', ':Gitsigns status<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<Leader>gp', ':Gitsigns preview_hunk<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<Leader>gn', ':Gitsigns next_hunk<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<Leader>gp', ':Gitsigns previous_hunk<CR>', { noremap = true, silent = true })

        -- CodeLens keymap
        vim.api.nvim_set_keymap('n', '<Leader>c d', ':lua vim.lsp.codelens.run()<CR>', { noremap = true, silent = true })
      '';

      colorschemes.dracula.enable = true;

      plugins = {
        # LSP Support
        lsp = {
          enable = true;
          servers = {
            tsserver.enable = true;
            html.enable = true;
            cssls.enable = true;
            biome.enable = true;
            terraformls.enable = true;
          };
        };

        # Treesitter for better syntax highlighting
        treesitter = {
          enable = true;
          ensureInstalled = [ "typescript" "javascript" "html" "css" ];
        };

        # Enhanced autocompletion configuration
        cmp = {
          enable = true;
          settings = {
            mapping = {
              preset = "insert";
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-e>" = "cmp.mapping.close()";
              "<C-j>" = "cmp.mapping.select_next_item()";
              "<C-k>" = "cmp.mapping.select_prev_item()";
              "<CR>" = "cmp.mapping.confirm({ select = true })";
              "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
              "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            };
            sources = [
              { name = "nvim_lsp"; }
              { name = "buffer"; }
              { name = "path"; }
            ];
          };
        };

        telescope.enable = true;
        gitsigns.enable = true;
      };
    };
  };
}
