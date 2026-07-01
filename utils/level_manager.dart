import 'dart:math';

class LevelManager {
  static Map<String, dynamic> generateQuestion(int level) {
    final random = Random();
    int a, b, answer;
    String operation, symbol;
    
    // Level 1-10: Addition
    if (level <= 10) {
      operation = 'addition';
      symbol = '+';
      int maxNum = 5 + (level - 1) * 5;
      a = random.nextInt(maxNum) + 1;
      b = random.nextInt(maxNum) + 1;
      answer = a + b;
    }
    // Level 11-20: Subtraction
    else if (level <= 20) {
      operation = 'subtraction';
      symbol = '−';
      int maxNum = 10 + (level - 11) * 5;
      a = random.nextInt(maxNum) + 10;
      b = random.nextInt(a) + 1;
      answer = a - b;
    }
    // Level 21-30: Multiplication
    else if (level <= 30) {
      operation = 'multiplication';
      symbol = '×';
      int maxNum = 3 + (level - 21) ~/ 2;
      a = random.nextInt(maxNum) + 1;
      b = random.nextInt(maxNum) + 1;
      answer = a * b;
    }
    // Level 31-40: Division
    else if (level <= 40) {
      operation = 'division';
      symbol = '÷';
      int maxNum = 4 + (level - 31) ~/ 2;
      b = random.nextInt(maxNum) + 1;
      answer = random.nextInt(maxNum) + 1;
      a = b * answer;
    }
    // Level 41-50: Algebra
    else {
      operation = 'algebra';
      symbol = '?';
      int type = random.nextInt(4);
      int maxNum = 5 + (level - 41);
      
      switch (type) {
        case 0: // x + b = c
          b = random.nextInt(maxNum) + 1;
          answer = random.nextInt(maxNum) + 1;
          a = answer + b;
          return {
            'text': '$a + x = ${a + b}',
            'answer': b,
            'operation': operation,
            'symbol': 'x',
            'displayAnswer': 'x = $b',
          };
        case 1: // x - b = c
          b = random.nextInt(maxNum) + 1;
          answer = random.nextInt(maxNum) + maxNum + 5;
          a = answer - b;
          return {
            'text': 'x - $b = $a',
            'answer': answer,
            'operation': operation,
            'symbol': 'x',
            'displayAnswer': 'x = $answer',
          };
        case 2: // b * x = c
          b = random.nextInt(maxNum) + 1;
          answer = random.nextInt(maxNum) + 1;
          a = b * answer;
          return {
            'text': '$b × x = $a',
            'answer': answer,
            'operation': operation,
            'symbol': 'x',
            'displayAnswer': 'x = $answer',
          };
        default: // x / b = c
          b = random.nextInt(maxNum) + 1;
          answer = random.nextInt(maxNum) + 1;
          a = b * answer;
          return {
            'text': 'x ÷ $b = $answer',
            'answer': a,
            'operation': operation,
            'symbol': 'x',
            'displayAnswer': 'x = $a',
          };
      }
    }
    
    return {
      'text': '$a $symbol $b = ?',
      'answer': answer,
      'operation': operation,
      'symbol': symbol,
      'displayAnswer': answer.toString(),
    };
  }
}