#!/bin/sh

set +e

if test -z "$DOCS_PATH"; then
    DOCS_PATH=docs
fi

if test -z "$PUBLISH_BRANCH"; then
    PUBLISH_BRANCH=gh-pages
fi

if git branch --list | grep -q $PUBLISH_BRANCH; then
    git branch -D $PUBLISH_BRANCH
fi

git checkout --orphan $PUBLISH_BRANCH
cp -R $DOCS_PATH /github/docs
git rm --cached -r .
mv /github/docs/* .

if test -n $SHOW_UNDERSCORE_FILES; then
    touch .nojekyll
fi

git add .
git config user.name "$GITHUB_ACTOR"
git config user.email "$GITHUB_ACTOR@users.noreply.github.com"
git commit -m "Publish"
git push -f origin $PUBLISH_BRANCH
