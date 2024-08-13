#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

GH_NAME=${GH_NAME:-"gh"}
GH_VERSION=${GH_VERSION:-"2.53.0"}
ARCH=${ARCH:-"amd64"}
RPM_GH_URL=https://github.com/cli/cli/releases/download/v${GH_VERSION}/${GH_NAME}_${GH_VERSION}_linux_${ARCH}.rpm

install-gh() {
  echo "Install gh ..."
  if [ "$(command -v gh)" = "" ]; then
    curl -Lo "/tmp/${GH_NAME}_${GH_VERSION}_linux_${ARCH}.rpm" "${RPM_GH_URL}"
    yum -y install /tmp/${GH_NAME}_${GH_VERSION}_linux_${ARCH}.rpm
    rm -f "/tmp/${GH_NAME}_${GH_VERSION}_linux_${ARCH}.rpm"
  fi
}

auth-gh() {
  echo "Auth login gh ..."
  if gh auth status &>/dev/null; then
    return 0
  else
    GH_TOKEN=$(<.gh_token.txt)
    if [ -z "$GH_TOKEN" ]; then
      echo "Error: Personal Access Token not found."
      exit 1
    fi
    echo "$GH_TOKEN" | gh auth login --with-token
  fi
}


main() {
    install-gh
    auth-gh
}

main "$@"
