import 'package:flutter/services.dart';
class SingleDotInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    // 检查是否包含多个小数点
    if (text.contains('.') && text.indexOf('.') != text.lastIndexOf('.')) {
      return oldValue;
    }
    // 检查是否符合数字和小数点规则
    if (RegExp(r'^[0-9.]*$').hasMatch(text)) {
      // 检查小数点后的位数
      if (text.contains('.')) {
        final parts = text.split('.');
        if (parts.length > 1 && parts[1].length > 2) {
          return oldValue;
        }
      }
      return newValue;
    }
    return oldValue;
  }
}

// 只允许输入 11 位数字的格式化器
class ElevenDigitsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    // 检查是否是纯数字且长度不超过 11 位
    if (RegExp(r'^[0-9]{0,11}$').hasMatch(text)) {
      return newValue;
    }
    return oldValue;
  }
}