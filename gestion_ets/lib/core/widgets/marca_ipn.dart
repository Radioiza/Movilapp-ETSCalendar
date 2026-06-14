import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Emblema del **IPN** sobre una insignia circular blanca. La insignia blanca
/// permite que el logotipo guinda luzca tanto sobre la barra superior guinda
/// como sobre fondos claros, y aporta una sombra sutil que lo despega del
/// fondo. Los assets se declaran en `pubspec.yaml` (carpeta `assets/images/`).
class MarcaIpn extends StatelessWidget {
  const MarcaIpn({super.key, this.tamano = 48});

  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      padding: EdgeInsets.all(tamano * 0.14),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.guinda.withValues(alpha: 0.25),
            blurRadius: tamano * 0.2,
            offset: Offset(0, tamano * 0.06),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/logo_ipn.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

/// Logotipo institucional de la **ESCOM** (incluye la leyenda "Instituto
/// Politécnico Nacional"). Pensado para fondos claros.
class LogoEscom extends StatelessWidget {
  const LogoEscom({super.key, this.altura = 56});

  final double altura;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_escom.png',
      height: altura,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}

/// Encabezado de marca para pantallas de bienvenida/acceso: los escudos del
/// IPN y la ESCOM juntos, el nombre de la app y la firma institucional.
class EncabezadoMarca extends StatelessWidget {
  const EncabezadoMarca({
    super.key,
    required this.titulo,
    this.subtitulo,
  });

  final String titulo;
  final String? subtitulo;

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const MarcaIpn(tamano: 72),
            const SizedBox(width: 20),
            Container(width: 1, height: 52, color: esquema.outlineVariant),
            const SizedBox(width: 20),
            const LogoEscom(altura: 62),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: esquema.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        const FirmaInstitucional(),
        if (subtitulo != null) ...<Widget>[
          const SizedBox(height: 14),
          Text(
            subtitulo!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: esquema.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }
}

/// Pequeña "píldora" con la firma **IPN · ESCOM**, para reforzar la identidad
/// institucional sin saturar la interfaz.
class FirmaInstitucional extends StatelessWidget {
  const FirmaInstitucional({super.key, this.color, this.sobreFondoOscuro = false});

  final Color? color;
  final bool sobreFondoOscuro;

  @override
  Widget build(BuildContext context) {
    final Color base = color ??
        (sobreFondoOscuro ? Colors.white : Theme.of(context).colorScheme.primary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: base.withValues(alpha: sobreFondoOscuro ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: base.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.account_balance_rounded, size: 14, color: base),
          const SizedBox(width: 6),
          Text(
            'IPN · ESCOM',
            style: TextStyle(
              color: base,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
