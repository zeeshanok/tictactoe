import 'dart:async';

typedef DebouncedAction<T> = void Function(T input);

/// Used to prevent an action from happening more than once in a given duration.
/// Eg. checking the availability of a username while the user is typing
/// in the username text field.
DebouncedAction<T> getDeboucer<T>(
    Duration duration, DebouncedAction<T> action) {
  Timer? timer;
  return (input) {
    timer?.cancel();
    timer = Timer(duration, () => action(input));
  };
}
