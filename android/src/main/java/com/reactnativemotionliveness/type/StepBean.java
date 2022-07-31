package com.reactnativemotionliveness.type;

/**
 * Created on 28/07/2018.
 *
 * @author Qiang Lili
 */
public class StepBean {

    private String name;

    private StepState state;

    public StepBean(String name, StepState state) {
        this.name = name;
        this.state = state;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public StepState getState() {
        return this.state;
    }

    public void setState(StepState state) {
        this.state = state;
    }

    public enum StepState {
        STEP_UNDO,
        STEP_CURRENT,
        STEP_COMPLETED
    }
}
