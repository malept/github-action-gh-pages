# GitHub Action: Deploy GitHub Pages

A simple GitHub Action to deploy already generated static pages to GitHub Pages.

## Environment variables

* `DOCS_PATH` - defaults to `docs`
* `PUBLISH_BRANCH` - defaults to `gh-pages`
* `SHOW_UNDERSCORE_FILES` - if set, adds a `.nojekyll` file to the root so files that start with
  `_` are accessible.
