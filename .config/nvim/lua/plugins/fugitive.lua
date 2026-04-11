return {
  {
    "tpope/vim-fugitive",
    -- fugitive が定義する全コマンドを列挙する。漏れがあるとそのコマンドは
    -- 一度他の fugitive コマンドを実行するまで E492 になる。
    cmd = {
      "G", "Git", "Gcd", "Glcd", "Ge", "Gedit", "Gpedit",
      "Gr", "Gread", "Gw", "Gwrite", "Gwq",
      "Gdiffsplit", "Ghdiffsplit", "Gvdiffsplit",
      "Gclog", "GcLog", "Gllog", "GlLog",
      "Gmove", "GMove", "Grename", "GRename",
      "Gdelete", "GDelete", "Gremove", "GRemove", "GUnlink",
      "Gdrop", "Gbrowse", "GBrowse",
    },
  },
}
