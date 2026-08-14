import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constant/App_Colors.dart';
import '../../../core/routes/Routes_name.dart';
import '../model/sellerNotificationModel.dart';
import '../viewModel/sellerNotificationProvider.dart';

class SellerNotificationScreen extends StatefulWidget {
  const SellerNotificationScreen({super.key});

  @override
  State<SellerNotificationScreen> createState() =>
      _SellerNotificationScreenState();
}

class _SellerNotificationScreenState extends State<SellerNotificationScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  // Tab controller for Unread/Read/All tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ─── Load Notifications ──────────────────────────────────────────
  Future<void> _loadNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMoreData = true;
    }

    await context.read<SellerNotificationProvider>().fetchNotifications(
      page: _currentPage,
      limit: 20,
    );

    // Check if more data is available
    final provider = context.read<SellerNotificationProvider>();
    final pagination = provider.notificationData?.data?.pagination;
    if (pagination != null) {
      _hasMoreData = pagination.page! < pagination.totalPages!;
    }
  }

  // ─── Load More on Scroll ─────────────────────────────────────────
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      await context.read<SellerNotificationProvider>().fetchNotifications(
        page: _currentPage,
        limit: 20,
      );

      // Update hasMoreData
      final provider = context.read<SellerNotificationProvider>();
      final pagination = provider.notificationData?.data?.pagination;
      if (pagination != null) {
        setState(() {
          _hasMoreData = pagination.page! < pagination.totalPages!;
        });
      }
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // ─── Refresh ─────────────────────────────────────────────────────
  Future<void> _onRefresh() async {
    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
    });
    await _loadNotifications(isRefresh: true);
  }

  // ─── Mark Notification as Read ──────────────────────────────────
  Future<void> _markAsRead(String notificationId) async {
    await context.read<SellerNotificationProvider>().markAsRead(notificationId);
  }

  // ─── Mark All as Read ────────────────────────────────────────────
  Future<void> _markAllAsRead() async {
    await context.read<SellerNotificationProvider>().markAllAsRead();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: AppColors.successGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0.5,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0052CC),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF0052CC),
          indicatorWeight: 3,
          tabs: [
            Consumer<SellerNotificationProvider>(
              builder: (context, provider, _) {
                return Tab(
                  text: 'Unread (${provider.unreadCount})',
                );
              },
            ),
            Consumer<SellerNotificationProvider>(
              builder: (context, provider, _) {
                return Tab(
                  text: 'Read (${provider.readNotifications.length})',
                );
              },
            ),
            Consumer<SellerNotificationProvider>(
              builder: (context, provider, _) {
                return Tab(
                  text: 'All (${provider.allNotifications.length})',
                );
              },
            ),
          ],
        ),
        actions: [
          // Mark all as read button
          Consumer<SellerNotificationProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount == 0) {
                return const SizedBox.shrink();
              }
              return IconButton(
                onPressed: () => _showMarkAllReadDialog(context),
                icon: const Icon(Icons.done_all_rounded),
                tooltip: 'Mark all as read',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<SellerNotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.allNotifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0052CC)),
                  SizedBox(height: 16),
                  Text('Loading notifications...'),
                ],
              ),
            );
          }

          if (provider.errorMessage != null && provider.allNotifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _onRefresh,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052CC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.allNotifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ll notify you when something important happens',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: const Color(0xFF0052CC),
            child: TabBarView(
              controller: _tabController,
              children: [
                // ─── Unread Tab ──────────────────────────────────
                _buildNotificationList(
                  context,
                  provider.unreadNotifications,
                  provider,
                ),
                // ─── Read Tab ────────────────────────────────────
                _buildNotificationList(
                  context,
                  provider.readNotifications,
                  provider,
                ),
                // ─── All Tab ─────────────────────────────────────
                _buildNotificationList(
                  context,
                  provider.allNotifications,
                  provider,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Build Notification List ──────────────────────────────────
  Widget _buildNotificationList(
      BuildContext context,
      List<Items> notifications,
      SellerNotificationProvider provider,
      ) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications in this tab',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _getItemCount(notifications, provider),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index < notifications.length) {
          final item = notifications[index];
          return _buildNotificationItem(
            context,
            item,
            provider,
            // Read callback
            onMarkRead: () async {
              if (item.id != null && !(item.read ?? false)) {
                await _markAsRead(item.id!);
              }
            },
          );
        } else {
          return _buildLoadingMoreIndicator();
        }
      },
    );
  }

  // ─── Get Item Count ─────────────────────────────────────────────
  int _getItemCount(List<Items> notifications, SellerNotificationProvider provider) {
    if (_isLoadingMore && _hasMoreData) {
      return notifications.length + 1;
    } else if (_hasMoreData) {
      return notifications.length + 1;
    } else {
      return notifications.length;
    }
  }

  // ─── Build Notification Item ────────────────────────────────────
  Widget _buildNotificationItem(
      BuildContext context,
      Items item,
      SellerNotificationProvider provider, {
        required VoidCallback onMarkRead,
      }) {
    final isUnread = !(item.read ?? true);

    return GestureDetector(
      onTap: () {
        debugPrint('🔔 [Notification] Tapped: ${item.title}');

        // 1. Extract Application ID
        String? targetId = _extractTargetId(item);

        debugPrint('🔍 [Notification] Extracted Target ID: $targetId');

        if (targetId != null && targetId.isNotEmpty) {
          try {
            // 2. Navigate to Details Screen
            Navigator.pushNamed(
              context,
              RouteName.loanApplicationDetailsScreen,
              arguments: targetId,
            );
            debugPrint('✅ [Notification] Navigating to Details Screen');

            // 3. Mark as read if unread
            if (isUnread && item.id != null) {
              _markAsRead(item.id!);
            }
          } catch (e) {
            debugPrint('❌ [Notification] Navigation Error: $e');
            _showErrorSnackBar(context, 'Failed to open details');
          }
        } else {
          debugPrint('⚠️ [Notification] No valid ID found for navigation');
          _showNoActionDialog(context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          // ⭐ KEY CHANGE: Unread = Blue BG, Read = White BG
          color: isUnread ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread ? Colors.blue.shade200 : const Color(0xFFE2E8F0),
          ),
          boxShadow: isUnread
              ? [
            BoxShadow(
              color: Colors.blue.shade100.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(14),
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundColor:
                _getSeverityColor(item.severity).withOpacity(0.15),
                radius: 24,
                child: Icon(
                  _getCategoryIcon(item.category),
                  color: _getSeverityColor(item.severity),
                  size: 22,
                ),
              ),
              // ⭐ Unread = Blue Dot, Read = No Dot (বা চেক মার্ক)
              if (isUnread)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0052CC),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '•',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.title ?? 'No Title',
                  style: TextStyle(
                    // ⭐ Unread = Bold, Read = Normal
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                    color: isUnread
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.createdAt != null)
                Text(
                  _formatDate(item.createdAt!),
                  style: TextStyle(
                    fontSize: 11,
                    color: isUnread ? Colors.grey[700] : Colors.grey[500],
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                item.body ?? '',
                style: TextStyle(
                  fontSize: 13,
                  color: isUnread
                      ? const Color(0xFF334155)
                      : const Color(0xFF64748B),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0052CC).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 12,
                          color: Color(0xFF0052CC),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF0052CC),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ⭐ Unread = "Mark as Read" বাটন
                  if (isUnread) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onMarkRead,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 12,
                              color: AppColors.successGreen,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Mark as Read',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.successGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: isUnread
              ? Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF0052CC),
              shape: BoxShape.circle,
            ),
          )
              : Icon(
            Icons.check_circle,
            color: Colors.green.shade400,
            size: 20,
          ),
        ),
      ),
    );
  }

  // ─── Extract Target ID ──────────────────────────────────────────
  String? _extractTargetId(Items notification) {
    // 1. Check data payload (most reliable)
    if (notification.data != null) {
      final payload = notification.data!;
      final id = payload.applicationId ?? payload.loanId;
      if (id != null && id.isNotEmpty) return id;
    }

    // 2. Check action object
    if (notification.action != null && notification.action!.id != null) {
      return notification.action!.id;
    }

    return null;
  }

  // ─── Loading More Indicator ─────────────────────────────────────
  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF0052CC),
          ),
        ),
      ),
    );
  }

  // ─── Show Mark All Read Dialog ──────────────────────────────────
  void _showMarkAllReadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.done_all_rounded, color: const Color(0xFF0052CC)),
            const SizedBox(width: 8),
            const Text('Mark All as Read'),
          ],
        ),
        content: const Text(
          'Are you sure you want to mark all notifications as read?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _markAllAsRead();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052CC),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // ─── Show No Action Dialog ──────────────────────────────────────
  void _showNoActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('No Action Available'),
        content: const Text(
          'This notification does not have an associated loan application.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ─── Show Error SnackBar ────────────────────────────────────────
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─── Helper Methods ─────────────────────────────────────────────
  Color _getSeverityColor(String? severity) {
    switch (severity?.toUpperCase()) {
      case 'HIGH':
      case 'CRITICAL':
        return AppColors.errorRed;
      case 'MEDIUM':
      case 'WARNING':
        return Colors.orange;
      case 'LOW':
        return Colors.blue;
      default:
        return const Color(0xFF0052CC);
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toUpperCase()) {
      case 'LOAN':
      case 'APPLICATION':
        return Icons.assignment_outlined;
      case 'PAYMENT':
        return Icons.payment_outlined;
      case 'SYSTEM':
        return Icons.settings_outlined;
      case 'PROMOTION':
        return Icons.local_offer_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 7) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (_) {
      return isoString;
    }
  }
}