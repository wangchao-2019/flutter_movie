import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import 'login_controller.dart';

const Color _accentOrange = Color(0xFFFF7A2E);

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1021),
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF0D1021),
              Color(0xFF1A1F3A),
              Color(0xFF0D1021),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: <Widget>[
                _buildBackButton(),
                const SizedBox(height: 30),
                _buildLogo(),
                const SizedBox(height: 28),
                _buildTitle(),
                const SizedBox(height: 40),
                _buildForm(),
                const SizedBox(height: 24),
                _buildLoginButton(),
                const SizedBox(height: 20),
                _buildSwitchMode(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () {
            if (Navigator.canPop(Get.context!)) {
              Get.back();
            } else {
              Get.offAllNamed(AppRoutes.movies);
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: _accentOrange.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: _accentOrange.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.movie_creation_outlined,
        size: 38,
        color: _accentOrange,
      ),
    );
  }

  Widget _buildTitle() {
    return Obx(
      () => Column(
        children: <Widget>[
          Text(
            controller.isRegisterMode.value ? '创建账号' : '欢迎回来',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.isRegisterMode.value
                ? '注册后即可同步您的收藏与观看记录'
                : '登录以同步您的收藏与观看记录',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: <Widget>[
        _buildTextField(
          controller: controller.usernameController,
          hint: '邮箱',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        Obx(
          () => _buildTextField(
            controller: controller.passwordController,
            hint: '密码',
            icon: Icons.lock_outline,
            obscure: controller.obscurePassword.value,
            suffix: IconButton(
              icon: Icon(
                controller.obscurePassword.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white54,
                size: 20,
              ),
              onPressed: controller.toggleObscure,
            ),
          ),
        ),
        Obx(
          () => controller.isRegisterMode.value
              ? Column(
                  children: <Widget>[
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: controller.confirmPasswordController,
                      hint: '确认密码',
                      icon: Icons.lock_outline,
                      obscure: controller.obscurePassword.value,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
          prefixIcon: Icon(icon, color: Colors.white54, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : (controller.isRegisterMode.value
                    ? controller.register
                    : controller.login),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentOrange,
            disabledBackgroundColor: _accentOrange.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  controller.isRegisterMode.value ? '注册' : '登录',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSwitchMode() {
    return Obx(
      () => GestureDetector(
        onTap: controller.toggleMode,
        child: RichText(
          text: TextSpan(
            text: controller.isRegisterMode.value ? '已有账号？' : '还没有账号？',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 14,
            ),
            children: <TextSpan>[
              TextSpan(
                text: controller.isRegisterMode.value ? '去登录' : '立即注册',
                style: const TextStyle(
                  color: _accentOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
