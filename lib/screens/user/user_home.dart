import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/product.dart';
import '../../models/purchase.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  String _categoryFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(user.name, user.email),
            Expanded(
              child: _selectedIndex == 0
                  ? _buildItemsTab(user.userId, user.name, user.phone)
                  : _buildMyIssuesTab(user.userId),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader(String name, String email) {
    final displayName = name.trim().isEmpty ? 'User' : name.trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Inventory',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF0F172A),
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$displayName - ${email.trim()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => context.read<AuthProvider>().signOut(),
            icon: const Icon(Icons.logout_outlined),
            color: const Color(0xFF475569),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTab(String userId, String userName, String userPhone) {
    return StreamBuilder<List<Product>>(
      stream: context.read<ProductProvider>().getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _emptyState(
            Icons.error_outline,
            'Unable to load items',
            'Please try again in a moment.',
          );
        }

        final products = snapshot.data ?? [];
        final visibleProducts = _filterProducts(products);

        return Column(
          children: [
            _buildInventorySummary(products),
            _buildSearchAndFilters(),
            Expanded(
              child: visibleProducts.isEmpty
                  ? _emptyState(
                      Icons.search_off_outlined,
                      'No items found',
                      'Try a different search or category filter.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                      itemCount: visibleProducts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final product = visibleProducts[index];
                        return _productCard(
                          product,
                          onIssue: () =>
                              _issueItem(product, userId, userName, userPhone),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMyIssuesTab(String userId) {
    return StreamBuilder<List<Purchase>>(
      stream: context.read<ProductProvider>().getPersonalPurchases(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _emptyState(
            Icons.error_outline,
            'Unable to load your issues',
            'Please try again in a moment.',
          );
        }

        final issues = snapshot.data ?? [];
        if (issues.isEmpty) {
          return _emptyState(
            Icons.assignment_outlined,
            'No issued items yet',
            'Items you take from inventory will appear here.',
          );
        }

        final activeCount = issues.where((issue) => !issue.isReturned).length;
        final returnedCount = issues.length - activeCount;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _summaryTile(
                      'Currently Issued',
                      '$activeCount',
                      Icons.outbox_outlined,
                      const Color(0xFFEFF6FF),
                      AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryTile(
                      'Returned',
                      '$returnedCount',
                      Icons.assignment_turned_in_outlined,
                      const Color(0xFFF0FDF4),
                      const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                itemCount: issues.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) => _issueCard(issues[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Product> _filterProducts(List<Product> products) {
    final query = _searchController.text.trim().toLowerCase();
    return products.where((product) {
      final category = _categoryFor(product);
      final matchesCategory =
          _categoryFilter == 'All' || category == _categoryFilter;
      final searchable = [
        product.productName,
        product.productId,
        product.specification,
        category,
      ].join(' ').toLowerCase();
      final matchesSearch = query.isEmpty || searchable.contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Widget _buildInventorySummary(List<Product> products) {
    final availableCount = products
        .where((product) => product.quantityAvailable > 0)
        .length;
    final lowStockCount = products
        .where(
          (product) =>
              product.quantityAvailable > 0 && product.quantityAvailable <= 5,
        )
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _summaryTile(
              'Available Items',
              '$availableCount',
              Icons.inventory_2_outlined,
              const Color(0xFFEFF6FF),
              AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryTile(
              'Low Stock',
              '$lowStockCount',
              Icons.priority_high_outlined,
              const Color(0xFFFFFBEB),
              const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close),
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.primaryBlue),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _filterChip('All'),
                _filterChip('Electrical'),
                _filterChip('Electronic'),
                _filterChip('General'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final selected = _categoryFilter == label;
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => setState(() => _categoryFilter = label),
      labelStyle: GoogleFonts.inter(
        color: selected ? AppTheme.primaryBlue : const Color(0xFF475569),
        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
      ),
      selectedColor: const Color(0xFFEFF6FF),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? AppTheme.primaryBlue : Colors.grey.shade200,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }

  Widget _productCard(Product product, {required VoidCallback onIssue}) {
    final inStock = product.quantityAvailable > 0;
    final category = _categoryFor(product);
    final categoryColor = category == 'Electrical'
        ? const Color(0xFF16A34A)
        : category == 'Electronic'
        ? AppTheme.primaryBlue
        : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_categoryIcon(category), color: categoryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.specification,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pill(product.productId, AppTheme.primaryBlue),
                    _pill(category, categoryColor),
                    _pill(
                      inStock
                          ? '${product.quantityAvailable} available'
                          : 'Out of stock',
                      inStock
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: inStock ? onIssue : null,
            icon: const Icon(Icons.add_task_outlined, size: 18),
            label: const Text('Issue'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade200,
              disabledForegroundColor: Colors.grey.shade500,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _issueCard(Purchase issue) {
    final statusColor = issue.isReturned
        ? const Color(0xFF16A34A)
        : AppTheme.primaryBlue;
    final statusText = issue.isReturned ? 'Returned' : 'Issued';
    final dateText =
        '${issue.purchaseDate.day.toString().padLeft(2, '0')}/'
        '${issue.purchaseDate.month.toString().padLeft(2, '0')}/'
        '${issue.purchaseDate.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.assignment_outlined, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.productName,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${issue.productId} - Qty ${issue.quantityBought} - $dateText',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _pill(statusText, statusColor),
        ],
      ),
    );
  }

  Widget _summaryTile(
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _emptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.grey.shade400, size: 54),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF0F172A),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _navButton(0, Icons.inventory_2_outlined, 'Items'),
              ),
              Expanded(
                child: _navButton(1, Icons.assignment_outlined, 'My Issues'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(int index, IconData icon, String label) {
    final selected = _selectedIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.primaryBlue : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: selected
                    ? AppTheme.primaryBlue
                    : const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  IconData _categoryIcon(String category) {
    if (category == 'Electrical') return Icons.electrical_services_outlined;
    if (category == 'Electronic') return Icons.memory_outlined;
    return Icons.category_outlined;
  }

  String _categoryFor(Product product) {
    final id = product.productId.toUpperCase();
    if (id.startsWith('ELE')) return 'Electrical';
    if (id.startsWith('ELN') || id.startsWith('ELC')) return 'Electronic';
    return 'General';
  }

  Future<void> _issueItem(
    Product product,
    String userId,
    String userName,
    String userPhone,
  ) async {
    final success = await context.read<ProductProvider>().buyProduct(
      userId,
      product,
      1,
      userName: userName,
      userPhone: userPhone,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${product.productName} issued to your account.'
              : 'Could not issue ${product.productName}.',
        ),
        backgroundColor: success ? const Color(0xFF16A34A) : Colors.red,
      ),
    );
  }
}
