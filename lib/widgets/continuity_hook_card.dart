import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/rich_text_helper.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/historia.dart';
import '../providers/continuity_hook_provider.dart';
import '../screens/continuity_hook_info_screen.dart';
import '../theme/m3_expressive_theme.dart';

/// Card inteligente exibido na Home para histórias em aberto.
///
/// Funciona em duas fases:
/// - **Fase 1** (padrão): texto do gancho + título + teaser da descrição + botões.
/// - **Fase 2** (expandida): opções de atualização de status da história.
///
/// A transição entre fases é animada via [AnimatedSize].
/// O card também anima a entrada com [AnimatedOpacity].
class ContinuityHookCard extends StatefulWidget {
  const ContinuityHookCard({super.key});

  @override
  State<ContinuityHookCard> createState() => _ContinuityHookCardState();
}

class _ContinuityHookCardState extends State<ContinuityHookCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _opacityAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacityAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    // Registra exibição e anima entrada após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _entryController.forward();
      context.read<ContinuityHookProvider>().markDisplayed();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Cor da borda baseada no status de continuidade
  // ---------------------------------------------------------------------------

  Color _borderColor(BuildContext context, Historia story) {
    final cs = Theme.of(context).colorScheme;
    switch (story.continua) {
      case 4: // SIM
        return cs.primary; // verde/primário do tema
      case 3: // TALVEZ
        return Colors.deepPurple.shade300;
      case 2: // NÃO SEI
        return Colors.blueAccent.shade200;
      default:
        return cs.outlineVariant;
    }
  }

  // ---------------------------------------------------------------------------
  // Texto do gancho localizado
  // ---------------------------------------------------------------------------

  String _hookText(AppLocalizations l10n, GanchoType? type) {
    switch (type) {
      case GanchoType.g01:
        return l10n.continuityHookG01;
      case GanchoType.g03:
        return l10n.continuityHookG03;
      case GanchoType.talvez:
        return l10n.continuityHookTalvez;
      case GanchoType.naoSei:
        return l10n.continuityHookNaoSei;
      case GanchoType.genericSim:
        return l10n.continuityHookGenericSim;
      case GanchoType.genericTalvez:
        return l10n.continuityHookGenericTalvez;
      case GanchoType.genericNaoSei:
        return l10n.continuityHookGenericNaoSei;
      case GanchoType.g02:
      case null:
        return l10n.continuityHookG02;
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContinuityHookProvider>();
    final story = provider.hookStory;

    if (story == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor = _borderColor(context, story);

    final plainText = RichTextHelper.jsonToPlainText(story.descricao);

    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: borderColor, width: 1.5),
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Badge + Ícone de informações ----
                    Row(
                      children: [
                        _Badge(
                            color: borderColor,
                            label: l10n.continuityHookBadge),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          tooltip: l10n.continuityInfoTitle,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ContinuityHookInfoScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ---- Texto do gancho ----
                    Text(
                      _hookText(l10n, provider.ganchoType),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ---- Título da história ----
                    Text(
                      story.titulo,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.labelColor(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // ---- Teaser da descrição (max 3 linhas, itálico) ----
                    if (plainText.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        plainText.trim(),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // ---- Fase 1: botões principais ----
                    if (!provider.isExpanded) _Phase1Buttons(story: story),

                    // ---- Fase 2: seletor de status (expandido) ----
                    if (provider.isExpanded)
                      _Phase2Options(continua: story.continua),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Badge de identificação
// -----------------------------------------------------------------------------

class _Badge extends StatelessWidget {
  final Color color;
  final String label;

  const _Badge({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Fase 1 — Botões principais
// -----------------------------------------------------------------------------

class _Phase1Buttons extends StatelessWidget {
  final Historia story;

  const _Phase1Buttons({required this.story});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<ContinuityHookProvider>();

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => provider.continueStory(context, '/create-historia'),
            icon: const Icon(Icons.edit_note, size: 18),
            label: Text(l10n.continuityHookBtnContinue),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => context.read<ContinuityHookProvider>().toggleExpanded(),
          icon: const Icon(Icons.expand_more, size: 18),
          label: Text(l10n.continuityHookBtnOptions),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 40),
            textStyle: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Fase 2 — Opções de atualização de status
// -----------------------------------------------------------------------------

class _Phase2Options extends StatelessWidget {
  /// Valor atual do campo `continua` da história exibida.
  final int continua;

  const _Phase2Options({required this.continua});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<ContinuityHookProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    final options = [
      (
        label: l10n.continuaYes,
        emoji: '✅',
        value: 4,
        color: Colors.green.shade600,
      ),
      (
        label: l10n.continuaMaybe,
        emoji: '⏳',
        value: 3,
        color: Colors.deepPurple.shade400,
      ),
      (
        label: l10n.continuaDontKnow,
        emoji: '🤷',
        value: 2,
        color: Colors.blueAccent.shade400,
      ),
      (
        label: l10n.continuityStatusClose,
        emoji: '❌',
        value: 1,
        color: colorScheme.error,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Botão de fechar a fase 2
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.expand_less),
            onPressed: () =>
                context.read<ContinuityHookProvider>().toggleExpanded(),
            tooltip: 'Fechar opções',
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options
              .map(
                (opt) => _StatusChip(
                  label: opt.label,
                  emoji: opt.emoji,
                  value: opt.value,
                  color: opt.color,
                  isSelected: continua == opt.value,
                  onTap: () => provider.updateStatus(opt.value),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String emoji;
  final int value;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.emoji,
    required this.value,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withValues(alpha: isSelected ? 1.0 : 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
