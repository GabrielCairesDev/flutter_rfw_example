import 'package:flutter/foundation.dart';
import 'package:flutter_rfw_example/data/repositories/remote_ui_repository.dart';
import 'package:rfw/formats.dart' show parseLibraryFile;
import 'package:rfw/rfw.dart';

class RemoteCounterViewModel extends ChangeNotifier {
  RemoteCounterViewModel({required RemoteUiRepository repository})
    : _repository = repository;

  final RemoteUiRepository _repository;

  final Runtime runtime = Runtime();
  final DynamicContent data = DynamicContent();

  static const coreName = LibraryName(<String>['core', 'widgets']);
  static const materialName = LibraryName(<String>['core', 'material']);
  static const mainName = LibraryName(<String>['main']);

  static const rootWidget = FullyQualifiedWidgetName(mainName, 'root');

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int _counter = 0;
  int get counter => _counter;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      runtime.update(coreName, createCoreWidgets());
      runtime.update(materialName, createMaterialWidgets());

      final library = await _repository.loadCounterUi();
      runtime.update(mainName, parseLibraryFile(library.source));

      for (final entry in library.initialData.entries) {
        data.update(entry.key, entry.value);
      }
      _counter = 0;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onEvent(String name, DynamicMap arguments) {
    switch (name) {
      case 'increment':
        _counter += 1;
        data.update('counter', <String, Object>{'value': '$_counter'});
      case 'reset':
        _counter = 0;
        data.update('counter', <String, Object>{'value': '$_counter'});
      default:
        debugPrint('evento RFW desconhecido: $name $arguments');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    runtime.dispose();
    super.dispose();
  }
}
