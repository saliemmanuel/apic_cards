import '../entities/member.dart';
import '../services/card_pdf_generator.dart';

/// Cas d'usage déléguant la génération du document PDF A4 des cartes professionnelles.
class GenerateCardsPdfUseCase {
  final CardPdfGenerator _pdfGenerator;

  const GenerateCardsPdfUseCase(this._pdfGenerator);

  Future<List<int>> call(List<Member> members) async {
    return await _pdfGenerator.generatePdf(members);
  }
}
