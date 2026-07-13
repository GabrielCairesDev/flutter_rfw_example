import 'package:flutter/services.dart';

/// Simula fetch de UI remota (asset local). Troque por HTTP em produção.
class RemoteUiService {
  Future<String> fetchLibraryText(String assetPath) {
    return rootBundle.loadString(assetPath);
  }
}
