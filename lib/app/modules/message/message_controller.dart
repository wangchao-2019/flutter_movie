import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/message_model.dart';
import '../../data/repositories/movie_repository.dart';
import '../../modules/auth/auth_controller.dart';

/// 单条留言数据。
class MessageItem {
  final String content;
  final DateTime time;

  const MessageItem({required this.content, required this.time});
}

/// 留言页控制器：管理留言列表与输入。
class MessageController extends GetxController {
  final RxList<MessageItem> messages = <MessageItem>[].obs;
  final TextEditingController textController = TextEditingController();
  final RxBool isSending = false.obs;
  final RxBool isLoading = false.obs;

  final MovieRepository _repository;

  MessageController(this._repository);

  @override
  void onInit() {
    super.onInit();
    loadMessages();
  }

  /// 加载留言列表。
  Future<void> loadMessages() async {
    isLoading.value = true;
    try {
      final List<MessageModel> list = await _repository.getMessages(
        page: 0,
        size: 20,
        token: AuthController.to.tokenValue,
      );
      messages.assignAll(list.map((MessageModel m) => MessageItem(
            content: m.content,
            time: m.createdAt,
          )));
    } catch (e) {
      final String msg = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      Get.snackbar(
        '加载失败',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 发送留言：调用后端接口，成功后插入本地列表。
  Future<void> send() async {
    final String text = textController.text.trim();
    if (text.isEmpty || isSending.value) return;

    isSending.value = true;
    try {
      await _repository.submitMessage(
        text,
        token: AuthController.to.tokenValue,
      );

      messages.insert(0, MessageItem(content: text, time: DateTime.now()));
      textController.clear();
    } catch (e) {
      final String msg = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      Get.snackbar(
        '提交失败',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isSending.value = false;
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
