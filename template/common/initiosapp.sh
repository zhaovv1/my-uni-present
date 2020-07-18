#!/bin/sh
#  Created by yin.yan on 2020/07/08
#  ******************** cli方式创建uni-app 使用脚本打包并运行到iOS基座，目前仅支持指定iOS模拟器 ********************
#  ******************** 先决条件：已有demo.app文件，即iOS的安装包资源 ********************

# 预先定义对应的环境变量
envionmentVariables(){
    # 工程根目录
    project_dir="$(pwd)"
    echo "项目根目录project_dir=${project_dir}"

    # uniapp APP平台资源路径
    uniappre_dir="${project_dir}/dist/dev/app-plus"
    echo "APP平台资源路径uniappre_dir=${uniappre_dir}"

    # uniapp appID
    uni_appid="__UNI__D20B223"

    # # 原生宿主工程路径
    # iosapp_dir="/Users/devops/Desktop/uni_yy"
    # echo "原生宿主工程路径iosapp_dir=${iosapp_dir}"

    # # 原生宿主存放uni资源.wgt路径
    # uniwgt_dir="${iosapp_dir}/uni_yy/UniMP/Apps"
    # echo "uni资源.wgt路径uniwgt_dir=${uniwgt_dir}"

    # 原生宿主scheme.app
    ios_scheme="uni_yy.app"

    # 原生宿主bundleid
    bundle_identifier="com.iwhalecloud.unitestyy"

    # 原生宿主.app路径，用于命令行安装并启动宿主
    bootapp_path=""

    # 是否是模拟器
    is_iphonesimulator=""

    # 选择的模拟器id
    simulatorID_selected=""

    # iPhone手机的udid，特指iOS移动设备
    device_id=""
}

# 使用模拟器运行项目
useSimulator(){
    echo "使用iOS模拟器运行？"
    while true
    do
    echo "Enter y or n : "
    read x
    case "$x" in 
    y|yes ) return 0;;
    n|no  ) return 1;;
    * ) echo "Answer yes or no!"
    esac
    done
}

# 检查原生宿主.app应用程序是否存在，.app为应用程序，无法进行常规判断是否存在
checkiOSApp(){
    if useSimulator ; then
        echo "检测模拟器资源"
        if [ -d "$project_dir/iPhoneSimulator/Payload" ]; 
        then
            echo "\033[37;45m 模拟器Payload文件夹存在success，如果必要请手动查看是否有.app应用程序 \033[0m"
            is_iphonesimulator="true"
            bootapp_path=${project_dir}/iPhoneSimulator/Payload/${ios_scheme}
            echo "原生宿主.app路径bootapp_path=${bootapp_path}"
        else
            echo "\033[37;45m模拟器.app应用程序不存在failed \033[0m"
            exit 1
        fi
        sleep 1
    else
        echo "检测真机资源"
        if [ -d "$project_dir/iPhone/Payload" ]; 
        then
            echo "\033[37;45m 真机Payload文件夹存在success，如果必要请手动查看是否有.app应用程序 \033[0m"
            is_iphonesimulator="false"
            bootapp_path=${project_dir}/iPhone/Payload/${ios_scheme}
            echo "原生宿主.app路径bootapp_path=${bootapp_path}"
        else
            echo "\033[37;45m真机.app应用程序不存在failed \033[0m"
            exit 1
        fi
        sleep 1
         
    fi
    
}

# 列出设备列表，指定运行的模拟器
chooseDevice(){
    if $is_iphonesimulator ; then
        echo "输出模拟器列表"
        a=$(xcrun simctl list devices)
        a=${a%%iPad*}
        a=${a##* --}
        # *************观察一下，如果不对，请手动修改脚本，应该是如下格式********
        # iPhone 5s (08D37A93-299E-445F-81C9-408E9F8E65A5) (Shutdown) 
        # iPhone 6 (C7C683EE-C4B3-4E8F-82F2-117E100FA094) (Shutdown) 
        # iPhone 6 Plus (4E1A2FD6-B393-41B7-B6ED-DFE9BD611980) (Shutdown) 
        # ***************************************************************
        echo "${a}"
        echo "\033[37;45m *****************************分割线********************************** \033[0m"
        echo "可供选择的设备列表"

        OLDIFS=$IFS
        #修改默认分隔符
        IFS=$'\n'

        devicesArrTemp=($(echo $a | grep -o "iPhone [^(]*"))
        x=0
        while [ $x -lt ${#devicesArrTemp[@]} ]
        do  
            deviceInfo="${devicesArrTemp[$x]}"
            id=$(($x+1))
            echo "$id: $deviceInfo"
            let x++
        done

        # 将分隔符改回默认分隔符
        IFS=$OLDIFS

        echo "请输入选择设备的序列号："
        read selectId
        selectId=$(($selectId-1))
        simulatorID_selected=${devicesArrTemp[$selectId]}
        simulatorID_selected=$(eval echo ${simulatorID_selected})
        echo "选择的模拟器是${simulatorID_selected}"
        
    else
        echo "输出usb连接的iPhone真机的udid"
        b=$(ios-deploy -c --no-wifi)
        b=${b%% (*}
        b=${b##*Found }
        # *************真机测试时，保证iPhone手机usb链接到电脑，并且只连接了一部iPhone手机********
        device_id=${b}
        echo "已连接iPhone的udid为:${device_id}"
    fi
    
}

# 打包uni-app资源
buildUniappResource(){
    cd $project_dir
    npm run dev:app-plus
}

# zip压缩资源文件并更改后缀为.wgt
zipRenamePackage(){
    cd $uniappre_dir
    # 压缩当前目录下的所有文件到一个zip
    zip -q -r ${uni_appid}.zip *
    
    # 修改资源文件名称
    mv ${uni_appid}.zip ${uni_appid}.wgt

    # 测试 移动资源文件到宿主指定位置
    # mv ${uniappre_dir}/${uni_appid}.wgt ${uniwgt_dir}/${uni_appid}.wgt

    # 将资源包上传到服务器上
}

# 安装原生宿主项目到iOS设备
openSimulator(){
    echo "\033[37;45m 安装到指定iOS设备... \033[0m"

    if $is_iphonesimulator ; then
        # 删除项目然后重新安装再启动
        # 安装到模拟器
        echo "安装到模拟器"
        xcrun simctl boot "$simulatorID_selected"
        open -a Simulator
        xcrun simctl install booted ${bootapp_path}
        xcrun simctl launch booted ${bundle_identifier}
    else
        # 安装到真机
        echo "安装到真机"
        ios-deploy -r –i ${device_id} -b ${bootapp_path}
    fi
}

# 启动本地服务，宿主端根据服务地址下载wgt资源
startservice(){
    cd $uniappre_dir
    http-server
}

# 监测代码是否有变动
starWatch(){
    cd $project_dir
    node watchf.js
}

envionmentVariables
checkiOSApp
chooseDevice
buildUniappResource &
zipRenamePackage
openSimulator
# startservice
# starWatch
