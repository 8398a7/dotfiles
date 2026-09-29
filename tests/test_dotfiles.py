import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from contextlib import redirect_stdout
import io
from unittest import mock

ROOT = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location('links', ROOT / 'scripts/links.py')
links = importlib.util.module_from_spec(spec)
spec.loader.exec_module(links)


class Sandbox(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='dotfiles tests ')
        self.addCleanup(self.temporary.cleanup)
        self.base = Path(self.temporary.name)
        self.home = self.base / 'home with spaces'
        self.home.mkdir()
        self.env = dict(os.environ, HOME=str(self.home), XDG_CONFIG_HOME=str(self.home / 'config with spaces'),
                        XDG_STATE_HOME=str(self.home / 'state'), GIT_CONFIG_NOSYSTEM='1',
                        GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_COUNT='0',
                        GIT_AUTHOR_NAME='Test', GIT_AUTHOR_EMAIL='test@example.test',
                        GIT_COMMITTER_NAME='Test', GIT_COMMITTER_EMAIL='test@example.test')
        for key in ['GIT_DIR', 'GIT_WORK_TREE', 'GIT_INDEX_FILE', 'GIT_CONFIG_PARAMETERS']:
            self.env.pop(key, None)

    def run_command(self, *args, cwd=None, env=None, **kwargs):
        return subprocess.run(args, cwd=cwd or self.base, env=env or self.env,
                              text=True, capture_output=True, **kwargs)

    def install(self):
        return self.run_command('bash', str(ROOT / 'scripts/install.sh'))

    def clean(self):
        return self.run_command('bash', str(ROOT / 'scripts/clean.sh'))

    def executable(self, name, body):
        directory = self.base / 'mock bin'
        directory.mkdir(exist_ok=True)
        path = directory / name
        path.write_text('#!/bin/sh\n' + body)
        path.chmod(0o755)
        self.env['PATH'] = str(directory) + os.pathsep + self.env['PATH']
        return path

    def git(self, *args):
        result = self.run_command('git', *args)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.strip()

    def repository(self):
        self.git('init', '-b', 'trunk')
        (self.base / 'file.txt').write_text('initial\n')
        self.git('add', 'file.txt')
        self.git('commit', '-m', 'initial')

    def zsh(self, script, *args):
        return self.run_command('zsh', '-f', '-c', script, 'test', *map(str, args))


class LinkTests(Sandbox):
    def test_install_reinstall_restore_original(self):
        old = self.home / '.gitconfig'
        old.write_text('[user]\n name = Original\n')
        config = Path(self.env['XDG_CONFIG_HOME'])
        (config / 'nvim').mkdir(parents=True)
        (config / 'nvim/init.lua').write_text('-- original')
        for _ in range(2):
            result = self.install()
            self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((config / 'nvim').is_symlink())
        self.assertTrue((self.home / '.ideavimrc').is_symlink())
        self.assertTrue((config / 'Code/User/settings.json').is_symlink())
        self.assertTrue((config / 'mise/config.toml').is_symlink())
        result = self.clean()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(old.read_text(), '[user]\n name = Original\n')
        self.assertEqual((config / 'nvim/init.lua').read_text(), '-- original')
        self.assertEqual(self.clean().returncode, 0)

    def test_clean_without_install_preserves_real_files(self):
        dest = Path(self.env['XDG_CONFIG_HOME']) / 'nvim'
        dest.mkdir(parents=True)
        (dest / 'init.lua').write_text('custom')
        self.assertEqual(self.clean().returncode, 0)
        self.assertEqual((dest / 'init.lua').read_text(), 'custom')

    def test_changed_link_keeps_backup(self):
        dest = self.home / '.zshrc'
        dest.write_text('old')
        self.assertEqual(self.install().returncode, 0)
        dest.unlink()
        dest.write_text('new user setting')
        self.assertNotEqual(self.clean().returncode, 0)
        self.assertEqual(dest.read_text(), 'new user setting')
        backups = list((self.home / 'state/dotfiles').rglob('backup-*'))
        self.assertTrue(any(p.is_file() and p.read_text() == 'old' for p in backups))
        self.assertNotEqual(self.install().returncode, 0)
        self.assertEqual(dest.read_text(), 'new user setting')

    def test_directory_symlink_does_not_modify_its_source(self):
        source = self.base / 'old git config'
        source.mkdir()
        (source / '.gitconfig.local').write_text('[user]\n name = Local\n')
        (source / 'ignore').write_text('original-ignore')
        (source / 'unrelated').write_text('keep visible')
        config = Path(self.env['XDG_CONFIG_HOME'])
        config.mkdir()
        (config / 'git').symlink_to(source)
        self.assertEqual(self.install().returncode, 0)
        self.assertEqual((source / 'ignore').read_text(), 'original-ignore')
        self.assertEqual((config / 'git/.gitconfig.local').read_text(), '[user]\n name = Local\n')
        self.assertEqual((config / 'git/unrelated').read_text(), 'keep visible')
        self.assertEqual(self.clean().returncode, 0)
        self.assertTrue((config / 'git').is_symlink())
        self.assertEqual((config / 'git').resolve(), source)

    def test_xdg_git_config_includes_local_overrides(self):
        self.assertEqual(self.install().returncode, 0)
        local = Path(self.env['XDG_CONFIG_HOME']) / 'git/.gitconfig.local'
        local.write_text('[user]\n name = Local\n')
        env = dict(self.env, GIT_CONFIG_GLOBAL=str(self.home / '.gitconfig'))
        result = self.run_command('git', 'config', '--get', 'user.name', env=env)
        self.assertEqual(result.stdout.strip(), 'Local')
        result = self.run_command('git', 'config', '--get', 'core.excludesfile', env=env)
        self.assertEqual(result.stdout.strip(), str(local.parent / 'ignore'))

    def test_mac_settings_and_external_ancestors(self):
        config = Path(self.env['XDG_CONFIG_HOME'])
        state = self.home / 'state'
        state.mkdir()
        journal = state / 'links.json'
        library = self.home / 'Library'
        external = self.base / 'external Library'
        external.mkdir()
        (external / 'keep').write_text('safe')
        library.symlink_to(external)
        entries = []
        with redirect_stdout(io.StringIO()):
            links.install(self.home, config, state, journal, entries, 'darwin')
        self.assertEqual((external / 'keep').read_text(), 'safe')
        self.assertFalse((external / 'Application Support').exists())
        self.assertEqual((library / 'keep').read_text(), 'safe')
        self.assertTrue((library / 'Application Support/Code/User/settings.json').is_symlink())
        with redirect_stdout(io.StringIO()):
            self.assertTrue(links.clean(journal, entries))
        self.assertTrue(library.is_symlink())
        self.assertEqual(library.resolve(), external)

    def test_config_root_symlink_preserves_other_apps_and_restores(self):
        source = self.base / 'old config'
        (source / 'git').mkdir(parents=True)
        (source / 'git/.gitconfig.local').write_text('[user]\n name = Local\n')
        (source / 'other app').mkdir()
        (source / 'other app/config').write_text('untouched')
        config = Path(self.env['XDG_CONFIG_HOME'])
        config.symlink_to(os.path.relpath(source, config.parent))
        self.assertEqual(self.install().returncode, 0)
        self.assertEqual((config / 'other app/config').read_text(), 'untouched')
        self.assertEqual((source / 'git/.gitconfig.local').read_text(), '[user]\n name = Local\n')
        self.assertEqual(self.clean().returncode, 0)
        self.assertTrue(config.is_symlink())
        self.assertEqual(config.resolve(), source)

    def test_external_xdg_symlink_parent_is_rejected(self):
        source = self.base / 'external config'
        source.mkdir()
        parent = self.base / 'config parent'
        parent.symlink_to(source)
        self.env['XDG_CONFIG_HOME'] = str(parent / 'config')
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(list(source.iterdir()), [])
        self.assertFalse((self.home / '.zshrc').exists())

    def test_changed_managed_directory_is_preserved(self):
        config = Path(self.env['XDG_CONFIG_HOME'])
        self.assertEqual(self.install().returncode, 0)
        self.assertEqual(self.clean().returncode, 0)
        # Force install to own a replacement directory, then replace it again.
        source = self.base / 'original sheldon'
        source.mkdir()
        config.mkdir(exist_ok=True)
        (config / 'sheldon').symlink_to(source)
        self.assertEqual(self.install().returncode, 0)
        (config / 'sheldon/plugins.toml').unlink()
        (config / 'sheldon').rmdir()
        newer = self.base / 'new user sheldon'
        newer.mkdir()
        (config / 'sheldon').symlink_to(newer)
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((config / 'sheldon').resolve(), newer)
        self.assertEqual(list(newer.iterdir()), [])

    def test_legacy_owned_links_only(self):
        (self.home / '.vim').symlink_to(ROOT / 'vim')
        other = self.base / 'external tmux'
        other.mkdir()
        (self.home / '.tmux').symlink_to(other)
        self.assertEqual(self.install().returncode, 0)
        self.assertFalse((self.home / '.vim').is_symlink())
        self.assertTrue((self.home / '.tmux').is_symlink())


class GitTests(Sandbox):
    def test_unstage_preserves_working_content(self):
        self.repository()
        (self.base / 'file.txt').write_text('new content\n')
        self.git('add', 'file.txt')
        env = dict(self.env, GIT_CONFIG_GLOBAL=str(ROOT / 'git/.gitconfig'))
        result = self.run_command('git', 'unstage', 'file.txt', env=env)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.base / 'file.txt').read_text(), 'new content\n')
        self.assertEqual(self.git('diff', '--cached'), '')

    def test_ignores_lists_tracked_ignored_files(self):
        self.repository()
        (self.base / '.gitignore').write_text('file.txt\n')
        env = dict(self.env, GIT_CONFIG_GLOBAL=str(ROOT / 'git/.gitconfig'))
        result = self.run_command('git', 'ignores', env=env)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), 'file.txt')

    def test_prune_preserves_worktrees_and_nonstandard_default(self):
        self.repository()
        self.git('branch', 'remote-default')
        self.git('branch', 'merged')
        self.git('branch', 'occupied')
        self.git('worktree', 'add', str(self.base / 'other worktree'), 'occupied')
        # Cached remote HEAD protects custom default names without networking.
        self.git('remote', 'add', 'origin', str(self.base / 'unused'))
        self.git('update-ref', 'refs/remotes/origin/remote-default', 'HEAD')
        self.git('symbolic-ref', 'refs/remotes/origin/HEAD', 'refs/remotes/origin/remote-default')
        result = self.run_command('bash', str(ROOT / 'git/bin/delete-merged-branches'))
        self.assertEqual(result.returncode, 0, result.stderr)
        branches = self.git('branch', '--format=%(refname:short)').splitlines()
        self.assertNotIn('merged', branches)
        self.assertIn('occupied', branches)
        self.assertIn('remote-default', branches)
        self.assertIn('trunk', branches)

    def test_prune_failure_does_not_delete_any_branches(self):
        self.repository()
        self.git('branch', 'merged')
        self.git('remote', 'add', 'origin', str(self.base / 'missing repo'))
        result = self.run_command('bash', str(ROOT / 'git/bin/delete-merged-branches'))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('merged', self.git('branch', '--format=%(refname:short)'))

    def test_prune_fetches_uncached_custom_default(self):
        self.repository()
        self.git('branch', 'merged')
        remote = self.base / 'remote.git'
        self.git('clone', '--bare', str(self.base), str(remote))
        self.git('remote', 'add', 'origin', str(remote))
        self.git('switch', '-c', 'working')
        result = self.run_command('bash', str(ROOT / 'git/bin/delete-merged-branches'))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('trunk', self.git('branch', '--format=%(refname:short)'))
        self.assertNotIn('merged', self.git('branch', '--format=%(refname:short)'))

    def test_issue_hook_opt_in_and_idempotence(self):
        self.repository()
        self.git('switch', '-c', 'feature/123-fix')
        message = self.base / 'message with spaces'
        message.write_text('fix: useful change\n\nbody\n')
        hook = str(ROOT / 'git/hooks/commit-msg')
        self.assertEqual(self.run_command('sh', hook, str(message)).returncode, 0)
        self.assertEqual(message.read_text().splitlines()[0], 'fix: useful change')
        self.git('config', 'dotfiles.issuePrefix', 'true')
        for _ in range(2):
            self.assertEqual(self.run_command('sh', hook, str(message)).returncode, 0)
        self.assertEqual(message.read_text(), '[#123] fix: useful change\n\nbody\n')
        self.assertFalse(list(self.base.glob('message with spaces.*')))

    def test_prompt_full_branch_detached_and_percent_literal(self):
        self.repository()
        self.git('switch', '-c', 'feature/100%done')
        script = 'source "$1"; git_current_branch_prompt'
        result = self.zsh(script, ROOT / 'zsh/functions/git_current_branch_prompt.zsh')
        self.assertIn('feature/100%%done', result.stdout)
        self.git('switch', '--detach')
        result = self.zsh(script, ROOT / 'zsh/functions/git_current_branch_prompt.zsh')
        self.assertIn(self.git('rev-parse', '--short', 'HEAD'), result.stdout)


class ShellTests(Sandbox):
    def test_path_dedup_and_space_safe_gitroot(self):
        self.repository()
        sub = self.base / 'nested dir'
        sub.mkdir()
        script = 'source "$1"; source "$2"; expath "$3"; expath "$3"; cd -- "$4"; cd_gitroot; print -r -- "$PWD"; print -l -- $path'
        result = self.zsh(script, ROOT / 'zsh/functions/expath.zsh', ROOT / 'zsh/functions/cd_gitroot.zsh', sub, sub)
        self.assertEqual(result.returncode, 0, result.stderr)
        lines = result.stdout.splitlines()
        self.assertEqual(lines[0], str(self.base))
        self.assertEqual(lines.count(str(sub)), 1)

    def test_directory_widget_escapes_and_cancel_preserves_buffer(self):
        self.executable('fd', "printf '%s\\0' 'space dir/a;echo nope'\n")
        fzf = self.executable('fzf', 'cat\n')
        script = 'source "$1"; zle() { :; }; BUFFER=original; fzf-fd; print -r -- "$BUFFER"'
        result = self.zsh(script, ROOT / 'zsh/functions/fzf_fd.zsh')
        self.assertEqual(result.returncode, 0, result.stderr)
        expected = "source \"$1\"; zle() { :; }; fzf-fd; print -r -- ${(Q)${BUFFER#cd -- }}"
        result = self.zsh(expected, ROOT / 'zsh/functions/fzf_fd.zsh')
        self.assertEqual(result.stdout.strip(), 'space dir/a;echo nope')
        fzf.write_text('#!/bin/sh\nexit 130\n')
        result = self.zsh(script, ROOT / 'zsh/functions/fzf_fd.zsh')
        self.assertEqual(result.stdout.strip(), 'original')

    def test_ssh_widget_skips_patterns_comments_and_cancel(self):
        (self.home / '.ssh').mkdir()
        (self.home / '.ssh/config').write_text('Host alpha beta *.example !excluded # comment words\n')
        fzf = self.executable('fzf', 'head -n 2 | tail -n 1\n')
        script = 'source "$1"; zle() { :; }; BUFFER=unchanged; fzf_ssh; print -r -- "$BUFFER"'
        result = self.zsh(script, ROOT / 'zsh/functions/fzf_ssh.zsh')
        self.assertEqual(result.stdout.strip(), 'ssh -- beta', result.stderr)
        fzf.write_text('#!/bin/sh\nexit 130\n')
        self.assertEqual(self.zsh(script, ROOT / 'zsh/functions/fzf_ssh.zsh').stdout.strip(), 'unchanged')

    def test_file_widget_preserves_exact_filename(self):
        filename = 'a dir/line\nbreak;$(echo nope).txt'
        self.executable('fd', "printf '%s\\0' '" + filename + "'\n")
        fzf = self.executable('fzf', 'cat\n')
        script = 'source "$1"; zle() { :; }; BUFFER=original; fzf_file_nvim; print -rn -- ${(Q)${BUFFER#nvim -- }}'
        result = self.zsh(script, ROOT / 'zsh/functions/fzf_file_nvim.zsh')
        self.assertEqual(result.stdout, filename, result.stderr)
        fzf.write_text('#!/bin/sh\nexit 130\n')
        self.assertEqual(self.zsh(script, ROOT / 'zsh/functions/fzf_file_nvim.zsh').stdout, 'original')

    def test_notification_passes_command_as_data(self):
        output = self.base / 'notification.json'
        self.executable('osascript', 'exec python3 -c \'import json,sys; from pathlib import Path; Path(sys.argv[1]).write_text(json.dumps(sys.argv[2:]))\' "$NOTIFY_OUTPUT" "$@"\n')
        self.env['NOTIFY_OUTPUT'] = str(output)
        command = 'sleep 15; echo "a\\b"; $(false)'
        script = 'source "$1"; __timetrack_threshold=1; __my_preexec_start_timetrack "$2"; SECONDS=$((SECONDS + 15)); __my_preexec_end_timetrack'
        result = self.zsh(script, ROOT / 'zsh/functions/hook.zsh', command)
        self.assertEqual(result.returncode, 0, result.stderr)
        args = json.loads(output.read_text())
        self.assertEqual(args[0], '-')
        self.assertGreaterEqual(int(args[1]), 15)
        self.assertEqual(args[2], command)

    def test_z_database_handles_variable_rank_and_spaces(self):
        directory = self.base / 'dir with spaces'
        directory.mkdir()
        data = self.home / '.z'
        data.write_text(str(directory) + '|123456789|1000\n')
        self.executable('fzf', 'cat\n')
        script = 'source "$1"; zle() { :; }; fzf_z_search; print -r -- ${(Q)${BUFFER#cd -- }}'
        result = self.zsh(script, ROOT / 'zsh/functions/fzf_z_search.zsh')
        self.assertEqual(result.stdout.strip(), str(directory), result.stderr)

    def test_psk_uses_term_and_explicit_force(self):
        self.executable('fzf', "printf '%s\\n' '123 00:01 test process'\n")
        script = 'source "$1"; kill() { print -r -- "$*"; }; psk; psk --force'
        result = self.zsh(script, ROOT / 'zsh/functions/psk.zsh')
        self.assertEqual(result.stdout.splitlines(), ['-s TERM -- 123', '-s KILL -- 123'], result.stderr)

    def test_git_widget_switches_remote_branch(self):
        self.repository()
        self.git('update-ref', 'refs/remotes/origin/feature/remote', 'HEAD')
        self.git('remote', 'add', 'origin', str(self.base / 'unused'))
        self.executable('fzf', "printf 'remotes/origin/feature/remote\\trefs/remotes/origin/feature/remote\\n'\n")
        result = self.zsh('source "$1"; fzf_git', ROOT / 'zsh/functions/fzf_git.zsh')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.git('branch', '--show-current'), 'feature/remote')

    def test_wt_uses_json_path_and_cancel(self):
        directory = self.base / 'worktree path'
        directory.mkdir()
        self.executable('fzf', 'cat\n')
        payload = json.dumps([{'bare': False, 'path': str(directory)}])
        script = 'source "$1"; git() { if [[ "$*" == "wt --json" ]]; then print -r -- "$2"; else print -r -- "$*"; fi; }; wt'
        # Store JSON separately because function positional args shadow script args.
        script = 'data=$2; ' + script.replace('print -r -- "$2"', 'print -r -- "$data"')
        result = self.zsh(script, ROOT / 'zsh/functions/wt.zsh', payload)
        self.assertEqual(result.stdout.strip(), 'wt ' + str(directory), result.stderr)

    def test_export_failure_and_sorted_atomic_success(self):
        # Copy the script/manifest so export cannot mutate this checkout.
        repo = self.base / 'copied repo'
        (repo / 'scripts').mkdir(parents=True)
        (repo / 'vscode').mkdir()
        shutil.copy2(ROOT / 'scripts/export-vscode-extensions.sh', repo / 'scripts')
        extensions = repo / 'vscode/extensions.txt'
        extensions.write_text('original\n')
        code = self.executable('code', 'printf partial; exit 1\n')
        command = str(repo / 'scripts/export-vscode-extensions.sh')
        self.assertNotEqual(self.run_command('bash', command).returncode, 0)
        self.assertEqual(extensions.read_text(), 'original\n')
        self.assertEqual(list((repo / 'vscode').iterdir()), [extensions])
        code.write_text("#!/bin/sh\nprintf '%s\\n' z.ext a.ext a.ext\n")
        self.assertEqual(self.run_command('bash', command).returncode, 0)
        self.assertEqual(extensions.read_text(), 'a.ext\nz.ext\n')

    def test_interactive_start_without_optional_tools_and_preserve_term(self):
        # Stub integrations to avoid installing plugins or modifying real state.
        # /usr/bin:/bin supplies shell utilities but none of the optional CLIs.
        self.env['PATH'] = '/usr/bin:/bin'
        env = dict(self.env, TERM='xterm-test', LANG='C', BUN_INSTALL=str(self.home / '.bun'))
        bun = self.home / '.bun'
        bun.mkdir()
        (bun / '_bun').write_text('typeset -g BUN_COMPLETION_LOADED=yes\n')
        result = self.run_command('zsh', '-f', '-i', '-c',
                                  'source "$1"; source "$1"; print -r -- "$TERM $LANG $BUN_COMPLETION_LOADED"',
                                  'test', str(ROOT / 'zsh/.zshrc'), env=env)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('xterm-test C yes', result.stdout)
        self.assertEqual(result.stderr, '')


class NeovimTests(Sandbox):
    def nvim(self, code, env=None):
        return self.run_command('nvim', '--clean', '--headless', '-i', 'NONE', '+lua ' + code, '+qa', env=env)

    def test_highlight_does_not_accumulate(self):
        code = f'dofile({json.dumps(str(ROOT / "nvim/lua/config/autocmds.lua"))}); '
        code += 'for _=1,5 do vim.cmd("doautocmd WinEnter") end; assert(#vim.fn.getmatches() == 1); vim.fn.clearmatches(); vim.cmd("doautocmd WinEnter"); assert(#vim.fn.getmatches() == 1)'
        result = self.nvim(code)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('Error', result.stderr)

    def test_clipboard_auto_native_and_forced_osc52(self):
        code = f'dofile({json.dumps(str(ROOT / "nvim/lua/config/options.lua"))}); '
        env = dict(self.env, DOTFILES_CLIPBOARD='auto')
        for key in ['SSH_CONNECTION', 'SSH_TTY', 'WSL_DISTRO_NAME', 'WSL_INTEROP']:
            env.pop(key, None)
        result = self.nvim(code + 'assert(vim.g.clipboard == nil)', env)
        self.assertNotIn('Error', result.stderr)
        remote = dict(env, SSH_CONNECTION='test ssh')
        result = self.nvim(code + 'assert(vim.g.clipboard.name == "OSC 52")', remote)
        self.assertNotIn('Error', result.stderr)
        remote['DOTFILES_CLIPBOARD'] = 'native'
        result = self.nvim(code + 'assert(vim.g.clipboard == nil)', remote)
        self.assertNotIn('Error', result.stderr)
        env['DOTFILES_CLIPBOARD'] = 'osc52'
        result = self.nvim(code + 'assert(vim.g.clipboard.name == "OSC 52"); local paste=vim.g.clipboard.paste["+"](); assert(type(paste[1]) == "table" and type(paste[2]) == "string")', env)
        self.assertNotIn('Error', result.stderr)


if __name__ == '__main__':
    unittest.main()
