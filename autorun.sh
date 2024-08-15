#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

GIT_VERSION=${GIT_VERSION:-"2.43.5"}

GH_NAME=${GH_NAME:-"gh"}
GH_VERSION=${GH_VERSION:-"2.53.0"}
ARCH=${ARCH:-"amd64"}
RPM_GH_URL=https://github.com/cli/cli/releases/download/v${GH_VERSION}/${GH_NAME}_${GH_VERSION}_linux_${ARCH}.rpm

install-git() {
  echo "Install git ..."
  if ! rpm -q "git-${GIT_VERSION}" &> /dev/null; then
    yum -y install "git-${GIT_VERSION}"
  fi
  
  if ! rpm -q "git-${GIT_VERSION}" &> /dev/null; then
    echo "Install git-${GIT_VERSION} failed!" >&2
    exit 1
  fi
}

install-gh() {
  echo "Install gh ..."
  if ! rpm -q "${GH_NAME}-${GH_VERSION}" &> /dev/null; then
    curl -Lo "/tmp/${GH_NAME}_${GH_VERSION}_linux_${ARCH}.rpm" "${RPM_GH_URL}"
    yum -y install /tmp/${GH_NAME}_${GH_VERSION}_linux_${ARCH}.rpm
    # rm -f "/tmp/${GH_NAME}_${GH_VERSION}_linux_${ARCH}.rpm"
  fi

  if ! rpm -q "${GH_NAME}-${GH_VERSION}" &> /dev/null; then
    echo "Install ${GH_NAME}-${GH_VERSION} failed!" >&2
    exit 1
  fi
}

auth-gh() {
  echo "Auth login gh ..."
  if gh auth status &>/dev/null; then
    exit 0
  else
    local gh_token=${GH_TOKEN:-""}
    unset GH_TOKEN
    GH_TOKEN_FILE=${GH_TOKEN_FILE:-".gh_token.txt"}

    if [[ -z "${gh_token}" ]]; then
      echo "gh_token not set, try to load from file ..."
      if [[ ! -f "${GH_TOKEN_FILE}" ]]; then
        echo "Error: GH_TOKEN_FILE: ${GH_TOKEN_FILE} not found!"
        exit 1
      fi
      gh_token=$(cat "${GH_TOKEN_FILE}")
    fi

    if [[ -z "${gh_token}" ]]; then
      echo "gh_token can't be empty!"
      exit 1
    fi
    echo "${gh_token}" | gh auth login --with-token
    unset gh_token
  fi
}


main() {

    # Here, Git is manually installed to specify the desired Git version. In fact, when gh is installed, Git will be automatically installed.
    install-git
    install-gh
    auth-gh
}

main "$@"
