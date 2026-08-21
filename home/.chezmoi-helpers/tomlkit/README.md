# Vendored tomlkit

Vendored copy of [`tomlkit`][1] v0.15.0 (pure-Python, no runtime dependencies,
requires Python >=3.9). Used by `dot_codex/modify_private_config.toml` for
comment-preserving TOML round-tripping of `~/.codex/config.toml`.

Why vendored instead of `pip install`: the modify_ script runs under the
system `/usr/bin:/bin:/opt/homebrew/bin:/usr/local/bin` Python (see its
shebang — asdf shims were removed in `f476a8c` to avoid PATH issues), which
has no guaranteed site-packages access. Vendoring next to the script keeps
the dependency local and version-pinned.

Do not edit by hand. To upgrade:

    pip3 download tomlkit --no-deps -d /tmp/tk_dl
    rm .chezmoi-helpers/tomlkit/*.py
    unzip -j /tmp/tk_dl/tomlkit-*.whl 'tomlkit/*' -d .chezmoi-helpers/tomlkit
    PYTHONPATH=.chezmoi-helpers python3 -c 'import tomlkit; print(tomlkit.__version__)'

[1]: https://github.com/sdispater/tomlkit
