import os
import shutil
from pathlib import Path
import git
import time
import subprocess
import re

RELEASE_ORDER = """
release6_20040906
release7_20050315
release7_20050729_2
release7_20050729_2-icecafe
release8_20050912
release8_20051007
release8_20051020
release8_20051220
release8_20051222
release8_20051227
release9_b4
release9_b5
release9_b9
release9_b11
release9_b13
release9_b14
release9_b15
release9_b17
release9_b19
release9_b20
release9_b21
release9_b22
release9_b23
release9_b26
release9_b26_2
release9_b27
release9_b28
release9_b28_2
release9_b30
release9_b31
release9_b32
release9_b32-mx
release9_b33
release9_b34
release9_b35
release10_b3
release10_b4
release10_b6
release10_b7
release10_b8
release10_b9
release10_b10
release10_b11
release10_b12
release10_b13
release11_b10
release11_b11
release11_b12
release11_b13
release11_b14
release11_b15
release11_b16
release11_b18
release11_b18_2
release11_b19
release11_b19_2
release11_b19_3
release11_b20
release11_b21
release11_b22
release11_b23
release11_b25
release11_b26
release11_b27
release11_b28
release11_b29
release11_b30
release11_b32
release11_b32_spam
release12_b4
release12_b5
release12_b6
release12_b7
release12_b8
release12_b11
release12_b12
release12_b13
release12_b16
release12_b17
release12_b18
release12_b19
release12_b20
release12_b20_newcrypto
release13.1_b5
release13.1_b6
release13.2_b10
release13.2_b3
release13.2_b5
release13.2_b6
release13.2_b7
release13.2_b8
release13.2_b9
release13.2_b11
release13.2_b12
release13.2_b13
release13.2_b14
release13.2_b14b
release13.2_b14b_v2
release13.2_b14b_v3
release13.2_b14b_v4
release13.2_b15
release13.2_b16
release14.1_b2
release14.1_b3
release14.1_b4
release14.1_b5
release14.1_b6
release14.1_b7
release14.1_b8
release14.1_b8_debug
release14.1_b9
release14.1_b10
release14.1_b11
release14.1_b12
release14.1_b13
release14.1_b14
release15.2_b1
release15.2_b2
release15.2_b3
release15.2_b4
release15.2_b5
release15.2_b6
release15.2_b7
release15.2_b8
release15.2_b9
release15.2_b10
release15.2_b11
release15.2_b12
release15.2_b13
release15.2_b14
release16_b2
release16_b3
release16_b4
release16_b5
release16_b6
release16_b7
release16_b8
release16_b9
release17_b1
release17_b2
release17_b3
release17_b4
release17_b5
release17_b6
release17_b7
release17_b8
release17_b9
release17_b10
release17_b10b
release17_b10c
release17_b11
release17_b12
release17_b12b
release17_b13
release18_b2
release18_b10_057608660d344f70a14839f120f50f51
r18_20071213_0402_3642_057608660d344f70a14839f120f50f51
r19_20080108_0302_3880c_893f5b1b323d5c8b3767d50e5f5988a6
r19_20080111_0302_3907_893f5b1b323d5c8b3767d50e5f5988a6
r20_20080212_0332_4132_7c04546c82da9ce33b1eeeec08ad80c9
r20_20080218_1014_4169_7c04546c82da9ce33b1eeeec08ad80c9
r20_20080225_0332_4315_7c04546c82da9ce33b1eeeec08ad80c9
r20_20080312_0333_4587_7c04546c82da9ce33b1eeeec08ad80c9
r21_20080317_0342_4666_5527e6590eba8f3fb66348bdf271b5a2
r21_20080319_0343_4774_5527e6590eba8f3fb66348bdf271b5a2
r21_20080327_0343_4865_5527e6590eba8f3fb66348bdf271b5a2
r21_20080328_1459_4880_5527e6590eba8f3fb66348bdf271b5a2
r21_20080403_0343_4908_5527e6590eba8f3fb66348bdf271b5a2
r21_20080403_0343_4908b_5527e6590eba8f3fb66348bdf271b5a2
r21_20080408_1212_4971_5527e6590eba8f3fb66348bdf271b5a2
r21_20080417_0343_5110_5527e6590eba8f3fb66348bdf271b5a2
r22_20080505_1429_5395_66afcf07d8b708feecf6e2e0e797ec09
r22_20080507_1930_5464_66afcf07d8b708feecf6e2e0e797ec09
r22_20080508_0353_5466_66afcf07d8b708feecf6e2e0e797ec09
r22_20080519_1524_5590_66afcf07d8b708feecf6e2e0e797ec09
r23_20080605_0403_6053_deebb3529e0d9d4e847a31e5f6fb4c5b
r23_20080605_0403_6053b_deebb3529e0d9d4e847a31e5f6fb4c5b
r23_20080611_0403_6169_deebb3529e0d9d4e847a31e5f6fb4c5b
r23_20080625_1015_6647_deebb3529e0d9d4e847a31e5f6fb4c5b
""".strip().split()


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
        return int(re.search(r'release(\d+)[_.](.*)', release).group(1))
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

        # os.chdir(output_path)
        # os.system(f'{projector_rays_path} --dump-scripts {input_file_path.name} {output_file_path.name}')

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
        for generated_file_path in output_path.iterdir():
            if generated_file_path.suffix == '.ls':
                script_name = generated_file_path.stem
                if ' - ' in script_name:
                    script_name = script_name.split(' - ', 1)[1]

                new_name = script_name
                count = 1
                while new_name in script_files_by_simplified_name:
                    new_name = f'{script_name} ({count})'
                    count += 1

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
    # history.
    #
    # repo.git.add(update=True)

    repo.index.commit(release)
    repo.create_tag(f'releases/{release}')

    end_time = time.time()

    print(f'Completed {release} (history took {end_time-git_time:.3f} s; {end_time-start_time:.3f} s in total)')

overall_end_time = time.time()

print(f'Completed {len(new_releases)} releases in {overall_end_time-overall_start_time:.3f}')

URL = "https://github.com/branw/habbo-shockwave-client-sources"

print('='*80)

all_releases = get_releases_from_tags(repo.tags)
last_release = None
for release in all_releases:
    line = "|"
    if get_version_from_release(last_release) < get_version_from_release(release):
        line += f"**{release}**"
    else:
        line += f"{release}"
    line += f"|[Browse]({URL}/tree/releases/{release})|"
    if last_release:
        line += f"[Diff]({URL}/compare/releases/{last_release}...releases/{release})"
    line += "|"

    print(line)
    last_release = release

