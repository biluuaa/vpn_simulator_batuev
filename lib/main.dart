import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Susi Network',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ConnectionScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.power),
            label: 'Подключения',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}

// === Экран "Подключения" ===
class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  bool _isConnected = false;
  Duration _connectionTime = Duration.zero;
  late Timer _timer;

  final List<Map<String, String>> _servers = [
    {'name': 'Susi Network', 'flag': ''},
    {'name': 'Германия', 'flag': '🇩🇪'},
    {'name': 'Швейцария', 'flag': '🇨🇭'},
    {'name': 'Финляндия', 'flag': '🇫🇮'},
    {'name': 'Турция', 'flag': '🇹🇷'},
    {'name': 'Франция', 'flag': '🇫🇷'},
    {'name': 'Австрия', 'flag': '🇦🇹'},
    {'name': 'США', 'flag': '🇺🇸'},
    {'name': 'Британия', 'flag': '🇬🇧'},
  ];

  int _selectedServerIndex = 0;

  // Состояние для всплывающего уведомления
  String? _notificationMessage;
  bool _isNotificationLoading = false;

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
      if (_isConnected) {
        _connectionTime = Duration.zero;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _connectionTime += const Duration(seconds: 1);
          });
        });
      } else {
        _timer.cancel();
        _connectionTime = Duration.zero;
      }
    });
  }

  void _selectServer(int index) {
    if (index == 0) return;

    setState(() {
      _selectedServerIndex = index;

      if (_isConnected) {
        _timer.cancel();
        _connectionTime = Duration.zero;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _connectionTime += const Duration(seconds: 1);
          });
        });
      }
    });
  }

  // === Функция обновления подписки ===
  void _updateSubscriptions() async {
    if (!_isConnected) return;

    setState(() {
      _notificationMessage = 'Updating subscriptions...';
      _isNotificationLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _notificationMessage = 'Done';
      _isNotificationLoading = false;
    });

    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _notificationMessage = null;
    });
  }

  // === Диалог с информацией о Susi Network ===
  void _showSusiInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Susi Network'),
        content: const Text('Здесь будет информация о Susi Network.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  // === Диалог для диагональной стрелки под текстом ===
  void _openExternalLink() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Внешняя ссылка'),
        content: const Text('Эта стрелка ведёт в другое приложение.\nВ нашем случае — просто уведомление.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_isConnected) {
      _timer.cancel();
    }
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Пока ничего не делает
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // === Добавили SingleChildScrollView для скролла ===
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // === Время подключения (всегда видно, не яркий белый) ===
                  Text(
                    'Время подключения: ${_formatDuration(_connectionTime)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70, // <-- Не яркий белый
                    ),
                  ),
                  const SizedBox(height: 20),

                  // === Всплывающее уведомление ===
                  if (_notificationMessage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isNotificationLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                              ),
                            )
                          else
                            const Icon(Icons.check, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _notificationMessage!,
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // === Область с кнопкой подключения ===
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: GestureDetector(
                      onTap: _toggleConnection,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _isConnected ? Colors.green : Colors.blue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isConnected ? Icons.power : Icons.power_off,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // === Статус (не яркий белый) ===
                  Text(
                    _isConnected ? 'Подключено' : 'Отключено',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70, // <-- Не яркий белый
                    ),
                  ),

                  const SizedBox(height: 32),

                  // === Поле с серверами (включая "Susi Network") ===
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ..._servers.asMap().entries.map((entry) {
                          int index = entry.key;
                          var server = entry.value;
                          bool isSelected = _selectedServerIndex == index;

                          // Для "Susi Network" делаем отдельный стиль
                          if (index == 0) {
                            return Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      // === Новая иконка: "S" в белом квадрате ===
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'S',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        server['name']!,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Кнопка обновления подписки (сине-голубая стрелка, слева)
                                      IconButton(
                                        icon: Icon(Icons.refresh, color: Colors.blue.shade300),
                                        onPressed: _updateSubscriptions,
                                      ),
                                      // Кнопка инфо (стрелка вправо, справа)
                                      IconButton(
                                        icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                        onPressed: _showSusiInfo,
                                      ),
                                    ],
                                  ),
                                ),
                                // === Разделительная линия ===
                                Divider(
                                  color: Colors.white.withOpacity(0.2),
                                  height: 1,
                                  thickness: 0.5,
                                ),
                                // === Текст под "Susi Network" ===
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Доступы отсортированы по нагрузке:\nВыше доступ в списке = Быстрее соединение',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      // Диагональная стрелка справа от текста
                                      IconButton(
                                        icon: const Icon(Icons.arrow_outward, size: 16, color: Colors.grey),
                                        onPressed: _openExternalLink,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }

                          // Для обычных серверов
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue.shade300 : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  leading: Text(
                                    server['flag']!,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  title: Text(
                                    server['name']!,
                                    style: const TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.info, color: Colors.grey),
                                    onPressed: () {
                                      // Позже добавим открытие окна
                                    },
                                  ),
                                  enabled: !_isConnected || index != 0,
                                  onTap: () {
                                    _selectServer(index);
                                  },
                                ),
                              ),
                              if (index < _servers.length - 1)
                                Divider(
                                  color: Colors.white.withOpacity(0.2),
                                  height: 1,
                                  thickness: 0.5,
                                ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// === Экран "Настройки" ===
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Здесь будут настройки приложения\n(пока пусто)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}