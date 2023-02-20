#!/bin/bash
ProductName=gtbox
#CustomLibs="gtgo,otherlib1,otherlib2"
CustomLibs=$(ls -l ./libs|awk '/^d/ {print $NF}')
echo $CustomLibs

OSTYPE="Unknown"
GetOSType(){
    uNames=`uname -s`
    osName=${uNames: 0: 4}
    if [ "$osName" == "Darw" ] # Darwin
    then
        OSTYPE="Darwin"
    elif [ "$osName" == "Linu" ] # Linux
    then
        OSTYPE="Linux"
    elif [ "$osName" == "MING" ] # MINGW, windows, git-bash
    then
        OSTYPE="Windows"
    else
        OSTYPE="Unknown"
    fi
}

removeCache() {
    rm -rf ./${ProductName}_version.go
    rm -rf ./install_${ProductName}.sh
}

install() {
    uninstall

    go get -u github.com/george012/${ProductName}@latest

    GetOSType
    echo ${OSTYPE}
    if [ ${OSTYPE} == "Windows" ]
    then
        ago_path_dir=`echo "${GOPATH/':\\'/'/'}" | sed 's/\"//g'`
        complate_gopath_dir='/'`echo "${ago_path_dir}" | tr A-Z a-z`
        find $complate_gopath_dir/pkg/mod/github.com/george012  -name "${ProductName}@*" -exec rm -rf {} \;
    else
        find ${GOPATH}/pkg/mod/github.com/george012  -name "${ProductName}@*" -exec rm -rf {} \;
    fi

    wget --no-check-certificate https://raw.githubusercontent.com/george012/${ProductName}/master/version.go -O ${ProductName}_version.go
    aVersion=`cat ./gtbox_version.go | grep -n "const VERSION =" | awk -F ":" '{print $2}'`
    aVersionString=`echo "${aVersion/'const VERSION = '/}" | sed 's/\"//g'`
    aVersionNo=`echo "${aVersionString}" | awk -F "v" '{print $2}'`

    for alibName in ${CustomLibs}
    do
        if [ ${OSTYPE} == "Darwin" ] # Darwin
        then
            srcPWD=`pwd`
            echo "handle Lib = "${alibName}
    #        cd ${GOPATH}/pkg/mod/github.com/george012/gtbox@v${aVersionNo} && /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/install_name_tool -add_rpath ../gtbox@v${aVersionNo} ${produckName} && cd ${srcPWD}
            ln -s ${GOPATH}/pkg/mod/github.com/george012/gtbox@v$aVersionNo/libs/${alibName}/lib$libName.dylib /usr/local/lib/lib${alibName}.dylib
            ln -s /usr/local/lib/lib${alibName}.dylib /usr/local/lib/lib${alibName}_arm64.dylib
        elif [ ${OSTYPE} == "Linux" ] # Linux
        then
            ln -s ${GOPATH}/pkg/mod/github.com/george012/${ProductName}@v$aVersionNo/libs/${alibName}/lib${alibName}.so /lib64/lib${alibName}.so && ldconfig
        elif [ ${OSTYPE} == "Windows" ] # MINGW, windows, git-bash
        then
            ln -s ${GOPATH}/pkg/mod/github.com/george012/${ProductName}@v$aVersionNo/libs/${alibName}/${alibName}.dll /c/Windows/System32/${alibName}.dll
        else
            echo ${OSTYPE}
        fi
    done

#    removeCache
}

uninstall() {
    GetOSType
    echo ${OSTYPE}
    for libName in ${CustomLibs}
    do
        if [ ${OSTYPE} == "Darwin" ] # Darwin
        then
            rm -rf /usr/local/lib/lib${libName}_arm64.dylib
            rm -rf /usr/local/lib/lib${libName}.dylib
        elif [ ${OSTYPE} == "Linux" ] # Linux
        then
            rm -rf /lib64/lib${libName}.so
        elif [ ${OSTYPE} == "Windows" ] # MINGW, windows, git-bash
        then
            rm -rf c:/Windows/System32/${libName}.dll
        else
            echo ${OSTYPE}
        fi
    done

    find ${GOPATH}/pkg/mod/github.com/george012  -name "${ProductName}@*" -exec rm -rf {} \;
}


echo "============================ ${ProductName} ============================"
echo "  1、安装 ${ProductName}"
echo "  2、卸载 ${ProductName}"
echo "======================================================================"
read -p "$(echo -e "请选择[1-2]：")" choose
case $choose in
1)
    install
    ;;
2)
    uninstall
    ;;
*)
    echo "输入错误，请重新输入！"
    ;;
esac
