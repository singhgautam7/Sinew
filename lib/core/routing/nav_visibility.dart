import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Why the bottom nav is hidden. The handoff hides it during the active
/// workout, the rest timer and every running timer.
enum NavHideReason { activeWorkout, restTimer, runningTimer, fullScreen }

/// The set of reasons currently hiding the nav. Features add a reason while
/// they need the full screen and remove it after; the nav shows again only
/// when no reason is left, so two features never fight over it.
class NavHideReasons extends Notifier<Set<NavHideReason>> {
  @override
  Set<NavHideReason> build() => const <NavHideReason>{};

  void hide(NavHideReason reason) {
    if (state.contains(reason)) return;
    state = <NavHideReason>{...state, reason};
  }

  void show(NavHideReason reason) {
    if (!state.contains(reason)) return;
    state = <NavHideReason>{...state}..remove(reason);
  }

  void set(NavHideReason reason, {required bool hidden}) =>
      hidden ? hide(reason) : show(reason);
}

final NotifierProvider<NavHideReasons, Set<NavHideReason>>
navHideReasonsProvider = NotifierProvider<NavHideReasons, Set<NavHideReason>>(
  NavHideReasons.new,
);

/// True while any feature needs the nav out of the way.
final Provider<bool> navHiddenProvider = Provider<bool>(
  (Ref ref) => ref.watch(navHideReasonsProvider).isNotEmpty,
);
