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
        return "User{" +
                "rat='" + rat + '\'' +
                ", imei='" + imei + '\'' +
                ", osv='" + osv + '\'' +
                ", net='" + net + '\'' +
                ", operator='" + operator + '\'' +
                ", imsi='" + imsi + '\'' +
                ", mac='" + mac + '\'' +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", version='" + version + '\'' +
                ", versionCode='" + versionCode + '\'' +
                ", locale='" + locale + '\'' +
                ", build_id='" + build_id + '\'' +
                ", appid='" + appid + '\'' +
                ", appkey='" + appkey + '\'' +
                ", apiInfo='" + apiInfo + '\'' +
                ", model='" + model + '\'' +
                ", supportSDCard=" + supportSDCard +
                ", uniqueId='" + uniqueId + '\'' +
                ", androidId='" + androidId + '\'' +
                ", deviceId='" + deviceId + '\'' +
                ", guid='" + guid + '\'' +
                ", fuid='" + fuid + '\'' +
                ", rdid='" + rdid + '\'' +
                ", iconName='" + iconName + '\'' +
                ", totalDeviceSize=" + totalDeviceSize +
                ", totalDeviceAvailableSize=" + totalDeviceAvailableSize +
                '}';
    }

    private long totalDeviceSize;
    private long totalDeviceAvailableSize;

    public long getTotalDeviceAvailableSize() {
        return totalDeviceAvailableSize;
    }

    public void setTotalDeviceAvailableSize(long totalDeviceAvailableSize) {
        this.totalDeviceAvailableSize = totalDeviceAvailableSize;
    }

    public long getTotalDeviceSize() {
        return totalDeviceSize;
    }

    public void setTotalDeviceSize(long totalDeviceSize) {
        this.totalDeviceSize = totalDeviceSize;
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
