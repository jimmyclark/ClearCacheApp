package com.game.entity;

import android.os.Build;

public class User {
    private String rat; // 屏幕分辨率
    private String imei;
    private String osv; // 手机操作系统
    private String net; // 联网方式
    private String operator; // 手机厂商
    private String imsi;
    private String mac;
    private String phoneNumber;
    private String version;
    private String versionCode;
    private String locale; // 区域
    private String build_id;
    private String appid;
    private String appkey;
    private String apiInfo;
    private String model;
    private boolean supportSDCard;//是否支持SDcard
    private String uniqueId;
    private String androidId;
    private String deviceId;
    private String guid;
    private String fuid;
    private String rdid;
    private String iconName;

    @Override
    public String toString() {
        StringBuffer userInfo = new StringBuffer();
        userInfo.append("[\n\t This user = { \n");
        userInfo.append("\t\t rat = " + getRat() + ",\n");
        userInfo.append("\t\t imei = " + getImei() + ",\n");
        userInfo.append("\t\t osv = " + getOsv() + ",\n");
        userInfo.append("\t\t net = " + getNet() + ",\n");
        userInfo.append("\t\t operator = " + getOperator() + ",\n");
        userInfo.append("\t\t imsi = " + getImsi() + ",\n");
        userInfo.append("\t\t mac = " + getMac() + ",\n");
        userInfo.append("\t\t phoneNumber = " + getPhoneNumber() + ",\n");
        userInfo.append("\t\t version = " + getVersion() + ",\n");
        userInfo.append("\t\t versionCode = " + getVersionCode() + ",\n");
        userInfo.append("\t\t locale = " + getLocale() +",\n");
        userInfo.append("\t\t build_id = " + getBuild_id() + ",\n");
        userInfo.append("\t\t appid = " + getAppid() + ",\n");
        userInfo.append("\t\t appkey = " + getAppkey() + ",\n");
        userInfo.append("\t\t apiInfo = " + getApiInfo() + ",\n");
        userInfo.append("\t\t model = " + getModel() + ",\n" );
        userInfo.append("\t\t supportSDCard = " + (isSupportSDCard() ? 1 : 0) + ",\n");
        userInfo.append("\t\t uniqueId = " + getUniqueId() + ",\n" );
        userInfo.append("\t\t androidId = " + getAndroidId() + ",\n" );
        userInfo.append("\t\t deviceId = " + getDeviceId() + ",\n" );
        userInfo.append("\t\t guid = " + getGuid() + ",\n" );
        userInfo.append("\t\t fuid = " + getFuid() + ",\n" );
        userInfo.append("\t\t rdid = " + getRdid() + ",\n" );
        userInfo.append("\t\t iconName = " + getIconName() + ",\n" );
        userInfo.append("\t\t isAndroid10 = " + isAndroid10() + ",\n" );
        userInfo.append("\t } \n]");
        return userInfo.toString();
    }
    public String getIconName() {
        if(iconName == null){
            return "";
        }
        return iconName;
    }
    public void setIconName(String iconName) {
        if(iconName != null) this.iconName = iconName;
    }
    public String getRat() {
        return rat;
    }
    public void setRat(String rat) {
        this.rat = rat;
    }
    public String getImei() {
        if(imei == null){
            return "";
        }
        return imei;
    }
    public void setImei(String imei) {
        if(imei != null) this.imei = imei;
    }
    public String getOsv() {
        return osv;
    }
    public void setOsv(String osv) {
        this.osv = osv;
    }
    public String getNet() {
        return net;
    }
    public void setNet(String net) {
        this.net = net;
    }
    public String getOperator() {
        return operator;
    }
    public void setOperator(String operator) {
        this.operator = operator;
    }
    public String getImsi() {
        return imsi;
    }
    public void setImsi(String imsi) {
        this.imsi = imsi;
    }
    public String getMac() {
        return mac;
    }
    public void setMac(String mac) {
        this.mac = mac;
    }
    public String getPhoneNumber() {
        return phoneNumber;
    }
    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }
    public String getVersion() {
        return version;
    }
    public void setVersion(String version) {
        this.version = version;
    }
    public String getVersionCode() {
        return versionCode;
    }
    public void setVersionCode(String versionCode) {
        this.versionCode = versionCode;
    }
    public String getLocale() {
        return locale;
    }
    public void setLocale(String locale) {
        this.locale = locale;
    }
    public String getBuild_id() {
        return build_id;
    }
    public void setBuild_id(String build_id) {
        this.build_id = build_id;
    }
    public String getAppid() {
        return appid;
    }
    public void setAppid(String appid) {
        this.appid = appid;
    }
    public String getAppkey() {
        return appkey;
    }
    public void setAppkey(String appkey) {
        this.appkey = appkey;
    }
    public String getApiInfo() {
        return apiInfo;
    }
    public void setApiInfo(String apiInfo) {
        this.apiInfo = apiInfo;
    }
    public String getModel() {
        return model;
    }
    public void setModel(String model) {
        this.model = model;
    }
    public boolean isSupportSDCard() {
        return supportSDCard;
    }
    public void setSupportSDCard(boolean supportSDCard) {
        this.supportSDCard = supportSDCard;
    }
    public String getUniqueId() {
        return uniqueId;
    }
    public void setUniqueId(String uniqueId) {
        this.uniqueId = uniqueId;
    }
    public String getAndroidId() {
        return androidId;
    }
    public void setAndroidId(String androidId) {
        this.androidId = androidId;
    }
    public String getDeviceId() {
        return deviceId;
    }
    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }
    public String getGuid() {
        return guid;
    }
    public void setGuid(String guid) {
        this.guid = guid;
    }
    public String getFuid() {
        return fuid;
    }
    public void setFuid(String fuid) {
        this.fuid = fuid;
    }
    public String getRdid() {
        if(rdid == null){
            return "";
        }
        return rdid;
    }
    public void setRdid(String rdid) {
        if(rdid != null) this.rdid = rdid;
    }
    public String isAndroid10() {
        boolean isTrue = Build.VERSION.SDK_INT > Build.VERSION_CODES.P;
        return isTrue ? "1" : "0";
    }
}
