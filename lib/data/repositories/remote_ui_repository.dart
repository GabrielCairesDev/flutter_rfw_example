import 'package:flutter_rfw_example/data/services/remote_ui_service.dart';
import 'package:flutter_rfw_example/domain/models/remote_ui_library.dart';

/// Entrega a lib RFW + o mapa inicial do [DynamicContent].
///
/// O `.rfwtxt` referencia esses dados assim:
/// - `data.user.name`
/// - `data.counter.value`
///
/// O `Text` do RFW só aceita pedaços String. Por isso `counter.value` é `'0'`,
/// não o inteiro `0` — senão o número some na tela.
class RemoteUiRepository {
  RemoteUiRepository({required RemoteUiService service}) : _service = service;

  final RemoteUiService _service;

  /// Declarado em `pubspec.yaml` → `flutter: assets:`.
  static const assetPath = 'assets/remote/counter.rfwtxt';

  Future<RemoteUiLibrary> loadCounterUi() async {
    final source = await _service.fetchLibraryText(assetPath);
    return RemoteUiLibrary(
      source: source,
      initialData: <String, Object>{
        'user': <String, Object>{'name': 'Gabriel'},
        'counter': <String, Object>{'value': '0'},
      },
    );
  }
}
