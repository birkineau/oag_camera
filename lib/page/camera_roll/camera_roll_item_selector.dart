import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/camera_roll_bloc.dart';
import '../../model/camera_roll_state.dart';
import '../../utility/center_item_selector_list_view.dart';
import 'camera_item_preview.dart';

typedef CameraRollConsumer = BlocConsumer<CameraRollBloc, CameraRollState>;

class CameraRollItemSelector extends StatefulWidget {
  static const kItemSize = 64.0;

  const CameraRollItemSelector({
    super.key,
    required this.enableListeners,
  });

  final bool enableListeners;

  @override
  State<CameraRollItemSelector> createState() => _CameraRollItemSelectorState();
}

class _CameraRollItemSelectorState extends State<CameraRollItemSelector> {
  final _selectorKey = GlobalKey<CenterItemSelectorState>();

  /// The index of the camera roll item that was just deleted.
  ///
  /// The current state has the new index of the selected item, so this value
  /// is updated through the previous state of the camera roll.
  ///
  /// * See [CameraRollConsumer.listenWhen].
  /// * See [CameraRollConsumer.listener].
  int? _previousIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: CameraRollItemSelector.kItemSize,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: const BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.enableListeners
          ? LayoutBuilder(
              builder: (context, constraints) => CameraRollConsumer(
                listenWhen: _selectedItemChanged,
                listener: _updateSelectedItem,
                buildWhen: _itemCountChanged,
                builder: (context, state) => _Selector(
                  selectorKey: _selectorKey,
                  onItemSelected: (index) => _setSelectedItem(context, index),
                  state: state,
                ),
              ),
            )
          : _Selector(state: context.read<CameraRollBloc>().state),
    );
  }

  bool _selectedItemChanged(CameraRollState previous, CameraRollState current) {
    _previousIndex = previous.selectedIndex;

    return current.selectedIndex != null &&
        (current is CameraRollDeletedItemState ||
            previous.selectedIndex != current.selectedIndex);
  }

  void _updateSelectedItem(BuildContext context, CameraRollState state) {
    final selectorState = _selectorKey.currentState;
    if (selectorState == null) return;

    if (state is CameraRollDeletedItemState) {
      selectorState
        ..removeItemAt(_previousIndex!)
        ..selectItemAt(state.selectedIndex!, notify: false);
    } else {
      selectorState.selectItemAt(state.selectedIndex!, notify: false);
    }
  }

  bool _itemCountChanged(CameraRollState previous, CameraRollState current) {
    return current.selectedIndex != null &&
        current.items.isNotEmpty &&
        previous.items.length != current.items.length;
  }

  void _setSelectedItem(BuildContext context, int index) {
    context.read<CameraRollBloc>().add(SetSelectedItemEvent(index: index));
    HapticFeedback.selectionClick();
  }
}

class _Selector extends StatelessWidget {
  const _Selector({
    this.onItemSelected,
    this.selectorKey,
    required this.state,
  });

  final GlobalKey<CenterItemSelectorState>? selectorKey;
  final void Function(int)? onItemSelected;
  final CameraRollState state;

  @override
  Widget build(BuildContext context) {
    if (state.selectedIndex == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) => CenterItemSelector(
        key: selectorKey,
        itemSize: CameraRollItemSelector.kItemSize,
        extent: constraints.maxWidth,
        initialIndex: state.selectedIndex,
        onItemSelected: onItemSelected,
        items: state.items,
        itemBuilder: (context, index, isSelected) {
          if (index >= state.items.length) return const SizedBox.shrink();

          final item = state.items[index];

          return _CameraRollItemCard(
            key: ValueKey("camera_item_${item.timeStamp}"),
            index: index,
            selected: isSelected,
            child: CameraItemPreview(
              scaleToFit: false,
              filterQuality: FilterQuality.none,
              item: item,
            ),
          );
        },
      ),
    );
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
