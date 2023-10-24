import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage<void> slideLeftTransition(
        GoRouterState state, Widget child) =>
    slideOffsetTransition(
      state: state,
      child: child,
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    );

CustomTransitionPage<void> slideUpTransition(
        GoRouterState state, Widget child) =>
    slideOffsetTransition(
      state: state,
      child: child,
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    );

CustomTransitionPage<void> slideOffsetTransition({
  required GoRouterState state,
  required Widget child,
  required Offset begin,
  required Offset end,
}) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeOutCubic,
        ),
        child: SlideTransition(
          position: Tween(
            begin: begin,
            end: end,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastEaseInToSlowEaseOut,
              reverseCurve: Curves.fastEaseInToSlowEaseOut,
            ),
          ),
          child: child,
        ),
      ),
    );
