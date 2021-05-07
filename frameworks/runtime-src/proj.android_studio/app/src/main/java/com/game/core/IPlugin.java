package com.game.core;


public interface IPlugin {
	void initialize();
	void setId(String id);
	void permissionResult(int requestCode,
			String[] permissions, int[] grantResults);
	void onResume();
	void onPause();
}
