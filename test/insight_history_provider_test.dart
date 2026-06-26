import 'package:dayapp/models/insight.dart';
import 'package:dayapp/providers/insight_history_provider.dart';
import 'package:dayapp/services/insight_history_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class _FakeInsightHistoryService extends InsightHistoryService {
  final List<InsightHistoryEntry> mockEntries;

  _FakeInsightHistoryService(this.mockEntries);

  @override
  Future<List<InsightHistoryEntry>> getHistory(
    String userId, {
    int? limitDays,
  }) async {
    return mockEntries;
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
    await initializeDateFormatting('en_US', null);
  });

  test('InsightHistoryProvider groups are localized correctly based on locale parameter', () async {
    final entryJune = InsightHistoryEntry(
      id: 1,
      userId: 'user-1',
      type: InsightType.trend,
      title: 'Insight 1',
      description: 'Desc 1',
      icon: 'icon',
      metadata: null,
      seenAt: DateTime(2026, 6, 15), // June 2026
      isPremium: false,
    );

    final service = _FakeInsightHistoryService([entryJune]);
    final provider = InsightHistoryProvider(service);

    // Carrega o histórico
    await provider.load('user-1');

    // Verifica que as entradas foram carregadas
    expect(provider.isLoading, isFalse);

    // Obtém grupos formatados com localidade pt_BR
    final groupsPt = provider.getGroups('pt_BR');
    expect(groupsPt.length, 1);
    // O nome do mês deve começar com "Junho".
    expect(groupsPt[0].label.startsWith('Junho'), isTrue);

    // Obtém grupos formatados com localidade en_US
    final groupsEn = provider.getGroups('en_US');
    expect(groupsEn.length, 1);
    expect(groupsEn[0].label.startsWith('June'), isTrue);
  });
}
