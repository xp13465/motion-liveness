package com.reactnativemotionliveness;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;

import java.io.File;

import javax.annotation.Nonnull;

public class MotionLivenessModule extends ReactContextBaseJavaModule {
    private static final String TAG = MotionLivenessModule.class.getSimpleName();
    private Handler handler = new Handler(Looper.getMainLooper());

    public MotionLivenessModule(@Nonnull ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Nonnull
    @Override
    public String getName() {
        return "MotionLiveness";
    }


    @ReactMethod
    public void getVideoVerifyPics(Promise promise) {
        WritableArray array = Arguments.createArray();
        for (byte[] imageData : ImageManager.getInstance().getImageResult()) {
            Bitmap bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.length);
            File saveFile = BitmapUtils.saveBitmap(bitmap, getReactApplicationContext());
            array.pushString(Uri.fromFile(saveFile).toString());
        }
        promise.resolve(array);
    }


}
