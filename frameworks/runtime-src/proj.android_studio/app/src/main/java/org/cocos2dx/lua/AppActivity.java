/****************************************************************************
 Copyright (c) 2008-2010 Ricardo Quesada
 Copyright (c) 2010-2012 cocos2d-x.org
 Copyright (c) 2011      Zynga Inc.
 Copyright (c) 2013-2014 Chukong Technologies Inc.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
package org.cocos2dx.lua;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.ActionBar;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;

import com.game.MyApplication;
import com.game.core.Cocos2dxActivityWrapper;
import com.game.core.ConstantValue;
import com.game.core.PluginManager;
import com.game.utils.CommonUtils;
import com.game.utils.PermissionUtil;

import com.app.clearcache.R;

public class AppActivity extends Cocos2dxActivityWrapper {
    public final String TAG = AppActivity.class.getSimpleName();
    private View decorView = null;

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if (startDialog != null && startDialog.isShowing()) {
            startDialog.dismiss();
        }
        startDialog = null;
    }

    private boolean isDebug = false;

    public static Context STATIC_REF = null;
    public static StartDialog startDialog;

    public static Cocos2dxActivityWrapper getContext() {
        return (Cocos2dxActivityWrapper) STATIC_REF;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        hideNavigationBar();

        STATIC_REF = this;

        addShortcutNeeded(R.string.app_name, R.drawable.icon);

        if (getIntent() != null) {
            Intent myIntent = getIntent();
            ConstantValue.google_push_action = myIntent.getStringExtra("bf_push_action");
            ConstantValue.google_push_id = myIntent.getStringExtra("bf_push_id");
            ConstantValue.google_push_sid = myIntent.getStringExtra("bf_login_type");
        }

		//初始化用户信息
		ConstantValue.device_user = CommonUtils.initUserInfo();

        if (getApp() != null && !getApp().isStartDialogShow() && startDialog == null) {
			try{
	            startDialog = new StartDialog(this, android.R.style.Theme_Translucent_NoTitleBar);
	            startDialog.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
					WindowManager.LayoutParams.FLAG_FULLSCREEN);
	            hideDialogNavigationBar(startDialog);
	            startDialog.setContentView(R.layout.start_screen);
	            startDialog.setCancelable(false);
	            startDialog.show();
	            getApp().setIsStartDialogShowed(true);
			}catch(Exception e){

			}
        }
    }

    @Override
    protected void onStart() {
        super.onStart();
    }

	private Message getMessageByWhat(int whatMsg){
		Message msg = new Message();
		msg.what = whatMsg;
		msg.obj = STATIC_REF;
		return msg;
	}

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    public void onPause() {
        super.onPause();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        getIntent().putExtras(intent);
    }

    @Override
    protected void onSetupPlugins(PluginManager pluginManager) {
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        pluginManager.getPlugin("FACEBOOK").permissionResult(requestCode, permissions, grantResults);
        if (Build.VERSION.SDK_INT < 23) {
            return;
        }

        for (int i = 0; i < grantResults.length; i++) {
            //判断权限的结果，如果有被拒绝，就return
            if (grantResults[i] == PackageManager.PERMISSION_GRANTED) {
                if (Manifest.permission.READ_PHONE_STATE.equals(permissions[i])) {
                    PermissionUtil.callLuaReadPhoneCallbackMethod();

                } else if (Manifest.permission.WRITE_EXTERNAL_STORAGE.equals(permissions[i])) {
                    PermissionUtil.callLuaOpenStoCallBackMethod();

                }
            }
        }
    }


    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        Log.d(TAG, "onConfigurationChanged");
        super.onConfigurationChanged(newConfig);
    }

    public MyApplication getApp() {
		Context context = null;
		try {
			context = (MyApplication) getApplicationContext();
		} catch (Exception e) {

		}
		return (MyApplication) context;

    }

    public void closeEditDialog() {
        super.hideEditTextDialog();
    }

    @SuppressLint("NewApi")
    public void hideNavigationBar() {
        if (!getIsCurHideVirtualKey()) {
            return;
        }
        decorView = getWindow().getDecorView();
        if (decorView == null) {
            return;
        }
        if (Build.VERSION.SDK_INT >= 21) {
            decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
            getWindow().setStatusBarColor(Color.TRANSPARENT);
            getWindow().setNavigationBarColor(Color.TRANSPARENT);
            ActionBar actionBar = getActionBar();
            if (actionBar != null) {
                actionBar.hide();
            }
        } else if (Build.VERSION.SDK_INT >= 19) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
            decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                    | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
        }
    }

    @SuppressLint("NewApi")
    public void hideDialogNavigationBar(Dialog dialog) {
        if (dialog == null) {
            return;
        }
        if (!getIsCurHideVirtualKey()) {
            return;
        }
        View decorView = dialog.getWindow().getDecorView();
        if (decorView == null) {
            return;
        }
        if (Build.VERSION.SDK_INT >= 21) {
            decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
            dialog.getWindow().setStatusBarColor(Color.TRANSPARENT);
            dialog.getWindow().setNavigationBarColor(Color.TRANSPARENT);
            ActionBar actionBar = dialog.getActionBar();
            if (actionBar != null) {
                actionBar.hide();
            }
        } else if (Build.VERSION.SDK_INT >= 19) {
            dialog.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            dialog.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
            decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                    | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
        }
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        Log.d(TAG, "virtual_key_debug onWindowFocusChanged hasFocus = " + hasFocus);
        if (hasFocus) {
            hideNavigationBar();
        }
    }

}
