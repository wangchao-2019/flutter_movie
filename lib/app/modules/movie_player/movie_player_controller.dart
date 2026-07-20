import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:video_player/video_player.dart';

import '../../data/models/movie_model.dart';

/// 播放器控制器：管理 [VideoPlayerController] 的初始化、播放/暂停与进度。
class MoviePlayerController extends GetxController {
  MoviePlayerController(this.movie);

  final Movie movie;

  late final VideoPlayerController videoController;

  /// 本地存储，用于持久化播放进度。
  final GetStorage _box = GetStorage();

  /// 进度存储 key（按电影 id 区分）。
  String get _progressKey => 'play_progress_${movie.id}';

  /// 上次保存进度的时间，用于节流。
  DateTime? _lastSaveAt;

  /// 是否正在缓冲。
  final RxBool isBuffering = false.obs;

  /// 是否初始化完成。
  final RxBool isInitialized = false.obs;

  /// 是否全屏铺满。
  final RxBool isFullscreen = false.obs;

  /// 是否显示控制栏（顶部返回+底部进度）。
  final RxBool showControls = true.obs;

  /// 控制栏自动隐藏计时器（播放时 3 秒后自动隐藏）。
  Timer? _controlsAutoHideTimer;

  /// 音量（0.0 ~ 1.0），用于静音切换。
  final RxDouble volume = 1.0.obs;

  /// 是否显示音量提示浮层（滑动调节时短暂显示）。
  final RxBool showVolumeIndicator = false.obs;

  /// 音量提示浮层自动隐藏计时器。
  Timer? _volumeIndicatorTimer;

  /// 屏幕亮度（0.0 ~ 1.0），用于覆盖层模拟亮度。
  final RxDouble brightness = 1.0.obs;

  /// 覆盖层不透明度（亮度越低，黑色覆盖层越深）。
  double get brightnessOverlayOpacity => 1.0 - brightness.value;

  /// 是否显示亮度提示浮层。
  final RxBool showBrightnessIndicator = false.obs;

  /// 亮度提示浮层自动隐藏计时器。
  Timer? _brightnessIndicatorTimer;

  @override
  void onInit() {
    super.onInit();
    final String url = movie.videoUrl.isNotEmpty
        ? movie.videoUrl
        : '';
    print('url: $url');
    videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) async {
        isInitialized.value = true;
        // 恢复上次观看进度
        final int? savedMs = _box.read(_progressKey) as int?;
        final int totalMs = videoController.value.duration.inMilliseconds;
        print('恢复进度: key=$_progressKey, savedMs=$savedMs, totalMs=$totalMs');
        if (savedMs != null && savedMs > 0 && savedMs < totalMs - 2000) {
          await videoController.seekTo(Duration(milliseconds: savedMs));
          print('已跳转到 ${savedMs}ms');
        }
        videoController.setVolume(volume.value);
        videoController.play();
        _startControlsAutoHide();
        // 初始化完成后再添加监听，避免提前触发保存逻辑
        videoController.addListener(_onVideoChange);
        update();
      }).catchError((Object e) {
        isBuffering.value = false;
      });
  }

  void _onVideoChange() {
    isBuffering.value = videoController.value.isBuffering;
    // 每 5 秒节流保存一次进度，防止应用被杀时丢失
    final DateTime now = DateTime.now();
    if (_lastSaveAt == null || now.difference(_lastSaveAt!).inSeconds >= 5) {
      _saveProgress();
      _lastSaveAt = now;
    }
  }

  /// 保存当前播放进度（看完则不保存，下次从头播放）。
  void _saveProgress() {
    if (!videoController.value.isInitialized) return;
    final int pos = videoController.value.position.inMilliseconds;
    final int total = videoController.value.duration.inMilliseconds;
    if (pos > 0 && pos < total - 2000) {
      _box.write(_progressKey, pos);
    } else {
      _box.remove(_progressKey);
    }
  }

  void togglePlay() {
    if (videoController.value.isPlaying) {
      videoController.pause();
      // 暂停时显示控制栏
      showControls.value = true;
      _controlsAutoHideTimer?.cancel();
    } else {
      videoController.play();
      _startControlsAutoHide();
    }
    update();
  }

  /// 静音前的音量，用于取消静音时恢复。
  double _lastVolume = 1.0;

  /// 设置音量（0.0 ~ 1.0），同时记忆非静音音量。
  void setVolumeLevel(double v) {
    volume.value = v.clamp(0.0, 1.0);
    if (volume.value > 0) _lastVolume = volume.value;
    videoController.setVolume(volume.value);
    update();
  }

  /// 切换静音（记忆上次音量，方便恢复）。
  void toggleMute() {
    if (volume.value == 0.0) {
      setVolumeLevel(_lastVolume);
    } else {
      _lastVolume = volume.value;
      setVolumeLevel(0.0);
    }
  }

  /// 手势上下滑动调节音量。
  /// [deltaFraction] 为相对屏幕高度的滑动比例（向上为正、增大音量）。
  void adjustVolumeByDrag(double deltaFraction) {
    setVolumeLevel(volume.value + deltaFraction);
    // 显示音量提示浮层，并在停止滑动后自动隐藏
    showVolumeIndicator.value = true;
    _volumeIndicatorTimer?.cancel();
    _volumeIndicatorTimer = Timer(const Duration(milliseconds: 800), () {
      showVolumeIndicator.value = false;
    });
  }

  /// 设置屏幕亮度（0.0 ~ 1.0），纯状态驱动覆盖层。
  void setBrightnessLevel(double v) {
    brightness.value = v.clamp(0.0, 1.0);
    update();
  }

  /// 手势上下滑动调节亮度。
  /// [deltaFraction] 为相对屏幕高度的滑动比例（向上为正、增大亮度）。
  void adjustBrightnessByDrag(double deltaFraction) {
    setBrightnessLevel(brightness.value + deltaFraction);
    // 显示亮度提示浮层，并在停止滑动后自动隐藏
    showBrightnessIndicator.value = true;
    _brightnessIndicatorTimer?.cancel();
    _brightnessIndicatorTimer = Timer(const Duration(milliseconds: 800), () {
      showBrightnessIndicator.value = false;
    });
  }

  /// 切换控制栏显示/隐藏，并启动/取消自动隐藏计时器。
  void toggleControls() {
    showControls.value = true;
    update();
    // 如果正在播放，3 秒后自动隐藏；暂停则保持显示
    if (videoController.value.isPlaying) {
      _startControlsAutoHide();
    }
  }

  /// 启动控制栏 3 秒后自动隐藏计时器（仅全屏模式下生效）。
  void _startControlsAutoHide() {
    _controlsAutoHideTimer?.cancel();
    // 竖屏时不自动隐藏，控制栏常驻
    if (!isFullscreen.value) return;
    _controlsAutoHideTimer = Timer(const Duration(seconds: 3), () {
      // 全屏 + 播放中才隐藏
      if (isFullscreen.value && videoController.value.isPlaying) {
        showControls.value = false;
        update();
      }
    });
  }

  void toggleFullscreen() {
    isFullscreen.value = !isFullscreen.value;
    if (isFullscreen.value) {
      // 进入横屏全屏
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      showControls.value = true;
      _startControlsAutoHide();
    } else {
      // 退出全屏，恢复竖屏
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    update();
  }

  @override
  void onClose() {
    // 退出时保存进度，并恢复竖屏和系统UI
    _saveProgress();
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _volumeIndicatorTimer?.cancel();
    _brightnessIndicatorTimer?.cancel();
    _controlsAutoHideTimer?.cancel();
    videoController.removeListener(_onVideoChange);
    videoController.dispose();
    super.onClose();
  }
}
