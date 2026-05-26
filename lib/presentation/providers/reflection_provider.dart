import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/reflection_repository.dart';
import '../../domain/models/reflection.dart';

final reflectionRepositoryProvider =
    Provider<ReflectionRepository>((_) => ReflectionRepository());

final todayReflectionProvider = FutureProvider<Reflection?>(
    (ref) => ref.watch(reflectionRepositoryProvider).getTodayReflection());

final allReflectionsProvider = FutureProvider<List<Reflection>>(
    (ref) => ref.watch(reflectionRepositoryProvider).getAll());
