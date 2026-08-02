import 'dart:io';

class FullCheckoutModel {
  // ── Step 1: Order Review ──
  String? issueDate;
  String? shopId;
  String? agentId;
  String? managerId;
  String? salesPersonId;
  String? productId;
  String? productModelId;
  String? productModel;
  String? brandName; // 💡 Added brand name
  double mrp = 0.0;

  // Sale Type
  String saleType = 'EMI'; // 'Selling Price' | 'EMI'

  // EMI Mode
  String emiMode = 'EXISTING_PLAN'; // EXISTING_PLAN | CREATE_NEW_PLAN | REMAINING_BALANCE

  // Existing Plan
  String? emiPlanId;
  int emiTenureMonths = 0;
  double downPayment = 0.0;
  double emiCharge = 0.0;
  double monthlyEmi = 0.0;
  String? monthlyPaymentDate;

  // ── Create New EMI Plan ──
  String newPlanName = '';
  int newPlanMonths = 3;
  String downPaymentCalculationType = 'RATE'; // RATE | AMOUNT
  String downPaymentCalculationRate = '20';
  String? downPaymentAmount;
  String appEmiChargeType = 'RATE';
  String appEmiChargeRate = '5';
  String? appEmiChargeAmount;
  String cashbackRate = '0';
  String? cashbackAmount;
  String newPlanNote = '';

  // ── Remaining Balance ──
  double customUpfrontPayment = 0.0;
  int customEmiDurationMonths = 6;
  String customAppEmiChargeType = 'RATE';
  String customAppEmiChargeRate = '0';
  String customCashbackRate = '0';
  String customEmiNote = '';
  List<Map<String, dynamic>> customAdditionalCharges = [];

  // ── Customer Info ──
  String name = '';
  String phone = '';
  String password = '';
  String presentAddress = '';
  String permanentAddress = '';
  String nidPassportNumber = '';
  String sourceOfIncome = 'Business';
  double monthlyIncome = 0.0;

  String get incomeSource => sourceOfIncome;
  set incomeSource(String? value) {
    if (value != null) sourceOfIncome = value;
  }

  // ── KYC ──
  File? customerPhoto;
  File? nidFront;
  File? nidBack;
  File? incomeProof;
  String incomeProofDocumentType = 'INCOME_PROOF_BANK_STATEMENT';

  // ── Guarantors ──
  List<GuarantorInfo> guarantors = [
    GuarantorInfo(type: 'FAMILY', relationship: 'Brother'),
    GuarantorInfo(type: 'NON_FAMILY', relationship: 'Friend'),
  ];

  // ── Payment ──
  String downPaymentMethod = 'CASH'; // CASH | BKASH | BANK
  String? bankAccountName;
  String? bankAccountNumber;
  String? bankName;
  String? downPaymentReferenceNumber;
  File? bankReceipt;
}

class GuarantorInfo {
  String type;
  String name;
  String phone;
  String relationship;
  String nidPassportNumber;
  File? nidFront;
  File? nidBack;

  GuarantorInfo({
    required this.type,
    this.name = '',
    this.phone = '',
    this.relationship = '',
    this.nidPassportNumber = '',
    this.nidFront,
    this.nidBack,
  });

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "name": name,
      "phone": phone,
      "relationship": relationship,
      "nidPassportNumber": nidPassportNumber,
    };
  }
}
