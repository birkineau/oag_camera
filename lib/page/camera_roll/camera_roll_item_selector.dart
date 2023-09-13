import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_roll_bloc.dart';
import '../../model/camera_item.dart';
import '../../model/camera_roll_state.dart';
import '../../utility/center_item_selector_list_view.dart';
import 'camera_item_preview.dart';

class CameraRollItemSelector extends StatefulWidget {
  static const kItemSize = 64.0;

  const CameraRollItemSelector({super.key});

  @override
  State<CameraRollItemSelector> createState() => _CameraRollItemSelectorState();
}

class _CameraRollItemSelectorState extends State<CameraRollItemSelector> {
  final _selectorKey = GlobalKey<CenterItemSelectorState>();
  int? _previousIndex;

  @override
  Widget build(BuildContext context) {
    final itemSelector = BlocConsumer<CameraRollBloc, CameraRollState>(
      listenWhen: (previous, current) {
        log("previous: ${previous.selectedIndex}");
        log(" current: ${current.selectedIndex}");
        return current is CameraRollDeletedItemState &&
            (_previousIndex = previous.selectedIndex) != current.selectedIndex;
      },
      listener: (context, state) {
        final index = state.selectedIndex;
        if (index == null) return;

        final selectorState = _selectorKey.currentState;
        if (selectorState == null) return;

        if (_previousIndex != null) selectorState.remove(_previousIndex!);

        // selectorState.selectItemAt(index, notify: false);
      },
      buildWhen: (previous, current) => _itemCountChanged(previous, current),
      builder: (context, state) => LayoutBuilder(
        builder: (context, constraints) => CenterItemSelector(
          key: _selectorKey,
          itemSize: CameraRollItemSelector.kItemSize,
          extent: constraints.maxWidth,
          onItemSelected: (index) => _setSelectedItem(context, index),
          initialIndex: state.selectedIndex,
          items: state.items,
          itemBuilder: (context, index, isSelected) {
            final item = state.items[index];

            return _CameraRollItemCard(
              key: ValueKey("camera_item_${item.timeStamp}"),
              index: index,
              selected: isSelected,
              child: SizedBox(
                width: CameraRollItemSelector.kItemSize,
                height: CameraRollItemSelector.kItemSize,
                child: CameraItemPreview(
                  scaleToFit: false,
                  filterQuality: FilterQuality.none,
                  item: item,
                ),
              ),
            );
          },
        ),
      ),
    );

    return Container(
      height: CameraRollItemSelector.kItemSize,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: const BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: itemSelector,
    );
  }

  bool _itemCountChanged(CameraRollState previous, CameraRollState current) {
    return current.items.isNotEmpty &&
        previous.items.length != current.items.length;
  }

  void _setSelectedItem(BuildContext context, int index) {
    context.read<CameraRollBloc>().add(SetSelectedItemEvent(index: index));
    HapticFeedback.selectionClick();
  }
}

class _CameraRollItemCard extends StatefulWidget {
  const _CameraRollItemCard({
    super.key,
    required this.index,
    required this.selected,
    required this.child,
  });

  final int index;
  final bool selected;
  final Widget child;

  @override
  State<_CameraRollItemCard> createState() => _CameraRollItemCardState();
}

class _CameraRollItemCardState extends State<_CameraRollItemCard>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: widget.selected ? const EdgeInsets.all(1.5) : null,
      decoration: BoxDecoration(
        color: widget.selected ? Colors.amber : Colors.transparent,
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.child,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
