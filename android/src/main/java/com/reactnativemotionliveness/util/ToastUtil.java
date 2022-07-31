package com.reactnativemotionliveness.util;

import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.reactnativemotionliveness.R;


/**
 * Created on 16/07/2018.
 *
 * @author Qiang Lili
 */
public class ToastUtil {

    /**
     * Show error.
     */
    public static void show(final Context context, final String message) {
        Toast toast = new Toast(context);
        toast.setGravity(Gravity.CENTER, 0, 0);
        View view = LayoutInflater.from(context).inflate(R.layout.common_interaction_toast_view, null);
        ((TextView) view.findViewById(R.id.txt_toast_message)).setText(message);
        toast.setView(view);
        toast.setDuration(Toast.LENGTH_LONG);
        toast.show();
    }
}
