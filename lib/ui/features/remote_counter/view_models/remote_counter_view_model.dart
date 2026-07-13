import 'package:flutter/foundation.dart';
import 'package:flutter_rfw_example/data/repositories/remote_ui_repository.dart';
// Texto .rfwtxt: importar formats. (rfw.dart esconde parse* de propósito —
// em produção use decodeLibraryBlob no blob .rfw.)
import 'package:rfw/formats.dart' show parseLibraryFile;
import 'package:rfw/rfw.dart';

/// Encapsula o ciclo de vida RFW deste exemplo.
///
/// Peças oficiais do pacote `rfw`:
///
/// | API | Função |
/// |-----|--------|
/// | [Runtime] | Registro de libs locais + remota |
/// | [DynamicContent] | Dados vivos (`data.*` no .rfwtxt) |
/// | `createCoreWidgets` / `createMaterialWidgets` | Libs locais |
/// | [parseLibraryFile] | Parse do texto remoto (demo) |
/// | eventos via [onEvent] | Resposta a `event "nome"` do .rfwtxt |
class RemoteCounterViewModel extends ChangeNotifier {
  RemoteCounterViewModel({required RemoteUiRepository repository})
    : _repository = repository;

  final RemoteUiRepository _repository;

  /// Resolve nomes (`Text`, `Scaffold`, `root`…) para builders.
  final Runtime runtime = Runtime();

  /// Modelo de dados do RFW. `data.update(...)` → UI remota redesenha.
  final DynamicContent data = DynamicContent();

  /// Devem coincidir com os `import` do `.rfwtxt`:
  /// `import core.widgets;` / `import core.material;`
  static const coreName = LibraryName(<String>['core', 'widgets']);
  static const materialName = LibraryName(<String>['core', 'material']);

  /// Nome da lib remota registrada com [Runtime.update].
  static const mainName = LibraryName(<String>['main']);

  /// Aponta para `widget root = ...` no `.rfwtxt`.
  static const rootWidget = FullyQualifiedWidgetName(mainName, 'root');

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int _counter = 0;
  int get counter => _counter;

  /// Pipeline RFW típico:
  /// 1. registrar libs locais
  /// 2. parse/decode da lib remota → `runtime.update`
  /// 3. popular `DynamicContent`
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

  /// Ligado a [RemoteWidget.onEvent].
  ///
  /// `.rfwtxt`: `onPressed: event "increment" { }`
  /// → `name == 'increment'`, `arguments` = mapa do evento.
  ///
  /// Padrão RFW: evento → lógica Dart → `data.update` → tela muda.
  /// A lib remota em si não “incrementa”; só dispara o evento.
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
