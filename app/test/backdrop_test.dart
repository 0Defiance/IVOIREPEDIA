import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ivoirepedia/src/ui/widgets/ivorian_patterns.dart';

void main() {
  // Pas de dérive : `pumpAndSettle` doit pouvoir se stabiliser.
  setUp(() => ivoireMotionEnabled = false);
  tearDown(() => ivoireMotionEnabled = true);

  Finder motifPainter() => find.byWidgetPredicate(
    (widget) => widget is CustomPaint && widget.painter is IvorianMotifPainter,
  );

  IvorianMotifPainter painterOf(WidgetTester tester) =>
      tester.widget<CustomPaint>(motifPainter()).painter!
          as IvorianMotifPainter;

  testWidgets('le pagne est peint derrière le contenu', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: IvorianBackdrop(child: Text('contenu'))),
    );
    await tester.pump();

    expect(find.text('contenu'), findsOneWidget);
    expect(motifPainter(), findsOneWidget);

    // Le contenu est la dernière couche : les motifs restent en arrière-plan.
    final stack = tester.widget<Stack>(
      find
          .descendant(
            of: find.byType(IvorianBackdrop),
            matching: find.byType(Stack),
          )
          .first,
    );
    expect(stack.children.last, isA<Text>());
  });

  testWidgets('les motifs réagissent au pointeur', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: IvorianBackdrop(child: SizedBox.expand())),
    );
    await tester.pump();

    expect(painterOf(tester).pointer, isNull);
    expect(painterOf(tester).progress, 0);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();

    await gesture.moveTo(const Offset(120, 90));
    await tester.pump();

    final painter = painterOf(tester);

    expect(painter.pointer, isNotNull);
    expect(painter.pointer!.dx, closeTo(120, 1));
    expect(painter.pointer!.dy, closeTo(90, 1));

    // La maille sous le pointeur s'éclaircit, celle du fond non.
    expect(
      painter.alphaAt(const Offset(120, 90)),
      greaterThan(IvorianMotifPainter.baseAlpha),
    );
    expect(
      painter.alphaAt(const Offset(900, 700)),
      closeTo(IvorianMotifPainter.baseAlpha, 0.001),
    );

    // Le pointeur parti, le fond revient à son repos.
    await gesture.removePointer();
    await tester.pump();

    expect(painterOf(tester).pointer, isNull);
  });
}
