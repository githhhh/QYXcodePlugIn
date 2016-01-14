#! /bin/bash
SRC_HOME=`pwd`

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
   cp ${SRC_HOME}/formate_cfg/$cfFileName $cfFilePath
   cp ${SRC_HOME}/formate_cfg/$ufFileName $ufFilePath
}

#bulide Release
function bulide_Release(){
   cd $SRC_HOME

   xcodebuild  -configuration Release  -workspace QYXcodePlugIn.xcworkspace -scheme ShortcutRecorder.framework || exit

   xcodebuild  -configuration Release  -workspace QYXcodePlugIn.xcworkspace -scheme PTHotKey.framework || exit

   xcodebuild  -configuration Release  -workspace QYXcodePlugIn.xcworkspace -scheme QYXcodePlugIn || exit
}


#call function

#安装format
install_Format
#安装代码片段
codeSnippetFun
#安装代码模板
codeTemplateFun
#安装插件
bulide_Release



#重启xcode
pkill -9 -x Xcode
sleep 0.2
open /Applications/Xcode.app

echo " 🎉  🎉  🎉  😉  😉  😉   Enjoy.Go!   🚀  🚀  🚀  🍻  🍻  🍻  "
