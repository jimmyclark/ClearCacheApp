#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright (c) 2017 - Amnon <hzmsmail.2@gmail.com>
# Usage: python generate_project.py
# 配置环境变量
# ANT_HOME, JAVA_HOME, ANDROID_HOME
#

import re
import json
import md5
import platform
import time

import shutil
import os,sys
import zipfile
import hashlib

PROJECT_ROOT        = str.replace(os.getcwd(), "tools", "")
PROJECT_ROOT        = str.replace(PROJECT_ROOT, "\\", "/")

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

def list_dir(path, folderRetArrays):
  for i in os.listdir(path):
    temp_dir = os.path.join(path, i)
    temp_dir = temp_dir.replace("\\","/")
    if os.path.isdir(temp_dir):
        list_dir(temp_dir, folderRetArrays)
    else:
        folderRetArrays.append(temp_dir)

def get_config_dirs(folderName, folderRetArrays):
    return list_dir(folderName, folderRetArrays)

def getAllFolders(apkName, apkFolders):
    apkFolder = apkName[:-4]
    get_config_dirs(apkFolder, apkFolders)

def getHashValue(fileName):
    line = fileName.readline()
    hashValue = hashlib.md5()
    while(line):
        hashValue.update(line)
        line = fileName.readline()
    return hashValue.hexdigest()

def writeToFile(fileName, content):
    fileObject = open(fileName, 'w+')
    fileObject.write(content)
    fileObject.write("\n")
    fileObject.close()

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

def main(argv):
    SRC_FOLDER = PROJECT_ROOT + "src/"

    # 需要排除的目录
    SPLIT_FOLDER = ["cocos", "framework"]

    FOLDER_NAME = PROJECT_ROOT + "src_folder.property"

    # 绝对路径
    temp_absolute_folder_array = []
    absolute_folder_array = []
    # 文件名
    folder_array = []
    # 相对路径
    relative_folder_array = []

    get_config_dirs(SRC_FOLDER, temp_absolute_folder_array)

    content = ""

    for item in temp_absolute_folder_array:
        containFlag = False
        for need_split in SPLIT_FOLDER:
            var_split = SRC_FOLDER + need_split
            if item.find(need_split) > 0:
                containFlag = True
                break
        if containFlag == False:
            content = content + "or_file=" + os.path.basename(item) + ",or_folder=" + item.replace(SRC_FOLDER,"")
            content = content + "\n"

    writeToFile(FOLDER_NAME, content)

if __name__ == '__main__':
    main(sys.argv[1:])
