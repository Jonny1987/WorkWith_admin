import 'package:flutter_riverpod/flutter_riverpod.dart';

class StateProperty {
  final String name;
  final AsyncValue value;

  StateProperty(this.name, this.value);
}

abstract class CustomState {
  Map<String, AsyncValue> get stateProperties;

  StateProperty? changedProperty(CustomState oldState) {
    assert(oldState.runtimeType == runtimeType);

    for (final entry in stateProperties.entries) {
      if (oldState.stateProperties[entry.key] != entry.value) {
        return StateProperty(entry.key, entry.value);
      }
    }
    return null;
  }
}
