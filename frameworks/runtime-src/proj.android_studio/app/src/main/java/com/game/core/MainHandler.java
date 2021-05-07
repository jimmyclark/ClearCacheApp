package com.game.core;

import java.util.Timer;
import java.util.TimerTask;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lib.Cocos2dxMusic;
import org.cocos2dx.lib.Cocos2dxRenderer;
import org.cocos2dx.lua.AppActivity;
import org.json.JSONException;
import org.json.JSONObject;

import com.game.utils.CommonUtils;
import com.game.utils.FileUtils;
import com.bigfoot.clearcache.R;

import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.Gravity;
import android.widget.TextView;

public class MainHandler extends Handler {
	public final int START_CLEAR_PROMPT_TIMER = 0x000001; // 启动清除数据提示倒计时
	public final int START_CLEAR_PROMPT_DIALOG = 0x000002; // 启动清除数据提示框
	public final int REMOVE_CLEAR_AND_PROMPT_REBOOT_DIALOG = 0x00003; // 关闭之前的弹框弹出清除数据成功的弹框
	public final int REMOVE_ALL_CLEAR_PROMPT_DIALOG = 0x0004; 	// 删除的已经弹出来的弹框
	public final int SHOW_CAN_CLEAR_PROMPT_TEXT_TIMER = 0x0005; // 启动清除数据文字的倒计时 
	public final int SHOW_CAN_CLEAR_PROMPT_TEXT = 0x0006; // 显示可以清除数据的文字
	
	private static final long NEED_PROMPT_TIME = 3000; // 删除数据后再弹框
	private static final long CAN_SHOW_PROMPT_TEXT_TIME = 10000; // 显示可以清除数据文字的时间
	
	private Timer showPromptTimer;
	private Timer clearPromptTaskTimer;
	private Timer clearFolderAndRemoveTimer;
	private AlertDialog promptDialog;
	private AlertDialog rebootDialog;
	
	public void removeAllTimer(){
		if(clearPromptTaskTimer!= null){
			clearPromptTaskTimer.cancel();
		}
		
		if(showPromptTimer != null){
			showPromptTimer.cancel();
		}
	}
	
	public boolean getClearFolderAndRemoveTaskTimer(){
		return clearFolderAndRemoveTimer != null;
	}
	
	@Override
	public void handleMessage(final Message msg) {
		switch (msg.what) {
		
		case REMOVE_ALL_CLEAR_PROMPT_DIALOG:
			if (promptDialog != null) {
				promptDialog.dismiss();
			}
			
			if(rebootDialog != null){
				rebootDialog.dismiss();
			}
			
			break;
			
		case REMOVE_CLEAR_AND_PROMPT_REBOOT_DIALOG:

			break;
		case START_CLEAR_PROMPT_DIALOG:

			break;
			
		//显示启动异常主动修复文字
		case SHOW_CAN_CLEAR_PROMPT_TEXT:
			break;
			
		case SHOW_CAN_CLEAR_PROMPT_TEXT_TIMER:
			final Context promptContext = (Context) msg.obj;
			TimerTask showPromptTimerTask = new TimerTask() {
				@Override
				public void run() {
					Message msg = new Message();
					msg.what = SHOW_CAN_CLEAR_PROMPT_TEXT;
					msg.obj = promptContext;
					MainHandler.this.sendMessage(msg);
				}
			};
			showPromptTimer = new Timer();
			showPromptTimer.schedule(showPromptTimerTask, CAN_SHOW_PROMPT_TEXT_TIME);
			break;
		}
	}
}
