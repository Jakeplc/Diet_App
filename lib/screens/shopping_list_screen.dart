import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/shopping_item.dart';
import '../services/shopping_list_service.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<ShoppingItem> _shoppingItems = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadSavedList();
  }

  Future<void> _loadSavedList() async {
    // Try to load from storage (if we implement persistence)
    // For now, start with empty list
    setState(() {
      _shoppingItems = [];
    });
  }

  Future<void> _generateFromMealPlans() async {
    final dateRange = await showDialog<Map<String, DateTime>>(
      context: context,
      builder: (context) => _DateRangeDialog(),
    );

    if (dateRange == null) return;

    setState(() => _isLoading = true);

    try {
      final items = await ShoppingListService.generateShoppingList(
        startDate: dateRange['start']!,
        endDate: dateRange['end']!,
      );

      setState(() {
        _shoppingItems = items;
        _isLoading = false;
      });

      if (items.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No meal plans found for selected dates'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleItem(ShoppingItem item) {
    setState(() {
      final index = _shoppingItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _shoppingItems[index].isChecked = !_shoppingItems[index].isChecked;
      }
    });
  }

  void _deleteItem(ShoppingItem item) {
    setState(() {
      _shoppingItems.removeWhere((i) => i.id == item.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _shoppingItems.add(item);
            });
          },
        ),
      ),
    );
  }

  void _clearCheckedItems() {
    setState(() {
      _shoppingItems.removeWhere((item) => item.isChecked);
    });
  }

  void _shareList() {
    final text = ShoppingListService.formatAsText(_shoppingItems);
    Share.share(text, subject: 'My Shopping List');
  }

  @override
  Widget build(BuildContext context) {
    final uncheckedCount = _shoppingItems
        .where((item) => !item.isChecked)
        .length;
    final checkedCount = _shoppingItems.where((item) => item.isChecked).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shopping List'),
            if (_shoppingItems.isNotEmpty)
              Text(
                '$uncheckedCount items • $checkedCount checked',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          if (_shoppingItems.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareList,
              tooltip: 'Share List',
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_checked',
                  child: Row(
                    children: [
                      Icon(Icons.cleaning_services, size: 20),
                      SizedBox(width: 10),
                      Text('Clear Checked'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, size: 20),
                      SizedBox(width: 10),
                      Text('Clear All'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'clear_checked') {
                  _clearCheckedItems();
                } else if (value == 'clear_all') {
                  setState(() => _shoppingItems.clear());
                }
              },
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _shoppingItems.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                _buildCategoryFilter(),
                Expanded(child: _buildShoppingList()),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateFromMealPlans,
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Generate'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          const Text(
            'No Shopping List Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Generate a list from your meal plans',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _generateFromMealPlans,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate from Meal Plans'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', ...ShoppingListService.getCategories()];

    return Container(
      height: 50,
      color: const Color(0xFF1E1E1E),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          final count = category == 'All'
              ? _shoppingItems.length
              : _shoppingItems
                    .where((item) => item.category == category)
                    .length;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: FilterChip(
              label: Text('$category ($count)'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: Colors.orange,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShoppingList() {
    final categories = ShoppingListService.getCategories();

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _selectedCategory == 'All' ? categories.length : 1,
      itemBuilder: (context, index) {
        final category = _selectedCategory == 'All'
            ? categories[index]
            : _selectedCategory;
        final categoryItems = _shoppingItems
            .where((item) => item.category == category)
            .toList();

        if (categoryItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      category,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${categoryItems.length} items',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              ...categoryItems.map((item) => _buildShoppingItemTile(item)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShoppingItemTile(ShoppingItem item) {
    final quantityStr = item.quantity == item.quantity.toInt()
        ? item.quantity.toInt().toString()
        : item.quantity.toStringAsFixed(1);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteItem(item),
      child: CheckboxListTile(
        value: item.isChecked,
        onChanged: (_) => _toggleItem(item),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isChecked ? TextDecoration.lineThrough : null,
            color: item.isChecked ? Colors.grey : null,
          ),
        ),
        subtitle: Text('$quantityStr ${item.unit}'),
        secondary: Icon(
          item.isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
          color: item.isChecked ? Colors.green : Colors.grey,
        ),
        activeColor: Colors.orange,
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Produce':
        return Icons.local_florist;
      case 'Protein':
        return Icons.set_meal;
      case 'Dairy':
        return Icons.water_drop;
      case 'Grains':
        return Icons.grain;
      case 'Frozen':
        return Icons.ac_unit;
      case 'Snacks':
        return Icons.cookie;
      case 'Beverages':
        return Icons.local_cafe;
      default:
        return Icons.shopping_bag;
    }
  }
}

// Date Range Selection Dialog
class _DateRangeDialog extends StatefulWidget {
  @override
  State<_DateRangeDialog> createState() => _DateRangeDialogState();
}

class _DateRangeDialogState extends State<_DateRangeDialog> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    final endDate = startDate.add(Duration(days: _selectedDays));

    return AlertDialog(
      title: const Text('Select Time Range'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Generate shopping list from meal plans for:'),
          const SizedBox(height: 20),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 3, label: Text('3 Days')),
              ButtonSegment(value: 7, label: Text('1 Week')),
              ButtonSegment(value: 14, label: Text('2 Weeks')),
            ],
            selected: {_selectedDays},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedDays = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date Range:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                  style: const TextStyle(color: Colors.orange),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {'start': startDate, 'end': endDate});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Generate'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
