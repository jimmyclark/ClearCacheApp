package org.cocos2dx.lib;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.webkit.JavascriptInterface;

public class Cocos2dxWeb {
	private Context context;

	public Cocos2dxWeb(Context context) {
		this.context = context;
	}

	@JavascriptInterface
	public void backToLua(final String action, final String param) {

		Cocos2dxActivity ctx = (Cocos2dxActivity) Cocos2dxActivity.getContext();

		ctx.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				try {
					JSONObject jsonObject = new JSONObject();
					jsonObject.put("action", action);
					jsonObject.put("param", param);
					jsonObject.put("luaFunction", "app.module.activity.ActivityCallBack");
					Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("nativeCallBackLua", jsonObject.toString());
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}
		});
	}
	
	@JavascriptInterface
	public void backToLua(final String action) {

		Cocos2dxActivity ctx = (Cocos2dxActivity) Cocos2dxActivity.getContext();

		ctx.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				try {
					JSONObject jsonObject = new JSONObject();
					jsonObject.put("action", action);
					jsonObject.put("luaFunction", "app.module.activity.ActivityCallBack");
					Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("nativeCallBackLua", jsonObject.toString());
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}
		});
	}
}
