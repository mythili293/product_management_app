import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/purchase.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  int? _editingLabIndex;
  bool _darkMode = false;
  bool _sortLabsAz = false;
  bool _sortTrackingNewest = false;
  bool _sortCategoriesAz = false;
  int _labPage = 0;
  int _categoryPage = 0;
  int _trackingPage = 0;
  static const int _pageSize = 4;
  String _trackingLabFilter = 'All Labs';
  String _trackingStatusFilter = 'All';
  String _detailTitle = '';
  final TextEditingController _globalSearchController = TextEditingController();
  final TextEditingController _trackingSearchController =
      TextEditingController();
  final TextEditingController _labSearchController = TextEditingController();
  final TextEditingController _categorySearchController =
      TextEditingController();
  final TextEditingController _labNameController = TextEditingController();
  final TextEditingController _responsiblePersonController =
      TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _labTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _machineCountController = TextEditingController();
  final TextEditingController _staffCountController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  StreamSubscription<List<Purchase>>? _trackingSubscription;
  bool _trackingLoading = true;
  String? _trackingError;

  final List<_NavItem> _navItems = const [
    _NavItem('Overview', Icons.dashboard_outlined),
    _NavItem('Lab Management', Icons.science_outlined),
    _NavItem('Item Categories', Icons.category_outlined),
    _NavItem('Item History', Icons.history_outlined),
    _NavItem('Admin Members', Icons.admin_panel_settings_outlined),
    _NavItem('Settings', Icons.settings_outlined),
  ];

  final List<Map<String, dynamic>> _adminMembers = const [
    {
      'name': 'Giri Sir',
      'phone': '98432 67510',
      'role': 'Super Admin',
      'status': 'Active',
      'lastLogin': 'Today 09:30 AM',
    },
    {
      'name': 'Prakash Sir',
      'phone': '98765 43210',
      'role': 'Lab Admin',
      'status': 'Active',
      'lastLogin': 'Today 08:45 AM',
    },
    {
      'name': 'Tom Sir',
      'phone': '91234 56780',
      'role': 'Inventory Admin',
      'status': 'Active',
      'lastLogin': 'Yesterday 05:20 PM',
    },
    {
      'name': 'Arjun Sir',
      'phone': '90000 12345',
      'role': 'Report Admin',
      'status': 'Active',
      'lastLogin': 'Monday 11:10 AM',
    },
  ];

  final List<Map<String, dynamic>> _labs = [
    {
      'no': 'LAB-001',
      'name': 'Hydrostatic Lab',
      'person': 'Giri Sir',
      'phone': '98432 67510',
      'status': 'Active',
      'machines': 42,
      'staff': 8,
    },
    {
      'no': 'LAB-002',
      'name': 'Pump Lab',
      'person': 'Prakash Sir',
      'phone': '98765 43210',
      'status': 'Active',
      'machines': 36,
      'staff': 7,
    },
    {
      'no': 'LAB-003',
      'name': 'Aroma Lab',
      'person': 'Tom Sir',
      'phone': '91234 56780',
      'status': 'Inactive',
      'machines': 18,
      'staff': 4,
    },
    {
      'no': 'LAB-004',
      'name': 'Heat Exchange Lab',
      'person': 'Arjun Sir',
      'phone': '90000 12345',
      'status': 'Active',
      'machines': 51,
      'staff': 9,
    },
  ];

  @override
  void initState() {
    super.initState();
    _trackingSubscription = _databaseService.getAllPurchases().listen(
      (purchases) {
        if (!mounted) return;
        setState(() {
          _trackingItems = purchases
              .asMap()
              .entries
              .map((entry) => _purchaseToTrackingItem(entry.value, entry.key))
              .toList();
          _trackingLoading = false;
          _trackingError = null;
          if (!_trackingLabOptions.contains(_trackingLabFilter)) {
            _trackingLabFilter = 'All Labs';
          }
          _resetPages();
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _trackingLoading = false;
          _trackingError = error.toString();
          _trackingItems = [];
          _resetPages();
        });
      },
    );
  }

  @override
  void dispose() {
    _trackingSubscription?.cancel();
    _globalSearchController.dispose();
    _trackingSearchController.dispose();
    _labSearchController.dispose();
    _categorySearchController.dispose();
    _labNameController.dispose();
    _responsiblePersonController.dispose();
    _contactController.dispose();
    _labTypeController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _machineCountController.dispose();
    _staffCountController.dispose();
    super.dispose();
  }

  int get _activeLabCount =>
      _labs.where((lab) => lab['status'] == 'Active').length;

  int get _totalMachines =>
      _labs.fold<int>(0, (total, lab) => total + (lab['machines'] as int));

  int get _totalStaff =>
      _labs.fold<int>(0, (total, lab) => total + (lab['staff'] as int));

  List<Map<String, dynamic>> get _filteredLabs {
    final query = [
      _globalSearchController.text,
      _labSearchController.text,
    ].join(' ').trim().toLowerCase();

    final labs = _labs.where((lab) {
      final searchable = [
        lab['no'],
        lab['name'],
        lab['person'],
        lab['phone'],
        lab['type'] ?? '',
        lab['location'] ?? '',
      ].join(' ').toLowerCase();
      final queryMatches = query.isEmpty || searchable.contains(query);
      return queryMatches;
    }).toList();

    if (_sortLabsAz) {
      labs.sort(
        (first, second) =>
            first['name'].toString().compareTo(second['name'].toString()),
      );
    }
    return labs;
  }

  List<Map<String, dynamic>> get _visibleLabs =>
      _pageSlice(_filteredLabs, _labPage);

  List<Map<String, dynamic>> get _filteredTrackingItems {
    final items = _trackingFilterBaseItems.where((item) {
      final statusMatches =
          _trackingStatusFilter == 'All' ||
          _deadlineStatusLabel(item) == _trackingStatusFilter;
      return statusMatches;
    }).toList();

    if (_sortTrackingNewest) {
      items.sort((first, second) => second['no'].compareTo(first['no']));
    }
    return items;
  }

  List<Map<String, dynamic>> get _trackingFilterBaseItems {
    final query = [
      _globalSearchController.text,
      _trackingSearchController.text,
    ].join(' ').trim().toLowerCase();

    final activeLabFilter = _activeTrackingLabFilter;
    return _trackingItems.where((item) {
      final labMatches =
          activeLabFilter == 'All Labs' || item['lab'] == activeLabFilter;
      final searchable = [
        item['person'],
        item['phone'],
        item['email'],
        item['item'],
        item['itemNo'],
        item['lab'],
        _deadlineStatusLabel(item),
      ].join(' ').toLowerCase();
      final queryMatches = query.isEmpty || searchable.contains(query);
      return labMatches && queryMatches;
    }).toList();
  }

  List<Map<String, dynamic>> get _visibleTrackingItems =>
      _pageSlice(_filteredTrackingItems, _trackingPage);

  int _trackingStatusCount(String status) => _trackingFilterBaseItems
      .where((item) => _deadlineStatusLabel(item) == status)
      .length;

  int get _activeTrackingCount => _trackingItems
      .where((item) => _deadlineStatusLabel(item) != 'Returned')
      .length;

  List<String> get _trackingLabOptions {
    final labs =
        _trackingItems
            .map((item) => '${item['lab'] ?? ''}'.trim())
            .where((lab) => lab.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['All Labs', ...labs];
  }

  String get _activeTrackingLabFilter =>
      _trackingLabOptions.contains(_trackingLabFilter)
      ? _trackingLabFilter
      : 'All Labs';

  String get _historyUpdatedText {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return 'Updated now, $hour:$minute $period';
  }

  List<Map<String, dynamic>> get _filteredCategories {
    final query = _categorySearchController.text.trim().toLowerCase();
    final categories = _categories.where((category) {
      final queryMatches =
          query.isEmpty ||
          category['name'].toString().toLowerCase().contains(query);
      return queryMatches;
    }).toList();

    if (_sortCategoriesAz) {
      categories.sort(
        (first, second) =>
            first['name'].toString().compareTo(second['name'].toString()),
      );
    }
    return categories;
  }

  List<Map<String, dynamic>> get _visibleCategories =>
      _pageSlice(_filteredCategories, _categoryPage);

  List<Map<String, dynamic>> _pageSlice(
    List<Map<String, dynamic>> source,
    int page,
  ) {
    final start = page * _pageSize;
    if (start >= source.length) return source.take(_pageSize).toList();
    final end = (start + _pageSize).clamp(0, source.length);
    return source.sublist(start, end);
  }

  final List<Map<String, dynamic>> _categories = [
    {'no': 1, 'name': 'Mechanical Items', 'items': 32, 'status': 'Active'},
    {'no': 2, 'name': 'Electric Items', 'items': 28, 'status': 'Active'},
    {'no': 3, 'name': 'Electronic Items', 'items': 35, 'status': 'Active'},
    {'no': 4, 'name': 'Testing Instruments', 'items': 30, 'status': 'Active'},
    {'no': 5, 'name': 'Calibration Tools', 'items': 50, 'status': 'Active'},
    {'no': 6, 'name': 'General Tools', 'items': 12, 'status': 'Active'},
  ];

  final List<Map<String, dynamic>> _categoryItems = const [
    {'name': 'Flow Meter', 'status': 'Available', 'color': Color(0xFF16A34A)},
    {'name': 'Spanner Set', 'status': 'Issued', 'color': Color(0xFFF59E0B)},
    {'name': 'Hand Pump', 'status': 'Available', 'color': Color(0xFF16A34A)},
    {'name': 'Pressure Gauge', 'status': 'Overdue', 'color': Color(0xFFDC2626)},
    {'name': 'Valve', 'status': 'Available', 'color': Color(0xFF16A34A)},
  ];

  List<Map<String, dynamic>> _trackingItems = [];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 980;
    final background = _darkMode
        ? const Color(0xFF0F172A)
        : const Color(0xFFF6F8FB);

    return Theme(
      data: AppTheme.lightTheme.copyWith(
        scaffoldBackgroundColor: background,
        textTheme: GoogleFonts.interTextTheme(AppTheme.lightTheme.textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryBlue,
          brightness: _darkMode ? Brightness.dark : Brightness.light,
        ),
        inputDecorationTheme: _inputTheme(),
      ),
      child: Scaffold(
        backgroundColor: background,
        drawer: isWide ? null : Drawer(child: _buildSidebar(compact: false)),
        body: SafeArea(
          child: Row(
            children: [
              if (isWide) _buildSidebar(compact: false),
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(isWide),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isWide ? 24 : 16),
                        child: _buildSelectedPage(isWide),
                      ),
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

  Widget _buildSelectedPage(bool isWide) {
    switch (_selectedIndex) {
      case 1:
        return _buildLabManagement(isWide);
      case 2:
        return _buildCategoryManagement(isWide);
      case 3:
        return _buildTrackingManagement(isWide);
      case 4:
        return _buildAdminMembers(isWide);
      case 5:
        return _buildSettings();
      case 6:
        return _buildMetricDetails(isWide);
      case 7:
        return _buildAddLabForm();
      default:
        return _buildOverview(isWide);
    }
  }

  Widget _buildSidebar({required bool compact}) {
    return Container(
      width: 260,
      color: _surfaceColor(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.biotech_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _text('Lab Admin', 18, FontWeight.w800),
                      _mutedText('Inventory ERP', 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _mutedText('ADMIN MODULES', 11),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final selected = _selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? _selectedNavColor()
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            color: selected
                                ? AppTheme.primaryBlue
                                : _mutedColor(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.label,
                              style: GoogleFonts.inter(
                                color: selected
                                    ? AppTheme.primaryBlue
                                    : _textColor(),
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () =>
                  Provider.of<AuthProvider>(context, listen: false).signOut(),
              icon: const Icon(Icons.logout_outlined),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isWide) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 12, vertical: 14),
      color: _surfaceColor(),
      child: Row(
        children: [
          if (!isWide)
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu),
              ),
            ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: TextField(
                controller: _globalSearchController,
                onChanged: (_) => setState(_resetPages),
                decoration: InputDecoration(
                  hintText: 'Search labs, people, items, modules...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _globalSearchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _globalSearchController.clear();
                            setState(_resetPages);
                          },
                          icon: const Icon(Icons.close),
                        ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  filled: true,
                  fillColor: _surfaceAltColor(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Dark mode',
            onPressed: () => setState(() => _darkMode = !_darkMode),
            icon: Icon(
              _darkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFEFF6FF),
            child: Icon(Icons.person_outline, color: AppTheme.primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageTitle(
          'Admin Dashboard',
          'Quick view of labs, categories, issued items, and overdue assets.',
        ),
        const SizedBox(height: 20),
        _summaryGrid([
          _SummaryData(
            'Total Labs',
            '${_labs.length}',
            Icons.science_outlined,
            const Color(0xFFEFF6FF),
            AppTheme.primaryBlue,
            detailIndex: 6,
          ),
          _SummaryData(
            'Active Labs',
            '$_activeLabCount',
            Icons.check_circle_outline,
            const Color(0xFFF0FDF4),
            const Color(0xFF16A34A),
            detailIndex: 6,
          ),
          _SummaryData(
            'Total Machines',
            '$_totalMachines',
            Icons.precision_manufacturing_outlined,
            const Color(0xFFFFF7ED),
            const Color(0xFFF97316),
            detailIndex: 6,
          ),
          _SummaryData(
            'Total Staff',
            '$_totalStaff',
            Icons.groups_2_outlined,
            const Color(0xFFFAF5FF),
            const Color(0xFF9333EA),
            detailIndex: 6,
          ),
        ], isWide),
        const SizedBox(height: 20),
        _sectionHeader(
          'Modules',
          'Open each admin area from one organized place.',
        ),
        const SizedBox(height: 12),
        _moduleGrid(isWide),
        const SizedBox(height: 20),
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildRecentActivityCard()),
                  const SizedBox(width: 20),
                  Expanded(child: _buildAdminAccessCard()),
                ],
              )
            : Column(
                children: [
                  _buildRecentActivityCard(),
                  const SizedBox(height: 16),
                  _buildAdminAccessCard(),
                ],
              ),
        const SizedBox(height: 20),
        _pageControls(),
      ],
    );
  }

  Widget _buildLabManagement(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageTitle(
          'Lab Management',
          'Create, monitor, and manage laboratory ownership details.',
        ),
        const SizedBox(height: 20),
        _summaryGrid([
          _SummaryData(
            'Total Labs',
            '${_labs.length}',
            Icons.science_outlined,
            const Color(0xFFEFF6FF),
            AppTheme.primaryBlue,
            detailIndex: 6,
          ),
          _SummaryData(
            'Active Labs',
            '$_activeLabCount',
            Icons.check_circle_outline,
            const Color(0xFFF0FDF4),
            const Color(0xFF16A34A),
            detailIndex: 6,
          ),
          _SummaryData(
            'Total Machines',
            '$_totalMachines',
            Icons.precision_manufacturing_outlined,
            const Color(0xFFFFF7ED),
            const Color(0xFFF97316),
            detailIndex: 6,
          ),
          _SummaryData(
            'Total Staff',
            '$_totalStaff',
            Icons.groups_2_outlined,
            const Color(0xFFFAF5FF),
            const Color(0xFF9333EA),
            detailIndex: 6,
          ),
        ], isWide),
        const SizedBox(height: 20),
        _sectionCard(
          child: Column(
            children: [
              _labToolbar(isWide),
              const SizedBox(height: 16),
              _filteredLabs.isEmpty
                  ? _emptyState(
                      'No labs found',
                      'Try clearing search or selecting All Labs.',
                    )
                  : isWide
                  ? _buildLabTable()
                  : _buildLabCards(),
              _pagination(
                totalRecords: _filteredLabs.length,
                currentPage: _labPage,
                onPrevious: () => setState(() {
                  if (_labPage > 0) _labPage--;
                }),
                onNext: () => setState(() {
                  if ((_labPage + 1) * _pageSize < _filteredLabs.length) {
                    _labPage++;
                  }
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _pageControls(),
      ],
    );
  }

  Widget _buildCategoryManagement(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageTitle(
          'Item Category Management',
          'Manage category masters and inspect items grouped inside each category.',
        ),
        const SizedBox(height: 20),
        _summaryGrid([
          _SummaryData(
            'Total Categories',
            '60',
            Icons.category_outlined,
            const Color(0xFFEFF6FF),
            AppTheme.primaryBlue,
          ),
          _SummaryData(
            'Active Categories',
            '60',
            Icons.verified_outlined,
            const Color(0xFFF0FDF4),
            const Color(0xFF16A34A),
          ),
          _SummaryData(
            'Total Items',
            '350',
            Icons.inventory_2_outlined,
            const Color(0xFFFFF7ED),
            const Color(0xFFF97316),
          ),
          _SummaryData(
            'Last Updated',
            '10:45 AM',
            Icons.update_outlined,
            const Color(0xFFF1F5F9),
            const Color(0xFF475569),
          ),
        ], isWide),
        const SizedBox(height: 20),
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildCategoryList(isWide)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildCategoryDetail()),
                ],
              )
            : Column(
                children: [
                  _buildCategoryList(isWide),
                  const SizedBox(height: 16),
                  _buildCategoryDetail(),
                ],
              ),
        const SizedBox(height: 20),
        _pageControls(),
      ],
    );
  }

  Widget _buildTrackingManagement(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _pageTitle(
                      'Item Status & History',
                      'Track safe, due-near, overdue, returned, and currently issued items.',
                    ),
                  ),
                  const SizedBox(width: 12),
                  _historyUpdatedPill(),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pageTitle(
                    'Item Status & History',
                    'Track safe, due-near, overdue, returned, and currently issued items.',
                  ),
                  const SizedBox(height: 12),
                  _historyUpdatedPill(),
                ],
              ),
        const SizedBox(height: 20),
        _summaryGrid([
          _SummaryData(
            'Safe Items',
            '${_trackingItems.where((item) => _deadlineStatusLabel(item) == 'Safe').length}',
            Icons.check_circle_outline,
            const Color(0xFFF0FDF4),
            const Color(0xFF16A34A),
            subtitle: 'Within return period',
          ),
          _SummaryData(
            'Due Near',
            '${_trackingItems.where((item) => _deadlineStatusLabel(item) == 'Due Near').length}',
            Icons.error_outline,
            const Color(0xFFFFFBEB),
            const Color(0xFFF59E0B),
            subtitle: 'Return approaching',
          ),
          _SummaryData(
            'Overdue',
            '${_trackingItems.where((item) => _deadlineStatusLabel(item) == 'Overdue').length}',
            Icons.warning_amber_rounded,
            const Color(0xFFFEF2F2),
            const Color(0xFFDC2626),
            subtitle: 'Past return date',
          ),
          _SummaryData(
            'Total Issued',
            '$_activeTrackingCount',
            Icons.outbox_outlined,
            const Color(0xFFEFF6FF),
            AppTheme.primaryBlue,
            subtitle: _historyUpdatedText,
          ),
        ], isWide),
        const SizedBox(height: 20),
        _sectionCard(
          child: Column(
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: isWide ? 320 : double.infinity,
                    child: _searchBox(
                      'Search item history...',
                      controller: _trackingSearchController,
                      onChanged: (_) => setState(() => _trackingPage = 0),
                    ),
                  ),
                  _dropdown(
                    _activeTrackingLabFilter,
                    _trackingLabOptions,
                    (value) => setState(() {
                      _trackingLabFilter = value;
                      _trackingPage = 0;
                    }),
                  ),
                  _smallButton(
                    Icons.sort_outlined,
                    _sortTrackingNewest ? 'Newest First' : 'Sort',
                    onPressed: () => setState(() {
                      _sortTrackingNewest = !_sortTrackingNewest;
                      _trackingPage = 0;
                    }),
                  ),
                  _smallButton(
                    Icons.download_outlined,
                    'Export',
                    onPressed: () => _showMessage(
                      'CSV export prepared for ${_filteredTrackingItems.length} records.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _trackingStatusFilters(),
              const SizedBox(height: 16),
              if (_trackingLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_trackingError != null)
                _emptyState(
                  'Unable to load history',
                  'Supabase returned: $_trackingError',
                )
              else if (_filteredTrackingItems.isEmpty)
                _emptyState(
                  'No history records found',
                  'Issue an item from the user page or adjust the filters.',
                )
              else ...[
                isWide ? _buildTrackingTable() : _buildTrackingCards(),
                _pagination(
                  totalRecords: _filteredTrackingItems.length,
                  currentPage: _trackingPage,
                  onPrevious: () => setState(() {
                    if (_trackingPage > 0) _trackingPage--;
                  }),
                  onNext: () => setState(() {
                    if ((_trackingPage + 1) * _pageSize <
                        _filteredTrackingItems.length) {
                      _trackingPage++;
                    }
                  }),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        _pageControls(),
      ],
    );
  }

  Widget _buildAdminMembers(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageTitle(
          'Admin Members',
          'Manage the four approved admin members and their phone based access.',
        ),
        const SizedBox(height: 20),
        _summaryGrid([
          _SummaryData(
            'Total Admins',
            '4',
            Icons.admin_panel_settings_outlined,
            const Color(0xFFEFF6FF),
            AppTheme.primaryBlue,
          ),
          _SummaryData(
            'Active Admins',
            '4',
            Icons.verified_user_outlined,
            const Color(0xFFF0FDF4),
            const Color(0xFF16A34A),
          ),
          _SummaryData(
            'Phone Signup',
            'Enabled',
            Icons.phone_android_outlined,
            const Color(0xFFFFF7ED),
            const Color(0xFFF97316),
          ),
          _SummaryData(
            'Pending Review',
            '0',
            Icons.pending_actions_outlined,
            const Color(0xFFF1F5F9),
            const Color(0xFF475569),
          ),
        ], isWide),
        const SizedBox(height: 20),
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(
                'Approved Admin List',
                'Only these registered phone numbers should receive admin access.',
              ),
              const SizedBox(height: 16),
              isWide ? _buildAdminTable() : _buildAdminCards(),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _pageControls(),
      ],
    );
  }

  Widget _buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageTitle(
          'Settings',
          'Configure return rules, dashboard preferences, and tracking behavior.',
        ),
        const SizedBox(height: 20),
        _sectionCard(
          child: Column(
            children: [
              _settingsTile(
                Icons.schedule_outlined,
                'Return alert rule',
                'Safe: 0-7 days, Due Near: 8-10 days, Overdue: 10+ days',
              ),
              _settingsTile(
                Icons.photo_camera_outlined,
                'Issue photo proof',
                'Allow image attachment when an item is issued to another lab.',
              ),
              _settingsTile(
                Icons.inventory_2_outlined,
                'Movable item tracking',
                'Only movable lab items should appear in issue and return workflows.',
              ),
              _settingsTile(
                Icons.dark_mode_outlined,
                'Theme',
                _darkMode
                    ? 'Dark mode is currently enabled.'
                    : 'Light mode is currently enabled.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _pageControls(),
      ],
    );
  }

  Widget _buildMetricDetails(bool isWide) {
    final title = _detailTitle.isEmpty ? 'Total Labs' : _detailTitle;
    final detailLabs = title == 'Active Labs'
        ? _labs.where((lab) => lab['status'] == 'Active').toList()
        : _labs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageTitle(
          title,
          'Detailed information connected to the selected dashboard card.',
        ),
        const SizedBox(height: 20),
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(
                title == 'Total Machines' || title == 'Total Staff'
                    ? 'Lab-wise Breakdown'
                    : 'Lab Details',
                'Click Lab Management for full filtering, editing, and actions.',
              ),
              const SizedBox(height: 16),
              ...detailLabs.map((lab) {
                final value = title == 'Total Machines'
                    ? '${lab['machines']} machines'
                    : title == 'Total Staff'
                    ? '${lab['staff']} staff'
                    : '${lab['person']} - ${lab['phone']}';
                return _detailTile(
                  lab['name'],
                  value,
                  lab['status'],
                  Icons.science_outlined,
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _pageControls(),
      ],
    );
  }

  Widget _buildAddLabForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageTitle(
          _editingLabIndex == null ? 'Add New Lab' : 'Edit Lab',
          _editingLabIndex == null
              ? 'Enter complete lab ownership, contact, type, and inventory details.'
              : 'Update lab ownership, contact, type, and inventory details.',
        ),
        const SizedBox(height: 20),
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(
                'Lab Information',
                'All fields are used in search, cards, and lab reports.',
              ),
              const SizedBox(height: 18),
              _formGrid([
                _formField(
                  _labNameController,
                  'Lab Name',
                  Icons.science_outlined,
                ),
                _formField(
                  _responsiblePersonController,
                  'Responsible Person',
                  Icons.person_outline,
                ),
                _formField(
                  _contactController,
                  'Contact Details',
                  Icons.phone_outlined,
                ),
                _formField(
                  _labTypeController,
                  'Lab Type',
                  Icons.category_outlined,
                ),
                _formField(
                  _locationController,
                  'Location',
                  Icons.location_on_outlined,
                ),
                _formField(
                  _machineCountController,
                  'Total Machines',
                  Icons.precision_manufacturing_outlined,
                  number: true,
                ),
                _formField(
                  _staffCountController,
                  'Total Staff',
                  Icons.groups_2_outlined,
                  number: true,
                ),
              ]),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText:
                      'Purpose, instruments handled, calibration notes, or special remarks',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: _saveLab,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      _editingLabIndex == null ? 'Save Lab' : 'Update Lab',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      _clearLabForm();
                      setState(() {
                        _editingLabIndex = null;
                        _selectedIndex = 1;
                      });
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                    style: _outlineButtonStyle(),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _pageControls(),
      ],
    );
  }

  Widget _moduleGrid(bool isWide) {
    final modules = [
      _ModuleData(
        'Lab Management',
        'Labs, responsible persons, contact numbers, status and actions.',
        Icons.science_outlined,
        1,
        AppTheme.primaryBlue,
      ),
      _ModuleData(
        'Item Categories',
        'Mechanical, electrical, electronic, tools and category item lists.',
        Icons.category_outlined,
        2,
        const Color(0xFF16A34A),
      ),
      _ModuleData(
        'Item History',
        'Safe, due-near, overdue, return status, image proof and activity logs.',
        Icons.history_outlined,
        3,
        const Color(0xFFF97316),
      ),
      _ModuleData(
        'Admin Members',
        'Four admin members, phone signup access and permission readiness.',
        Icons.admin_panel_settings_outlined,
        4,
        const Color(0xFF7C3AED),
      ),
      _ModuleData(
        'Settings',
        'Return day rules, attachment options and tracking configuration.',
        Icons.settings_outlined,
        5,
        const Color(0xFF475569),
      ),
    ];

    final query = _globalSearchController.text.trim().toLowerCase();
    final visibleModules = query.isEmpty
        ? modules
        : modules
              .where(
                (module) =>
                    module.title.toLowerCase().contains(query) ||
                    module.description.toLowerCase().contains(query),
              )
              .toList();

    if (visibleModules.isEmpty) {
      return _emptyState(
        'No modules found',
        'Try searching for lab, category, history, admin, or settings.',
      );
    }

    return _responsiveWrap(
      minItemWidth: 300,
      spacing: 16,
      children: visibleModules.map(_moduleCard).toList(),
    );
  }

  Widget _moduleCard(_ModuleData module) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => setState(() => _selectedIndex = module.index),
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: module.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(module.icon, color: module.color),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16, color: _mutedColor()),
              ],
            ),
            const SizedBox(height: 14),
            _text(module.title, 16, FontWeight.w800),
            const SizedBox(height: 8),
            _mutedText(module.description, 12),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Recent Activity',
            'Latest issue and tracking updates.',
          ),
          const SizedBox(height: 14),
          if (_trackingLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_trackingError != null)
            _mutedText('Unable to load recent activity from Supabase.', 13)
          else if (_trackingItems.isEmpty)
            _mutedText('No issue activity yet.', 13)
          else
            ..._trackingItems.take(3).map((item) {
              final status = _deadlineStatusLabel(item);
              final activity = status == 'Returned'
                  ? '${item['item']} returned'
                  : '${item['item']} issued to ${item['lab']}';
              return _activityTile(
                activity,
                '${item['person']} - ${_deadlineDaysText(item)}',
                status,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAdminAccessCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Access Setup',
            'Phone signup is ready for approved admins.',
          ),
          const SizedBox(height: 14),
          ..._adminMembers
              .take(4)
              .map(
                (admin) => _activityTile(
                  admin['name'],
                  admin['phone'],
                  admin['status'],
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(bool isWide) {
    return _sectionCard(
      child: Column(
        children: [
          _categoryToolbar(isWide),
          const SizedBox(height: 16),
          _filteredCategories.isEmpty
              ? _emptyState(
                  'No categories found',
                  'Try clearing the search field.',
                )
              : isWide
              ? _buildCategoryTable()
              : _buildCategoryCards(),
          _pagination(
            totalRecords: _filteredCategories.length,
            currentPage: _categoryPage,
            onPrevious: () => setState(() {
              if (_categoryPage > 0) _categoryPage--;
            }),
            onNext: () => setState(() {
              if ((_categoryPage + 1) * _pageSize <
                  _filteredCategories.length) {
                _categoryPage++;
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDetail() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _text('Selected Category', 18, FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          _mutedText('Mechanical Items', 14),
          const SizedBox(height: 20),
          _text('Items in this Category', 14, FontWeight.w700),
          const SizedBox(height: 12),
          ..._categoryItems.map((item) => _categoryItemTile(item)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _selectedIndex = 2),
              icon: const Icon(Icons.open_in_new_outlined),
              label: const Text('View All Items'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabTable() {
    return _dataTable(
      columns: const [
        'Lab No',
        'Lab Name',
        'Responsible Person',
        'Contact Number',
        'Actions',
      ],
      columnWidths: const [110, 230, 210, 170, 120],
      rows: _visibleLabs.map((lab) {
        return DataRow(
          cells: [
            DataCell(_tableText(lab['no'], width: 110, strong: true)),
            DataCell(_tableText(lab['name'], width: 230, strong: true)),
            DataCell(_tableText(lab['person'], width: 210)),
            DataCell(_tableText(lab['phone'], width: 170)),
            DataCell(
              _actionRow(
                showReturned: false,
                onView: () => _openLabDetails(lab),
                onEdit: () => _editLab(lab),
                onDelete: () => _deleteLab(lab),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCategoryTable() {
    return _dataTable(
      columns: const ['No', 'Category Name', 'Total Items', 'Actions'],
      columnWidths: const [80, 280, 150, 120],
      rows: _visibleCategories.map((category) {
        return DataRow(
          cells: [
            DataCell(_tableText('${category['no']}', width: 80)),
            DataCell(_tableText(category['name'], width: 280, strong: true)),
            DataCell(_tableText('${category['items']} Items', width: 150)),
            DataCell(
              _actionRow(
                showReturned: false,
                onView: () => _openCategoryDetails(category),
                onEdit: () => _renameCategory(category),
                onDelete: () => _deleteCategory(category),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTrackingTable() {
    return _dataTable(
      columns: const [
        'No',
        'Person Name',
        'Contact Info',
        'Item Name / Item No',
        'Lab / Location',
        'Issued Date',
        'Return Due Date',
        'Days',
        'Status',
        'Actions',
      ],
      columnWidths: const [70, 150, 210, 220, 170, 130, 150, 110, 120, 130],
      rows: _visibleTrackingItems.map((item) {
        final deadlineLabel = _deadlineStatusLabel(item);
        return DataRow(
          color: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return _deadlineHoverColor(deadlineLabel);
            }
            return _deadlineRowColor(deadlineLabel);
          }),
          cells: [
            DataCell(_rowIndicatorCell('${item['no']}', deadlineLabel)),
            DataCell(_tableText(item['person'], width: 150, strong: true)),
            DataCell(
              SizedBox(
                width: 210,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _tableText(item['phone'], width: 210, strong: true),
                    _mutedText(item['email'], 11),
                  ],
                ),
              ),
            ),
            DataCell(_itemNameWithNumberCell(item)),
            DataCell(_tableText(item['lab'], width: 170)),
            DataCell(_tableText(item['issued'], width: 130)),
            DataCell(_tableText(item['due'], width: 150)),
            DataCell(_tableText(_deadlineDaysText(item), width: 110)),
            DataCell(_deadlineBadge(deadlineLabel)),
            DataCell(
              _actionRow(
                showReturned: true,
                onView: () => _openDetails(item),
                onEdit: () => _openDetails(item),
                onReturned: () {
                  _markReturned(item);
                },
                onDelete: () {
                  _deleteTrackingItem(item);
                },
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAdminTable() {
    return _dataTable(
      columns: const [
        'Admin Name',
        'Phone Number',
        'Role',
        'Last Login',
        'Actions',
      ],
      columnWidths: const [200, 170, 190, 190, 130],
      rows: _adminMembers.map((admin) {
        return DataRow(
          cells: [
            DataCell(_tableText(admin['name'], width: 200, strong: true)),
            DataCell(_tableText(admin['phone'], width: 170)),
            DataCell(_tableText(admin['role'], width: 190)),
            DataCell(_tableText(admin['lastLogin'], width: 190)),
            DataCell(
              _actionRow(
                showReturned: false,
                onView: () => _showMessage('Admin profile opened.'),
                onEdit: () => _showMessage(
                  'Admin permissions can be edited from settings.',
                ),
                onDelete: () =>
                    _showMessage('Admin delete requires owner approval.'),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _dataTable({
    required List<String> columns,
    required List<DataRow> rows,
    List<double>? columnWidths,
  }) {
    final widths = columnWidths ?? List<double>.filled(columns.length, 150);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: _surfaceColor(),
          border: Border.all(color: _borderColor()),
          borderRadius: BorderRadius.circular(14),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(_tableHeaderColor()),
            dataRowColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return _darkMode
                    ? const Color(0xFF243044)
                    : const Color(0xFFEFF6FF);
              }
              return _surfaceColor();
            }),
            dataRowMinHeight: 64,
            dataRowMaxHeight: 72,
            headingRowHeight: 52,
            horizontalMargin: 18,
            columnSpacing: 18,
            dividerThickness: 0.7,
            columns: columns.asMap().entries.map((entry) {
              final index = entry.key;
              final label = entry.value;
              return DataColumn(
                label: SizedBox(
                  width: widths[index],
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w900,
                      color: _textColor(),
                    ),
                  ),
                ),
              );
            }).toList(),
            rows: rows,
          ),
        ),
      ),
    );
  }

  Widget _tableText(String text, {required double width, bool strong = false}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: _textColor(),
          fontSize: 13,
          fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    );
  }

  Widget _rowIndicatorCell(String text, String status) {
    final indicatorColor = status == 'Overdue'
        ? const Color(0xFFDC2626)
        : status == 'Due Near'
        ? const Color(0xFFF59E0B)
        : Colors.transparent;

    return SizedBox(
      width: 70,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 42,
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: _textColor(),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemNameWithNumberCell(Map<String, dynamic> item) {
    return SizedBox(
      width: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['item'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: _textColor(),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item['itemNo'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: _mutedColor(),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabCards() {
    return Column(
      children: _visibleLabs.map((lab) {
        return _mobileCard([
          _cardLine('Lab No', lab['no']),
          _cardLine('Lab Name', lab['name']),
          _cardLine('Responsible Person', lab['person']),
          _cardLine('Contact Number', lab['phone']),
          const SizedBox(height: 10),
          _actionRow(
            showReturned: false,
            onView: () => _openLabDetails(lab),
            onEdit: () => _editLab(lab),
            onDelete: () => _deleteLab(lab),
          ),
        ]);
      }).toList(),
    );
  }

  Widget _buildCategoryCards() {
    return Column(
      children: _visibleCategories.map((category) {
        return _mobileCard([
          _cardLine('No', '${category['no']}'),
          _cardLine('Category', category['name']),
          _cardLine('Total Items', '${category['items']} Items'),
          const SizedBox(height: 10),
          _actionRow(
            showReturned: false,
            onView: () => _openCategoryDetails(category),
            onEdit: () => _renameCategory(category),
            onDelete: () => _deleteCategory(category),
          ),
        ]);
      }).toList(),
    );
  }

  Widget _buildTrackingCards() {
    return Column(
      children: _visibleTrackingItems.map((item) {
        final deadlineLabel = _deadlineStatusLabel(item);
        return _mobileCard(
          [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _text(item['item'], 16, FontWeight.w800),
                      const SizedBox(height: 4),
                      _mutedText(item['itemNo'], 12),
                    ],
                  ),
                ),
                _deadlineBadge(deadlineLabel),
              ],
            ),
            const SizedBox(height: 8),
            _cardLine('Person', item['person']),
            _cardLine('Contact', item['phone']),
            _cardLine('Lab / Location', item['lab']),
            _cardLine('Issued Date', item['issued']),
            _cardLine('Due Date', item['due']),
            _cardLine('Days Outstanding', _deadlineDaysText(item)),
            const SizedBox(height: 10),
            _actionRow(
              showReturned: true,
              onView: () => _openDetails(item),
              onEdit: () => _openDetails(item),
              onReturned: () {
                _markReturned(item);
              },
              onDelete: () {
                _deleteTrackingItem(item);
              },
            ),
          ],
          backgroundColor: _deadlineRowColor(deadlineLabel),
          borderColor: _deadlineBorderColor(deadlineLabel),
        );
      }).toList(),
    );
  }

  Widget _buildAdminCards() {
    return Column(
      children: _adminMembers.map((admin) {
        return _mobileCard([
          _text(admin['name'], 16, FontWeight.w800),
          const SizedBox(height: 8),
          _cardLine('Phone Number', admin['phone']),
          _cardLine('Role', admin['role']),
          _cardLine('Last Login', admin['lastLogin']),
          const SizedBox(height: 10),
          _actionRow(
            showReturned: false,
            onView: () => _showMessage('Admin profile opened.'),
            onEdit: () =>
                _showMessage('Admin permissions can be edited from settings.'),
            onDelete: () =>
                _showMessage('Admin delete requires owner approval.'),
          ),
        ]);
      }).toList(),
    );
  }

  Widget _mobileCard(
    List<Widget> children, {
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor ?? _surfaceColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? _borderColor()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _labToolbar(bool isWide) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: isWide ? 320 : double.infinity,
          child: TextField(
            controller: _labSearchController,
            onChanged: (_) => setState(() {
              _labPage = 0;
            }),
            decoration: InputDecoration(
              hintText: 'Search lab name, person, contact, type...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _labSearchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear lab search',
                      onPressed: () {
                        _labSearchController.clear();
                        setState(() {
                          _labPage = 0;
                        });
                      },
                      icon: const Icon(Icons.close),
                    ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _labSearchController.clear();
              _labPage = 0;
            });
          },
          icon: const Icon(Icons.list_alt_outlined, size: 18),
          label: const Text('All Labs'),
          style: _outlineButtonStyle(),
        ),
        OutlinedButton.icon(
          onPressed: () => setState(() {
            _sortLabsAz = !_sortLabsAz;
            _labPage = 0;
          }),
          icon: const Icon(Icons.sort_by_alpha_outlined, size: 18),
          label: Text(_sortLabsAz ? 'A to Z On' : 'A to Z'),
          style: _outlineButtonStyle(),
        ),
        ElevatedButton.icon(
          onPressed: () {
            _clearLabForm();
            setState(() {
              _editingLabIndex = null;
              _selectedIndex = 7;
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add New Lab'),
        ),
      ],
    );
  }

  Widget _categoryToolbar(bool isWide) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: isWide ? 320 : double.infinity,
          child: TextField(
            controller: _categorySearchController,
            onChanged: (_) => setState(() {
              _categoryPage = 0;
            }),
            decoration: InputDecoration(
              hintText: 'Search categories...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _categorySearchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear category search',
                      onPressed: () {
                        _categorySearchController.clear();
                        setState(() {
                          _categoryPage = 0;
                        });
                      },
                      icon: const Icon(Icons.close),
                    ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => setState(() {
            _sortCategoriesAz = !_sortCategoriesAz;
            _categoryPage = 0;
          }),
          icon: const Icon(Icons.sort_by_alpha_outlined, size: 18),
          label: Text(_sortCategoriesAz ? 'A to Z On' : 'A to Z'),
          style: _outlineButtonStyle(),
        ),
        ElevatedButton.icon(
          onPressed: _addCategory,
          icon: const Icon(Icons.add),
          label: const Text('Add New Category'),
        ),
      ],
    );
  }

  Widget _historyUpdatedPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _surfaceColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.update_outlined, size: 18, color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          _text(_historyUpdatedText, 12, FontWeight.w800),
        ],
      ),
    );
  }

  Widget _trackingStatusFilters() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _trackingFilterChip('All', Icons.history_outlined),
          _trackingFilterChip('Safe', Icons.check_circle_outline),
          _trackingFilterChip('Due Near', Icons.error_outline),
          _trackingFilterChip('Overdue', Icons.warning_amber_rounded),
        ],
      ),
    );
  }

  Widget _trackingFilterChip(String status, IconData icon) {
    final selected = _trackingStatusFilter == status;
    final count = status == 'All'
        ? _trackingFilterBaseItems.length
        : _trackingStatusCount(status);
    final color = status == 'Safe'
        ? const Color(0xFF16A34A)
        : status == 'Due Near'
        ? const Color(0xFFF59E0B)
        : status == 'Overdue'
        ? const Color(0xFFDC2626)
        : AppTheme.primaryBlue;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => setState(() {
        _trackingStatusFilter = status;
        _trackingPage = 0;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: _darkMode ? 0.24 : 0.12)
              : _surfaceAltColor(),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color : _borderColor(),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: selected ? color : _mutedColor()),
            const SizedBox(width: 8),
            Text(
              '$status ($count)',
              style: GoogleFonts.inter(
                color: selected ? color : _textColor(),
                fontSize: 13,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBox(
    String hint, {
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller == null || controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  controller.clear();
                  onChanged?.call('');
                },
                icon: const Icon(Icons.close),
              ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _dropdown(
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _surfaceAltColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor()),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: options
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }

  Widget _smallButton(
    IconData icon,
    String label, {
    VoidCallback? onPressed,
    bool enabled = true,
  }) {
    return OutlinedButton.icon(
      onPressed: enabled
          ? (onPressed ?? () => _showMessage('$label selected.'))
          : null,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _summaryGrid(List<_SummaryData> items, bool isWide) {
    return _responsiveWrap(
      minItemWidth: 240,
      spacing: 16,
      children: items.map(_summaryCard).toList(),
    );
  }

  Widget _responsiveWrap({
    required double minItemWidth,
    required double spacing,
    required List<Widget> children,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final columns = (availableWidth / minItemWidth).floor().clamp(1, 4);
        final itemWidth = (availableWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }

  Widget _summaryCard(_SummaryData item) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: item.detailIndex == null
          ? null
          : () {
              setState(() {
                _detailTitle = item.title;
                _selectedIndex = item.detailIndex!;
              });
            },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _surfaceColor(),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borderColor()),
          boxShadow: _cardShadow(),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _mutedText(item.subtitle ?? item.title, 12),
                  const SizedBox(height: 6),
                  _text(item.value, 25, FontWeight.w900),
                  const SizedBox(height: 4),
                  _mutedText(item.title, 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceColor(),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor()),
        boxShadow: _cardShadow(),
      ),
      child: child,
    );
  }

  Widget _categoryItemTile(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceAltColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: item['color'],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: _text(item['name'], 13, FontWeight.w700)),
          _mutedText(item['status'], 12),
          PopupMenuButton<String>(
            onSelected: (value) =>
                _showMessage('${item['name']} $value selected.'),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'view', child: Text('View')),
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
            icon: const Icon(Icons.more_vert, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _text(title, 17, FontWeight.w800),
              const SizedBox(height: 4),
              _mutedText(subtitle, 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _activityTile(String title, String subtitle, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceAltColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor()),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _text(title, 13, FontWeight.w800),
                const SizedBox(height: 4),
                _mutedText(subtitle, 12),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _statusBadge(status),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceAltColor(),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor()),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _text(title, 14, FontWeight.w800),
                const SizedBox(height: 4),
                _mutedText(subtitle, 12),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: _mutedColor()),
        ],
      ),
    );
  }

  Widget _formGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 760 ? 2 : 1;
        final spacing = 14.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(width: width, child: child))
              .toList(),
        );
      },
    );
  }

  Widget _formField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool number = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }

  Widget _detailTile(
    String title,
    String subtitle,
    String status,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceAltColor(),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor()),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _text(title, 14, FontWeight.w800),
                const SizedBox(height: 4),
                _mutedText(subtitle, 12),
              ],
            ),
          ),
          _statusBadge(status),
        ],
      ),
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 16),
      decoration: BoxDecoration(
        color: _surfaceAltColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor()),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_outlined, size: 42, color: _mutedColor()),
          const SizedBox(height: 12),
          _text(title, 16, FontWeight.w800),
          const SizedBox(height: 6),
          _mutedText(subtitle, 13, align: TextAlign.center),
        ],
      ),
    );
  }

  Widget _pageControls() {
    final canMoveWithinModules = _selectedIndex >= 0 && _selectedIndex <= 5;
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              if (_selectedIndex == 7 || _selectedIndex == 6) {
                _selectedIndex = 1;
              } else if (canMoveWithinModules && _selectedIndex > 0) {
                _selectedIndex--;
              }
            });
          },
          icon: const Icon(Icons.arrow_back),
          label: const Text('Previous'),
          style: _outlineButtonStyle(),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              if (_selectedIndex == 7 || _selectedIndex == 6) {
                _selectedIndex = 1;
              } else if (canMoveWithinModules && _selectedIndex < 5) {
                _selectedIndex++;
              }
            });
          },
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Next'),
        ),
      ],
    );
  }

  ButtonStyle _outlineButtonStyle() {
    return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      foregroundColor: _textColor(),
      side: BorderSide(color: _borderColor()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _resetPages() {
    _labPage = 0;
    _categoryPage = 0;
    _trackingPage = 0;
  }

  void _clearLabForm() {
    _labNameController.clear();
    _responsiblePersonController.clear();
    _contactController.clear();
    _labTypeController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _machineCountController.clear();
    _staffCountController.clear();
  }

  void _saveLab() {
    if (_labNameController.text.trim().isEmpty ||
        _responsiblePersonController.text.trim().isEmpty ||
        _contactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter lab name, responsible person, and contact details.',
          ),
        ),
      );
      return;
    }

    final labData = {
      'no': _editingLabIndex == null
          ? 'LAB-${(_labs.length + 1).toString().padLeft(3, '0')}'
          : _labs[_editingLabIndex!]['no'],
      'name': _labNameController.text.trim(),
      'person': _responsiblePersonController.text.trim(),
      'phone': _contactController.text.trim(),
      'type': _labTypeController.text.trim().isEmpty
          ? 'General Lab'
          : _labTypeController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'status': 'Active',
      'machines': int.tryParse(_machineCountController.text.trim()) ?? 0,
      'staff': int.tryParse(_staffCountController.text.trim()) ?? 0,
    };

    setState(() {
      if (_editingLabIndex == null) {
        _labs.add(labData);
      } else {
        _labs[_editingLabIndex!] = labData;
      }
      _editingLabIndex = null;
      _clearLabForm();
      _selectedIndex = 1;
    });
  }

  void _editLab(Map<String, dynamic> lab) {
    final index = _labs.indexOf(lab);
    if (index == -1) return;

    _labNameController.text = lab['name'] ?? '';
    _responsiblePersonController.text = lab['person'] ?? '';
    _contactController.text = lab['phone'] ?? '';
    _labTypeController.text = lab['type'] ?? '';
    _descriptionController.text = lab['description'] ?? '';
    _locationController.text = lab['location'] ?? '';
    _machineCountController.text = '${lab['machines'] ?? 0}';
    _staffCountController.text = '${lab['staff'] ?? 0}';

    setState(() {
      _editingLabIndex = index;
      _selectedIndex = 7;
    });
  }

  void _deleteLab(Map<String, dynamic> lab) {
    setState(() => _labs.remove(lab));
    _showMessage('${lab['name']} deleted.');
  }

  void _openLabDetails(Map<String, dynamic> lab) {
    _openInfoSheet(
      title: lab['name'],
      rows: {
        'Lab No': lab['no'],
        'Responsible Person': lab['person'],
        'Contact': lab['phone'],
        'Lab Type': lab['type'] ?? 'General Lab',
        'Location': lab['location'] ?? 'Not assigned',
        'Machines': '${lab['machines']}',
        'Staff': '${lab['staff']}',
      },
    );
  }

  void _openCategoryDetails(Map<String, dynamic> category) {
    _openInfoSheet(
      title: category['name'],
      rows: {
        'Category No': '${category['no']}',
        'Total Items': '${category['items']}',
      },
    );
  }

  void _renameCategory(Map<String, dynamic> category) {
    final controller = TextEditingController(text: category['name']);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Category Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => category['name'] = controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(Map<String, dynamic> category) {
    setState(() => _categories.remove(category));
    _showMessage('${category['name']} deleted.');
  }

  void _addCategory() {
    final next = _categories.length + 1;
    setState(() {
      _categories.add({
        'no': next,
        'name': 'New Category $next',
        'items': 0,
        'status': 'Active',
      });
    });
    _showMessage('New category added.');
  }

  Future<void> _markReturned(Map<String, dynamic> item) async {
    final purchaseId = item['purchaseId']?.toString();
    if (purchaseId == null || purchaseId.isEmpty) {
      _showMessage('Missing purchase id for ${item['item']}.');
      return;
    }

    try {
      final admin = context.read<AuthProvider>().appUser;
      await _databaseService.returnPurchase(
        purchaseId,
        returnedBy: admin?.name ?? 'Admin',
        itemCondition: 'No Damage',
        returnPhotoName: '',
        returnPhotoSource: '',
        returnPhotoBytes: null,
      );
      if (!mounted) return;
      _showMessage('${item['item']} marked as returned.');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Return failed: $error');
    }
  }

  Future<void> _deleteTrackingItem(Map<String, dynamic> item) async {
    final purchaseId = item['purchaseId']?.toString();
    if (purchaseId == null || purchaseId.isEmpty) {
      _showMessage('Missing purchase id for ${item['item']}.');
      return;
    }

    try {
      await _databaseService.deletePurchase(purchaseId);
      if (!mounted) return;
      _showMessage('${item['item']} history record deleted.');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Delete failed: $error');
    }
  }

  void _openInfoSheet({
    required String title,
    required Map<String, String> rows,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surfaceColor(),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _text(title, 20, FontWeight.w900)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...rows.entries.map((entry) => _cardLine(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _actionRow({
    required bool showReturned,
    VoidCallback? onView,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onReturned,
  }) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      onSelected: (value) {
        if (value == 'view') {
          if (onView != null) onView();
        } else if (value == 'edit') {
          if (onEdit != null) {
            onEdit();
          } else {
            _showMessage('Edit action selected.');
          }
        } else if (value == 'returned') {
          if (onReturned != null) {
            onReturned();
          } else {
            _showMessage('Item marked as returned.');
          }
        } else if (value == 'delete') {
          if (onDelete != null) {
            onDelete();
          } else {
            _showMessage('Delete action selected.');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${value[0].toUpperCase()}${value.substring(1)} action selected.',
              ),
            ),
          );
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: ListTile(
            leading: Icon(Icons.visibility_outlined),
            title: Text('View Details'),
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit'),
            dense: true,
          ),
        ),
        if (showReturned)
          const PopupMenuItem(
            value: 'returned',
            child: ListTile(
              leading: Icon(Icons.assignment_return_outlined),
              title: Text('Mark Returned'),
              dense: true,
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Delete'),
            dense: true,
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _surfaceAltColor(),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _borderColor()),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_outlined, size: 16, color: _textColor()),
            const SizedBox(width: 6),
            _text('Actions', 12, FontWeight.w700),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _purchaseToTrackingItem(Purchase purchase, int index) {
    final dueDate =
        purchase.returnDueDate ??
        purchase.purchaseDate.add(const Duration(days: 10));
    final displayName = purchase.userName.trim().isEmpty
        ? 'User'
        : purchase.userName.trim();
    final phone = purchase.userPhone.trim().isEmpty
        ? 'Not provided'
        : purchase.userPhone.trim();

    return {
      'no': index + 1,
      'purchaseId': purchase.purchaseId,
      'person': displayName,
      'phone': phone,
      'email': 'UID ${_shortId(purchase.userId)}',
      'item': purchase.productName,
      'itemNo': purchase.productId,
      'lab': _labForProduct(purchase.productId),
      'issued': _formatDate(purchase.purchaseDate),
      'due': _formatDate(dueDate),
      'status': purchase.isReturned ? 'Returned' : 'Issued',
      'uploadedBy': displayName,
      'uploadedAt': _formatDateTime(purchase.purchaseDate),
      'issuePhotoUrl': purchase.issuePhotoSource,
      'returnPhotoUrl': purchase.returnPhotoSource,
      'returnedBy': purchase.returnedBy,
      'returnedAt': purchase.returnDate == null
          ? ''
          : _formatDateTime(purchase.returnDate!),
    };
  }

  String _labForProduct(String productId) {
    final id = productId.toUpperCase();
    if (id.startsWith('ELE')) return 'Electrical Store';
    if (id.startsWith('ELN') || id.startsWith('ELC')) return 'Electronic Store';
    return 'General Store';
  }

  String _shortId(String value) {
    if (value.length <= 8) return value;
    return value.substring(0, 8);
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  String _formatDateTime(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '${value.day} ${months[value.month - 1]} ${value.year} - $hour:$minute $period';
  }

  DateTime? _parseHistoryDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  int? _daysUntilDue(Map<String, dynamic> item) {
    final dueDate = _parseHistoryDate(item['due'] ?? '');
    if (dueDate == null) return null;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dueOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueOnly.difference(todayOnly).inDays;
  }

  String _deadlineStatusLabel(Map<String, dynamic> item) {
    if (item['status'] == 'Returned') return 'Returned';

    final daysUntilDue = _daysUntilDue(item);
    if (daysUntilDue != null) {
      if (daysUntilDue < 0) return 'Overdue';
      if (daysUntilDue <= 3) return 'Due Near';
      return 'Safe';
    }

    final days = item['days'];
    if (days is int) {
      if (days > 10) return 'Overdue';
      if (days >= 8) return 'Due Near';
      return 'Safe';
    }

    return item['status'] ?? 'Safe';
  }

  String _deadlineDaysText(Map<String, dynamic> item) {
    final days = item['days'];
    if (days is int) return '$days days';

    final daysUntilDue = _daysUntilDue(item);
    if (daysUntilDue == null) return 'Not set';
    if (daysUntilDue < 0) return '${daysUntilDue.abs()} days overdue';
    if (daysUntilDue == 0) return 'Due today';
    return '$daysUntilDue days left';
  }

  Color? _deadlineRowColor(String status) {
    if (status == 'Overdue') {
      return _darkMode
          ? const Color(0xFF7F1D1D).withValues(alpha: 0.45)
          : const Color(0xFFFFE4E6);
    }
    if (status == 'Due Near') {
      return _darkMode
          ? const Color(0xFF78350F).withValues(alpha: 0.48)
          : const Color(0xFFFEF3C7);
    }
    return null;
  }

  Color? _deadlineHoverColor(String status) {
    if (status == 'Overdue') {
      return _darkMode
          ? const Color(0xFF991B1B).withValues(alpha: 0.42)
          : const Color(0xFFFEE2E2);
    }
    if (status == 'Due Near') {
      return _darkMode
          ? const Color(0xFF92400E).withValues(alpha: 0.42)
          : const Color(0xFFFEF3C7);
    }
    return _darkMode ? const Color(0xFF243044) : const Color(0xFFEFF6FF);
  }

  Color _deadlineBorderColor(String status) {
    if (status == 'Overdue') {
      return _darkMode ? const Color(0xFFEF4444) : const Color(0xFFFCA5A5);
    }
    if (status == 'Due Near') {
      return _darkMode ? const Color(0xFFF59E0B) : const Color(0xFFFCD34D);
    }
    return _borderColor();
  }

  Widget _deadlineBadge(String status) {
    final color = status == 'Overdue'
        ? const Color(0xFFDC2626)
        : status == 'Due Near'
        ? const Color(0xFFF59E0B)
        : status == 'Returned'
        ? const Color(0xFF2563EB)
        : const Color(0xFF16A34A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: _darkMode ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          color: _darkMode && status == 'Due Near'
              ? const Color(0xFFFCD34D)
              : color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = status == 'Active' || status == 'Safe'
        ? const Color(0xFF16A34A)
        : status == 'Due Near'
        ? const Color(0xFFF59E0B)
        : status == 'Inactive'
        ? const Color(0xFF64748B)
        : const Color(0xFFDC2626);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _pagination({
    required int totalRecords,
    required int currentPage,
    required VoidCallback onPrevious,
    required VoidCallback onNext,
  }) {
    final start = totalRecords == 0 ? 0 : currentPage * _pageSize + 1;
    final end = (currentPage * _pageSize + _pageSize).clamp(0, totalRecords);
    final hasPrevious = currentPage > 0;
    final hasNext = (currentPage + 1) * _pageSize < totalRecords;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          _mutedText('Showing $start-$end of $totalRecords records', 12),
          const Spacer(),
          _smallButton(
            Icons.chevron_left,
            'Prev',
            onPressed: onPrevious,
            enabled: hasPrevious,
          ),
          const SizedBox(width: 8),
          _smallButton(
            Icons.chevron_right,
            'Next',
            onPressed: onNext,
            enabled: hasNext,
          ),
        ],
      ),
    );
  }

  void _openDetails(Map<String, dynamic> item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: MediaQuery.sizeOf(context).width > 620
                ? 440
                : double.infinity,
            height: MediaQuery.sizeOf(context).height,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _surfaceColor(),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _text('Item Details', 22, FontWeight.w900),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 210,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 76,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _cardLine('Item Name', item['item']),
                  _cardLine('Item Number', item['itemNo']),
                  _cardLine('Uploaded Date', item['uploadedAt']),
                  _cardLine('Uploaded By', item['uploadedBy']),
                  _cardLine('Current Holder', item['person']),
                  _cardLine('Location', item['lab']),
                  const SizedBox(height: 18),
                  _drawerAction(Icons.remove_red_eye_outlined, 'Preview Image'),
                  _drawerAction(Icons.download_outlined, 'Download Image'),
                  _drawerAction(
                    Icons.delete_outline,
                    'Delete Image',
                    danger: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _drawerAction(IconData icon, String label, {bool danger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton.icon(
        onPressed: () => _showMessage('$label completed.'),
        icon: Icon(icon, color: danger ? const Color(0xFFDC2626) : null),
        label: Text(
          label,
          style: TextStyle(color: danger ? const Color(0xFFDC2626) : null),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _pageTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _text(title, 26, FontWeight.w900),
        const SizedBox(height: 6),
        _mutedText(subtitle, 14),
      ],
    );
  }

  Widget _cardLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 132, child: _mutedText(label, 12)),
          Expanded(child: _text(value, 13, FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _text(String text, double size, FontWeight weight) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: _textColor(),
        fontSize: size,
        fontWeight: weight,
      ),
    );
  }

  Widget _mutedText(
    String text,
    double size, {
    TextAlign align = TextAlign.start,
  }) {
    return Text(
      text,
      textAlign: align,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      style: GoogleFonts.inter(
        color: _mutedColor(),
        fontSize: size,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecorationTheme _inputTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: _surfaceAltColor(),
      labelStyle: GoogleFonts.inter(color: _mutedColor()),
      hintStyle: GoogleFonts.inter(color: _mutedColor()),
      prefixIconColor: _mutedColor(),
      suffixIconColor: _mutedColor(),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _borderColor()),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _borderColor()),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
      ),
    );
  }

  Color _textColor() =>
      _darkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color _mutedColor() =>
      _darkMode ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
  Color _surfaceColor() => _darkMode ? const Color(0xFF111827) : Colors.white;
  Color _surfaceAltColor() =>
      _darkMode ? const Color(0xFF1F2937) : const Color(0xFFF8FAFC);
  Color _tableHeaderColor() =>
      _darkMode ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF);
  Color _selectedNavColor() =>
      _darkMode ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF);
  Color _borderColor() =>
      _darkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  List<BoxShadow> _cardShadow() => _darkMode
      ? []
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ];
}

class _NavItem {
  final String label;
  final IconData icon;

  const _NavItem(this.label, this.icon);
}

class _SummaryData {
  final String title;
  final String value;
  final IconData icon;
  final Color background;
  final Color color;
  final String? subtitle;
  final int? detailIndex;

  const _SummaryData(
    this.title,
    this.value,
    this.icon,
    this.background,
    this.color, {
    this.subtitle,
    this.detailIndex,
  });
}

class _ModuleData {
  final String title;
  final String description;
  final IconData icon;
  final int index;
  final Color color;

  const _ModuleData(
    this.title,
    this.description,
    this.icon,
    this.index,
    this.color,
  );
}
