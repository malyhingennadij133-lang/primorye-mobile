import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String sbUrl = 'https://supabase.co';
const String sbKey = 'sb_publishable_q8Q4n2v9X7kLm3pR6tW1yZ_primorye_anon_key';

void main() => runApp(const RabotaTutMobileApp());

class RabotaTutMobileApp extends StatelessWidget {
  const RabotaTutMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Работа Тут',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFFCC00),
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
      ),
      home: const HomeRoleSwitcher(),
    );
  }
}

class HomeRoleSwitcher extends StatefulWidget {
  const HomeRoleSwitcher({super.key});
  @override
  State<HomeRoleSwitcher> createState() => _HomeRoleSwitcherState();
}

class _HomeRoleSwitcherState extends State<HomeRoleSwitcher> {
  int _bottomTab = 0;
  bool _isWorkerMode = false;
  bool _loading = false;
  String _selectedCity = 'Артём';
  String _activeCategory = '';

  List<String> _cities = ['Артём', 'Владивосток', 'Уссурийск', 'Находка', 'Москва', 'Санкт-Петербург'];

  List<Map<String, dynamic>> _services = [
    {'id': 1, 'title': 'Грузчики', 'parent_title': '', 'rate': 750, 'min_hours': 2, 'max_qty': 30, 'sort_order': 1},
    {'id': 2, 'title': 'Грузовое такси', 'parent_title': '', 'rate': 1400, 'min_hours': 2, 'max_qty': 10, 'sort_order': 2},
    {'id': 3, 'title': 'Разнорабочие', 'parent_title': '', 'rate': 650, 'min_hours': 4, 'max_qty': 30, 'sort_order': 3},
    {'id': 4, 'title': 'Клининг / Уборка', 'parent_title': '', 'rate': 900, 'min_hours': 3, 'max_qty': 15, 'sort_order': 4},
    {'id': 5, 'title': 'Спецтехника', 'parent_title': '', 'rate': 3500, 'min_hours': 4, 'max_qty': 5, 'sort_order': 5},
    {'id': 6, 'title': 'Тяжёлые работы (такелаж)', 'parent_title': '', 'rate': 1100, 'min_hours': 2, 'max_qty': 20, 'sort_order': 6},
    {'id': 7, 'title': 'Вывоз строительного мусора', 'parent_title': '', 'rate': 2800, 'min_hours': 2, 'max_qty': 10, 'sort_order': 7},
    {'id': 8, 'title': 'Сборка и разборка мебели', 'parent_title': '', 'rate': 850, 'min_hours': 2, 'max_qty': 10, 'sort_order': 8},
    {'id': 9, 'title': 'Универсалы / Мастер на час', 'parent_title': '', 'rate': 950, 'min_hours': 2, 'max_qty': 10, 'sort_order': 9},
    {'id': 10, 'title': 'Земельные и дачные работы', 'parent_title': '', 'rate': 750, 'min_hours': 4, 'max_qty': 30, 'sort_order': 10},
    {'id': 11, 'title': 'Интернет-мастер', 'parent_title': '', 'rate': 1000, 'min_hours': 1, 'max_qty': 5, 'sort_order': 11},
    {'id': 12, 'title': 'Автокран', 'parent_title': 'Спецтехника', 'rate': 4000, 'min_hours': 4, 'max_qty': 3, 'sort_order': 1},
    {'id': 13, 'title': 'Экскаватор-погрузчик', 'parent_title': 'Спецтехника', 'rate': 3500, 'min_hours': 4, 'max_qty': 3, 'sort_order': 2},
    {'id': 14, 'title': 'Манипулятор (воровайка)', 'parent_title': 'Спецтехника', 'rate': 3200, 'min_hours': 3, 'max_qty': 5, 'sort_order': 3},
    {'id': 15, 'title': 'Самосвал', 'parent_title': 'Спецтехника', 'rate': 3000, 'min_hours': 4, 'max_qty': 5, 'sort_order': 4},
    {'id': 16, 'title': 'Автовышка', 'parent_title': 'Спецтехника', 'rate': 3800, 'min_hours': 4, 'max_qty': 3, 'sort_order': 5},
    {'id': 17, 'title': 'Бобкэт (мини-погрузчик)', 'parent_title': 'Спецтехника', 'rate': 2800, 'min_hours': 4, 'max_qty': 3, 'sort_order': 6},
  ];

  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadFromCloud();
  }

  Map<String, String> get _headers => {
    'apikey': sbKey,
    'Authorization': 'Bearer $sbKey',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };

  Future<void> _loadFromCloud() async {
    setState(() => _loading = true);
    try {
      final cRes = await http.get(Uri.parse('$sbUrl/rest/v1/cities?select=city&order=city.asc'), headers: _headers);
      if (cRes.statusCode == 200) {
        final raw = List<Map<String, dynamic>>.from(jsonDecode(cRes.body));
        if (raw.isNotEmpty) {
          _cities = raw.map((e) => e['city'].toString()).toList();
          if (!_cities.contains(_selectedCity)) _selectedCity = _cities.first;
        }
      }
      final sRes = await http.get(Uri.parse('$sbUrl/rest/v1/services?select=*&active=eq.true&order=sort_order.asc'), headers: _headers);
      if (sRes.statusCode == 200) {
        final rawS = List<Map<String, dynamic>>.from(jsonDecode(sRes.body));
        if (rawS.isNotEmpty) _services = rawS;
      }
      final oRes = await http.get(Uri.parse('$sbUrl/rest/v1/orders?select=*&order=id.desc'), headers: _headers);
      if (oRes.statusCode == 200) {
        _orders = List<Map<String, dynamic>>.from(jsonDecode(oRes.body));
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }
  Future<void> _createOrder(Map<String, dynamic> svc) async {
    final addrCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    int qty = 1;
    int hours = (svc['min_hours'] ?? 2) as int;
    final rate = (svc['rate'] ?? 750) as int;
    final maxQ = (svc['max_qty'] ?? 30) as int;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${svc['title']} ($_selectedCity)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Адрес подачи (улица, дом)', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Ваш телефон (+7...)', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Человек / единиц (до $maxQ): $qty'),
                  Row(children: [
                    IconButton(onPressed: qty > 1 ? () => setModal(() => qty--) : null, icon: const Icon(Icons.remove_circle)),
                    IconButton(onPressed: qty < maxQ ? () => setModal(() => qty++) : null, icon: const Icon(Icons.add_circle)),
                  ]),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Часов работы: $hours'),
                  Row(children: [
                    IconButton(onPressed: hours > 1 ? () => setModal(() => hours--) : null, icon: const Icon(Icons.remove_circle)),
                    IconButton(onPressed: () => setModal(() => hours++), icon: const Icon(Icons.add_circle)),
                  ]),
                ],
              ),
              const SizedBox(height: 8),
              Text('Итого: ${qty * hours * rate} ₽', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFFCC00), foregroundColor: Colors.black),
                  onPressed: () async {
                    if (addrCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    await http.post(
                      Uri.parse('$sbUrl/rest/v1/orders'),
                      headers: _headers,
                      body: jsonEncode({
                        'service_title': svc['title'],
                        'city': _selectedCity,
                        'address': addrCtrl.text.trim(),
                        'client_phone': phoneCtrl.text.trim(),
                        'needed_workers': qty,
                        'hired_workers': 0,
                        'total_sum': qty * hours * rate,
                        'status': 'Открыт',
                      }),
                    );
                    await _loadFromCloud();
                  },
                  child: const Text('Оформить заказ', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _takeOrder(Map<String, dynamic> o) async {
    final id = o['id'];
    final hired = ((o['hired_workers'] ?? 0) as int) + 1;
    final need = (o['needed_workers'] ?? 1) as int;
    final closed = hired >= need;
    await http.patch(
      Uri.parse('$sbUrl/rest/v1/orders?id=eq.$id'),
      headers: _headers,
      body: jsonEncode({
        'hired_workers': hired,
        'status': closed ? 'Закрыт (набран)' : 'Идёт набор',
      }),
    );
    await _loadFromCloud();
  }
  @override
  Widget build(BuildContext context) {
    final mainServices = _services.where((s) => (s['parent_title'] ?? '').toString().isEmpty).toList();
    final subServices = _services.where((s) => (s['parent_title'] ?? '').toString() == _activeCategory).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFCC00),
        title: Row(
          children: [
            const Text('РАБОТА ТУТ', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButton<String>(
                value: _cities.contains(_selectedCity) ? _selectedCity : _cities.first,
                isExpanded: true,
                underline: const SizedBox(),
                items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
                onChanged: (v) => setState(() => _selectedCity = v ?? _selectedCity),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _isWorkerMode = !_isWorkerMode),
            icon: Icon(_isWorkerMode ? Icons.engineering : Icons.person, color: Colors.black),
            label: Text(_isWorkerMode ? 'Исполнитель' : 'Заказчик', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _isWorkerMode
              ? _buildWorkerFeed()
              : _bottomTab == 1
                  ? _buildMyOrders()
                  : _activeCategory.isNotEmpty
                      ? _buildSubServicesGrid(subServices)
                      : _buildMainServicesGrid(mainServices),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _bottomTab,
        onDestinationSelected: (i) => setState(() {
          _bottomTab = i;
          _activeCategory = '';
        }),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Услуги'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Заказы'),
        ],
      ),
    );
  }

  Widget _buildMainServicesGrid(List<Map<String, dynamic>> list) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.35),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final s = list[i];
        final title = s['title'].toString();
        final hasSubs = _services.any((x) => (x['parent_title'] ?? '').toString() == title);
        final openCount = _orders.where((o) => o['service_title'] == title && o['status'] != 'Закрыт (набран)').length;
        return InkWell(
          onTap: () => hasSubs ? setState(() => _activeCategory = title) : _createOrder(s),
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text('от ${s['rate']} ₽/ч', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                  if (openCount > 0) Text('Заявок: $openCount', style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubServicesGrid(List<Map<String, dynamic>> subs) {
    return Column(
      children: [
        ListTile(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _activeCategory = '')),
          title: Text('$_activeCategory — выберите технику / вид:', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: 0.95),
            itemCount: subs.length,
            itemBuilder: (_, i) {
              final s = subs[i];
              return InkWell(
                onTap: () => _createOrder(s),
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${s['title']}', textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('${s['rate']}₽', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWorkerFeed() {
    final open = _orders.where((o) => o['status'] != 'Закрыт (набран)').toList();
    return RefreshIndicator(
      onRefresh: _loadFromCloud,
      child: open.isEmpty
          ? const Center(child: Text('Свободных заявок в эфире пока нет'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: open.length,
              itemBuilder: (_, i) {
                final o = open[i];
                final hired = o['hired_workers'] ?? 0;
                final need = o['needed_workers'] ?? 1;
                return Card(
                  child: ListTile(
                    title: Text('${o['service_title']} • ${o['city']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${o['address']}\nНабрано: $hired из $need чел. • ${o['total_sum']} ₽'),
                    trailing: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFFCC00), foregroundColor: Colors.black),
                      onPressed: () => _takeOrder(o),
                      child: const Text('Взять'),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildMyOrders() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _orders.length,
      itemBuilder: (_, i) {
        final o = _orders[i];
        return Card(
          child: ListTile(
            title: Text('#${o['id']} ${o['service_title']} (${o['city']})'),
            subtitle: Text('${o['address']} • ${o['hired_workers']}/${o['needed_workers']} чел. • ${o['total_sum']} ₽'),
            trailing: Text('${o['status']}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}
