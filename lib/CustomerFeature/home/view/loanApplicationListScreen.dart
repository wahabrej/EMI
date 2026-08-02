import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constant/App_Colors.dart';
import '../viewModel/loan_application_view_model.dart';
import '../../../../core/routes/Routes_name.dart';

class CustomerLoanApplicationListScreen extends StatefulWidget {
  const CustomerLoanApplicationListScreen({super.key});

  @override
  State<CustomerLoanApplicationListScreen> createState() => _CustomerLoanApplicationListScreenState();
}

class _CustomerLoanApplicationListScreenState extends State<CustomerLoanApplicationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerLoanApplicationViewModel>().fetchApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CustomerLoanApplicationViewModel>();

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.black, size: 20),
        ),
        title: const Text(
          'Loan Applications',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : vm.applications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => vm.fetchApplications(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.applications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final app = vm.applications[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context, 
                            RouteName.customerLoanApplicationDetailsScreen, 
                            arguments: app
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderGrey),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.infoBlue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.description_outlined, color: AppColors.primaryBlue),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          app.product?.name ?? 'Product Name',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        Text(
                                          app.displayId ?? '',
                                          style: const TextStyle(color: AppColors.greyText, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildStatusBadge(app.status),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoColumn('Loan Amount', '৳${app.regularPrice ?? 0}'),
                                  _buildInfoColumn('Tenure', '${app.planMonths ?? 0} Mo'),
                                  _buildInfoColumn('EMI', '৳${app.monthlyEmi ?? 0}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    Color bg;
    switch (status?.toUpperCase()) {
      case 'APPROVED':
        color = AppColors.successGreen;
        bg = AppColors.successBg;
        break;
      case 'REJECTED':
        color = AppColors.errorRed;
        bg = const Color(0xFFFEE2E2);
        break;
      default:
        color = Colors.orange;
        bg = const Color(0xFFFFF7ED);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status ?? 'PENDING',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.greyText, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No applications found', style: TextStyle(color: AppColors.greyText, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
