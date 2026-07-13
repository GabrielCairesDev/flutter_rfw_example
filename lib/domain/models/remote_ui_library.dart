/// Biblioteca RFW em texto (.rfwtxt) + dados iniciais de configuração.
class RemoteUiLibrary {
  const RemoteUiLibrary({
    required this.source,
    required this.initialData,
  });

  final String source;
  final Map<String, Object> initialData;
}
