import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'types.dart';


/// A [TextField] with a [value] and [onValueChanged] instead of having the
/// [controller].
/// 
/// The purpose is to make the [TextField] easily bindable to any provider, like
/// this:
/// 
/// ```dart
/// ReactiveTextField(
///   value: context.watch<TextHolder>().value,
///   onValueChanged: (value) {
///     context.read<TextHolder>().value = value;
///   },
/// )
/// ```
/// 
/// See also:
///
///  * [TextField], which is the base class of this widget.
class ReactiveTextField extends TextField
{
  /// The text value to be shown.
  final String value;

  /// Called when the [value] changes.
  /// 
  /// The [value] usually changes on text submission, leaving the widget
  /// (depending on [unfocusBehavior]), undoing/redoing the [undoController],
  /// rebuilding the widget with a new [value].
  final ValueChanged<String>? onValueChanged;

  /// Called whenever the text is changed.
  /// 
  /// Unlike the [onChanged] this callback is triggered not only when the text
  /// changes by the user.
  final ValueChanged<String>? onTextChanged;

  /// Whether the text should be saved, restored or kept the same when the
  /// widget loses the focus.
  /// 
  /// It is useful to change in the multiline [ReactiveTextField].
  /// 
  /// Defaults to [UnfocusBehavior.resetValue].
  final UnfocusBehavior unfocusBehavior;

  const ReactiveTextField({
    super.key,
    super.groupId = EditableText,
    super.controller,
    super.focusNode,
    super.undoController,
    super.decoration = const InputDecoration(),
    super.keyboardType,
    super.textInputAction,
    super.textCapitalization = TextCapitalization.none,
    super.style,
    super.strutStyle,
    super.textAlign = TextAlign.start,
    super.textAlignVertical,
    super.textDirection,
    super.readOnly = false,
    super.showCursor,
    super.autofocus = false,
    super.statesController,
    super.obscuringCharacter = '•',
    super.obscureText = false,
    super.autocorrect,
    super.smartDashesType,
    super.smartQuotesType,
    super.enableSuggestions = true,
    super.maxLines = 1,
    super.minLines,
    super.expands = false,
    super.maxLength,
    super.maxLengthEnforcement,
    super.onChanged,
    super.onEditingComplete,
    super.onSubmitted,
    super.onAppPrivateCommand,
    super.inputFormatters,
    super.enabled,
    super.ignorePointers,
    super.cursorWidth = 2.0,
    super.cursorHeight,
    super.cursorRadius,
    super.cursorOpacityAnimates,
    super.cursorColor,
    super.cursorErrorColor,
    super.selectionHeightStyle,
    super.selectionWidthStyle,
    super.keyboardAppearance,
    super.scrollPadding = const EdgeInsets.all(20.0),
    super.dragStartBehavior = DragStartBehavior.start,
    super.enableInteractiveSelection,
    super.selectAllOnFocus,
    super.selectionControls,
    super.onTap,
    super.onTapAlwaysCalled = false,
    super.onTapOutside,
    super.onTapUpOutside,
    super.mouseCursor,
    super.buildCounter,
    super.scrollController,
    super.scrollPhysics,
    super.autofillHints = const <String>[],
    super.contentInsertionConfiguration,
    super.clipBehavior = Clip.hardEdge,
    super.restorationId,
    super.stylusHandwritingEnabled = EditableText.defaultStylusHandwritingEnabled,
    super.enableIMEPersonalizedLearning = true,
    super.contextMenuBuilder = _defaultContextMenuBuilder,
    super.canRequestFocus = true,
    super.spellCheckConfiguration,
    super.magnifierConfiguration,
    super.hintLocales,
    required this.value,
    this.onValueChanged,
    this.onTextChanged,
    this.unfocusBehavior = UnfocusBehavior.resetValue,
  });

  static Widget _defaultContextMenuBuilder(
    final BuildContext context,
    final EditableTextState editableTextState,
  )
  {
    if (defaultTargetPlatform == TargetPlatform.iOS
      && SystemContextMenu.isSupported(context)
    ) {
      return SystemContextMenu.editableText(editableTextState: editableTextState);
    }
    return AdaptiveTextSelectionToolbar.editableText(editableTextState: editableTextState);
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties)
  {
    super.debugFillProperties(properties);
    properties.add(StringProperty('value', value));
  }

  @override
  State<ReactiveTextField> createState() => _ReactiveTextFieldState();
}


class _ReactiveTextFieldState extends State<ReactiveTextField>
{
  TextEditingController get controller => widget.controller ?? _controller!;

  FocusNode get focusNode => widget.focusNode ?? _focusNode!;

  String get value => _value;

  set value(final String value)
  {
    if (_value == value) return;
    _value = value;
    widget.onValueChanged?.call(value);
  }

  @override
  void initState()
  {
    super.initState();
    _text = widget.value;
    _value = widget.value;
    _initTextController();
    _initFocusNode();
    _initHistoryController();
  }

  @override
  void dispose()
  {
    _deinitHistoryController();
    _deinitFocusNode();
    _focusNode?.dispose();
    _deinitTextController();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant final ReactiveTextField oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _deinitTextController(oldWidget.controller);
      _initTextController();
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _deinitFocusNode(oldWidget.focusNode);
      _initFocusNode();
    }
    if (oldWidget.value != widget.value) {
      _applyWidgetValue(inBuildMode: true);
    }
    if (oldWidget.undoController != widget.undoController) {
      _deinitHistoryController(oldWidget.undoController);
      _initHistoryController();
    }
  }

  @override
  Widget build(final BuildContext context)
  {
    return TextField(
      groupId: widget.groupId,
      controller: controller,
      focusNode: focusNode,
      undoController: widget.undoController,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      textDirection: widget.textDirection,
      readOnly: widget.readOnly,
      showCursor: widget.showCursor,
      autofocus: widget.autofocus,
      statesController: widget.statesController,
      obscuringCharacter: widget.obscuringCharacter,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      smartDashesType: widget.smartDashesType,
      smartQuotesType: widget.smartQuotesType,
      enableSuggestions: widget.enableSuggestions,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      maxLength: widget.maxLength,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: _onSubmitted,
      onAppPrivateCommand: widget.onAppPrivateCommand,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      ignorePointers: widget.ignorePointers,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorOpacityAnimates: widget.cursorOpacityAnimates,
      cursorColor: widget.cursorColor,
      cursorErrorColor: widget.cursorErrorColor,
      selectionHeightStyle: widget.selectionHeightStyle,
      selectionWidthStyle: widget.selectionWidthStyle,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPadding: widget.scrollPadding,
      dragStartBehavior: widget.dragStartBehavior,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      selectAllOnFocus: widget.selectAllOnFocus,
      selectionControls: widget.selectionControls,
      onTap: widget.onTap,
      onTapAlwaysCalled: widget.onTapAlwaysCalled,
      onTapOutside: widget.onTapOutside,
      onTapUpOutside: widget.onTapUpOutside,
      mouseCursor: widget.mouseCursor,
      buildCounter: widget.buildCounter,
      scrollController: widget.scrollController,
      scrollPhysics: widget.scrollPhysics,
      autofillHints: widget.autofillHints,
      contentInsertionConfiguration: widget.contentInsertionConfiguration,
      clipBehavior: widget.clipBehavior,
      restorationId: widget.restorationId,
      stylusHandwritingEnabled: widget.stylusHandwritingEnabled,
      enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
      contextMenuBuilder: widget.contextMenuBuilder,
      canRequestFocus: widget.canRequestFocus,
      spellCheckConfiguration: widget.spellCheckConfiguration,
      magnifierConfiguration: widget.magnifierConfiguration,
      hintLocales: widget.hintLocales,
    );
  }

  void _initTextController([ final TextEditingController? oldController ])
  {
    if (widget.controller == null) _controller = TextEditingController();
    controller.value = oldController?.value ?? TextEditingValue(
      text: _text,
      selection: TextSelection(baseOffset: 0, extentOffset: 0),
    );
    controller.addListener(_onTextChanged);
  }

  void _deinitTextController([ TextEditingController? controller ])
  {
    controller ??= this.controller;
    controller.removeListener(_onTextChanged);
  }

  void _initFocusNode()
  {
    if (widget.focusNode == null) _focusNode = FocusNode();
    focusNode.addListener(_onFocusChanged);
  }

  void _deinitFocusNode([ FocusNode? focusNode ])
  {
    focusNode ??= this.focusNode;
    focusNode.removeListener(_onFocusChanged);
  }

  void _initHistoryController()
  {
    widget.undoController?.onUndo.addListener(_onHistoryChanged);
    widget.undoController?.onRedo.addListener(_onHistoryChanged);
  }

  void _deinitHistoryController([ UndoHistoryController? controller ])
  {
    controller ??= widget.undoController;
    controller?.onUndo.removeListener(_onHistoryChanged);
    controller?.onRedo.removeListener(_onHistoryChanged);
  }

  void _applyControllerValue()
  {
    value = controller.text;
  }

  void _applyWidgetValue({ final bool inBuildMode = false })
  {
    value = widget.value;
    _applyInternalValue(inBuildMode: inBuildMode);
  }

  void _applyInternalValue({ final bool inBuildMode = false })
  {
    if (!focusNode.hasFocus && controller.text != value) {
      _setText(value, inBuildMode: inBuildMode);
      controller.value = TextEditingValue(
        text: value,
        selection: TextSelection(baseOffset: 0, extentOffset: 0),
      );
    }
  }

  void _setText(final String value, { final bool inBuildMode = false })
  {
    if (_text == value) return;
    _text = value;
    final onTextChanged = widget.onTextChanged;
    if (onTextChanged != null) {
      if (inBuildMode) {
        scheduleMicrotask(() => onTextChanged(_text));
      } else {
        onTextChanged(_text);
      }
    }
  }

  void _onSubmitted(final String value)
  {
    this.value = value;
    widget.onSubmitted?.call(value);
  }

  void _onTextChanged()
  {
    _setText(controller.text);
  }

  void _onFocusChanged()
  {
    if (focusNode.hasFocus) return;
    switch (widget.unfocusBehavior) {
      case UnfocusBehavior.nothing:
        break;
      case UnfocusBehavior.resetValue:
        _applyInternalValue();
      case UnfocusBehavior.saveValue:
        _applyControllerValue();
    }
  }

  void _onHistoryChanged()
  {
    // We can't use the controller.value immediately right now because the
    // history will change the controller.value a bit later. It happens because
    // we add this listener in our initState before the TextField is built in
    // our build method and adds its listener to the undo controller.
    scheduleMicrotask(_applyControllerValue);
  }

  late String _text;
  late String _value;
  FocusNode? _focusNode;
  TextEditingController? _controller;
}
