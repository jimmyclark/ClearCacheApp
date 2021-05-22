package org.cocos2dx.lib;

import java.io.UnsupportedEncodingException;
import java.lang.reflect.Method;
import java.net.URI;
import java.net.URLDecoder;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.webkit.ConsoleMessage;
import android.webkit.ConsoleMessage.MessageLevel;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import android.widget.ProgressBar;
import android.widget.Toast;

public class Cocos2dxWebView extends WebView {
	private static final String TAG = Cocos2dxWebViewHelper.class.getSimpleName();

	private int mViewTag;
	private String mJSScheme;
	private String isHTMLUrl;
	private Cocos2dxWeb web;
	private ProgressBar loading_bar;
	private boolean isHideLoading = false;
	private Context m_context;

	public Cocos2dxWeb getWeb() {
		return web;
	}

	public Cocos2dxWebView(Context context) throws Exception {
		this(context, -1);
	}

	@SuppressLint("SetJavaScriptEnabled")
	public Cocos2dxWebView(Context context, int viewTag) throws Exception {
		super(context);
		this.mViewTag = viewTag;
		this.mJSScheme = "";
		this.isHTMLUrl = "";
		this.isHideLoading = false;
		this.m_context = context;

		this.setFocusable(true);
		this.setFocusableInTouchMode(true);
		this.setBackgroundColor(0);
		this.setScalesPageToFit(true);
		this.getSettings().setSupportZoom(false);
		this.getSettings().setDomStorageEnabled(true);
		this.getSettings().setJavaScriptEnabled(true);
//		this.getSettings().setUseWideViewPort(true);
//		this.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
//		this.requestFocus();
		this.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);

		// `searchBoxJavaBridge_` has big security risk. http://jvn.jp/en/jp/JVN53768697
		try {
			Method method = this.getClass().getMethod("removeJavascriptInterface", new Class[] { String.class });
			method.invoke(this, "searchBoxJavaBridge_");
		} catch (Exception e) {
			Log.d(TAG, "This API level do not support `removeJavascriptInterface`");
		}

		web = new Cocos2dxWeb(context);
		this.addJavascriptInterface(web, "client");

		this.setWebViewClient(new Cocos2dxWebViewClient());
		this.setWebChromeClient(new Cocos2dxWebChromeClient());
	}

	public void setJavascriptInterfaceScheme(String scheme) {
		this.mJSScheme = scheme != null ? scheme : "";
	}

	public void setScalesPageToFit(boolean scalesPageToFit) {
		this.getSettings().setSupportZoom(scalesPageToFit);
	}

    class Cocos2dxWebChromeClient extends WebChromeClient{

        @Override
        public void onProgressChanged(WebView view, int newProgress) {
            super.onProgressChanged(view, newProgress);
            if(newProgress >= 100){
                hideLoading();
            }else{
            	showLoading();
            }

        }

        @Override
		public boolean onConsoleMessage(ConsoleMessage consoleMessage) {
        	MessageLevel level = consoleMessage.messageLevel();
        	String msg = consoleMessage.message();
        	int lineNumber = consoleMessage.lineNumber();

        	String content = null;
        	if(level.equals(MessageLevel.ERROR)){
        		content = String.format("[- ERROR -] : %s, lineNumber = [%s]", msg, lineNumber);
        	}else if(level.equals(MessageLevel.DEBUG)){
        		content = String.format("[- DEBUG -] : %s, lineNumber = [%s]", msg, lineNumber);
        	}else if(level.equals(MessageLevel.LOG)){
        		content = String.format("[- LOG -] : %s, lineNumber = [%s]", msg, lineNumber);
        	}

        	if(content != null){
        		web.backToLua("-999",content);
        	}

			return super.onConsoleMessage(consoleMessage);
		}

		@Override
		public void onConsoleMessage(String message, int lineNumber, String sourceID) {
			String content = String.format("[- ERROR -] : %s, lineNumber = [%s]",
					message, lineNumber);

			if(content != null){
        		web.backToLua("-999",content);
        	}

			super.onConsoleMessage(message, lineNumber, sourceID);
		}

	}

	class Cocos2dxWebViewClient extends WebViewClient {
		@Override // below 24
		public boolean shouldOverrideUrlLoading(WebView view, String urlString) {
			if (urlString.startsWith("http:") || urlString.startsWith("https:")) {
				view.stopLoading();
				urlString = urlString.replaceAll("\\{", "%7B");
				urlString = urlString.replaceAll("\\}", "%7D");
				view.loadUrl(urlString);

				URI uri = null;
				try{
					uri = URI.create(urlString);
				}catch(Exception e){
					e.printStackTrace();
				}

				if (uri != null && uri.getScheme().equals(mJSScheme)) {
					Cocos2dxWebViewHelper._onJsCallback(mViewTag, urlString);
					return true;
				}
				return Cocos2dxWebViewHelper._shouldStartLoading(mViewTag, urlString);
			} else if (urlString.startsWith("sms:")) {
				handleSMSLink(urlString);
				return true;
			} else {
				try {
					Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(urlString));
					Cocos2dxActivity.getContext().startActivity(intent);
				} catch (Exception e) {

				}
				return true;
			}
		}

		@Override // over 24
		public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
			String urlString = request.getUrl().toString();
			if (urlString.startsWith("http:") || urlString.startsWith("https:")) {
				view.stopLoading();
				urlString = urlString.replaceAll("\\{", "%7B");
				urlString = urlString.replaceAll("\\}", "%7D");
				view.loadUrl(urlString);

				URI uri = null;
				try{
					uri = URI.create(urlString);
				}catch(Exception e){
					e.printStackTrace();
				}

				if (uri != null && uri.getScheme().equals(mJSScheme)) {
					Cocos2dxWebViewHelper._onJsCallback(mViewTag, urlString);
					return true;
				}
				return Cocos2dxWebViewHelper._shouldStartLoading(mViewTag, urlString);
			} else if (urlString.startsWith("sms:")) {
				handleSMSLink(urlString);
				return true;
			} else {
				try {
					Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(urlString));
					Cocos2dxActivity.getContext().startActivity(intent);
				} catch (Exception e) {

				}
				return true;
			}
		}

		public void onPageFinished(WebView view, String url) {
			if (isHTMLUrl != null && isHTMLUrl.equals(url)) {
				return;
			}

			isHTMLUrl = url;
			super.onPageFinished(view, url);

			Cocos2dxWebViewHelper._didFinishLoading(mViewTag, url);
		}

		@Override
		public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
			hideLoading();

			super.onReceivedError(view, errorCode, description, failingUrl);
			Cocos2dxWebViewHelper._didFailLoading(mViewTag, failingUrl);
		}
	}

	public void hideLoading() {
		// Log.d("Cocos2dxWebView", " progress ---> hideLoading");
		if (loading_bar != null) {
			loading_bar.clearAnimation();
			loading_bar.setVisibility(View.GONE);
			View parentView = (View) loading_bar.getParent();
			if (parentView != null) {
				((ViewGroup) parentView).removeView(loading_bar);
			}
			loading_bar = null;
		}
		this.isHideLoading = true;
	}

	public void showLoading() {
		this.isHideLoading = false;
		// Log.d("Cocos2dxWebView", " progress ---> showLoading " + this.isHideLoading);
		if (null != loading_bar) {
			loading_bar.setVisibility(View.VISIBLE);
		}
	}

	public void setWebViewRect(int left, int top, int maxWidth, int maxHeight) {
		// Log.d("Cocos2dxWebView", " progress ---> setWebViewRect " +
		// this.isHideLoading);
		FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT,
				FrameLayout.LayoutParams.WRAP_CONTENT);
		layoutParams.leftMargin = left;
		layoutParams.topMargin = top;
		layoutParams.width = maxWidth;
		layoutParams.height = maxHeight;
		layoutParams.gravity = Gravity.TOP | Gravity.LEFT;
		this.setLayoutParams(layoutParams);

		if (loading_bar == null && !this.isHideLoading) {
			loading_bar = new ProgressBar(this.getContext(), null, android.R.attr.progressBarStyleInverse);
			View parentView = (View) this.getParent();
			if (parentView != null) {
				((ViewGroup) parentView).addView(loading_bar);
			}
		}
		if (loading_bar != null) {
			int barWidth = 48, barHeight = 48;
			FrameLayout.LayoutParams loadingParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT,
					FrameLayout.LayoutParams.WRAP_CONTENT);
			loadingParams.leftMargin = left + maxWidth / 2 - barWidth / 2;
			loadingParams.topMargin = top + maxHeight / 2 - barHeight / 2;
			loadingParams.gravity = Gravity.TOP | Gravity.LEFT;
			loading_bar.setLayoutParams(loadingParams);
			AlphaAnimation alphaAnimation = new AlphaAnimation(0, 1);
			loading_bar.setAnimation(alphaAnimation);
			alphaAnimation.setFillAfter(true);
			alphaAnimation.setDuration(1000);
			alphaAnimation.setAnimationListener(new Animation.AnimationListener() {
				@Override
				public void onAnimationStart(Animation animation) {
				}

				@Override
				public void onAnimationEnd(Animation animation) {
					if (loading_bar != null) {
						loading_bar.clearAnimation();
					}
				}

				@Override
				public void onAnimationRepeat(Animation animation) {
				}
			});
		}
	}

	protected void handleSMSLink(String url) {
		/*
		 * If you want to ensure that your intent is handled only by a text messaging
		 * app (and not other email or social apps), then use the ACTION_SENDTO action
		 * and include the "smsto:" data scheme
		 */

		// Initialize a new intent to send sms message
		Intent intent = new Intent(Intent.ACTION_SENDTO);

		// Extract the phoneNumber from sms url
		String phoneNumber = url.split("[:?]")[1];

		if (!TextUtils.isEmpty(phoneNumber)) {
			// Set intent data
			// This ensures only SMS apps respond
			intent.setData(Uri.parse("smsto:" + phoneNumber));

			// Alternate data scheme
			// intent.setData(Uri.parse("sms:" + phoneNumber));
		} else {
			// If the sms link built without phone number
			intent.setData(Uri.parse("smsto:"));

			// Alternate data scheme
			// intent.setData(Uri.parse("sms:" + phoneNumber));
		}

		// Extract the sms body from sms url
		if (url.contains("body=")) {
			String smsBody = url.split("body=")[1];

			// Encode the sms body
			try {
				smsBody = URLDecoder.decode(smsBody, "UTF-8");
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}

			if (!TextUtils.isEmpty(smsBody)) {
				// Set intent body
				intent.putExtra("sms_body", smsBody);
			}
		}

		if (this.m_context != null) {
			if (intent.resolveActivity(m_context.getPackageManager()) != null) {
				// Start the sms app
				this.m_context.startActivity(intent);
			} else {
				Toast.makeText(this.m_context, "No SMS app found.", Toast.LENGTH_SHORT).show();
			}
		}
	}

}
