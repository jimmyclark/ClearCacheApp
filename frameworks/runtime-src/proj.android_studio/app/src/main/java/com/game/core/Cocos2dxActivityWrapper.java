package com.game.core;

import java.util.ArrayList;
import java.util.List;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.cocos2dx.utils.PSNative;
import org.cocos2dx.utils.PSNetwork;

import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.pm.PackageInfo;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Parcelable;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.util.Log;

public abstract class Cocos2dxActivityWrapper extends Cocos2dxActivity implements ILifecycleNotifier{
	protected final String TAG = getClass().getSimpleName();
	protected abstract void onSetupPlugins(PluginManager pluginManager);

	protected PluginManager pluginManager = new PluginManager();
	protected LifecycleNotifierImpl lifecycleNotifier = new LifecycleNotifierImpl();
	protected Handler uiThreadHandler;
	protected Handler bgThreadHandler;

	protected HandlerThread handlerThread;
	private boolean isResumed = false;

	protected List<Runnable> callOnResumedQueue = new ArrayList<Runnable>();
	private PowerManager pManager;
	private WakeLock mWakeLock;

	public static Cocos2dxActivityWrapper getContext() {
		return (Cocos2dxActivityWrapper)Cocos2dxActivity.getContext();
	}

	public PluginManager getPluginManager() {
		return pluginManager;
	}

	public void runOnResumed(Runnable runnable) {
		if (isResumed) {
			runnable.run();
		} else {
			synchronized (callOnResumedQueue) {
				callOnResumedQueue.add(runnable);
			}
		}
	}

	public Handler getUIThreadHandler() {
		return uiThreadHandler;
	}

	public Handler getBackgroundThreadHandler() {
		return bgThreadHandler;
	}

	@Override
	public void addObserver(ILifecycleObserver observer) {
		// TODO Auto-generated method stub
		lifecycleNotifier.addObserver(observer);
	}

	@Override
	public void removeObserver(ILifecycleObserver observer) {
		// TODO Auto-generated method stub
		lifecycleNotifier.removeObserver(observer);
	}

	@Override
	public Cocos2dxGLSurfaceView onCreateView() {
		// TODO Auto-generated method stub
		Cocos2dxGLSurfaceView glSurfaceView = new Cocos2dxGLSurfaceView(this);
		glSurfaceView.setEGLConfigChooser(5, 6, 5, 0, 16, 8);
		return glSurfaceView;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		Log.d(TAG, "onCreate");

		handlerThread = new HandlerThread(getClass().getName() + ".handlerThread") {
			@Override
			public void run() {
				final UncaughtExceptionHandler handler = Thread.getDefaultUncaughtExceptionHandler();
				Thread.setDefaultUncaughtExceptionHandler(new UncaughtExceptionHandler() {

					@Override
					public void uncaughtException(Thread thread, Throwable ex) {
						// TODO Auto-generated method stub
						Log.e(TAG, "thread(" + ")[" + thread.getName() + "] uncaught error:" + ex.getMessage(), ex);
						if (handler != null) {
							handler.uncaughtException(thread, ex);
						}
					}
				});
				super.run();
			};
		};
		handlerThread.start();
		bgThreadHandler = new Handler(handlerThread.getLooper());
		bgThreadHandler.post(new Runnable() {

			@Override
			public void run() {
				// TODO Auto-generated method stub
				Log.d(TAG, "bgThreadHandler" + Thread.currentThread().getId());
			}
		});

		Log.d(TAG, "bgThreadHandler" + Thread.currentThread().getId());

		uiThreadHandler = new Handler(getMainLooper());
		onSetupPlugins(pluginManager);
		pluginManager.initialize();
		lifecycleNotifier.onCreate(this, savedInstanceState);
	}

	@Override
	protected void onRestoreInstanceState(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onRestoreInstanceState(savedInstanceState);
		Log.d(TAG, "onRestoreInstanceState");
		lifecycleNotifier.onRestoreInstanceState(this, savedInstanceState);
	}

	@Override
	protected void onStart() {
		// TODO Auto-generated method stub
		super.onStart();
		Log.d(TAG, "onStart");
		lifecycleNotifier.onStart(this);
	}

	@Override
	protected void onRestart() {
		// TODO Auto-generated method stub
		super.onRestart();
		Log.d(TAG, "onRestart");
		lifecycleNotifier.onRestart(this);
	}

	@Override
	protected void onSaveInstanceState(Bundle outState) {
		// TODO Auto-generated method stub
		super.onSaveInstanceState(outState);
		Log.d(TAG, "onSaveInstanceState");
		lifecycleNotifier.onSaveInstanceState(this, outState);
	}

	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
		Log.d(TAG, "onPause");
		lifecycleNotifier.onPause(this);

		//释放禁止锁屏
		try {
			if (null != mWakeLock) {
				mWakeLock.release();
			}
		} catch (Exception e) {
			// TODO: handle exception
			Log.e(TAG, e.getMessage(), e);
		}
	}

	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		Log.d(TAG, "onResume");

		isResumed = true;

		while (true) {
			Runnable runnable = null;
			synchronized (callOnResumedQueue) {
				if (callOnResumedQueue.isEmpty()) {
					break;
				} else {
					runnable = callOnResumedQueue.remove(0);
				}
			}
			if (runnable != null) {
				if (bgThreadHandler != null) {
					bgThreadHandler.postDelayed(runnable, 50);
				} else {
					runnable.run();
				}
			}
		}
		try {
			//禁止锁屏
			pManager = (PowerManager)getSystemService(POWER_SERVICE);
			mWakeLock = pManager.newWakeLock(PowerManager.SCREEN_BRIGHT_WAKE_LOCK | PowerManager.ON_AFTER_RELEASE, TAG);
			mWakeLock.acquire();
		} catch (Exception e) {
			// TODO: handle exception
			Log.d(TAG, e.getMessage(), e);
		}
	}

	protected void onStop() {
		// TODO Auto-generated method stub
		super.onStop();
		Log.d(TAG, "onStop");
		isResumed = false;
	}

	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		Log.d(TAG, "onDestroy");
		isResumed = false;
		handlerThread.quit();
		handlerThread = null;
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		super.onActivityResult(requestCode, resultCode, data);
		Log.d(TAG, "onActivityResult requestCode:" + requestCode + " resultCode" + resultCode + " data:" + (data != null ? data.toString() : null));
		lifecycleNotifier.onActivityResult(this, requestCode, resultCode, data);
	}

	protected void addShortcutNeeded(int appNameId, int appIconId) {
		try {
			SharedPreferences sp = getSharedPreferences("INSTALL_SHORTCUT_VERSION_STORE", MODE_PRIVATE);
			String lastAddShortcutVersion = sp.getString("LAST_INSTALL_SHORTCUT_VERSION", null);
			PackageInfo packInfo = getPackageManager().getPackageInfo(getPackageName(), 0);
			String installedVersionName = packInfo.versionName;
			if (lastAddShortcutVersion == null || !lastAddShortcutVersion.equals(installedVersionName)) {
				removeShortcut(appNameId);
				addShortcut(appNameId, appIconId);
				Editor editor = sp.edit();
				editor.putString("LAST_INSTALL_SHORTCUT_VERSION", installedVersionName);
				editor.commit();
			}
		} catch (Exception e) {
			// TODO: handle exception
			Log.e(TAG, e.getMessage(), e);
		}
	}

	void addShortcut(int appNameId, int appIconId) {
		//添加桌面快捷方式
		 try {
			Intent shortcutIntent = new Intent("com.android.launcher.action.INSTALL_SHORTCUT");
			shortcutIntent.putExtra("duplicate", false); //不允许重复创建
			shortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_NAME, getString(appNameId));
			Parcelable icon = Intent.ShortcutIconResource.fromContext(getApplicationContext(), appIconId);
			shortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_ICON_RESOURCE, icon);
			Intent intent = getPackageManager().getLaunchIntentForPackage(getPackageName());
			shortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_INTENT, intent);
			sendBroadcast(shortcutIntent);
		} catch (Exception e) {
			// TODO: handle exception
			Log.e(TAG, e.getMessage(), e);
		}
	}

	void removeShortcut(int appNameId) {
		try {
			Intent shortcutIntent = new Intent("com.android.launcher.action.UNINSTALL_SHORTCUT");
			shortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_NAME, getString(appNameId));
			Intent intent = getPackageManager().getLaunchIntentForPackage(getPackageName());
			shortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_INTENT, intent);
			sendBroadcast(shortcutIntent);
		} catch (Exception e) {
			// TODO: handle exception
			Log.e(TAG, e.getMessage(), e);
		}
	}

	boolean hasShortcut(int appNameId) {
		boolean result = false;
		try {
			final String uriStr;
			if (android.os.Build.VERSION.SDK_INT < 8) {
				uriStr = "content://com.android.launcher.settings/favorites?notify=true";
			} else {
				uriStr = "content://com.android.launcher2.settings/favorites?notify=true";
			}
			final Uri CONTENT_URI = Uri.parse(uriStr);
			final Cursor c = getContentResolver().query(CONTENT_URI, null, "title=?", new String[]{getString(appNameId)}, null);
			if (c != null && c.getCount() > 0) {
				result = true;
			}
		} catch (Exception e) {
			// TODO: handle exception
			Log.d(TAG, e.getMessage(), e);
		}
		return result;
	}
}
