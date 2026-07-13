import 'package:flutter/material.dart';
import 'package:flutter_rfw_example/ui/features/remote_counter/view_models/remote_counter_view_model.dart';
import 'package:rfw/rfw.dart';

/// Hospeda o [RemoteWidget] — ponte Flutter ↔ biblioteca remota RFW.
///
/// Args essenciais do [RemoteWidget]:
/// - `runtime` — libs já registradas
/// - `data` — [DynamicContent]
/// - `widget` — `FullyQualifiedWidgetName` (ex.: main/root)
/// - `onEvent` — callback dos `event "..."` do `.rfwtxt`
class RemoteCounterView extends StatefulWidget {
  const RemoteCounterView({super.key, required this.viewModel});

  final RemoteCounterViewModel viewModel;

  @override
  State<RemoteCounterView> createState() => _RemoteCounterViewState();
}

class _RemoteCounterViewState extends State<RemoteCounterView> {
  @override
  void initState() {
    super.initState();
    // Carrega a lib remota após o 1º frame (evita notify no meio do build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;

        if (vm.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (vm.error != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erro ao carregar UI remota:\n${vm.error}'),
              ),
            ),
          );
        }

        return RemoteWidget(
          runtime: vm.runtime,
          data: vm.data,
          widget: RemoteCounterViewModel.rootWidget,
          onEvent: vm.onEvent,
        );
      },
    );
  }
}
