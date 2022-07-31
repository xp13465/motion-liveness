package com.reactnativemotionliveness;

import android.content.Context;
import android.os.SystemClock;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.LinearInterpolator;
import android.widget.TextView;

import androidx.constraintlayout.widget.ConstraintLayout;

import com.reactnativemotionliveness.type.StepBean;
import com.reactnativemotionliveness.util.MediaController;
import com.sensetime.senseid.sdk.liveness.interactive.FaceOcclusion;
import com.sensetime.senseid.sdk.liveness.interactive.InteractiveLivenessApi;
import com.sensetime.senseid.sdk.liveness.interactive.OnLivenessListener;
import com.sensetime.senseid.sdk.liveness.interactive.common.type.CloudInternalCode;
import com.sensetime.senseid.sdk.liveness.interactive.common.type.ResultCode;
import com.sensetime.senseid.sdk.liveness.interactive.common.util.FileUtil;
import com.sensetime.senseid.sdk.liveness.interactive.type.FaceDistance;
import com.sensetime.senseid.sdk.liveness.interactive.type.FacePosition;
import com.sensetime.senseid.sdk.liveness.interactive.type.LightIntensity;
import com.sensetime.senseid.sdk.liveness.interactive.type.OcclusionStatus;

import java.io.File;
import java.util.ArrayList;
import java.util.List;


public class MotionLivenessView extends AbstractMotionLivenessView {

    private static Context context;
    private StatusListener statusListener;
    private boolean initFlag = false;
    private boolean isFirst = true;
    public boolean isOnLiving = false;
    private File externalAssets;

    public static void setContext(Context ctx) {
        context = ctx;
    }

    public static Context getAppContext() {
        return context;
    }

    public void setStatusListener(StatusListener statusListener) {
        this.statusListener = statusListener;
    }

    public MotionLivenessView(Context context) {
        super(context);
        mInflater = LayoutInflater.from(context);
        init();
    }

    public MotionLivenessView(Context context, AttributeSet attrs) {
        super(context, attrs);
        mInflater = LayoutInflater.from(context);
        init();
    }

    public MotionLivenessView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        mInflater = LayoutInflater.from(context);
        init();
    }


    public void init() {
        View view = mInflater.inflate(R.layout.layout_motion_liveness, this, true);


        File protobufFolder = new File(getContext().getFilesDir(), "protobuf");

        if (protobufFolder != null && protobufFolder.exists()) {
            FileUtil.deleteResultDir(protobufFolder.getAbsolutePath());
        }

        for (int nativeMotion : this.mSequences) {
            this.mCurrentStepBeans.add(
                    new StepBean(getMotionName(nativeMotion), StepBean.StepState.STEP_UNDO));
        }

        idelIv = view.findViewById(R.id.iv_idel);
        rl = view.findViewById(R.id.rl);
        resultLl = view.findViewById(R.id.resultLl);
        resultIv = view.findViewById(R.id.resultIv);
        resultTv1 = view.findViewById(R.id.resultTv1);
        resultTv2 = view.findViewById(R.id.resultTv2);
        ConstraintLayout.LayoutParams layoutParams = (ConstraintLayout.LayoutParams) rl.getLayoutParams();

        WindowManager w = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        Display d = w.getDefaultDisplay();
        DisplayMetrics metrics = new DisplayMetrics();
        d.getMetrics(metrics);
        int padding = metrics.widthPixels / 10;
        layoutParams.width = metrics.widthPixels;
        layoutParams.height = metrics.widthPixels;
        rl.setLayoutParams(layoutParams);
        rl.setPadding(padding, padding, padding, padding);


        mOverlayView = view.findViewById(R.id.overlay_interactive);
        mTipsView = (TextView) view.findViewById(R.id.tips);
        mLoadingView = view.findViewById(R.id.img_loading);
        mCameraPreviewView = view.findViewById(R.id.camera_preview);

        externalAssets = new File(context.getFilesDir(), "assets");

        FileUtil.copyAssetsToFile(context, DETECTION_MODEL_FILE_NAME,
                new File(externalAssets, DETECTION_MODEL_FILE_NAME).getAbsolutePath());
        FileUtil.copyAssetsToFile(context, ALIGNMENT_MODEL_FILE_NAME,
                new File(externalAssets, ALIGNMENT_MODEL_FILE_NAME).getAbsolutePath());
        FileUtil.copyAssetsToFile(context, QUALITY_MODEL_FILE_NAME,
                new File(externalAssets, QUALITY_MODEL_FILE_NAME).getAbsolutePath());
        FileUtil.copyAssetsToFile(context, FRAME_SELECTOR_MODEL_FILE_NAME,
                new File(externalAssets, FRAME_SELECTOR_MODEL_FILE_NAME).getAbsolutePath());

        FileUtil.copyAssetsToFile(context, LICENSE_FILE_NAME,
                new File(externalAssets, LICENSE_FILE_NAME).getAbsolutePath());


    }


    public void start() {
        if (!initFlag) {
            // Sample默认不启动与人脸质量相关的质量检测（光线、模糊）.
            InteractiveLivenessApi.init(context, API_KEY, API_SECRET,
                    new File(externalAssets, LICENSE_FILE_NAME).getAbsolutePath(),
                    new File(externalAssets, DETECTION_MODEL_FILE_NAME).getAbsolutePath(),
                    new File(externalAssets, ALIGNMENT_MODEL_FILE_NAME).getAbsolutePath(), null,
                    new File(externalAssets, FRAME_SELECTOR_MODEL_FILE_NAME).getAbsolutePath(),
                    mLivenessListener);
            initFlag = true;
        }
        resultLl.setVisibility(GONE);
        idelIv.setVisibility(GONE);
        mCameraPreviewView.setVisibility(VISIBLE);
        mOverlayView.setVisibility(VISIBLE);
        mStartInputData = !isFirst;
        InteractiveLivenessApi.start(null, mDifficulty);
        if (statusListener != null) statusListener.onLiving();
        isFirst = false;
        isOnLiving = true;
    }

    public void pauseCameraPreview() {
        if (statusListener != null && isOnLiving) {
            isOnLiving = false;
//            statusListener.onIdle();
            statusListener.onError(null);
        }


        mCameraPreviewView.stop();
    }


    private void onFailDetect(ResultCode resultCode,
                              @CloudInternalCode final int cloudInternalCode) {

        switch (resultCode) {
            case STID_E_API_KEY_INVALID:
            case STID_E_SERVER_DETECT_FAIL:
            case STID_E_SERVER_TIMEOUT:
            case STID_E_SERVER_ACCESS:
            case STID_E_DETECT_FAIL:
            case STID_E_HACK:
                break;
            default:
//                showError(getErrorNotice(resultCode));
                break;
        }
        if (statusListener != null) statusListener.onError(getErrorNotice(resultCode));
        isOnLiving = false;
        /*end*/
    }


    private OnLivenessListener mLivenessListener = new OnLivenessListener() {
        private long mLastStatusUpdateTime;

        @Override
        public void onInitialized() {
            mStartInputData = true;
            Log.d("MotionLivenessView", "onInitialized");
            // 开启质检检测开关的示例代码（注：init时传入正确的质检模型才会生效）
            //InteractiveLivenessApi.setIlluminationFilterEnable(true, 1.899F, 4.9970F);
            //InteractiveLivenessApi.setBlurryFilterEnable(false, 0.4F);
        }

        @Override
        public void onStatusUpdate(final int faceState, final FaceOcclusion faceOcclusion,
                                   final int faceDistance, final int lightIntensity) {
            Log.d("MotionLivenessView", "--------");
            Log.d("MotionLivenessView", faceState + "");
            Log.d("MotionLivenessView", faceDistance + "");
            Log.d("MotionLivenessView", lightIntensity + "");
            Log.d("MotionLivenessView", "--------");
            if (!mMotionDetecting
                    && SystemClock.elapsedRealtime() - mLastStatusUpdateTime < 300
                    && faceState != FacePosition.NORMAL) {
                return;
            }

            if (faceDistance == FaceDistance.TOO_CLOSE) {
                mTipsView.setText(R.string.common_face_too_close);
            } else if (faceDistance == FaceDistance.TOO_FAR) {
                mTipsView.setText(R.string.common_face_too_far);
            } else if (faceState == FacePosition.OUT_OF_BOUND) {
                mTipsView.setText(R.string.common_tracking_missed);
            } else if (lightIntensity == LightIntensity.TOO_DARK) {
                mTipsView.setText(
                        R.string.common_face_light_dark_align);
            } else if (lightIntensity == LightIntensity.TOO_BRIGHT) {
                mTipsView.setText(
                        R.string.common_face_light_bright_align);
            } else if (faceOcclusion != null && faceOcclusion.isOcclusion()) {
                StringBuffer occlusionPart = new StringBuffer();
                boolean needComma = false;

                if (faceOcclusion.getBrowOcclusionStatus() == OcclusionStatus.OCCLUSION) {
                    occlusionPart.append(context.getString(R.string.common_covered_brow));
                    needComma = true;
                }

                if (faceOcclusion.getEyeOcclusionStatus() == OcclusionStatus.OCCLUSION) {
                    occlusionPart.append(context.getString(R.string.common_covered_eye));
                    needComma = true;
                }

                if (faceOcclusion.getNoseOcclusionStatus() == OcclusionStatus.OCCLUSION) {
                    occlusionPart.append(needComma ? "、" : "");
                    occlusionPart.append(context.getString(R.string.common_covered_nose));
                    needComma = true;
                }

                if (faceOcclusion.getMouthOcclusionStatus() == OcclusionStatus.OCCLUSION) {
                    occlusionPart.append(needComma ? "、" : "");
                    occlusionPart.append(context.getString(R.string.common_covered_mouth));
                }

                mTipsView.setText(
                        context.getString(R.string.common_face_covered, occlusionPart.toString()));
            } else if (faceState == FacePosition.NORMAL) {
                mTipsView.setText(
                        mMotionDetecting ? getMotionDescription(mSequences[mCurrentMotionIndex])
                                : context.getString(R.string.common_detecting));
            } else {
                mTipsView.setText(R.string.common_tracking_missed);
            }

            mLastStatusUpdateTime = SystemClock.elapsedRealtime();
        }

        @Override
        public void onFailure(ResultCode resultCode, int httpStatusCode, int cloudInternalCode,
                              String requestId, byte[] bytes, List<byte[]> imageData) {
            Log.d("MotionLivenessView", "失败");
            mStartInputData = false;
            onFailDetect(resultCode, cloudInternalCode);
        }

        @Override
        public void onSuccess(int httpCode, int cloudInternalCode, String requestId, byte[] result,
                              List<byte[]> imageData) {
            Log.d("MotionLivenessView", "成功");

            mStartInputData = false;
            ImageManager.getInstance().saveImageResult(new ArrayList<>(imageData));
            statusListener.onSuccess();
            isOnLiving = false;
        }

        @Override
        public void onOnlineCheckBegin() {
            Log.d("MotionLivenessView", "onOnlineCheckBegin");
            mStartInputData = false;

            mCameraPreviewView.setVisibility(View.GONE);
            mOverlayView.setVisibility(View.GONE);
            mLoadingView.setVisibility(View.VISIBLE);

            if (mIsVoiceOn) {
                MediaController.getInstance().release();
            }

            Animation animation =
                    AnimationUtils.loadAnimation(context, R.anim.anim_rotate);
            animation.setInterpolator(new LinearInterpolator());
            mLoadingView.startAnimation(animation);
        }

        @Override
        public void onAligned() {
            Log.d("MotionLivenessView", "onAligned");
            mOverlayView.setMaskPathColor(
                    mOverlayView.getResources().getColor(R.color.common_interaction_ginger_pink));
            mTipsView.setText(null);

            InteractiveLivenessApi.start(mSequences, mDifficulty);
        }

        @Override
        public void onMotionSet(final int index, int motion) {
            Log.d("MotionLivenessView", "onMotionSet");
            mCurrentMotionIndex = index;

            mTipsView.setText(
                    getMotionDescription(mSequences[mCurrentMotionIndex]));
            mMotionDetecting = true;

            if (mIsVoiceOn) {
                MediaController.getInstance()
                        .playNotice(context, mSequences[mCurrentMotionIndex]);
            }
        }
    };


    public interface StatusListener {
//        void onIdle();

        void onLiving();

        void onError(String errorNotice);

        void onSuccess();
    }


//    public class MyLifecycleObserver implements LifecycleObserver {
//
//        @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
//        void onResume() {
//            try {
//                resumeCameraPreview();
//            } catch (IOException e) {
//                e.printStackTrace();
//            }
//        }
//
//        @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
//        void onPause() {
//            pauseCameraPreview();
//            reset();
//        }
//
//        @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
//        void onDestroy() {
//            destroy();
//        }
//
//    }
}
