# EasyWork(自用)

快速配置个人工作环境，提高开发效率的各种Shell脚本及使用技巧

## Usage

终端下运行下面命令：

```bash
eval "$(curl -sL https://raw.githubusercontent.com/wangzhizhou/EasyWork/master/scripts/shell-config)"
```

之后，重新打开终端后，可以使用快捷指令：
- `cgit`配置git
- `cvim`配置vim
- `cshell`重置shell

## Shell 配置与功能

一键配置 Shell，统一注入个性化配置：[scripts/shell-config](file:///Users/bytedance/Documents/EasyWork/scripts/shell-config)

使用方式：
- 推荐从终端直接执行：
  ```bash
  eval "$(curl -sL https://raw.githubusercontent.com/wangzhizhou/EasyWork/master/scripts/shell-config)"
  ```
- 或在本仓库中执行脚本：
  ```bash
  bash scripts/shell-config
  ```

脚本做了什么：
- 自动检测系统与 Shell 类型，并选择合适的原始配置文件：
  - macOS: zsh → ~/.zshrc；bash → ~/.bash_profile
  - Linux: ~/.bashrc
- 若是 macOS + zsh，且未安装 Oh My Zsh，则自动安装（不替换现有 ~/.zshrc；不自动切换 Shell 会话）
- 确保原始 rc 文件存在，并在末尾追加：
  - source ~/.sh_config_custom
- 生成自定义配置文件 ~/.sh_config_custom，主要包含：
  - 语言环境：LC_ALL/LANG = en_US.UTF-8
  - 粘贴优化：bash 下启用 bracketed-paste
  - 多行提示符：ASCII 兔子 + 仓库/分支提示（zsh 使用 PROMPT，bash 使用 PS1）
  - 常用别名：grep 着色、mv/cp/rm 交互式、g=git、ffmpeg 系列、spm=swift package、q=exit
  - 常用函数：run N 次执行任意命令（示例：run 10 echo hi）
  - 快捷更新：cshell/cgit/cvim 可从远程拉取最新配置并应用
- 执行结束后会立即加载当前会话配置，并提示重开终端以完全生效

常用提示：
- Git 分支提示：会在提示符下方显示 “[目录名: 当前分支 → 上游]”
- 切换/还原：
  - 要禁用：编辑你的 ~/.zshrc 或 ~/.bashrc/ ~/.bash_profile，删除 source ~/.sh_config_custom 这一行，并可删除 ~/.sh_config_custom
  - 要自定义：直接编辑 ~/.sh_config_custom，保存后重开终端或 source 你的 rc 文件

注意：
- 脚本包含从远程加载配置的快捷命令，方便但存在供应链风险。生产环境下建议固定版本或自行审阅脚本内容。

## Git 配置与别名

交互式配置 Git，支持全局或当前仓库，并注入常用别名：[scripts/git-config](file:///Users/bytedance/Documents/EasyWork/scripts/git-config)

使用方式：
- 推荐通过快捷命令：
  ```bash
  cgit
  ```
- 或直接运行脚本：
  ```bash
  bash scripts/git-config
  ```

配置流程概览：
- 检查 Git 是否安装（未安装会直接退出）
- 选择配置范围：
  - 全局（~/.gitconfig）
  - 本地（当前仓库 .git/config）
- 确认/修改用户名与邮箱：
  - 使用当前已配置值
  - 在 “personal/work/custom” 三种选项间选择或自定义
- 确认无误后写入配置，并输出最终配置以便核对

注入的实用别名（节选）：
- 配置查看：cfg（全局）、cfl（本地）、cfs（系统）、cfw（worktree）
- 日志视图：l、la、lm、lma、lg、lgs、lgt、lgb、lgr、lgtg
- 分支：b、br、bv、bd/bD、bu、pl、plrs、po/poh/pof/pofs/poa/pot
- 提交/添加：a、c、ca、cm
- 切换/新分支：co、cb
- 克隆/清理：cl、clrs、cdf
- Cherry-pick：pk、pkc、pka
- 合并：m、mc、ma
- 状态：s、ss
- 暂存：st、sl、sp
- 标签：t、tl、td
- 子模块：sm、smi、smu、sms、smur、smuir
- 远端：r、rv、rpo
- 还原/重置：re、rst、rsth
- Rebase：rb、rbc、rba、rbi、rbir
- Worktree：wt、wta、wtl、wtr、wtm、wtp
- Patch：fp、fp1、ap
- 其他：h（全局配置列表）、sh（快速查看 HEAD 提交）

常用操作示例：
- 查看漂亮日志：git l 或 git la（包含图形/作者/装饰）
- 从远程提交：git pl（pull），git po（push origin 当前分支）
- 以 rebase 方式拉取：git plrb
- 快速创建并切换到新分支：git cb feature/xyz
- 快速恢复到 HEAD：git rsth

查看与回滚：
- 查看当前配置：
  - 全局：git config --global --list
  - 本地：git config --local --list
- 回滚别名（如需精简）：编辑 ~/.gitconfig 的 [alias] 段落，手动移除不需要的条目

## Vim 配置与插件

运行一次 Vim 配置脚本完成初始化与插件安装：

```bash
bash [scripts/vim-config](file:///Users/bytedance/Documents/EasyWork/scripts/vim-config)
```

脚本会自动：
- 检查并安装 Node.js（用于 coc.nvim、Markdown 预览）
- 检查并安装 ripgrep（提供 :Rg 内容搜索支持）
- 备份现有 ~/.vimrc 并生成新配置，随后执行插件安装

常用插件与用法速览：
- 插件管理（vim-plug）
  - :PlugInstall 安装插件；:PlugUpdate 更新；:PlugClean 清理未使用
- 文件树（NERDTree）
  - Ctrl-n 打开/关闭文件树；树中按 ? 查看快捷键；:NERDTreeFind 定位当前文件
- 状态栏（vim-airline）
  - 主题为 papercolor，自动启用
- Git（vim-fugitive + vim-gitgutter）
  - :G、:Gstatus、:Gdiffsplit 基本操作；[c / ]c 跳转到上一/下一处变更
- 注释（vim-commentary）
  - gcc 注释/取消注释当前行；gc{motion} 注释选定范围
- Markdown（vim-markdown + markdown-preview.nvim）
  - 空格 mp 启动预览；空格 ms 停止；空格 mt 切换
  - 若预览未启动，可执行 :call mkdp#util#install()
- HTML/CSS/Emmet（emmet-vim、html5.vim、vim-css3-syntax）
  - Emmet 常用快捷：Ctrl-y , 展开缩写（例如 ul>li*3）
- 搜索（fzf + fzf.vim）
  - :Files 文件搜索；:Rg 文本搜索（依赖 ripgrep）
- 代码检查/修复（ALE）
  - 保存自动修复（已启用）；Ctrl-j/ Ctrl-k 在问题间跳转
  - 需在项目中提供 eslint/stylelint 等工具配置
- 补全（coc.nvim）
  - gd 跳转定义、gr 引用、gi 实现、K 悬停文档
  - 推荐安装扩展：:CocInstall -sync coc-tsserver coc-json coc-eslint coc-prettier coc-css coc-html coc-snippets | :CocUpdate

故障排查：
- 若启动 Vim 出现与 YouCompleteMe 相关的 Python 错误（E887），请重新执行脚本或手动执行：
  - rm -rf ~/.vim/plugged/YouCompleteMe && vim +PlugClean\! +qall && vim +PlugInstall +qall
