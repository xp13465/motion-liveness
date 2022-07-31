package com.reactnativemotionliveness.view;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import com.reactnativemotionliveness.R;
import com.reactnativemotionliveness.util.DensityUtil;


/**
 * Created on 29/07/2018.
 *
 * @author Qiang Lili
 */
public class WaterRippleView extends View {

    private static final int DEFAULT_RIPPLE_SPEED = 1;

    private static final int DEFAULT_RIPPLE_COUNT = 1;

    private static final int DEFAULT_RIPPLE_SPACE = 15;

    private static final float DEFAULT_CENTER_IMAGE_RATIO = 1.0F;

    private boolean mRunning = false;

    private int[] mStrokeWidthArr;

    private int mMaxStrokeWidth;

    private int mRippleStrokeWidth = mMaxStrokeWidth;

    private int mRippleCount = DEFAULT_RIPPLE_COUNT;

    private int mRippleSpacing;

    private int mWidth;

    private int mHeight;

    private Paint mPaint;

    private Bitmap mBitmap;

    private int mMaxBitmapWidth;

    private int mMaxBitmapHeight;

    private int mRippleSpeed = DEFAULT_RIPPLE_SPEED;

    private float mImageRatio = DEFAULT_CENTER_IMAGE_RATIO;

    public WaterRippleView(Context context) {
        this(context, null);
    }

    public WaterRippleView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    /**
     * Constructor.
     *
     * @param context context.
     * @param attrs attrs.
     * @param defStyleAttr defStyleAttr.
     */
    public WaterRippleView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);

        initAttrs(context, attrs);
    }

    private void initAttrs(Context context, AttributeSet attrs) {

        this.mMaxBitmapHeight = DensityUtil.dip2px(context, 31);

        this.mMaxBitmapWidth = this.mMaxBitmapHeight;

        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.WaterRippleView);

        final int waveColor = typedArray.getColor(R.styleable.WaterRippleView_rippleColor,
                ContextCompat.getColor(context, R.color.common_interaction_ginger_pink));

        final Drawable drawable = typedArray.getDrawable(R.styleable.WaterRippleView_rippleCenterIcon);

        this.mRippleCount = typedArray.getInt(R.styleable.WaterRippleView_rippleCount, DEFAULT_RIPPLE_COUNT);

        this.mRippleSpacing = typedArray.getDimensionPixelSize(R.styleable.WaterRippleView_rippleSpacing,
                DensityUtil.dip2px(context, DEFAULT_RIPPLE_SPACE));

        this.mRippleSpeed = typedArray.getInt(R.styleable.WaterRippleView_rippleSpeed, DEFAULT_RIPPLE_SPEED);

        this.mRunning = typedArray.getBoolean(R.styleable.WaterRippleView_rippleAutoRunning, false);

        typedArray.recycle();

        this.mBitmap = ((BitmapDrawable) drawable).getBitmap();

        this.mPaint = new Paint();
        this.mPaint.setAntiAlias(true);
        this.mPaint.setStyle(Paint.Style.STROKE);
        this.mPaint.setColor(waveColor);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);

        int size = (this.mRippleCount * this.mRippleSpacing + this.mMaxBitmapWidth / 2) * 2;
        if (this.mBitmap.getWidth() > this.mMaxBitmapWidth || this.mBitmap.getHeight() > this.mMaxBitmapHeight) {
            size = (this.mRippleCount * this.mRippleSpacing + this.mBitmap.getWidth() / 2) * 2;
        }

        this.mWidth = resolveSize(size, widthMeasureSpec);
        this.mHeight = resolveSize(size, heightMeasureSpec);

        setMeasuredDimension(this.mWidth, this.mHeight);

        this.mMaxStrokeWidth = (this.mWidth - this.mBitmap.getWidth()) / 2;

        initArray();
    }

    private void initArray() {
        this.mStrokeWidthArr = new int[this.mRippleCount];
        for (int i = 0; i < this.mStrokeWidthArr.length; i++) {
            this.mStrokeWidthArr[i] = -this.mRippleStrokeWidth / this.mRippleCount * i;
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        drawBitmap(canvas);

        if (this.mRunning) {
            drawRipple(canvas);
            postInvalidateDelayed(2500 / this.mRippleSpeed);
        }
    }

    private void drawBitmap(Canvas canvas) {
        int left = (this.mWidth - this.mBitmap.getWidth()) / 2;
        int top = (this.mHeight - this.mBitmap.getHeight()) / 2;

        canvas.drawBitmap(this.mBitmap, left, top, null);
    }

    private void drawRipple(Canvas canvas) {
        for (int strokeWidth : this.mStrokeWidthArr) {
            if (strokeWidth < 0) {
                continue;
            }

            this.mPaint.setStrokeWidth(strokeWidth);
            this.mPaint.setAlpha(255 - 255 * strokeWidth / this.mRippleStrokeWidth);

            canvas.drawCircle(this.mWidth / 2, this.mHeight / 2,
                    (this.mBitmap.getWidth() * this.mImageRatio) / 2 + strokeWidth / 2, this.mPaint);
        }
        for (int i = 0; i < this.mStrokeWidthArr.length; i++) {

            this.mStrokeWidthArr[i] += DensityUtil.dip2px(this.getContext(), 1);

            if (this.mStrokeWidthArr[i] > this.mRippleStrokeWidth) {
                this.mStrokeWidthArr[i] = 0;
            }
        }
    }

    /**
     * Start wave ripple.
     */
    public void start() {
        this.mRunning = true;
        postInvalidate();
    }

    /**
     * Stop wave ripple.
     */
    public void stop() {
        this.mRunning = false;
        initArray();
        postInvalidate();
    }

    /**
     * Set center bitmap to draw.
     *
     * @param bitmap bitmap.
     */
    public void setCenterBitmap(final Bitmap bitmap) {
        if (bitmap.getHeight() > this.mBitmap.getHeight() || bitmap.getWidth() > this.mBitmap.getWidth()) {
            return;
        }
        this.mBitmap = bitmap;
        invalidate();
    }

    /**
     * Set drawable resource for center icon.
     *
     * @param drawableResource drawable resource.
     */
    public void setCenterIconResource(final int drawableResource) {
        this.mBitmap = ((BitmapDrawable) (ContextCompat.getDrawable(getContext(), drawableResource))).getBitmap();
        invalidate();
    }

    /**
     * Set stroke width of ripple.
     *
     * @param pixels pixels.
     */
    public void setRippleStrokeWidth(final int pixels) {
        this.mRippleStrokeWidth = pixels > this.mMaxStrokeWidth ? this.mMaxStrokeWidth : pixels;
    }

    /**
     * Set the speed of ripple, the bigger the value, the faster.
     *
     * @param speed speed.
     */
    public void setRippleSpeed(final int speed) {
        this.mRippleSpeed = speed < 1 ? DEFAULT_RIPPLE_SPEED : speed;
    }

    /**
     * Set the true scale of the image in the diagram, which determines the size of the ripples.
     *
     * @param ratio ratio.
     */
    public void setCenterImageRatio(final float ratio) {
        this.mImageRatio = Float.compare(ratio, 0) > 0 ? ratio : DEFAULT_CENTER_IMAGE_RATIO;
    }
}