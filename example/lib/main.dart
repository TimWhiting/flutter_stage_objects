import 'package:flutter/material.dart';
import 'package:flutter_stage_objects/flutter_stage_objects.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:dartx/dartx.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage('Flutter Stage Objects'),
    );
  }
}

class MyHomePage extends HookWidget {
  String title;
  MyHomePage(this.title);
  Widget _createText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Hello Cube'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAnimating = useState(false);
    final controller = useAnimationController(duration: 5.seconds);
    final value = useAnimation(controller);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Stage(
        onSceneCreated: (Scene scene) {
          scene.camera.position.setFrom(Vector3(0, 0, 300));
          scene.camera.updateTransform();
        },
        children: [
          TriangularPrism(
            position: Vector3(0, 0, 0),
            rotation: Vector3(0, value * 360, 0),
            width: 300,
            height: 100,
            autofill: false,
            sides: {
              Side.Front: Container(
                color: Colors.green,
                child: _createText(),
              ),
              Side.Back: Container(
                color: Colors.blue,
                child: _createText(),
              ),
            },
          ).actor,
          Cube(
            position: Vector3(0, 100, 0),
            rotation: Vector3(0, value * 360, 0),
            width: 300,
            height: 200,
            depth: 100,
            autofill: false,
            sides: {
              Side.Bottom: Container(
                color: Colors.yellow,
                child: _createText(),
              ),
              Side.Top: null,
              Side.Left: _createText(),
              Side.Right: Container(
                color: Colors.purple,
                child: _createText(),
              ),
              Side.Front: Container(
                color: Colors.green,
                child: _createText(),
              ),
              Side.Back: Container(
                color: Colors.blue,
                child: _createText(),
              ),
            },
          ).actor
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(isAnimating.value ? Icons.pause : Icons.play_arrow),
        onPressed: () => _handleStartStop(controller, isAnimating),
      ),
    );
  }

  _handleStartStop(
      AnimationController controller, ValueNotifier<bool> isAnimating) {
    if (isAnimating.value) {
      controller.stop();
    } else {
      controller.forward().then((_) {
        isAnimating.value = false;
        controller.reset();
      });
    }
    isAnimating.value = !isAnimating.value;
  }
}
