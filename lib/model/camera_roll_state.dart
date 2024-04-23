import 'package:equatable/equatable.dart';
import 'package:oag_camera/model/model.dart';

class CameraRollState extends Equatable {
  const CameraRollState({
    required this.maxItems,
    required this.items,
    this.selectedIndex,
  })  : assert(maxItems >= 1),
        assert(items.length <= maxItems),
        assert(selectedIndex == null ||
            (selectedIndex >= 0 && selectedIndex < items.length));

  final int maxItems;
  final List<CameraItem> items;
  final int? selectedIndex;

  int get length => items.length;
  bool get isEmpty => items.isEmpty;
  bool get isFull => items.length >= maxItems;

  CameraRollState copyWith({
    int? maxItems,
    List<CameraItem>? items,
    int? Function()? selectedIndex,
  }) {
    return CameraRollState(
      maxItems: maxItems ?? this.maxItems,
      items: items ?? this.items,
      selectedIndex:
          selectedIndex != null ? selectedIndex() : this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [maxItems, items, selectedIndex];
}

/// A state to represent an open camera roll with a deleted item.
class CameraRollDeletedItemState extends CameraRollState {
  const CameraRollDeletedItemState({
    required int maxItems,
    required List<CameraItem> items,
    required int? selectedIndex,
    required this.deletedItem,
  }) : super(
          maxItems: maxItems,
          items: items,
          selectedIndex: selectedIndex,
        );

  final CameraItem deletedItem;

  @override
  List<Object?> get props => super.props..add(deletedItem);
}
