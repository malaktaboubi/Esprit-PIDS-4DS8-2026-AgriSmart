import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/services/auth_service.dart';
import '../models/diagnosis.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';

class CropHealthHistoryScreen extends StatefulWidget {
  const CropHealthHistoryScreen({super.key});
  @override
  State<CropHealthHistoryScreen> createState() => _CropHealthHistoryScreenState();
}

class _CropHealthHistoryScreenState extends State<CropHealthHistoryScreen> {
  late CropHealthApiService _apiService;
  List<Diagnosis> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _apiService = CropHealthApiService(authService);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await _apiService.fetchMyHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Record"),
        content: const Text("Are you sure you want to remove this diagnosis?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _apiService.deleteDiagnosis(id);
      if (success) {
        _loadHistory(); // Refresh
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete record"), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diagnosis History"),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _history.isEmpty
              ? const Center(
                  child: Text(
                    "No records yet.",
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return Card(
                      color: AppColors.surface,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: item.imagePath.startsWith('http') || item.imagePath.startsWith('/')
                              ? Image.network(
                                  _apiService.getFullImageUrl(item.imagePath),
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, st) => Container(
                                    width: 64,
                                    height: 64,
                                    color: AppColors.background,
                                    child: const Icon(Icons.broken_image, color: AppColors.textMuted),
                                  ),
                                )
                              : Image.file(
                                  File(item.imagePath),
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        title: Text(
                          item.diseaseName,
                          style: TextStyle(
                            color: item.isUnknown ? Colors.redAccent : AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "${item.plantName}\n${_formatDate(item.date)}",
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!item.isUnknown)
                              Text(
                                "${(item.confidence * 100).toStringAsFixed(0)}%",
                                style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold),
                              ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => _deleteItem(item.id!),
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
