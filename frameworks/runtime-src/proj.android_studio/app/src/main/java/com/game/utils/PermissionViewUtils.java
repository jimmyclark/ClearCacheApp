package com.game.utils;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.w3c.dom.Text;

import android.content.ComponentName;
import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;

public class PermissionViewUtils {
	public static void gotoPermissionView(){
		try{
			String manufacture = android.os.Build.MANUFACTURER;
			if (TextUtils.equals(manufacture.toLowerCase(), "redmi") ||
					TextUtils.equals(manufacture.toLowerCase(), "xiaomi")) {
	            gotoMiuiPermission();//小米
	        } else if (TextUtils.equals(manufacture.toLowerCase(), "meizu")) {
	            gotoMeizuPermission();
	        } else if (TextUtils.equals(manufacture.toLowerCase(), "huawei")
	        		|| TextUtils.equals(manufacture.toLowerCase(), "honor")) {
	            gotoHuaweiPermission();
	        }else if(TextUtils.equals(manufacture.toLowerCase(),"sony")){
	        	gotoSonyPermission();

	        }else if(TextUtils.equals(manufacture.toLowerCase(),"oppo")){
	        	gotoOppoPermission();

	        }else if(TextUtils.equals(manufacture.toLowerCase(),"lg")){
	        	gotoLGPermission();
	        }else {
	            goToSettingView();
	        }
		}catch(Exception e){
			goToSettingView();
		}
	}

	public static void goToPermissions(){
		PermissionViewUtils.gotoPermissionView();
	}

	private static void gotoMiuiPermission(){
		try { // MIUI 8
            Intent localIntent = new Intent("miui.intent.action.APP_PERM_EDITOR");
            localIntent.setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.PermissionsEditorActivity");
            localIntent.putExtra("extra_pkgname", Cocos2dxActivity.getContext().getPackageName());
            Cocos2dxActivity.getContext().startActivity(localIntent);
        } catch (Exception e) {
            try { // MIUI 5/6/7
                Intent localIntent = new Intent("miui.intent.action.APP_PERM_EDITOR");
                localIntent.setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.AppPermissionsEditorActivity");
                localIntent.putExtra("extra_pkgname", Cocos2dxActivity.getContext().getPackageName());
                Cocos2dxActivity.getContext().startActivity(localIntent);
            } catch (Exception e1) { // 否则跳转到应用详情
            	goToSettingView();
            }
        }
	}

    private static void gotoMeizuPermission() {
        try {
            Intent intent = new Intent("com.meizu.safe.security.SHOW_APPSEC");
            intent.addCategory(Intent.CATEGORY_DEFAULT);
            intent.putExtra("packageName", Cocos2dxActivity.getContext().getPackageName());
            Cocos2dxActivity.getContext().startActivity(intent);
        } catch (Exception e) {
            goToSettingView();
        }
    }

    private static void gotoHuaweiPermission() {
        try {
            Intent intent = new Intent();
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra("packageName", Cocos2dxActivity.getContext().getPackageName());
            ComponentName comp = new ComponentName("com.huawei.systemmanager", "com.huawei.permissionmanager.ui.MainActivity");//华为权限管理
            intent.setComponent(comp);
            Cocos2dxActivity.getContext().startActivity(intent);
        } catch (Exception e) {
            goToSettingView();
        }

    }

    private static void gotoSonyPermission(){
    	try {
			Intent intent = new Intent();
			intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			intent.putExtra("packageName", Cocos2dxActivity.getContext().getPackageName());
			ComponentName comp = new ComponentName("com.sonymobile.cta", "com.sonymobile.cta.SomcCTAMainActivity");
			intent.setComponent(comp);
			Cocos2dxActivity.getContext().startActivity(intent);
    	}catch(Exception e){
    		goToSettingView();
    	}
    }

    private static void gotoOppoPermission(){
    	try {
			Intent intent = new Intent();
			intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			intent.putExtra("packageName", Cocos2dxActivity.getContext().getPackageName());
			ComponentName comp = new ComponentName("com.color.safecenter", "com.color.safecenter.permission.PermissionManagerActivity");
			intent.setComponent(comp);
			Cocos2dxActivity.getContext().startActivity(intent);
    	}catch(Exception e){
    		goToSettingView();
    	}
    }

    private static void gotoLGPermission(){
    	try {
			Intent intent = new Intent();
			intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			intent.putExtra("packageName", Cocos2dxActivity.getContext().getPackageName());
			ComponentName comp = new ComponentName("com.android.settings", "com.android.settings.Settings$AccessLockSummaryActivity");
			intent.setComponent(comp);
			Cocos2dxActivity.getContext().startActivity(intent);
    	}catch(Exception e){
    		goToSettingView();
    	}
    }

	private static void goToSettingView(){
		try {
			Intent localIntent = new Intent();
			localIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			localIntent.setAction("android.settings.APPLICATION_DETAILS_SETTINGS");
			localIntent.setData(Uri.fromParts("package", Cocos2dxActivity.getContext().getPackageName(), null));
			Cocos2dxActivity.getContext().startActivity(localIntent);
		} catch (Exception e) {
		}
	}
}
