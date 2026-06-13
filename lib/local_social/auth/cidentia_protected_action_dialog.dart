import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/local_social/auth/cidentia_auth_gate_contract.dart';

class CidentiaProtectedActionDialog {
  const CidentiaProtectedActionDialog._();

  static Future<void> show(
    BuildContext context, {
    required CidentiaProtectedAction action,
    CidentiaGateLanguage language = CidentiaGateLanguage.tr,
  }) {
    final message = CidentiaAuthGateContract.messageFor(action, language);

    return showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF06111F),
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: Color(0x4438BDF8)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0EA5E9), Color(0xFF7C3AED)],
                          ),
                        ),
                        child: const Icon(Icons.verified_user_outlined),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'CidenDB CID gerekli',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Kapat',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFFD1D5DB),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Cidentia.Live içinde içerikleri misafir olarak '
                    'gezebilirsin. Profil düzenleme, takip, yorum, mesaj, '
                    'canlı yayın, upload, wallet ve proof gibi gerçek '
                    'işlemler için doğrulanmış CID oturumu gerekir.',
                    style: TextStyle(
                      color: Color(0xFFA1A1AA),
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'CidenDB OTP köprüsü M4B aşamasında gerçek '
                            'backend ile bağlanacak.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('CidenDB ile giriş yap'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'CID kaydı olmayan kullanıcı CidentiaApp '
                            'onboarding akışına yönlendirilecek.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('CidentiaApp ile kayıt / onboarding'),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.public_rounded),
                    label: const Text('Misafir olarak gezmeye devam et'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
