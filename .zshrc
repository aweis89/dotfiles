# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# auto install zinit
if [ ! -d $HOME/.zinit ]; then
  mkdir $HOME/.zinit
  git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
fi

source ~/.zinit/bin/zinit.zsh
# source ~/zinit.zsh

autoload -Uz compinit
compinit

# Load the pure theme, with zsh-async library that's bundled with it.
zinit ice pick"async.zsh" src"pure.zsh"
zinit light sindresorhus/pure

# Load git functions
zinit ice src"plugins/git/git.plugin.zsh"
zinit light ohmyzsh/ohmyzsh

## A glance at the new for-syntax – load all of the above
## plugins with a single command. For more information see:
## https://zdharma-continuum.github.io/zinit/wiki/For-Syntax/
zinit for \
    light-mode  zsh-users/zsh-autosuggestions \
    light-mode  zdharma-continuum/fast-syntax-highlighting \
                zdharma-continuum/history-search-multi-word \
		agkozak/zsh-z \
    light-mode pick"async.zsh" src"pure.zsh" \
                sindresorhus/pure

# Binary release in archive, from GitHub-releases page.
# After automatic unpacking it provides program "fzf".
zinit ice from"gh-r" as"program"
zinit light junegunn/fzf

zinit ice from"gh-r" as"program"
zinit light ahmetb/kubectx

# Scripts that are built at install (there's single default make target, "install",
# and it constructs scripts by `cat'ing a few files). The make'' ice could also be:
# `make"install PREFIX=$ZPFX"`, if "install" wouldn't be the only, default target.
zinit ice as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zinit light tj/git-extras

zinit wait lucid for \
      OMZ::plugins/common-aliases \
      OMZ::plugins/alias-finder \
      OMZ::plugins/copydir \
      OMZ::plugins/cp \
      OMZ::plugins/encode64 \
      OMZ::plugins/extract \
      OMZ::plugins/git \
      if"[[ $+commands[go] ]]" OMZ::plugins/golang \
      if"[[ $+commands[npm] ]]" OMZ::plugins/npm \
      if"[[ $+commands[sudo] ]]" OMZ::plugins/sudo \
      if"[[ $+commands[systemd] ]]" OMZ::plugins/systemd \
      OMZ::plugins/urltools

# Handle completions without loading any plugin, see "clist" command.
# This one is to be ran just once, in interactive session.
# zinit creinstall %HOME/my_completions

# custom local config
source $HOME/myzshrc.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="/usr/local/opt/llvm/bin:$PATH"
