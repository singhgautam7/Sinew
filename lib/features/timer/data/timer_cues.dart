import '../../../core/models/timer_preset.dart';
import '../../../core/settings/app_settings.dart';

/// [base] with sound, haptic and voice taken from Settings > Timer. The
/// countdown length and the warning stay the mode's own (boxing warns ten
/// seconds before a round ends, for example).
///
/// Used wherever cues are born: a new setup, the built-in presets when they
/// are first inserted, a timer started without a setup screen. A saved preset
/// keeps the cues it was saved with.
TimerCues seedCues(TimerCues base, AppSettings settings) => base.copyWith(
  sound: settings.timerSound,
  haptic: settings.timerHaptic,
  voice: settings.timerVoice,
);
