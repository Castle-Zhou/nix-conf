return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    -- Mason：用于安装 LSP 服务器、DAP、Linter 等
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "clangd",
        "lua_ls",
        "vtsls",
        "pyright",
        "rust_analyzer",
        "jsonls",
        "yamlls",
      },
      automatic_installation = true,
      -- automatic_enable 默认开启，会自动对所有已安装的 LSP server 调用 vim.lsp.enable()
    })

    -- 基于 Neovim 0.11+ 的 vim.lsp.config API
    -- 全局 on_attach / capabilities 会应用于所有 LSP 服务器
    vim.lsp.config["*"] = {
      on_attach = function(client, bufnr)
        local buf = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("keep", { desc = "Go to Definition" }, buf))
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("keep", { desc = "Go to Implementation" }, buf))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("keep", { desc = "Hover Documentation" }, buf))
        vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("keep", { desc = "Find References" }, buf))
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("keep", { desc = "Prev Diagnostic" }, buf))
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("keep", { desc = "Next Diagnostic" }, buf))
        vim.keymap.set("n", "<Leader>cr", vim.lsp.buf.rename, vim.tbl_extend("keep", { desc = "Rename" }, buf))
        vim.keymap.set("n", "<Leader>cf", vim.lsp.buf.format, vim.tbl_extend("keep", { desc = "Format" }, buf))
        vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("keep", { desc = "Code Action" }, buf))
        vim.keymap.set("n", "<Leader>d", vim.diagnostic.open_float, vim.tbl_extend("keep", { desc = "Open Diagnostic" }, buf))
      end,
      capabilities = (function()
        local caps = vim.lsp.protocol.make_client_capabilities()
        local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
        if ok then
          caps = cmp_lsp.default_capabilities(caps)
        end
        return caps
      end)(),
    }

  end,
}
