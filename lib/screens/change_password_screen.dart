import 'package:flutter/material.dart';
import 'package:arcdev_absensi/screens/home_screen.dart';
import 'package:arcdev_absensi/services/api_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String userToken;
  final String userUUID;

  ChangePasswordScreen({required this.userToken, required this.userUUID});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _currentPassword = '';
  String _newPassword = '';
  String _confirmNewPassword = '';
  bool _submitted = false;

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newPasswordHasError =
        _newPassword.isNotEmpty &&
        (_newPassword == _currentPassword || _newPassword.length < 6);

    final confirmPasswordHasError =
        _confirmNewPassword.isNotEmpty && _confirmNewPassword != _newPassword;

    final confirmPasswordIsValid =
        _confirmNewPassword.isNotEmpty &&
        _confirmNewPassword == _newPassword &&
        _newPassword != _currentPassword &&
        _newPassword.length >= 6;

    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Change Your Password',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),

                _buildLabel('Current Password'),
                _buildPasswordField(
                  controller: _currentPasswordController,
                  hint: 'Enter old password',
                  obscure: !_showCurrentPassword,
                  toggleObscure:
                      () => setState(
                        () => _showCurrentPassword = !_showCurrentPassword,
                      ),
                  onChanged: (val) => setState(() => _currentPassword = val),
                  validator:
                      (val) =>
                          val == null || val.isEmpty
                              ? 'Please enter your current password'
                              : null,
                ),

                const SizedBox(height: 25),
                _buildLabel('New Password'),
                _buildPasswordField(
                  controller: _newPasswordController,
                  hint: 'Enter new password',
                  obscure: !_showNewPassword,
                  toggleObscure:
                      () =>
                          setState(() => _showNewPassword = !_showNewPassword),
                  onChanged: (val) => setState(() => _newPassword = val),
                  errorText:
                      newPasswordHasError
                          ? (_newPassword.length < 6
                              ? 'Password harus minimal 6 karakter'
                              : 'Password tidak boleh sama dengan sebelumnya')
                          : null,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return 'Silakan isi password baru';
                    if (val == _currentPassword)
                      return 'Password tidak boleh sama dengan sebelumnya';
                    if (val.length < 6)
                      return 'Password harus minimal 6 karakter';
                    return null;
                  },
                ),

                const SizedBox(height: 25),
                _buildLabel('Confirm New Password'),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  hint: 'Confirm new password',
                  obscure: !_showConfirmPassword,
                  toggleObscure:
                      () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword,
                      ),
                  onChanged: (val) => setState(() => _confirmNewPassword = val),
                  errorText:
                      confirmPasswordHasError ? 'Password tidak sinkron' : null,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return 'Silakan konfirmasi password baru';
                    if (val != _newPassword) return 'Password tidak sinkron';
                    return null;
                  },
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleChangePassword,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggleObscure,
    required ValueChanged<String> onChanged,
    String? errorText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14.0,
          horizontal: 16.0,
        ),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleObscure,
        ),
      ),
    );
  }

  Future<void> _handleChangePassword() async {
    setState(() => _submitted = true);

    final formValid = _formKey.currentState!.validate();
    final confirmPasswordIsEmpty = _confirmNewPassword.trim().isEmpty;
    final passwordMatch = _newPassword == _confirmNewPassword;
    final isSameAsOld = _newPassword == _currentPassword;

    if (!formValid) {
      String errorMsg = "Terdapat kesalahan pada input.";
      if (_currentPassword.trim().isEmpty ||
          _newPassword.trim().isEmpty ||
          confirmPasswordIsEmpty) {
        errorMsg = "Semua kolom harus diisi.";
      } else if (isSameAsOld) {
        errorMsg = "Password tidak boleh sama dengan sebelumnya.";
      } else if (!passwordMatch) {
        errorMsg = "Password tidak sinkron.";
      }

      _showDialog(DialogType.warning, 'Gagal', errorMsg, Colors.orange);
      return;
    }

    try {
      final api = ApiService();
      final message = await api.changePassword(
        token: widget.userToken,
        currentPassword: _currentPassword,
        newPassword: _newPassword,
        confirmPassword: _confirmNewPassword,
      );

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Berhasil',
        desc: message,
        btnOkOnPress: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => MainScreen(
                    userToken: widget.userToken,
                    userUUID: widget.userUUID,
                  ),
            ),
          );
        },
        btnOkColor: Colors.green,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
      ).show();
    } catch (e) {
      _showDialog(
        DialogType.error,
        'Gagal',
        'Gagal mengubah password: ${e.toString()}',
        Colors.red,
      );
    }
  }

  void _showDialog(DialogType type, String title, String desc, Color color) {
    AwesomeDialog(
      context: context,
      dialogType: type,
      animType: AnimType.scale,
      title: title,
      desc: desc,
      btnOkOnPress: () {},
      btnOkColor: color,
      autoHide: const Duration(milliseconds: 2500),
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }
}
