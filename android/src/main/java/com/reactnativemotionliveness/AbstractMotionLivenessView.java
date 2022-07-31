package com.reactnativemotionliveness;

import android.content.Context;
import android.graphics.Rect;
import android.hardware.Camera;
import android.os.Handler;
import android.os.Looper;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.reactnativemotionliveness.type.StepBean;
import com.reactnativemotionliveness.ui.camera.SenseCamera;
import com.reactnativemotionliveness.ui.camera.SenseCameraPreview;
import com.reactnativemotionliveness.util.MediaController;
import com.reactnativemotionliveness.view.AbstractOverlayView;
import com.sensetime.senseid.sdk.liveness.interactive.InteractiveLivenessApi;
import com.sensetime.senseid.sdk.liveness.interactive.MotionComplexity;
import com.sensetime.senseid.sdk.liveness.interactive.NativeMotion;
import com.sensetime.senseid.sdk.liveness.interactive.common.type.PixelFormat;
import com.sensetime.senseid.sdk.liveness.interactive.common.type.ResultCode;
import com.sensetime.senseid.sdk.liveness.interactive.common.type.Size;
import com.sensetime.senseid.sdk.liveness.interactive.type.BoundInfo;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public abstract class AbstractMotionLivenessView extends RelativeLayout implements Camera.PreviewCallback {

    protected LayoutInflater mInflater;
    protected Handler handler = new Handler(Looper.getMainLooper());

    //请将账户信息补全，然后删除此行。Fill in your account info below, and delete this line.
    protected static String API_KEY = "5795cb839ce943cfb08159f0e42a8f9f";
    protected static String API_SECRET = "61f78cc79f884e1ba9f3042e9fa67bfd";
    protected static final String LICENSE_FILE_NAME = "motion-liveness.lic";

    protected static final String DETECTION_MODEL_FILE_NAME = "M_Detect_Hunter_SmallFace.model";
    protected static final String ALIGNMENT_MODEL_FILE_NAME = "M_Align_occlusion.model";
    protected static final String QUALITY_MODEL_FILE_NAME = "M_Face_Quality_Assessment.model";
    protected static final String FRAME_SELECTOR_MODEL_FILE_NAME = "M_Liveness_Cnn_half.model";


    protected final List<StepBean> mCurrentStepBeans = new ArrayList<>();
    protected boolean mIsVoiceOn = true;
    protected int mDifficulty = MotionComplexity.NORMAL;
    protected int[] mSequences = new int[]{
            NativeMotion.CV_LIVENESS_BLINK, NativeMotion.CV_LIVENESS_MOUTH,
            NativeMotion.CV_LIVENESS_HEADNOD, NativeMotion.CV_LIVENESS_HEADYAW
    };
    protected int mCurrentMotionIndex = -1;
    protected boolean mStartInputData = false;

    protected TextView mTipsView = null;
    protected View mLoadingView = null;
    protected AbstractOverlayView mOverlayView = null;
    protected RelativeLayout rl = null;
    protected LinearLayout resultLl = null;
    protected ImageView resultIv = null;
    protected TextView resultTv1 = null;
    protected TextView resultTv2 = null;
    protected ImageView idelIv = null;

    protected SenseCameraPreview mCameraPreviewView = null;
    protected SenseCamera mSenseCamera = null;
    protected boolean mMotionDetecting;

    public AbstractMotionLivenessView(Context context) {
        super(context);
    }

    public AbstractMotionLivenessView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public AbstractMotionLivenessView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }


    public void resumeCameraPreview() throws IOException {
        if (mSenseCamera == null) {
            mSenseCamera = new SenseCamera.Builder(MotionLivenessView.getAppContext()).setFacing(SenseCamera.CAMERA_FACING_FRONT)
                    .setRequestedPreviewSize(640, 480)
                    .build();
            mSenseCamera.setOnPreviewFrameCallback(this);
        }
        mCameraPreviewView.start(this.mSenseCamera);

    }


    /**
     * @param status -2->idel
     *               -1->未通过
     *               0->审核中
     *               1->通过
     */
    public void reset(int status, String title1, String title2) {
        InteractiveLivenessApi.stop();
        MediaController.getInstance().release();
        this.mStartInputData = false;
        this.mMotionDetecting = false;
        this.mCurrentMotionIndex = -1;
        if (mLoadingView != null) {
            mLoadingView.clearAnimation();
            mLoadingView.setVisibility(View.GONE);
        }
        if (status == -2) {
            mTipsView.setText(R.string.common_ready_tips);
            idelIv.setVisibility(View.VISIBLE);
            resultLl.setVisibility(View.GONE);
        } else {
            this.mTipsView.setText(null);
            idelIv.setVisibility(View.GONE);
            resultLl.setVisibility(View.VISIBLE);
            resultIv.setImageResource(status == 0 ? R.drawable.living_reviewing : (status == 1 ? R.drawable.living_success : R.drawable.living_error));
            resultTv1.setText(title1);
            resultTv2.setText(title2);
        }


        this.mOverlayView.setMaskPathColor(
                mOverlayView.getResources().getColor(R.color.common_interaction_light_gray));

        mCameraPreviewView.setVisibility(View.GONE);
        mOverlayView.setVisibility(View.GONE);
        mLoadingView.setVisibility(View.GONE);

    }

    public void destroy() {
        InteractiveLivenessApi.release();
        MediaController.getInstance().release();
        this.mCameraPreviewView.stop();
        this.mCameraPreviewView.release();
    }


//
//    @Override
//    protected void onDetachedFromWindow() {
//        super.onDetachedFromWindow();
//    }

    @Override
    public void requestLayout() {
        super.requestLayout();
        post(measureAndLayout);
    }

    private final Runnable measureAndLayout = () -> {
        measure(
                MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.EXACTLY),
                MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.EXACTLY));
        layout(getLeft(), getTop(), getRight(), getBottom());
    };

    @Override
    public void onPreviewFrame(byte[] data, Camera camera) {
        if (!this.mStartInputData) {
            return;
        }
        Log.d("MotionLivenessView", "onPreviewFrame");
        int viewWidth = this.mCameraPreviewView.getWidth();
        int viewHeight = this.mCameraPreviewView.getHeight();
        Rect containerRect = this.mCameraPreviewView.convertViewRectToPicture(
                new Rect(0, 0, viewWidth, viewHeight));

        Rect maskBounds = this.mOverlayView.getMaskBounds();

        if (maskBounds != null) {
            final int imageWidth = this.mSenseCamera.getPreviewSize().getWidth();
            final int imageHeight = this.mSenseCamera.getPreviewSize().getHeight();

            BoundInfo boundInfo = this.mCameraPreviewView.convertBoundInfoToPicture(
                    new BoundInfo(maskBounds.centerX(), maskBounds.centerY(),
                            maskBounds.width() * 3 / 8));

            InteractiveLivenessApi.inputData(data, PixelFormat.NV21,
                    new Size(imageWidth, imageHeight), containerRect, true,
                    mSenseCamera.getRotationDegrees(), boundInfo);
        }
    }

//    /**
//     * Show error message.
//     *
//     * @param errorMessage 信息内容
//     */
//    protected void showError(final String errorMessage) {
//        handler.post(() -> {
//            if (!TextUtils.isEmpty(errorMessage)) {
//                ToastUtil.show(ContextApplication.get(), errorMessage);
//            }
//        });
//    }

    protected int getSequenceByIndex(int index) {
        switch (index) {
            case 0:
                return NativeMotion.CV_LIVENESS_MOUTH;
            case 1:
                return NativeMotion.CV_LIVENESS_HEADNOD;
            case 2:
                return NativeMotion.CV_LIVENESS_HEADYAW;
            default:
                return NativeMotion.CV_LIVENESS_BLINK;
        }
    }

    protected String getMotionName(final int nativeMotion) {
        switch (nativeMotion) {
            case NativeMotion.CV_LIVENESS_BLINK:
                return getResources().getString(R.string.common_blink_tag);
            case NativeMotion.CV_LIVENESS_HEADNOD:
                return getResources().getString(R.string.common_nod_tag);
            case NativeMotion.CV_LIVENESS_HEADYAW:
                return getResources().getString(R.string.common_yaw_tag);
            case NativeMotion.CV_LIVENESS_MOUTH:
                return getResources().getString(R.string.common_mouth_tag);
            default:
                return null;
        }
    }


    protected String getMotionDescription(final int nativeMotion) {
        switch (nativeMotion) {
            case NativeMotion.CV_LIVENESS_BLINK:
                return getResources().getString(R.string.common_blink_description);
            case NativeMotion.CV_LIVENESS_HEADNOD:
                return getResources().getString(R.string.common_nod_description);
            case NativeMotion.CV_LIVENESS_HEADYAW:
                return getResources().getString(R.string.common_yaw_description);
            case NativeMotion.CV_LIVENESS_MOUTH:
                return getResources().getString(R.string.common_mouth_description);
            default:
                return null;
        }
    }


    protected String getErrorNotice(ResultCode resultCode) {
        switch (resultCode) {
            case STID_E_CALL_API_IN_WRONG_STATE:
                return getResources().getString(R.string.common_error_wrong_state);
            case STID_E_LICENSE_INVALID:
                return getResources().getString(R.string.common_error_check_license_fail);
            case STID_E_LICENSE_FILE_NOT_FOUND:
                return getResources().getString(R.string.common_error_license_file_not_found);
            case STID_E_LICENSE_PLATFORM_NOT_SUPPORTED:
                return getResources().getString(R.string.common_error_platform_not_support);
            case STID_E_LICENSE_VERSION_MISMATCH:
                return getResources().getString(R.string.common_error_sdk_not_match);
            case STID_E_LICENSE_BUNDLE_ID_INVALID:
                return getResources().getString(
                        R.string.common_error_license_package_name_mismatch);
            case STID_E_LICENSE_EXPIRE:
                return getResources().getString(R.string.common_error_license_expire);
            case STID_E_MODEL_INVALID:
                return getResources().getString(R.string.common_error_check_model_fail);
            case STID_E_MODEL_EXPIRE:
                return getResources().getString(R.string.common_error_model_expire);
            case STID_E_MODEL_FILE_NOT_FOUND:
                return getResources().getString(R.string.common_error_model_file_not_found);
            case STID_E_API_KEY_SECRET_NULL:
                return getResources().getString(R.string.common_error_api_key_secret);
            case STID_E_TIMEOUT:
                return getResources().getString(R.string.common_error_error_time_out);
            case STID_E_SERVER_ACCESS:
                return getResources().getString(R.string.common_error_error_server);
            case STID_E_CHECK_CONFIG_FAIL:
                return getResources().getString(R.string.common_error_check_config_fail);
            case STID_E_NOFACE_DETECTED:
                return getResources().getString(R.string.common_error_action_over);
            case STID_E_DETECT_FAIL:
            case STID_E_HACK:
                return getResources().getString(R.string.common_error_interactive_detection_fail);
            case STID_E_SERVER_TIMEOUT:
                return getResources().getString(R.string.common_error_server_timeout);
            case STID_E_FACE_COVERED:
                return getResources().getString(R.string.common_error_face_covered);
            case STID_E_FACE_LIGHT_DARK:
                return getResources().getString(R.string.common_face_light_dark_detect);
            case STID_E_INVALID_ARGUMENTS:
                return getResources().getString(R.string.common_error_invalid_arguments);
            case STID_E_DETECTION_MODEL_FILE_NOT_FOUND:
                return getResources().getString(R.string.common_error_detection_model_not_found);
            case STID_E_ALIGNMENT_MODEL_FILE_NOT_FOUND:
                return getResources().getString(R.string.common_error_alignment_model_not_found);
            case STID_E_FACE_QUALITY_MODEL_FILE_NOT_FOUND:
                return getResources().getString(R.string.common_error_face_quality_model_not_found);
            case STID_E_FRAME_SELECTOR_MODEL_FILE_NOT_FOUND:
                return getResources().getString(R.string.common_error_frame_select_model_not_found);
            case STID_E_ANTI_SPOOFING_MODEL_FILE_NOT_FOUND:
                return getResources().getString(
                        R.string.common_error_anti_spoofing_model_not_found);
            case STID_E_CAPABILITY_NOT_SUPPORTED:
                return getResources().getString(R.string.common_error_capability_not_support);
            default:
                return null;
        }
    }


}
