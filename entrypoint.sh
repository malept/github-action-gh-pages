#!/bin/sh

set -e

if test -n "$GH_PAGES_DEBUG"; then
    set -x
fi

if test -n "$INPUT_DOCSPATH"; then
    DOCS_PATH="$INPUT_DOCSPATH"
else
    DOCS_PATH=docs
fi

if test -z "$INPUT_GITCOMMITEMAIL"; then
    INPUT_GITCOMMITEMAIL="$GITHUB_ACTOR@users.noreply.github.com"
fi

if test -z "$INPUT_GITCOMMITMESSAGE"; then
    INPUT_GITCOMMITMESSAGE="Publish"
fi

if test -z "$INPUT_GITCOMMITUSER"; then
    INPUT_GITCOMMITUSER="$GITHUB_ACTOR"
fi

if test -n "$INPUT_DEFAULTBRANCH"; then
  DEFAULT_BRANCH="$INPUT_DEFAULTBRANCH"
else
  DEFAULT_BRANCH=master
fi

if test -n "$INPUT_PUBLISHBRANCH"; then
    PUBLISH_BRANCH="$INPUT_PUBLISHBRANCH"
else
    PUBLISH_BRANCH=gh-pages
fi

if test -n "$INPUT_VERSIONDOCS"; then
    if test -n "$INPUT_GITREVISION"; then
        GIT_REVISION="$INPUT_GITREVISION"
    elif test -n "$GITHUB_REF"; then
        GIT_REVISION="$(echo $GITHUB_REF | sed -e 's:refs/\(head\|tag\)s/::g')"
    fi
fi

if test -n "$GIT_REVISION"; then
    DOC_TARGET_DIR="$GIT_REVISION"
elif test -n "$INPUT_VERSIONDOCS"; then
    DOC_TARGET_DIR="$DEFAULT_BRANCH"
else
    DOC_TARGET_DIR=.
fi

if ! git branch --list --remote | grep --quiet "origin/${PUBLISH_BRANCH}$"; then
    echo "Creating new $PUBLISH_BRANCH...."
    git checkout --orphan $PUBLISH_BRANCH
    git rm --cached .gitignore
    git rm --force -r .

    if test -n $INPUT_SHOWUNDERSCOREFILES; then
        touch .nojekyll
    fi
else
    echo "Switching to existing $PUBLISH_BRANCH..."
    git checkout $PUBLISH_BRANCH
    if test "$DOC_TARGET_DIR" != "." -a -d "$DOC_TARGET_DIR"; then
        git rm -r "$DOC_TARGET_DIR"
    fi
fi

if test "$DOC_TARGET_DIR" = "."; then
    rsync --archive "$DOCS_PATH"/ ./
    rm -r "$DOCS_PATH"/
else
    if test -n "$INPUT_VERSIONDOCS" -a "$DOC_TARGET_DIR" = "$DEFAULT_BRANCH"; then
        REDIRECT_URL="$DOC_TARGET_DIR/$INPUT_REDIRECTURLSUFFIX"
        echo "<html><head><meta http-equiv='refresh' content='0; url=$REDIRECT_URL'></head></html>" > index.html
    fi
    mv "$DOCS_PATH" "$DOC_TARGET_DIR"
fi

git add .

if test -n "$(git status -s)"; then
    git config user.name "$INPUT_GITCOMMITUSER"
    git config user.email "$INPUT_GITCOMMITEMAIL"
    git commit $INPUT_GITCOMMITFLAGS --message "$INPUT_GITCOMMITMESSAGE"

    if test -n "$GH_PAGES_SSH_DEPLOY_KEY"; then
        mkdir ~/.ssh
        echo "$GH_PAGES_SSH_DEPLOY_KEY" > ~/.ssh/deploy_key
        chmod 400 ~/.ssh/deploy_key

        git remote rm origin
        git remote add origin "git@github.com:$GITHUB_REPOSITORY.git"
    else
        echo "machine github.com login $GITHUB_ACTOR password $GITHUB_TOKEN" > ~/.netrc
        chmod 600 ~/.netrc
    fi

    GIT_SSH_COMMAND="ssh -i ~/.ssh/deploy_key" git push origin HEAD:$PUBLISH_BRANCH
fi
