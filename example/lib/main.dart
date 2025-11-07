import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reactive_textfield/reactive_textfield.dart';


const btnConstraints = BoxConstraints(minWidth: kMinInteractiveDimension);
const btnIconSize = 20.0;


void main()
{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({ super.key });

  @override
  Widget build(final BuildContext context)
  {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ChangeNotifierProvider<TextHolder>(
        create: (context) => TextHolder('Initial text'),
        child: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget
{
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage>
{
  @override
  void initState()
  {
    super.initState();
    _historyController = UndoHistoryController();
  }

  @override
  void dispose()
  {
    _historyController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context)
  {
    final value = context.watch<TextHolder>().value;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 24.0,
            children: [
              Column(
                spacing: 4.0,
                children: [
                  MyTextField(
                    labelText: 'Field #1',
                    historyController: _historyController,
                  ),
                  HistoryButtons(controller: _historyController),
                ],
              ),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Field #2',
                ),
                child: Text(value),
              ),
              MyTextField(
                labelText: 'Field #3',
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final rnd = Random(DateTime.now().millisecondsSinceEpoch).nextInt(100);
          MaterialBannerClosedReason? bannerCloseReason;
          
          void closeBanner([
            final MaterialBannerClosedReason reason = MaterialBannerClosedReason.dismiss,
          ])
          {
            if (bannerCloseReason != null) return;
            ScaffoldMessenger.maybeOf(context)?.hideCurrentMaterialBanner(
              reason: reason,
            );
          }

          ScaffoldMessenger.maybeOf(context)?.showMaterialBanner(
            MaterialBanner(
              content: Text('A new text #$rnd has been scheduled.'),
              actions: [
                TextButton(
                  onPressed: closeBanner,
                  child: Text('Dismiss'),
                ),
              ],
            ),
          ).closed.then((reason) => bannerCloseReason = reason);
          Future.delayed(
            const Duration(milliseconds: 3000),
            () {
              closeBanner(MaterialBannerClosedReason.hide);
              if (context.mounted) {
                context.read<TextHolder>().value = 'Random text #$rnd';
              }
            },
          );
        },
        tooltip: 'Schedule change',
        child: const Icon(Icons.add),
      ),
    );
  }

  late final UndoHistoryController _historyController;
}


class TextHolder with ChangeNotifier
{
  String get value => _value;

  set value(final String value)
  {
    if (_value == value) return;
    _value = value;
    notifyListeners();
  }

  TextHolder(final String value)
  : _value = value;

  String _value;
}


class HistoryButtons extends StatefulWidget
{
  final UndoHistoryController controller;

  const HistoryButtons({
    super.key,
    required this.controller,
  });

  @override
  State<HistoryButtons> createState() => _HistoryButtonsState();
}

class _HistoryButtonsState extends State<HistoryButtons>
{
  @override
  void initState()
  {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose()
  {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant final HistoryButtons oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  Widget build(final BuildContext context)
  {
    return Row(
      spacing: 8.0,
      children: [
        IconButton.filledTonal(
          onPressed: widget.controller.value.canUndo
            ? widget.controller.undo
            : null,
          icon: const Icon(Icons.undo),
          iconSize: btnIconSize,
          constraints: btnConstraints,
        ),
        IconButton.filledTonal(
          onPressed: widget.controller.value.canRedo
            ? widget.controller.redo
            : null,
          icon: const Icon(Icons.redo),
          iconSize: btnIconSize,
          constraints: btnConstraints,
        ),
      ],
    );
  }

  void _onChanged()
  {
    setState(() {});
  }
}


class MyTextField extends StatefulWidget
{
  final String? labelText;
  final int? maxLines;
  final UndoHistoryController? historyController;

  const MyTextField({
    super.key,
    this.labelText,
    this.maxLines = 1,
    this.historyController,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField>
{
  @override
  void initState()
  {
    super.initState();
    _value = context.read<TextHolder>().value;
    _focusNode = FocusNode();
  }

  @override
  void dispose()
  {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context)
  {
    return Selector<TextHolder, String>(
      selector: (context, holder) => holder.value,
      builder: (context, value, child) {
        if (!_focusNode.hasFocus) {
          _value = value;
        }
        final synced = _value == value;
        return ReactiveTextField(
          decoration: InputDecoration(
            labelText: widget.labelText,
            suffixIcon: widget.maxLines == 1
              ? null
              : IconButton.filledTonal(
                  onPressed: synced ? null : () {
                    context.read<TextHolder>().value = _value;
                    _focusNode.unfocus();
                  },
                  icon: Icon(Icons.done),
                  iconSize: btnIconSize,
                  constraints: btnConstraints,
                ),
            suffixIconColor: synced ? Theme.of(context).disabledColor : null,
          ),
          undoController: widget.historyController,
          focusNode: _focusNode,
          maxLines: widget.maxLines,
          unfocusBehavior: widget.maxLines == 1
            ? UnfocusBehavior.resetValue
            : UnfocusBehavior.nothing,
          value: value,
          onTextChanged: (value) => setState(() => _value = value),
          onValueChanged: (value) => context.read<TextHolder>().value = value,
        );
      },
    );
  }

  late String _value;
  late final FocusNode _focusNode;
}
