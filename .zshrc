# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Download Znap, if it's not there yet.
[[ -f ~/Git/zsh-snap/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git ~/Git/zsh-snap

source ~/Git/zsh-snap/znap.zsh  # Start Znap

# `znap prompt` makes your prompt visible in just 15-40ms!
# znap prompt sindresorhus/pure

# `znap source` automatically downloads and starts your plugins.

ZSH_CACHE_DIR="~/.local/share/zsh/cache/" # used by ohmyzsh
ZSH=~/Git/ohmyzsh
znap source ohmyzsh/ohmyzsh \
	plugins/git lib/git \
	plugins/golang \
	plugins/rust \
	plugins/tmux \
	plugins/yarn \
	plugins/npm \
	plugins/pip \
	plugins/z

# znap source agkozak/zsh-z
znap source romkatv/powerlevel10k
znap source unixorn/fzf-zsh-plugin
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-syntax-highlighting
# `znap eval` caches and runs any kind of command output for you.
# znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'

deps=(
	~/.zshrc.local
	~/.zsh/keybindings.zsh
	~/.zsh/completion.zsh
	~/.zsh/history.zsh
	~/.zsh/alias.zsh
)

for i in "${deps[@]}"
do
	[[ ! -f "$i" ]] || source "$i"
done

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
