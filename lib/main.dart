import 'package:flutter/material.dart';
import 'package:flutter_rfw_example/data/repositories/remote_ui_repository.dart';
import 'package:flutter_rfw_example/data/services/remote_ui_service.dart';
import 'package:flutter_rfw_example/ui/features/remote_counter/view_models/remote_counter_view_model.dart';
import 'package:flutter_rfw_example/ui/features/remote_counter/views/remote_counter_view.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const RfwExampleApp());
}

class RfwExampleApp extends StatelessWidget {
  const RfwExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => RemoteUiService()),
        Provider(
          create: (context) => RemoteUiRepository(
            service: context.read<RemoteUiService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => RemoteCounterViewModel(
            repository: context.read<RemoteUiRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'RFW Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: Consumer<RemoteCounterViewModel>(
          builder: (context, viewModel, _) {
            return RemoteCounterView(viewModel: viewModel);
          },
        ),
      ),
    );
  }
}
