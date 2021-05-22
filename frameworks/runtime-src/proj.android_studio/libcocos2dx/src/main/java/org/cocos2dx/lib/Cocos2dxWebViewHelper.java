package org.cocos2dx.lib;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.graphics.Point;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.SparseArray;
import android.view.Display;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;

import java.lang.reflect.Method;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;


public class Cocos2dxWebViewHelper {
    private static final String TAG = Cocos2dxWebViewHelper.class.getSimpleName();
    private static Handler sHandler;
    private static Cocos2dxActivity sCocos2dxActivity;
    private static FrameLayout sLayout;

    private static SparseArray<Cocos2dxWebView> webViews;
    private static int viewTag = 0;
    private static Button closeBtn;
    private static Cocos2dxWebView currentWebView;

    public Cocos2dxWebViewHelper(FrameLayout layout) {
        Cocos2dxWebViewHelper.sLayout = layout;
        Cocos2dxWebViewHelper.sHandler = new Handler(Looper.myLooper());

        Cocos2dxWebViewHelper.sCocos2dxActivity = (Cocos2dxActivity) Cocos2dxActivity.getContext();
        Cocos2dxWebViewHelper.webViews = new SparseArray<Cocos2dxWebView>();
    }

    private static native boolean shouldStartLoading(int index, String message);

    public static boolean _shouldStartLoading(int index, String message) {
        return !shouldStartLoading(index, message);
    }
    
    public static Cocos2dxWebView getCurrentWebView(){
    	return currentWebView;
    }

    private static native void didFinishLoading(int index, String message);

    public static void _didFinishLoading(int index, String message) {
        didFinishLoading(index, message);
    }

    private static native void didFailLoading(int index, String message);

    public static void _didFailLoading(int index, String message) {
        didFailLoading(index, message);
    }

    private static native void onJsCallback(int index, String message);

    public static void _onJsCallback(int index, String message) {
        onJsCallback(index, message);
    }

    @SuppressWarnings("unused")
    public static int createWebView() {
        final int index = viewTag;
        sCocos2dxActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
            	try{
                    final Cocos2dxWebView webView = new Cocos2dxWebView(sCocos2dxActivity, index);
					webView.setOnKeyListener(new View.OnKeyListener() {
						@Override
						public boolean onKey(View v, int keyCode, KeyEvent event) {
							if (event.getAction() == KeyEvent.ACTION_DOWN) {
								if (keyCode == KeyEvent.KEYCODE_BACK && webView.canGoBack()) {
									webView.goBack();
									Cocos2dxGLSurfaceView.getInstance().requestFocus();
									return true;
								}
							}
							else {
								Cocos2dxGLSurfaceView.getInstance().requestFocus();
							}
							return false;
						}
					});
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
						webView.enableSlowWholeDocumentDraw();
					}
					
                    currentWebView = webView;
                    FrameLayout.LayoutParams lParams = new FrameLayout.LayoutParams(
                            FrameLayout.LayoutParams.WRAP_CONTENT,
                            FrameLayout.LayoutParams.WRAP_CONTENT);
                    webView.setBackgroundColor(0);
                    if(sLayout != null){
    	                sLayout.addView(webView, lParams);
    	                webView.setVisibility(View.INVISIBLE);
    	                webViews.put(index, webView);
                    }
            	}catch(Exception e){
            		
            	}
            }
        });
        return viewTag++;
    }

    @SuppressWarnings("unused")
    public static void removeWebView(final int index) {
        sCocos2dxActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxWebView webView = webViews.get(index);
                if (webView != null) {
                    webViews.remove(index);
                    sLayout.removeView(webView);
                }
                
                if(closeBtn != null){
                	sLayout.removeView(closeBtn);
                	closeBtn = null;
                }
            }
        });
    }

    @SuppressWarnings("unused")
    public static void setVisible(final int index, final boolean visible) {
        sCocos2dxActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxWebView webView = webViews.get(index);
                if (webView != null) {
                    webView.setVisibility(visible ? View.VISIBLE : View.GONE);

                    if(!visible){
	                    webView.hideLoading();
                    }
                }
            }
        });
    }

    @SuppressWarnings("unused")
    public static void setWebViewRect(final int index, final int left, final int top, final int maxWidth, final int maxHeight) {
        sCocos2dxActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(webViews == null) return;
                final Cocos2dxWebView webView = webViews.get(index);
                if (webView == null) return;
                webView.setWebViewRect(left, top, maxWidth, maxHeight);
                int sfViewWidth  = Cocos2dxGLSurfaceView.getInstance().getWidth();
                int sfViewHeight = Cocos2dxGLSurfaceView.getInstance().getHeight();
                if (!(sfViewWidth == maxWidth && sfViewHeight == maxHeight)) return;
                if (closeBtn != null) return;
                closeBtn = new Button(sLayout.getContext());
                final FrameLayout.LayoutParams btnParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                btnParams.topMargin   = convertDipsToPixels(8);
                btnParams.gravity     = Gravity.RIGHT;
                btnParams.rightMargin = convertDipsToPixels(8);
                closeBtn.setGravity(Gravity.RIGHT);
                closeBtn.setBackgroundResource(R.drawable.panels_close);
                closeBtn.setOnTouchListener(new OnTouchListener() {
                    @Override
                    public boolean onTouch(View arg0, MotionEvent arg1) {
                    	if (closeBtn == null) return true;
						if(arg1.getAction() == MotionEvent.ACTION_DOWN){
							closeBtn.setScaleX(0.98f);
							closeBtn.setScaleY(0.98f);
						}else if(arg1.getAction() == MotionEvent.ACTION_UP){
							closeBtn.setScaleX(1f);
							closeBtn.setScaleY(1f);
							try{
                        		if(closeBtn != null){
                        			sLayout.removeView(closeBtn);
                        			closeBtn = null;
                        		}
                        		webView.getWeb().backToLua("0");
                        		
                        	}catch(Exception e){
                        		
                        	}
						}
						return true;
					}
				});
                sLayout.addView(closeBtn, btnParams);
            }
        });
    }

    @SuppressWarnings("unused")
    public static void setJavascriptInterfaceScheme(final int index, final String scheme) {
        sCocos2dxActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxWebView webView = webViews.get(index);
                if (webView != null) {
                    webView.setJavascriptInterfaceScheme(scheme);
                }
            }
        });
    }

    @SuppressWarnings("unused")
    public static void loadData(final int index, final String data, final String mimeType, final String encoding, final String baseURL) {
        sCocos2dxActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxWebView webView = webViews.get(index);
                if (webView != null) {
                    webView.loadDataWithBaseURL(baseURL, data, mimeType, encoding, null);
                }
            }
        });
    }

    @SuppressWarnings("unused")
    public static void loadHTMLString(final int index, final String htmlString, final String mimeType, final String encoding) {
        sCocos2dxActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxWebView webView = webViews.get(index);
                if (webView != null) {
                    webView.loadData(htmlString, mimeType, encoding);
                }
            }
        });
    }

    @SuppressWarnings("unused")
    public static void loadUrl(final int index, final String url) {
        sCocos2dxActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxWebView webView = webViews.get(index);
                if (webView != null) {
                    webView.loadUrl(url);
                }
            }
        });
    }

    @SuppressWarnings("unused")
    public static void loadFile(final int index, final String filePath) {
        sCocos2dxActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxWebView webView = webViews.get(index);
                if (webView != null) {
                    webView.loadUrl(filePath);
                }
            }
        });
    }

    public static void stopLoading(final int index) {
        sCocos2dxActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxWebView webView = webViews.get(index);
                if (webView != null) {
                    webView.stopLoading();
                }
            }
        });

    }

    public static void reload(final int index) {
        sCocos2dxActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxWebView webView = webViews.get(index);
                if (webView != null) {
                    webView.reload();
                }
            }
        });
    }

    public static <T> T callInMainThread(Callable<T> call) throws ExecutionException, InterruptedException {
        FutureTask<T> task = new FutureTask<T>(call);
        sHandler.post(task);
        return task.get();
    }

    @SuppressWarnings("unused")
    public static boolean canGoBack(final int index) {
        Callable<Boolean> callable = new Callable<Boolean>() {
            @Override
            public Boolean call() throws Exception {
                Cocos2dxWebView webView = webViews.get(index);
                return webView != null && webView.canGoBack();
            }
        };
        try {
            return callInMainThread(callable);
        } catch (ExecutionException e) {
            return false;
        } catch (InterruptedException e) {
            return false;
        }
    }

    @SuppressWarnings("unused")
    public static boolean canGoForward(final int index) {
        Callable<Boolean> callable = new Callable<Boolean>() {
            @Override
            public Boolean call() throws Exception {
                Cocos2dxWebView webView = webViews.get(index);
                return webView != null && webView.canGoForward();
            }
        };
        try {
            return callInMainThread(callable);
        } catch (ExecutionException e) {
            return false;
        } catch (InterruptedException e) {
            return false;
        }
    }

    @SuppressWarnings("unused")
    public static void goBack(final int index) {
        sCocos2dxActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxWebView webView = webViews.get(index);
                if (webView != null) {
                    webView.goBack();
                }
            }
        });
    }

    @SuppressWarnings("unused")
    public static void goForward(final int index) {
        sCocos2dxActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxWebView webView = webViews.get(index);
                if (webView != null) {
                    webView.goForward();
                }
            }
        });
    }

    @SuppressWarnings("unused")
    public static void evaluateJS(final int index, final String js) {
        sCocos2dxActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxWebView webView = webViews.get(index);
                if (webView != null) {
                    webView.loadUrl("javascript:" + js);
                }
            }
        });
    }

    @SuppressWarnings("unused")
    public static void setScalesPageToFit(final int index, final boolean scalesPageToFit) {
        sCocos2dxActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Cocos2dxWebView webView = webViews.get(index);
                if (webView != null) {
                    webView.setScalesPageToFit(scalesPageToFit);
                    webView.setVisibility(View.INVISIBLE);
                }
            }
        });
    }

    public static int convertDipsToPixels(final float pDIPs) {
        final float scale = sLayout.getContext().getResources().getDisplayMetrics().density;
        return Math.round(pDIPs * scale);
    }
}
