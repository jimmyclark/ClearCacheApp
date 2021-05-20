package com.game.core;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Build;
import android.os.Vibrator;
import android.text.TextUtils;
import android.util.Log;

import com.game.utils.CommonUtils;
import com.game.utils.FileUtils;
import com.game.utils.PermissionUtil;
import com.game.utils.PermissionViewUtils;
import com.app.clearcache.R;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lua.AppActivity;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;

public class Function {
	public static final String TAG = Function.class.getSimpleName();

	// 获取版本号
	public static String getAppVersion() {
		try {
			Context ctx = AppActivity.getContext();
			if (ctx != null) {
				PackageManager packageManager = ctx.getPackageManager();
				// getPackageName()是你当前类的包名，0代表获取的是版本号
				PackageInfo packageInfo = packageManager.getPackageInfo(ctx.getPackageName(), 0);
				return packageInfo.versionName;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}

	public static void deleteAllNeedThings(String folderName) {
		FileUtils.deleteDirectory(folderName);
	}

	public static void closeStartScreen() {
		try {
			long nowTime = System.currentTimeMillis();
			long needTime = AppActivity.startDialog.getDistantStartTime(nowTime);

			if("1".equals(CommonUtils.getSharedString(ConstantValue.SHARED_PREFERENCE_IS_NEED_SECOND_START))){
				CommonUtils.putSharedString(ConstantValue.SHARED_PREFERENCE_IS_NEED_SECOND_START, "0");
			}

			if (AppActivity.startDialog != null && AppActivity.startDialog.isShowing()) {
				if (AppActivity.startDialog.getDelayTime() > 0) {
					new Thread(new Runnable() {

						@Override
						public void run() {
							try {
								Thread.sleep(AppActivity.startDialog.getDelayTime());

							} catch (Exception e) {
								// e.printStackTrace();
							}
							if(AppActivity.startDialog != null){
								AppActivity.startDialog.dismiss();
								AppActivity.startDialog = null;
							}
						}
					}).start();
				} else {
					AppActivity.startDialog.dismiss();
					AppActivity.startDialog = null;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	// 字符串截取
	public static String getFixedWidthText(String font, int size, String text, int width) {
		if (text == null || text.length() < 3) {
			return text;
		}
		Paint p = new Paint();
		p.setTextSize(size);
		if (!TextUtils.isEmpty(font)) {
			p.setTypeface(Typeface.create(font, Typeface.NORMAL));
		} else {
			p.setTypeface(Typeface.DEFAULT);
		}
		StringBuilder sb = new StringBuilder(text.substring(0, 1));
		sb.append("..");
		int i;
		String ret = "";
		for (i = 1; i < text.length(); i++) {
			float w = p.measureText(sb.toString());
			if (w < width) {
				ret = sb.toString();
				sb.insert(i, text.subSequence(i, i + 1));
				if (i + 1 == text.length()) {
					return text;
				}
			} else {
				break;
			}
		}
		return ret;
	}

	public static String getInitThings() {
		// 判断是否是当前的版本号
		String fileDirectory = Cocos2dxHelper.getFileDirectory() + "/version.dat";

		if (new File(fileDirectory).exists()) {
			try {
				String tempVersion = FileUtils.readFileByLines(fileDirectory, "");
				if (null != tempVersion) {
					String version = tempVersion.trim();
					String curVersion = CommonUtils.getGameVersion(Cocos2dxActivity.getContext()).toString();
					if (!version.equals(curVersion)) {
						deleteAllExistUpdateFolder();
						// 旧版本比新版本还要大，不管什么原因，先把原来的更新都删了
						if (compareVersion(version, curVersion) > 0) {
							deleteAllExistUdGameFolder();
						}
						FileUtils.writeString(fileDirectory,
								CommonUtils.getGameVersion(Cocos2dxActivity.getContext()).toString());
					}
				}
			} catch (Exception e) {

			}

		} else {
			try {
				new File(fileDirectory).createNewFile();
				FileUtils.writeString(fileDirectory,
						CommonUtils.getGameVersion(Cocos2dxActivity.getContext()).toString());
				deleteAllExistUpdateFolder();
				deleteAllExistUdGameFolder();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		JSONObject initJsons = new JSONObject();
		try {
			initJsons.put("rat", ConstantValue.device_user.getRat());
			initJsons.put("imei", ConstantValue.device_user.getImei());
			initJsons.put("osv", ConstantValue.device_user.getOsv());
			initJsons.put("net", ConstantValue.device_user.getNet());
			initJsons.put("operator",ConstantValue.device_user.getOperator());
			initJsons.put("imsi", ConstantValue.device_user.getImsi());
			initJsons.put("mac", ConstantValue.device_user.getMac());
			initJsons.put("phonenumber", ConstantValue.device_user.getPhoneNumber());
			initJsons.put("version", ConstantValue.device_user.getVersion());
			initJsons.put("versionCode", ConstantValue.device_user.getVersionCode());
			initJsons.put("locale", ConstantValue.device_user.getLocale());
			initJsons.put("buildId",ConstantValue.device_user.getBuild_id());
			initJsons.put("appid", ConstantValue.device_user.getAppid());
			initJsons.put("appkey",ConstantValue.device_user.getAppkey());
			initJsons.put("api", ConstantValue.device_user.getApiInfo());
			initJsons.put("model", ConstantValue.device_user.getModel());
			initJsons.put("fbInvited", ConstantValue.isFBInvitedSetUp ? "1" : "0");
			initJsons.put("google_action", ConstantValue.google_push_action);
			initJsons.put("google_id", ConstantValue.google_push_id);
			initJsons.put("google_sid", ConstantValue.google_push_sid);
			initJsons.put("supportSDCard", ConstantValue.device_user.isSupportSDCard() ? 1 : 0);
			initJsons.put("uniqueId", ConstantValue.device_user.getUniqueId());
			initJsons.put("androidId", ConstantValue.device_user.getAndroidId());
			initJsons.put("deviceId",ConstantValue.device_user.getDeviceId());
			initJsons.put("guid", ConstantValue.device_user.getGuid());
			initJsons.put("fuid", ConstantValue.device_user.getFuid());
			initJsons.put("isFirstStart",isFirstStart()?"1":"0");
			initJsons.put("rdid", ConstantValue.google_ad_id);
			initJsons.put("iconName", ConstantValue.device_user.getIconName());
			initJsons.put("isAndroid10",  ConstantValue.device_user.isAndroid10());
			initJsons.put("deviceTotalSize", ConstantValue.device_user.getTotalDeviceSize());
			initJsons.put("deviceAvaliableSize", ConstantValue.device_user.getTotalDeviceAvailableSize());

		} catch (Exception e) {
			e.printStackTrace();
		}
		ConstantValue.isSendToLua = true;
		ConstantValue.dynamicLink = null;
		return initJsons.toString();
	}

	private static void deleteAllExistUpdateFolder() {
		String version = Cocos2dxHelper.getFileDirectory() + "/version";
		String updateFolder = Cocos2dxHelper.getFileDirectory() + "/ud";
		FileUtils.deleteDirectory(version);
		FileUtils.deleteDirectory(updateFolder);
	}

	/**
	 *  对比两个版本号，v1 > v2 正数， v1 < v2 负数 相等  0
	 * @param v1 版本号1
	 * @param v2 版本号2
	 * @return number result
	 */
	public static int compareVersion(String v1, String v2) {
		int i = 0, j = 0, x = 0, y = 0;
		int v1Len = v1.length();
		int v2Len = v2.length();
		char c;
		do {
			// 计算出 V1 中的点之前的数字
			while (i < v1Len) {
				c = v1.charAt(i++);
				if (c >= '0' && c <= '9') {
					// c-‘0’表示两者的 ASCLL 差值
					x = x * 10 + (c - '0');
				} else if (c == '.') {
					break;
				} else {
					// 无效的字符
				}
			}
			//  计算出 V2 中的点之前的数字
			while (j < v2Len) {
				c = v2.charAt(j++);
				if (c >= '0' && c <= '9') {
					y = y * 10 + (c - '0');
				} else if (c == '.') {
					break;
				} else {
					// 无效的字符
				}
			}
			if (x < y) {
				return -1;
			} else if (x > y) {
				return 1;
			} else {
				x = 0;
				y = 0;
				continue;
			}

		} while ((i < v1Len) || (j < v2Len));
		return 0;
	}

	/**
	 * 删除游戏中存在的小游戏更新
	 */
	private static void deleteAllExistUdGameFolder() {
		String updateGameFolder = Cocos2dxHelper.getFileDirectory() + "/udGame";
		FileUtils.deleteDirectory(updateGameFolder);
	}

	public static void parseWebViewByContent(String urlContent, int isHideBtn) {
		// HuodongController.getInstance().loadHuodongPopupWindow(urlContent,isHideBtn
		// == 1);
	}

	public static void parseAllScreenWebViewByContent(String urlContent) {
		// HuodongController.getInstance().loadAllScreenPopupWindow(urlContent);
	}

	public static void closeAllWebView() {
		// HuodongController.getInstance().closeHuodongPopupWindow();
	}

	public static int checkContainPhoneState() {
		return PermissionUtil.checkContainPhoneState(Cocos2dxActivity.getContext());
	}

	public static void openPhoneState(int callback) {
		PermissionUtil.openPhoneState((Activity) Cocos2dxActivity.getContext(), callback);
	}

	public static int checkContainSdcardState() {
		return PermissionUtil.checkContainExternalStorateState(Cocos2dxActivity.getContext());
	}

	public static void openSdcardState(int callback) {
		PermissionUtil.openExternalStorageState((Activity) Cocos2dxActivity.getContext(), callback);
	}

	public static void goToSetting() {
		PermissionViewUtils.goToPermissions();
	}

	public static String getImei() {
		return CommonUtils.getImei(Cocos2dxActivity.getContext());
	}

	public static String getDeviceId() {
		return CommonUtils.getDeviceId(Cocos2dxActivity.getContext());
	}

	public static String getAndroidId() {
		return CommonUtils.getAndroidId(Cocos2dxActivity.getContext());
	}

	public static void checkAllPermission(int phoneCallBack) {
		PermissionUtil.checkAllPermission((Activity) Cocos2dxActivity.getContext(), phoneCallBack);
	}

	/**
	 * 实现文本复制功能
	 *
	 * @param content
	 */
	public static void copyToBoard(final String content) {
		Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
			@Override
			public void run() {
				ClipboardManager cmb = (ClipboardManager) Cocos2dxActivity.getContext()
						.getSystemService(Context.CLIPBOARD_SERVICE);
				cmb.setPrimaryClip(ClipData.newPlainText(null, content.trim()));
			}
		}, 50);

	}

	public static int getStoNoShow() {
		return PermissionUtil.checkContainStorageStateHasForbid((Activity) Cocos2dxActivity.getContext());
	}

	public static int getPhoneNoShow() {
		return PermissionUtil.checkContainPhoneStateHasForbid((Activity) Cocos2dxActivity.getContext());
	}

	public static boolean isFirstStart(){
		SharedPreferences sp = Cocos2dxActivity.getContext().getSharedPreferences("firstConfig",
				Context.MODE_PRIVATE);
		boolean permitOpen = sp.getBoolean("firstStart", false);

		if (!permitOpen) {
			SharedPreferences.Editor editor = sp.edit();
			editor.putBoolean("firstStart", true);
			editor.commit();
		}

		return permitOpen;
	}

	public static void restartApp() {
		// Intent intent =
		// Cocos2dxActivity.getContext().getPackageManager().getLaunchIntentForPackage(Cocos2dxActivity.getContext().getPackageName());
		// intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		// PendingIntent restartIntent =
		// PendingIntent.getActivity(Cocos2dxActivity.getContext(), 0, intent,
		// Intent.FLAG_ACTIVITY_NEW_TASK);
		// AlarmManager mgr =
		// (AlarmManager)Cocos2dxActivity.getContext().getSystemService(Context.ALARM_SERVICE);
		// mgr.set(AlarmManager.RTC, System.currentTimeMillis(), restartIntent);
		// android.os.Process.killProcess(android.os.Process.myPid());

	}

	public static void putSharedString(String key, String value){
		CommonUtils.putSharedString(key, value);
	}

	public static void hideEditDialog(){
		((AppActivity) Cocos2dxActivity.getContext()).closeEditDialog();
	}

	public static void setIsHideVirtualKey(final boolean flag) {
		SharedPreferences sp = AppActivity.getContext().getSharedPreferences("gameConfig", Context.MODE_PRIVATE);
		if (sp == null) {
			return;
		}
		boolean isHideVirtualKey = sp.getBoolean("isHideVirtualKey", false);
		if (isHideVirtualKey != flag) {
			boolean finalFlag = Build.VERSION.SDK_INT >= 19 ? flag : false;
			SharedPreferences.Editor editor = sp.edit();
			editor.putBoolean("isHideVirtualKey", finalFlag);
			editor.commit();
		}
	}

	public static boolean isAppInstalled(String appName) {
		return CommonUtils.isAppInstalled(appName);
	}

	// 上报用户信息(用户 ID)
	public static void uploadUserInfo(final String params) {
        Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
            @Override
            public void run() {
                try {
                    JSONObject jsonObject = new JSONObject(params);
                    String mid = jsonObject.getString("mid");
                    if (mid != null) {
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }, 50);
    }

	private static void callErrorFunc(final int callback) {
		if (callback == 0) {
			return;
		}

		Cocos2dxActivityUtil.runOnResumed(new Runnable() {
			@Override
			public void run() {
				Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
					@Override
					public void run() {
						if (callback != -1) {
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callback, "failed");
						}
					}
				});
			}
		});
	}

	public static void awakeMsgIntent(final String shortCode, final String msgContent){
		if(shortCode == null || "".equals(shortCode) ||
			msgContent == null || "".equals(msgContent)
		){
			return;
		}

		try{
			Intent intent = new Intent(Intent.ACTION_SENDTO, Uri.parse("smsto:" + shortCode));
            intent.putExtra("sms_body", msgContent);
            Cocos2dxActivity.getContext().startActivity(intent);
		}catch(Exception e){
			e.printStackTrace();
		}
	}

	public static void callBackToLua(final String params, final int callback, boolean delay) {
		Log.d(TAG, "callBackToLua " + params + " callback = " + callback + " delay = " + delay);
		if(delay) {
			Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
			if(ctx != null) {
				Cocos2dxActivityUtil.runOnResumed(new Runnable() {
					@Override
					public void run() {
						Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
							@Override
							public void run() {
								Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callback, params);
								Cocos2dxLuaJavaBridge.releaseLuaFunction(callback);
							}
						}, 50);
					}
				});
			}
		} else {
			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
				@Override
				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callback, params);
							Cocos2dxLuaJavaBridge.releaseLuaFunction(callback);
						}
					});
				}
			});
		}
	}

	/**
	 *  获取版本信息
	 * @param requestStr 预留字段，以后扩展需要
	 * @return string
	 */
	public static String getVersionInfo(String requestStr) {
		String versionInfoStr = "";
		try {
			JSONObject versionInfoJson = new JSONObject();
			versionInfoJson.put("packageName", CommonUtils.getPackageName(Cocos2dxActivity.getContext()).toString());
			versionInfoJson.put("soVersion", CommonUtils.getBuildInfo(Cocos2dxActivity.getContext()));
			versionInfoStr = versionInfoJson.toString();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return versionInfoStr;
	}

	public static String getSystemFontSize() {
		try{
			Configuration mCurConfig = Cocos2dxActivity.getContext().getResources().getConfiguration();
			return mCurConfig.fontScale + "";
		}catch (Exception e){
			e.printStackTrace();
		}

		return "0";
	}
}
