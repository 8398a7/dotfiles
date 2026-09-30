#!/usr/bin/env python3
"""Install reversible links without deleting unrelated configuration."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import uuid

ROOT = Path(__file__).resolve().parent.parent


def exists(path):
    return path.exists() or path.is_symlink()


def points_to(path, target):
    return path.is_symlink() and path.resolve() == target.resolve()


def manifest(home, config, platform, state):
    code = (home / 'Library/Application Support/Code/User' if platform == 'darwin'
            else config / 'Code/User')
    return [
        (home / '.gitconfig', state / 'gitconfig'),
        (config / 'git/ignore', ROOT / 'git/ignore'),
        (config / 'git/bin', ROOT / 'git/bin'),
        (config / 'herdr/config.toml', ROOT / 'herdr/config.toml'),
        (config / 'herdr/bin', ROOT / 'herdr/bin'),
        (config / 'nvim', ROOT / 'nvim'),
        (config / 'sheldon/plugins.toml', ROOT / 'zsh/plugins.toml'),
        (config / 'mise/config.toml', ROOT / 'mise.toml'),
        (home / '.zsh', ROOT / 'zsh'),
        (home / '.zshrc', ROOT / 'zsh/.zshrc'),
        (home / '.ideavimrc', ROOT / 'idea/.ideavimrc'),
        (code / 'settings.json', ROOT / 'vscode/settings.json'),
    ]


def save(journal, entries):
    temporary = journal.with_suffix('.tmp')
    temporary.write_text(json.dumps(entries, ensure_ascii=False, indent=2) + '\n')
    temporary.replace(journal)


def backup_entry(dest, state):
    backup = state / ('backup-' + uuid.uuid4().hex) if exists(dest) else None
    return {'dest': str(dest), 'backup': str(backup) if backup else None}


def move_original(entry):
    if entry['backup']:
        Path(entry['dest']).rename(entry['backup'])
        print(f"backup: {entry['dest']} -> {entry['backup']}")


def retire_links(home):
    roots = {ROOT}
    result = subprocess.run(['git', '-C', str(ROOT), 'rev-parse', '--git-common-dir'],
                            capture_output=True, text=True)
    if result.returncode == 0:
        common = Path(result.stdout.strip())
        roots.add((ROOT / common).resolve().parent)
    for name, source in [('.vim', 'vim'), ('.vimrc', 'vim/.vimrc'),
                         ('.tmux', 'tmux'), ('.tmux.conf', 'tmux/.tmux.conf')]:
        dest = home / name
        if any(points_to(dest, root / source) for root in roots):
            dest.unlink()
            print(f'retired link: {dest}')


def install(home, config, state, journal, entries, platform):
    # Never install through someone else's directory symlink: that would mutate
    # its source (e.g. the former ~/.config/git -> dotfiles/git layout).
    for directory in [config, config / 'git', config / 'herdr', config / 'sheldon',
                      config / 'mise',
                      (home / 'Library/Application Support/Code/User'
                       if platform == 'darwin' else config / 'Code/User')]:
        # Check every ancestor below HOME/config, including Code and Library.
        ancestors = [p for p in reversed(directory.parents)
                     if p != home and p != config and (home in p.parents or config in p.parents)]
        for dest in [*ancestors, directory]:
            if dest.is_symlink() or (exists(dest) and not dest.is_dir()):
                previous = next((e for e in reversed(entries) if e['dest'] == str(dest)), None)
                if previous and not (previous.get('inherited') and points_to(dest, Path(previous['target']))):
                    raise RuntimeError(f'管理中のディレクトリが変更されています。保持しました: {dest}')
                if dest in state.parents or dest.resolve() in state.resolve().parents:
                    raise RuntimeError(f'復旧記録を含むディレクトリは置換できません: {dest}')
                # Keep unrelated settings visible without writing through the old
                # directory symlink. Clean removes these owned links first.
                original_directory = dest.resolve()
                children = list(dest.iterdir()) if dest.is_dir() else []
                local = dest / '.gitconfig.local'
                local_data = local.read_bytes() if dest == config / 'git' and local.is_file() else None
                entry = backup_entry(dest, state)
                entry['kind'] = 'directory'
                if local_data is not None:
                    entry['local_hash'] = hashlib.sha256(local_data).hexdigest()
                entries.append(entry)
                save(journal, entries)
                move_original(entry)
                dest.mkdir(parents=True)
                if local_data is not None:
                    (dest / '.gitconfig.local').write_bytes(local_data)
                    (dest / '.gitconfig.local').chmod(0o600)
                for child in children:
                    if child.name == '.gitconfig.local' and local_data is not None:
                        continue
                    target = original_directory / child.name
                    inherited = {'dest': str(dest / child.name), 'backup': None,
                                 'kind': 'link', 'target': str(target), 'inherited': True}
                    entries.append(inherited)
                    save(journal, entries)
                    (dest / child.name).symlink_to(target)
            elif not exists(dest):
                entry = backup_entry(dest, state)
                entry['kind'] = 'directory'
                entries.append(entry)
                save(journal, entries)
                dest.mkdir(parents=True, exist_ok=True)
    # Git include paths honor XDG_CONFIG_HOME, including paths with spaces.
    quote = lambda value: json.dumps(str(value), ensure_ascii=False)
    (state / 'gitconfig').write_text(
        '[include]\n  path = ' + quote(ROOT / 'git/.gitconfig') + '\n'
        '[core]\n  excludesfile = ' + quote(config / 'git/ignore') + '\n'
        '[include]\n  path = ' + quote(config / 'git/.gitconfig.local') + '\n'
    )
    for dest, target in manifest(home, config, platform, state):
        if points_to(dest, target):
            continue
        # Keep the first backup across reinstalls and user replacements.
        previous = next((e for e in reversed(entries) if e['dest'] == str(dest)), None)
        if previous is not None and not (previous.get('inherited') and points_to(dest, Path(previous['target']))):
            raise RuntimeError(f'管理中のリンクが変更されています。保持しました: {dest}')
        dest.parent.mkdir(parents=True, exist_ok=True)
        entry = backup_entry(dest, state)
        entry.update(kind='link', target=str(target))
        entries.append(entry)
        save(journal, entries)
        move_original(entry)
        dest.symlink_to(target)
        print(f'link: {dest} -> {target}')
    retire_links(home)


def clean(journal, entries):
    remaining = list(entries)
    for entry in reversed(entries):
        dest = Path(entry['dest'])
        backup = Path(entry['backup']) if entry['backup'] else None
        if entry['kind'] == 'link':
            if points_to(dest, Path(entry['target'])):
                dest.unlink()
            elif exists(dest):
                print(f'保持しました (変更された設定): {dest}', file=sys.stderr)
                continue
        elif exists(dest):
            if dest.is_symlink() or not dest.is_dir():
                print(f'保持しました (変更されたディレクトリ): {dest}', file=sys.stderr)
                continue
            local = dest / '.gitconfig.local'
            children = list(dest.iterdir())
            if children == [local] and 'local_hash' in entry and local.is_file() and not local.is_symlink():
                if hashlib.sha256(local.read_bytes()).hexdigest() == entry['local_hash']:
                    local.unlink()
            try:
                dest.rmdir()
            except OSError:
                print(f'保持しました (追加された設定): {dest}', file=sys.stderr)
                if backup:
                    continue
                # Newly created shared directories may contain user additions.
                # Leave them in place; there is no original directory to restore.
        if backup and exists(backup):
            backup.rename(dest)
            print(f'restore: {dest}')
        remaining.remove(entry)
        save(journal, remaining)
    if not remaining:
        journal.unlink(missing_ok=True)
    return not remaining


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['install', 'clean'])
    args = parser.parse_args()
    home = Path.home()
    config = Path(os.environ.get('XDG_CONFIG_HOME', str(home / '.config')))
    state_home = Path(os.environ.get('XDG_STATE_HOME', str(home / '.local/state')))
    if not config.is_absolute() or not state_home.is_absolute():
        parser.error('XDG_CONFIG_HOME / XDG_STATE_HOME は絶対パスで指定してください')
    for parent in config.parents:
        if parent != home and parent not in home.parents and parent.is_symlink():
            parser.error(f'XDG_CONFIG_HOME の親のリンクを安全に置換できません: {parent}')
    state = state_home / 'dotfiles' / hashlib.sha256(str(ROOT).encode()).hexdigest()[:16]
    state.mkdir(parents=True, exist_ok=True, mode=0o700)
    state.chmod(0o700)
    journal = state / 'links.json'
    entries = json.loads(journal.read_text()) if journal.exists() else []
    try:
        if args.action == 'install':
            install(home, config, state, journal, entries, sys.platform)
        elif not clean(journal, entries):
            return 1
    except (OSError, RuntimeError) as error:
        print(f'{error}\nバックアップと復旧記録: {state}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
