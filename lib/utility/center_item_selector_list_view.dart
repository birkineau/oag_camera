import 'package:flutter/widgets.dart';

final _pageStorageBucket = PageStorageBucket();

class CenterItemSelectorScrollConfiguration {
  static const defaultConfiguration = CenterItemSelectorScrollConfiguration();

  const CenterItemSelectorScrollConfiguration({
    this.minPages = .0,
    this.maxPages = 4.0,
    this.velocityDivisor = 500,
  });

  final double minPages;
  final double maxPages;
  final int velocityDivisor;
}

class CenterItemSelector<T> extends StatefulWidget {
  const CenterItemSelector({
    super.key,
    this.controller,
    this.scrollConfiguration,
    this.scrollDirection = Axis.horizontal,
    this.extent,
    required this.itemSize,
    this.reverse = false,
    this.onItemSelected,
    this.initialIndex,
    required this.items,
    required this.itemBuilder,
  });

  final ScrollController? controller;
  final CenterItemSelectorScrollConfiguration? scrollConfiguration;
  final Axis scrollDirection;
  final double? extent;
  final double itemSize;
  final bool reverse;
  final void Function(int index)? onItemSelected;
  final int? initialIndex;
  final List<T> items;

  final Widget Function(
    BuildContext context,
    int index,
    bool isSelected,
  ) itemBuilder;

  @override
  State<CenterItemSelector> createState() => CenterItemSelectorState();
}

class CenterItemSelectorState<T> extends State<CenterItemSelector<T>> {
  late final ScrollController _scrollController;

  late int _centerIndex;
  int get index => _centerIndex;

  late double _extent;
  late double _halfExtent;
  late double _padding;
  late double _delta;

  bool _ignoreScrollNotification = false;

  @override
  void initState() {
    super.initState();

    _scrollController = widget.controller ?? ScrollController();
    _centerIndex = widget.initialIndex ?? widget.items.length - 1;
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => _scrollController.jumpTo(_indexToOffset(_centerIndex)),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _extent = widget.extent ??
        (widget.scrollDirection == Axis.horizontal
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.height);

    _halfExtent = _extent / 2.0;
    _padding = (_extent - widget.itemSize) / 2.0;
    _delta = _halfExtent - _padding - widget.itemSize;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: _pageStorageBucket,
      child: ListView.builder(
        key: PageStorageKey("center_item_selector_${widget.items.hashCode}"),
        controller: _scrollController,
        scrollDirection: widget.scrollDirection,
        physics: _SnapScrollPhysics(
          snapSize: widget.itemSize,
          configuration: widget.scrollConfiguration ??
              CenterItemSelectorScrollConfiguration.defaultConfiguration,
        ),
        padding: widget.scrollDirection == Axis.horizontal
            ? EdgeInsets.symmetric(horizontal: _padding)
            : EdgeInsets.symmetric(vertical: _padding),
        reverse: widget.reverse,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final isSelected = index == _centerIndex;

          return GestureDetector(
            key: ValueKey("item_$index"),
            behavior: HitTestBehavior.translucent,
            onTap: () => selectItemAt(index),
            child: SizedBox(
              width: widget.itemSize,
              height: widget.itemSize,
              child: widget.itemBuilder(context, index, isSelected),
            ),
          );
        },
      ),
    );
  }

  Future<void> selectItemAt(int index, {bool notify = true}) async {
    if (_centerIndex == index || _ignoreScrollNotification) {
      return;
    }

    setState(() => _centerIndex = index);

    if (notify) {
      widget.onItemSelected?.call(_centerIndex);
    }

    await _animateToIndex(index);
  }

  Future<void> selectPreviousItem() async {
    final previousIndex = _centerIndex - 1;

    if (previousIndex < 0) {
      return;
    }

    return selectItemAt(previousIndex);
  }

  Future<void> selectNextItem() async {
    final nextIndex = _centerIndex + 1;

    if (nextIndex >= widget.items.length) {
      return;
    }

    return selectItemAt(nextIndex);
  }

  void _onScroll() {
    if (_ignoreScrollNotification) {
      return;
    }

    final centerOffset =
        _scrollController.offset + _delta + widget.itemSize / 2.0;

    final index = (centerOffset / widget.itemSize).round();

    if (index != _centerIndex && index >= 0 && index < widget.items.length) {
      setState(
        () {
          _centerIndex = index;
          widget.onItemSelected?.call(_centerIndex);
        },
      );
    }
  }

  double _indexToOffset(int index) {
    if (index == widget.items.length - 1) {
      return _scrollController.position.maxScrollExtent;
    }

    return index * widget.itemSize;
  }

  Future<void> _animateToIndex(
    int index, {
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.decelerate,
  }) async {
    _ignoreScrollNotification = true;

    await _scrollController.animateTo(
      _indexToOffset(index),
      duration: duration,
      curve: curve,
    );

    _ignoreScrollNotification = false;
  }
}

class _SnapScrollPhysics extends ScrollPhysics {
  const _SnapScrollPhysics({
    super.parent,
    required this.snapSize,
    required this.configuration,
  });

  final double snapSize;
  final CenterItemSelectorScrollConfiguration configuration;

  @override
  _SnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SnapScrollPhysics(
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
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
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
    // Calculate the minimum and maximum pages that the view can scroll to.
    final minPage = position.minScrollExtent / snapSize;
    final maxPage = position.maxScrollExtent / snapSize;

    // Add additional pages based on the velocity, but stay within thebounds.
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
