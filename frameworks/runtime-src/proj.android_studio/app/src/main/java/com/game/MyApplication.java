package com.game;

import android.app.Application;
import android.content.Context;
import android.content.res.Configuration;
import android.util.Log;

import androidx.multidex.MultiDex;

public class MyApplication extends Application {

	public static final String TAG = MyApplication.class.getName();
	private boolean isStartDialogShow = false;

	@Override
	public void onCreate() {
		super.onCreate();
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		Log.d(TAG, "onConfigurationChanged");
		super.onConfigurationChanged(newConfig);
	}

	public boolean isStartDialogShow() {
		return this.isStartDialogShow;
	}

	public void setIsStartDialogShowed(boolean isShowed) {
		this.isStartDialogShow = isShowed ? true : false;
	}

	@Override
	protected void attachBaseContext(Context base) {
		super.attachBaseContext(base);
		try{
			// 将MultiDex注入到项目中
			MultiDex.install(this);
		}catch (Exception e){
			e.printStackTrace();
		}
	}
}
