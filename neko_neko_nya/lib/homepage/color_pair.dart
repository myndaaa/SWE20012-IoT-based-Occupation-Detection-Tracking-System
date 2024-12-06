import 'package:metaballs/metaballs.dart';
import 'package:flutter/material.dart';

class ColorsEffectPair {
  final List<Color> colors;
  final MetaballsEffect? effect;
  final String name;

  ColorsEffectPair({
    required this.colors,
    required this.name,
    required this.effect,
  });
}

List<ColorsEffectPair> colorsAndEffects = [
  ColorsEffectPair(
      colors: [
        const Color.fromARGB(255, 255, 60, 120),
        const Color.fromARGB(255, 237, 120, 255),
      ],
      effect: MetaballsEffect.follow(),
      name: 'FOLLOW'
  ),
  ColorsEffectPair(
      colors: [
        const Color.fromARGB(255, 118, 23, 166),
        const Color.fromARGB(255, 217, 152, 250),
      ],
      effect: MetaballsEffect.grow(),
      name: 'GROW'
  ),
  ColorsEffectPair(
      colors: [
        const Color.fromARGB(255, 90, 60, 255),
        const Color.fromARGB(255, 120, 255, 255),
      ],
      effect: MetaballsEffect.speedup(),
      name: 'SPEEDUP'
  ),
  ColorsEffectPair(
      colors: [
        const Color.fromARGB(255, 145, 105, 129),
        const Color.fromARGB(255, 242, 191, 222),
      ],
      effect: MetaballsEffect.ripple(),
      name: 'RIPPLE'
  ),
  ColorsEffectPair(
      colors: [
        const Color.fromARGB(255, 120, 217, 255),
        const Color.fromARGB(255, 255, 234, 214),
      ],
      effect: null,
      name: 'NONE'
  ),
];