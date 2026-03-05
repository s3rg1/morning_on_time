import 'package:dnd_checker/dnd_checker.dart';
import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';
import '../l10n/app_localizations.dart';

/// Utility class for volume-related operations
class VolumeUtils {
  /// Check device volume and DND status, showing warning dialogs as needed.
  /// 
  /// Shows a low-volume warning if media volume is below 70%, and/or a DND
  /// warning if Do Not Disturb is active (sounds and TTS are skipped during DND).
  /// 
  /// [context] - BuildContext for showing dialog and accessing localizations
  /// [checkSetupComplete] - Optional callback to verify if setup is complete before checking
  /// 
  /// Returns true if any warning was shown, false if skipped
  static Future<bool> checkVolumeAndWarn(
    BuildContext context, {
    bool Function()? checkSetupComplete,
  }) async {
    try {
      // If setup check is provided and returns false, skip checks
      if (checkSetupComplete != null && !checkSetupComplete()) {
        return false;
      }

      bool warningShown = false;

      // Check volume level
      final volume = await VolumeController().getVolume();
      
      // Warn if volume is below 70%
      if (volume < 0.7 && context.mounted) {
        final loc = AppLocalizations.of(context)!;
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.volume_down, color: Colors.orange, size: 28),
                const SizedBox(width: 8),
                Text(loc.lowVolume),
              ],
            ),
            content: Text(
              loc.lowVolumeMessage((volume * 100).round()),
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.okIllAdjustIt),
              ),
            ],
          ),
        );
        warningShown = true;
      }

      // Check DND status
      final dndActive = await DndChecker.isDndActive();
      if (dndActive && context.mounted) {
        final loc = AppLocalizations.of(context)!;
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.do_not_disturb, color: Colors.red, size: 28),
                const SizedBox(width: 8),
                Expanded(child: Text(loc.dndEnabled)),
              ],
            ),
            content: Text(
              loc.dndEnabledMessage,
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.gotIt),
              ),
            ],
          ),
        );
        warningShown = true;
      }

      return warningShown;
    } catch (e) {
      // Silently fail if checks are not available
      debugPrint('Volume/DND check failed: $e');
      return false;
    }
  }
}
