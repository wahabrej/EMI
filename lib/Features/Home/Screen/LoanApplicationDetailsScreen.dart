import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constant/App_Colors.dart';
import '../../../core/constant/Api_End_point.dart';
import '../ViewModel/LoanApplicationViewModel.dart';

class LoanApplicationDetailsScreen extends StatefulWidget {
  final String applicationId;

  const LoanApplicationDetailsScreen({super.key, required this.applicationId});

  @override
  State<LoanApplicationDetailsScreen> createState() =>
      _LoanApplicationDetailsScreenState();
}

class _LoanApplicationDetailsScreenState
    extends State<LoanApplicationDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
        '[DetailsScreen] Fetching details for ID: ${widget.applicationId}',
      );
      context.read<LoanApplicationViewModel>().fetchApplicationDetails(
        widget.applicationId,
      );
    });
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

          // 🔥 rawData থেকে guarantors নিন
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
                  _infoRow("Phone", app.phone ?? 'N/A'),
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
                  _infoRow("Application Date", app.issueDate ?? 'N/A'),
                ]),

                const SizedBox(height: 20),
                _sectionHeader("Customer Documents"),
                _buildCustomerDocumentSection(context, app),

                // 🔥 Guarantor Details - rawData থেকে
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

                if (currentStatus == 'PENDING') ...[
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

  Widget _infoRow(String label, String value) {
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
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Customer Document Section ───
  Widget _buildCustomerDocumentSection(BuildContext context, dynamic app) {
    final List<Map<String, String>> docs = [];

    final viewModel = context.read<LoanApplicationViewModel>();
    final dataMap = viewModel.rawData ?? {};

    debugPrint('📄 [Customer] DataMap Keys: ${dataMap.keys.join(', ')}');

    // ─── customerDocuments থেকে ডকুমেন্ট নিন ───
    var customerDocs = dataMap['customerDocuments'];
    if (customerDocs != null && customerDocs is List) {
      for (var doc in customerDocs) {
        String url = doc['url'] ?? doc['fileUrl'] ?? doc['path'] ?? '';
        String docType = doc['documentType'] ?? doc['type'] ?? 'DOCUMENT';
        if (url.isNotEmpty) {
          String label = _getDocumentLabel(docType);
          bool exists = docs.any((d) => d['url'] == url);
          if (!exists) {
            docs.add({'label': label, 'url': url});
          }
        }
      }
    }

    // ─── customer অবজেক্ট থেকে সরাসরি ডকুমেন্ট নিন ───
    if (dataMap['customer'] != null &&
        dataMap['customer'] is Map<String, dynamic>) {
      final customer = dataMap['customer'] as Map<String, dynamic>;
      debugPrint(
        '📄 [Customer] Checking customer object: ${customer.keys.join(', ')}',
      );

      // Photo
      String? photo = customer['customerImageUrl'] ?? customer['customerImage'];
      if (photo != null && photo.toString().isNotEmpty) {
        bool exists = docs.any((d) => d['url'] == photo);
        if (!exists) {
          docs.add({'label': 'PHOTO', 'url': photo.toString()});
        }
      }

      // Video
      String? video = customer['customerVideoUrl'] ?? customer['customerVideo'];
      if (video != null && video.toString().isNotEmpty) {
        bool exists = docs.any((d) => d['url'] == video);
        if (!exists) {
          docs.add({'label': 'VIDEO', 'url': video.toString()});
        }
      }

      // NID Front
      if (customer['customerNidFront'] != null &&
          customer['customerNidFront'].toString().isNotEmpty) {
        bool exists = docs.any(
          (d) => d['url'] == customer['customerNidFront'].toString(),
        );
        if (!exists) {
          docs.add({
            'label': 'NID FRONT',
            'url': customer['customerNidFront'].toString(),
          });
        }
      }

      // NID Back
      if (customer['customerNidBack'] != null &&
          customer['customerNidBack'].toString().isNotEmpty) {
        bool exists = docs.any(
          (d) => d['url'] == customer['customerNidBack'].toString(),
        );
        if (!exists) {
          docs.add({
            'label': 'NID BACK',
            'url': customer['customerNidBack'].toString(),
          });
        }
      }

      // Income Proof
      String? income =
          customer['incomeProofUrl'] ?? customer['incomeProofDocument'];
      if (income != null && income.toString().isNotEmpty) {
        bool exists = docs.any((d) => d['url'] == income);
        if (!exists) {
          docs.add({'label': 'INCOME PROOF', 'url': income.toString()});
        }
      }

      // Bank Receipt
      String? bank = customer['bankReceiptUrl'] ?? customer['bankReceipt'];
      if (bank != null && bank.toString().isNotEmpty) {
        bool exists = docs.any((d) => d['url'] == bank);
        if (!exists) {
          docs.add({'label': 'BANK RECEIPT', 'url': bank.toString()});
        }
      }
    }

    // ─── Direct fields from dataMap ───
    if (dataMap['customerImageUrl'] != null &&
        dataMap['customerImageUrl'].toString().isNotEmpty) {
      bool exists = docs.any(
        (d) => d['url'] == dataMap['customerImageUrl'].toString(),
      );
      if (!exists) {
        docs.add({
          'label': 'PHOTO',
          'url': dataMap['customerImageUrl'].toString(),
        });
      }
    }

    if (dataMap['customerVideoUrl'] != null &&
        dataMap['customerVideoUrl'].toString().isNotEmpty) {
      bool exists = docs.any(
        (d) => d['url'] == dataMap['customerVideoUrl'].toString(),
      );
      if (!exists) {
        docs.add({
          'label': 'VIDEO',
          'url': dataMap['customerVideoUrl'].toString(),
        });
      }
    }

    if (dataMap['incomeProofUrl'] != null &&
        dataMap['incomeProofUrl'].toString().isNotEmpty) {
      bool exists = docs.any(
        (d) => d['url'] == dataMap['incomeProofUrl'].toString(),
      );
      if (!exists) {
        docs.add({
          'label': 'INCOME PROOF',
          'url': dataMap['incomeProofUrl'].toString(),
        });
      }
    }

    if (dataMap['bankReceiptUrl'] != null &&
        dataMap['bankReceiptUrl'].toString().isNotEmpty) {
      bool exists = docs.any(
        (d) => d['url'] == dataMap['bankReceiptUrl'].toString(),
      );
      if (!exists) {
        docs.add({
          'label': 'BANK RECEIPT',
          'url': dataMap['bankReceiptUrl'].toString(),
        });
      }
    }

    debugPrint('📄 [Customer] Total Documents Found: ${docs.length}');
    for (var doc in docs) {
      debugPrint('📄 [Customer] - ${doc['label']}: ${doc['url']}');
    }

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
          return _docThumbnail(doc['label']!, doc['url']!, isVideo);
        },
      ),
    );
  }

  // ─── Document Label Helper ───
  String _getDocumentLabel(String docType) {
    final type = docType.toUpperCase();
    if (type.contains('PHOTO') || type.contains('CUSTOMER_PHOTO'))
      return 'PHOTO';
    if (type.contains('VIDEO') || type.contains('CUSTOMER_VIDEO'))
      return 'VIDEO';
    if (type.contains('NID_FRONT')) return 'NID FRONT';
    if (type.contains('NID_BACK')) return 'NID BACK';
    if (type.contains('INCOME')) return 'INCOME PROOF';
    if (type.contains('BANK')) return 'BANK RECEIPT';
    if (type.contains('GUARANTOR')) return 'GUARANTOR DOC';
    return docType.replaceAll('_', ' ').toUpperCase();
  }

  // ─── Guarantor Card with Documents ───
  Widget _buildGuarantorCardWithDocuments(
    BuildContext context,
    dynamic g,
    int index,
    NumberFormat currency,
  ) {
    debugPrint('═══════════════════════════════════════════════════');
    debugPrint(
      '📄 [Guarantor $index] ========== BUILDING GUARANTOR CARD ==========',
    );

    final viewModel = context.read<LoanApplicationViewModel>();
    final dataMap = viewModel.rawData ?? {};

    // 🔥 g যদি Map হয়, তাহলে Map হিসেবে ব্যবহার করুন
    Map<String, dynamic> guarantorMap;
    if (g is Map<String, dynamic>) {
      guarantorMap = g;
    } else {
      // যদি Object হয়, তাহলে toJson() ব্যবহার করুন
      try {
        guarantorMap = g.toJson() as Map<String, dynamic>;
      } catch (_) {
        guarantorMap = {};
      }
    }

    debugPrint('📄 [Guarantor $index] Name: ${guarantorMap['name'] ?? 'NULL'}');
    debugPrint(
      '📄 [Guarantor $index] Phone: ${guarantorMap['phone'] ?? 'NULL'}',
    );
    debugPrint(
      '📄 [Guarantor $index] Relationship: ${guarantorMap['relationship'] ?? 'NULL'}',
    );
    debugPrint(
      '📄 [Guarantor $index] NID Front: ${guarantorMap['nidFront'] ?? 'NULL'}',
    );
    debugPrint(
      '📄 [Guarantor $index] NID Back: ${guarantorMap['nidBack'] ?? 'NULL'}',
    );
    debugPrint(
      '📄 [Guarantor $index] ID Type: ${guarantorMap['idType'] ?? 'NULL'}',
    );
    debugPrint(
      '📄 [Guarantor $index] NID/Passport Number: ${guarantorMap['nidPassportNumber'] ?? 'NULL'}',
    );
    debugPrint('📄 [Guarantor $index] Type: ${guarantorMap['type'] ?? 'NULL'}');

    // ─── Raw Data থেকে guarantorDocuments চেক করুন ───
    debugPrint(
      '📄 [Guarantor $index] Raw Data Keys: ${dataMap.keys.join(', ')}',
    );

    var guarantorDocs = dataMap['guarantorDocuments'] ?? [];
    debugPrint(
      '📄 [Guarantor $index] guarantorDocs Type: ${guarantorDocs.runtimeType}',
    );
    debugPrint(
      '📄 [Guarantor $index] guarantorDocs Length: ${guarantorDocs is List ? guarantorDocs.length : 'NOT A LIST'}',
    );

    if (guarantorDocs is List) {
      for (int i = 0; i < guarantorDocs.length; i++) {
        final doc = guarantorDocs[i];
        debugPrint('📄 [Guarantor $index] Doc $i: $doc');
      }
    }

    final List<Map<String, String>> docs = [];

    debugPrint('📄 [Guarantor $index] Looking for documents...');

    // ─── guarantorDocuments ───
    if (guarantorDocs is List) {
      for (var doc in guarantorDocs) {
        int? guarantorIndex = doc['guarantorIndex'] ?? doc['index'];
        debugPrint(
          '📄 [Guarantor $index] Checking doc with guarantorIndex: $guarantorIndex',
        );

        if (guarantorIndex == index || guarantorIndex == null) {
          String url = doc['url'] ?? doc['fileUrl'] ?? doc['path'] ?? '';
          String docType = doc['documentType'] ?? doc['type'] ?? 'DOCUMENT';
          debugPrint(
            '📄 [Guarantor $index] Found doc - URL: $url, Type: $docType',
          );

          if (url.isNotEmpty) {
            String label = _getDocumentLabel(docType);
            bool exists = docs.any((d) => d['url'] == url);
            if (!exists) {
              docs.add({'label': label, 'url': url});
              debugPrint('📄 [Guarantor $index] Added doc: $label -> $url');
            } else {
              debugPrint('📄 [Guarantor $index] Doc already exists: $label');
            }
          } else {
            debugPrint('📄 [Guarantor $index] URL is empty for doc: $doc');
          }
        } else {
          debugPrint(
            '📄 [Guarantor $index] Skipping doc - index mismatch: $guarantorIndex != $index',
          );
        }
      }
    }

    // ─── Guarantor এর নিজস্ব NID চেক করুন (Map থেকে) ───
    String? nidFront = guarantorMap['nidFront'];
    debugPrint('📄 [Guarantor $index] Checking nidFront: $nidFront');
    if (nidFront != null && nidFront.isNotEmpty) {
      bool exists = docs.any((d) => d['url'] == nidFront);
      if (!exists) {
        docs.add({'label': 'NID FRONT', 'url': nidFront});
        debugPrint(
          '📄 [Guarantor $index] Added NID FRONT from nidFront: $nidFront',
        );
      } else {
        debugPrint('📄 [Guarantor $index] NID FRONT already exists');
      }
    }

    String? nidBack = guarantorMap['nidBack'];
    debugPrint('📄 [Guarantor $index] Checking nidBack: $nidBack');
    if (nidBack != null && nidBack.isNotEmpty) {
      bool exists = docs.any((d) => d['url'] == nidBack);
      if (!exists) {
        docs.add({'label': 'NID BACK', 'url': nidBack});
        debugPrint(
          '📄 [Guarantor $index] Added NID BACK from nidBack: $nidBack',
        );
      } else {
        debugPrint('📄 [Guarantor $index] NID BACK already exists');
      }
    }

    debugPrint('📄 [Guarantor $index] Total Documents Found: ${docs.length}');
    for (int i = 0; i < docs.length; i++) {
      debugPrint(
        '📄 [Guarantor $index]   Doc ${i + 1}: ${docs[i]['label']} -> ${docs[i]['url']}',
      );
    }
    debugPrint('═══════════════════════════════════════════════════');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Guarantor Info ───
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
                        guarantorMap['name']?.isNotEmpty == true
                            ? guarantorMap['name'][0].toUpperCase()
                            : 'G',
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
                          Text(
                            "${guarantorMap['relationship'] ?? 'N/A'} • ${guarantorMap['phone'] ?? 'N/A'}",
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.infoBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        guarantorMap['relationship'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.infoBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "${guarantorMap['idType'] ?? 'NID'} Number: ${guarantorMap['nidPassportNumber'] ?? 'N/A'}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ─── Divider ───
          if (docs.isNotEmpty)
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // ─── Guarantor Documents ───
          if (docs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Documents',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      itemBuilder: (context, docIndex) {
                        final doc = docs[docIndex];
                        return _docThumbnail(doc['label']!, doc['url']!, false);
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _docThumbnail(String label, String url, [bool isVideo = false]) {
    if (url.isEmpty) return const SizedBox.shrink();

    final fullUrl = ApiEndPoint.assetUrl(url);

    debugPrint(
      '[DocThumbnail] Label: $label, URL: $fullUrl, isVideo: $isVideo',
    );

    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                if (isVideo) {
                  _showVideoPlayer(context, fullUrl, label);
                } else {
                  _showFullScreenImage(context, fullUrl, label);
                }
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
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        height: 80,
                        width: 100,
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'No Image',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (isVideo)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── Video Player ───
  // ─── Video Player with VideoPlayerController ───
  void _showVideoPlayer(BuildContext context, String videoUrl, String title) {
    debugPrint('🎬 [VideoPlayer] Opening video: $videoUrl');

    // VideoPlayerController ব্যবহার করুন
    final controller = VideoPlayerController.network(videoUrl);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FutureBuilder(
              future: controller.initialize(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  //
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Loading video...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Failed to load video',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                //
                controller.play();
                return Dialog(
                  backgroundColor: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VideoPlayer(controller),
                          ),
                        ),
                        // Play/Pause Button
                        Positioned.fill(
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (controller.value.isPlaying) {
                                    controller.pause();
                                  } else {
                                    controller.play();
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Close Button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                controller.dispose();
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        // Title
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Video Progress
                        Positioned(
                          bottom: 50,
                          left: 16,
                          right: 16,
                          child: VideoProgressIndicator(
                            controller,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: Colors.blue,
                              bufferedColor: Colors.grey,
                              backgroundColor: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ─── Full Screen Image ───
  void _showFullScreenImage(
    BuildContext context,
    String imageUrl,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.9)),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                    errorBuilder: (_, __, ___) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
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
            onPressed: viewModel.isLoading
                ? null
                : () => _showRejectDialog(context, viewModel, id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.errorRed,
              side: const BorderSide(color: AppColors.errorRed),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Reject",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () => _showApproveDialog(context, viewModel, id),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052CC),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Approve",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Are you sure you want to approve this loan application?",
              ),
              const SizedBox(height: 16),
              TextField(
                controller: remarksController,
                decoration: const InputDecoration(
                  hintText: "Enter approval remarks (optional)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: viewModel.isLoading ? null : () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                      bool success = await viewModel.approveApplication(
                        id,
                        remarksController.text,
                      );
                      if (success && mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Application Approved Successfully"),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                        Navigator.pop(context);
                      } else if (viewModel.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(viewModel.errorMessage!),
                            backgroundColor: AppColors.errorRed,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0052CC),
              ),
              child: viewModel.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Confirm Approval",
                      style: TextStyle(color: Colors.white),
                    ),
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
    final List<String> rejectionReasons = [
      "Incomplete application",
      "KYC verification failed",
      "Credit score below minimum requirement",
      "Other (Specify Remarks)",
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Reject Application"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Rejection Reason:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedReason,
                      isExpanded: true,
                      items: rejectionReasons
                          .map(
                            (String v) =>
                                DropdownMenuItem(value: v, child: Text(v)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => selectedReason = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Remarks:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: remarksController,
                  decoration: InputDecoration(
                    hintText: selectedReason == "Other (Specify Remarks)"
                        ? "Explain 'Other' reason (Mandatory)"
                        : "Additional notes (Optional)",
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: viewModel.isLoading ? null : () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                      if (selectedReason == "Other (Specify Remarks)" &&
                          remarksController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please provide remarks for 'Other' reason",
                            ),
                          ),
                        );
                        return;
                      }
                      bool success = await viewModel.rejectApplication(
                        id,
                        selectedReason,
                        remarksController.text.trim(),
                      );
                      if (success && mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Application Rejected"),
                            backgroundColor: AppColors.errorRed,
                          ),
                        );
                        Navigator.pop(context);
                      } else if (viewModel.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(viewModel.errorMessage!),
                            backgroundColor: AppColors.errorRed,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
              ),
              child: viewModel.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Confirm Reject",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
