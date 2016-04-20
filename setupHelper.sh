#! /bin/bash
SRC_HOME=`pwd`
#外部传入参数
paramterFromOut=$1

#镜像代码片段
function codeSnippetFun(){
   sniPath='Library/Developer/Xcode/UserData/CodeSnippets'
   cd ~
   curSniFullPath=$(pwd)/$sniPath

   if [ ! -x "$curSniFullPath" ];then
        mkdir -p $curSniFullPath
   fi

   cd $SRC_HOME
   #强行镜像
   ln -sf  $curSniFullPath  ${SRC_HOME}/CodeSnippets
}


#镜像代码模板
function codeTemplateFun(){
    #改IFS 为 \n ,要不无法创建带空格的目录名哦
    IFS=$'\n'
    templatePath='Library/Developer/Xcode/Templates/File Templates/QYFileTemplate'
    cd ~
    curTemplatePath=$(pwd)/$templatePath

    if [ ! -x "$curTemplatePath" ];then
        mkdir -p $curTemplatePath
    fi

    #切到项目目录
    cd $SRC_HOME
    #强行镜像
    ln -sf ${SRC_HOME}/QYFileTemplate $curTemplatePath
}

#安装格式化组件
function install_Format(){
   brew install clang-format || exit
   brew install uncrustify || exit

   cfFileName='.clang-format'
   ufFileName='.uncrustify.cfg'
   #cfg path
   cd ~
   cfFilePath=$(pwd)/$cfFileName
   ufFilePath=$(pwd)/$ufFileName
   #copy
   cd $SRC_HOME
   cp ${SRC_HOME}/Formate_cfg/$cfFileName $cfFilePath
   cp ${SRC_HOME}/Formate_cfg/$ufFileName $ufFilePath
}

#updatePlist
function updatePlist(){
    cd $SRC_HOME

    #plist name
    plist="QYXcodePlugIn-Info.plist"

    #finde plist file path
    for plistPath in `find ${SRC_HOME} -name "$plist" -print`
    do
        plist=${plistPath}
        break
    done

    #读取
    plugInGitPath=`/usr/libexec/PlistBuddy -c "Print :QYXcodePlugInGitPath" "$plist"`

    #是否存在
    if [ -z "$plugInGitPath" ];
    then

        #不存在
        plugInGitPath=${SRC_HOME}
        /usr/libexec/PlistBuddy -c "Add :QYXcodePlugInGitPath string $plugInGitPath@@$plist" "$plist"

    else
        #存在
        /usr/libexec/PlistBuddy -c "Delete :QYXcodePlugInGitPath" "$plist"

    fi

}

#bulide Release
function bulide_Release(){
   cd $SRC_HOME

   xcodebuild  -configuration Release  -workspace QYXcodePlugIn.xcworkspace -scheme ShortcutRecorder.framework || exit

   xcodebuild  -configuration Release  -workspace QYXcodePlugIn.xcworkspace -scheme PTHotKey.framework || exit

   xcodebuild  -configuration Release  -workspace QYXcodePlugIn.xcworkspace -scheme QYXcodePlugIn || exit

}


#call Function

#安装format
install_Format
##安装代码片段
codeSnippetFun
##安装代码模板
codeTemplateFun
#写入工程路径
updatePlist
#安装插件
bulide_Release

#fix 升级XCode 没有用
find ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -name Info.plist -maxdepth 3 | xargs -I{} defaults write {} DVTPlugInCompatibilityUUIDs -array-add `defaults read /Applications/Xcode.app/Contents/Info.plist DVTPlugInCompatibilityUUID`

#判断是否传入外部参数（是否更新）
if [ -z "$paramterFromOut" ];
then
    #重启XCode
    pkill -9 -x Xcode
    #fix LSOpenURLsWithRole() failed with error on OSX Yosemite
    sleep 0.5
    open /Applications/Xcode.app
else
    #存在
    if [ "$paramterFromOut" == "up" ]
    then
        sleep 0.5
    fi
fi

#编译成功,清理plist
updatePlist

echo " 🎉  🎉  🎉  😉  😉  😉   Enjoy.Go!   🚀  🚀  🚀  🍻  🍻  🍻  "

