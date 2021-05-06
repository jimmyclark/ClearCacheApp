#!/usr/bin/env python
# -*- coding: utf-8 -*-

# 目标API
DEFINITE_API  = "0x01007300"
# 参照API
DEPENDENT_API = "0x0100B200"

import os,sys,platform,re,string
import shutil

# 工程路径
PROJECT_ROOT  = str.replace(os.getcwd(), "tools", "")
PROJECT_ROOT  = str.replace(PROJECT_ROOT, "\\", "/")

PLATFORM      = platform.system()

# 列出dir下所有文件目录结构，返回至resultFileList中
def listAllFiles(dir, resultFileList):
    for item in os.listdir(dir):
        if os.path.isfile(dir + "/" + item):
            resultFileList.append(dir + "/" + item)

        else:
            listAllFiles(dir + "/" + item,resultFileList)

# 过滤需要被过滤的文件
def filterNeedDiffer(result, needKey, filterResult, extra):
    for item in result:
        if needKey in item:
            needFilter = item[0:string.index(item,needKey)]
            if "lua" in needKey:
                if "0x0" in needFilter:
                    needFilter = needFilter[0: string.index(needFilter, "0x0")]

                else:
                    needFilter = needFilter

            else:
                needFilter = needFilter + "/" + extra

            if needFilter not in filterResult:
                filterResult.append(needFilter)

def copytree(src, dst, symlinks=False, ignore=None):
    if not os.path.exists(dst):
        os.makedirs(dst)
    for item in os.listdir(src):
        s = os.path.join(src, item)
        d = os.path.join(dst, item)
        if os.path.isdir(s):
            copytree(s, d, symlinks, ignore)
        else:
            if not os.path.exists(d) or os.stat(s).st_mtime - os.stat(d).st_mtime > 1:
                shutil.copy2(s, d)

def copyFile(src, dst):
    shutil.copy2(src, dst)

# 删除文件/文件夹
def removeFiles(filePath, isAbsolute = False):
    removeFiles = []
    if isAbsolute == False:
        filePath = PROJECT_ROOT + filePath
    if (os.path.exists(filePath)):
        if (os.path.isfile(filePath)):
            os.remove(filePath)
            removeFiles.append(filePath)
        else:
            shutil.rmtree(filePath)
    return removeFiles

def readFile(file_name):
    content = ""
    file_object = open(file_name,'rU')
    try:
        for line in file_object:
            content = content + line
    finally:
         file_object.close()
    return content

# 把字符串写入文件
def writeToFile(fileName, str):
    file = open(fileName, "wb")
    file.write(str)
    file.close()

# 替换Const.lua中的defaultAPI
def replaceConstAPI():
    ConstLuaFile = PROJECT_ROOT + "src/app/common/Const.lua"
    content = readFile(ConstLuaFile)
    strInfo = re.compile('Const.defaultApi = \"[0-9A-Za-z]+\"')
    content = re.sub(strInfo,"Const.defaultApi = \"" + DEFINITE_API + "\"",content)

def main(argv):
    processPINTU()
    processRES()
    processSRC()
    replaceConstAPI()

def processPINTU():
    print("is processing the 'PINTU' folder...")
    pinTuResult = []
    filterPinTuResult = []
    needCopyPinTuResultList = []

    # 先将PinTu 文件目录下所有文件整成列表
    listAllFiles(PROJECT_ROOT + "PinTu",pinTuResult)

    # 找到相关资源目录/0/的目录
    filterNeedDiffer(pinTuResult, "/" + DEPENDENT_API + "/",filterPinTuResult, "")
    # 找到相关资源目录/r0/的目录
    filterNeedDiffer(pinTuResult, "/r" + DEPENDENT_API + "/",filterPinTuResult, "r")

    # 寻找PinTu文件夹目录下是否含有对应目录文件夹
    for pintuDir in filterPinTuResult:
        if "/r" in pintuDir:
            origin = pintuDir +  DEPENDENT_API
            direct = pintuDir + DEFINITE_API
        else:
            origin = pintuDir + "/" + DEPENDENT_API
            direct = pintuDir + "/" + DEFINITE_API

        if os.path.exists(origin):
            array = {}
            array["origin"] = origin
            array["defin"] = direct
            needCopyPinTuResultList.append(array)

    index = 0
    tpsFiles = []
    for item in needCopyPinTuResultList:
        if os.path.exists(item["defin"]):
            print("removing" , item["defin"])
            removeFiles(item["defin"],True)

        index = index + 1
        copytree(item["origin"], item["defin"])

        tempFiles = []
        listAllFiles(item["defin"],tempFiles)
        for temp in tempFiles:
            if ".tps" in temp:
                content = readFile(temp)

                content = content.replace(DEPENDENT_API,DEFINITE_API)
                writeToFile(temp,content)
                tpsFiles.append(temp)

    print "PinTu is procceed.. totally modified " + bytes(index) + " files to " + DEFINITE_API

def processRES():
    print("is processing the 'res' folder...")
    resResult = []
    filterResResult = []
    needCopyResResultList = []

    # 先将 res 目录中所有文件整成列表
    listAllFiles(PROJECT_ROOT + "res",resResult)

    # 找到相关资源目录/0/的目录
    filterNeedDiffer(resResult, "/" + DEPENDENT_API + "/",filterResResult, "")
    # 找到相关资源目录/r0/的目录
    filterNeedDiffer(resResult, "/r" + DEPENDENT_API + "/",filterResResult, "r")

    # 寻找res文件夹目录下是否含有对应目录文件夹
    for resDir in filterResResult:
        if "/r" in resDir:
            origin = resDir +  DEPENDENT_API
            direct = resDir + DEFINITE_API
        else:
            origin = resDir + "/" + DEPENDENT_API
            direct = resDir + "/" + DEFINITE_API

        if os.path.exists(origin):
            array = {}
            array["origin"] = origin
            array["defin"] = direct
            needCopyResResultList.append(array)

    index = 0
    for item in needCopyResResultList:
        if os.path.exists(item["defin"]):
            print("removing" , item["defin"])
            removeFiles(item["defin"],True)

        index = index + 1
        copytree(item["origin"], item["defin"])

    print "res is procceed.. totally modified " + bytes(index) + " files to " + DEFINITE_API

def processSRC():
    print("is processing the 'src' folder...")

    srcResult = []
    filterSrcResult = []
    filterLuaSrcResult = []
    needCopySrcResultList = []

    # 先替换图片目录，目录
    listAllFiles(PROJECT_ROOT + "src",srcResult)

    # 先找到目录以API打头的文件
    filterNeedDiffer(srcResult, "/" + DEPENDENT_API + "/",filterSrcResult, "")
    # 再找到以API为文件名的.Lua
    filterNeedDiffer(srcResult, DEPENDENT_API + ".lua",filterLuaSrcResult, "")

    # 封装需要拷贝的文件夹目录
    for srcDir in filterSrcResult:
        origin = srcDir + DEPENDENT_API
        direct = srcDir + DEFINITE_API

        if os.path.exists(origin):
            array = {}
            array["origin"] = origin
            array["defin"] = direct
            needCopySrcResultList.append(array)

    # 封装需要拷贝的文件
    for src in filterLuaSrcResult:
        origin = src + DEPENDENT_API + ".lua"
        direct = src + DEFINITE_API + ".lua"
        if os.path.exists(origin):
            array = {}
            array["origin"] = origin
            array["defin"] = direct
            needCopySrcResultList.append(array)

    index = 0
    for item in needCopySrcResultList:
        if os.path.exists(item["defin"]):
            print("removing" , item["defin"])
            removeFiles(item["defin"],True)

        index = index + 1
        if os.path.isdir(item["origin"]):
            copytree(item["origin"], item["defin"])

        else:
            copyFile(item["origin"], item["defin"])

    for item in filterLuaSrcResult:
        content = readFile(item + DEFINITE_API + ".lua")
        if DEPENDENT_API != "0":
            content = str.replace(content, DEPENDENT_API , DEFINITE_API)

        writeToFile(item + DEFINITE_API + ".lua",content)

    print "src is procceed.. totally modified " + bytes(index) + " files to " + DEFINITE_API

    if DEPENDENT_API == "0":
        print("You need modify the src API manually because of your dependent API is 0.")

    else:
        print("start modify the directory which contains dependent API.")
        #遍历目录文件中的代码文件，替换目标文件含有dependent API的

        index = 0
        for item in needCopySrcResultList:
            if os.path.isdir(item["defin"]):
                tempResult = []
                listAllFiles(item["defin"],tempResult)
                for tempItem in tempResult:
                    content = readFile(tempItem)
                    content = str.replace(content, DEPENDENT_API , DEFINITE_API)
                    writeToFile(tempItem,content)
                    index = index + 1
        print "modified is proceed... total modified "  + bytes(index) + " files to " + DEFINITE_API

if __name__ == '__main__':
    main(sys.argv[1:])