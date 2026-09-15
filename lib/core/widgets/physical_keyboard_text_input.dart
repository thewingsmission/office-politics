import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhysicalKeyboardTextInput extends StatefulWidget {
  const PhysicalKeyboardTextInput({super.key, required this.child});

  final Widget child;

  @override
  State<PhysicalKeyboardTextInput> createState() =>
      _PhysicalKeyboardTextInputState();
}

class _PhysicalKeyboardTextInputState extends State<PhysicalKeyboardTextInput> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(handlePhysicalKeyDesignScreen);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(handlePhysicalKeyDesignScreen);
    super.dispose();
  }

  @visibleForTesting
  bool handlePhysicalKeyDesignScreen(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;
    if (_hasModifierShortcutDesignScreen()) return false;
    final editable = focusedEditableTextDesignScreen();
    if (editable == null || editable.widget.readOnly) {
      return false;
    }

    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      return _applyPhysicalEditDesignScreen(
        editable,
        const _PhysicalEdit.deleteBack(),
      );
    }
    if (event.logicalKey == LogicalKeyboardKey.delete) {
      return _applyPhysicalEditDesignScreen(
        editable,
        const _PhysicalEdit.deleteForward(),
      );
    }

    final character = event.character;
    if (character == null || character.isEmpty) return false;
    if (character == '\n' || character == '\r' || character == '\t') {
      return false;
    }
    return _applyPhysicalEditDesignScreen(
      editable,
      _PhysicalEdit.insert(character),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

EditableTextState? focusedEditableTextDesignScreen() {
  final focusContext = FocusManager.instance.primaryFocus?.context;
  if (focusContext == null) return null;
  if (focusContext is StatefulElement &&
      focusContext.state is EditableTextState) {
    return focusContext.state as EditableTextState;
  }
  return focusContext.findAncestorStateOfType<EditableTextState>();
}

bool _applyPhysicalEditDesignScreen(
  EditableTextState editable,
  _PhysicalEdit edit,
) {
  final value = editable.textEditingValue;
  final selection = value.selection;
  if (!selection.isValid) return false;

  var start = selection.start;
  var end = selection.end;
  var replacement = '';
  switch (edit.kind) {
    case _PhysicalEditKind.insert:
      replacement = edit.character ?? '';
    case _PhysicalEditKind.deleteBack:
      if (start == end) {
        if (start <= 0) return true;
        start -= 1;
      }
    case _PhysicalEditKind.deleteForward:
      if (start == end) {
        if (start >= value.text.length) return true;
        end += 1;
      }
  }

  editable.userUpdateTextEditingValue(
    TextEditingValue(
      text: value.text.replaceRange(start, end, replacement),
      selection: TextSelection.collapsed(offset: start + replacement.length),
      composing: TextRange.empty,
    ),
    SelectionChangedCause.keyboard,
  );
  return true;
}

bool _hasModifierShortcutDesignScreen() {
  final pressed = HardwareKeyboard.instance.logicalKeysPressed;
  return pressed.contains(LogicalKeyboardKey.control) ||
      pressed.contains(LogicalKeyboardKey.controlLeft) ||
      pressed.contains(LogicalKeyboardKey.controlRight) ||
      pressed.contains(LogicalKeyboardKey.meta) ||
      pressed.contains(LogicalKeyboardKey.metaLeft) ||
      pressed.contains(LogicalKeyboardKey.metaRight) ||
      pressed.contains(LogicalKeyboardKey.alt) ||
      pressed.contains(LogicalKeyboardKey.altLeft) ||
      pressed.contains(LogicalKeyboardKey.altRight);
}

enum _PhysicalEditKind { insert, deleteBack, deleteForward }

class _PhysicalEdit {
  const _PhysicalEdit.insert(this.character) : kind = _PhysicalEditKind.insert;
  const _PhysicalEdit.deleteBack()
    : kind = _PhysicalEditKind.deleteBack,
      character = null;
  const _PhysicalEdit.deleteForward()
    : kind = _PhysicalEditKind.deleteForward,
      character = null;

  final _PhysicalEditKind kind;
  final String? character;
}
