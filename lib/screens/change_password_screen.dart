import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/services/api_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String userToken; // UserToken harus disediakan

  ChangePasswordScreen({required this.userToken});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _currentPassword = '';
  String _newPassword = '';
  String _confirmNewPassword = '';
  bool _submitted = false;

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  void showSnackBar(String message, {Color color = Colors.red, Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color, duration: duration,));
  }

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
      appBar: AppBar(title: const Text('')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Change Your Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Current Password',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: !_showCurrentPassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14.0,
                      horizontal: 16.0,
                    ),
                    hintText: 'Enter Old password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showCurrentPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(
                          () => _showCurrentPassword = !_showCurrentPassword,
                        );
                      },
                    ),
                  ),

                  onChanged:
                      (value) => setState(() => _currentPassword = value),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'New Password',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_showNewPassword,
                  onChanged: (value) => setState(() => _newPassword = value),
                  decoration: InputDecoration(
                    hintText: 'Enter new password',
                    errorText:
                        newPasswordHasError
                            ? '${_newPassword.length < 6 ? 'Password tidak boleh kurang dari 6 karakter' : 'Password tidak boleh sama dengan sebelumnya'}'
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: newPasswordHasError ? Colors.red : Colors.grey,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showNewPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _showNewPassword = !_showNewPassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silakan isi password baru';
                    }
                    if (value == _currentPassword) {
                      return 'Password tidak boleh sama dengan sebelumnya';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                const Text(
                  'Confirm New Password',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  onChanged:
                      (value) => setState(() => _confirmNewPassword = value),
                  decoration: InputDecoration(
                    hintText: 'Confirm new password',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14.0,
                      horizontal: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color:
                            confirmPasswordIsValid
                                ? Colors.green
                                : Colors.grey.shade400,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color:
                            confirmPasswordIsValid ? Colors.green : Colors.blue,
                        width: 2.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    errorText:
                        confirmPasswordHasError
                            ? 'Password tidak sinkron'
                            : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(
                          () => _showConfirmPassword = !_showConfirmPassword,
                        );
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silakan konfirmasi password baru';
                    }
                    if (value != _newPassword) {
                      return 'Password tidak sinkron';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() => _submitted = true);

                      final formValid = _formKey.currentState!.validate();
                      final confirmPasswordIsEmpty =
                          _confirmNewPassword.trim().isEmpty;
                      final passwordMatch = _newPassword == _confirmNewPassword;
                      final isSameAsOld = _newPassword == _currentPassword;

                      if (!formValid) {
                        if (_currentPassword.trim().isEmpty ||
                            _newPassword.trim().isEmpty ||
                            confirmPasswordIsEmpty) {
                          showSnackBar("Semua kolom harus diisi.");
                        } else if (isSameAsOld) {
                          showSnackBar(
                            "Password tidak boleh sama dengan sebelumnya.",
                          );
                        } else if (!passwordMatch) {
                          showSnackBar("Password tidak sinkron.");
                        } else {
                          showSnackBar("Terdapat kesalahan pada input.");
                        }
                        return;
                      }

                      try {
                        showSnackBar(
                          "Mengubah password...",
                          color: Colors.blue,
                          duration: const Duration(seconds: 1),
                        );
                        final api = ApiService();
                        final message = await api.changePassword(
                          token: widget.userToken,
                          currentPassword: _currentPassword,
                          newPassword: _newPassword,
                          confirmPassword: _confirmNewPassword,
                        );

                        showSnackBar(message, color: Colors.green, duration: const Duration(seconds: 2));

                        // Tunggu 2 detik sebelum navigasi agar user lihat feedback visual
                        await Future.delayed(const Duration(seconds: 1));

                        // Navigasi ke MainScreen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    MainScreen(userToken: widget.userToken),
                          ),
                        );
                      } catch (e) {
                        showSnackBar(
                          'Gagal: ${e.toString()}',
                          color: Colors.red,
                        );
                      }
                    },

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
}
