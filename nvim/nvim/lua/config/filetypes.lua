vim.filetype.add({
  extension = {
    conf = "conf",
    jsonnet = "jsonnet",
    libsonnet = "jsonnet",
    log = "log",
    mutt = "muttrc",
    service = "systemd",
    zag = "zig",
    sc = "scala",
    scala = "scala",
    sbt = "scala",
    java = "java",
    ts = "typescript",
    tsx = "typescriptreact",
  },
  filename = {
    [".eslintrc"] = "json",
  },
  pattern = {
    [".*%.wiki"] = "markdown",
  },
})

-- Term filetype for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*",
  callback = function()
    vim.bo.filetype = "term"
  end,
})
