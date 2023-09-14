import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'snap_scroll_page_physics.dart';

final _pageStorageBucket = PageStorageBucket();

class CenterItemSelector<T> extends StatefulWidget {
  const CenterItemSelector({
    super.key,
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

  final SnapScrollPhysicsConfiguration? scrollConfiguration;
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
  final _listKey = GlobalKey<AnimatedListState>();

  late ScrollController _scrollController;

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

    _scrollController = ScrollController()..addListener(_onScroll);
    _centerIndex = widget.initialIndex ?? widget.items.length - 1;

    SchedulerBinding.instance.addPostFrameCallback(
      (_) => _scrollController.jumpTo(_indexToOffset(_centerIndex)),
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

    SchedulerBinding.instance.addPostFrameCallback(
      (_) => _scrollController.jumpTo(_indexToOffset(_centerIndex)),
    );
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
      child: KeyedSubtree(
        key: PageStorageKey("center_item_selector_${widget.items.hashCode}"),
        child: AnimatedList(
          key: _listKey,
          controller: _scrollController,
          scrollDirection: widget.scrollDirection,
          physics: SnapScrollPhysics(
            snapSize: widget.itemSize,
            configuration: widget.scrollConfiguration ??
                SnapScrollPhysicsConfiguration.defaultConfiguration,
          ),
          padding: widget.scrollDirection == Axis.horizontal
              ? EdgeInsets.symmetric(horizontal: _padding)
              : EdgeInsets.symmetric(vertical: _padding),
          reverse: widget.reverse,
          initialItemCount: widget.items.length,
          itemBuilder: (context, index, animation) => GestureDetector(
            key: ValueKey("item_$index"),
            behavior: HitTestBehavior.translucent,
            onTap: () => selectItemAt(index),
            child: SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: animation, // animation
                curve: Curves.fastEaseInToSlowEaseOut,
              ),
              axis: Axis.horizontal,
              child: SizedBox(
                width: widget.itemSize,
                height: widget.itemSize,
                child: widget.itemBuilder(
                  context,
                  index,
                  index == _centerIndex,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void remove(int index) {
    final listState = _listKey.currentState;
    if (listState == null) return;

    final child = widget.itemBuilder(context, index, false);
    const curve = Curves.linear;

    listState.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: CurvedAnimation(
          parent: animation,
          curve: curve,
          reverseCurve: curve.flipped,
        ),
        axis: Axis.horizontal,
        child: child,
      ),
      duration: const Duration(milliseconds: 300),
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
    if (_ignoreScrollNotification) return;

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

/// BACKUP
/*
import 'dart:developer';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'snap_scroll_page_physics.dart';

final _pageStorageBucket = PageStorageBucket();

class CenterItemSelector<T> extends StatefulWidget {
  const CenterItemSelector({
    super.key,
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

  final SnapScrollPhysicsConfiguration? scrollConfiguration;
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
  late ScrollController _scrollController;

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

    _scrollController = ScrollController();
    _centerIndex = widget.initialIndex ?? widget.items.length - 1;
    _scrollController.addListener(_onScroll);

    SchedulerBinding.instance.addPostFrameCallback(
      (_) => _scrollController.jumpTo(_indexToOffset(_centerIndex)),
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
  void didUpdateWidget(CenterItemSelector<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    _scrollController.dispose();
    _scrollController = ScrollController(
      initialScrollOffset: _indexToOffset(_centerIndex),
    )..addListener(_onScroll);
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
        physics: SnapScrollPhysics(
          snapSize: widget.itemSize,
          configuration: widget.scrollConfiguration ??
              SnapScrollPhysicsConfiguration.defaultConfiguration,
        ),
        padding: widget.scrollDirection == Axis.horizontal
            ? EdgeInsets.symmetric(horizontal: _padding)
            : EdgeInsets.symmetric(vertical: _padding),
        reverse: widget.reverse,
        itemCount: widget.items.length,
        itemBuilder: (context, index) => GestureDetector(
          key: ValueKey("item_$index"),
          behavior: HitTestBehavior.translucent,
          onTap: () => selectItemAt(index),
          child: SizedBox(
            width: widget.itemSize,
            height: widget.itemSize,
            child: widget.itemBuilder(context, index, index == _centerIndex),
          ),
        ),
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
    if (_ignoreScrollNotification) return;

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

    log("current offset: ${_scrollController.offset}");
    log("   next offset: ${_indexToOffset(index)}");

    await _scrollController.animateTo(
      _indexToOffset(index),
      duration: duration,
      curve: curve,
    );

    _ignoreScrollNotification = false;
  }
}
*/
