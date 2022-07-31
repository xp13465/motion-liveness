import React from 'react';
import { findNodeHandle, requireNativeComponent, UIManager } from 'react-native';

export interface RCTMotionLivenessViewProps{
  style?: Object;
  ref?: Object;

  onLiving?(): void;

  onError?(): void;

  onSuccess?(): void;
}

const RCTMotionLivenessView = requireNativeComponent(`RCTMotionLivenessView`);

export default class extends React.Component<RCTMotionLivenessViewProps>{
  customView: any = null;

  start = async () => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.customView),
     'start',
      undefined,
    );
  };

  reset = async (array: [number, string | null, string | null]) => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.customView),
     'reset',
      array,
    );
  };

  resume = async () => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.customView),
     'resume',
      undefined,
    );
  };

  pause = async () => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.customView),
    'pause',
      undefined,
    );
  };

  destroy = async () => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.customView),
    'destroy',
      undefined,
    );
  };

  _onLiving = () => {
    if (!this.props.onLiving) {
      return;
    }

    this.props.onLiving();
  };

  _onError = () => {
    if (!this.props.onError) {
      return;
    }

    this.props.onError();
  };


  _onSuccess = () => {
    if (!this.props.onSuccess) {
      return;
    }

    this.props.onSuccess();
  };

  render() {
    return (
      <RCTMotionLivenessView
        {...this.props}
        onLiving={this._onLiving}
        onError={this._onError}
        onSuccess={this._onSuccess}
        ref={(component: React.Component) => {
          this.customView = component;
        }}
      />
    );
  }

}
