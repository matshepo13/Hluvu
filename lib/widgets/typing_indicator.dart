import 'package:flutter/material.dart';
import 'chat_item.dart';

class TypingIndicator extends ChatItem {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return _TypingIndicatorContent();
  }
}

class _TypingIndicatorContent extends StatefulWidget {
  const _TypingIndicatorContent({Key? key}) : super(key: key);

  @override
  State<_TypingIndicatorContent> createState() => _TypingIndicatorContentState();
}

class _TypingIndicatorContentState extends State<_TypingIndicatorContent> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(3, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 400),
        vsync: this,
      );
    });

    _animations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    for (var i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        _animationControllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromARGB(255, 159, 109, 168),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Evibot is processing',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          ...List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedBuilder(
                animation: _animations[index],
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -4 * _animations[index].value),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 159, 109, 168),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}