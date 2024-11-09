import 'package:flutter/material.dart';

class ToggleButtonGroup extends StatefulWidget {
  const ToggleButtonGroup({super.key});

  @override
  State<ToggleButtonGroup> createState() => _ToggleButtonGroupState();
}

class _ToggleButtonGroupState extends State<ToggleButtonGroup> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment<int>(value: 0, label: Text('Recent')),
        ButtonSegment<int>(value: 1, label: Text('Popular')),
        ButtonSegment<int>(value: 2, label: Text('Trending')),
      ],
      selected: {selectedIndex},
      onSelectionChanged: (Set<int> newSelection) {
        setState(() {
          selectedIndex = newSelection.first;
        });
      },
    );
  }
}