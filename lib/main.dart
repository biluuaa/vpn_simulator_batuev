import 'dart:async';
import 'package:flutter/material.dart';

// === Кастомная иконка "Роутинг" ===
class RoutingIcon extends StatelessWidget {
  final Color color;
  const RoutingIcon({super.key, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _RoutingPainter(color: color),
      ),
    );
  }
}

class _RoutingPainter extends CustomPainter {
  final Color color;
  _RoutingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width * 0.5, size.height / 2), paint);
    canvas.drawLine(
      Offset(size.width * 0.5, size.height / 2),
      Offset(size.width, size.height * 0.2),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height / 2),
      Offset(size.width, size.height * 0.8),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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

// === Главный экран с навигацией ===
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _bottomNavIndex = 0;
  String _currentSubScreen = 'main';

  @override
  Widget build(BuildContext context) {
    Widget currentBody;

    if (_currentSubScreen == 'url_schemes') {
      currentBody = UrlSchemesScreen(
        onBack: () => setState(() => _currentSubScreen = 'main'),
      );
    } else if (_currentSubScreen == 'routing') {
      currentBody = RoutingDetailScreen(
        onBack: () => setState(() => _currentSubScreen = 'main'),
      );
    } else {
      currentBody = [
        ConnectionScreen(),
        SettingsScreen(
          onUrlSchemesPressed: () => setState(() => _currentSubScreen = 'url_schemes'),
          onRoutingPressed: () => setState(() => _currentSubScreen = 'routing'),
        ),
      ][_bottomNavIndex];
    }

    return Scaffold(
      body: currentBody,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
            _currentSubScreen = 'main';
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
  bool _isServerListVisible = false;

  String? _notificationMessage;
  bool _isNotificationLoading = false;
  bool _isAddPressed = false;

  Future<void> _blinkButton() async {
    if (!_isConnected) return;
    setState(() {
      _isConnected = false;
    });
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _isConnected = true;
    });
  }

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
        _notificationMessage = null;
      }
    });
  }

  void _selectServer(int index) {
    setState(() {
      _selectedServerIndex = index;
    });
    if (_isConnected) {
      _connectionTime = Duration.zero;
      _timer.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _connectionTime += const Duration(seconds: 1);
        });
      });
      _blinkButton();
    }
  }

  void _updateSubscriptions() async {
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

  void _toggleServerList() {
    setState(() {
      _isServerListVisible = !_isServerListVisible;
    });
  }

  void _showAddMenu() {
    setState(() {
      _isAddPressed = true;
    });

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 60,
        80,
        0,
        0,
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: const [
              Text('Отсканировать QR'),
              Spacer(),
              Icon(Icons.qr_code, color: Colors.blue),
            ],
          ),
        ),
        PopupMenuItem(
          child: Row(
            children: const [
              Text('Ввести вручную'),
              Spacer(),
              Icon(Icons.keyboard, color: Colors.blue),
            ],
          ),
        ),
      ],
    ).then((_) {
      setState(() {
        _isAddPressed = false;
      });
    });
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
        title: const Text('Susi Network'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: _isAddPressed ? Colors.grey : Colors.blue,
            onPressed: _showAddMenu,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Время подключения: ${_formatDuration(_connectionTime)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

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
                              color: const Color(0x4D000000),
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

                  Text(
                    _isConnected ? 'Подключено' : 'Отключено',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
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
                              const Text(
                                'Susi Network',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  _isServerListVisible
                                      ? Icons.arrow_drop_down
                                      : Icons.arrow_forward_ios,
                                  size: _isServerListVisible ? 24 : 16,
                                  color: Colors.grey,
                                ),
                                onPressed: _toggleServerList,
                              ),
                              IconButton(
                                icon: Icon(Icons.refresh, color: Colors.blue.shade300),
                                onPressed: _updateSubscriptions,
                              ),
                            ],
                          ),
                        ),

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
                              IconButton(
                                icon: const Icon(Icons.arrow_outward, size: 16, color: Colors.grey),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Внешняя ссылка'),
                                      content: const Text('Переход в другое приложение.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('ОК'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        if (_isServerListVisible)
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                ..._servers.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  var server = entry.value;
                                  bool isSelected = _selectedServerIndex == index;

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
                                            onPressed: () {},
                                          ),
                                          onTap: () => _selectServer(index),
                                        ),
                                      ),
                                      if (index < _servers.length - 1)
                                        Divider(
                                          color: const Color(0x33FFFFFF),
                                          height: 1,
                                          thickness: 0.5,
                                        ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
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
  final VoidCallback onUrlSchemesPressed;
  final VoidCallback onRoutingPressed;

  const SettingsScreen({
    super.key,
    required this.onUrlSchemesPressed,
    required this.onRoutingPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color blockColor = const Color(0xFF202020);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Настройки',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: onUrlSchemesPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: blockColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, color: Colors.blue),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Схемы URL',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'РОУТИНГ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              GestureDetector(
                onTap: onRoutingPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: blockColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      RoutingIcon(color: Colors.blue),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Роутинг',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'ПРЕДПОЧТЕНИЯ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: blockColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildSettingItem(
                      icon: Icons.receipt_long_outlined,
                      title: 'Подписка',
                      trailingColor: Colors.grey,
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.router,
                      title: 'Туннель',
                      trailingColor: Colors.grey,
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.settings,
                      title: 'Настройки приложения',
                      trailingColor: Colors.grey,
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.description,
                      title: 'Логи',
                      trailingColor: Colors.grey,
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.schedule,
                      title: 'On Demand',
                      trailingColor: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({required IconData icon, required String title, Color? trailingColor}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 18)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: trailingColor ?? Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: const Color(0x1FFFFFFF),
      height: 1,
      thickness: 0.5,
    );
  }
}

// === Экран: Схемы URL ===
class UrlSchemesScreen extends StatelessWidget {
  final VoidCallback onBack;

  const UrlSchemesScreen({super.key, required this.onBack});

  static const List<String> _items = [
    'ДОБАВИТЬ КОНФИГУРАЦИЮ',
    'ДОБАВИТЬ ПОДПИСКУ',
    'ДОБАВИТЬ РОУТИНГ',
    'CONNECT',
    'DISCONNECT',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Схемы URL'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 0, top: 8.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var item in _items)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 0, bottom: 8),
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF202020),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Ваш сервис://import',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// === Экран: Роутинг ===
class RoutingDetailScreen extends StatefulWidget {
  final VoidCallback onBack;

  const RoutingDetailScreen({super.key, required this.onBack});

  @override
  State<RoutingDetailScreen> createState() => _RoutingDetailScreenState();
}

class _RoutingDetailScreenState extends State<RoutingDetailScreen> {
  bool _isEnabled = false;
  bool _isAddPressed = false;

  void _showCreateRoutingMenu() {
    setState(() {
      _isAddPressed = true;
    });

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(300, 80, 0, 0),
      items: [
        PopupMenuItem(
          child: Row(
            children: const [
              Text('Создать роутинг'),
              Spacer(),
              Icon(Icons.create_new_folder, color: Colors.blue),
            ],
          ),
        ),
      ],
    ).then((_) {
      setState(() {
        _isAddPressed = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Роутинг'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: _isAddPressed ? Colors.grey : Colors.blue,
            onPressed: _showCreateRoutingMenu,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Включено',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                const Spacer(),
                Switch(
                  value: _isEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isEnabled = value;
                    });
                  },
                  activeThumbColor: Colors.green,
                  activeTrackColor: const Color(0x4D00FF00),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: const Color(0x4DFFFFFF),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              'Для того, чтобы настройки роутинга вступили в силу, необходимо перезапустить туннель.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            const Text(
              'РОУТИНГИ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF202020),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Настройте свой первый роутинг, нажав на "+" в правом верхнем углу',
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}