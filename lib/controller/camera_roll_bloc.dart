import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/camera_item.dart';
import '../model/camera_roll_state.dart';

/// Provides add and remove operations for a list of [CameraItem] instances.
class CameraRollBloc extends Bloc<CameraRollEvent, CameraRollState> {
  CameraRollBloc({
    required int maxItems,
    List<CameraItem>? initialItems,
  }) : super(
          CameraRollState(
            maxItems: maxItems,
            items: initialItems ?? [],

            /// Select the last item in the list, if there are any items.
            selectedIndex: initialItems == null || initialItems.isEmpty
                ? null
                : initialItems.length - 1,
          ),
        ) {
    on<AddItemEvent>(_addItem);
    on<SetSelectedItemEvent>(_setSelectedItem);
    on<DeleteSelectedItemEvent>(_deleteSelectedItem);
  }

  CameraItem itemAt(int index) {
    return state.items[index];
  }

  CameraItem? get selectedItem {
    if (state.selectedIndex == null) return null;
    return state.items[state.selectedIndex!];
  }

  /// See [AddItemEvent].
  void _addItem(AddItemEvent event, Emitter<CameraRollState> emit) {
    if (state.isFull) {
      addError(Exception("The camera roll is full."), StackTrace.current);
    }

    emit(
      state.copyWith(
        items: [...state.items, event.item],

        /// The selected index is set to the index of the newly added item.
        ///
        /// The newly added item is always inserted at [state.items.length],
        /// because [state.items.length] is accessed before the new item is
        /// added to the list.
        selectedIndex: () => state.items.length,
      ),
    );

    log(
      "Added item '${event.item.name}' to camera roll.",
      name: "$CameraRollBloc._add",
    );

    event.onItemAdded?.call(event.item);
  }

  void _setSelectedItem(
    SetSelectedItemEvent event,
    Emitter<CameraRollState> emit,
  ) {
    if (state.selectedIndex == event.index) {
      return;
    }

    emit(state.copyWith(selectedIndex: () => event.index));
  }

  void _deleteSelectedItem(
    DeleteSelectedItemEvent event,
    Emitter<CameraRollState> emit,
  ) {
    final deletionIndex = state.selectedIndex;

    if (deletionIndex == null || deletionIndex > state.items.length - 1) {
      return;
    }

    final newItems = [...state.items];
    final removedItem = newItems.removeAt(deletionIndex);
    int? newSelectedIndex;

    if (newItems.isEmpty) {
      newSelectedIndex = null;
    } else {
      newSelectedIndex = math.min(newItems.length - 1, deletionIndex);
    }

    emit(
      CameraRollDeletedItemState(
        maxItems: state.maxItems,
        items: newItems,
        selectedIndex: newSelectedIndex,
        deletedItem: removedItem,
      ),
    );

    log(
      "Removed item '${removedItem.name}' from camera roll.",
      name: "$CameraRollBloc._deleteSelectedItem",
    );
  }
}

abstract class CameraRollEvent {
  const CameraRollEvent();
}

/// Adds the [CameraItem] to the list of items.
class AddItemEvent extends CameraRollEvent {
  const AddItemEvent({
    required this.item,
    this.onItemAdded,
  });

  final CameraItem item;
  final void Function(CameraItem item)? onItemAdded;
}

/// Deletes the currently selected item.
///
/// The currently selected item is stored in [CameraRoll.selectedItemIndex].
class DeleteSelectedItemEvent extends CameraRollEvent {
  const DeleteSelectedItemEvent();
}

class SetSelectedItemEvent extends CameraRollEvent {
  const SetSelectedItemEvent({required this.index});

  final int? index;
}
