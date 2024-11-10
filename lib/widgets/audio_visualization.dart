import 'package:flutter/material.dart';

class AudioVisualization extends StatelessWidget {
  final List<double> audioLevels;

  const AudioVisualization({
    Key? key,
    required this.audioLevels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: audioLevels.map((level) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              width: 3,
              height: 60 * level,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    primaryColor,
                    colorScheme.secondary.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}