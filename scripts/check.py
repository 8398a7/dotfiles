#!/usr/bin/env python3
"""Validate configuration syntax and run isolated behavior tests."""
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tomllib

ROOT = Path(__file__).resolve().parent.parent


def run(*args):
    subprocess.run(args, cwd=ROOT, check=True)


def main():
    for tool in ['bash', 'zsh', 'git', 'nvim', 'jq']:
        if not shutil.which(tool):
            raise SystemExit(f'{tool} が必要です (README の検証手順を参照)')
    bash_files = [*ROOT.glob('scripts/*.sh'), *ROOT.glob('git/bin/*')]
    for path in bash_files:
        run('bash', '-n', str(path))
    for path in [ROOT / 'herdr/bin/herdr-wt', ROOT / 'git/hooks/commit-msg', *ROOT.glob('.githooks/*')]:
        run('sh', '-n', str(path))
    for path in [ROOT / 'zsh/.zshrc', *ROOT.glob('zsh/functions/*.zsh')]:
        run('zsh', '-n', str(path))
    for path in [ROOT / 'mise.toml', ROOT / 'zsh/plugins.toml', ROOT / 'herdr/config.toml', ROOT / 'nvim/.stylua.toml']:
        tomllib.loads(path.read_text())
    for path in [ROOT / 'vscode/settings.json', ROOT / 'nvim/lazy-lock.json']:
        json.loads(path.read_text())
    # No plugin setup or writes to the real Neovim configuration.
    run('nvim', '--clean', '--headless', '-i', 'NONE',
        '+lua for _, p in ipairs(vim.fn.glob("nvim/**/*.lua", false, true)) do local f, e = loadfile(p); if not f then vim.api.nvim_err_writeln(e); vim.cmd.cquit() end end', '+qa')
    run(sys.executable, '-m', 'unittest', 'discover', '-s', 'tests', '-v')
    print('設定の構文と隔離環境の動作検証に成功しました')


if __name__ == '__main__':
    main()
