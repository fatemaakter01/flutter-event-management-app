import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../services/catering_service.dart';

class CateringManagementScreen extends StatefulWidget {
  const CateringManagementScreen({super.key});

  @override
  State<CateringManagementScreen> createState() => _CateringManagementScreenState();
}

class _CateringManagementScreenState extends State<CateringManagementScreen> with SingleTickerProviderStateMixin {
  final CateringService _cateringService = CateringService();
  late TabController _tabController;
  List<CateringItem> _items = [];
  bool _isLoading = true;

  final List<String> _categories = ['Starter', 'Main Course', 'Drinks', 'Dessert'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadCatering();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCatering() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _cateringService.fetchCateringItems();
      if (mounted) {
        setState(() {
          _items = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCateringForm([CateringItem? item]) {
    final nameController = TextEditingController(text: item?.name);
    final priceController = TextEditingController(text: item?.price.toString());
    
    // Default to the current tab's category if adding new item
    String selectedCategory = item?.category ?? _categories[_tabController.index];
    bool isVeg = item?.type == 'Veg' || (item == null);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(item == null ? 'Add to $selectedCategory' : 'Edit Item', 
            style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController, 
                  decoration: const InputDecoration(labelText: 'Item Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.restaurant))
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: _categories.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setModalState(() => selectedCategory = val!),
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: priceController, 
                  decoration: const InputDecoration(labelText: 'Price per Plate', border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)), 
                  keyboardType: const TextInputType.numberWithOptions(decimal: true)
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: Text(isVeg ? 'Veg (Vegetarian)' : 'Non-Veg'),
                  value: isVeg,
                  onChanged: (val) => setModalState(() => isVeg = val),
                  secondary: Icon(Icons.eco, color: isVeg ? Colors.green : Colors.red),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
              onPressed: () async {
                if (nameController.text.isEmpty) return;
                
                final newItem = CateringItem(
                  cateringId: item?.cateringId,
                  name: nameController.text,
                  category: selectedCategory,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  type: isVeg ? 'Veg' : 'Non-Veg',
                  status: 'Available',
                );
                
                bool success = item == null 
                  ? await _cateringService.addCateringItem(newItem)
                  : await _cateringService.updateCateringItem(item.cateringId!, newItem);
                
                if (success) {
                  _loadCatering();
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: Text(item == null ? 'Add Item' : 'Update Item'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Tab Bar Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.deepPurple,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.deepPurple,
                    isScrollable: true,
                    tabs: _categories.map((c) => Tab(text: c)).toList(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.deepPurple),
                  onPressed: _loadCatering,
                ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: _categories.map((c) => _buildCategoryList(c)).toList(),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCateringForm(),
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Food', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCategoryList(String category) {
    final list = _items.where((i) => i.category == category).toList();
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text('No items in $category', style: TextStyle(color: Colors.grey[400], fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCateringForm(), 
              icon: const Icon(Icons.add),
              label: Text('Add First $category Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final bool isVeg = item.type == 'Veg';
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: isVeg ? Colors.green[50] : Colors.red[50],
              child: Icon(Icons.restaurant, color: isVeg ? Colors.green : Colors.red, size: 20),
            ),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Price: \$${item.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                Text(item.type, style: TextStyle(color: isVeg ? Colors.green : Colors.red, fontSize: 12)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20), 
                  onPressed: () => _showCateringForm(item)
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), 
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Item?'),
                        content: Text('Delete "${item.name}" from $category?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirm == true && item.cateringId != null) {
                      if (await _cateringService.deleteCateringItem(item.cateringId!)) {
                        _loadCatering();
                      }
                    }
                  }
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
