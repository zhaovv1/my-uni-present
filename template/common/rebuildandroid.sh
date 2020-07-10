#!/bin/sh
function buidwgt(){
    printf "\033[37;45m开始编译 🎉  🎉  🎉   \033[0m \n"
    rm -rf ./dist
    npm run build:app-plus

    cd ./dist/build/app-plus
    zip -q -r __UNI__3F88888.wgt *
    cd ../../../
    printf "\033[37;45m编译完成 🎉  🎉  🎉   \033[0m"
}
buidwgt