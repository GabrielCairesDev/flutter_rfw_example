/// Insumos do RFW: biblioteca de widgets + dados de configuração.
///
/// RFW separa sempre:
/// 1. **Library** ([source]) — “como desenhar” (`.rfwtxt` / blob `.rfw`)
/// 2. **Data** ([initialData]) — “o que mostrar” (`DynamicContent`)
///
/// Mudar layout/widgets ≠ mudar dados. São updates independentes no Runtime.
class RemoteUiLibrary {
  const RemoteUiLibrary({
    required this.source,
    required this.initialData,
  });

  /// Conteúdo `.rfwtxt` (texto). Em produção: bytes `.rfw` + `decodeLibraryBlob`.
  final String source;

  /// Raiz do [DynamicContent]: maps/lists/scalars (sem `null`).
  /// No `.rfwtxt` vira `data.user`, `data.counter`, etc.
  final Map<String, Object> initialData;
}
