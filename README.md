# Alacritty + Zellij Config

Alacritty を起動すると Zellij が自動で開く構成です。
この repository は Nix / Home Manager / sudo なしで設定ファイルを配置できるようにしています。

This setup is derived from and modified after an Omakub setup. See
`NOTICE` for attribution.

## Files

```text
.config/alacritty/
  alacritty.toml
  btop.toml
  pane.toml
  shared.toml
  font.toml
  font-size.toml
  theme.toml

.config/zellij/
  config.kdl
  layouts/bottom-tabs.kdl
  themes/*.kdl
  plugins/zjstatus.wasm
```

## Requirements

- Alacritty
- Zellij
- CaskaydiaMono Nerd Font

設定の配置だけなら sudo は不要です。
ただし Alacritty / Zellij 本体を新規に入れる方法はデバイスの権限に依存します。

sudo なしで使いやすい選択肢:

- 既に `alacritty` と `zellij` が入っている環境で使う
- Nix が使える環境なら user profile に入れる
- Homebrew/Linuxbrew が使える環境なら user local に入れる
- Zellij は公式 release binary を `~/.local/bin` に置く

Zellij を user local に置く例:

```bash
mkdir -p ~/.local/bin
# Download the matching Linux binary from:
# https://github.com/zellij-org/zellij/releases
# Then place it as ~/.local/bin/zellij and make it executable.
chmod +x ~/.local/bin/zellij
```

`~/.local/bin` が `PATH` に入っていない場合:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Install Config

```bash
git clone git@github.com:AMkuro/alacritty-zellij-config.git
cd alacritty-zellij-config
./install.sh
```

`install.sh` は repository 内の `.config/alacritty` と `.config/zellij` を、`~/.config/` 配下へ directory symlink します。
既存 path がある場合は、上書き前に確認し、許可されたものだけ timestamp 付きで退避して symlink に置き換えます。

```text
~/.config/alacritty.bak.YYYYmmdd-HHMMSS
```

事前確認:

```bash
./install.sh --dry-run
```

## Font

この設定は `CaskaydiaMono Nerd Font` を指定しています。
sudo なしなら font file を user font directory に置きます。

```bash
mkdir -p ~/.local/share/fonts
# Put CaskaydiaMono Nerd Font .ttf files in ~/.local/share/fonts
fc-cache -fv
```

## Shell Setting

`~/.zshrc` などに追加します。

```bash
# Let terminal apps receive Ctrl+s.
stty -ixon
```

## Key Bindings

| Key | Action |
| --- | --- |
| `Alt p` | pane mode |
| `Alt t` | tab mode |
| `Alt s` | session mode |
| `Alt e` | scroll mode |
| `Alt r` | resize mode |
| `Alt m` | move mode |
| `Alt g` | locked mode |
| `Alt g` in locked mode | normal mode |

## License

MIT. See `LICENSE` and `NOTICE`.
