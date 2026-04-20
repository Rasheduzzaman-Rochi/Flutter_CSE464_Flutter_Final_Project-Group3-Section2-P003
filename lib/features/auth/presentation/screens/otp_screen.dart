import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants.dart';
import '../../provider/auth_provider.dart';
import '../widgets/auth_shell.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;
  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AuthShell(
      title: 'OTP Verification',
      subtitle: 'Enter the 6-digit code sent to your account.',
      icon: Icons.shield_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F7FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD5E6FA)),
            ),
            child: Text(
              'For demo, use OTP: ${auth.lastOtpCode.isEmpty ? '123456' : auth.lastOtpCode}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF1E3A5F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              _otpLength,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == _otpLength - 1 ? 0 : 8,
                  ),
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    decoration: InputDecoration(
                      hintText: '-',
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => _onOtpChanged(index, value),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: auth.isLoading ? null : () => _verifyOtp(context),
            child: auth.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Verify OTP'),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'Need to update your account details?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.signup),
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('Back To Sign Up'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1B4965),
                side: const BorderSide(color: Color(0xFFBFD5EA)),
                backgroundColor: const Color(0xFFF8FBFF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyOtp(BuildContext context) async {
    final enteredOtp = _enteredOtp;
    if (enteredOtp.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 OTP digits.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final error = await auth.verifyOtp(enteredOtp);

    if (!context.mounted) {
      return;
    }

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  String get _enteredOtp =>
      _otpControllers.map((controller) => controller.text).join();

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
      return;
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }
}
