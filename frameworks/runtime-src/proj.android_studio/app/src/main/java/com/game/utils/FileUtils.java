package com.game.utils;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.util.ArrayList;

public class FileUtils {
	public static String getCurrentLocation() {
		String path = FileUtils.class.getProtectionDomain().getCodeSource().getLocation().getFile();
		try {
			path = java.net.URLDecoder.decode(path, "UTF-8");
		} catch (java.io.UnsupportedEncodingException e) {
			return null;
		}

		if (path.startsWith("/")) {
			path = path.substring(1);
		}

		if (path.endsWith(".jar")) {
			path = path.substring(0, path.lastIndexOf("/") + 1);
		}

		return path;
	}

	/**
	 * @param fileName
	 * @return long
	 */
	public static long getFileSize(String fileName) {
		File file = new File(fileName);
		if (!file.exists())
			return 0;
		return file.length();
	}

	public static boolean deleteDirectory(String sPath) {
		if (!sPath.endsWith("/")) {
			sPath += "/";
		}

		File dirFile = new File(sPath);

		if (!dirFile.exists() || !dirFile.isDirectory()) {
			return false;
		}
		boolean flag = true;
		File[] files = dirFile.listFiles();
		if (null == files || files.length <= 0) {
			return true;
		}

		for (int i = 0; i < files.length; i++) {
			if (files[i].isFile()) {
				flag = deleteFile(files[i].getAbsolutePath());
				if (!flag)
					break;
			} else {
				flag = deleteDirectory(files[i].getAbsolutePath());
				if (!flag)
					break;
			}
		}
		if (!flag)
			return true;
		if (dirFile.delete()) {
			return true;
		} else {
			return true;
		}
	}

	public static boolean deleteFile(String sPath) {
		boolean flag = false;
		File file = new File(sPath);
		if (file.exists() && file.isFile()) {
			file.delete();
			flag = true;
		}
		return flag;
	}

	/**
	 * @param fileName
	 * @return
	 */
	public static String readFileByLines(String fileName,String anotherPrefix) {
		StringBuilder sb = new StringBuilder();
		File file = new File(fileName);
		BufferedReader reader = null;
		try {
			reader = new BufferedReader(new FileReader(file));
			String tempString = null;
			while ((tempString = reader.readLine()) != null) {
				sb.append(tempString + anotherPrefix);
			}
			reader.close();

		} catch (IOException e) {
			e.printStackTrace();
			return null;

		} finally {
			if (reader != null) {
				try {
					reader.close();
					return sb.toString();
				} catch (IOException e1) {
					return null;
				}
			}
		}
		return sb.toString();
	}

	public static String readFileByLinesOriginally(String fileName) {
		StringBuilder sb = new StringBuilder();
		File file = new File(fileName);
		BufferedReader reader = null;
		try {
			reader = new BufferedReader(new FileReader(file));
			String tempString = null;
			while ((tempString = reader.readLine()) != null) {
				sb.append(tempString + "\n");
			}
			reader.close();

		} catch (IOException e) {
			e.printStackTrace();
			return null;

		} finally {
			if (reader != null) {
				try {
					reader.close();
					return sb.toString();
				} catch (IOException e1) {
					return null;
				}
			}
		}
		return sb.toString();
	}

	public static boolean writeString(String fileName, String str) {
		return writeString(fileName,str, false);
	}

	public static boolean writeString(String fileName, String str, boolean isAppend) {
		try {
			File file = new File(fileName);
			if (!file.exists())
				file.createNewFile();
			FileOutputStream out = new FileOutputStream(file, isAppend);
			OutputStreamWriter ow = new OutputStreamWriter(out, "utf-8");
			// StringBuffer sb = new StringBuffer();
			// sb.append(str);
			ow.write(str + "\n");
			ow.close();
			out.close();
			return true;
		} catch (IOException ex) {
			return false;
		}
	}

	public static boolean write(String fileName, String content){
		try {
			FileOutputStream out = new FileOutputStream(fileName);
			OutputStreamWriter ow = new OutputStreamWriter(out, "utf-8");
			ow.write(content + "\n");
			ow.close();
			out.close();
			return true;

		} catch (Exception e) {
			return false;
		}

	}

	public static boolean copyFolder(String originFolder, String definiteFolder) {
		File originDir = new File(originFolder);
		if (!originDir.exists()) {
			return false;
		} else if (!originDir.isDirectory()) {
			return false;
		}

		if (!definiteFolder.endsWith("/")) {
			definiteFolder = definiteFolder + "/";
		}
		File destDir = new File(definiteFolder);

		if (destDir.exists()) {
			new File(definiteFolder).delete();
		} else {
			if (!destDir.mkdirs()) {
				return false;
			}
		}

		boolean flag = true;
		File[] files = originDir.listFiles();
		for (int i = 0; i < files.length; i++) {
			if (files[i].isFile()) {
				flag = copyFile(files[i].getAbsolutePath(), definiteFolder + files[i].getName());
				if (!flag)
					break;
			} else if (files[i].isDirectory()) {
				flag = copyFolder(files[i].getAbsolutePath(), definiteFolder + files[i].getName());
				if (!flag)
					break;
			}
		}

		if (!flag) {
			return false;
		} else {
			return true;
		}
	}

	public static boolean copyFile(String originFile, String definiteFile) {
		File origin = new File(originFile);

		if (!origin.exists()) {
			return false;

		} else if (!origin.isFile()) {
			return false;
		}

		File destFile = new File(definiteFile);

		if (destFile.exists()) {
			new File(definiteFile).delete();
		} else {
			if (!destFile.getParentFile().exists()) {
				if (!destFile.getParentFile().mkdirs()) {
					return false;
				}
			}
		}

		int byteread = 0;
		InputStream in = null;
		OutputStream out = null;

		try {
			in = new FileInputStream(originFile);
			out = new FileOutputStream(definiteFile);
			byte[] buffer = new byte[1024];

			while ((byteread = in.read(buffer)) != -1) {
				out.write(buffer, 0, byteread);
			}
			return true;
		} catch (FileNotFoundException e) {
			return false;
		} catch (IOException e) {
			return false;
		} finally {
			try {
				if (out != null)
					out.close();
				if (in != null)
					in.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	public static ArrayList<String> allFileList(String fileName) {
		ArrayList<String> allFiles = new ArrayList<String>();
		list(new File(fileName), allFiles);
		return allFiles;
	}

	public static void list(File file, ArrayList<String> allFiles) {
		if (file.isDirectory()) {
			File[] lists = file.listFiles();
			if (lists != null) {
				for (int i = 0; i < lists.length; i++) {
					list(lists[i], allFiles);// 是目录就递归进入目录内再进行判断
				}
			}
		}else{
			allFiles.add(file.getAbsolutePath());
		}
	}
}
