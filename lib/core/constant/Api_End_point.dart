class ApiEndPoint {
  ApiEndPoint._();

  // ── Base URLs ──────────────────────────────────────────────
  static const String localBaseUrl      = 'http://localhost:3001';
  static const String productionBaseUrl = 'https://api.smartpay.click';

  // Active base URL (Switch to productionBaseUrl for release)
  static const String baseUrl = productionBaseUrl;

  // ── Auth ───────────────────────────────────────────────────
  static const String login       = '$baseUrl/auth/login';
  static const String currentUser = '$baseUrl/auth/me';

  /// 1. Sales Person / Staff Dashboard
  static String salesDashboardSummary(String userId) =>
      '$baseUrl/dashboard/summary/$userId';

  /// 2. Customer Dashboard
  static String customerDashboardSummary(String userId) =>
      '$baseUrl/dashboard/customer-summary/$userId';

  // ── Lookup / Dropdown APIs ─────────────────────────────────
  static const String shops        = '$baseUrl/shops';
  static const String agents       = '$baseUrl/agents';
  static const String managers     = '$baseUrl/managers';
  static const String salesPersons = '$baseUrl/sales-persons';
  static const String products     = '$baseUrl/products';
  static const String emiPlans     = '$baseUrl/emi-plans';

  static String emiPlansByProduct(String productId) =>
      '$baseUrl/emi-plans/product/$productId';

  // ── EMI Quotation ──────────────────────────────────────────
  static String emiQuotation(String emiPlanId) =>
      '$baseUrl/emi-plans/$emiPlanId/quotation';

  // ── Customer CRUD ──────────────────────────────────────────
  static const String customers = '$baseUrl/customers';
  static const String myCustomerDetails = '$baseUrl/customers/me/details';

  static String customerById(String id) =>
      '$baseUrl/customers/$id';

  static String customerDetails(String id) =>
      '$baseUrl/customers/$id/details';

  // ── Customer File Uploads ──────────────────────────────────
  static String uploadCustomerPhoto(String customerId) =>
      '$baseUrl/customers/$customerId/photo';

  static String uploadCustomerDocument(String customerId) =>
      '$baseUrl/customers/$customerId/documents';

  static String deleteCustomerDocument(String customerId, String docId) =>
      '$baseUrl/customers/$customerId/documents/$docId';

  // ── Guarantor Document Upload ──────────────────────────────
  static String uploadGuarantorDocument(String customerId, String guarantorId) =>
      '$baseUrl/customers/$customerId/guarantors/$guarantorId/document';

  // ── Loan Applications ──────────────────────────────────────
  static const String loanApplications = '$baseUrl/loan-applications';

  static String loanApplicationById(String id) =>
      '$baseUrl/loan-applications/$id';

  static String approveLoanApplication(String id) =>
      '$baseUrl/loan-applications/$id/approve';

  static String rejectLoanApplication(String id) =>
      '$baseUrl/loan-applications/$id/reject';

  // ── Asset URL Helper ───────────────────────────────────────
  static String assetUrl(String relativeUrl) {
    if (relativeUrl.startsWith('http://') || relativeUrl.startsWith('https://')) {
      return relativeUrl;
    }
    return '$baseUrl$relativeUrl';
  }

  // ── Customer Panel Specific Endpoints ──────────────────────
  static const String customerProfile = '$baseUrl/customer/profile';
  static const String customerDashboard = '$baseUrl/customer/dashboard';
  static const String customerLoans = '$baseUrl/customer/loans';

  static String customerLoanById(String loanId) =>
      '$baseUrl/customer/loans/$loanId';

  static const String customerPayments = '$baseUrl/customer/payments';
  static const String initiateCustomerPayment = '$baseUrl/customer/payments/initiate';
  static const String customerLoanApplications = '$baseUrl/customer/loan-applications';

  static String customerLoanApplicationById(String id) =>
      '$baseUrl/customer/loan-applications/$id';

  static const String customerNotifications = '$baseUrl/customer/notifications';
}
