import '../db/database_helper.dart';
import '../db/historia_audio_helper.dart';
import '../db/historia_foto_helper.dart';
import '../db/historia_video_helper.dart';
import '../models/historia.dart';
import '../repositories/historia_repository.dart';
import '../services/file_utils.dart';

class TrashService {
  final HistoriaRepository _repository;
  final HistoriaFotoHelper _fotoHelper;
  final HistoriaAudioHelper _audioHelper;
  final HistoriaVideoHelper _videoHelper;

  TrashService({
    HistoriaRepository? repository,
    HistoriaFotoHelper? fotoHelper,
    HistoriaAudioHelper? audioHelper,
    HistoriaVideoHelper? videoHelper,
  }) : _repository = repository ?? HistoriaRepository(),
       _fotoHelper = fotoHelper ?? HistoriaFotoHelper(),
       _audioHelper = audioHelper ?? HistoriaAudioHelper(),
       _videoHelper = videoHelper ?? HistoriaVideoHelper();

  Future<List<Historia>> fetchDeletedStories(String userId) async {
    await DatabaseHelper().deleteExpiredTrashStories(userId: userId);
    return _repository.fetchDeletedStories(userId: userId);
  }

  Future<List<Historia>> fetchArchivedStories(String userId) async {
    return _repository.fetchArchivedStories(userId: userId);
  }

  Future<void> restoreStories(List<Historia> historias) async {
    for (final historia in historias) {
      await _repository.restoreHistoria(historia);
    }
  }

  Future<void> permanentlyDeleteStories(List<Historia> historias) async {
    for (final historia in historias) {
      await _deleteHistoriaMedia(historia);
      await _repository.deleteHistoriaPermanently(historia);
    }
  }

  Future<void> emptyTrash(String userId) async {
    final deletedStories = await fetchDeletedStories(userId);
    for (final historia in deletedStories) {
      await _deleteHistoriaMedia(historia);
    }
    await _repository.deleteStoriesPermanentlyByUser(userId);
  }

  Future<void> _deleteHistoriaMedia(Historia historia) async {
    if (historia.id == null) return;
    await _fotoHelper.deleteFotosByHistoria(historia.id!);
    await _audioHelper.deleteAudiosByHistoria(historia.id!);
    await _videoHelper.deleteVideosByHistoria(historia.id!);
    await FileUtils.deleteFileIfExists(historia.fotoHistoria);
  }
}
