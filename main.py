import collections
import hashlib
import json
import os
import shutil
from pathlib import Path
import git
import time
import subprocess
import re
import datetime

with open('releases.txt', 'r') as f:
    RELEASE_ORDER = f.read().strip().split()

# https://stackoverflow.com/a/39956572/5616282
def try_getting_git_repo(path):
    try:
        repo = git.Repo(path)
        _ = repo.git_dir
        return repo
    except git.exc.InvalidGitRepositoryError:
        return None


def delete_all_files_in_dir(dir_path):
    e = None
    for _ in range(5):
        for path in dir_path.iterdir():
            if path.is_dir():
                if path.name == '.git':
                    continue

                try:
                    shutil.rmtree(path)
                except PermissionError as ex:
                    e = ex
                    time.sleep(0.5)
                    continue
            else:
                os.remove(path)
        return
    raise e


def convert_mac_line_endings_to_unix(path):
    with open(path, 'rb+') as f:
        content = f.read()
        f.seek(0)
        f.truncate(0)
        f.write(content.replace(b'\r', b'\n'))


def get_releases_from_tags(tags):
    releases = [tag.name.split('/', 1)[1] for tag in tags
                if tag.name.startswith('releases/')]
    return sorted(releases, key=RELEASE_ORDER.index)


def get_notes_for_releases(repo, releases):
    notes = [json.loads(repo.git.notes('show', f'releases/{release}'))
             for release in releases]
    return list(zip(releases, notes))


def get_version_from_release(release):
    if release is None:
        return 0
    elif release.startswith('dcr'):
        return 1  # TODO find out actual version numbers of the early releases
    elif release.startswith('release'):
        return int(re.search(r'release(\d+)[_.]?(.*)', release).group(1))
    elif release.startswith('r'):
        return int(re.search(r'r(\d+)_(.*)', release).group(1))


projector_rays_path = Path('projectorrays.exe').resolve()
if not projector_rays_path.exists():
    raise Exception('Missing ProjectorRays binary')

releases_path = Path('releases').resolve()
if not releases_path.exists():
    raise Exception('Missing releases folder')

releases = []
for path in releases_path.iterdir():
    if not path.is_dir():
        continue

    releases.append(path.name)

if not releases:
    raise Exception('No folders in releases folder')

staging_path = Path('staging').resolve()
staging_path.mkdir(exist_ok=True)

# TODO figure out a way to actually support commit reordering, so that this
# script can become idempotent
existing_releases = []
if repo := try_getting_git_repo(staging_path):
    existing_releases.extend(get_releases_from_tags(repo.tags))
else:
    repo = git.Repo.init(staging_path, initial_branch='sources')

new_releases = [release for release in RELEASE_ORDER
                if release in releases and release not in existing_releases]
print(f'Found {len(new_releases)} new releases:', new_releases)

unknown_releases = [release for release in releases if release not in RELEASE_ORDER]
if unknown_releases:
    raise Exception('Unknown releases found, please update releases.txt:\n ', '\n'.join(unknown_releases))

print('-'*80)
overall_start_time = time.time()

# Record the last release each file appears in. Ideally we would record the
# individual scripts as well, but that requires doing two passes :(
last_release_with_file = {}
for release in new_releases:
    input_path = releases_path / release

    for input_file_path in input_path.iterdir():
        if not input_file_path.is_file():
            continue
        if input_file_path.suffix not in ['.dcr', '.cct']:
            continue

        last_release_with_file[input_file_path.name] = release

first_pass_time = time.time()
print(f'First pass took {first_pass_time-overall_start_time:.3f} s')
print('-'*80)

# Parse any new releases and add them to the repo's HEAD
last_release = None
for i, release in enumerate(new_releases):
    delete_all_files_in_dir(staging_path)

    start_time = time.time()

    # Start dumping all the scripts in parallel
    work = []
    file_names = []

    input_path = releases_path / release
    print(f'[{i+1:03}/{len(new_releases):03}] Loading', release)
    for input_file_path in input_path.iterdir():
        if not input_file_path.is_file():
            continue
        if input_file_path.suffix in ['.dir', '.cst']:
            raise Exception(f'Release {release} contains unprotected ' +
                            f'Shockwave file {input_file_path.name}')
        if input_file_path.suffix not in ['.dcr', '.cct']:
            continue

        file_names.append(input_file_path.name)

        output_path = staging_path / input_file_path.name
        output_path.mkdir(exist_ok=True)

        shutil.copy(input_file_path.absolute(), output_path.absolute() / input_file_path.name)

        output_suffix = 'dir' if input_file_path.suffix == 'dcr' else 'cst'
        output_file_path = output_path / f"{input_file_path.stem}.{output_suffix}"

        cmd = f'{projector_rays_path} --dump-scripts {input_file_path.name} {output_file_path.name}'
        process = subprocess.Popen(cmd, cwd=output_path, stdout=subprocess.DEVNULL)

        work.append((output_path, process))

    processing_time = time.time()
    print(f'Processing (loading took {processing_time-start_time:.3f} s)')

    # Process the outputs
    files_to_commit = []
    script_names = {}
    for output_path, process in work:
        process.wait()

        script_files_by_simplified_name = {}
        lowercase_simplified_names = set()
        for generated_file_path in output_path.iterdir():
            if generated_file_path.suffix == '.ls':
                # Simplify name by removing script file info
                script_name = generated_file_path.stem
                if ' - ' in script_name:
                    if match := re.match(r'Cast \w+ (\w+) \d+( - (.*))?', script_name):
                        script_name = match.group(3)

                # De-duplicate names for Windows
                new_name = script_name
                count = 1
                while new_name.lower() in lowercase_simplified_names:
                    new_name = f'{script_name} ({count})'
                    count += 1
                lowercase_simplified_names.add(new_name.lower())

                new_name += generated_file_path.suffix

                script_files_by_simplified_name[new_name] = generated_file_path

        script_names[output_path.name] = list(script_files_by_simplified_name.keys())

        for new_name, existing_path in script_files_by_simplified_name.items():
            new_path = output_path / new_name
            os.rename(existing_path, new_path)
            files_to_commit.append(new_path)
            print(f'+ Adding {output_path.name}/{new_name}')

            # Old Macs used "\r" for line endings, which confuses GitHub
            convert_mac_line_endings_to_unix(new_path)

    git_time = time.time()
    print(f'Building Git history (processing took {git_time-start_time:.3f} s)')

    repo.index.add(files_to_commit)

    # Uncomment to show deletions between releases. Disabled by default
    # because several releases only have a file or two, muddying up the
    # history. See #1.
    #
    # repo.git.add(update=True)

    # Prune files that no longer appear in releases, and scripts that did not
    # appear in the current release
    deletions_to_commit = []
    diff = repo.index.diff(None)
    for change in diff:
        if not change.deleted_file:
            continue

        file_name = change.a_path.split('/', 1)[0]
        entire_file_deleted = last_release_with_file[file_name] == last_release
        only_script_deleted = file_name in file_names
        if entire_file_deleted or only_script_deleted:
            print(f'- Pruning {change.a_path} (deleted {"file" if entire_file_deleted else "script"})')
            deletions_to_commit.append(change.a_path)

    if deletions_to_commit:
        repo.index.remove(deletions_to_commit)

    author = git.Actor('Habbo Devs', None)
    # TODO use more relevant dates (#2)
    date = str(datetime.datetime(2000, 1, 1))
    repo.index.commit(release, author=author, committer=author, author_date=date, commit_date=date)

    tag = f'releases/{release}'
    repo.create_tag(tag)

    # Store the list of files present using Git notes. This allows us to do
    # things like display the number of files per release in the README in an
    # existing repo.
    file_info = {}
    for input_file_path in input_path.iterdir():
        if not input_file_path.is_file():
            continue
        if input_file_path.name not in file_names:
            continue

        sha256 = hashlib.sha256()
        with open(input_file_path, 'rb') as f:
            while data := f.read(66536):
                sha256.update(data)

        file_info[input_file_path.name] = {
            'sha256': sha256.hexdigest(),
            # 'scripts': script_names[input_file_path.name],
        }

    notes = {
        'files': file_info,
    }
    repo.git.notes('add', '-m', json.dumps(notes), tag)

    end_time = time.time()
    print(f'Completed {release} (history took {end_time-git_time:.3f} s; {end_time-start_time:.3f} s in total)')
    print('-'*80)

    last_release = release

overall_end_time = time.time()

print(f'Completed {len(new_releases)} releases in {overall_end_time-overall_start_time:.3f} s')
print('-'*80)

URL = "https://github.com/branw/habbo-shockwave-client-sources"

print('Loading all release info')

all_releases = get_releases_from_tags(repo.tags)
all_releases_with_notes = get_notes_for_releases(repo, all_releases)

print('Creating releases table')

# Create a Markdown table of releases for the README
release_table = ''
last_release = None
for release, notes in all_releases_with_notes:
    is_new_version = get_version_from_release(last_release) < get_version_from_release(release)

    line = '|**' if is_new_version else '|'
    line += release
    line += '**|**' if is_new_version else '|'
    line += f"{len(notes['files'])}"
    line += '**|**' if is_new_version else '|'
    line += f'[Browse]({URL}/tree/releases/{release})'
    line += '**|' if is_new_version else '|'
    if last_release:
        line += '**' if is_new_version else ''
        line += f'[Diff]({URL}/compare/releases/{last_release}...releases/{release})'
        line += '**' if is_new_version else ''
    line += '|\n'

    release_table += line
    last_release = release

print('Creating files table')

# Create a Markdown table with each file's first and last appearance
file_appearances = {}
for release, notes in all_releases_with_notes:
    for file in notes['files'].keys():
        # # Don't count files that had no scripts in a release
        # if not notes['files'][file]['scripts']:
        #     continue

        if file not in file_appearances:
            file_appearances[file] = []
        file_appearances[file].append(release)

file_table = ''
for file, appearances in sorted(file_appearances.items(), key=lambda kv: len(kv[1]), reverse=True):
    first_release = appearances[0]
    last_release = appearances[-1]
    line = f'|{file}|{len(appearances)}' + \
           f'|[{first_release}]({URL}/tree/releases/{first_release}/{file}/)..' + \
           f'[{last_release}]({URL}/tree/releases/{last_release}/{file}/)|'

    file_table += line + '\n'

# Update the README
with open('README.md', 'rb') as f:
    readme = f.read()
with open('README.md', 'wb') as f:
    readme = re.sub(
        rb'\|\*\*.*\n\n### Files',
        release_table.encode() + b'\n### Files',
        readme,
        flags=re.DOTALL)
    readme = re.sub(
        rb'\|-------------------------------\|.*\|.*\n\n## Generator',
        rb'|-------------------------------|\n' + file_table.encode() + b'\n## Generator',
        readme,
        flags=re.DOTALL)
    f.write(readme)

