package com.reactnativemotionliveness.view;

import android.content.Context;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.RectF;
import android.util.AttributeSet;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * Created on 2018/11/30.
 *
 * @author Zhu Xiangdong
 */
public class InteractiveLivenessOverlayView extends AbstractOverlayView {
    private RectF mRectF = new RectF();

    public InteractiveLivenessOverlayView(Context context) {
        super(context);
    }

    public InteractiveLivenessOverlayView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public InteractiveLivenessOverlayView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected void buildPath(@NonNull final Path path, final int viewWidth, final int viewHeight) {
        this.mRectF.set(viewWidth * 0.1f, viewHeight * 0.1f, viewWidth * 0.9f, viewHeight * 0.9f);

        path.addCircle(this.mRectF.centerX(), this.mRectF.centerY(), this.mRectF.width() / 2, Path.Direction.CCW);
    }

    @Override
    public Rect getMaskBounds() {
        final Rect rect = new Rect();
        this.mRectF.round(rect);
        return rect;
    }
}
