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
  /// GET /dashboard/summary/:userId
  static String salesDashboardSummary(String userId) =>
      '$baseUrl/dashboard/summary/$userId';

  /// 2. Customer Dashboard
  /// GET /dashboard/customer-summary/:userId
  static String customerDashboardSummary(String userId) =>
      '$baseUrl/dashboard/customer-summary/$userId';

  // ── Lookup / Dropdown APIs ─────────────────────────────────
  static const String shops        = '$baseUrl/shops';
  static const String agents       = '$baseUrl/agents';        // Optional: ?shopId=SHOP_ID
  static const String managers     = '$baseUrl/managers';      // Optional: ?agentId=AGENT_ID
  static const String salesPersons = '$baseUrl/sales-persons'; // Optional: ?managerId=MANAGER_ID
  static const String products     = '$baseUrl/products';      // Optional: ?salesPersonId=SP_ID&brandId=B_ID&search=iphone
  static const String emiPlans     = '$baseUrl/emi-plans';     // Optional: ?productId=P_ID&isActive=true

  // Helper for Product-wise EMI Plan
  static String emiPlansByProduct(String productId) =>
      '$baseUrl/emi-plans/product/$productId';

  // ── EMI Quotation ──────────────────────────────────────────
  // POST /emi-plans/EMI_PLAN_ID/quotation
  static String emiQuotation(String emiPlanId) =>
      '$baseUrl/emi-plans/$emiPlanId/quotation';

  // ── Customer CRUD ──────────────────────────────────────────
  // GET  /customers          → list (search, shopId, agentId, managerId, salesPersonId)
  // POST /customers          → create (Direct Sale)
  static const String customers = '$baseUrl/customers';

  // GET /customers/me/details → Logged-in customer's own profile
  static const String myCustomerDetails = '$baseUrl/customers/me/details';

  // GET  /customers/:id      → view
  // PUT  /customers/:id      → update
  // DELETE /customers/:id    → delete
  static String customerById(String id) =>
      '$baseUrl/customers/$id';

  // GET /customers/:id/details → details alias
  static String customerDetails(String id) =>
      '$baseUrl/customers/$id/details';

  // ── Customer File Uploads ──────────────────────────────────
  // POST /customers/:id/photo (field: customerImage)
  static String uploadCustomerPhoto(String customerId) =>
      '$baseUrl/customers/$customerId/photo';

  // POST /customers/:id/documents (fields: documentType, document)
  static String uploadCustomerDocument(String customerId) =>
      '$baseUrl/customers/$customerId/documents';

  // DELETE /customers/:id/documents/:docId
  static String deleteCustomerDocument(String customerId, String docId) =>
      '$baseUrl/customers/$customerId/documents/$docId';

  // ── Guarantor Document Upload ──────────────────────────────
  // POST /customers/:id/guarantors/:guarantorId/document (fields: documentType, document)
  static String uploadGuarantorDocument(String customerId, String guarantorId) =>
      '$baseUrl/customers/$customerId/guarantors/$guarantorId/document';

  // ── Loan Applications (EMI Approval Workflow) ─────────────
  // POST /loan-applications   → create (multipart/form-data)
  // GET  /loan-applications   → list (Optional: ?status=PENDING)
  static const String loanApplications = '$baseUrl/loan-applications';

  // GET /loan-applications/:id → view
  static String loanApplicationById(String id) =>
      '$baseUrl/loan-applications/$id';

  // POST /loan-applications/:id/approve
  static String approveLoanApplication(String id) =>
      '$baseUrl/loan-applications/$id/approve';

  // POST /loan-applications/:id/reject
  static String rejectLoanApplication(String id) =>
      '$baseUrl/loan-applications/$id/reject';

  // ── Asset URL Helper ───────────────────────────────────────
  // Prepend base URL to relative asset paths (e.g., /assets/customers/file.webp)
  static String assetUrl(String relativeUrl) {
    if (relativeUrl.startsWith('http://') || relativeUrl.startsWith('https://')) {
      return relativeUrl;
    }
    return '$baseUrl$relativeUrl';
  }
}