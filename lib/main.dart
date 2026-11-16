import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';

const String supabaseUrl = 'https://supabase.co';
const String supabaseKey = 'sb_publishable_9Y3IES6sn7s1onvGikCaNg_hsISZNc1';

void main() => runApp(const PrimoryeMobileApp());

class PrimoryeMobileApp extends StatelessWidget {
  const PrimoryeMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Приморье • Сервис 10 в 1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFFC107),
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
      ),
      home: const MobileHomeScreen(),
    );
  }
}

class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  int _tabIndex = 0;
  String _selectedCity = 'Артём';
  String _userName = 'Алексей';
  String _userPhone = '+7 914 000-00-00';
  bool _loading = true;
  String _statusText = 'Синхронизация...';
  List<Map<String, dynamic>> _tariffs = [];
  List<Map<String, dynamic>> _cloudOrders = [];

  final List<String> _cities = [
    'Артём',
    'Уссурийск',
    'Владивосток',
    'Находка',
    'Большой Камень',
    'Спасск-Дальний',
  ];

  final List<String> _campuses = [
    'Городской адрес (без кампуса)',
    'Кампус ДВФУ (о. Русский) • Корпус A / B',
    'Кампус ДВФУ (о. Русский) • Корпус C / D',
    'Кампус ДВФУ (о. Русский) • Корпус E / F / G',
    'Кампус ДВФУ • Жилые корпуса (Север / Юг)',
    'Складской комплекс / РЦ (Угловое)',
    'Логистический терминал / Промзона',
  ];

  final List<String> _warehouseGates = [
    'Обычный подъезд (без ворот)',
    'Ворота №1',
    'Ворота №2',
    'Ворота №3',
    'Ворота №4',
    'Ворота №5',
    'Ворота №6',
    'Ворота №7',
    'Ворота №8',
    'Ворота №9',
    'Ворота №10',
    'Ворота №11–15 / Пандус КПП',
  ];

  final List<Map<String, dynamic>> _mainServices = [
    {
      'id': 'loaders',
      'title': 'Грузчики',
      'icon': '💪',
      'unit_label': 'Чел.',
      'max_slider_count': 30,
      'base_rate': 600,
    },
    {
      'id': 'cargo',
      'title': 'Грузовое такси',
      'icon': '🚚',
      'unit_label': 'Машин',
      'max_slider_count': 10,
      'base_rate': 750,
    },
    {
      'id': 'machinery',
      'title': 'Спецтехника',
      'icon': '🚜',
      'unit_label': 'Ед. тех.',
      'max_slider_count': 10,
      'base_rate': 2500,
    },
    {
      'id': 'cleaning',
      'title': 'Клининг и уборка',
      'icon': '🧹',
      'unit_label': 'Клинеров',
      'max_slider_count': 15,
      'base_rate': 1800,
    },
    {
      'id': 'taxi',
      'title': 'Своё Такси (+ Отогрев)',
      'icon': '🚖',
      'unit_label': 'Авто',
      'max_slider_count': 10,
      'base_rate': 150,
    },
    {
      'id': 'rent',
      'title': 'Аренда квартир и домов',
      'icon': '🏠',
      'unit_label': 'Объектов',
      'max_slider_count': 10,
      'base_rate': 1500,
    },
    {
      'id': 'car_rent',
      'title': 'Прокат авто',
      'icon': '🔑',
      'unit_label': 'Авто',
      'max_slider_count': 10,
      'base_rate': 2500,
    },
    {
      'id': 'electric',
      'title': 'Электрик',
      'icon': '⚡',
      'unit_label': 'Мастеров',
      'max_slider_count': 10,
      'base_rate': 500,
    },
    {
      'id': 'courier',
      'title': 'Курьер и Доставка',
      'icon': '📦',
      'unit_label': 'Курьеров',
      'max_slider_count': 10,
      'base_rate': 200,
    },
  ];

  final List<Map<String, dynamic>> _loadersSubTypes = [
    {
      'id': 'loaders_std',
      'title': 'Обычные грузчики',
      'icon': '💪',
      'unit_label': 'Чел.',
      'max_slider_count': 30,
      'base_rate': 600,
    },
    {
      'id': 'loaders_heavy',
      'title': 'Тяжёлые работы / Такелаж',
      'icon': '⛏️',
      'unit_label': 'Чел.',
      'max_slider_count': 30,
      'base_rate': 700,
    },
    {
      'id': 'loaders_univ',
      'title': 'Универсалы',
      'icon': '🛠️',
      'unit_label': 'Чел.',
      'max_slider_count': 30,
      'base_rate': 650,
    },
    {
      'id': 'loaders_wh',
      'title': 'Разнорабочие на склад',
      'icon': '📦',
      'unit_label': 'Чел.',
      'max_slider_count': 30,
      'base_rate': 550,
    },
    {
      'id': 'loaders_move',
      'title': 'Квартирный переезд',
      'icon': '🏠',
      'unit_label': 'Чел.',
      'max_slider_count': 15,
      'base_rate': 650,
    },
    {
      'id': 'loaders_furn',
      'title': 'Сборка и разборка мебели',
      'icon': '🪛',
      'unit_label': 'Мастеров',
      'max_slider_count': 10,
      'base_rate': 700,
    },
  ];

  final List<Map<String, dynamic>> _machineryTypes = [
    {
      'id': 'crane',
      'title': 'Автокран (16–25 т)',
      'icon': '🏗️',
      'unit_label': 'Ед.',
      'max_slider_count': 5,
      'base_rate': 3500,
    },
    {
      'id': 'drill',
      'title': 'Буровая / Ямобур',
      'icon': '🔩',
      'unit_label': 'Ед.',
      'max_slider_count': 5,
      'base_rate': 3000,
    },
    {
      'id': 'excavator',
      'title': 'Экскаватор-погрузчик',
      'icon': '🚜',
      'unit_label': 'Ед.',
      'max_slider_count': 8,
      'base_rate': 2800,
    },
    {
      'id': 'manipulator',
      'title': 'Манипулятор (Воровайка)',
      'icon': '🚛',
      'unit_label': 'Ед.',
      'max_slider_count': 10,
      'base_rate': 2500,
    },
    {
      'id': 'dump_truck',
      'title': 'Самосвал (10–20 т)',
      'icon': '🚚',
      'unit_label': 'Машин',
      'max_slider_count': 15,
      'base_rate': 2200,
    },
    {
      'id': 'tower',
      'title': 'Автовышка (18–28 м)',
      'icon': '🪜',
      'unit_label': 'Ед.',
      'max_slider_count': 5,
      'base_rate': 2500,
    },
    {
      'id': 'mini_exc',
      'title': 'Мини-экскаватор',
      'icon': '⛏️',
      'unit_label': 'Ед.',
      'max_slider_count': 8,
      'base_rate': 2000,
    },
    {
      'id': 'bulldozer',
      'title': 'Бульдозер / Трал',
      'icon': '🚧',
      'unit_label': 'Ед.',
      'max_slider_count': 5,
      'base_rate': 4500,
    },
  ];
  @override
  void initState() {
    super.initState();
    _syncAllFromSupabase();
  }

  Future<void> _syncAllFromSupabase() async {
    setState(() {
      _loading = true;
      _statusText = 'Синхронизация с сервером...';
    });
    try {
      final tReq = await html.HttpRequest.request(
        '$supabaseUrl/rest/v1/service_tariffs?select=*&is_active=eq.true',
        requestHeaders: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      );
      final oReq = await html.HttpRequest.request(
        '$supabaseUrl/rest/v1/orders?select=*&status=neq.cancelled&order=created_at.desc',
        requestHeaders: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      );
      setState(() {
        _tariffs = tReq.status == 200
            ? (jsonDecode(tReq.responseText!) as List)
                  .cast<Map<String, dynamic>>()
            : [];
        _cloudOrders = oReq.status == 200
            ? (jsonDecode(oReq.responseText!) as List)
                  .cast<Map<String, dynamic>>()
            : [];
        _statusText = 'Онлайн • Заявок в работе: ${_cloudOrders.length}';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _statusText = 'Автономный режим';
        _loading = false;
      });
    }
  }

  Future<void> _sendOrderToCloud(Map<String, dynamic> payload) async {
    try {
      await html.HttpRequest.request(
        '$supabaseUrl/rest/v1/orders',
        method: 'POST',
        requestHeaders: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        sendData: jsonEncode(payload),
      );
      await _syncAllFromSupabase();
    } catch (e) {
      debugPrint('Ошибка отправки: $e');
    }
  }

  Future<void> _updateOrderInCloud(
    String orderId,
    Map<String, dynamic> patch,
  ) async {
    try {
      await html.HttpRequest.request(
        '$supabaseUrl/rest/v1/orders?id=eq.$orderId',
        method: 'PATCH',
        requestHeaders: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
          'Content-Type': 'application/json',
        },
        sendData: jsonEncode(patch),
      );
      await _syncAllFromSupabase();
    } catch (e) {
      debugPrint('Ошибка обновления: $e');
    }
  }

  void _openSubCatalog({
    required String parentId,
    required String title,
    required List<Map<String, dynamic>> items,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setSubState) => Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFFFFC107),
              title: Text(
                '$title • г. $_selectedCity',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
            body: GridView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (ctx, i) {
                final sub = items[i];
                final fullTitle = '$title: ${sub['title']}';
                final cnt = _cloudOrders
                    .where(
                      (o) =>
                          o['description'] == fullTitle &&
                          o['city'] == _selectedCity &&
                          o['status'] == 'searching',
                    )
                    .length;
                return InkWell(
                  onTap: () => _openOrderSheet({
                    ...sub,
                    'service_id': parentId,
                    'title': fullTitle,
                  }, onCreated: () => setSubState(() {})),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              sub['icon'],
                              style: const TextStyle(fontSize: 28),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'от ${sub['base_rate']} ₽/ч',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cnt > 0
                                        ? Colors.green.shade100
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Заявок: $cnt',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: cnt > 0
                                          ? Colors.green.shade900
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          sub['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _openOrderSheet(
    Map<String, dynamic> service, {
    VoidCallback? onCreated,
  }) {
    final int maxCount = (service['max_slider_count'] ?? 10) as int;
    final double baseRate = ((service['base_rate'] ?? 500) as num).toDouble();
    final String unitLabel = (service['unit_label'] ?? 'Чел.').toString();
    final String serviceId =
        (service['service_id'] ?? service['id'] ?? 'loaders').toString();
    final bool showCampusAndGates =
        serviceId == 'cargo' ||
        serviceId == 'loaders' ||
        serviceId == 'machinery';

    double workersCount = 1;
    double hoursCount = 2;
    final addressCtrl = TextEditingController(text: 'ул. Кирова, 12');
    String selectedCampus = _campuses.first;
    String selectedGate = _warehouseGates.first;
    String payMethod = 'Безналичный расчёт';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final total = (baseRate * workersCount * hoursCount).round();
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${service['icon']} ${service['title']}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Ставка: ${baseRate.round()} ₽/ч • г. $_selectedCity',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Улица и дом / Склад',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (showCampusAndGates) ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedCampus,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Кампус / Терминал подъезда',
                        border: OutlineInputBorder(),
                      ),
                      items: _campuses
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c, overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setModalState(() => selectedCampus = v!),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedGate,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Номер ворот / Пандус',
                        border: OutlineInputBorder(),
                      ),
                      items: _warehouseGates
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: (v) => setModalState(() => selectedGate = v!),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    'Количество ($unitLabel): ${workersCount.round()} из $maxCount',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: workersCount,
                    min: 1,
                    max: maxCount.toDouble(),
                    divisions: maxCount > 1 ? maxCount - 1 : 1,
                    onChanged: (v) => setModalState(() => workersCount = v),
                  ),
                  Text(
                    'Время (часов): ${hoursCount.round()} ч.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: hoursCount,
                    min: 1,
                    max: 12,
                    divisions: 11,
                    onChanged: (v) => setModalState(() => hoursCount = v),
                  ),
                  DropdownButtonFormField<String>(
                    value: payMethod,
                    decoration: const InputDecoration(
                      labelText: 'Оплата',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Безналичный расчёт',
                        child: Text('Карта / СБП'),
                      ),
                      DropdownMenuItem(
                        value: 'Наличные',
                        child: Text('Наличные'),
                      ),
                      DropdownMenuItem(
                        value: 'На счёт',
                        child: Text('На счёт организации'),
                      ),
                    ],
                    onChanged: (v) => setModalState(() => payMethod = v!),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        final fullAddress = showCampusAndGates
                            ? '${addressCtrl.text} • $selectedCampus • $selectedGate'
                            : addressCtrl.text;
                        Navigator.pop(ctx);
                        await _sendOrderToCloud({
                          'service_id': serviceId,
                          'city': _selectedCity,
                          'address_from': fullAddress,
                          'description': service['title'],
                          'workers_needed': workersCount.round(),
                          'hours_count': hoursCount.round(),
                          'total_price': total,
                          'payment_method': payMethod,
                          'status': 'searching',
                        });
                        onCreated?.call();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Заявка на $total ₽ создана!'),
                              backgroundColor: Colors.green.shade700,
                            ),
                          );
                        }
                      },
                      child: Text(
                        'ЗАКАЗАТЬ ЗА $total ₽',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC107),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Приморье • Сервис 10 в 1',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            Text(_statusText, style: const TextStyle(fontSize: 11)),
          ],
        ),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCity,
              items: _cities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCity = v!),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _syncAllFromSupabase,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _tabIndex,
              children: [
                _buildClientTab(),
                _buildWorkerTab(),
                _buildProfileTab(),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Заказчик',
          ),
          NavigationDestination(
            icon: Icon(Icons.engineering_outlined),
            label: 'Исполнитель',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }

  Widget _buildClientTab() {
    final services = _tariffs.isNotEmpty
        ? _tariffs.where((t) => t['parent_id'] == null).toList()
        : _mainServices;
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (ctx, i) {
        final item = services[i];
        final id = item['id'].toString();
        final activeCount = _cloudOrders
            .where(
              (o) =>
                  o['service_id'] == id &&
                  o['city'] == _selectedCity &&
                  o['status'] == 'searching',
            )
            .length;
        return InkWell(
          onTap: () {
            if (id == 'machinery') {
              _openSubCatalog(
                parentId: 'machinery',
                title: 'Спецтехника',
                items: _machineryTypes,
              );
            } else if (id == 'loaders') {
              _openSubCatalog(
                parentId: 'loaders',
                title: 'Грузчики',
                items: _loadersSubTypes,
              );
            } else {
              _openOrderSheet(item);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['icon'] ?? '🛠️',
                      style: const TextStyle(fontSize: 28),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'от ${(item['base_rate'] as num).round()} ₽',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: activeCount > 0
                                ? Colors.green.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Заявок: $activeCount',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: activeCount > 0
                                  ? Colors.green.shade900
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  item['title'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkerTab() {
    final activeList = _cloudOrders
        .where((o) => o['status'] == 'searching')
        .toList();
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Card(
          color: Colors.green.shade800,
          child: const ListTile(
            leading: Icon(Icons.wallet, color: Colors.white),
            title: Text(
              'Баланс: 1 450 ₽',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Комиссия: 10% • 1-й заказ: 0%',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (activeList.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Нет свободных заявок в облаке. Создайте заказ во вкладке «Заказчик»!',
              ),
            ),
          )
        else
          ...activeList.map(
            (o) => Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${o['description']} — ${o['total_price']} ₽',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '📍 ${o['city']}, ${o['address_from']} • Набрано: ${o['workers_assigned'] ?? 0}/${o['workers_needed']}',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _updateOrderInCloud(o['id'], {
                              'status': 'cancelled',
                            }),
                            child: const Text('Отклонить'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              final next =
                                  ((o['workers_assigned'] ?? 0) as int) + 1;
                              final needed = (o['workers_needed'] ?? 1) as int;
                              _updateOrderInCloud(o['id'], {
                                'workers_assigned': next,
                                'status': next >= needed
                                    ? 'in_progress'
                                    : 'searching',
                              });
                            },
                            child: const Text('Принять (+1)'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileTab() {
    final nameCtrl = TextEditingController(text: _userName);
    final phoneCtrl = TextEditingController(text: _userPhone);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(
          radius: 36,
          backgroundColor: Color(0xFFFFC107),
          child: Icon(Icons.person, size: 40, color: Colors.black),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Ваше имя',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: phoneCtrl,
          decoration: const InputDecoration(
            labelText: 'Телефон',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFFC107),
            foregroundColor: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _userName = nameCtrl.text;
              _userPhone = phoneCtrl.text;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Данные профиля сохранены!')),
            );
          },
          child: const Text(
            'Сохранить профиль',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.sos, color: Colors.red),
            title: const Text('Экстренная связь с диспетчером'),
            subtitle: const Text('Круглосуточная поддержка Приморского края'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Сигнал SOS отправлен в диспетчерскую!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
