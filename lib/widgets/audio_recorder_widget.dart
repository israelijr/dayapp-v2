import 'dart:io';
import 'dart:typed_data';

import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../providers/pin_provider.dart';
import '../theme/m3_expressive_theme.dart';

/// Widget de gravação/seleção de áudio.
/// Suporta seleção múltipla de arquivos de áudio.
class AudioRecorderWidget extends StatefulWidget {
  /// Callback para quando um único áudio é gravado/selecionado (compatibilidade)
  final Function(Uint8List audio, int duration)? onAudioRecorded;

  /// Callback para quando múltiplos áudios são selecionados
  /// Cada item contém: {audio: Uint8List, duration: int}
  final Function(List<Map<String, dynamic>> audios)? onMultipleAudiosSelected;

  /// Se true, permite seleção múltipla de arquivos
  final bool allowMultiple;

  const AudioRecorderWidget({
    this.onAudioRecorded,
    this.onMultipleAudiosSelected,
    super.key,
    this.allowMultiple = true,
  }) : assert(
         onAudioRecorded != null || onMultipleAudiosSelected != null,
         'Deve fornecer onAudioRecorded ou onMultipleAudiosSelected',
       );

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  bool _showRecordingInterface = false;
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isPaused = false;
  int _recordDuration = 0;
  String? _recordingPath;
  bool _isLoading = false;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showRecordingInterface) {
      return _buildRecordingInterface();
    }
    return _buildInitialDialog();
  }

  Widget _buildInitialDialog() {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.audiotrack, size: 64, color: AppColors.primaryVariant),
            const SizedBox(height: 16),
            Text(
              widget.allowMultiple
                  ? AppLocalizations.of(context)!.audioPickerTitleMultiple
                  : AppLocalizations.of(context)!.audioPickerTitleSingle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.labelColor(context),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              )
            else ...[
              Text(
                widget.allowMultiple
                    ? AppLocalizations.of(
                        context,
                      )!.audioPickerChooseOptionMultiple
                    : AppLocalizations.of(
                        context,
                      )!.audioPickerChooseOptionSingle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.labelColor(context),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: widget.allowMultiple
                    ? _pickMultipleAudioFiles
                    : _pickAudioFile,
                icon: const Icon(Icons.folder_open),
                label: Text(
                  widget.allowMultiple
                      ? AppLocalizations.of(
                          context,
                        )!.audioPickerSelectFilesMultiple
                      : AppLocalizations.of(
                          context,
                        )!.audioPickerSelectFilesSingle,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryVariant,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showRecordingInterface = true;
                  });
                },
                icon: const Icon(Icons.mic),
                label: Text(AppLocalizations.of(context)!.audioPickerRecord),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryVariant,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingInterface() {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              size: 64,
              color: _isRecording
                  ? Theme.of(context).colorScheme.error
                  : AppColors.primaryVariant,
            ),
            const SizedBox(height: 16),
            Text(
              _isRecording
                  ? (_isPaused
                        ? AppLocalizations.of(context)!.recordingPaused
                        : AppLocalizations.of(context)!.recording)
                  : AppLocalizations.of(context)!.readyToRecord,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.labelColor(context),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _formatDuration(_recordDuration),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryVariant,
              ),
            ),
            const SizedBox(height: 24),
            if (!_isRecording) ...[
              ElevatedButton.icon(
                onPressed: _startRecording,
                icon: const Icon(Icons.fiber_manual_record),
                label: Text(AppLocalizations.of(context)!.startRecording),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isPaused)
                    IconButton(
                      onPressed: _pauseRecording,
                      icon: const Icon(Icons.pause_circle, size: 48),
                      color: AppColors.emoticonOrange,
                    )
                  else
                    IconButton(
                      onPressed: _resumeRecording,
                      icon: const Icon(Icons.play_circle, size: 48),
                      color: AppColors.emoticonGreen,
                    ),
                  const SizedBox(width: 24),
                  IconButton(
                    onPressed: _stopRecording,
                    icon: const Icon(Icons.stop_circle, size: 48),
                    color: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                if (_isRecording) {
                  await _recorder.stop();
                }
                if (!mounted) return;
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        _recordingPath =
            '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: _recordingPath!,
        );

        setState(() {
          _isRecording = true;
          _isPaused = false;
          _recordDuration = 0;
        });

        _startTimer();
      } else {
        // Permissão negada: fecha o dialog silenciosamente
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorStartRecording(e.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _pauseRecording() async {
    try {
      await _recorder.pause();
      setState(() {
        _isPaused = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorPauseRecording(e.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _resumeRecording() async {
    try {
      await _recorder.resume();
      setState(() {
        _isPaused = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorResumeRecording(e.toString()),
          ),
        ),
      );
    }
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_isRecording && !_isPaused && mounted) {
        setState(() {
          _recordDuration++;
        });
        return true;
      }
      return false;
    });
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();

      if (path != null) {
        final file = File(path);
        final bytes = await file.readAsBytes();

        if (widget.onAudioRecorded != null) {
          widget.onAudioRecorded!(bytes, _recordDuration);
        } else if (widget.onMultipleAudiosSelected != null) {
          widget.onMultipleAudiosSelected!([
            {'audio': bytes, 'duration': _recordDuration},
          ]);
        }

        if (!mounted) return;
        Navigator.of(context).pop();

        // Limpa o arquivo temporário
        try {
          await file.delete();
        } catch (e) {
          // Ignora erro ao deletar arquivo temporário
          debugPrint('AudioRecorderWidget: erro ao excluir áudio temporário: $e');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorStopRecording(e.toString()),
          ),
        ),
      );
    }
  }

  /// Seleciona múltiplos arquivos de áudio
  Future<void> _pickMultipleAudioFiles() async {
    // Seta flag para evitar bloqueio de tela quando o app vai para background
    final pinProvider = context.read<PinProvider>();
    pinProvider.isPickingExternalMedia = true;
    debugPrint('AUDIO: Flag isPickingExternalMedia = true (múltiplos)');

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      // Se o usuário cancelou, aguarda antes de resetar a flag
      if (result == null || result.files.isEmpty) {
        debugPrint('AUDIO: Usuário cancelou, aguardando antes de resetar');
        await Future.delayed(const Duration(milliseconds: 500));
        pinProvider.isPickingExternalMedia = false;
        return;
      }

      if (!mounted) {
        pinProvider.isPickingExternalMedia = false;
        return;
      }
      setState(() => _isLoading = true);

      final List<Map<String, dynamic>> audioDataList = [];
      for (final platformFile in result.files) {
        if (platformFile.path != null) {
          final file = File(platformFile.path!);
          final bytes = await file.readAsBytes();
          // Duração estimada (placeholder)
          const estimatedDuration = 0;
          audioDataList.add({'audio': bytes, 'duration': estimatedDuration});
        }
      }

      // Usa callback de múltiplos áudios se disponível
      if (widget.onMultipleAudiosSelected != null) {
        widget.onMultipleAudiosSelected!(audioDataList);
      } else if (widget.onAudioRecorded != null) {
        for (final audioData in audioDataList) {
          widget.onAudioRecorded!(
            audioData['audio'] as Uint8List,
            audioData['duration'] as int,
          );
        }
      }

      // Aguarda para garantir que eventos de lifecycle foram processados
      debugPrint('AUDIO: Arquivos processados, aguardando antes de resetar');
      await Future.delayed(const Duration(milliseconds: 500));
      pinProvider.isPickingExternalMedia = false;

      if (!mounted) return;
      Navigator.of(context).pop();

      // Mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            audioDataList.length == 1
                ? AppLocalizations.of(context)!.successAudioAdded
                : AppLocalizations.of(context)!.successAudiosAdded(audioDataList.length),
          ),
        ),
      );
    } catch (e) {
      // Garante reset da flag em caso de erro
      pinProvider.isPickingExternalMedia = false;

      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorSelectAudios(e.toString()),
          ),
        ),
      );
    }
  }

  /// Seleciona um único arquivo de áudio (modo único)
  Future<void> _pickAudioFile() async {
    // Seta flag para evitar bloqueio de tela quando o app vai para background
    final pinProvider = context.read<PinProvider>();
    pinProvider.isPickingExternalMedia = true;
    debugPrint('AUDIO: Flag isPickingExternalMedia = true (único)');

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      // Se o usuário cancelou, aguarda antes de resetar a flag
      if (result == null || result.files.single.path == null) {
        debugPrint('AUDIO: Usuário cancelou, aguardando antes de resetar');
        await Future.delayed(const Duration(milliseconds: 500));
        pinProvider.isPickingExternalMedia = false;
        return;
      }

      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();

      // Estima duração (placeholder)
      const estimatedDuration = 0;

      if (widget.onAudioRecorded != null) {
        widget.onAudioRecorded!(bytes, estimatedDuration);
      } else if (widget.onMultipleAudiosSelected != null) {
        widget.onMultipleAudiosSelected!([
          {'audio': bytes, 'duration': estimatedDuration},
        ]);
      }

      // Aguarda para garantir que eventos de lifecycle foram processados
      debugPrint('AUDIO: Arquivo processado, aguardando antes de resetar');
      await Future.delayed(const Duration(milliseconds: 500));
      pinProvider.isPickingExternalMedia = false;

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      // Garante reset da flag em caso de erro
      pinProvider.isPickingExternalMedia = false;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorSelectFile(e.toString()),
          ),
        ),
      );
    }
  }
}
