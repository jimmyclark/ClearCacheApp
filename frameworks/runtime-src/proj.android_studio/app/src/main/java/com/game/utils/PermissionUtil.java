package com.game.utils;

import java.util.ArrayList;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONObject;

import com.game.core.Cocos2dxActivityUtil;
import com.game.core.ConstantValue;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.Build;
import androidx.core.app.ActivityCompat;
import android.util.Log;

/**
 * 暂时放这里，因为底层的权限管理是都要的，但是又没有统一处理 Created by amnon on 2017/3/16.
 */

public class PermissionUtil {
	private static final String TAG = "PermissionUtil";

	private static final String STO_KEY = "stoSetting";
	private static final String PHONE_KEY = "phoneSetting";

	public static int stoCallBack = -1;
	public static int readPhoneAuthenCallBack = -1;

	/**
	 * 检查所有权限
	 */
	public static void checkAllPermission(Activity activity, int phoneCallBack) {
		if (Build.VERSION.SDK_INT < 23) {
			return;
		}

		// 三个权限 放入列表中
		ArrayList<String> permissions = new ArrayList<String>();
		permissions.add(Manifest.permission.READ_PHONE_STATE);
		permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);

		try {
			if (checkContainPhoneState(activity.getApplicationContext()) == 1) {
				Log.d(TAG, "remove PHONE State");
				removeFromArrayList(permissions, Manifest.permission.READ_PHONE_STATE);
			} else {
				Log.d(TAG, "not contain read-phone-state");
				// 检查电话权限是否被永久禁止了
				if (checkContainPhoneStateHasForbid(activity) == 1) {
					Log.d(TAG, "永久禁止了电话权限");
					removeFromArrayList(permissions, Manifest.permission.READ_PHONE_STATE);

				} else {
					Log.d(TAG, "电话权限未被永久禁止");
				}
			}

			if (checkContainExternalStorateState(activity.getApplicationContext()) == 1) {
				Log.d(TAG, "remove Storage State");
				removeFromArrayList(permissions, Manifest.permission.WRITE_EXTERNAL_STORAGE);
			} else {
				Log.d(TAG, "not contain write-external-storate");
				// 检查c存储权限是否被永久禁止了
				if (checkContainStorageStateHasForbid(activity) == 1) {
					Log.d(TAG, "永久禁止了存储权限");
					removeFromArrayList(permissions, Manifest.permission.WRITE_EXTERNAL_STORAGE);

				} else {
					Log.d(TAG, "存储权限未被永久禁止");
				}
			}

			Log.d(TAG, "未授权的权限有" + permissions);

			ArrayList<String> needPopupPermissions = new ArrayList<String>();
			for (int i = 0; i < permissions.size(); i++) {
				if (needPopupPermissions.size() < 2) {
					if (permissions.get(i) == Manifest.permission.READ_PHONE_STATE) {
						putSharedPreference(activity.getApplicationContext(), PHONE_KEY);
					} else if (permissions.get(i) == Manifest.permission.WRITE_EXTERNAL_STORAGE) {
						putSharedPreference(activity.getApplicationContext(), STO_KEY);
					}
					needPopupPermissions.add(permissions.get(i));
				}
			}

			Log.d(TAG, "启动弹出来的权限有" + needPopupPermissions);

			if (needPopupPermissions.size() > 0) {
				readPhoneAuthenCallBack = phoneCallBack;
				ActivityCompat.requestPermissions(activity, (String[]) needPopupPermissions.toArray(new String[0]),
						PERMISSIONS_ALL);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * 检查存储权限是否被永久禁止了
	 *
	 * @return 1 表示永久禁止了
	 * @return 0 表示未永久禁止或者SDK 小于23
	 */
	public static int checkContainStorageStateHasForbid(Activity activity) {
		if (Build.VERSION.SDK_INT < 23) {
			return 0;
		}

		try {
			boolean isRefuse = ActivityCompat.shouldShowRequestPermissionRationale(activity,
					Manifest.permission.WRITE_EXTERNAL_STORAGE);
			if (isRefuse) {
				Log.d(TAG, "存储权限未选择永久禁止");
				return 0;

			} else {
				if (getSharedPreference(activity.getApplicationContext(), STO_KEY)) {
					Log.d(TAG, "存储权限选择了永久禁止");
					return 1;

				} else {
					Log.d(TAG, "存储权限第一次设置值，走禁止逻辑");
					return 0;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			return 0;
		}

	}

	/**
	 * 检查是否含有存储权限
	 *
	 * @return 1 表示已授权或SDK小于23
	 * @return 0 表示未授权
	 */
	public static int checkContainExternalStorateState(Context context) {
		if (Build.VERSION.SDK_INT < 23) {
			return 1;
		}

		try {
			return ActivityCompat.checkSelfPermission(context,
					Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED ? 1 : 0;
		} catch (Exception e) {
			e.printStackTrace();
			return 1;
		}
	}

	/**
	 * 打开手机存储卡权限
	 *
	 * @param callback
	 *            回调
	 */
	public static void openExternalStorageState(Activity activity, int callback) {
		try {
			stoCallBack = callback;
			ActivityCompat
					.requestPermissions(activity,
							new String[] { Manifest.permission.WRITE_EXTERNAL_STORAGE,
									Manifest.permission.READ_EXTERNAL_STORAGE },
							PERMISSIONS_REQUEST_WRITE_EXTERNAL_STORAGE);
			putSharedPreference(activity.getApplicationContext(), STO_KEY);
		} catch (Exception e) {
			e.printStackTrace();
			stoCallBack = -1;
		}
	}

	/**
	 * 检查是否含有电话权限
	 *
	 * @return 1 表示已授权或SDK小于23
	 * @return 0 表示未授权
	 */
	public static int checkContainPhoneState(Context context) {
		if (Build.VERSION.SDK_INT < 23) {
			return 1;
		}

		try {
			return ActivityCompat.checkSelfPermission(context,
					Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED ? 1 : 0;
		} catch (Exception e) {
			e.printStackTrace();
			return 1;
		}
	}

	/**
	 * 检查电话权限是否被永久禁止了
	 *
	 * @return 1 表示永久禁止了
	 * @return 0 表示未永久禁止或者SDK 小于23
	 */
	public static int checkContainPhoneStateHasForbid(Activity activity) {
		if (Build.VERSION.SDK_INT < 23) {
			return 0;
		}

		try {
			boolean isRefuse = ActivityCompat.shouldShowRequestPermissionRationale(activity,
					Manifest.permission.READ_PHONE_STATE);
			if (isRefuse) {
				Log.d(TAG, "电话权限未选择永久禁止");
				return 0;

			} else {
				if (getSharedPreference(activity.getApplicationContext(), PHONE_KEY)) {
					Log.d(TAG, "电话权限选择了永久禁止");
					return 1;

				} else {
					Log.d(TAG, "电话权限第一次设置值，走禁止逻辑");
					return 0;
				}

			}
		} catch (Exception e) {
			e.printStackTrace();
			return 0;
		}

	}

	/**
	 * 打开电话权限
	 *
	 * @param callback
	 *            回调
	 */
	public static void openPhoneState(Activity activity, int callback) {
		try {
			readPhoneAuthenCallBack = callback;
			ActivityCompat.requestPermissions(activity, new String[] { Manifest.permission.READ_PHONE_STATE },
					PERMISSIONS_REQUEST_READ_PHONE_STATE);
			putSharedPreference(activity.getApplicationContext(), PHONE_KEY);
		} catch (Exception e) {
			e.printStackTrace();
			readPhoneAuthenCallBack = -1;
		}
	}

	/**
	 * 申请权限回调使用常量
	 */
	public final static int PERMISSIONS_REQUEST_READ_PHONE_STATE = 1001;
	public final static int PERMISSIONS_REQUEST_WRITE_EXTERNAL_STORAGE = 1002;
	public static final int PERMISSIONS_ALL = 1010;

	public static void callLuaReadPhoneCallbackMethod() {
		if (readPhoneAuthenCallBack != -1) {
			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
				@Override
				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							JSONObject changeJsons = new JSONObject();
							try {
								ConstantValue.device_user.setMac(CommonUtils.getMac(Cocos2dxActivity.getContext()));
								ConstantValue.device_user.setUniqueId(CommonUtils.getUniqueId());
								ConstantValue.device_user.setAndroidId(CommonUtils.getAndroidId(Cocos2dxActivity.getContext()));
								ConstantValue.device_user.setDeviceId(CommonUtils.getDeviceId(Cocos2dxActivity.getContext()));
								ConstantValue.device_user.setImei(CommonUtils.getImei(Cocos2dxActivity.getContext()));

								changeJsons.put("imei", ConstantValue.device_user.getImei());
								changeJsons.put("mac", ConstantValue.device_user.getMac());
								changeJsons.put("uniqueId", ConstantValue.device_user.getUniqueId());
								changeJsons.put("androidId", ConstantValue.device_user.getAndroidId());
								changeJsons.put("deviceId",ConstantValue.device_user.getDeviceId());

							} catch (Exception e) {
								e.printStackTrace();
							}

							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(readPhoneAuthenCallBack, changeJsons.toString());
							readPhoneAuthenCallBack = -1;
						}
					});
				}
			});
		}
	}

	public static void callLuaOpenStoCallBackMethod() {
		if (stoCallBack != -1) {
			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
				@Override
				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(stoCallBack, "");
							stoCallBack = -1;
						}
					});
				}
			});
		}
	}

	public static boolean getSharedPreference(Context context, String key) {
		SharedPreferences sp = context.getSharedPreferences("firstConfig", Context.MODE_PRIVATE);
		boolean permitOpen = sp.getBoolean(key, false);
		Log.d(TAG, "取值： " + key + "= " + (permitOpen ? "true" : "false"));
		return permitOpen;
	}

	public static void putSharedPreference(Context context, String key) {
		SharedPreferences sp = context.getSharedPreferences("firstConfig", Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = sp.edit();
		editor.putBoolean(key, true);
		Log.d(TAG, "设置值： " + key + "= true ");
		editor.commit();
	}

	public static boolean removeFromArrayList(ArrayList<String> needRemoveList, String needRemove) {
		if (needRemoveList.size() <= 0) {
			return false;
		}
		for (int i = 0; i < needRemoveList.size(); i++) {
			if (needRemoveList.get(i) == needRemove) {
				needRemoveList.remove(i);
				return true;
			}
		}

		return false;
	}
}
