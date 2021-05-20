package com.game.utils;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.ProviderInfo;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Picture;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Environment;
import android.provider.Settings.Secure;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.view.Display;
import android.view.View;
import android.view.WindowManager;
import android.webkit.WebView;

import com.game.core.ConstantValue;

import com.app.clearcache.R;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lua.AppActivity;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.Locale;
import com.game.entity.User;

/**
 * 公共类
 * @author ClarkWu
 *
 */
public class CommonUtils {
	private static final Object object = new Object();
	public static final String LINE_PACKAGE_NAME = "jp.naver.line.android";
	public static final String WAPP_PACKAGE_NAME = "com.whatsapp";

	/**
	 * 得到游戏语言
	 * @param context
	 * @return
	 */
	public static String getGameLanguage(Context context){
		try{
			Resources res = context.getResources();
			Configuration config = res.getConfiguration();
			return config.locale.getCountry();
			
		}catch(Exception e){
			return null;
		}
	}
	
	/**
	 * 得到运营商ID
	 * @param context
	 * @return
	 */
	public static String getOperator(Context context){
		try{
			TelephonyManager telManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
			return telManager.getSubscriberId();
			
		}catch(Exception e){
			return null;
		}
	}
	
	/**
	 * 得到游戏名称
	 * @param context
	 */
	public static String getGameName(Context context){
		try{
			return context.getResources().getString(R.string.app_name);
		}catch(Exception e){
			return null;
		}
	}

	/**
	 * 得到游戏版本号
	 * @param context
	 * @return StringBuffer 游戏版本
	 */
	public static StringBuffer getGameVersion(Context context){
		try {
			PackageManager manager = context.getPackageManager();
			PackageInfo info = manager.getPackageInfo(context.getPackageName(), 0);
			return new StringBuffer(info.versionName);
		} catch (Exception e) {
			e.printStackTrace();
			return new StringBuffer("");
		}
	}

	public static StringBuffer getPackageName(Context context){
		try {
			return new StringBuffer(context.getPackageName());
		} catch (Exception e) {
			e.printStackTrace();
			return new StringBuffer("");
		}
	}

	public static String getGooglePushId(Context context){
		try{
			return context.getResources().getStringArray(R.array.gcm_sender_ids)[0];
		}catch(Exception e){
			e.printStackTrace();
			return "";
		}
	}

	public static String getBuildInfo(Context context){
		try{
			String fileName = context.getApplicationInfo().nativeLibraryDir + "/libcocos2dlua.so";
			long fileSize = FileUtils.getFileSize(fileName);
			DecimalFormat df = new DecimalFormat("#.00");
			return fileName + " " + df.format((double)fileSize /1024/1024) + "MB";

		}catch(Exception e){
			e.printStackTrace();
			return "";
		}
	}

	/**
	 * 得到游戏内部版本号
	 * @param context
	 * @return StringBuffer 游戏内部版本versioncode
	 */
	public static StringBuffer getGameVersionCode(Context context){
		try {
			PackageManager manager = context.getPackageManager();
			PackageInfo info = manager.getPackageInfo(context.getPackageName(), 0);
			return new StringBuffer(info.versionCode + "");
		} catch (Exception e) {
			e.printStackTrace();
			return new StringBuffer("");
		}
	}

	/**
	 * 设备的可选 IETF 语言区域标记，采用分别由两个字母组成的语言代码和国家/地区代码，两者之间用下划线分隔。(en_US)
	 * @param context
	 * @return
	 */
	public static StringBuffer getGameLocale(Context context){
		try{
			return new StringBuffer(Locale.getDefault().toString());
		}catch(Exception e){
			e.printStackTrace();
			return new StringBuffer("");
		}
	}

	/**
	 * 得到手机型号
	 * @return String 手机型号
	 */
	public static String getModel(){
		try{
			return android.os.Build.MODEL;
		}catch(Exception e){
			e.printStackTrace();
			return "";
		}
	}

	public static String getBuild(){
		return "Build/" + Build.ID;
	}

	public static int getSDCardMount(){
		try{
			if(isSDCARDMounted()){
				return 1;
			}else{
				return 0;
			}
		}catch(Exception e){
			return 0;
		}
	}

	private static boolean isSDCARDMounted() {
		String status = Environment.getExternalStorageState();
		if (status.equals(Environment.MEDIA_MOUNTED))
			return true;
		return false;
	}

	/**
	 * 得到手机操作系统
	 * @return String 手机操作系统
	 */
	public static String getOsv(Context context){
		try{
			return android.os.Build.VERSION.RELEASE;
		}catch(Exception e){
			e.printStackTrace();
			return "";
		}
	}

	/**
	 * 得到手机设备号
	 * @param context
	 * @return String 手机imei
	 */
	public static String getImei(Context context){
		String sitemid = null;
		try{
			sitemid = getDeviceId(context);
		}catch(Exception e){
			sitemid = null;
		}

		try{
			if(sitemid == null ||"".equals(sitemid)){
				sitemid = getMac(context);
			}
		}catch(Exception e){
			e.printStackTrace();
		}

		try{
			if(sitemid == null || "000000000000".equals(sitemid)){
				sitemid = getAndroidId(context);
			}
		}catch(Exception e){
			e.printStackTrace();
		}

		try{
			if(sitemid == null || "".equals(sitemid) ){
				sitemid = getUniqueId();
			}
		}catch(Exception e){
			e.printStackTrace();
		}

		return sitemid;
	}

	public static String getDeviceId(Context context){
		try{
			TelephonyManager telephoneManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);

			String sitemid = telephoneManager.getDeviceId();
			return sitemid;

		}catch(Exception e){
			e.printStackTrace();
			return "";
		}
	}

	/**
	 * 获取imsi
	 * @param context
	 * @return String imsi
	 */
	public static String getImsi(Context context){
		try{
			TelephonyManager telephoneManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
			return telephoneManager.getSubscriberId();
		}catch(Exception e){
			e.printStackTrace();
			return "";
		}
	}

	/**
	 * 获取卡槽一的电话号码
	 * @param context
	 * @return
	 */
	public static String getPhoneNumber(Context context){
		try{
			TelephonyManager telephoneManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
			return telephoneManager.getLine1Number();
		}catch(Exception e){
			e.printStackTrace();
			return "";
		}

	}

	/**
	 * 得到手机厂商
	 * @return
	 */
	public static String getManufacture(){
		try{
			return android.os.Build.MANUFACTURER;
		}catch(Exception e){
			e.printStackTrace();
			return "";
		}
	}

	/**
	 * 得到屏幕尺寸
	 * @param context
	 * @return xx * xx
	 */
	@SuppressWarnings("deprecation")
	public static String getPixels(Activity context){
		try{
			WindowManager windowManager = context.getWindowManager();
	        Display display = windowManager.getDefaultDisplay();
			int screenWidth = display.getWidth();
	        int screenHeight = display.getHeight();
	        return screenWidth + "*" + screenHeight;
		}catch(Exception e){
			e.printStackTrace();
			return "";
		}
	}

	/**
	 * 得到当前的连接方式
	 * @param context
	 * @return
	 */
	public static String getApnNet(Context context){
		try{
			ConnectivityManager connectivityManager = (ConnectivityManager) context
			.getSystemService(Context.CONNECTIVITY_SERVICE);
			NetworkInfo network = connectivityManager.getActiveNetworkInfo();
			if(network!= null && network.isAvailable() && network.isConnected()){
				int type = network.getType();
				if(type == ConnectivityManager.TYPE_WIFI){
					return "wifi";
				}else if (type == ConnectivityManager.TYPE_MOBILE){
					TelephonyManager telephonyManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
					switch(telephonyManager.getNetworkType()){
						case TelephonyManager.NETWORK_TYPE_1xRTT:
						case TelephonyManager.NETWORK_TYPE_CDMA:
						case TelephonyManager.NETWORK_TYPE_EDGE:
						case TelephonyManager.NETWORK_TYPE_GPRS:
						case TelephonyManager.NETWORK_TYPE_IDEN:

							return "2G";

						case TelephonyManager.NETWORK_TYPE_EHRPD:
						case TelephonyManager.NETWORK_TYPE_EVDO_0:
						case TelephonyManager.NETWORK_TYPE_EVDO_A:
						case TelephonyManager.NETWORK_TYPE_EVDO_B:
						case TelephonyManager.NETWORK_TYPE_HSDPA:
						case TelephonyManager.NETWORK_TYPE_HSPA:
						case TelephonyManager.NETWORK_TYPE_HSPAP:
						case TelephonyManager.NETWORK_TYPE_HSUPA:
						case TelephonyManager.NETWORK_TYPE_UMTS:
							return "3G";
						case TelephonyManager.NETWORK_TYPE_LTE:
							return "4G";
						default :
							return "UNKNOWN";
					}
				}

			}else{
				return "无连接";
			}
			return "UNKNOWN";

		}catch(Exception e){
			e.printStackTrace();
			return "";
		}
	}

	/**
	 * 获得mac地址
	 * @param context
	 */
	public static String getMac(Context context){
		String macAddress = "000000000000";
		try {
            WifiManager wifiMgr = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
            WifiInfo info = (null == wifiMgr ? null : wifiMgr
                    .getConnectionInfo());
            if (null != info) {
                if (!TextUtils.isEmpty(info.getMacAddress()))
                    macAddress = info.getMacAddress().replace(":", "");
                else
                    return macAddress;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return macAddress;
        }
        return macAddress;
	}

	public static String getAppid(Context context){
		try{
			String appIdAndKey = getAppMetaData(context,"CHANNEL");
			return appIdAndKey.split("-")[0];
		}catch(Exception e){
			e.printStackTrace();
			return "";
		}
	}

	public static String getAppkey(Context context){
		try{
			String appIdAndKey = getAppMetaData(context,"CHANNEL");
			return appIdAndKey.split("-")[1];
		}catch(Exception e){
			e.printStackTrace();
			return "";
		}
	}

	public static String getAndroidId(Context context){
		try{
			return Secure.getString(context.getContentResolver(),Secure.ANDROID_ID);
		}catch(Exception e){
			return "";
		}
	}

	@SuppressWarnings("deprecation")
	public static String getUniqueId(){
		try{
			if(Build.VERSION.SDK_INT > 21){
				return "bf" +
						Build.BOARD.length()%10 + Build.BRAND.length()%10 +
						Build.SUPPORTED_ABIS.length%10 + Build.DEVICE.length()%10 +
						Build.DISPLAY.length()%10 + Build.HOST.length()%10 +
						Build.ID.length()%10 + Build.MANUFACTURER.length()%10 +
						Build.MODEL.length()%10 +
						Build.PRODUCT.length()%10 +
						Build.TAGS.length()%10 +
						Build.TYPE.length()%10 +
						Build.USER.length()%10 ;

			}else{
				return "bf" +
						Build.BOARD.length()%10 + Build.BRAND.length()%10 +
						Build.CPU_ABI.length()%10 + Build.DEVICE.length()%10 +
						Build.DISPLAY.length()%10 + Build.HOST.length()%10 +
						Build.ID.length()%10 + Build.MANUFACTURER.length()%10 +
						Build.MODEL.length()%10 +
						Build.PRODUCT.length()%10 +
						Build.TAGS.length()%10 +
						Build.TYPE.length()%10 +
						Build.USER.length()%10 ;
			}
		}catch(Exception e){
			e.printStackTrace();
			return "";
		}
	}

	public static String getAppMetaData(Context ctx, String key) {
        if (ctx == null || TextUtils.isEmpty(key)) {
            return null;
        }
        String resultData = null;
        try {
            PackageManager packageManager = ctx.getPackageManager();
            if (packageManager != null) {
                ApplicationInfo applicationInfo = packageManager.getApplicationInfo(ctx.getPackageName(), PackageManager.GET_META_DATA);
                if (applicationInfo != null) {
                    if (applicationInfo.metaData != null) {
                        resultData = applicationInfo.metaData.getString(key);
                    }
                }

            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return resultData;
    }

	public static boolean checkApkExist(Context context, String packageName){
		if (TextUtils.isEmpty(packageName))
            return false;
        try {
            context.getPackageManager()
                    .getApplicationInfo(packageName,
                            PackageManager.GET_UNINSTALLED_PACKAGES);
            return true;
        } catch (PackageManager.NameNotFoundException e) {
            return false;
        }
	}

	public static void putSharedString(String key, String value){
		SharedPreferences sp = Cocos2dxActivity.getContext().getSharedPreferences("userThing",
				Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = sp.edit();
		editor.putString(key, value);
		editor.commit();
	}

	public static String getSharedString(String key){
		SharedPreferences sp = Cocos2dxActivity.getContext().getSharedPreferences("userThing",
				Context.MODE_PRIVATE);
		return sp.getString(key, "");
	}

	public static Bitmap screenShot(Activity ctx) {
        View view = ctx.getWindow().getDecorView();
        view.setDrawingCacheEnabled(true);
        view.buildDrawingCache();

        Bitmap bp = Bitmap.createBitmap(view.getDrawingCache(), 0, 0, view.getMeasuredWidth(),
                view.getMeasuredHeight());

        view.setDrawingCacheEnabled(false);
        view.destroyDrawingCache();
        return bp;
    }

    public static Bitmap webViewScreenShot(Context context, final WebView webView) {
        Picture picture = webView.capturePicture();
        int width = picture.getWidth();
        int height = picture.getHeight();
        if (width > 0 && height > 0) {
          Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.RGB_565);
          Canvas canvas = new Canvas(bitmap);
          picture.draw(canvas);
          return bitmap;
        }
        return null;

    }

    public static String saveToSD(Bitmap bmp) {
        String fileDirectory = Cocos2dxHelper.getFileDirectory();
        if (fileDirectory == null || "".equals(fileDirectory)) {
            return null;
        }

        String fileName = fileDirectory + "/screenActivityPopup.jpg";
        File file = new File(fileName);
        if (!file.exists()) {
            try {
                file.createNewFile();
            } catch (IOException e) {
                e.printStackTrace();
                return null;
            }
        }
        FileOutputStream fos = null;
        try {
            fos = new FileOutputStream(file);
            if (fos != null) {
                // 第一参数是图片格式，第二参数是图片质量，第三参数是输出流
                bmp.compress(Bitmap.CompressFormat.JPEG, 100, fos);
                fos.flush();
            }
            fos.close();
            return fileName;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

	/**
	 * 判断应用是否有安装
	 * @param appName 应用名称
	 * @return boolean 是否已安装
	 */
	public static boolean isAppInstalled(String appName) {
		String packageName = "";
		switch (appName){
			case "line":
				packageName = LINE_PACKAGE_NAME;
				break;
			case "whatsapp":
				packageName = WAPP_PACKAGE_NAME;
				break;
		}
		if (packageName.length() <= 0) {
			return false;
		}
		synchronized (object) {
			int i = 0;
			try {
				PackageManager localPackageManager = AppActivity.getContext().getPackageManager();
				localPackageManager.getPackageInfo(packageName, 1);
				i = 1;
			} catch (PackageManager.NameNotFoundException localNameNotFoundException) {

			} catch (RuntimeException localRuntimeException) {

			} catch (Exception e) {
				i = 0;
			}
			return i == 1;
		}
	}

	public static User initUserInfo(){
		User user = new User();
		try{
			user.setRat(CommonUtils.getPixels((Activity) Cocos2dxActivity.getContext()));
			user.setImei(CommonUtils.getImei(Cocos2dxActivity.getContext()));
			user.setOsv(CommonUtils.getOsv(Cocos2dxActivity.getContext()));
			user.setNet(CommonUtils.getApnNet(Cocos2dxActivity.getContext()));
			user.setOperator(CommonUtils.getManufacture());
			user.setImsi(CommonUtils.getImsi(Cocos2dxActivity.getContext()));
			user.setMac(CommonUtils.getMac(Cocos2dxActivity.getContext()));
			user.setPhoneNumber(CommonUtils.getPhoneNumber(Cocos2dxActivity.getContext()));
			user.setVersion(CommonUtils.getGameVersion(Cocos2dxActivity.getContext()).toString());
			user.setVersionCode(CommonUtils.getGameVersionCode(Cocos2dxActivity.getContext()).toString());
			user.setLocale("" + CommonUtils.getGameLocale(Cocos2dxActivity.getContext()));
			user.setBuild_id(CommonUtils.getBuild());
			user.setModel(CommonUtils.getModel());
			user.setSupportSDCard(CommonUtils.getSDCardMount() == 1);
			user.setUniqueId(CommonUtils.getUniqueId());
			user.setAndroidId(CommonUtils.getAndroidId(Cocos2dxActivity.getContext()));
			user.setDeviceId(CommonUtils.getDeviceId(Cocos2dxActivity.getContext()));
			user.setGuid(CommonUtils.getSharedString("guestUid"));
			user.setFuid(CommonUtils.getSharedString("fbUid"));
			user.setRdid(ConstantValue.google_ad_id);
			user.setIconName(CommonUtils.getGameName(Cocos2dxActivity.getContext()));
			user.setTotalDeviceAvailableSize(CommonUtils.getAvailiableMemorySize(Cocos2dxActivity.getContext()));
			user.setTotalDeviceSize(CommonUtils.getTotalMemorySize(Cocos2dxActivity.getContext()));

			return user;

		}catch(Exception e){

		}

		return null;
	}
	/**
	 * 判断当前应用是否是debug状态
	 */
	public static boolean isApkInDebug(Context context) {
		try {
			ApplicationInfo info = context.getApplicationInfo();
			return (info.flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 *  计算缩放因子
	 * @param options 位图选项
	 * @param reqWidth 目标宽度
	 * @param reqHeight 目标高度
	 * @return int 缩放因子 ( x >=1 ) 会对原图进行 1/x 缩放
	 */
	public static int calculateInSampleSize(
			BitmapFactory.Options options, int reqWidth, int reqHeight) {
		// Raw height and width of image
		final int height = options.outHeight;
		final int width = options.outWidth;
		int inSampleSize = 1;
		if (height > reqHeight || width > reqWidth) {
			final int halfHeight = height / 2;
			final int halfWidth = width / 2;
			// Calculate the largest inSampleSize value that is a power of 2 and keeps both
			// height and width larger than the requested height and width.
			while ((halfHeight / inSampleSize) >= reqHeight
					&& (halfWidth / inSampleSize) >= reqWidth) {
				inSampleSize *= 2;
			}
		}
		return inSampleSize;
	}

	//获取总内存
	public static long getTotalMemorySize(Context context){
		long size = 0;

		try{
			//获取ActivityManager管理，要获取【运行相关】的信息，与运行相关的信息有关
			ActivityManager activityManager = (ActivityManager) context.getSystemService(context.ACTIVITY_SERVICE);
			ActivityManager.MemoryInfo outInfo = new ActivityManager.MemoryInfo();//outInfo对象里面包含了内存相关的信息
			activityManager.getMemoryInfo(outInfo);//把内存相关的信息传递到outInfo里面C++思想

			size = outInfo.totalMem;
		}catch(Exception e){
			e.printStackTrace();
		}

		return size;
	}

	// 获得可用内存
	public static long getAvailiableMemorySize(Context context){
		long size = 0;

		try{
			//获取ActivityManager管理，要获取【运行相关】的信息，与运行相关的信息有关
			ActivityManager activityManager = (ActivityManager) context.getSystemService(context.ACTIVITY_SERVICE);
			ActivityManager.MemoryInfo outInfo = new ActivityManager.MemoryInfo();//outInfo对象里面包含了内存相关的信息
			activityManager.getMemoryInfo(outInfo);//把内存相关的信息传递到outInfo里面C++思想

			size = outInfo.availMem;
		}catch(Exception e){
			e.printStackTrace();
		}

		return size;
	}

//	public static Uri getUri(Activity activity, String path){
//		File file = new File(path);
//		Uri uri = null;
//		if (Build.VERSION.SDK_INT >= 24) {
//			try {
//				uri = FileProvider.getUriForFile(activity
//						, PictureManager.getFileProviderName(activity)
//						, file);
//			} catch (PackageManager.NameNotFoundException e) {
//				e.printStackTrace();
////				ToastUtils.showShort("获取文件路径失败");
//			}
//		} else {
//			uri = Uri.fromFile(file);
//		}
//
//		return uri;
//	}
}
