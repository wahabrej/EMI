import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constant/App_Colors.dart';
import '../../../core/constant/Api_End_point.dart';
import '../Model/customer_detail_model.dart';
import '../ViewModel/CustomerDetailViewModel.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailsScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerDetailViewModel>().fetchCustomerDetail(
        widget.customerId,
      );
    });
  }

  void _makePhoneCall(String phoneNumber) async {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      await launchUrl(phoneUri);
    } catch (e) {
      print('Call error: $e');
    }
  }

  // 📌 ডকুমেন্ট কালেকশন ফাংশন - ভিডিও সহ
  List<Map<String, String>> _collectCustomerDocuments(CustomerData customer) {
    List<Map<String, String>> documents = [];

    if (customer == null) return documents;

    // ১. Direct document fields
    if (customer.nidFront != null && customer.nidFront!.isNotEmpty) {
      documents.add({'label': 'NID FRONT', 'url': customer.nidFront!});
      debugPrint('📄 [Screen] Added NID Front: ${customer.nidFront}');
    }
    if (customer.nidBack != null && customer.nidBack!.isNotEmpty) {
      documents.add({'label': 'NID BACK', 'url': customer.nidBack!});
      debugPrint('📄 [Screen] Added NID Back: ${customer.nidBack}');
    }
    if (customer.incomeProof != null && customer.incomeProof!.isNotEmpty) {
      documents.add({'label': 'INCOME PROOF', 'url': customer.incomeProof!});
      debugPrint('📄 [Screen] Added Income Proof: ${customer.incomeProof}');
    }
    if (customer.profileImage != null && customer.profileImage!.isNotEmpty) {
      documents.add({'label': 'PROFILE PHOTO', 'url': customer.profileImage!});
      debugPrint('📄 [Screen] Added Profile Photo: ${customer.profileImage}');
    }

    // 📌 ভিডিও ডকুমেন্ট
    if (customer.customerVideo != null && customer.customerVideo!.isNotEmpty) {
      documents.add({'label': 'VIDEO', 'url': customer.customerVideo!});
      debugPrint('📄 [Screen] Added Customer Video: ${customer.customerVideo}');
    }
    if (customer.customerVideoUrl != null &&
        customer.customerVideoUrl!.isNotEmpty) {
      if (!documents.any((d) => d['url'] == customer.customerVideoUrl)) {
        documents.add({'label': 'VIDEO', 'url': customer.customerVideoUrl!});
        debugPrint(
          '📄 [Screen] Added Customer Video URL: ${customer.customerVideoUrl}',
        );
      }
    }

    // ২. customerDocuments অ্যারে (ভিডিও সহ)
    if (customer.customerDocuments != null) {
      for (var doc in customer.customerDocuments!) {
        String? url = doc.validUrl;
        if (url != null && url.isNotEmpty) {
          String label = doc.displayLabel;
          if (!documents.any((d) => d['url'] == url)) {
            documents.add({'label': label, 'url': url});
            debugPrint('📄 [Screen] Added doc from array: $label');
          }
        }
      }
    }

    debugPrint('📄 [Screen] Total documents: ${documents.length}');
    return documents;
  }

  // 📌 গ্যারান্টরের ডকুমেন্ট কালেকশন (ভিডিও সহ)
  List<Map<String, String>> _collectGuarantorDocuments(Guarantor guarantor) {
    List<Map<String, String>> documents = [];

    if (guarantor == null) return documents;

    // ১. Direct fields
    if (guarantor.nidFront != null && guarantor.nidFront!.isNotEmpty) {
      documents.add({'label': 'NID FRONT', 'url': guarantor.nidFront!});
      debugPrint('📄 [Screen] Guarantor NID Front: ${guarantor.nidFront}');
    }
    if (guarantor.nidBack != null && guarantor.nidBack!.isNotEmpty) {
      documents.add({'label': 'NID BACK', 'url': guarantor.nidBack!});
      debugPrint('📄 [Screen] Guarantor NID Back: ${guarantor.nidBack}');
    }
    if (guarantor.profileImage != null && guarantor.profileImage!.isNotEmpty) {
      documents.add({'label': 'PHOTO', 'url': guarantor.profileImage!});
    }

    // 📌 গ্যারান্টরের ভিডিও
    if (guarantor.guarantorVideo != null &&
        guarantor.guarantorVideo!.isNotEmpty) {
      documents.add({'label': 'VIDEO', 'url': guarantor.guarantorVideo!});
      debugPrint('📄 [Screen] Guarantor Video: ${guarantor.guarantorVideo}');
    }
    if (guarantor.guarantorVideoUrl != null &&
        guarantor.guarantorVideoUrl!.isNotEmpty) {
      if (!documents.any((d) => d['url'] == guarantor.guarantorVideoUrl)) {
        documents.add({'label': 'VIDEO', 'url': guarantor.guarantorVideoUrl!});
      }
    }

    // ২. documents অ্যারে
    if (guarantor.documents != null) {
      for (var doc in guarantor.documents!) {
        String? url = doc.validUrl;
        if (url != null && url.isNotEmpty) {
          String label = doc.displayLabel;
          if (!documents.any((d) => d['url'] == url)) {
            documents.add({'label': label, 'url': url});
          }
        }
      }
    }

    return documents;
  }

  @override
  Widget build(BuildContext context) {
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
          'Customer Details',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<CustomerDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0052CC)),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  viewModel.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final customer = viewModel.customerDetail;
          if (customer == null) {
            return const Center(child: Text("No details found"));
          }

          // 📌 ডকুমেন্ট কালেক্ট করা
          List<Map<String, String>> customerDocs = _collectCustomerDocuments(
            customer,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(customer),
                const SizedBox(height: 24),

                _sectionHeader("Personal Information"),
                _buildInfoCard([
                  _infoRow("Full Name", customer.name ?? 'N/A'),
                  _infoRow("Phone", customer.phone ?? 'N/A', isPhone: true),
                  _infoRow("Email", customer.email ?? 'N/A'),
                  _infoRow("NID/Passport", customer.nidPassportNumber ?? 'N/A'),
                  _infoRow(
                    "Source of Income",
                    customer.sourceOfIncome ?? 'N/A',
                  ),
                  _infoRow(
                    "Monthly Income",
                    "৳${currency.format(customer.monthlyIncome ?? 0)}",
                  ),
                  _infoRow("Present Address", customer.presentAddress ?? 'N/A'),
                  _infoRow(
                    "Permanent Address",
                    customer.permanentAddress ?? 'N/A',
                  ),
                ]),

                // 📌 কাস্টমার ডকুমেন্ট সেকশন
                if (customerDocs.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionHeader("Documents (${customerDocs.length})"),
                  _buildDocumentSection(customerDocs),
                ] else ...[
                  const SizedBox(height: 24),
                  _sectionHeader("Documents"),
                  Container(
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
                  ),
                ],

                if (customer.activeLoans != null &&
                    customer.activeLoans!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionHeader("Active Loans"),
                  ...customer.activeLoans!
                      .map((loan) => _buildLoanCard(loan, currency))
                      .toList(),
                ],

                // 📌 গ্যারান্টর সেকশন
                if (customer.guarantors != null &&
                    customer.guarantors!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionHeader("Guarantor Details"),
                  ...customer.guarantors!
                      .map((g) => _buildGuarantorCard(g))
                      .toList(),
                ],

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Profile Header ───
  Widget _buildProfileHeader(CustomerData customer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFFEFF6FF),
            backgroundImage:
            customer.profileImage != null &&
                customer.profileImage!.isNotEmpty
                ? NetworkImage(_getFullUrl(customer.profileImage!))
                : null,
            child:
            customer.profileImage == null || customer.profileImage!.isEmpty
                ? Text(
              customer.name != null && customer.name!.isNotEmpty
                  ? customer.name![0].toUpperCase()
                  : 'C',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0052CC),
              ),
            )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "ID: ${customer.displayId ?? 'N/A'}",
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: customer.status?.toUpperCase() == 'ACTIVE'
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    customer.status ?? 'ACTIVE',
                    style: TextStyle(
                      color: customer.status?.toUpperCase() == 'ACTIVE'
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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

  // ─── Section Header ───
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

  // ─── Info Card ───
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

  // ─── Info Row ───
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
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isPhone && value.isNotEmpty && value != 'N/A')
                  GestureDetector(
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📌 ডকুমেন্ট সেকশন - হরাইজন্টাল স্ক্রল
  Widget _buildDocumentSection(List<Map<String, String>> documents) {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final doc = documents[index];
          final isVideo =
              doc['label']?.toUpperCase().contains('VIDEO') ?? false;
          return _docThumbnail(
            doc['label'] ?? 'DOCUMENT',
            doc['url'] ?? '',
            isVideo,
            documents, // 📌 All documents list pass করছি
            index, // 📌 Current index pass করছি
          );
        },
      ),
    );
  }

  // 📌 ফুল URL জেনারেট
  String _getFullUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return ApiEndPoint.assetUrl(url);
  }

  // 📌 ডকুমেন্ট থাম্বনেইল (Slider সাপোর্ট সহ)
  Widget _docThumbnail(
      String label,
      String url,
      bool isVideo,
      List<Map<String, String>> allDocs,
      int currentIndex,
      ) {
    if (url.isEmpty) return const SizedBox.shrink();

    final fullUrl = _getFullUrl(url);

    bool isVideoFile =
        isVideo ||
            label.toUpperCase().contains('VIDEO') ||
            url.toLowerCase().endsWith('.mp4') ||
            url.toLowerCase().endsWith('.mov') ||
            url.toLowerCase().endsWith('.avi') ||
            url.toLowerCase().endsWith('.mkv') ||
            url.toLowerCase().endsWith('.webm');

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
                _showDocumentSlider(
                  context,
                  allDocs,
                  currentIndex,
                );
              },
              child: Container(
                height: 80,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isVideoFile
                    ? Stack(
                  children: [
                    Container(
                      height: 80,
                      width: 100,
                      color: Colors.black87,
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 50,
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
                )
                    : Stack(
                  children: [
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
                          child: Center(
                            child: CircularProgressIndicator(
                              value:
                              loadingProgress.expectedTotalBytes !=
                                  null
                                  ? loadingProgress
                                  .cumulativeBytesLoaded /
                                  loadingProgress
                                      .expectedTotalBytes!
                                  : null,
                              color: const Color(0xFF0052CC),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        height: 80,
                        width: 100,
                        color: Colors.grey[200],
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 30,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Failed',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 📌 NEW: Document Slider Viewer
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

  // 📌 ভিডিও প্লেয়ার (Single video for backward compatibility)
  void _showVideoPlayer(BuildContext context, String videoUrl, String title) {
    final controller = VideoPlayerController.network(videoUrl);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: FutureBuilder(
          future: controller.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 300,
                width: 300,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            if (snapshot.hasError) {
              return SizedBox(
                height: 300,
                width: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 8),
                      const Text(
                        'Error loading video',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Close',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            controller.play();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
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
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          controller.dispose();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── Loan Card ───
  Widget _buildLoanCard(ActiveLoan loan, NumberFormat currency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loan.productName ?? 'Unknown Loan',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: loan.status?.toUpperCase() == 'ACTIVE'
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  loan.status ?? '',
                  style: TextStyle(
                    color: loan.status?.toUpperCase() == 'ACTIVE'
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _loanStat("Total", "৳${currency.format(loan.totalAmount ?? 0)}"),
              _loanStat(
                "Paid",
                "৳${currency.format(loan.paidAmount ?? 0)}",
                color: const Color(0xFF10B981),
              ),
              _loanStat(
                "Remaining",
                "৳${currency.format(loan.remainingAmount ?? 0)}",
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loanStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // ─── Guarantor Card with Documents ───
  Widget _buildGuarantorCard(Guarantor g) {
    // 📌 গ্যারান্টরের ডকুমেন্ট কালেক্ট করা
    List<Map<String, String>> guarantorDocs = _collectGuarantorDocuments(g);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  g.name != null && g.name!.isNotEmpty
                      ? g.name![0].toUpperCase()
                      : 'G',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0052CC),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.name ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "${g.relationship ?? 'N/A'} • ${g.phone ?? 'N/A'}",
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                        if (g.phone != null && g.phone!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.phone_rounded,
                              size: 18,
                              color: Color(0xFF0052CC),
                            ),
                            onPressed: () => _makePhoneCall(g.phone!),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      "${g.idType ?? 'NID'} Number: ${g.nidPassportNumber ?? 'N/A'}",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (guarantorDocs.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Documents:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: guarantorDocs.length,
                itemBuilder: (context, index) {
                  final doc = guarantorDocs[index];
                  final isVideo =
                      doc['label']?.toUpperCase().contains('VIDEO') ?? false;
                  return _docThumbnail(
                    doc['label'] ?? 'DOCUMENT',
                    doc['url'] ?? '',
                    isVideo,
                    guarantorDocs, // 📌 All documents list
                    index, // 📌 Current index
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── ✅ Document Slider Viewer Widget ───
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
    _videoController?.dispose();
    _videoController = null;

    setState(() {
      _currentIndex = index;
      _isVideoPlaying = false;
    });

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
              final isVideo = doc['label']?.toUpperCase().contains('VIDEO') ?? false;
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
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentIndex + 1} / ${widget.documents.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                                duration: const Duration(milliseconds: 300),
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
                            onPressed: _currentIndex < widget.documents.length - 1
                                ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
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
              Icon(
                Icons.broken_image,
                color: Colors.white,
                size: 64,
              ),
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