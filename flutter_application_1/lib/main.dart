import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  
  bool _isLogin = true;
  DateTime? _selectedBirthDate;
  
  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    _checkIfUserLoggedIn();
  }

  void _checkIfUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('currentUser');
    if (userEmail != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HoroscopeScreen(userEmail: userEmail),
        ),
      );
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = '${picked.day}.${picked.month}.${picked.year}';
      });
    }
  }

  void _submitForm() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Пожалуйста, заполните все обязательные поля');
      return;
    }

    if (!_isLogin && (name.isEmpty || _selectedBirthDate == null)) {
      _showError('Пожалуйста, заполните все поля для регистрации');
      return;
    }

    try {
      if (_isLogin) {
        final user = await _userRepository.loginUser(email, password);
        if (user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('currentUser', email);
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HoroscopeScreen(userEmail: email),
              ),
            );
          }
        } else {
          _showError('Неверный email или пароль');
        }
      } else {
        final newUser = User(
          email: email,
          password: password,
          name: name,
          birthDate: _selectedBirthDate!,
          registrationDate: DateTime.now(),
        );
        
        final success = await _userRepository.registerUser(newUser);
        if (success) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('currentUser', email);
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HoroscopeScreen(userEmail: email),
              ),
            );
          }
        } else {
          _showError('Пользователь с таким email уже существует');
        }
      }
    } catch (e) {
      _showError('Произошла ошибка: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      size: 60,
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isLogin ? 'Вход в Гороскоп' : 'Регистрация',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Поле имени (только для регистрации)
                    if (!_isLogin) ...[
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Имя',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Поле даты рождения (только для регистрации)
                      TextField(
                        controller: _birthDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Дата рождения',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month),
                            onPressed: () => _selectBirthDate(context),
                          ),
                        ),
                        onTap: () => _selectBirthDate(context),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Поле email
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    
                    // Поле пароля
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    
                    // Кнопка отправки
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          _isLogin ? 'Войти' : 'Зарегистрироваться',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Переключение между входом и регистрацией
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _nameController.clear();
                          _birthDateController.clear();
                          _selectedBirthDate = null;
                        });
                      },
                      child: Text(
                        _isLogin 
                            ? 'Нет аккаунта? Зарегистрируйтесь'
                            : 'Уже есть аккаунт? Войдите',
                        style: const TextStyle(color: Colors.purple),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HoroscopeScreen extends StatefulWidget {
  final String userEmail;

  const HoroscopeScreen({super.key, required this.userEmail});

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  DateTime? _selectedDate;
  ZodiacSign? _zodiacSign;
  User? _currentUser;

  final UserRepository _userRepository = UserRepository();
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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = await _userRepository.getUser(widget.userEmail);
    if (user != null && mounted) {
      setState(() {
        _currentUser = user;
        _selectedDate = user.birthDate;
        _zodiacSign = _calculateZodiacSign(user.birthDate);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
      
      // Обновляем дату рождения пользователя
      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(birthDate: picked);
        await _userRepository.updateUser(updatedUser);
        setState(() {
          _currentUser = updatedUser;
        });
      }
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
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
        actions: [
          if (_currentUser != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  'Привет, ${_currentUser!.name}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Выйти',
          ),
        ],
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
              child: Column(
                children: [
                  const Icon(
                    Icons.star,
                    size: 50,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Узнай свой знак зодиака',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  const Text(
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
                'Изменить дату рождения',
                style: TextStyle(fontSize: 18),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Отображение выбранной даты
            if (_selectedDate != null)
              Text(
                'Дата рождения: ${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
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

// Модель пользователя
class User {
  final String email;
  final String password;
  final String name;
  final DateTime birthDate;
  final DateTime registrationDate;

  User({
    required this.email,
    required this.password,
    required this.name,
    required this.birthDate,
    required this.registrationDate,
  });

  User copyWith({
    String? email,
    String? password,
    String? name,
    DateTime? birthDate,
    DateTime? registrationDate,
  }) {
    return User(
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      registrationDate: registrationDate ?? this.registrationDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'registrationDate': registrationDate.toIso8601String(),
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'],
      password: map['password'],
      name: map['name'],
      birthDate: DateTime.parse(map['birthDate']),
      registrationDate: DateTime.parse(map['registrationDate']),
    );
  }
}

// Репозиторий для работы с пользователями
class UserRepository {
  final List<User> _users = [];

  Future<bool> registerUser(User newUser) async {
    // Проверяем, существует ли пользователь с таким email
    if (_users.any((user) => user.email == newUser.email)) {
      return false;
    }
    
    _users.add(newUser);
    await _saveUsersToStorage();
    return true;
  }

  Future<User?> loginUser(String email, String password) async {
    await _loadUsersFromStorage();
    try {
      return _users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  Future<User?> getUser(String email) async {
    await _loadUsersFromStorage();
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUser(User updatedUser) async {
    final index = _users.indexWhere((user) => user.email == updatedUser.email);
    if (index != -1) {
      _users[index] = updatedUser;
      await _saveUsersToStorage();
    }
  }

  Future<void> _saveUsersToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = _users.map((user) => user.toMap()).toList();
    await prefs.setString('users', jsonEncode(usersJson));
  }

  Future<void> _loadUsersFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    if (usersJson != null) {
      final List<dynamic> usersList = jsonDecode(usersJson);
      _users.clear();
      _users.addAll(usersList.map((userMap) => User.fromMap(userMap)));
    }
  }
}

enum ZodiacSign {
  aries, taurus, gemini, cancer, leo, virgo, libra,
  scorpio, sagittarius, capricorn, aquarius, pisces
}