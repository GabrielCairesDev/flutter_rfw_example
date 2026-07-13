import 'package:flutter_rfw_example/data/services/remote_ui_service.dart';
import 'package:flutter_rfw_example/domain/models/remote_ui_library.dart';

class RemoteUiRepository {
  RemoteUiRepository({required RemoteUiService service}) : _service = service;

  final RemoteUiService _service;

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
