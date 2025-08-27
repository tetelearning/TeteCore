echo "Time: $(date -Iseconds)" > ./Tete.Web/wwwroot/build.txt
echo "Build: $TRAVIS_BUILD_NUMBER" >> ./Tete.Web/wwwroot/build.txt
echo "Branch: $TRAVIS_BRANCH" >> ./Tete.Web/wwwroot/build.txt
