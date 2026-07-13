import 'package:flutter/services.dart';

/// Obtém a biblioteca remota RFW.
///
/// Neste exemplo: lê asset `.rfwtxt` (offline, fácil de editar).
/// Em app real: HTTP que devolve blob `.rfw` → `decodeLibraryBlob`.
class RemoteUiService {
  Future<String> fetchLibraryText(String assetPath) {
    return rootBundle.loadString(assetPath);
  }
}
