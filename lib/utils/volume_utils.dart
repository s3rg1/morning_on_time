import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';
import '../l10n/app_localizations.dart';

/// Utility class for volume-related operations
class VolumeUtils {
  /// Check device volume and show warning dialog if below 30%
  /// 
  /// [context] - BuildContext for showing dialog and accessing localizations
  /// [checkSetupComplete] - Optional callback to verify if setup is complete before checking
  /// 
  /// Returns true if volume check was performed, false if skipped
  static Future<bool> checkVolumeAndWarn(
    BuildContext context, {
    bool Function()? checkSetupComplete,
  }) async {
    try {
      // If setup check is provided and returns false, skip volume check
      if (checkSetupComplete != null && !checkSetupComplete()) {
        return false;
      }

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
        return true;
      }
      return false;
    } catch (e) {
      // Silently fail if volume check is not available
      debugPrint('Volume check failed: $e');
      return false;
    }
  }
}
