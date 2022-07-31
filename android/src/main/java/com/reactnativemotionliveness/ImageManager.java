package com.reactnativemotionliveness;

import java.util.ArrayList;
import java.util.List;

/**
 * Created on 2020-01-08.
 *
 * @author Qiang Lili
 */
public class ImageManager {

    private List<byte[]> mImageListData = new ArrayList<>();

    private ImageManager() {
        // empty.
    }

    /**
     * Get instance of ImageManager.
     *
     * @return instance of ImageManager.
     */
    public static ImageManager getInstance() {
        return InstanceHolder.INSTANCE;
    }

    /**
     * Save image result.
     *
     * @param imageResult image result.
     */
    public void saveImageResult(final List<byte[]> imageResult) {
        this.mImageListData.clear();

        if (null == imageResult || imageResult.isEmpty()) {
            return;
        }

        this.mImageListData.addAll(imageResult);
    }

    /**
     * Get image result data.
     *
     * @return image result data
     */
    public List<byte[]> getImageResult() {
        return this.mImageListData;
    }

    public static class InstanceHolder {
        private static final ImageManager INSTANCE = new ImageManager();
    }
}
