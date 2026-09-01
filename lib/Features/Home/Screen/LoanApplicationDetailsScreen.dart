import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constant/App_Colors.dart';
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../ViewModel/LoanApplicationViewModel.dart';

class LoanApplicationDetailsScreen extends StatefulWidget {
  final String applicationId;

  const LoanApplicationDetailsScreen({super.key, required this.applicationId});

  @override
  State<LoanApplicationDetailsScreen> createState() =>
      _LoanApplicationDetailsScreenState();
}

final AppStorage _storage = AppStorage();
String? userRole;

class _LoanApplicationDetailsScreenState
    extends State<LoanApplicationDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserRole();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
        '[DetailsScreen] Fetching details for ID: ${widget.applicationId}',
      );
      context.read<LoanApplicationViewModel>().fetchApplicationDetails(
        widget.applicationId,
      );
    });
  }

  Future<void> _loadUserRole() async {
    final role = await _storage.getUserRole();
    if (!mounted) return;
    setState(() {
      userRole = role;
    });
  }

  // 💡 তারিখ ফরম্যাট করার হেল্পার মেথড
  String _formatDate(String? dateStr) {
    if (dateStr == null ||
        dateStr.isEmpty ||
        dateStr == 'N/A' ||
        dateStr == 'null')
      return 'N/A';

    try {
      if (RegExp(r'^\d+$').hasMatch(dateStr)) {
        final day = int.tryParse(dateStr);
        if (day != null && day >= 1 && day <= 31) {
          String suffix = 'th';
          if (day % 10 == 1 && day % 100 != 11)
            suffix = 'st';
          else if (day % 10 == 2 && day % 100 != 12)
            suffix = 'nd';
          else if (day % 10 == 3 && day % 100 != 13)
            suffix = 'rd';
          return "$day$suffix of every month";
        }
      }

      DateTime? dt = DateTime.tryParse(dateStr);

      if (dt == null && dateStr.contains('-')) {
        List<String> parts = dateStr.split(' ')[0].split('-');
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            dt = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          } else {
            dt = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        }
      }

      if (dt != null) {
        return DateFormat('dd MMM yyyy').format(dt);
      }

      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canApproveReject = userRole != "SALES_PERSON";
    final currency = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.black,
            size: 20,
          ),
        ),
        title: const Text(
          'Application Details',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<LoanApplicationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.applicationDetails == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0052CC)),
            );
          }

          if (viewModel.errorMessage != null &&
              viewModel.applicationDetails == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.fetchApplicationDetails(
                        widget.applicationId,
                      ),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          }

          final app = viewModel.applicationDetails;
          if (app == null) return const Center(child: Text("No details found"));

          final String currentStatus = (app.status ?? '').toUpperCase().trim();
          final dataMap = viewModel.rawData ?? {};
          var guarantors =
              dataMap['customer']?['guarantors'] ?? dataMap['guarantors'] ?? [];

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBanner(currentStatus),

                if (currentStatus == 'REJECTED' &&
                    app.rejectionReason != null) ...[
                  const SizedBox(height: 16),
                  _buildRejectionReasonCard(app.rejectionReason!),
                ],

                if (currentStatus == 'APPROVED' &&
                    app.approvalRemarks != null) ...[
                  const SizedBox(height: 16),
                  _buildApprovalRemarksCard(app.approvalRemarks!),
                ],

                const SizedBox(height: 20),
                _sectionHeader("Applicant Information"),
                _buildInfoCard([
                  _infoRow("Application ID", app.displayId ?? 'N/A'),
                  _infoRow("Full Name", app.name ?? 'N/A'),
                  _infoRow("Phone", app.phone ?? 'N/A', isPhone: true),
                  _infoRow(
                    "${app.idType ?? 'NID'} Number",
                    app.nidPassportNumber ?? 'N/A',
                  ),
                  _infoRow("Source of Income", app.sourceOfIncome ?? 'N/A'),
                  _infoRow(
                    "Monthly Income",
                    "৳${currency.format(app.monthlyIncome ?? 0)}",
                  ),
                  _infoRow("Present Address", app.presentAddress ?? 'N/A'),
                  _infoRow("Permanent Address", app.permanentAddress ?? 'N/A'),
                ]),

                const SizedBox(height: 20),
                _sectionHeader("Loan Details"),
                _buildInfoCard([
                  _infoRow("Product", app.product?.name ?? 'N/A'),
                  _infoRow("MRP", "৳${currency.format(app.mrp ?? 0)}"),
                  _infoRow(
                    "Down Payment",
                    "৳${currency.format(app.downPayment ?? 0)} (${app.downPaymentMethod ?? 'N/A'})",
                  ),
                  _infoRow("Tenure", "${app.planMonths ?? 0} Months"),
                  _infoRow(
                    "Monthly EMI",
                    "৳${currency.format(app.monthlyEmi ?? 0)}",
                  ),
                  if (app.cashbackAmount != null && app.cashbackAmount! > 0)
                    _infoRow(
                      "Eligible Cashback",
                      "৳${currency.format(app.cashbackAmount ?? 0)}",
                    ),
                  _infoRow("Application Date", _formatDate(app.issueDate)),
                  _infoRow("Payment Date", _formatDate(app.nextPaymentDate)),
                ]),

                const SizedBox(height: 20),
                _sectionHeader("Customer Documents"),
                _buildCustomerDocumentSection(context, app),

                if (guarantors is List && guarantors.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _sectionHeader("Guarantor Details"),
                  ...guarantors.asMap().entries.map((entry) {
                    int index = entry.key;
                    var g = entry.value;
                    return _buildGuarantorCardWithDocuments(
                      context,
                      g,
                      index,
                      currency,
                    );
                  }).toList(),
                ],

                if (currentStatus == 'PENDING' && canApproveReject) ...[
                  const SizedBox(height: 40),
                  _buildActionButtons(
                    context,
                    viewModel,
                    app.id ?? widget.applicationId,
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Status Banner ───
  Widget _buildStatusBanner(String status) {
    Color color = Colors.orange;
    if (status == 'APPROVED') color = AppColors.successGreen;
    if (status == 'REJECTED') color = AppColors.errorRed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 20),
          const SizedBox(width: 10),
          Text(
            "Status: $status",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionReasonCard(String reason) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Rejection Reason:",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(reason, style: TextStyle(color: Colors.red.shade900)),
        ],
      ),
    );
  }

  Widget _buildApprovalRemarksCard(String remarks) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Approval Remarks:",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(remarks, style: TextStyle(color: Colors.green.shade900)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(String label, String value, {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
                if (isPhone && value.isNotEmpty && value != 'N/A')
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: () => _makePhoneCall(value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0052CC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.phone_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Call Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot call: $phoneNumber'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ─── ✅ UPDATED: Customer Document Section ───
// LoanApplicationDetailsScreen.dart - _buildCustomerDocumentSection ফাংশন আপডেট করুন

  Widget _buildCustomerDocumentSection(BuildContext context, dynamic app) {
    final List<Map<String, String>> docs = [];
    final viewModel = context.read<LoanApplicationViewModel>();
    final dataMap = viewModel.rawData ?? {};

    // 🔥 Get customer documents from dataMap
    var customerDocs = dataMap['customerDocuments'];
    if (customerDocs != null && customerDocs is List) {
      for (var doc in customerDocs) {
        String url = doc['url'] ?? doc['fileUrl'] ?? doc['path'] ?? '';
        String docType = doc['documentType'] ?? doc['type'] ?? 'DOCUMENT';
        if (url.isNotEmpty) {
          String label = _getDocumentLabel(docType);
          if (!docs.any((d) => d['url'] == url)) {
            docs.add({'label': label, 'url': url});
            debugPrint('📄 [UI] Added customer doc: $label -> $url');
          }
        }
      }
    }

    // 🔥 Also check direct fields from data (for backward compatibility)
    if (dataMap['customerImageUrl'] != null && dataMap['customerImageUrl'].toString().isNotEmpty) {
      String url = dataMap['customerImageUrl'].toString();
      if (!docs.any((d) => d['url'] == url)) {
        docs.add({'label': 'PHOTO', 'url': url});
      }
    }
    if (dataMap['customerVideoUrl'] != null && dataMap['customerVideoUrl'].toString().isNotEmpty) {
      String url = dataMap['customerVideoUrl'].toString();
      if (!docs.any((d) => d['url'] == url)) {
        docs.add({'label': 'VIDEO', 'url': url});
      }
    }
    if (dataMap['incomeProofUrl'] != null && dataMap['incomeProofUrl'].toString().isNotEmpty) {
      String url = dataMap['incomeProofUrl'].toString();
      if (!docs.any((d) => d['url'] == url)) {
        docs.add({'label': 'INCOME PROOF', 'url': url});
      }
    }

    debugPrint('📄 [UI] Total customer documents: ${docs.length}');

    if (docs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Text(
            'No documents uploaded',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final doc = docs[index];
          final isVideo = doc['label'] == 'VIDEO' || doc['label'] == 'Video';
          return _docThumbnail(
            doc['label']!,
            doc['url']!,
            isVideo,
            docs,
            index,
          );
        },
      ),
    );
  }

// ─── _getDocumentLabel ফাংশন আপডেট করুন ───
  String _getDocumentLabel(String docType) {
    final type = docType.toUpperCase();
    if (type.contains('PHOTO')) return 'PHOTO';
    if (type.contains('VIDEO')) return 'VIDEO';
    if (type.contains('NID_FRONT') || type.contains('NIDFRONT')) return 'NID FRONT';
    if (type.contains('NID_BACK') || type.contains('NIDBACK')) return 'NID BACK';
    if (type.contains('INCOME') || type.contains('SALARY')) return 'INCOME PROOF';
    if (type.contains('BANK')) return 'BANK RECEIPT';
    if (type.contains('CUSTOMER_PHOTO')) return 'PHOTO';
    if (type.contains('CUSTOMER_VIDEO')) return 'VIDEO';
    return docType.replaceAll('_', ' ').toUpperCase();
  }

// _buildGuarantorCardWithDocuments ফাংশন আপডেট করুন

  Widget _buildGuarantorCardWithDocuments(
      BuildContext context,
      dynamic g,
      int index,
      NumberFormat currency,
      ) {
    final viewModel = context.read<LoanApplicationViewModel>();
    final dataMap = viewModel.rawData ?? {};
    Map<String, dynamic> guarantorMap = g is Map<String, dynamic> ? g : {};
    final List<Map<String, String>> docs = [];

    // 🔥 Get guarantor documents from dataMap
    var guarantorDocs = dataMap['guarantorDocuments'] ?? [];
    if (guarantorDocs is List) {
      for (var doc in guarantorDocs) {
        if (doc['guarantorIndex'] == index) {
          String url = doc['url'] ?? '';
          if (url.isNotEmpty) {
            String label = _getDocumentLabel(doc['documentType'] ?? '');
            docs.add({'label': label, 'url': url});
            debugPrint('📄 [UI] Added guarantor $index doc: $label -> $url');
          }
        }
      }
    }

    debugPrint('📄 [UI] Guarantor $index has ${docs.length} documents');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                      child: Text(
                        guarantorMap['name']?[0].toUpperCase() ?? 'G',
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guarantorMap['name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "${guarantorMap['relationship'] ?? 'N/A'} • ${guarantorMap['phone'] ?? 'N/A'}",
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.phone_rounded,
                                  size: 18,
                                  color: AppColors.primaryBlue,
                                ),
                                onPressed: () =>
                                    _makePhoneCall(guarantorMap['phone']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  "${guarantorMap['idType'] ?? 'NID'} Number: ${guarantorMap['nidPassportNumber'] ?? 'N/A'}",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          // ─── Documents Section ───
          if (docs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  itemBuilder: (context, docIndex) => _docThumbnail(
                    docs[docIndex]['label']!,
                    docs[docIndex]['url']!,
                    false,
                    docs,
                    docIndex,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── UPDATED: Document Thumbnail with Slide Navigation ───
  Widget _docThumbnail(
    String label,
    String url,
    bool isVideo,
    List<Map<String, String>> allDocs,
    int currentIndex,
  ) {
    if (url.isEmpty) return const SizedBox.shrink();
    final fullUrl = ApiEndPoint.assetUrl(url);

    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 100,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                // 📌 Open full-screen slider viewer
                _showDocumentSlider(context, allDocs, currentIndex);
              },
              child: Stack(
                children: [
                  if (isVideo)
                    Container(
                      height: 80,
                      width: 100,
                      color: Colors.black,
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    )
                  else
                    Image.network(
                      fullUrl,
                      height: 80,
                      width: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 80,
                          width: 100,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF0052CC),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        height: 80,
                        width: 100,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  // 📌 Document count badge
                  if (allDocs.length > 1)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${currentIndex + 1}/${allDocs.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Video indicator
                  if (isVideo)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'VIDEO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ───  NEW: Document Slider Viewer ───
  void _showDocumentSlider(
    BuildContext context,
    List<Map<String, String>> documents,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _DocumentSliderViewer(
        documents: documents,
        initialIndex: initialIndex,
      ),
    );
  }

  // ─── NEW: Video Player (updated) ───
  void _showVideoPlayer(BuildContext context, String videoUrl, String title) {
    final controller = VideoPlayerController.network(videoUrl);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => FutureBuilder(
          future: controller.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              controller.play();
              return Dialog(
                backgroundColor: Colors.black,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (controller.value.isPlaying) {
                              controller.pause();
                            } else {
                              controller.play();
                            }
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            controller.dispose();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  // ─── ✅ NEW: Full Screen Image (for single image) ───
  void _showFullScreenImage(
    BuildContext context,
    String imageUrl,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Action Buttons ───
  Widget _buildActionButtons(
    BuildContext context,
    LoanApplicationViewModel viewModel,
    String id,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showRejectDialog(context, viewModel, id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.errorRed,
              side: const BorderSide(color: AppColors.errorRed),
            ),
            child: const Text("Reject"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showApproveDialog(context, viewModel, id),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052CC),
              foregroundColor: Colors.white,
            ),
            child: const Text("Approve"),
          ),
        ),
      ],
    );
  }

  void _showApproveDialog(
    BuildContext context,
    LoanApplicationViewModel viewModel,
    String id,
  ) {
    final remarksController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Approve Application"),
          content: TextField(
            controller: remarksController,
            decoration: const InputDecoration(hintText: "Remarks (optional)"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                bool success = await viewModel.approveApplication(
                  id,
                  remarksController.text,
                );
                if (success && mounted) {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    LoanApplicationViewModel viewModel,
    String id,
  ) {
    final remarksController = TextEditingController();
    String selectedReason = "Incomplete application";
    final reasons = [
      "Incomplete application",
      "KYC verification failed",
      "Credit score below minimum requirement",
      "Other (Specify Remarks)",
    ];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Reject Application"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedReason,
                isExpanded: true,
                items: reasons
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedReason = v!),
              ),
              TextField(
                controller: remarksController,
                decoration: const InputDecoration(hintText: "Remarks"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                bool success = await viewModel.rejectApplication(
                  id,
                  selectedReason,
                  remarksController.text,
                );
                if (success && mounted) {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ✅ NEW: Document Slider Viewer Widget ───
class _DocumentSliderViewer extends StatefulWidget {
  final List<Map<String, String>> documents;
  final int initialIndex;

  const _DocumentSliderViewer({
    required this.documents,
    required this.initialIndex,
  });

  @override
  State<_DocumentSliderViewer> createState() => _DocumentSliderViewerState();
}

class _DocumentSliderViewerState extends State<_DocumentSliderViewer> {
  late PageController _pageController;
  late int _currentIndex;
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Check if current document is video
    _checkVideoAndInitialize();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _checkVideoAndInitialize() async {
    final doc = widget.documents[_currentIndex];
    final isVideo = doc['label']?.toUpperCase().contains('VIDEO') ?? false;

    if (isVideo) {
      final url = ApiEndPoint.assetUrl(doc['url']!);
      _videoController = VideoPlayerController.network(url);
      await _videoController?.initialize();
      _videoController?.play();
      setState(() {
        _isVideoPlaying = true;
      });
    }
  }

  void _onPageChanged(int index) {
    // Dispose old video controller
    _videoController?.dispose();
    _videoController = null;

    setState(() {
      _currentIndex = index;
      _isVideoPlaying = false;
    });

    // Check if new page is video
    _checkVideoAndInitialize();
  }

  void _toggleVideoPlayback() {
    if (_videoController == null) return;

    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(0),
      child: Stack(
        children: [
          // ─── Page Viewer ───
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.documents.length,
            itemBuilder: (context, index) {
              final doc = widget.documents[index];
              final isVideo =
                  doc['label']?.toUpperCase().contains('VIDEO') ?? false;
              final url = ApiEndPoint.assetUrl(doc['url']!);
              final label = doc['label'] ?? 'Document';

              return Container(
                color: Colors.black,
                child: Center(
                  child: isVideo
                      ? _buildVideoViewer(url, label)
                      : _buildImageViewer(url, label),
                ),
              );
            },
          ),

          // ─── Top Bar ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Document count
                  Text(
                    '${_currentIndex + 1} / ${widget.documents.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Close button
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      _videoController?.dispose();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),

          // ─── Bottom Bar ───
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Document label
                  Text(
                    widget.documents[_currentIndex]['label'] ?? 'Document',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Navigation dots
                  if (widget.documents.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.documents.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  // Previous/Next buttons
                  if (widget.documents.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: _currentIndex > 0
                                ? () {
                                    _pageController.previousPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                            child: const Text(
                              'Previous',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed:
                                _currentIndex < widget.documents.length - 1
                                ? () {
                                    _pageController.nextPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                            child: const Text(
                              'Next',
                              style: TextStyle(color: Colors.white),
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

  // ─── Image Viewer ───
  Widget _buildImageViewer(String url, String label) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      child: Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
        errorBuilder: (_, __, ___) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.white, size: 64),
              SizedBox(height: 8),
              Text(
                'Failed to load image',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Video Viewer ───
  Widget _buildVideoViewer(String url, String label) {
    if (_videoController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: _toggleVideoPlayback,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
          // Play/Pause overlay
          if (!_videoController!.value.isPlaying)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 64,
              ),
            ),
        ],
      ),
    );
  }
}
