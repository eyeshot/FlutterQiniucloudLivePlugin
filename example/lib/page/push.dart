import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiniucloud_live_plugin/view/qiniucloud_push_view.dart';
import 'package:flutter_qiniucloud_live_plugin/controller/qiniucloud_push_view_controller.dart';
import 'package:flutter_qiniucloud_live_plugin/enums/qiniucloud_push_listener_type_enum.dart';
import 'package:flutter_qiniucloud_live_plugin/enums/qiniucloud_push_camera_type_enum.dart';

/// 推流界面
class PushPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PushPageState();
}

class PushPageState extends State<PushPage> {
  /// 推流控制器
  QiniucloudPushViewController controller;

  /// 当前状态
  String status;

  /// 描述信息
  String info;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (controller != null) {
      controller.removeListener(onListener);
    }
  }

  /// 控制器初始化
  onViewCreated(QiniucloudPushViewController controller) {
    this.controller = controller;
    controller.addListener(onListener);
  }

  /// 监听器
  onListener(type, params) {
    // 状态改变监听
    if (type == QiniucloudPushListenerTypeEnum.StateChanged) {
      Map<String, dynamic> paramObj = jsonDecode(params);
      stateChanged(paramObj["status"], paramObj["extra"]);
    }
  }

  /// 状态改变事件
  stateChanged(status, extra) async {
    this.setState(() => this.status = status);
  }

  /// 获得状态文本描述
  getStatusText(status) {
    if (status == null) {
      return "等待预览";
    }

    switch (status) {
      case "PREPARING":
        return "PREPARING";
      case "READY":
        return "准备就绪";
      case "CONNECTING":
        return "连接中";
      case "STREAMING":
        return "推流中";
      case "SHUTDOWN":
        return "直播中断";
      case "IOERROR":
        return "网络连接失败";
      case "OPEN_CAMERA_FAIL":
        return "摄像头打开失败";
      case "AUDIO_RECORDING_FAIL":
        return "麦克风打开失败";
      case "DISCONNECTED":
        return "已经断开连接";
      case "TORCH_INFO":
        return "可开启闪光灯";
      default:
        return "未绑定事件:$status";
    }
  }

  /// 开始预览事件
  onResume() async {
    bool result = await controller.resume();
    this.setState(() => info = "预览执行结果: $result");
  }

  /// 开始推流事件
  onPush() async {
    bool result = await controller.startStreaming();
    this.setState(() => info = "推流执行结果: $result");
  }

  /// 停止推流事件
  onStopPush() async {
    bool result = await controller.stopStreaming();
    this.setState(() => info = "停止推流执行结果: $result");
  }

  /// 检测是否支持缩放
  onCheckZoomSupported() async {
    bool result = await controller.isZoomSupported();
    if (result) {
      int current = await controller.getZoom();
      int max = await controller.getMaxZoom();
      this.setState(() => info = "缩放检测结果: 支持，当前缩放比例:$current，最大缩放比例:$max");
    } else {
      this.setState(() => info = "缩放检测结果: 不支持");
    }
  }

  /// 设置最大缩放比例
  onSetMaxZoom() async {
    int max = await controller.getMaxZoom();
    await controller.setZoomValue(value: max);
    this.setState(() => info = "缩放比例设置成功:$max");
  }

  /// 重置缩放比例
  onResetZoom() async {
    await controller.setZoomValue(value: 0);
    this.setState(() => info = "缩放比例设置成功:0");
  }

  /// 开启闪光灯
  onTurnLightOn() async {
    bool result = await controller.turnLightOn();
    this.setState(() => info = "开启闪光灯结果: $result");
  }

  /// 关闭闪光灯
  onTurnLightOff() async {
    bool result = await controller.turnLightOff();
    this.setState(() => info = "关闭闪光灯结果: $result");
  }

  /// 切换摄像头
  onSwitchCamera() async {
    bool result = await controller.switchCamera();
    this.setState(() => info = "切换摄像头: $result");
  }

  /// 切换后置摄像头
  onSwitchBackCamera() async {
    bool result = await controller.switchCamera(
        target: QiniucloudPushCameraTypeEnum.CAMERA_FACING_BACK);
    this.setState(() => info = "切换后置摄像头: $result");
  }

  /// 切换前置摄像头
  onSwitchFrontCamera() async {
    bool result = await controller.switchCamera(
        target: QiniucloudPushCameraTypeEnum.CAMERA_FACING_FRONT);
    this.setState(() => info = "切换前置摄像头: $result");
  }

  /// 切换3DR摄像头
  onSwitch3DRCamera() async {
    bool result = await controller.switchCamera(
        target: QiniucloudPushCameraTypeEnum.CAMERA_FACING_3RD);
    this.setState(() => info = "切换3DR摄像头: $result");
  }

  /// 静音
  onMute(mute) async {
    await controller.mute(mute: mute);
    this.setState(() => info = "已成功执行静音/恢复静音步骤");
  }

  /// 关闭/启用日志
  onSetNativeLoggingEnabled(enabled) async {
    await controller.setNativeLoggingEnabled(enabled: enabled);
    this.setState(() => info = "已成功执行关闭/启用日志步骤");
  }

  /// 暂停
  onPause() async {
    await controller.pause();
    this.setState((){
      info = "已成功执行暂停";
      status = null;
    });
  }

  /// 销毁
  onDestroy() async {
    await controller.destroy();
    this.setState(() => info = "已成功执行销毁");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height / 2,
            child: QiniucloudPushView(
              url:
                  "rtmp://pili-publish.tianshitaiyuan.com/zuqulive/1576377182468A?e=1576380782&token=v740N_w0pHblR7KZMSPHhfdqjxrHEv5e_yBaiq0e:SWWOtiXbZXZgrMiW3WaHLfJIkT4=",
              onViewCreated: onViewCreated,
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height / 2,
            child: Column(
              children: <Widget>[
                Text("当前状态:${getStatusText(this.status)}"),
                Text(info ?? ""),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      Wrap(
                        children: <Widget>[
                          RaisedButton(
                            onPressed: this.status == null ? onResume : null,
                            child: Text("开始预览"),
                          ),
                          RaisedButton(
                            onPressed: this.status != null ? onPause : null,
                            child: Text("暂停预览"),
                          ),
                          RaisedButton(
                            onPressed: this.status == null ? onDestroy : null,
                            child: Text("销毁资源"),
                          ),
                          RaisedButton(
                            onPressed: this.status == "READY" ? onPush : null,
                            child: Text("开始推流"),
                          ),
                          RaisedButton(
                            onPressed:
                                this.status == "STREAMING" ? onStopPush : null,
                            child: Text("停止推流"),
                          ),
                          RaisedButton(
                            onPressed: this.status != null
                                ? onCheckZoomSupported
                                : null,
                            child: Text("是否支持缩放"),
                          ),
                          RaisedButton(
                            onPressed:
                                this.status != null ? onSetMaxZoom : null,
                            child: Text("设置为最大缩放比例"),
                          ),
                          RaisedButton(
                            onPressed: this.status != null ? onResetZoom : null,
                            child: Text("重置缩放比例"),
                          ),
                          RaisedButton(
                            onPressed:
                                this.status != null ? onTurnLightOn : null,
                            child: Text("开启闪光灯"),
                          ),
                          RaisedButton(
                            onPressed:
                                this.status != null ? onTurnLightOff : null,
                            child: Text("关闭闪光灯"),
                          ),
                          RaisedButton(
                            onPressed:
                                this.status != null ? onSwitchCamera : null,
                            child: Text("切换摄像头"),
                          ),
                          RaisedButton(
                            onPressed: this.status != null
                                ? onSwitchFrontCamera
                                : null,
                            child: Text("切换前置摄像头"),
                          ),
                          RaisedButton(
                            onPressed:
                                this.status != null ? onSwitchBackCamera : null,
                            child: Text("切换后置摄像头"),
                          ),
                          RaisedButton(
                            onPressed:
                                this.status != null ? onSwitch3DRCamera : null,
                            child: Text("切换3DR摄像头"),
                          ),
                          RaisedButton(
                            onPressed:
                                this.status != null ? () => onMute(true) : null,
                            child: Text("开启静音"),
                          ),
                          RaisedButton(
                            onPressed: this.status != null
                                ? () => onMute(false)
                                : null,
                            child: Text("恢复声音"),
                          ),
                          RaisedButton(
                            onPressed: this.status != null
                                ? () => onSetNativeLoggingEnabled(false)
                                : null,
                            child: Text("关闭日志"),
                          ),
                          RaisedButton(
                            onPressed: this.status != null
                                ? () => onSetNativeLoggingEnabled(false)
                                : null,
                            child: Text("启用日志(控制台查看)"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
