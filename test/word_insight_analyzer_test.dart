import 'package:dayapp/services/word_insight_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tokenize removes stopwords and short words', () {
    const analyzer = WordInsightAnalyzer();

    final tokens = analyzer.tokenize(
      'A sua história tem muitas coisas sobre a vida e um teste final.',
    );

    expect(tokens, contains('historia'));
    expect(tokens, contains('coisas'));
    expect(tokens, contains('teste'));
    expect(tokens, isNot(contains('sua')));
    expect(tokens, isNot(contains('tem')));
    expect(tokens, isNot(contains('sobre')));
    expect(
      tokens,
      isNot(contains('final')),
      reason:
          'final is a stopword and should not be used for chapter suggestion',
    );
  });

  test('normalizeText removes accents and punctuation', () {
    const analyzer = WordInsightAnalyzer();

    final normalized = analyzer.normalizeText('Têm café, ação e coração!');

    expect(normalized, 'tem cafe acao e coracao');
  });
}
