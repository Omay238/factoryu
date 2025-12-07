rm -rf build
mkdir build

# build .love
rm **/.DS_Store
cd src
zip -r -9 ../build/factoryu.love .
cd ../build


# windows
curl -LO https://github.com/love2d/love/releases/download/11.5/love-11.5-win32.zip
unzip love-11.5-win32.zip
rm love-11.5-win32.zip
mv love-11.5-win32 factoryu-windows

rm factoryu-windows/changes.txt factoryu-windows/lovec.exe factoryu-windows/readme.txt
cp ../README.md factoryu-windows
cat factoryu.love >> factoryu-windows/love.exe
mv factoryu-windows/love.exe factoryu-windows/factoryu.exe
cd factoryu-windows
zip -r -9 ../factoryu-windows .
cd ..


# macos
curl -LO https://github.com/love2d/love/releases/download/11.5/love-11.5-macos.zip
unzip love-11.5-macos.zip
rm love-11.5-macos.zip
mv love.app factoryu.app

cp ../support/build/macos/Info.plist factoryu.app/Contents
cp ../support/build/macos/PkgInfo factoryu.app/Contents
cp factoryu.love factoryu.app/Contents/resources
cd factoryu.app
zip -y -r -9 ../factoryu.app.zip .
cd ..


# linux doesn't really work yet


# web
bun x love.js -c -t factoryu factoryu.love factoryu-web
cd factoryu-web
rm -rf theme
cp -r ../../support/build/web/theme .
cp ../../support/build/web/index.html .
zip -r -9 ../factoryu-web.zip .
cd ..
