import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/audit_repository.dart';
import '../data/models/log_model.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepository(ref.read(apiClientProvider));
});

final logsProvider = FutureProvider.autoDispose<List<LogModel>>((ref) async {
  final repo = ref.read(auditRepositoryProvider);
  return repo.getLogs(null);
});
