import 'package:flutter/material.dart';

/// Formulario de **Login seguro** — widget de presentación puro: valida el
/// formato de los campos y delega la autenticación (incluida la
/// comparación contra contraseñas encriptadas) en `SesionAuth`.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.cargando, required this.onEnviar});

  final bool cargando;
  final void Function(String nombreUsuario, String contrasena) onEnviar;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _llaveFormulario = GlobalKey<FormState>();
  final TextEditingController _usuarioCtrl = TextEditingController();
  final TextEditingController _contrasenaCtrl = TextEditingController();
  bool _ocultarContrasena = true;

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _contrasenaCtrl.dispose();
    super.dispose();
  }

  void _enviar() {
    if (_llaveFormulario.currentState?.validate() ?? false) {
      widget.onEnviar(_usuarioCtrl.text.trim(), _contrasenaCtrl.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _llaveFormulario,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            controller: _usuarioCtrl,
            enabled: !widget.cargando,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Usuario',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (String? valor) {
              if (valor == null || valor.trim().isEmpty) {
                return 'Captura tu usuario';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _contrasenaCtrl,
            enabled: !widget.cargando,
            obscureText: _ocultarContrasena,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _enviar(),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(_ocultarContrasena
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _ocultarContrasena = !_ocultarContrasena),
              ),
            ),
            validator: (String? valor) {
              if (valor == null || valor.isEmpty) {
                return 'Captura tu contraseña';
              }
              if (valor.length < 6) {
                return 'Debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: widget.cargando ? null : _enviar,
            icon: widget.cargando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login_rounded),
            label: Text(widget.cargando ? 'Verificando…' : 'Iniciar sesión'),
          ),
        ],
      ),
    );
  }
}
