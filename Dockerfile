FROM debian:buster
LABEL "com.github.actions.name"="GitHub Pages Deployment"
LABEL "com.github.actions.description"="Deploys static pages to GitHub Pages"
LABEL "com.github.actions.icon"="book-open"
LABEL "com.github.actions.color"="gray-dark"
LABEL "repository"="https://github.com/malept/github-action-gh-pages"
LABEL "maintainer"="Mark Lee <https://github.com/malept>"

RUN apt-get update && apt-get install -y --no-install-recommends git openssh-client rsync && apt clean && rm -rf /var/lib/apt/lists/*
RUN ssh-keyscan -H github.com >> /etc/ssh/ssh_known_hosts

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
