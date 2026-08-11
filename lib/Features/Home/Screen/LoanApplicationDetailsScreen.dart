import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constant/App_Colors.dart';
import '../../../core/constant/Api_End_point.dart';
import '../ViewModel/LoanApplicationViewModel.dart';

class LoanApplicationDetailsScreen extends StatefulWidget {
  final String applicationId;

  const LoanApplicationDetailsScreen({super.key, required this.applicationId});

  @override
  State<LoanApplicationDetailsScreen> createState() => _LoanApplicationDetailsScreenState();
}

class _LoanApplicationDetailsScreenState extends State<LoanApplicationDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔍 [DetailsScreen] Fetching details for ID: ${widget.applicationId}');
      context.read<LoanApplicationViewModel>().fetchApplicationDetails(widget.applicationId);
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
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.black, size: 20),
        ),
        title: const Text('Application Details',
            style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Consumer<LoanApplicationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.applicationDetails == null) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0052CC)));
          }

          if (viewModel.errorMessage != null && viewModel.applicationDetails == null) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(viewModel.errorMessage!,
                      textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchApplicationDetails(widget.applicationId),
                    child: const Text("Retry"),
                  )
                ],
              ),
            ));
          }

          final app = viewModel.applicationDetails;
          if (app == null) return const Center(child: Text("No details found"));

          final String currentStatus = (app.status ?? '').toUpperCase().trim();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBanner(currentStatus),

                if (currentStatus == 'REJECTED' && app.rejectionReason != null) ...[
                  const SizedBox(height: 16),
                  _buildRejectionReasonCard(app.rejectionReason!),
                ],

                if (currentStatus == 'APPROVED' && app.approvalRemarks != null) ...[
                  const SizedBox(height: 16),
                  _buildApprovalRemarksCard(app.approvalRemarks!),
                ],

                const SizedBox(height: 20),
                _sectionHeader("Applicant Information"),
                _buildInfoCard([
                  _infoRow("Application ID", app.displayId ?? 'N/A'),
                  _infoRow("Full Name", app.name ?? 'N/A'),
                  _infoRow("Phone", app.phone ?? 'N/A'),
                  _infoRow("${app.idType ?? 'NID'} Number", app.nidPassportNumber ?? 'N/A'),
                  _infoRow("Source of Income", app.sourceOfIncome ?? 'N/A'),
                  _infoRow("Monthly Income", "৳${currency.format(app.monthlyIncome ?? 0)}"),
                  _infoRow("Present Address", app.presentAddress ?? 'N/A'),
                  _infoRow("Permanent Address", app.permanentAddress ?? 'N/A'),
                ]),

                const SizedBox(height: 20),
                _sectionHeader("Loan Details"),
                _buildInfoCard([
                  _infoRow("Product", app.product?.name ?? 'N/A'),
                  _infoRow("MRP", "৳${currency.format(app.mrp ?? 0)}"),
                  _infoRow("Down Payment", "৳${currency.format(app.downPayment ?? 0)} (${app.downPaymentMethod ?? 'N/A'})"),
                  _infoRow("Tenure", "${app.planMonths ?? 0} Months"),
                  _infoRow("Monthly EMI", "৳${currency.format(app.monthlyEmi ?? 0)}"),
                  _infoRow("Application Date", app.issueDate ?? 'N/A'),
                ]),

                const SizedBox(height: 20),
                _sectionHeader("Documents"),
                _buildDocumentSection(app),

                if (app.guarantors != null && app.guarantors!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _sectionHeader("Guarantor Details"),
                  ...app.guarantors!.map((g) => _buildGuarantorCard(g, currency)).toList(),
                ],
                
                if (currentStatus == 'PENDING') ...[
                  const SizedBox(height: 40),
                  _buildActionButtons(context, viewModel, app.id ?? widget.applicationId),
                ],
                
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

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
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
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
          const Text("Rejection Reason:", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
          const Text("Approval Remarks:", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
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
            child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection(dynamic app) {
    final isPassport = (app.idType ?? 'NID').toString().toUpperCase() == 'PASSPORT';
    
    final docs = [
      if (app.customerImage != null) {'label': 'Photo', 'url': app.customerImage},
      if (isPassport) ...[
        if (app.customerNidFront != null) {'label': 'Passport Copy', 'url': app.customerNidFront},
      ] else ...[
        if (app.customerNidFront != null) {'label': 'NID Front', 'url': app.customerNidFront},
        if (app.customerNidBack != null) {'label': 'NID Back', 'url': app.customerNidBack},
      ],
      if (app.incomeProofDocument != null) {'label': 'Income Proof', 'url': app.incomeProofDocument},
    ];

    if (docs.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: docs.length,
        itemBuilder: (context, index) => _docThumbnail(docs[index]['label']!, docs[index]['url']!),
      ),
    );
  }

  Widget _docThumbnail(String label, String? url) {
    if (url == null) return const SizedBox.shrink();
    final fullUrl = ApiEndPoint.assetUrl(url);

    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 100,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              fullUrl,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 100, width: 100, color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildGuarantorCard(dynamic g, NumberFormat currency) {
    final isPassport = (g.idType ?? 'NID').toString().toUpperCase() == 'PASSPORT';
    
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
          Text(g.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text("${g.relationship} • ${g.phone}", style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 8),
          Text("${g.idType ?? 'NID'} Number: ${g.nidPassportNumber ?? 'N/A'}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (isPassport) ...[
                  if (g.nidFront != null) _docThumbnail("Passport Copy", g.nidFront),
                ] else ...[
                  if (g.nidFront != null) _docThumbnail("NID Front", g.nidFront),
                  if (g.nidBack != null) _docThumbnail("NID Back", g.nidBack),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, LoanApplicationViewModel viewModel, String id) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: viewModel.isLoading ? null : () => _showRejectDialog(context, viewModel, id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.errorRed,
              side: const BorderSide(color: AppColors.errorRed),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text("Reject", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: viewModel.isLoading ? null : () => _showApproveDialog(context, viewModel, id),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052CC),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text("Approve", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _showApproveDialog(BuildContext context, LoanApplicationViewModel viewModel, String id) {
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
              const Text("Are you sure you want to approve this loan application?"),
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
            TextButton(onPressed: viewModel.isLoading ? null : () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: viewModel.isLoading ? null : () async {
                bool success = await viewModel.approveApplication(id, remarksController.text);
                if (success && mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Application Approved Successfully"), backgroundColor: AppColors.successGreen));
                  Navigator.pop(context);
                } else if (viewModel.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!), backgroundColor: AppColors.errorRed));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0052CC)),
              child: viewModel.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Confirm Approval", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, LoanApplicationViewModel viewModel, String id) {
    final remarksController = TextEditingController();
    String selectedReason = "Incomplete application";
    final List<String> rejectionReasons = ["Incomplete application", "KYC verification failed", "Credit score below minimum requirement", "Other (Specify Remarks)"];

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
                const Text("Select Rejection Reason:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedReason,
                      isExpanded: true,
                      items: rejectionReasons.map((String v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (v) => setDialogState(() => selectedReason = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Remarks:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: remarksController,
                  decoration: InputDecoration(hintText: selectedReason == "Other (Specify Remarks)" ? "Explain 'Other' reason (Mandatory)" : "Additional notes (Optional)", border: const OutlineInputBorder()),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: viewModel.isLoading ? null : () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: viewModel.isLoading ? null : () async {
                if (selectedReason == "Other (Specify Remarks)" && remarksController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please provide remarks for 'Other' reason")));
                  return;
                }
                bool success = await viewModel.rejectApplication(id, selectedReason, remarksController.text.trim());
                if (success && mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Application Rejected"), backgroundColor: AppColors.errorRed));
                  Navigator.pop(context);
                } else if (viewModel.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!), backgroundColor: AppColors.errorRed));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
              child: viewModel.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Confirm Reject", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
