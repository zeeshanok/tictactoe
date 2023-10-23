import 'dart:async';

typedef DebouncedAction<T> = void Function(T input);
DebouncedAction<T> getDeboucer<T>(
    Duration duration, DebouncedAction<T> action) {
  Timer? timer;
  return (input) {
    timer?.cancel();
    timer = Timer(duration, () => action(input));
  };
}
