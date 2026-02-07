import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';


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

  StreamSubscription<AccelerometerEvent>? _sub;

  DateTime _lastShake = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastTilt = DateTime.fromMillisecondsSinceEpoch(0);
  int _lastTiltDir = 0; // -1 left, +1 right, 0 none

  void start() {
    _sub?.cancel();
    _sub = accelerometerEvents.listen(_onAccelerometer);
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  void _onAccelerometer(AccelerometerEvent e) {
    final now = DateTime.now();

    // --- Shake ---
    // Convert to g-force.
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
