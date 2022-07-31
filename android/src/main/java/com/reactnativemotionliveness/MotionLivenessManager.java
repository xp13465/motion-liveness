package com.reactnativemotionliveness;

/**
 * Created by 🐎  on 3/15/21.
 * DESC:
 */
public class MotionLivenessManager {


    private static MotionLivenessManager instance;

    private MotionLivenessManager() {
    }

    public void init(String appKey, String apiSecret) {
        AbstractMotionLivenessView.API_KEY = appKey;
        AbstractMotionLivenessView.API_SECRET = apiSecret;
    }

    public static synchronized MotionLivenessManager getInstance() {
        if (instance == null) {
            instance = new MotionLivenessManager();
        }

        return instance;
    }
}
