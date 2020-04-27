library flutter_stage_objects;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_stage/flutter_stage.dart';
export 'package:flutter_stage/flutter_stage.dart';

/// A [ShapeBuilder]
abstract class ShapeBuilder {
  Vector3 get position => Vector3(0, 0, 0);
  Vector3 get rotation => Vector3(0, 0, 0);
  Vector3 get scale => Vector3(1, 1, 1);

  /// Gets the [actor]'s children
  List<Actor> get children => [];

  /// Gets the [actor] for the shape
  Actor get actor => Actor(
        position: position,
        rotation: rotation,
        scale: scale,
        children: children,
      );
}

/// A [Shape]
abstract class Shape extends ShapeBuilder {
  /// The shape's [position]
  Vector3 position;

  /// The shape's [rotation]
  Vector3 rotation;

  /// The shape's [scale]
  Vector3 scale;

  /// Constructs a [Shape]
  Shape(this.position, this.rotation, this.scale) {
    position ??= Vector3(0, 0, 0);
    rotation ??= Vector3(0, 0, 0);
    scale ??= Vector3(1, 1, 1);
  }
}

/// A [Prism]
abstract class Prism extends Shape {
  /// The [Prism]'s width
  double width;

  /// The [Prism]'s height
  double height;

  /// The [Prism]'s depth
  double depth;

  /// Constructs a [Prism]
  Prism(Vector3 position, Vector3 rotation, Vector3 scale, this.width,
      this.height, this.depth)
      : super(position, rotation, scale);
}

enum Side { Top, Left, Right, Bottom, Front, Back }
enum ShapeEnum { RectangularPrism, TriangularPrism }

extension SideNames on Side {
  String get string {
    return EnumToString.parse(this);
  }
}

extension RectangularPrismSides on Side {
  Vector3 position(double width, double height, double depth) {
    switch (this) {
      case Side.Top:
        return Vector3(0, -height / 2, 0);
      case Side.Bottom:
        return Vector3(0, height / 2, 0);
      case Side.Left:
        return Vector3(-width / 2, 0, 0);
      case Side.Right:
        return Vector3(width / 2, 0, 0);
      case Side.Front:
        return Vector3(0, 0, depth / 2);
      case Side.Back:
        return Vector3(0, 0, -depth / 2);
      default:
        return Vector3(0, 0, height);
    }
  }

  Vector3 get rotation {
    switch (this) {
      case Side.Top:
        return Vector3(90, 0, 0);
      case Side.Bottom:
        return Vector3(270, 0, 0);
      case Side.Left:
        return Vector3(0, 270, 0);
      case Side.Right:
        return Vector3(0, 90, 0);
      case Side.Front:
        return Vector3(0, 0, 0);
      case Side.Back:
        return Vector3(180, 0, 180);
      default:
        return Vector3(0, 0, 0);
    }
  }

  double width(double width, double height, double depth) {
    switch (this) {
      case Side.Top:
        return width;
      case Side.Bottom:
        return width;
      case Side.Left:
        return depth;
      case Side.Right:
        return depth;
      case Side.Front:
        return width;
      case Side.Back:
        return width;
      default:
        return width;
    }
  }

  double height(double width, double height, double depth) {
    switch (this) {
      case Side.Top:
        return depth;
      case Side.Bottom:
        return depth;
      case Side.Left:
        return height;
      case Side.Right:
        return height;
      case Side.Front:
        return height;
      case Side.Back:
        return height;
      default:
        return height;
    }
  }
}

extension TriangularPrismSides on Side {
  Vector3 position(double width, double height, double depth) {
    switch (this) {
      case Side.Top:
        return Vector3(0, 0, 0);
      case Side.Bottom:
        return Vector3(0, 0, 0);
      case Side.Left:
        return Vector3(-width / 2, 0, 0);
      case Side.Right:
        return Vector3(width / 2, 0, 0);
      case Side.Front:
        return Vector3(0, -sqrt(3) * height / 4, height / 4);
      case Side.Back:
        return Vector3(0, -sqrt(3) * height / 4, -height / 4);
      default:
        return Vector3(0, 0, height);
    }
  }

  Vector3 get rotation {
    switch (this) {
      case Side.Top:
        return Vector3(90, 0, 0);
      case Side.Bottom:
        return Vector3(270, 0, 0);
      case Side.Left:
        return Vector3(0, 270, 0);
      case Side.Right:
        return Vector3(0, 90, 0);
      case Side.Front:
        return Vector3(30, 0, 0);
      case Side.Back:
        return Vector3(150, 0, 180);
      default:
        return Vector3(0, 0, 0);
    }
  }

  double width(double width, double height, double depth) {
    return width;
  }

  double height(double width, double height, double depth) {
    return height;
  }
}

/// Creates a RectangularPrism
class Cube extends Prism {
  /// All of the sides of the widget
  Map<Side, Widget> sides;

  /// Widgets are [centered] on their side
  bool centered;

  /// Autofill the side with a container with [color]
  bool autofill;

  /// All sides default to this [color]
  Color color;

  /// Creates a RectangularPrism
  Cube({
    Vector3 position,
    Vector3 rotation,
    Vector3 scale,
    @required double width,
    @required double height,
    @required double depth,
    this.sides,
    this.color,
    this.centered,
    this.autofill,
  }) : super(position, rotation, scale, width, height, depth) {
    centered ??= false;
    color ??= Colors.white;
    autofill ??= true;
    assert(this.sides != null);
  }
  Actor _createActor(Side s) {
    return Actor(
      name: s.string,
      position: RectangularPrismSides(s).position(width, height, depth),
      rotation: RectangularPrismSides(s).rotation,
      scale: Vector3(1, 1, 1),
      width: RectangularPrismSides(s).width(width, height, depth),
      height: RectangularPrismSides(s).height(width, height, depth),
      widget: Container(
            color: color,
            child: centered ? Center(child: sides[s]) : sides[s],
          ) ??
          Container(color: color),
    );
  }

  @override
  List<Actor> get children {
    if (!autofill) {
      return sides.keys.map((s) => _createActor(s)).toList();
    }
    return Side.values.map((s) => _createActor(s)).toList();
  }
}

/// A [TriangularPrism]
class TriangularPrism extends Prism {
  /// All of the sides of the widget
  Map<Side, Widget> sides;

  /// Widgets are [centered] on their side
  bool centered;

  /// Autofill the side with a container with [color]
  bool autofill;

  /// All sides default to this [color]
  Color color;

  /// Creates a [TriangularPrism]
  TriangularPrism({
    Vector3 position,
    Vector3 rotation,
    Vector3 scale,
    @required double width,
    @required double height,
    this.sides,
    this.color,
    this.centered,
    this.autofill,
  }) : super(position, rotation, scale, width, height, null) {
    centered ??= false;
    autofill ??= true;
    color ??= Colors.white;
    assert(this.sides != null);
  }

  Actor _createActor(Side s) {
    return Actor(
      name: s.string,
      position: TriangularPrismSides(s).position(width, height, depth),
      rotation: TriangularPrismSides(s).rotation,
      scale: Vector3(1, 1, 1),
      width: TriangularPrismSides(s).width(width, height, depth),
      height: TriangularPrismSides(s).height(width, height, depth),
      widget: Container(
            color: color,
            child: centered ? Center(child: sides[s]) : sides[s],
          ) ??
          Container(color: color),
    );
  }

  @override
  List<Actor> get children {
    if (!autofill) {
      return sides.keys
          .where((s) => s != Side.Top && s != Side.Left && s != Side.Right)
          .map((s) => _createActor(s))
          .toList();
    }
    return Side.values
        .where((s) => s != Side.Top && s != Side.Left && s != Side.Right)
        .map((s) => _createActor(s))
        .toList();
  }
}
