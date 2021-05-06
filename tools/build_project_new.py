#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright (c) 2017 - Amnon <hzmsmail.2@gmail.com>
# Usage: python build_project.py

import re
import shutil
import os,sys
import json
import md5
import platform
import zipfile
import time

platformName       = platform.system()
QUICK_V3_ROOT      = os.environ.get("QUICK_V3_ROOT")
if (platformName == "windows"):
    sys.path.append(QUICK_V3_ROOT + "quick\\bin2\\")
else:
    sys.path.append(QUICK_V3_ROOT + "/quick/bin2/")
import PackageScripts
import EncodeRes

PROJECT_ROOT       = str.replace(os.getcwd(), "tools", "")
COCOS_CONSOLE_ROOT = os.environ.get("COCOS_CONSOLE_ROOT")
# to add global var begin
GAME_VERSION       = "1.8.0"
TEST_UPDATE        = 0
UPDATE_VERSION     = 0
DEBUG              = 0
IS_ANDROID         = 1
TEST_URL           = "http://192.168.100.107:8089/"
NORMAL_URL         = "http://ud.bfgamesth.com/"
NORMAL_CND_URL     = "http://up.bfgamesth.com/"

HALLTH_PATH        = "build/" + GAME_VERSION + "/"

if (DEBUG != 0):
    MY_HALL_NET     = TEST_URL + HALLTH_PATH
    MY_CND_HALL_NET = MY_HALL_NET
else:
    MY_HALL_NET     = NORMAL_URL + HALLTH_PATH
    MY_CND_HALL_NET = NORMAL_CND_URL + HALLTH_PATH

# 游戏 API 映射表
# value 对应 subVer 、 platform 和 是否跳过生成 manifest
GAME_API_MAP = {
    # "0x01007300" : [0, 0], # king iOS subVer, isAndroid
    # "0x0100A200" : [0, 1], # dummy新
    "0x0100B200" : [0, 1, 0], # king新
    # "0x0100C200" : [0, 1], # 骰子新
    # "0x0100D200" : [0, 1], # dummy新2
}
# to add global var end

##### common function begin #####
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

# 删除空文件夹
def deleteGapDir(filePath):
    for dirpath, dirnames, files in os.walk(filePath, topdown=False):
        if not os.listdir(dirpath):
            os.rmdir(dirpath)

# 获取文件 md5 值
def getFileMd5(fileName):
    tempFile = open(fileName, "rb").read()
    m = md5.new(tempFile)
    return m.hexdigest()

# 获取文件大小 单位为 KB
def getFileSize(filePath):
    filePath = unicode(filePath, 'utf8')
    fsize = os.path.getsize(filePath)
    fsize = fsize / float(1024)
    return round(fsize, 2)

# 获取文件夹下的所有文件
def getFiles(filePath):
    fileList = []
    for files in os.listdir(filePath):
        path = os.path.join(filePath, files)
        if os.path.isfile(path):
            fileList.append(path)
        if os.path.isdir(path):
            tempFileList = getFiles(path)
            for tempFile in tempFileList:
                fileList.append(tempFile)
    return fileList

# 获取指定文件列表下文件的 md5
def getFileMapMd5(fileMap, replacePath):
    fileMd5Map = {}
    fileList = []
    for filePath in fileMap:
        tempFileList = getFiles(filePath)
        fileList     = list(set(fileList).union(set(tempFileList)))
    for file in fileList:
        tempKey = file.replace(replacePath, "")
        if (os.path.splitext(tempKey)[-1] == ".zip"):
            print(tempKey)
            isCompressed = True
        else:
            isCompressed = False
        fileMd5Map[tempKey.replace("\\", "/")] = {
            "md5"  : getFileMd5(file),
            "size" : getFileSize(file),
            "compressed" : isCompressed
        }
    return fileMd5Map

# 读取文件内容
def readFile(fileName):
    content = ""
    file_object = open(fileName,'rU')
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

# 格式化 json 字符串
def formatJsonData(json_data):
    return json.dumps(json.loads(json_data), indent=4, sort_keys=False, ensure_ascii=False)

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

# 打包目录为 zip 文件（未压缩）
def makeZip(source_dir, output_filename):
    zipf = zipfile.ZipFile(output_filename, 'w')
    pre_len = len(os.path.dirname(source_dir))
    for parent, dirnames, filenames in os.walk(source_dir):
        for filename in filenames:
            pathfile = os.path.join(parent, filename)
            arcname = pathfile[pre_len:].strip(os.path.sep)     #相对路径
            zipf.write(pathfile, arcname)
    zipf.close()

##### common function end #####
# remove the cache folders
def removeCachedFolder():
    createDirs("build")
    if SUB_VER == 0:
        removeFiles("build/publish")
    else:
        removeFiles("build/remote")
    if (os.path.exists(PROJECT_ROOT + "build/temp")):
        removeFiles("build/temp")
    createDirs("build/temp")

# modify the config.lua
def modifyConfig(buildType):
    configFile = PROJECT_ROOT + "src/config.lua"
    f = open(configFile, "r")
    newStr = ""
    curTime = time.strftime("%Y%m%d_%H%M%S", time.localtime())
    for eachConfig in f:
        if re.search("DEBUG = \d", eachConfig):
            eachConfig = re.sub("DEBUG = \d", "DEBUG = " + str(buildType), eachConfig)
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

# encodeRes
def encodeRes():
    if (EncodeRes):
        orgPath     = BUILD_TEMP_PATH + "res"
        if (not os.path.exists(orgPath)):
            print("res is nil")
            return
        EncodeRes.encodeRes(BUILD_TEMP_PATH, "bigfoot", "bf")
        removeFiles(BUILD_TEMP_PATH + "res_bk", True)
        print("encode res success")
        return
    orgPath     = BUILD_TEMP_PATH + "res"
    dstPath     = BUILD_TEMP_PATH + "resNew"
    if (not os.path.exists(orgPath)):
        return
    excuteCMD   = "bat "
    encryptFile = "%s/quick/bin/encrypt_res."%(QUICK_V3_ROOT)
    encodeCMD   = "%s -i %s -o %s -es bigfoot -ek bf"
    if (platformName == "Windows"):
        encryptFile = str.replace(encryptFile, "/", os.sep) + "bat"
        encodeRes = encodeCMD%(encryptFile, orgPath, dstPath)
        excuteCMD = ""
    else:
        encryptFile = encryptFile + "sh"
        encodeRes = encodeCMD%(encryptFile, orgPath, dstPath)
        excuteCMD = "sh "

    if os.path.exists(encryptFile):
        os.system(excuteCMD + encodeRes)
        if (os.path.exists(dstPath)):
            removeFiles(orgPath + os.sep, True)
            shutil.move(dstPath, orgPath)
    else:
        print("lack of " + encodeRes)
    print("encode res success")

# encodeSrc
def encodeSrc():
    orgPath     = BUILD_TEMP_PATH + "src/"
    dstPath     = BUILD_TEMP_PATH + "srcNew/"
    if (not os.path.exists(orgPath)):
        return
    excuteCMD   = "cocos"
    excryptFile = ""
    encryptCMD  = "luacompile -s %s -d %s -e -k bf -b bigfoot --disable-compile"%(orgPath, dstPath)
    if (platformName == "Windows" or platformName == "Unix"):
        encodeStr = "%s %s"%(excuteCMD, encryptCMD)
        os.popen(encodeStr)
    else:
        excuteCMD = "python"
        encryptFile = "%s/cocos.py"%(COCOS_CONSOLE_ROOT)
        encodeStr = "%s %s %s"%(excuteCMD, encryptFile, encryptCMD)
        os.system(encodeStr)
    if (os.path.exists(dstPath)):
        removeFiles(orgPath, True)
        shutil.move(dstPath, orgPath)
    print("encode src success")


# encodeSrcZip
def encodeSrcZip(bit):
    orgPath     = BUILD_TEMP_PATH + "src/"
    dstPath     = BUILD_TEMP_PATH + "res/game.zip"
    if (not os.path.exists(orgPath)):
        return
    bit = bit and bit or 32
    if (PackageScripts):
        PackageScripts.packageScript(BUILD_TEMP_PATH, "game", str(bit))
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

# 准备好需要处理的资源和代码
def perpareSources():
    # createDirs("build")
    orgRes = PROJECT_ROOT + "res"
    dstRes = PROJECT_ROOT + "build/temp/res"
    shutil.copytree(orgRes, dstRes)

    orgSrc = PROJECT_ROOT + "src"
    dstSrc = PROJECT_ROOT + "build/temp/src"
    shutil.copytree(orgSrc, dstSrc)

# 根据平台删除文件
def removeFileWithPlatform(prefixPath, isAndroid = 1):
    # 发布 Android 需要删除的文件列表
    iosFileList = [
        "res/sounds/ios",
        "res/image/ios",
        "src/app/ios",
    ]

    # 发布 iOS 版本需要删除的文件列表
    androidFileList = [
        "res/sounds/android",
        "res/image/android",
        "src/app/android",
    ]
    removeFileList = iosFileList
    if (isAndroid == 0):
        removeFileList = androidFileList
    for dirPath in removeFileList:
        removeFiles(prefixPath + dirPath, True)

# 删除 test 相关的文件
def removeFilesWithTest(prefixPath):
    removeFileList = [
        "res/test",
        "src/app/test"
    ]
    # print("removeFilesWithTest prefixPath = ", prefixPath)
    for dirPath in removeFileList:
        removeFiles(prefixPath + dirPath, True)

# 删除由操作系统创建的缓存文件
def removeFileCreatedBySystem(prefixPath):
    fileList = getFiles(prefixPath)
    for fileName in fileList:
        if (".DS_Store" in fileName or "Thumbs.db" in fileName):
            removeFiles(fileName, True)

## add for find cur api files begin
# 查找指定目录下对应规则的文件
def getMatchFileList(fileList, prefixPath, gameAPI, matchParam):
    resultList  = []
    matchList   = []
    noMatchList = []
    # print("getMatchFileList begin")
    if (not matchParam):
        return resultList
    # 查找文件夹是否包含有对应 API 的文件
    for fileName in fileList:
        # print(fileName)
        newFileName = fileName.replace(prefixPath, "")
        if (gameAPI in newFileName):
            matchList.append(newFileName)
        else:
            # 正则匹配 过滤跟版本相关的
            patter = re.compile(r'/0/|\\0\\|/r0/|\\r0\\|/r0x\w+/|\\r0x\w+\\|/0x\w+/|\\0x\w+\\')
            if (re.search(patter, newFileName)):
                noMatchList.append(newFileName)
    # 找不到保留 /0/ 文件夹
    if (not matchList):
        defaultPath = matchParam
        for tempFileName in noMatchList:
            # print("not matchList = " + tempFileName)
            if (not defaultPath in tempFileName):
                resultList.append(tempFileName)
    else:
        for tempFileName in noMatchList:
            resultList.append(tempFileName)
            # print(tempFileName)
    # print("getMatchFileList end")
    return resultList

def getFilesFromList(filePath, fileList):
    newFileList = []
    for fileName in fileList:
        if (filePath in fileName):
            newFileList.append(fileName)
    return newFileList

# 通过 API 删除非当前 API 的资源和代码
def removeFileWithAPI(prefixPath, gameAPI):
    fileList = getFiles(prefixPath)
    foundList  = []
    removeList = []
    for fileName in fileList:
        newFileName = fileName.replace(prefixPath, "")
        if (gameAPI in newFileName):
            spliteResult = os.path.split(newFileName)
            foundList.append(spliteResult[0])
    # 去重
    newFoundList = list(set(foundList))
    newFoundList.sort(key=foundList.index)
    containAPIList = []
    # 分割路径
    for removeFileName in newFoundList:
        # 找到的路径中包含有 API 的路径
        if (gameAPI in removeFileName):
            spliteResult = removeFileName.split(gameAPI)
            removeList.append(spliteResult[0])
        else:
            removeList.append(removeFileName)
    newRemoveList = list(set(removeList))
    newRemoveList.sort(key=removeList.index)

    # 查找最终需要删除的文件夹
    finalRemoveList = []
    for filePath in newRemoveList:
        # 查找 /API/ 或者 /0/ 文件夹
        if (filePath.endswith("/") or filePath.endswith("\\")):
            resultList = getFilesFromList(filePath, fileList)
            matchParam = "/0/"
            if (platformName == "Windows"):
                matchParam = "\\0\\"
            foundRemoveList = getMatchFileList(resultList, prefixPath, gameAPI, matchParam)
            finalRemoveList = list(set(finalRemoveList).union(set(foundRemoveList)))
        # 找 /r 结尾的路径
        elif (filePath.endswith("/r") or filePath.endswith("\\r")):
            matchParam = "/r0/"
            if (platformName == "Windows"):
                matchParam = "\\r0\\"
            resultList = getFilesFromList(filePath, fileList)
            finalRemoveList = list(set(finalRemoveList).union(set(getMatchFileList(resultList, prefixPath, gameAPI, matchParam))))
        # 剩下的文件
        else:
            resultList = getFiles(prefixPath + filePath + os.sep)
            matchList   = []
            noMatchList = []
            # 查找文件夹是否包含有对应 API 的文件
            for fileName in resultList:
                newFileName = fileName.replace(prefixPath, "")
                if (gameAPI in newFileName):
                    matchList.append(newFileName)
                else:
                    patter = re.compile(r'0\.lua|/0/|\\0\\|/r0/|\\r0\\|/r0x\w+/|\\r0x\w+\\|/0x\w+/|\\0x\w+\\')
                    if (re.search(patter, newFileName)):
                        noMatchList.append(newFileName)
            # 找不到保留 xx0.lua 文件
            if (not matchList):
                matchStr = "0.lua"
                for tempFileName in noMatchList:
                    if (matchStr in tempFileName):
                        finalRemoveList.append(tempFileName)
            else:
                for tempFileName in noMatchList:
                    finalRemoveList.append(tempFileName)
    finalRemoveList.sort()
    for finalFileName in finalRemoveList:
        # print(finalFileName)
        removeFiles(prefixPath + finalFileName, True)

## add for find cur api files end

# 删除弃用文件
# buildType 编译类型（0 正式包 5 测试包）
# prefixPath 地址前缀
# gameAPI 游戏 API
def removeDepercatedFiles(buildType, prefixPath, gameAPI, isAndroid = 1):
    print("prefixPath = " + prefixPath + " gameAPI = " + gameAPI)
    removeFileWithPlatform(prefixPath, isAndroid)
    if buildType == 0 and TEST_UPDATE == 0:
        removeFilesWithTest(prefixPath)
    removeFileCreatedBySystem(prefixPath)
    removeFileWithAPI(prefixPath, gameAPI)
    deleteGapDir(prefixPath)

# 生成更新服务器上 资源和代码
def genRemote(outputPath, gameApi, subVer):
    print("genRemote")
    orgPath  = BUILD_TEMP_PATH
    patchFile = outputPath + "patch_" + gameApi + "_" + str(subVer) + ".zip"
    createDirs(outputPath, True)
    makeZip(orgPath, patchFile)
    if not IS_SKIP_MANIFEST:
        genManifestByPath(outputPath, gameApi, {}, subVer, str.replace(outputPath, "files/", ""))

# 删除相同文件
def removeSameFiles(gameApi, prefixPath, fileMd5Map):
    proJsonFileName = PROJECT_ROOT + "project_" + str(gameApi) + ".json"
    if (os.path.exists(proJsonFileName)):
        proFileStr = readFile(proJsonFileName)
        proFileMap = json.loads(proFileStr)
    else:
        return
    removeList = []
    for fileName in fileMd5Map:
        orgData = proFileMap.get(fileName, {})
        dstData = fileMd5Map.get(fileName, {})
        if (orgData.get("md5") and dstData.get("md5") == orgData.get("md5")):
            removeList.append(fileName)
    for removeFileName in removeList:
        removeFiles(prefixPath + removeFileName, True)
    deleteGapDir(prefixPath)

# 保存项目配置
def saveProject(gameApi, fileMd5Map):
    projectFileName = PROJECT_ROOT + "project_" + str(gameApi) + ".json"
    writeToFile(projectFileName, formatJsonData(json.dumps(fileMd5Map)))

# 生成游戏对应的 manifest
# 返回 version 和 project 文件的位置
def genManifestByPath(dirPath, gameAPI, md5FileMap, subVer, outputPath):
    print("genHallManifest API = ", gameAPI)
    projectFile = "project_%s.manifest"%(gameAPI)
    versionFile = "version_%s.manifest"%(gameAPI)
    manifestUrl = "%s%s"%(MY_HALL_NET, projectFile)
    versionUrl  = "%s%s"%(MY_HALL_NET, versionFile)
    fileUrl     = MY_CND_HALL_NET + "files/"
    subVer      = subVer or UPDATE_VERSION
    outputPath  = outputPath or dirPath
    versionManifest = {
        "version" : GAME_VERSION + "." + str(subVer),
        "remoteManifestUrl" : manifestUrl,
        "remoteVersionUrl" : versionUrl,
        "packageUrl" : fileUrl,
    }
    writeToFile(outputPath + versionFile, formatJsonData(json.dumps(versionManifest)))
    projectManifest = versionManifest.copy()
    if subVer == 0:
        projectManifest["assets"] = {}
    else:
        if md5FileMap:
            projectManifest["assets"] = md5FileMap
        else:
            projectManifest["assets"] = getFileMapMd5([dirPath], dirPath)

    writeToFile(outputPath + projectFile, formatJsonData(json.dumps(projectManifest)))
    if subVer == 0 and os.path.exists(dirPath + "res/"):
        writeToFile(dirPath + "res/" + projectFile, formatJsonData(json.dumps(projectManifest)))

# 加密文件
def encryptFiles():
    if DEBUG == 0 or TEST_UPDATE == 1:
        if SUB_VER == 0:
            encodeSrcZip(32)
            encodeSrcZip(64)
            # encodeSrc()
        else:
            encodeSrc()
        encodeRes()


# 输出打包需要的内容
# @param buildType 编译类型 0 正式 5 测试
def genOutput(buildType):
    print("genOutput")
    # copy the files to gen the output games by gameAPI
    removeDepercatedFiles(DEBUG, BUILD_TEMP_PATH, GAME_API, IS_ANDROID)
    fileMd5Map = getFileMapMd5([BUILD_TEMP_PATH], BUILD_TEMP_PATH)
    if (SUB_VER != 0):
        outputPath = BUILD_PATH + "remote/" + GAME_VERSION + "/files/"
        removeSameFiles(GAME_API, BUILD_TEMP_PATH, fileMd5Map)
        encryptFiles()
        genRemote(outputPath, GAME_API, SUB_VER)
    else:
        outputPath = BUILD_PATH + "publish" + os.sep + GAME_VERSION + os.sep + GAME_API + os.sep
        createDirs(outputPath, True)
        saveProject(GAME_API, fileMd5Map)
        encryptFiles()
        if not IS_SKIP_MANIFEST:
            genManifestByPath(BUILD_TEMP_PATH, GAME_API, {}, SUB_VER, outputPath)
        if (not (os.path.exists(BUILD_TEMP_PATH + "res/game32.zip") or os.path.exists(BUILD_TEMP_PATH + "res/game64.zip"))):
            shutil.move(BUILD_TEMP_PATH + "src/", outputPath + "src")
        shutil.move(BUILD_TEMP_PATH + "res/", outputPath + "res")
    removeFiles(BUILD_TEMP_PATH, True)

def init(buildType, version, gameApi, gameConfig, testUpdate = 0):
    global GAME_VERSION
    global DEBUG
    global TEST_UPDATE

    global MY_HALL_NET
    global MY_CND_HALL_NET
    global BUILD_PATH
    global BUILD_TEMP_PATH

    global GAME_API
    global SUB_VER
    global IS_ANDROID
    global IS_SKIP_MANIFEST

    DEBUG            = buildType
    GAME_VERSION     = version
    GAME_API         = gameApi
    # 这个字段只在测试热更新逻辑时使用，设置为 1 之后，打包将忽略 DEBUG 值，也就是测试包还是正式包，代码都是 zip
    TEST_UPDATE      = testUpdate and testUpdate or 0

    HALLTH_PATH      = "build/" + GAME_VERSION + "/"
    BUILD_PATH       = PROJECT_ROOT + "build/"
    BUILD_TEMP_PATH  = BUILD_PATH + "temp/"

    if not GAME_API:
        print("gameApi is not defined, build is error!")
        return

    if not gameConfig:
        print("gameConfig is not defined, build is error!")
        return

    SUB_VER          = gameConfig[0] and gameConfig[0] or 0
    IS_ANDROID       = gameConfig[1] and gameConfig[1] or 0
    IS_SKIP_MANIFEST = gameConfig[2] and gameConfig[2] or 0

    if (DEBUG == 0 and TEST_UPDATE == 0):
        MY_HALL_NET     = NORMAL_URL + HALLTH_PATH
        MY_CND_HALL_NET = NORMAL_CND_URL + HALLTH_PATH
    else:
        MY_HALL_NET     = TEST_URL + HALLTH_PATH
        MY_CND_HALL_NET = MY_HALL_NET
    removeCachedFolder()
    curTime = modifyConfig(DEBUG)
    perpareSources()
    print("init success!")
    return curTime

def main(argv):
    buildType = DEBUG
    # try:
    #     # : 表示必填
    #     opts, args = getopt.getopt(argv,"hd",[""])
    # except getopt.GetoptError:
    #     print 'build_project.py -d'
    #     sys.exit(2)
    # for opt, arg in opts:
    #     if opt == '-h':
    #         print 'build_project.py -d'
    #         sys.exit()
    #     elif opt in ("-d", "--"):
    #         buildType = arg
    # if (buildType == 0):
    #     DEBUG = 0
    # else:
    #     DEBUG = buildType
    for gameApi in GAME_API_MAP:
        init(buildType, GAME_VERSION, gameApi, GAME_API_MAP[gameApi], TEST_UPDATE)
        genOutput(buildType)
    # makeZip(PROJECT_ROOT + "build/publish/1.8.0/0x0100B200/", PROJECT_ROOT + "build/hallth/1.8.0/files/patch_0x0100B200.zip")

if __name__ == '__main__':
    main(sys.argv[1:])
