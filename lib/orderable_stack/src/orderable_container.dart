import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'orderable.dart';
import 'orderable_stack.dart';

/// internal stack
class OrderableContainer<T> extends StatefulWidget {
  final List<OrderableWidget<T>> uiItems;

  final Size itemSize;
  final Direction direction;
  final double margin;

  const OrderableContainer({
    required this.uiItems,
    required this.itemSize,
    this.margin = kMargin,
    this.direction = Direction.horizontal,
  }) : super(key: const Key('OrderableContainer'));

  @override
  State<StatefulWidget> createState() => OrderableContainerState();
}

class OrderableContainerState extends State<OrderableContainer> {
  @override
  Widget build(BuildContext context) => ConstrainedBox(
      constraints: BoxConstraints.loose(stackSize),
      child: Stack(
        children: widget.uiItems,
      ));

  Size get stackSize => widget.direction == Direction.horizontal
      ? Size((widget.itemSize.width + widget.margin) * widget.uiItems.length,
          widget.itemSize.height)
      : Size(widget.itemSize.width,
          (widget.itemSize.height + widget.margin) * widget.uiItems.length);
}

/// Content Widget wrapper : add animation and gestureDetection to itemBuilder
/// widgets
class OrderableWidget<T> extends StatefulWidget {
  final Orderable<T> data;
  Size itemSize;
  double maxPos;
  final double margin;
  Direction direction;
  VoidCallback onMove;
  VoidCallback onDrop;
  double step;
  final WidgetFactory<T> itemBuilder;

  OrderableWidget({
    Key? key,
    required this.data,
    required this.itemBuilder,
    required this.maxPos,
    required this.itemSize,
    required this.onMove,
    required this.onDrop,
    bool isDragged = false,
    this.direction = Direction.horizontal,
    this.step = 0.0,
    required this.margin,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => OrderableWidgetState(data: data);

  @override
  String toString({DiagnosticLevel minLevel: DiagnosticLevel.debug}) =>
      'DraggableText{data: $data, position: ${data.currentPosition}}';
}

class OrderableWidgetState<T> extends State<OrderableWidget<T>>
    with SingleTickerProviderStateMixin {
  /// item
  Orderable<T> data;

  bool get isHorizontal => widget.direction == Direction.horizontal;

  OrderableWidgetState({required this.data});

  final _forcus = FocusNode();

  @override
  Widget build(BuildContext context) => AnimatedPositioned(
        duration: Duration(milliseconds: data.selected ? 1 : 200),
        left: data.x,
        top: data.y,
        child: buildGestureDetector(horizontal: isHorizontal),
      );

  /// build horizontal or verticak drag gesture detector
  Widget buildGestureDetector({required bool horizontal}) {
    if (horizontal) {
      return GestureDetector(
        onHorizontalDragStart: startDrag,
        onHorizontalDragEnd: endDrag,
        onHorizontalDragUpdate: (event) {
          setState(() {
            if (moreThanMin(event.primaryDelta!) &&
                lessThanMax(event.primaryDelta!)) {
              data.currentPosition =
                  Offset(data.x + event.primaryDelta!, data.y);
            }
            widget.onMove();
          });
        },
        child: widget.itemBuilder(data: data, itemSize: widget.itemSize),
      );
    } else {
      var gestureDetector = GestureDetector(
        onVerticalDragStart: startDrag,
        onVerticalDragEnd: endDrag,
        onTap: _onTap,
        onVerticalDragUpdate: (event) {
          setState(() {
            if (moreThanMin(event.primaryDelta!) &&
                lessThanMax(event.primaryDelta!)) {
              print(event.primaryDelta!);
              data.currentPosition =
                  Offset(data.x, data.y + event.primaryDelta!);
            }
            widget.onMove();
          });
        },
        child: widget.itemBuilder(data: data, itemSize: widget.itemSize),
      );
      if (data.selected) {
        return RawKeyboardListener(
          focusNode: _forcus,
          autofocus: true,
          onKey: _onKey,
          child: gestureDetector,
        );
      } else {
        return gestureDetector;
      }
    }
  }

  void startDrag(DragStartDetails event) {
    setState(() {
      data.selected = true;
    });
  }

  void endDrag(DragEndDetails event) {
    setState(() {
      data.selected = false;
      widget.onDrop();
    });
  }

  bool moreThanMin(double primaryDelta) {
    if (isHorizontal) {
      return data.x + primaryDelta > 0;
    } else {
      return data.y + primaryDelta > 0;
    }
  }

  bool lessThanMax(double primaryDelta) {
    if (isHorizontal) {
      return data.x + primaryDelta + widget.itemSize.width < widget.maxPos;
    } else {
      return data.y + primaryDelta + widget.itemSize.height < widget.maxPos;
    }
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) =>
      'OrderableWidgetState{data: $data}';

  void _onKey(RawKeyEvent event) async {
    if (data.selected) {
      final value = widget.itemSize.height + widget.margin;
      if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
        // handle key down
        setState(() {
          if (moreThanMin(value) && lessThanMax(value)) {
            data.currentPosition = Offset(data.x, data.y + value);
          }
          widget.onMove();
        });
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onDrop();
      } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
        // handle key up
        setState(() {
          if (moreThanMin(-value) && lessThanMax(-value)) {
            data.currentPosition = Offset(data.x, data.y - value);
          }
          widget.onMove();
        });
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onDrop();
      }
    }
  }

  void _onTap() {
    if (data.selected) {
      setState(() {
        data.selected = false;
        widget.onDrop();
      });
    } else {
      setState(() {
        data.selected = true;
      });
    }
  }
}
