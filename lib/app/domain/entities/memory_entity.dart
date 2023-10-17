// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:js_interop_unsafe';

class MemoryEntity {
  static const operations = ['&', '/', '+', '-', 'x', '='];

  final _buffer = [0.0, 0.0];
  int _bufferIndex = 0;
  String? _operation;
  String _value = '0';
  bool _wipeValue = false;
  String? _lastCommand; // a ? server para dizer que pode ser nulo sendo opcional atribuir um valor

  void applyCommand(String command) {
    if (_isReplacingOperatio(command)) {
      _operation = command;
      return;
    }
    if (command == 'AC') {
      _setClear();
    } else if (operations.contains(command)) {
      _setOperation(command);
    } else {
      _addDigit(command);
    }
    _lastCommand = command;
  }

  _isReplacingOperatio(String command) {
    return operations.contains(_lastCommand) && operations.contains(command) && _lastCommand != '=' && command != '=';
  }

  _setOperation(String command) {
    bool isEquals = command == '=';
    if (_bufferIndex == 0) {
      if (!isEquals) {
        _operation = command;
        _bufferIndex = 1;
        _wipeValue = true;
      }
    } else {
      _buffer[0] = _calculate();
      _buffer[1] = 0.0;
      _value = _buffer[0].toString();
      _value = _value.endsWith('.0') ? _value.split('.')[0] : _value;
      _operation = isEquals ? null : command;
      _bufferIndex = isEquals ? 0 : 1;
    }
  }

  _addDigit(String newOperation) {
    final isDot = newOperation == '.';
    final wipeValue = (_value == '0' && !isDot) || _wipeValue;
    if (isDot && _value.contains('.') && !wipeValue) {
      return;
    }
    final emptyValue = isDot ? '0' : '';
    final currentValue = wipeValue ? emptyValue : _value;
    _value = currentValue + newOperation;
    _wipeValue = false;
    _buffer[_bufferIndex] = double.tryParse(_value) ?? 0;
  }

  _setClear() {
    _value = '0';
    _buffer.setAll(0, [0.0, 0.0]);
    _bufferIndex = 0;
    _operation = null;
    _wipeValue = false;
  }

  _calculate() {
    switch (_operation) {
      case '&':
        return _buffer[0] % _buffer[1];
      case '/':
        return _buffer[0] / _buffer[1];
      case '+':
        return _buffer[0] + _buffer[1];
      case '-':
        return _buffer[0] - _buffer[1];
      case 'x':
        return _buffer[0] * _buffer[1];
      default:
        return _buffer[0];
    }
  }

  String get value {
    return _value;
  }
}
