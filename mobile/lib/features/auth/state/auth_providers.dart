import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/legal_documents_repository.dart';

/// Repositório de autenticação. Trocar pela implementação HTTP quando a API
/// Django existir.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => const MockAuthRepository(),
);

/// Texto dos termos de uso e da política de privacidade. Trocar pela
/// implementação HTTP quando a API Django existir.
final legalDocumentsRepositoryProvider = Provider<LegalDocumentsRepository>(
  (ref) => const PendingLegalDocumentsRepository(),
);
