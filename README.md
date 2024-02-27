# GitHub Action: Deploy GitHub Pages

A simple GitHub Action to deploy already generated static pages to GitHub Pages.

## Inputs

* `defaultBranch` - The default branch name for the repository, defaults to `master` for
  backwards-compatiblity reasons. _Version 2.x will likely default to `main`_.
* `docsPath` - The folder where the generated docs are located, defaults to `docs`.
* `gitCommitEmail` - The email to use when committing to the repository, defaults to the repository
  owner's fake GitHub email.
* `gitCommitFlags` - Any extra `git commit` flags to pass, such as `--no-verify`.
* `gitCommitMessage` - The commit message to use when creating/updating the GitHub Pages branch.
  Defaults to `Publish`.
* `gitCommitUser` - The value to set `git config user.name`, defaults to the repository owner.
* `noCommit` - If set, stage changes but do not commit them, defaults to `false`.
* `publishBranch` - The branch name that GitHub Pages uses to build the website, defaults
  to `gh-pages`.
* `redirectURLSuffix` - The path suffix for the redirect URL used in `index.html`, when
  `versionDocs` is `true`.
* `showUnderscoreFiles` - If set, adds a `.nojekyll` file to the root so files that start with
  `_` are accessible.
* `versionDocs`- If set, put docs for all branches and tags in their own subfolders, defaults
  to `false`.

## Secrets used

This action uses one of two methods to push the commit back up to the repository:

* If `GH_PAGES_SSH_DEPLOY_KEY` is specified in the repository secrets, it is used to push the
  commit back to the repository's SSH endpoint.
* Otherwise, `GITHUB_TOKEN` is used to push the commit back to the repository's HTTPS endpoint. This
  currently only works with private repositories. See the [GitHub Actions forum post](https://github.community/t5/GitHub-Actions/Github-action-not-triggering-gh-pages-upon-push/td-p/26869) for details.

## Example workflow

```yaml
name: Publish Documentation

on: push

jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - run: git fetch --no-tags --prune --depth=1 origin +refs/heads/*:refs/remotes/origin/*
    - name: Build docs
    - run: make docs
    - name: Publish docs
      uses: malept/github-action-gh-pages@main
      with:
        gitCommitUser: Docs Publisher Bot
      env:
        DOCS_SSH_DEPLOY_KEY: ${{ secrets.DOCS_SSH_DEPLOY_KEY }}
```

In a production setting, `main` should be a tagged version (e.g., `v1.0.0`).

## Debugging

If you need to debug the `entrypoint.sh` script, you can set the `GH_PAGES_DEBUG` environment
variable, which sets `-x` in the shell script.
