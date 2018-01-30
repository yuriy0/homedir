#! bash

# This script tries to fix broken LFS files in a git repo
# This creates two new commits on the local copy and pushes the first

set -e # git should not fail

usage () {
    echo "${FUNCNAME} GIT_PATHSPEC LFS_TRACKING_INFO"
    echo "  If any arguments have spaces, enclose in single quotes"
    echo >&2 "$@"
    exit 1
}
br () {
  echo "## $@"
}
[ "$#" -eq 2 ] || usage "2 arguments required, $# provided"

pathspec="$1"
lfs_tracking="$2"
lfs_tracking_nm=("${lfs_tracking[@]//\"/}")
quo=\"

br "Untracking path spec..."
git lfs untrack "$lfs_tracking"
br "Staging for commit..."
git rm --cached "$pathspec"
git add .gitattributes
br "Committing removal..."
git commit -m "${quo}Remove broken LFS files ($lfs_tracking_nm)${quo}"
br "Pushing..."
git push

br "Re-tracking path spec..."
git lfs track "$lfs_tracking"
br "Staging for commit..."
git add .gitattributes "$pathspec"
br "Committing re-addition..."
git commit -m "${quo}Re-adding broken LFS Files ($lfs_tracking_nm)${quo}"

br "Completed; verify that the state of the repo is correct, then push."
git log -n2
