
#!/bin/bash
set -e

sudo opm run coverage

temp=`cat packagedef | grep ".Версия(" | sed 's|[^"]*"||' | sed -r 's/".+//'`
version=${temp##*|}

if [ "$TRAVIS_SECURE_ENV_VARS" == "true" ]; then
  if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    sonar-scanner \
        -Dsonar.host.url=$SONAR_HOST \
        -Dsonar.analysis.mode=issues \
        -Dsonar.github.pullRequest=$TRAVIS_PULL_REQUEST \
        -Dsonar.github.repository=$TRAVIS_REPO_SLUG \
        -Dsonar.github.oauth=$SONAR_GITHUB_TOKEN \
        -Dsonar.login=$SONAR_TOKEN \
        -Dsonar.scanner.skip=false

  elif [ "$TRAVIS_BRANCH" == "develop" ] && [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
    sonar-scanner \
        -Dsonar.host.url=$SONAR_HOST \
        -Dsonar.login=$SONAR_TOKEN \
        -Dsonar.projectVersion=$version \
        -Dsonar.scanner.skip=false
  fi
fi