import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'movie_player_controller.dart';

class MoviePlayerView extends GetView<MoviePlayerController> {
  const MoviePlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          // 视频区（纯显示）
          Positioned.fill(
            child: Obx(() {
              if (!controller.isInitialized.value) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CircularProgressIndicator(color: Color(0xFFFF7A2E)),
                      SizedBox(height: 16),
                      Text('视频加载中...', style: TextStyle(color: Colors.white60)),
                    ],
                  ),
                );
              }
              // 全屏模式：铺满整个屏幕（cover 裁切）+ 横屏
              if (controller.isFullscreen.value) {
                return SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller.videoController.value.size.width,
                      height: controller.videoController.value.size.height,
                      child: VideoPlayer(controller.videoController),
                    ),
                  ),
                );
              }
              // 默认：竖屏，视频铺满宽度、高度按比例自适应
              return SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: controller.videoController.value.size.width,
                    height: controller.videoController.value.size.height,
                    child: VideoPlayer(controller.videoController),
                  ),
                ),
              );
            }),
          ),

          // 亮度覆盖层（黑色半透明，模拟亮度调节）
          Positioned.fill(
            child: Obx(() => IgnorePointer(
              child: Container(
                color: Colors.black
                    .withOpacity(controller.brightnessOverlayOpacity),
              ),
            )),
          ),

          // 手势+点击层：左半屏调亮度，右半屏调音量，任意位置点击切换控制栏
          Positioned.fill(
            child: GestureDetector(
              onTap: controller.toggleControls,
              child: Row(
                children: <Widget>[
                  // 左半屏：亮度
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: controller.toggleControls,
                      onVerticalDragUpdate: (DragUpdateDetails details) {
                        final double screenHeight = MediaQuery.of(context).size.height;
                        final double deltaFraction =
                            -details.delta.dy / screenHeight * 1.5;
                        controller.adjustBrightnessByDrag(deltaFraction);
                      },
                    ),
                  ),
                  // 右半屏：音量
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: controller.toggleControls,
                      onVerticalDragUpdate: (DragUpdateDetails details) {
                        final double screenHeight = MediaQuery.of(context).size.height;
                        final double deltaFraction =
                            -details.delta.dy / screenHeight * 1.5;
                        controller.adjustVolumeByDrag(deltaFraction);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 音量提示浮层（滑动时短暂显示）
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Obx(() {
                  if (!controller.showVolumeIndicator.value) {
                    return const SizedBox.shrink();
                  }
                  final int percent = (controller.volume.value * 100).round();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          controller.volume.value == 0.0
                              ? Icons.volume_off
                              : controller.volume.value < 0.5
                                  ? Icons.volume_down
                                  : Icons.volume_up,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$percent%',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),

          // 亮度提示浮层（滑动时短暂显示）
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Obx(() {
                  if (!controller.showBrightnessIndicator.value) {
                    return const SizedBox.shrink();
                  }
                  final int percent = (controller.brightness.value * 100).round();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          controller.brightness.value < 0.5
                              ? Icons.brightness_low
                              : Icons.brightness_high,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$percent%',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),

          // 顶部返回栏（播放时自动隐藏）
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Obx(() {
              if (!controller.showControls.value) return const SizedBox.shrink();
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          controller.movie.title,
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          // 底部控制栏（播放时自动隐藏）
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Obx(() {
                if (!controller.isInitialized.value || !controller.showControls.value) {
                  return const SizedBox.shrink();
                }
                final VideoPlayerValue v = controller.videoController.value;
                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: <Color>[Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // 进度条
                      VideoProgressIndicator(
                        controller.videoController,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Color(0xFFFF7A2E),
                          bufferedColor: Colors.white38,
                          backgroundColor: Colors.white12,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: controller.togglePlay,
                            icon: Icon(
                              v.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: controller.toggleMute,
                            icon: Icon(
                              controller.volume.value == 0.0
                                  ? Icons.volume_off
                                  : Icons.volume_up,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDuration(v.position),
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const Text(' / ', style: TextStyle(color: Colors.white38, fontSize: 13)),
                          Text(
                            _formatDuration(v.duration),
                            style: const TextStyle(color: Colors.white38, fontSize: 13),
                          ),
                          const Spacer(),
                          if (controller.isBuffering.value)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                            ),
                          IconButton(
                            onPressed: controller.toggleFullscreen,
                            icon: Icon(
                              controller.isFullscreen.value
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final int minutes = d.inMinutes;
    final int seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
