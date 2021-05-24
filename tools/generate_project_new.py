#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright (c) 2019 - Amnon <hzmsmail.2@gmail.com>
# Usage: python generate_project_ios.py
#  if use python generate_project_ios.py -r just for restore resource, default is not!
# Desc: 生成 iOS 打包需要的资源,并准备好打包的资源
# TODO: 目前先支持打一个游戏的，后续加入脚本打包再输出多个游戏打包的
import shutil, re

import os, sys, getopt
import platform
import time



QUICK_V3_ROOT       = os.environ.get("QUICK_V3_ROOT")
COCOS_CONSOLE_ROOT  = os.environ.get("COCOS_CONSOLE_ROOT")
platformName        = platform.system()
PROJECT_ROOT        = str.replace(os.getcwd(), "tools", "")
PROJECT_ROOT        = str.replace(PROJECT_ROOT, "\\", "/")
CONST_ROOT          = PROJECT_ROOT + "/src/app/common/Const.lua"

if (platformName == "windows"):
    sys.path.append(QUICK_V3_ROOT + "quick\\bin2\\")
else:
    sys.path.append(QUICK_V3_ROOT + "/quick/bin2/")

import PackageScripts
import EncodeRes

# 需要生成的版本 Debug 5 还是 release 0
DEBUG        = 0
# 版本号
VERSION      = "1.0.0"

# 测试热更新（采用内网测试，需要修改代码）
# 同时可以调整 DEBUG，但需要保证 so 库正确
TEST_UPDATE  = 0

GAME_API_MAP = {
    "package"     : "com.app.clearcache",
    "versionCode" : 1,
}

def readFile(file_name):
    content = ""
    file_object = open(file_name,'rU')
    try:
        for line in file_object:
            content = content + line
    finally:
         file_object.close()
    return content

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

# 创建目录
def createDirs(dirPath, isAbsolute = False):
    if (not isAbsolute):
        dirPath = PROJECT_ROOT + dirPath
    if not os.path.exists(dirPath):
        os.makedirs(dirPath)

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

# 把字符串写入文件
def writeToFile(fileName, str):
    file = open(fileName, "wb")
    file.write(str)
    file.close()

def init(bkPath):
    # 还原资源和代码
    restoreRes(bkPath)



def restoreRes(fromPath):
    removeFiles(fromPath, True)
    createDirs(fromPath, True)

# 修改Const.lua文件中的域名
def modifyConstLua():
    print("修改 Const.lua 文件中的版本号")

    content = readFile(CONST_ROOT)
    pattern = re.compile(r'Const\.DEFAULT_GAME_VERSION = "[0-9\\.:]+";')
    content = re.sub(pattern, "Const.DEFAULT_GAME_VERSION = \"" + VERSION + "\";", content)

    writeToFile(CONST_ROOT, content)

def modifyConfig():
    configFile = PROJECT_ROOT + "src/config.lua"
    f = open(configFile, "r")
    newStr = ""
    curTime = time.strftime("%Y%m%d_%H%M%S", time.localtime())
    for eachConfig in f:
        if re.search("DEBUG = \d", eachConfig):
            eachConfig = re.sub("DEBUG = \d", "DEBUG = " + str(DEBUG), eachConfig)
            newStr += eachConfig
        elif re.search("BUILD_TIME = \"\w+\"", eachConfig) and DEBUG != 0:
            eachConfig = re.sub("BUILD_TIME = \"\w+\"", "BUILD_TIME = \"" + curTime + "\"", eachConfig)
            newStr += eachConfig
        else:
            newStr += eachConfig
    wopen = open(configFile,"w")
    wopen.write(newStr)
    f.close()
    wopen.close()
    print "modified finish"
    return curTime

def moveRootSrcRes(fromPath):
    copytree(PROJECT_ROOT + "/res", fromPath + "/res")
    copytree(PROJECT_ROOT + "/src", fromPath + "/src")

# 修改 so 文件
def modifySoFile(androidPath):
    soList = ["armeabi", "arm64-v8a"]
    buildPath = DEBUG == 0 and "release" or "debug"
    bkPath = androidPath + "so_bk" + os.sep + buildPath + os.sep
    soPath = androidPath + "libcocos2dx/src/main/libcocos2dx/"
    for abiPath in soList:
        removeFiles(soPath + abiPath, True)
        print(bkPath + abiPath)
        if (os.path.exists(bkPath + abiPath)):
            copytree(bkPath + abiPath, soPath + abiPath)

# 修改 gradle 主要修改 versionCode 和 version
def modifyBuildGradle(androidPath, versionCode):
    gradleFile = androidPath + "build.gradle"
    content = readFile(gradleFile)
    patternCode = re.compile(r'versionCode = \d+')
    patternVersion = re.compile(r'versionName = "[a-z0-9A-Z/\\.]+\"')
    content = re.sub(patternCode, "versionCode = " + str(versionCode), content)
    content = re.sub(patternVersion, "versionName = \"" + VERSION + "\"", content)

    writeToFile(gradleFile, content)

def modifySettingGradle(androidPath, moduleName):
    settingStr = "include ':%s', ':libcocos2dx'"%(moduleName)
    gradleFile = androidPath + "settings.gradle"
    content = readFile(gradleFile)
    content = settingStr
    writeToFile(gradleFile, content)

# 生成 Android 包
def generateAndroidPackage(androidPath, packageName, isAab, moduleName, curTime, versionCode):
    buildVar       = " clean assembleDebug"
    prefix         = DEBUG == 0 and ".apk" or (curTime + "_test.apk")
    outputFileName = "v" + VERSION + "_" + str(versionCode) + "_" + packageName + prefix
    packagePath    = androidPath + "packages/"
    if (os.path.exists(androidPath)):
        os.chdir(androidPath)
    moduleName = moduleName and moduleName or "app"
    outputPath = "./%s/build/outputs/apk/debug/%s-debug.apk"%(moduleName, moduleName)
    toPath     = "%spackages/%s"%(androidPath, outputFileName)
    if (DEBUG == 0):
        buildVar   = isAab and " clean bundleRelease" or " clean assembleRelease"
        outputPath = isAab and "./%s/build/outputs/renamedBundle/"%(moduleName) or "./%s/build/outputs/apk/release/%s-release.apk"%(moduleName, moduleName)
        toPath     = isAab and packagePath or toPath
    gradleFile  = "gradlew%s"
    excuteCMD   = ""
    if (platformName == "Windows"):
        gradleFile = str.replace(gradleFile%(".bat"), "/", os.sep)
    else:
        gradleFile = gradleFile%("")
        excuteCMD = "./"
    if not os.path.exists(androidPath + gradleFile):
        print("lack of " + gradleFile + ",Goto generate aab manual")
        return
    os.system(excuteCMD + gradleFile + buildVar)
    print("Generate android package success!")
    if (os.path.exists(toPath)):
        removeFiles(toPath, True)
    if (os.path.isfile(outputPath)):
        createDirs(packagePath, True)
        copyFile(outputPath, toPath)
    else:
        createDirs(toPath, True)
        copytree(outputPath, toPath)
    if (platformName == "Windows"):
        print(packagePath)
        os.startfile(packagePath)
    else:
        os.system("open " + packagePath)

# encodeRes
def encodeRes(filePath):
    if (EncodeRes):
        orgPath     = filePath
        if (not os.path.exists(orgPath)):
            print("res is nil")
            return
        EncodeRes.encodeRes(orgPath, "bigfoot", "bf")
        removeFiles(orgPath + "/res_bk", True)
    print("encode res success")

def encodeSrcZip(filePath, bit):
    orgPath     = filePath + "/src/"
    dstPath     = filePath + "/res/game.zip"
    print(orgPath, dstPath)
    if (not os.path.exists(orgPath)):
        return
    bit = bit and bit or 32
    if (PackageScripts):
        PackageScripts.packageScript(filePath, "game", str(bit))
        print("encode src success")
        return
    if (bit == 64):
        dstPath = BUILD_TEMP_PATH + "res/game64.zip"
    excuteCMD   = "bat "
    encryptFile = "%s/quick/bin/compile_scripts."%(QUICK_V3_ROOT)
    encryptCMD  = "%s -i %s -o %s -e xxtea_zip -ek bigfoot -es bf -b %d"
    if (platformName == "Windows"):
        encryptFile = str.replace(encryptFile, "/", os.sep) + "bat"
        encryptSrc  = encryptCMD%(encryptFile, orgPath, dstPath, bit)
        excuteCMD   = ""
    else:
        encryptFile = encryptFile + "sh"
        encryptSrc = encryptCMD%(encryptFile, orgPath, dstPath, bit)
        excuteCMD = "sh "

    if os.path.exists(encryptFile):
        os.system(excuteCMD + encryptSrc)
    else:
        print("lack of " + encryptSrc)
    print("encode src to zip success")

def encryptFiles(filePath):
    if DEBUG == 0:
        encodeRes(filePath)
        encodeSrcZip(filePath, 32)
        encodeSrcZip(filePath, 64)

def copyFile(src, dst):
    shutil.copy2(src, dst)

def main(argv):
    isRestore = False
    try:
        # : 表示必填
        opts, args = getopt.getopt(argv,"hr",[""])
    except getopt.GetoptError:
        print 'generate_project_ios.py -h'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'you can use python generate_project_ios.py -r to restore the resource'
            sys.exit()
        elif opt == '-r':
            isRestore = True
    bkPath = PROJECT_ROOT + "org_resources"

    init(bkPath)
    modifyConstLua()
    modifyConfig()

    moveRootSrcRes(bkPath)
    encryptFiles(bkPath)

    #拷贝到项目路径下
    androidPath = "%sframeworks/runtime-src/proj.android_studio/"%(PROJECT_ROOT)
    moduleName  = "app"
    toPath      = "%s%s/src/main/assets/"%(androidPath, moduleName)
    if (os.path.exists(toPath)):
        removeFiles(toPath, True)

    if DEBUG == 0:
        fromPath    = bkPath + "/res"
        toPath      = toPath + "res"
        copytree(fromPath, toPath)

    else:
        copytree(bkPath, toPath)

    package     = GAME_API_MAP["package"]
    versionCode = GAME_API_MAP["versionCode"]

    curTime     = time.strftime("%Y%m%d_%H%M%S", time.localtime())

    modifySoFile(androidPath)
    modifyBuildGradle(androidPath, versionCode)
    modifySettingGradle(androidPath, moduleName)
    generateAndroidPackage(androidPath, package, False, moduleName, curTime, versionCode)
    print("SUCCESS")

if __name__ == '__main__':
    main(sys.argv[1:])
