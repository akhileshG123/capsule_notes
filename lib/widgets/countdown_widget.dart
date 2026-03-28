import 'package:flutter/material.dart';
import 'dart:async';

class CountdownWidget extends StatefulWidget {
  final DateTime unlockAt;
  const CountdownWidget({super.key, required this.unlockAt});

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    if (widget.unlockAt.isAfter(now)) {
      setState(() {
        _timeLeft = widget.unlockAt.difference(now);
      });
    } else {
      if (mounted) setState(() => _timeLeft = Duration.zero);
      _timer.cancel();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeLeft == Duration.zero) return const Text('Unlocked!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold));
    return Text(
      '${_timeLeft.inDays}d ${_timeLeft.inHours % 24}h ${_timeLeft.inMinutes % 60}m',
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }
}
