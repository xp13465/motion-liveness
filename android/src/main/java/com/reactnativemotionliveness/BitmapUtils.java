package com.reactnativemotionliveness;

import android.graphics.Bitmap;

import com.facebook.react.bridge.ReactApplicationContext;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

/**
 * 图片选择类
 * Created by lml on 2015/7/1.
 */
public class BitmapUtils {




    /**
     * Save Bitmap
     * @param bm   picture to save
     * @param reactApplicationContext
     * @return
     */
    public static File saveBitmap(Bitmap bm, ReactApplicationContext reactApplicationContext) {
        //指定我们想要存储文件的地址
        String targetPath = reactApplicationContext.getFilesDir() + "/bitmaps/";
        File file = new File(targetPath);
        if (file.exists()) {
            file.delete();//重点在这里
        }
        if (!file.exists()) {
            file.mkdir();//重点在这里
        }
        //如果指定文件夹创建成功，那么我们则需要进行图片存储操作
        File saveFile = new File(targetPath, System.currentTimeMillis()+"");
        try {
            if (!saveFile.exists()) {
                saveFile.createNewFile();//重点在这里
            }
            if (saveFile.exists()) {
                saveFile.delete();
            }
            if (!saveFile.exists()) {
                saveFile.createNewFile();//重点在这里
            }
            FileOutputStream saveImgOut = new FileOutputStream(saveFile);
            // compress - 压缩的意思
            bm.compress(Bitmap.CompressFormat.JPEG, 80, saveImgOut);
            //存储完成后需要清除相关的进程
            saveImgOut.flush();
            saveImgOut.close();
            return saveFile;
        } catch (IOException ex) {
            return null;
        }

    }
}
