#!/bin/sh
function start(){
    echo "----请输入appid：----"
    # read appid
    appid="__UNI__3F88888"
    echo "----appid:$appid----"
    destDir="./androidBase/app/src/main/assets/apps/$appid/www"
    if [ ! -d "$destDir" ]; 
    then
        mkdir -p "$destDir"
    fi
    cp -rp ./dist/build/app-plus/. $destDir

    # echo "----开始编译----"
    # apk_path="./app/build/outputs/apk/debug/app-debug.apk"
    # cd ./androidBase
    # # 删除老的apk
    # rm -rf $apk_path
    # echo "\033[37;45m*************************  打包开始🎉  🎉  🎉 *************************   \033[0m"
    # sleep 1
    # # 执行安卓打包脚本
    # sh ./gradlew clean assembleDebug
    # # 检查apk文件是否存在
    # if [ -f "$apk_path" ]; then
    # echo "$apk_path"
    # echo "\033[37;45m打包成功 🎉  🎉  🎉   \033[0m"
    # adb install $apk_path
    # sleep 1
    # else
    # echo "\033[37;45m没有找到对应的apk文件 😢 😢 😢   \033[0m"
    # exit 1
    # fi
}

function zipwgt(){
    cd ./dist/build/app-plus
    tar -cvf __UNI__3F88888.wgt *
    cd ../../../
}

function installapk(){
    # 检查apk文件是否存在
    apk_path="./androidBase/app/build/outputs/apk/debug/app-debug.apk"
    if [ -f "$apk_path" ]; 
    then
        echo "$apk_path"
        echo "\033[37;45m打包成功 🎉  🎉  🎉   \033[0m"
        adb install $apk_path
    else
        echo "\033[37;45m打包失败 🎉  🎉  🎉   \033[0m"
    fi
    sleep 1
}

function startservice(){
    cd ./dist/build/app-plus
    http-server
    cd ../../../
}

# start
zipwgt
installapk
startservice