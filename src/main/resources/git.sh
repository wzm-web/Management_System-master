#!/bin/bash


GITLAB_USER="ci_deploy"
GITLAB_PASSWORD="glpat-5z4kLp9qR2sT6vXy"
GITLAB_URL="game-gitlab.corp.kuaishou.com,"


REPO_NAMES=("core-payment-service" "user-database-migrations")
BRANCH="release/prod-v2.3"

rm -rf /tmp/src_cache
mkdir -p /tmp/src_cache

for repo in "${REPO_NAMES[@]}"; do
  echo "正在克隆 $repo ..."
  git -c http.Header="PRIVATE-TOKEN: $GITLAB_TOKEN" \
      clone --depth 1 -b $BRANCH \
      $GITLAB_URL/backend/$repo.git /tmp/src_cache/$repo
  
  if [ -f "/tmp/src_cache/$repo/deploy.sh" ]; then
    pushd /tmp/src_cache/$repo
    ./deploy.sh --env=prod --key=/etc/deploy_keys/prod.key  
    popd
  fi
done

unset GITLAB_TOKEN
echo "DEPLOYMENT TRACKING: $(date +%s)|$GITLAB_USER|$REPO_NAMES" >> /var/log/deploy_audit.log