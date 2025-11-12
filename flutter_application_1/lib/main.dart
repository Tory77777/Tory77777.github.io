import 'package:flutter/material.dart';

void main() {
  runApp(const HoroscopeApp());
}

class HoroscopeApp extends StatelessWidget {
  const HoroscopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Гороскоп',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Roboto',
      ),
      home: const HoroscopeScreen(),
    );
  }
}

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  DateTime? _selectedDate;
  ZodiacSign? _zodiacSign;

  final Map<ZodiacSign, String> _zodiacDescriptions = {
    ZodiacSign.aries: '''
Овен - первый знак зодиака, символизирующий начало и энергию.
Сильные стороны: смелый, уверенный, энтузиаст, оптимистичный, честный, страстный
Слабые стороны: нетерпеливый, капризный, вспыльчивый, агрессивный''',
    
    ZodiacSign.taurus: '''
Телец - земной знак, связанный с материальным миром и стабильностью.
Сильные стороны: надежный, терпеливый, практичный, преданный, ответственный, стабильный
Слабые стороны: упрямый, собственнический, негибкий''',
    
    ZodiacSign.gemini: '''
Близнецы - воздушный знак, представляющий общение и интеллект.
Сильные стороны: нежный, ласковый, любопытный, adaptable, учится быстро
Слабые стороны: нервный, непоследовательный, нерешительный''',
    
    ZodiacSign.cancer: '''
Рак - водный знак, связанный с эмоциями и интуицией.
Сильные стороны: десятьacious, очень imaginative, верный, эмоциональный, симпатичный, убедительный
Слабые стороны: пессимистичный, подозрительный, манипулятивный, небезопасный''',
    
    ZodiacSign.leo: '''
Лев - огненный знак, представляющий творчество и самовыражение.
Сильные стороны: творческий, страстный, щедрый, теплотный, веселый, юмористический
Слабые стороны: высокомерный, упрямый, ленивый, негибкий''',
    
    ZodiacSign.virgo: '''
Дева - земной знак, связанный с анализом и служением.
Сильные стороны: верный, аналитический, добрый, трудолюбивый, практичный
Слабые стороны: застенчивый, беспокойный, чрезмерно критичный к себе и другим''',
    
    ZodiacSign.libra: '''
Весы - воздушный знак, представляющий баланс и отношения.
Сильные стороны: кооперативный, дипломатичный, изящный, справедливый, социальный
Слабые стороны: нерешительный, избегает конфронтации, будет нести обиду''',
    
    ZodiacSign.scorpio: '''
Скорпион - водный знак, связанный с интенсивностью и трансформацией.
Сильные стороны: верный, эмоциональный, страстный, решительный
Слабые стороны: ревнивый, скрытный, жестокий''',
    
    ZodiacSign.sagittarius: '''
Стрелец - огненный знак, представляющий приключения и философию.
Сильные стороны: щедрый, идеалистический, отличное чувство юмора
Слабые стороны: обещает больше, чем может выполнить, очень нетерпеливый, будет говорить прямо''',
    
    ZodiacSign.capricorn: '''
Козерог - земной знак, связанный с амбициями и дисциплиной.
Сильные стороны: ответственный, дисциплинированный, имеет самоконтроль, хорошие менеджеры
Слабые стороны: знающий, непрощающий, снисходительный, ожидает худшего''',
    
    ZodiacSign.aquarius: '''
Водолей - воздушный знак, представляющий инновации и гуманизм.
Сильные стороны: прогрессивный, оригинальный, независимый, гуманитарный
Слабые стороны: бежит от эмоционального выражения, темпераментный, непокорный''',
    
    ZodiacSign.pisces: '''
Рыбы - водный знак, связанный с духовностью и состраданием.
Сильные стороны: сострадательный, художественный, интуитивный, нежный, мудрый, музыкальный
Слабые стороны: боязливый, слишком доверчивый, грустный, желание убежать от реальности''',
  };

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.purple,
            colorScheme: const ColorScheme.light(primary: Colors.purple),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _zodiacSign = _calculateZodiacSign(picked);
      });
    }
  }

  ZodiacSign _calculateZodiacSign(DateTime birthDate) {
    final int day = birthDate.day;
    final int month = birthDate.month;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return ZodiacSign.aries;
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return ZodiacSign.taurus;
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      return ZodiacSign.gemini;
    } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      return ZodiacSign.cancer;
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      return ZodiacSign.leo;
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      return ZodiacSign.virgo;
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      return ZodiacSign.libra;
    } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return ZodiacSign.scorpio;
    } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return ZodiacSign.sagittarius;
    } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return ZodiacSign.capricorn;
    } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return ZodiacSign.aquarius;
    } else {
      return ZodiacSign.pisces;
    }
  }

  String _getZodiacSignName(ZodiacSign sign) {
    switch (sign) {
      case ZodiacSign.aries: return 'Овен';
      case ZodiacSign.taurus: return 'Телец';
      case ZodiacSign.gemini: return 'Близнецы';
      case ZodiacSign.cancer: return 'Рак';
      case ZodiacSign.leo: return 'Лев';
      case ZodiacSign.virgo: return 'Дева';
      case ZodiacSign.libra: return 'Весы';
      case ZodiacSign.scorpio: return 'Скорпион';
      case ZodiacSign.sagittarius: return 'Стрелец';
      case ZodiacSign.capricorn: return 'Козерог';
      case ZodiacSign.aquarius: return 'Водолей';
      case ZodiacSign.pisces: return 'Рыбы';
    }
  }

  String _getZodiacSignEmoji(ZodiacSign sign) {
    switch (sign) {
      case ZodiacSign.aries: return '♈';
      case ZodiacSign.taurus: return '♉';
      case ZodiacSign.gemini: return '♊';
      case ZodiacSign.cancer: return '♋';
      case ZodiacSign.leo: return '♌';
      case ZodiacSign.virgo: return '♍';
      case ZodiacSign.libra: return '♎';
      case ZodiacSign.scorpio: return '♏';
      case ZodiacSign.sagittarius: return '♐';
      case ZodiacSign.capricorn: return '♑';
      case ZodiacSign.aquarius: return '♒';
      case ZodiacSign.pisces: return '♓';
    }
  }

  Color _getZodiacSignColor(ZodiacSign sign) {
    switch (sign) {
      case ZodiacSign.aries: return Colors.red;
      case ZodiacSign.taurus: return Colors.green;
      case ZodiacSign.gemini: return Colors.yellow;
      case ZodiacSign.cancer: return Colors.white;
      case ZodiacSign.leo: return Colors.orange;
      case ZodiacSign.virgo: return Colors.brown;
      case ZodiacSign.libra: return Colors.pink;
      case ZodiacSign.scorpio: return Colors.black;
      case ZodiacSign.sagittarius: return Colors.purple;
      case ZodiacSign.capricorn: return Colors.grey;
      case ZodiacSign.aquarius: return Colors.blue;
      case ZodiacSign.pisces: return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Гороскоп'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Заголовок
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.deepPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.star,
                    size: 50,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Узнай свой знак зодиака',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Введите дату рождения и узнайте свою судьбу',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Кнопка выбора даты
            ElevatedButton.icon(
              onPressed: () => _selectDate(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(Icons.calendar_today),
              label: const Text(
                'Выбрать дату рождения',
                style: TextStyle(fontSize: 18),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Отображение выбранной даты
            if (_selectedDate != null)
              Text(
                'Выбранная дата: ${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.purple,
                ),
              ),
            
            const SizedBox(height: 30),
            
            // Отображение знака зодиака
            if (_zodiacSign != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Карточка знака зодиака
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _getZodiacSignColor(_zodiacSign!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _getZodiacSignColor(_zodiacSign!),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _getZodiacSignEmoji(_zodiacSign!),
                              style: const TextStyle(fontSize: 60),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _getZodiacSignName(_zodiacSign!),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: _getZodiacSignColor(_zodiacSign!),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              _zodiacDescriptions[_zodiacSign]!,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Дополнительная информация
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Интересные факты:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildZodiacFact(_zodiacSign!),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
         
          ],
        ),
      ),
    );
  }

  Widget _buildZodiacFact(ZodiacSign sign) {
    final facts = {
      ZodiacSign.aries: 'Овны часто становятся лидерами и первопроходцами.',
      ZodiacSign.taurus: 'Тельцы ценят комфорт и стабильность выше всего.',
      ZodiacSign.gemini: 'Близнецы - самые общительные знаки зодиака.',
      ZodiacSign.cancer: 'Раки обладают сильной интуицией и эмоциональностью.',
      ZodiacSign.leo: 'Львы обожают быть в центре внимания.',
      ZodiacSign.virgo: 'Девы внимательны к деталям и перфекционисты.',
      ZodiacSign.libra: 'Весы стремятся к гармонии и балансу во всем.',
      ZodiacSign.scorpio: 'Скорпионы - самые страстные и загадочные знаки.',
      ZodiacSign.sagittarius: 'Стрельцы обожают путешествия и приключения.',
      ZodiacSign.capricorn: 'Козероги - амбициозные и трудолюбивые.',
      ZodiacSign.aquarius: 'Водолеи - инноваторы и гуманисты.',
      ZodiacSign.pisces: 'Рыбы - самые творческие и духовные знаки.',
    };
    
    return Text(
      facts[sign]!,
      style: const TextStyle(fontSize: 16),
    );
  }
}

enum ZodiacSign {
  aries, taurus, gemini, cancer, leo, virgo, libra,
  scorpio, sagittarius, capricorn, aquarius, pisces
}