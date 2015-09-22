#! /bin/bash

#安装代码片段
function codeSnippetFun(){
   mv ~/Library/Developer/Xcode/UserData/CodeSnippets ~/Library/Developer/Xcode/UserData/CodeSnippets.backup

   SRC_HOME=`pwd`
   ln -s ${SRC_HOME}/CodeSnippets ~/Library/Developer/Xcode/UserData/CodeSnippets
}


#安装代码模板
function codeTemplateFun(){
    #改IFS 为 \n ,要不无法创建带空格的目录名哦
    IFS=$'\n'
    path='Library/Developer/Xcode/Templates/File Templates'
    SRC_HOME=`pwd`
    cd ~
    curPath=$(pwd)/$path

    if [ ! -x "$curPath" ];then
        mkdir -p $curPath
    fi 

    cd $SRC_HOME

    #清空
    rm -rf ~/Library/Developer/Xcode/Templates/File\ Templates 
    ln -s ${SRC_HOME}/QYFileTemplate ~/Library/Developer/Xcode/Templates/File\ Templates
}


#call fun

#安装代码片段
codeSnippetFun
#安装代码模板
codeTemplateFun

echo "==done="
