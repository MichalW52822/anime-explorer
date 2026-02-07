import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';

/// Serwis odpowiedzialny za obsługę interakcji opartych na ruchu urządzenia.
/// Wykorzystuje dane z akcelerometru do wykrywania gestów potrząśnięcia oraz przechylenia.
/// Progi czułości oraz czasy blokady (cooldown) zostały dobrane eksperymentalnie,
/// aby ograniczyć przypadkowe wywołania akcji.
class MotionService {
  MotionService({
    this.onShake,
    this.onTiltLeft,
    this.onTiltRight,
    this.shakeGForceThreshold = 2.7,
    this.tiltThreshold = 4.0,
    this.shakeCooldown = const Duration(milliseconds: 900),
    this.tiltCooldown = const Duration(milliseconds: 600),
  });

  final void Function()? onShake;
  final void Function()? onTiltLeft;
  final void Function()? onTiltRight;

  final double shakeGForceThreshold;

  final double tiltThreshold;

  final Duration shakeCooldown;
  final Duration tiltCooldown;
  /// Subskrypcja strumienia danych z akcelerometru.
  /// Aktywna tylko wtedy, gdy sterowanie ruchem jest włączone.
  StreamSubscription<AccelerometerEvent>? _sub;

  DateTime _lastShake = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastTilt = DateTime.fromMillisecondsSinceEpoch(0);
  int _lastTiltDir = 0; // -1 left, +1 right, 0 none
  /// Rozpoczyna nasłuchiwanie zdarzeń z akcelerometru.
  /// W przypadku istnienia wcześniejszej subskrypcji zostaje ona anulowana.
  void start() {
    _sub?.cancel();
    _sub = accelerometerEvents.listen(_onAccelerometer);
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }
  /// Obsługuje pojedynczą próbkę danych z akcelerometru.
  /// Wykrywa potrząśnięcie (wysoka wartość g-force) oraz przechylenie urządzenia.
  /// Detekcja potrząśnięcia ma priorytet nad przechyleniem w tej samej próbce.
  void _onAccelerometer(AccelerometerEvent e) {
    final now = DateTime.now();

    // --- Shake ---
    // Przeliczenie surowych wartości przyspieszenia na g-force.
    // Umożliwia niezależną od orientacji urządzenia detekcję potrząśnięcia.
    final gX = e.x / 9.81;
    final gY = e.y / 9.81;
    final gZ = e.z / 9.81;
    final gForce = math.sqrt(gX * gX + gY * gY + gZ * gZ);
    if (gForce > shakeGForceThreshold && now.difference(_lastShake) > shakeCooldown) {
      _lastShake = now;
      onShake?.call();
      return; // prefer shake over tilt in the same sample
    }

    // --- Tilt ---
    if (now.difference(_lastTilt) < tiltCooldown) return;

    int dir = 0;
    if (e.x >= tiltThreshold) dir = 1;
    if (e.x <= -tiltThreshold) dir = -1;

    // Fire only on a direction change (prevents spamming when held tilted).
    if (dir != 0 && dir != _lastTiltDir) {
      _lastTilt = now;
      _lastTiltDir = dir;
      if (dir == 1) {
        onTiltRight?.call();
      } else {
        onTiltLeft?.call();
      }
    }
    if (dir == 0) {
      // Reset when user goes back to neutral.
      _lastTiltDir = 0;
    }
  }
}
