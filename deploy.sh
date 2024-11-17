set -e
npm run build

cd dist

git init
git add -A
git commit -m "new deploy"
git push -f git@github.com:trujic/nexus.git master:gh-pages

cd -