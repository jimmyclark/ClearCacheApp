package org.cocos2dx.lua;

import android.app.Dialog;
import android.content.Context;
import android.os.Message;
import android.view.View;
import android.widget.TextView;

import com.bigfoot.clearcache.R;

import org.cocos2dx.lib.Cocos2dxActivity;

public class StartDialog extends Dialog {
	private TextView cannt_boot_field;
	private TextView clickToCancel;
	@Override
	public void dismiss() {
		if(isShowDialog){
			isShowDialog = false;
			super.dismiss();
		}
	}

	private static final long CLOSE_TIME = 3000;
	private long startTime = 0;
	private boolean isShowDialog = false;
	
	@Override
	public void show() {
		if(!isShowDialog){
			super.show();
			isShowDialog = true;
			startTime = System.currentTimeMillis();
		}
	}
	
	public long getDistantStartTime(long endTime){
		return endTime - startTime;
	}

	public long getDelayTime(){
		long currentTime = System.currentTimeMillis();
		long hasTime = currentTime - startTime;
		
		//还剩时间
		return CLOSE_TIME - hasTime;
		
	}
	
	public StartDialog(Context context, int themeResId) {
		super(context, themeResId);
	}

	public StartDialog(Context context) {
		super(context);
	}

	protected StartDialog(Context context, boolean cancelable, OnCancelListener cancelListener) {
		super(context, cancelable, cancelListener);
	}
}
