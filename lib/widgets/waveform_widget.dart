import 'package:flutter/material.dart';
import '../utils/theme.dart';

class WaveformWidget extends StatelessWidget {
  const WaveformWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.transparent,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(20, (index) => _WaveBar(index: index)),
        ),
      ),
    );
  }
}

class _WaveBar extends StatefulWidget {
  final int index;
  const _WaveBar({required this.index});

  @override
  State<_WaveBar> createState() => _WaveBarState();
}

class _WaveBarState extends State<_WaveBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + (widget.index * 50 % 400)),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 16 + (_controller.value * 50),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.accent,
                AppTheme.accentLight,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }
}
