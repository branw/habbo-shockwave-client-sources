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


def get_version_from_release(release):
    if release is None:
        return 0
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
    repo = git.Repo.init(staging_path)

new_releases = [release for release in RELEASE_ORDER
                if release in releases and release not in existing_releases]
print('New releases:', new_releases)

overall_start_time = time.time()

# Parse any new releases and add them to the repo's HEAD
for release in new_releases:
    delete_all_files_in_dir(staging_path)

    start_time = time.time()

    # Start dumping all the scripts in parallel
    work = []

    input_path = releases_path / release
    print('Exploring', input_path)
    for input_file_path in input_path.iterdir():
        if not input_file_path.is_file():
            continue
        if input_file_path.suffix not in ['.dcr', '.cct']:
            continue

        output_path = staging_path / input_file_path.stem
        output_path.mkdir(exist_ok=True)

        shutil.copy(input_file_path.absolute(), output_path.absolute() / input_file_path.name)

        output_suffix = 'dir' if input_file_path.suffix == 'dcr' else 'cst'
        output_file_path = output_path / f"{input_file_path.stem}.{output_suffix}"

        cmd = f'{projector_rays_path} --dump-scripts {input_file_path.name} {output_file_path.name}'
        process = subprocess.Popen(cmd, cwd=output_path, stdout=subprocess.DEVNULL)

        work.append((output_path, process))

    processing_time = time.time()

    print(f'Processing (exploring took {processing_time-start_time:.3f} s)')

    # Process the outputs
    files_to_commit = []
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

        for new_name, existing_path in script_files_by_simplified_name.items():
            new_path = output_path / new_name
            os.rename(existing_path, new_path)
            files_to_commit.append(new_path)

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

    author = git.Actor('Habbo Devs', None)
    # TODO use more relevant dates (#2)
    date = str(datetime.datetime(2000, 1, 1))
    repo.index.commit(release, author=author, committer=author, author_date=date, commit_date=date)
    repo.create_tag(f'releases/{release}')

    end_time = time.time()

    print(f'Completed {release} (history took {end_time-git_time:.3f} s; {end_time-start_time:.3f} s in total)')

overall_end_time = time.time()

print(f'Completed {len(new_releases)} releases in {overall_end_time-overall_start_time:.3f}')

URL = "https://github.com/branw/habbo-shockwave-client-sources"

table = ''
all_releases = get_releases_from_tags(repo.tags)
last_release = None
for release in all_releases:
    is_new_version = get_version_from_release(last_release) < get_version_from_release(release)

    line = '|**' if is_new_version else '|'
    line += release
    line += '**|**' if is_new_version else '|'
    line += f'[Browse]({URL}/tree/releases/{release})'
    line += '**|' if is_new_version else '|'
    if last_release:
        line += '**' if is_new_version else ''
        line += f'[Diff]({URL}/compare/releases/{last_release}...releases/{release})'
        line += '**' if is_new_version else ''
    line += '|\n'

    table += line
    last_release = release

with open('README.md', 'rb') as f:
    readme = f.read()
with open('README.md', 'wb') as f:
    f.write(re.sub(
        rb'\|\*\*.*\n\n## Generator',
        table.encode() + b'\n## Generator',
        readme,
        flags=re.DOTALL))

