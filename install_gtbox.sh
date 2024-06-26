#!/bin/bash

set -e

ProductName=gtbox
REPO_PFEX=george012/${ProductName}

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
GetOSType

removeCache() {
    rm -rf ./install_${ProductName}.sh
}

parse_json(){
    echo "${1//\"/}" | tr -d '\n' | tr -d '\r' | sed "s/.*$2:\([^,}]*\).*/\1/"
}

get_repo_latest_version(){
    local REMOTE_REPO_VERSION=""
    local LATEST_RELEASE_INFO=$(curl --silent https://api.github.com/repos/${REPO_PFEX}/releases/latest)
    if ! echo "$LATEST_RELEASE_INFO" | grep -q "Not Found"; then
        REMOTE_REPO_VERSION=$(parse_json "$LATEST_RELEASE_INFO" "tag_name")
    else
      return 1
    fi
    echo $REMOTE_REPO_VERSION | tr -d '\r\n'
    return 0
}

create_symlink() {
    local alibName=$1
    local aVersionStr=$2
    local prefix="lib"
    local libPath=${complate_gopath_dir}/pkg/mod/github.com/george012/${ProductName}@${aVersionStr}/libs/${alibName}

    case ${OSTYPE} in
        "Darwin"|"Linux")
            # 如果 alibName 不是以 "lib" 开头，则添加 "lib" 前缀
            [[ ${alibName} == lib* ]] || alibName="${prefix}${alibName}"

            if [ "${OSTYPE}" == "Darwin" ]; then
                sudo ln -sf ${libPath}/${alibName}.dylib /usr/local/lib/${alibName}.dylib
                sudo ln -sf /usr/local/lib/${alibName}.dylib /usr/local/lib/${alibName}_arm64.dylib
            else
                sudo ln -sf ${libPath}/${alibName}.so /lib64/${alibName}.so && sudo ldconfig
            fi
            ;;
        "Windows")
            [[ ${alibName} != lib* ]] || alibName="${alibName#lib}"
            ln -sf ${libPath}/${alibName}.dll /c/Windows/System32/${alibName}.dll
            ;;
        *)
            echo ${OSTYPE}
            ;;
    esac
}

install() {
    echo "install to "${OSTYPE}

    complate_gopath_dir=${GOPATH}
    if [ ${OSTYPE} == "Windows" ]
    then
        ago_path_dir=`echo "${GOPATH/':\\'/'/'}" | sed 's/\"//g'`
        complate_gopath_dir='/'`echo "${ago_path_dir}" | tr A-Z a-z`
        find ${complate_gopath_dir}/pkg/mod/github.com/george012 -depth -name "${ProductName}@*" -exec rm -rf {} \;
    else
        find ${complate_gopath_dir}/pkg/mod/github.com/george012 -depth -name "${ProductName}@*" -exec sudo rm -rf {} \;
    fi

    last_repo_version=$(get_repo_latest_version)

    go get -u github.com/george012/${ProductName}@${last_repo_version} \
    && {
        CustomLibs=$(ls -l ${complate_gopath_dir}/pkg/mod/github.com/george012/gtbox@${last_repo_version}/libs |awk '/^d/ {print $NF}') \
        && for alibName in ${CustomLibs}
        do
            create_symlink ${alibName} ${last_repo_version}
        done
    }

    removeCache
}

uninstall() {
    echo "uninstall with "${OSTYPE}

    complate_gopath_dir=${GOPATH}
    if [ ${OSTYPE} == "Windows" ]
    then
        ago_path_dir=`echo "${GOPATH/':\\'/'/'}" | sed 's/\"//g'`
        complate_gopath_dir='/'`echo "${ago_path_dir}" | tr A-Z a-z`
    fi
    last_repo_version=$(get_repo_latest_version)
    CustomLibs=$(ls -l ${complate_gopath_dir}/pkg/mod/github.com/george012/${ProductName}@${last_repo_version}/libs |awk '/^d/ {print $NF}') \

    for libName in ${CustomLibs}; do
        local prefix="lib"
        case ${OSTYPE} in
            "Darwin"|"Linux")
                # 如果 libName 不是以 "lib" 开头，则添加 "lib" 前缀
                [[ ${libName} == lib* ]] || libName="${prefix}${alibName}"

                if [ "${OSTYPE}" == "Darwin" ]; then
                    sudo rm -f /usr/local/lib/${libName}.dylib || echo "Failed to remove ${libName}.dylib"
                    sudo rm -f /usr/local/lib/${libName}_arm64.dylib || echo "Failed to remove ${libName}_arm64.dylib"
                else
                    sudo rm -f /lib64/${libName}.so || echo "Failed to remove ${libName}.so" && ldconfig
                fi

                ;;
            "Windows")
                [[ ${libName} != lib* ]] || libName="${libName#lib}"
                rm -f /c/Windows/System32/${libName}.dll || echo "Failed to remove ${libName}.dll"
                rm -f /c/Windows/System32/${libName}_arm64.dll || echo "Failed to remove ${libName}_arm64.dll"

                ;;
            *)
                echo ${OSTYPE}
                ;;
        esac
    done

    case ${OSTYPE} in
        "Darwin"|"Linux")
            find ${complate_gopath_dir}/pkg/mod/github.com/george012 -depth -name "${ProductName}@*" -exec sudo rm -rf {} \;
            ;;
        "Windows")
            find ${complate_gopath_dir}/pkg/mod/github.com/george012 -depth -name "${ProductName}@*" -exec rm -rf {} \;
            ;;
        *)
            echo ${OSTYPE}
            ;;
    esac

    removeCache
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
