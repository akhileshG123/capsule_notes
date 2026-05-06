import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../utils/theme.dart';

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
    if (_timeLeft == Duration.zero) {
      return Text(
        'Unlocked!',
        style: GoogleFonts.outfit(
          color: AppTheme.accent,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      );
    }
    return Text(
      '${_timeLeft.inDays}d ${_timeLeft.inHours % 24}h ${_timeLeft.inMinutes % 60}m',
      style: GoogleFonts.outfit(
        color: const Color(0xFF7B5DAF),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }
}
