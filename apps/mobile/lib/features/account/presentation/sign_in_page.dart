import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/imovia_colors.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key, this.returnTo = '/'});
  final String returnTo;

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  bool _codeRequested = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (!_email.text.contains('@')) {
      setState(() => _error = 'Saisis une adresse e-mail valide.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(accountRepositoryProvider).requestCode(_email.text);
      if (mounted) setState(() => _codeRequested = true);
    } on ApiException {
      if (mounted) {
        setState(
          () => _error =
              'Le code n’a pas pu être envoyé. Réessaie dans un instant.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verifyCode() async {
    if (!RegExp(r'^\d{6}$').hasMatch(_code.text.trim())) {
      setState(() => _error = 'Le code doit contenir 6 chiffres.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final token = await ref
          .read(accountRepositoryProvider)
          .verifyCode(_email.text, _code.text);
      await ref.read(sessionTokenStoreProvider).writeToken(token);
      if (mounted) context.go(widget.returnTo);
    } on ApiException {
      if (mounted) {
        setState(
          () => _error = 'Code invalide ou expiré. Demande un nouveau code.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ImoviaColors.page,
    appBar: AppBar(
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 30),
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: const BoxDecoration(
            color: ImoviaColors.ink,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.home_work_outlined,
            color: ImoviaColors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Connecte-toi à IMOVIA',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          _codeRequested
              ? 'Saisis le code reçu par e-mail.'
              : 'Un code de vérification sera envoyé à ton adresse e-mail.',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: ImoviaColors.gray),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: _email,
          enabled: !_codeRequested,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'Adresse e-mail',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        if (_codeRequested) ...[
          const SizedBox(height: 14),
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'Code à 6 chiffres',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: ImoviaColors.danger)),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _busy
              ? null
              : (_codeRequested ? _verifyCode : _requestCode),
          child: _busy
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  _codeRequested ? 'Vérifier et continuer' : 'Recevoir un code',
                ),
        ),
        if (_codeRequested)
          TextButton(
            onPressed: _busy ? null : _requestCode,
            child: const Text('Renvoyer le code'),
          ),
      ],
    ),
  );
}
