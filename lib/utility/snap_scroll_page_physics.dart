import 'package:flutter/material.dart';

class SnapScrollPhysicsConfiguration {
  static const defaultConfiguration = SnapScrollPhysicsConfiguration();

  const SnapScrollPhysicsConfiguration({
    this.minPages = .0,
    this.maxPages = 4.0,
    this.velocityDivisor = 500,
  });

  final double minPages;
  final double maxPages;
  final int velocityDivisor;
}

class SnapScrollPhysics extends ScrollPhysics {
  const SnapScrollPhysics({
    super.parent,
    required this.snapSize,
    required this.configuration,
  });

  final double snapSize;
  final SnapScrollPhysicsConfiguration configuration;

  @override
  SnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnapScrollPhysics(
      parent: buildParent(ancestor),
      snapSize: snapSize,
      configuration: configuration,
    );
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    /// If we're out of range and not headed back in range, defer to the parent
    /// ballistics, which should put us back in range at a page boundary.
    if ((velocity <= .0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= .0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final tolerance = toleranceFor(position);
    final target = _getTargetPixels(position, tolerance, velocity);

    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }

    return null;
  }

  @override
  bool get allowImplicitScrolling => false;

  double _getPage(ScrollMetrics position) {
    return position.pixels / snapSize;
  }

  double _getPixels(ScrollMetrics position, double page) {
    return page * snapSize;
  }

  double _getTargetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
  ) {
    /// Calculate the minimum and maximum pages that the view can scroll to.
    final minPage = position.minScrollExtent / snapSize;
    final maxPage = position.maxScrollExtent / snapSize;

    /// Add additional pages based on the velocity, but stay within thebounds.
    final velocityFactor = (velocity.abs() / configuration.velocityDivisor)
        .clamp(configuration.minPages, configuration.maxPages);

    var page = _getPage(position);

    if (velocity > 0) {
      page += velocityFactor;
      page = page.clamp(minPage, maxPage);
    } else if (velocity < 0) {
      page -= velocityFactor;
      page = page.clamp(minPage, maxPage);
    }

    return _getPixels(position, page.roundToDouble());
  }
}
