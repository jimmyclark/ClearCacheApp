package com.game.core;
import com.game.entity.User;

public class ConstantValue {
	public static boolean isFBInvitedSetUp;
	public static String google_push_id;
	public static String google_push_action;
	public static String google_push_sid;

	public static String google_ad_id;
	public static String dynamicLink;
	public static boolean isSendToLua;
	public static User device_user;
	public static boolean isManualClearData; // 是否手动删除数据
	public static boolean isShowClearDialog; // 是否显示了清除数据的弹框

	public static final String SHARED_PREFERENCE_IS_NEED_SECOND_START = "startDialogShowSecond"; // 用于标识上一次是操作异常清除数据操作 0表示没有过 1表示有过
	public static final String SHARED_PREFERENCE_THE_SECOND_FIXING_MANUAL = "secondFixingManual"; // 手动清除触发

	public static final String UMENG_START_FIXED_DIALOG_KEY = "startFixedDialog_V176";
	public static final String UMENG_COMMON_VALUE = "commonValue";
	public static final String UMENG_MANUAL_START_FIXED_DIALOG = "manualStartFixedDialog"; // 手动触发修复完成提示弹框
	public static final String UMENG_CERTAIN = "certain"; 							 // 确定按钮
	public static final String UMENG_SHOW_FIXING_TEXT = "showFixedText"; 			 // 显示启动异常，点击文字事件
	public static final String UMENG_CLICK_MANUAL_REMOVE_TEXT = "manualRemoveText";  // 手动删除数据
}
