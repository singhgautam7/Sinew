import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'timer_session.dart';

/// Wraps the app so a timer left running is restored as soon as the app
/// starts (not only when the Timer tab is opened) and is brought up to date
/// whenever the app returns to the foreground.
///
/// Sits inside the root `ProviderScope`, above the router.
class TimerBootstrap extends ConsumerStatefulWidget {
  const TimerBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<TimerBootstrap> createState() => _TimerBootstrapState();
}

class _TimerBootstrapState extends ConsumerState<TimerBootstrap>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(timerSessionProvider.notifier).syncFromService();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watching starts the restore and keeps the session alive.
    ref.watch(timerSessionProvider);
    return widget.child;
  }
}
