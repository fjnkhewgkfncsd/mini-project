import 'dart:io';

class InputHelpers {
  static String getRequiredString(String prompt) {
    while (true) {
      print(prompt);
      final input = stdin.readLineSync()?.trim() ?? '';
      if (input.isNotEmpty) return input;
      print('❌ This field is required.');
    }
  }
  
  static String getString(String prompt) {
    print(prompt);
    return stdin.readLineSync()?.trim() ?? '';
  }
  
  static int getPositiveInt(String prompt) {
    while (true) {
      print(prompt);
      final input = stdin.readLineSync()?.trim() ?? '';
      try {
        final value = int.parse(input);
        if (value >= 0) return value;
        print('❌ Please enter a positive number.');
      } catch (e) {
        print('❌ Please enter a valid number.');
      }
    }
  }
}