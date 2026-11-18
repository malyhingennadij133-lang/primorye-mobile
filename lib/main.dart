import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';

void main() => runApp(const PrimoryeMobileSuperApp());

const String kSupabaseUrl = 'https://' 'irwfyswmawiamejmisjg.supabase.co';


const String kSupabaseKey = 'sb_publishable_9Y3IES6sn7s1onvGlkCaNg_hsISZNc1';

class PrimoryeMobileSuperApp extends StatefulWidget {
  const PrimoryeMobileSuperApp({super.key});

  @override
  State<PrimoryeMobileSuperApp> createState() => _PrimoryeMobileSuperAppState();
}

class _PrimoryeMobileSuperAppState extends State<PrimoryeMobileSuperApp> {
  bool _isDark = false;
  Color _accent = const Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Приморье Суперапп',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: _isDark ? Brightness.dark : Brightness.light,
        colorSchemeSeed: _accent,
        scaffoldBackgroundColor: _isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      ),
      home: MainAppShell(
        isDark: _isDark,
        accent: _accent,
        onToggleTheme: () => setState(() => _isDark = !_isDark),
      ),
    );
  }
}

class MainAppShell extends StatefulWidget {
  final bool isDark;
  final Color accent;
  final VoidCallback onToggleTheme;

  const MainAppShell({super.key, required this.isDark, required this.accent, required this.onToggleTheme});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _bottomTab = 0; // 0: Заказчик (квадраты), 1: Исполнитель (список в строчку), 2: Мои заказы
  String _selectedCity = 'Артём';
  bool _executorAuto = true;
  bool _showAllRowsMenu = true;
  String? _selectedRowCategory;

  final List<String> _cities = ['Артём', 'Владивосток', 'Уссурийск', 'Находка', 'Большой Камень', 'Спасск-Дальний', 'Арсеньев', 'Партизанск'];

  final List<Map<String, dynamic>> _catalog = [
    {'title': 'Грузчики', 'rate': 700, 'max_qty': 30, 'icon': Icons.groups_rounded, 'items': ['Квартирный переезд', 'Офисный переезд', 'Разгрузка фур и контейнеров', 'Подъём стройматериалов']},
    {'title': 'Разнорабочие', 'rate': 650, 'max_qty': 30, 'icon': Icons.engineering_rounded, 'items': ['Помощь на стройке', 'Земельные работы', 'Уборка территории', 'Складские работы']},
    {'title': 'Тяжёлые работы', 'rate': 900, 'max_qty': 20, 'icon': Icons.fitness_center_rounded, 'items': ['Перенос пианино и роялей', 'Сейфы и банкоматы', 'Промышленные станки', 'Крупногабаритные грузы']},
    {'title': 'Универсалы', 'rate': 750, 'max_qty': 25, 'icon': Icons.handyman_rounded, 'items': ['Сборка и разборка мебели', 'Упаковка имущества', 'Мелкий бытовой ремонт', 'Демонтажные работы']},
    {'title': 'Грузовое такси', 'rate': 1400, 'max_qty': 10, 'icon': Icons.local_shipping_rounded, 'items': ['Бортовой грузовик 1.5т', 'Фургон / Будка 3т', 'Грузовик 5т с гидробортом', 'Рефрижератор']},
    {'title': 'Спецтехника', 'rate': 2500, 'max_qty': 10, 'icon': Icons.agriculture_rounded, 'items': ['Кран-борт / Манипулятор', 'Автовышка (14м–28м)', 'Мини-экскаватор', 'Самосвал', 'Автокран (16т–32т)', 'Буровая / Ямобур', 'Погрузчик / Бобкэт', 'Трал']},
    {'title': 'Интернет-мастер', 'rate': 1200, 'max_qty': 5, 'icon': Icons.router_rounded, 'items': ['Настройка Wi-Fi и роутеров', 'Прокладка и обжим кабеля', 'Видеонаблюдение', 'Настройка ТВ и приставок']},
  ];
  List<Map<String, dynamic>> _orders = [];
  bool _loading = false;

  Map<String, String> get _headers => {
        'apikey': kSupabaseKey,
        'Authorization': 'Bearer $kSupabaseKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      };

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    try {
      final req = await html.HttpRequest.request(
        '$kSupabaseUrl/rest/v1/orders?select=*&order=created_at.desc',
        method: 'GET',
        requestHeaders: _headers,
      );
      if (req.status == 200 && req.responseText != null && mounted) {
        setState(() => _orders = (jsonDecode(req.responseText!) as List).cast<Map<String, dynamic>>());
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _createOrder({required String service, required String subservice, required int qty, required int hours, required int price, required String address, required String phone, required String payment}) async {
    try {
      await html.HttpRequest.request(
        '$kSupabaseUrl/rest/v1/orders',
        method: 'POST',
        requestHeaders: _headers,
        sendData: jsonEncode({
          'city': _selectedCity,
          'service': '$service ($subservice)',
          'workers_count': qty,
          'hours': hours,
          'price': price,
          'address': address,
          'client_phone': phone,
          'payment_method': payment,
          'status': 'open',
        }),
      );
      await _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Заявка создана ($qty чел./ед.) • Набор закроется автоматически при заполнении!'), backgroundColor: const Color(0xFF16A34A)),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.isDark ? const Color(0xFF1F2937) : Colors.white,
        leading: _bottomTab == 1
            ? IconButton(
                tooltip: 'Все услуги в строчку',
                icon: Icon(_selectedRowCategory != null ? Icons.arrow_back_rounded : Icons.menu_rounded),
                onPressed: () => setState(() {
                  if (_selectedRowCategory != null) {
                    _selectedRowCategory = null;
                  } else {
                    _showAllRowsMenu = !_showAllRowsMenu;
                  }
                }),
              )
            : null,
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedCity,
            items: _cities.map((c) => DropdownMenuItem(value: c, child: Text('$c (${_orders.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedCity = v);
            },
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Дневная / Ночная тема',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.light_mode_rounded : Icons.contrast_rounded),
          ),
          if (_bottomTab == 1)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('AUTO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                selected: _executorAuto,
                selectedColor: const Color(0xFF16A34A),
                onSelected: (v) => setState(() => _executorAuto = v),
              ),
            ),
        ],
      ),
      body: _bottomTab == 0
          ? _buildClientGrid()
          : _bottomTab == 1
              ? _buildExecutorRows()
              : _buildMyOrdersTab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _bottomTab,
        onDestinationSelected: (i) => setState(() => _bottomTab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Заказчик'),
          NavigationDestination(icon: Icon(Icons.view_list_rounded), label: 'Исполнитель'),
          NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: 'Заказы'),
        ],
      ),
    );
  }
  Widget _buildClientGrid() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: widget.accent.withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
            child: const Text('Подача грузчиков, бригад до 30 чел. и спецтехники по Приморью за 30 минут!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.25),
              itemCount: _catalog.length,
              itemBuilder: (_, i) {
                final cat = _catalog[i];
                return InkWell(
                  onTap: () => _openCategorySubgrid(cat),
                  borderRadius: BorderRadius.circular(14),
                  child: Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(backgroundColor: widget.accent.withOpacity(0.2), radius: 22, child: Icon(cat['icon'] as IconData, color: widget.accent, size: 26)),
                          const SizedBox(height: 8),
                          Text(cat['title'] as String, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text('от ${cat['rate']} ₽/ч • до ${cat['max_qty']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openCategorySubgrid(Map<String, dynamic> cat) {
    final items = (cat['items'] as List).cast<String>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text('${cat['title']} • Выберите услугу')),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.25),
              itemCount: items.length,
              itemBuilder: (_, idx) => InkWell(
                onTap: () => _openOrderForm(cat, items[idx]),
                borderRadius: BorderRadius.circular(14),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(cat['icon'] as IconData, color: widget.accent, size: 30),
                        const SizedBox(height: 8),
                        Text(items[idx], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('${cat['rate']} ₽/час', style: TextStyle(color: widget.accent, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openOrderForm(Map<String, dynamic> cat, String subservice) {
    int qty = 2;
    int hours = 2;
    String payment = 'Наличные';
    final addressCtrl = TextEditingController(text: '$_selectedCity, ');
    final phoneCtrl = TextEditingController(text: '+7 (914) ');
    final maxQty = cat['max_qty'] as int;
    final rate = cat['rate'] as int;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${cat['title']}: $subservice', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('Количество человек / единиц (макс. $maxQty): $qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                Slider(value: qty.toDouble(), min: 1, max: maxQty.toDouble(), divisions: maxQty > 1 ? maxQty - 1 : 1, onChanged: (v) => setModal(() => qty = v.round())),
                Text('Часов работы: $hours', style: const TextStyle(fontWeight: FontWeight.bold)),
                Slider(value: hours.toDouble(), min: 1, max: 12, divisions: 11, onChanged: (v) => setModal(() => hours = v.round())),
                TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Адрес / Ворота / Кампус', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Ваш телефон', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: payment,
                  decoration: const InputDecoration(labelText: 'Способ оплаты', border: OutlineInputBorder()),
                  items: ['Наличные', 'Перевод СБП', 'По счёту (с Актом для юрлиц)'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) {
                    if (v != null) setModal(() => payment = v);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: widget.accent, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                      _createOrder(service: cat['title'] as String, subservice: subservice, qty: qty, hours: hours, price: qty * hours * rate, address: addressCtrl.text, phone: phoneCtrl.text, payment: payment);
                    },
                    child: Text('Оформить заявку • ${qty * hours * rate} ₽', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildExecutorRows() {
    final rowCategories = [
      {'title': 'Ближайшие ($_selectedCity)', 'filter': ''},
      {'title': 'Межгород (Приморский край)', 'filter': 'Межгород'},
      ..._catalog.map((c) => {'title': c['title'] as String, 'filter': c['title'] as String}),
    ];

    if (_selectedRowCategory != null) {
      final cat = _catalog.firstWhere((c) => c['title'] == _selectedRowCategory, orElse: () => {});
      final subItems = cat.isNotEmpty ? (cat['items'] as List).cast<String>() : <String>[];
      final filteredOrders = _orders.where((o) => (o['service'] ?? '').toString().contains(_selectedRowCategory!)).toList();

      return ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: widget.accent.withOpacity(0.15),
            child: Text('$_selectedRowCategory • Все позиции в строчку (${filteredOrders.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (final sub in subItems) ...[
            ListTile(
              leading: Container(width: 4, height: 24, color: widget.accent),
              title: Text(sub, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: Text('${_orders.where((o) => (o['service'] ?? '').toString().contains(sub)).length}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const Divider(height: 1),
          ],
          for (final o in filteredOrders)
            ListTile(
              leading: const Icon(Icons.flash_on_rounded, color: Colors.amber),
              title: Text('${o['service']} • ${o['price']} ₽', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${o['city']} • ${o['address']} • ${o['payment_method']}'),
              trailing: FilledButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Запрос на заказ отправлен диспетчеру!'))), child: const Text('Взять')),
            ),
        ],
      );
    }

    return ListView(
      children: [
        if (_showAllRowsMenu) ...[
          for (final rc in rowCategories) ...[
            ListTile(
              leading: Container(width: 4, height: 24, color: widget.accent),
              title: Text(rc['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: Text(
                '${rc['filter']!.isEmpty ? _orders.length : _orders.where((o) => (o['service'] ?? '').toString().contains(rc['filter']!)).length}',
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onTap: () {
                if (_catalog.any((c) => c['title'] == rc['filter'])) {
                  setState(() => _selectedRowCategory = rc['filter']);
                }
              },
            ),
            const Divider(height: 1),
          ],
        ],
        for (final o in _orders) ...[
          ListTile(
            leading: const Icon(Icons.flash_on_rounded, color: Colors.amber),
            title: Text('${o['service'] ?? 'Заказ'} (${o['workers_count'] ?? 1} чел.) • ${o['price'] ?? 0} ₽', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${o['city'] ?? ''} • ${o['address'] ?? ''} • ${o['payment_method'] ?? ''}'),
            trailing: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: widget.accent, foregroundColor: Colors.black),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Вы откликнулись на заявку!'))),
              child: const Text('Запросить'),
            ),
          ),
          const Divider(height: 1),
        ],
      ],
    );
  }

  Widget _buildMyOrdersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text('Активные заявки (${_orders.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              OutlinedButton.icon(onPressed: _loadOrders, icon: const Icon(Icons.refresh_rounded), label: const Text('Обновить')),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
                  ? const Center(child: Text('Активных заявок пока нет'))
                  : ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (_, i) {
                        final o = _orders[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: ListTile(
                            title: Text('${o['service']} — ${o['price']} ₽', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${o['city']} • ${o['address']} • ${o['payment_method']}'),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
