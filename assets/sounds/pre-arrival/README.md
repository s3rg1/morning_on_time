# Pre-Arrival Check Sounds

These are placeholder files for the 3 Pre-Arrival Check alarm sounds (IDs 5, 7, 8).

Replace them with real audio files before production:

| File | Urgency | Description |
|------|---------|-------------|
| `pre_arrival_gentle.wav` | Low (T-60s) | Gentle reminder chime — soft, non-alarming |
| `pre_arrival_urgent.wav` | Medium (T-30s) | More urgent alert tone — attention-grabbing |
| `pre_arrival_critical.wav` | High (T-10s) | Critical alarm tone — impossible to ignore |

## Requirements

- Format: `.wav` (Android raw resources don't support all formats)
- Duration: 1-3 seconds recommended
- The same files must be placed in **both** locations:
  - `assets/sounds/pre-arrival/` (Flutter assets)
  - `android/app/src/main/res/raw/` (Android notification sounds)
- For iOS, `.caf` versions are needed in the iOS bundle
