import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/game_model.dart';

final selectedGameProvider = StateProvider<GameModel?>((ref) => null);
