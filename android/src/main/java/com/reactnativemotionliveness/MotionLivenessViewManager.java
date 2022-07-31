package com.reactnativemotionliveness;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import java.io.IOException;
import java.util.Map;

public class MotionLivenessViewManager extends SimpleViewManager<MotionLivenessView> {
    public static final String REACT_CLASS = "RCTMotionLivenessView";


    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    public Map getExportedCustomBubblingEventTypeConstants() {
        MapBuilder.Builder<Object, Object> builder = MapBuilder.builder();
        builder.put("onLiving", MapBuilder.of("phasedRegistrationNames", MapBuilder.of("bubbled", "onLiving")));
        builder.put("onError", MapBuilder.of("phasedRegistrationNames", MapBuilder.of("bubbled", "onError")));
        builder.put("onSuccess", MapBuilder.of("phasedRegistrationNames", MapBuilder.of("bubbled", "onSuccess")));
        return builder.build();
    }

    @Override
    public void onDropViewInstance(@NonNull MotionLivenessView view) {
        super.onDropViewInstance(view);
    }

    @NonNull
    @Override
    protected MotionLivenessView createViewInstance(@NonNull ThemedReactContext reactContext) {
        MotionLivenessView motionLivenessView = new MotionLivenessView((reactContext));
        MotionLivenessView.StatusListener statusListener = new MotionLivenessView.StatusListener() {

            @Override
            public void onLiving() {
                WritableMap event = Arguments.createMap();
                RCTEventEmitter eventEmitter = reactContext.getJSModule(RCTEventEmitter.class);
                eventEmitter.receiveEvent(motionLivenessView.getId(), "onLiving", event);
            }

            @Override
            public void onError(String errorNotice) {
                if (null == errorNotice) {
                    motionLivenessView.reset(-2, null, null);
                } else {
                    motionLivenessView.reset(-1, "真人认证审核未通过", errorNotice);
                }
                WritableMap event = Arguments.createMap();
                RCTEventEmitter eventEmitter = reactContext.getJSModule(RCTEventEmitter.class);
                eventEmitter.receiveEvent(motionLivenessView.getId(), "onError", event);
            }

            @Override
            public void onSuccess() {
                WritableMap event = Arguments.createMap();
                RCTEventEmitter eventEmitter = reactContext.getJSModule(RCTEventEmitter.class);
                eventEmitter.receiveEvent(motionLivenessView.getId(), "onSuccess", event);

            }
        };
        motionLivenessView.setStatusListener(statusListener);
        return motionLivenessView;
    }


    @Override
    public void receiveCommand(final MotionLivenessView root, String commandId, @Nullable ReadableArray args) {
        switch (commandId) {
            case "start":
                root.start();
                break;
            case "reset":
                if (args != null && args.size() > 0) {
                    root.reset(args.getInt(0), args.getString(1), args.getString(2));
                }
                break;
            case "resume":
                try {
                    root.resumeCameraPreview();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                break;
            case "pause":
                root.pauseCameraPreview();
                if (root.isOnLiving) {
                    root.reset(-2, null, null);
                }
                break;
            case "destroy":
                root.destroy();
                break;

        }
    }


}
