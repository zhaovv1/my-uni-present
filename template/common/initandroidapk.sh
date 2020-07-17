#!/bin/sh
function selectdevice(){
    selectdeviceId=""
    adb devices > devices.txt  2>&1 
    i=0
    exec 3<&0         # save stdin 将标准输入重定向到文件描述符3
    exec < ./devices.txt # 输入文件

    while read line; do
        line=$(eval echo ${line})
        if [[ $line =~ "devices" ]]
        then
        echo ""
        elif [[ $line =~ "device" ]]
        then
            deviceName=${line%% *}
            id=$(( ${#devicesArrTemp[@]} + 1 ))
            echo "$id):$deviceName"
            devicesArrTemp[${#devicesArrTemp[@]}]=$deviceName
            devicesArrTemp[$i]=$deviceName
            let i++
        else
            echo ""
        fi
    done
    exec 0<&3 
    if [[ 1 -lt ${#devicesArrTemp[@]} ]]
    then
        echo "选择设备："
        read selectindex
        selectindex=$(( $selectindex - 1 ))
        selectdeviceId="${devicesArrTemp[$selectindex]}"
        echo $selectdeviceId
    else
        echo ""
    fi

}


function installapk(){
    # 检查apk文件是否存在
    apk_path="./androidBase/app/build/outputs/apk/debug/app-debug.apk"
    if [ -f "$apk_path" ]; 
    then
        echo "$apk_path"
        echo "\033[37;45m打包成功 🎉  🎉  🎉   \033[0m"
        if [[ -n "${selectdeviceId}" ]]
        then
            adb -s $selectdeviceId install -r $apk_path
        else
            adb install -r $apk_path
        fi
        
        adb shell am start com.ztesoft.fmx.myapplication/.MainActivity
    else
        echo "\033[37;45m打包失败 🎉  🎉  🎉   \033[0m"
    fi
    sleep 1
}

function buidwgt(){
    rm -rf ./dist
    npm run dev:app-plus
}


function startservice(){
    cd ./dist/dev/app-plus
    http-server
    cd ../../../
}

selectdevice
buidwgt &
installapk
startservice 