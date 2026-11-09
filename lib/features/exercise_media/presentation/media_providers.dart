// Riverpod providers for exercise media, motion player, and figure assets.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinew/core/db/library/library_db.dart';
import 'package:sinew/core/providers.dart';

import '../data/exercise_media_repository.dart';
import '../data/figure_assets.dart';
import '../data/motion_model.dart';

/// Singleton repository provider for motion records.
final FutureProvider<ExerciseMediaRepository> exerciseMediaRepositoryProvider =
    FutureProvider<ExerciseMediaRepository>((Ref ref) async {
      final LibraryDatabase db = await ref.watch(libraryDatabaseProvider.future);
      return ExerciseMediaRepository(db: db);
    });

/// Family provider loading a Motion for an exerciseId.
final motionProvider =
    FutureProvider.autoDispose.family<Motion?, String>((
      Ref ref,
      String exerciseId,
    ) async {
      final ExerciseMediaRepository repo = await ref.watch(
        exerciseMediaRepositoryProvider.future,
      );
      return repo.motionFor(exerciseId);
    });

/// Lazy loader for bundled figure specs.
final FutureProvider<FigureAssets> figureAssetsProvider =
    FutureProvider<FigureAssets>((Ref ref) async {
      return FigureAssets.load();
    });
