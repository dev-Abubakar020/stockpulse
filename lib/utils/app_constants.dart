class AppConstants {
  AppConstants._();

  ///App Constants
  static const String appName = 'StockPulse';
  static const String appVersion = '1.0.0';

  ///All API Endpoints - Supabase
  static const String supabaseUrl = 'https://lrfszjtnmsvevmkkiuna.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_GRRl45M2HhkvRoLKgT6R1A_Jr04DeT7';
  static const String googleWebClientId =
      '875735535485-6jb7n1hgrknqsfnnf2i641co6o2cb971.apps.googleusercontent.com';
  static const String googleIosClientId =
      '875735535485-2opp6las5tn4lt6o8tvir4rq97dokhjd.apps.googleusercontent.com';
  static const String stagAppName = 'StockPulse';
  static const String splashSlug = 'Initializing Data...';

  /// All Assets
  static const String googleLogo = 'assets/images/googlelogo.png';
  static const String appleLogo = 'assets/images/applelogo.png';
  static const String phoneLogo = 'assets/images/phonelogo.png';
  static const String splashImage = 'assets/images/splashImage.png';
  static const String onboardingImage1 =
      "https://raw.githubusercontent.com/muhxdan/Flutter-Onboarding-Screen/refs/heads/master/assets/images/image1.png";
  static const String onboardingImage2 =
      "https://raw.githubusercontent.com/muhxdan/Flutter-Onboarding-Screen/refs/heads/master/assets/images/image2.png";
  static const String onboardingImage3 =
      "https://github.com/muhxdan/Flutter-Onboarding-Screen/blob/master/assets/images/image3.png?raw=true";
  static const String defaultUserIcon =
      'https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=612x612&w=0&k=20&c=yBeyba0hUkh14_jgv1OKqIH0CCSWU_4ckRkAoy2p73o=';

  /// OnBoarding Screen Constants
  static const String onboardingTitle1 = "Manage Your Store with Ease";
  static const String onboardingTitle2 = "View Analytic And Track Success";
  static const String onboardingTitle3 = "Clock In, Clock Out, Simplified";
  static const String onboardingDesc1 =
      "Add Products, Manage Inventory And Take Orders Anywhere.";
  static const String onboardingDesc2 =
      "Get Real-time insights And Make Data-Driven Decisions.";
  static const String onboardingDesc3 =
      "Mark your attendance and monitor your daily schedule with ease and accuracy.";
  static const String recError = 'This password reset link is invalid or has expired. Please request a new one.';
  static const String unableToSentLink = 'Unable to verify password reset link. Please request a new one.';
  static const String loginWelcomeTitle = 'Welcome Back';
  static const String phoneLoginTitle = 'Login Via Phone';
  static const String start = 'START';
  static const String skip = 'SKIP';
  static const String next = 'NEXT';
  static const String signupTitle = 'Create Account';
  static const String saleTitle = 'Sale';
  static const String saleSummary = 'Sale Summary';
  static const String newSale = 'New Sale';
  static const String productTitle = 'All Inventory';
  static const String businessTitle = 'Business Management';
  static const String totalProduct = 'Total Inventory';
  static const String quickAction = "Quick Actions";
  static const String recentSales = "Recent Sales";
  static const String recentPurchase = "Recent Purchase";
  static const String homeTitle = 'Home';
  static const String productLabel = 'Inventory';
  static const String moreTitle = 'More';
  static const String detailPTitle = 'Product Details';
  static const String purchaseTitle = 'Purchase';
  static const String addPurchase = 'Add Purchase';
  static const String addProducts = 'Add Inventory';
  static const String uncatProduct = 'Uncategorized';
  static const String report = 'Reports';
  static const String lowStockTitle = 'Low Stock';
  static const String profitTitle = 'Profit';
  static const String settingTitle = 'Setting';
  static const String delTitle = 'Delete';
  static const String cancelTitle = 'Cancel';
  static const String delProduct = 'Delete Product';
  static const String businessInfo = 'Business Info';
  static const String invHealth = 'Inventory Health';
  static const String barCode = 'BarCode';
  static const String barCodeSubCheck = 'Save BarCode';
  static const String healthyStock = 'Healthy Stock';
  static const String calPerPiece = 'Calculated per piece sold';
  static const String currAvailability = 'Current Available';
  static const String enterPhoneNumber = "Enter Phone Number";
  static const String regPhone = 'Registered Phone Number';
  static const String regPhoneHint = '+1 (555) 000-0000';
  static const String signupSubtitle =
      'Enter your details to register your secure zero-knowledge workspace';
  static const String loginWelcomeSubtitle =
      'Sign in to manage your store, sales, and inventory.';
  static const String dangerZineSubtitle =
      'Deleting this product will immediately remove it from the active POS register and transaction quick-picks. Past receipts remain archived.';
  static const String recoveryEmailSubtitle =
      'No worries! Enter your email address and we will send you a secure password reset link.';
  static const String loginSlug = "Enter your credentials to access your Shop";
  static const String loginEmailLabel = 'Email';
  static const String nameLabel = 'Name';
  static const String phoneLabel = 'Phone';
  static const String morningGreeting = "Good Morning ☀️";
  static const String afternoonGreeting = "Good Afternoon 🌤️";
  static const String eveningGreeting = "Good Evening 🌇";
  static const String nightGreeting = "Good Night 🌙";
  static const String nameHint = 'Enter your name';
  static const String emailHint = 'abc@company.com';
  static const String loginEmailHint = 'Enter your email';
  static const String loginPasswordLabel = 'Password';
  static const String loginPasswordHint = 'Enter your password';
  static const String searchHint = "Search product ...";
  static const String searchHint2 = 'Search purchase ...';
  static const String searchHint3 = 'Search Sale ...';
  static const String searchHint1 = 'Search Invoices, suppliers...';
  static const String unit = "/unit";
  static const String defaultCurrency = "Rs. ";
  static const String todayCardSummary = "Today's Sales";
  static const String addSale = "Add Sale";
  static const String add = "Add";
  static const String edit = "Edit";
  static const String priceMargin = "Pricing & Margins";
  static const String retailPrice = "Retail Sale Price";
  static const String wholeSaleP = "Wholesale Purchase";
  static const String costBasis = "cost basis";
  static const String addCat = 'Add Category';
  static const String addExpense = 'Add Expense';
  static const String dateNotes = 'Date and Notes';
  static const String dateFormat = 'D/MM/YYYY';
  static const String dateFormat1 = 'dd MMM, hh:mm a';
  static const String dateFormat2 = 'dd-MM-yyyy hh:mm a';
  static const String descExpense = 'Describe the expense...';

  static const String reset = 'Reset';
  static const String categoryName = 'Category Name ';
  static const String staffName = 'Staff Email ';
  static const String staffEmailDesc = 'Enter the email address of the staff member you want to invite.';
  static const String staffEmailLabelHint = 'abc@gmail.com';
  static const String staffEmailHint =
                                     'An invitation will be sent to this email.\nThe staff member will need to create \na new StockPulse account using the same email address.';
  static const String requiredAsterisk = '*';
  static const String required = 'Required';
  static const String inviteExpired = 'Invitation Expired';
  static const String invalidInvitation = 'Invalid Invitation';
  static const String unableToLoad = 'Unable to load staff invitation.';
  static const String accInActive = 'Account Inactive';
  static const String accInValidSubTitle = 'Your staff account is inactive. Please contact the shop owner.';

  static const String categoryNameHint =
      'Enter a unique and descriptive category name for your catalog.';
  static const String categoryStatus = 'Category Status';
  static const String databaseKeyPrefix = 'Database key: ';
  static const String databaseKey = 'is_active';
  static const String fontMonospace = 'monospace';
  static const String visibleChannels = 'Visible across Merchant Channels';
  static const String hiddenChannels = 'Hidden across Merchant Channels';
  static const String categoryStatusHint =
      'Inactive categories will hide associated items from quick customer checkout.';
  static const String saveCategory = 'Save Category';

  static const String searchCat = 'Search Categories';
  static const String searchStaff = 'Search Staff';
  static const String allCat = 'All Categories';
  static const String allStaff = 'All Staff';
  static const String addStaff = 'Add Staff';
  static const String allExpenses = 'All Expenses';
  static const String noCatFound = 'No categories found.';
  static const String noStaffFound = 'No Staff found.';
  static const String noData = 'No category data available';
  static const String noExpenseFound = 'No Expenses found.';
  static const String customer = "Customer";
  static const String addNote = "Add Note (Optional)";
  static const String noteHint = "Write a note...";
  static const String disTitle = "'Discount (Rs.)'";
  static const String walkInCustomer = "Walk In Customer";
  static const String all = "All";
  static const String seeAll = "See All";
  static const String cartItem = "Cart Items";
  static const String cartEmpty = "Your Cart is Empty";
  static const String clrAll = "Clear All";
  static const String statusActive = "Active";
  static const String pending = "Pending";
  static const String statusInActive = "InActive";
  static const String markActive = "Mark Active";
  static const String markInActive = "Mark InActive";
  static const String statusInStock = "In Stock";
  static const String statusOutOfStock = "Out Of Stock";
  static const String dangerZone = "Danger Zone";
  static const String defaultCat = "Beverages";
  static const String defaultBarCode = '5449000000996';
  static const String barcodeCopied = 'Barcode copied to clipboard!';
  static const String defaultTitle = '1.5 Litre (Family Bottle)';
  static const String loginForgotPassword = 'Forgot password';
  static const String forgotType = 'forgot_password';
  static const String rememberMe = 'Remember me';
  static const String rememberPassword = 'Remember your password?';
  static const String loginButton = 'Sign In';
  static const String loginContinueWith = 'or continue with';
  static const String loginGoogle = 'Google';
  static const String loginApple = 'Apple';
  static const String loginPhone = 'Phone';
  static const String loginNoAccount = "Don't have an account?";
  static const String signupSignIn = 'Already have an account?';
  static const String recoveryEmail = 'Please enter your email address';
  static const String recoveryPhone = 'Please enter your phone number';
  static const String encryptedTitle =
      '256-BIT ENCRYPTED RECOVERY • INSTANT DELIVERY';
  static const String loginSignUp = 'Sign Up >';
  static const String signUpText = 'Sign Up';
  static const String recoveryChannel = 'Email Address';
  static const String regEmailAddress = 'Registered Email';
  static const String sendVerificationCode = 'Send Reset Link';
  static const String logout = 'Log out';

  static const String exitAppTitle = 'Exit App';
  static const String exitAppSnackBarMsg = 'Press back again to exit the app';

  static const String createYourShop = 'Create your shop';
  static const String toggleTheme = 'Toggle theme';
  static const String workspaceSubtitle = 'Set up your workspace';
  static const String shopDetails = 'Shop details';
  static const String ownerName = 'Owner name';
  static const String shopName = 'Shop name';
  static const String enterShopName = 'Enter your shop name';
  static const String phoneOptional = 'Phone (optional)';
  static const String completeAddress = 'Complete address';
  static const String addressHint = 'Street, area, city, and country';
  static const String currency = 'Currency';
  static const String country = 'Country';
  static const String symbol = 'Symbol';
  static const String total = 'Total';
  static const String currencyCode = 'Currency code';
  static const String saveAndContinue = 'Save and continue';
  static const String addShopImage = 'Add shop image (optional)';
  static const String changeShopImage = 'Change shop image';
  static const String shopCreatedSuccessMsg = 'Shop created successfully!';
  static const String couldNotCreateShopTitle = 'Could not create shop';
  static const String completeShopFieldsMsg =
      'Please complete the owner, shop, and address fields.';

  static const String insufficientAmount = 'Insufficient Amount';
  static const String receivedAmountError =
      'Received amount cannot be less than the total amount.';

  /// Add Sale Screen Constants
  static const String stockLabel = 'Stock: ';
  static const String barcodeLabel = 'Barcode: ';
  static const String subtotal = 'Subtotal';
  static const String discountLabel = 'Discount';
  static const String totalAmountLabel = 'Total Amount';
  static const String selectPaymentMethod = 'Select Payment Method';
  static const String receivedAmountLabel = 'Received Amount';
  static const String changeLabel = 'Change';
  static const String invoiceOptions = 'Invoice Options';
  static const String printInvoice = 'Print Invoice';
  static const String shareWhatsApp = 'Share via WhatsApp';
  static const String saleCompletedSuccess = 'Sale Completed\nSuccessfully!';
  static const String stockUpdatedAuto =
      'Stock has been updated automatically.';
  static const String statusLabel = 'Status';
  static const String loginFailedLabel = 'Login Failed';
  static const String googleSignInLabel = 'Google Sign-In Failed';
  static const String completedLabel = 'Completed';
  static const String cancelledLabel = 'Cancelled';
  static const String paymentMethodLabel = 'Payment Method';
  static const String cashLabel = 'Cash';
  static const String cardLabel = 'Card';
  static const String saleIdLabel = 'Sale ID';
  static const String viewSales = 'View Sales';
  static const String addAnotherSale = 'Add Another Sale';
  static const String itemsLabel = 'items';
  static const String proceedToPayment = 'CheckOut';
  static const String completeSaleLabel = 'Complete Sale';
  static const String noProductsAvailable = 'No Product available';
  static const String noInverntriesAvailable = 'No Inventory available';
  static const String noProductsFound = 'No Inventory found';
  static const String addProductsBeforeSale =
      'Add Inventory before creating a sale.';
  static const String tryAnotherProductName =
      'Try another Inventory name or barcode.';
  static const String viewCart = 'View Cart';
  static const String cartDetail = 'Cart Detail';

  /// Auth Alerts & Messages
  static const String warningTitle = 'Warning';
  static const String successTitle = 'Success';
  static const String errorTitle = 'Error';
  static const String loginFailedTitle = 'Login Failed';
  static const String signupFailedTitle = 'Signup Failed';
  static const String googleSignInFailedTitle = 'Google Sign-In Failed';
  static const String noInternetTitle = 'No Internet Connection';
  static const String noInternetMsg =
      'Please check your internet connection and try again.';
  static const String checkYourEmailTitle = 'Check your email';
  static const String confirmEmailMsg =
      'Your account was created. Please confirm your email before signing in.';
  static const String resetLinkSentMsg =
      'Password reset link sent to your email.';
  static const String emailLinkExpiredMsg =
      'Email link has expired or is invalid. Please request a new one.';
  static const String passwordUpdatedSuccessMsg =
      'Password updated successfully.';
  static const String verificationFailedTitle = 'Verification Failed';
  static const String otpErrorTitle = 'OTP Error';
  static const String phoneRequiredMsg = 'Phone number is required.';
  static const String enterValidOtpMsg = 'Enter a valid 6-digit OTP code.';
  static const String sessionExpiredMsg =
      'Verification session expired. Please resend OTP.';
  static const String incompleteCodeTitle = 'Incomplete Code';
  static const String incompleteCodeMsg =
      'Please enter all 6 digits of the verification code.';
  static const String createNewPassword = 'Create New Password';
  static const String newPasswordLabel = 'New Password';
  static const String passHint = '••••••••••••';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String updateBusiness = 'Update Business';
  static const String updatePasswordBtn = 'Update Password';
  static const String createAccountBtn = 'Create Account';
  static const String agreePrefix = 'I agree to the ';
  static const String termsOfService = 'Terms of Service';
  static const String agreeAnd = ' and ';
  static const String privacyPolicy = 'Privacy Policy';
  static const String agreeSuffix = '.';
  static const String agreeToTermsText =
      'I agree to the Terms of Service and Privacy Policy.';
  static const String verifyAndProceedBtn = 'Verify & Proceed';
  static const String verifyOtpCodeTitle = 'Verify OTP Code';
  static const String resendCodeText = 'Resend Code';
  static const String resendCodeInPrefix = 'Resend code in 00:';
  static const String didntReceiveCode = "Didn't receive the code?";
  static const String preferEmailSignIn = 'Prefer email sign in?';
  static const String backToSignIn = 'Back to Sign In';
  static const String newVendorReg = 'NEW VENDOR REGISTRATION';
  static const String newStaffReg = 'NEW STAFF REGISTRATION';
  static const String signupDescForOwner =
      'Create your account to manage inventories';
  static const String passwordsDoNotMatch = 'Passwords do not match.';
  static const String passLength = 'At least 8 characters';
  static const String passwordLengthError =
      'Password must be at least 8 characters.';
  static const String stockpulseWorkspace = 'STOCKPULSE WORKSPACE';
  static const String twoFactorSecurity = '2FA SECURITY';
  static const String phoneSubtitle =
      'We will send a 6-digit one-time password to verify and secure your account.';
  static const String mobileNumberLabel = 'MOBILE NUMBER';
  static const String phoneEncryptedMsg =
      'Your phone number is encrypted & never shared.';
  static const String resetPasswordDesc =
      'Create you StockPulse Account Password';

  /// Platform & Exception Messages
  static const String defaultErrorMessage =
      'Something went wrong. Please try again.';
  static const String accountAlreadyExists =
      'An account already exists with this email address.';
  static const String invalidEmailAddress =
      'Please enter a valid email address.';
  static const String weakPassword =
      'The password is too weak. Please choose a stronger password.';
  static const String invalidEmailOrPassword = 'Invalid email or password.';
  static const String userNotFound =
      'No account was found with these credentials.';
  static const String userBanned =
      'This account has been disabled. Please contact support.';
  static const String emailNotConfirmed =
      'Please verify your email address before signing in.';
  static const String phoneNotConfirmed =
      'Please verify your phone number before signing in.';
  static const String signupDisabled =
      'New account registration is currently disabled.';
  static const String emailProviderDisabled =
      'Email authentication is currently disabled.';
  static const String phoneProviderDisabled =
      'Phone authentication is currently disabled.';
  static const String otpExpired =
      'The verification code has expired. Please request a new one.';
  static const String otpDisabled =
      'OTP authentication is currently unavailable.';
  static const String captchaFailed =
      'Security verification failed. Please try again.';
  static const String sessionExpired =
      'Your session has expired. Please sign in again.';
  static const String rateLimitExceeded =
      'Too many requests. Please wait and try again.';
  static const String recordAlreadyExists = 'This record already exists.';
  static const String foreignKeyViolation =
      'This operation cannot be completed because related data exists.';
  static const String notNullViolation = 'Required information is missing.';
  static const String permissionDeniedAction =
      'You do not have permission to perform this action.';
  static const String recordNotFound = 'The requested record was not found.';
  static const String authFailed = 'Authentication failed. Please try again.';
  static const String databaseError =
      'A database error occurred. Please try again.';
  static const String noInternetError =
      'No internet connection. Please check your network.';
  static const String requestTimeout =
      'The request timed out. Please try again.';
  static const String invalidDataFormat = 'Invalid data format received.';
  static const String permissionDeniedDevice =
      'Permission denied. Please allow the required permission.';
  static const String cameraPermissionDenied =
      'Camera permission is required to use this feature.';
  static const String cameraUnavailable = 'Camera is currently unavailable.';
  static const String storagePermissionDenied =
      'Storage permission is required.';
  static const String deviceError =
      'A device error occurred. Please try again.';

  /// Sale View Screen Constants
  static const String noSalesFound = 'No sales found';
  static const String noSalesYet = 'No sales yet';
  static const String changeSearchOrFilter =
      'Try changing your search or filter.';
  static const String completedSalesAppearHere =
      'Your completed sales will appear here.';

  ///Validator
  // Numeric Constants
  static const int minPasswordLength = 8;
  static const int minNameLength = 2;
  static const int minPhoneDigits = 7;
  static const int maxPhoneDigits = 15;
  static const int minOtpLength = 6;

  // Validation Error Messages
  static const String emailRequired = 'Email is required.';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String passwordRequired = 'Password is required.';
  static const String mustBeSignIn = 'You must be signed in to create a shop.';
  static const String passwordMinLength =
      'Password must be at least 8 characters long.';
  static const String passwordUppercase =
      'Password must contain at least one uppercase letter.';
  static const String passwordLowercase =
      'Password must contain at least one lowercase letter.';
  static const String passwordNumber =
      'Password must contain at least one number.';
  static const String passwordSpecialChar =
      'Password must contain at least one special character.';
  static const String nameRequired = 'Name is required.';
  static const String nameMinLength =
      'Name must be at least 2 characters long.';
  static const String confirmPasswordRequired = 'Please confirm your password.';
  static const String phoneRequired = 'Phone number is required.';
  static const String invalidPhone = 'Please enter a valid phone number.';
  static const String otpRequired = 'Verification code is required.';
  static const String invalidOtp = 'Please enter a valid 6-digit OTP code.';

  // RegExp Raw Strings
  static const String emailPattern =
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
  static const String uppercasePattern = r'[A-Z]';
  static const String lowercasePattern = r'[a-z]';
  static const String digitPattern = r'[0-9]';
  static const String specialCharPattern = r'[!@#$%^&*(),.?":{}|<>]';
  static const String nonDigitsPattern = r'\D';
  static const String emptyString = '';

  // Helper Methods for Dynamic Strings
  static String requiredField(String fieldName) => '$fieldName is required.';

  // Option 2: Static strings (if you prefer resolving state at the call site)
  static const String noPurchasesFoundTitle = 'No purchases found';
  static const String noPurchasesYetTitle = 'No purchases yet';
  static const String noPurchasesFoundSubtitle =
      'Try changing your search or filter.';
  static const String noPurchasesYetSubtitle =
      'Your completed purchases will appear here.';
  // Static Constants Alternative
  static const String queryNotFoundTitle = 'Query Not found';
  static const String noProductsFoundTitle = 'No Inventory found';
  static const String noProductsFoundSubtitle =
      'Try changing your search or filter.';
  static const String noProductsYetSubtitle =
      'Your added Inventory will appear here.';

  /// Additional Category, Product, Purchase & Sale Constants
  static const String categoryNameEmpty = 'Category name cannot be empty';
  static const String categoryAddedSuccess = 'Category added successfully';
  static const String categoryStatusUpdated = 'Category status updated';
  static const String failedFetchCategories = 'Failed to fetch categories';
  static const String failedUpdateCategoryStatus =
      'Failed to update category status';
  static const String unableLoadProducts = 'Unable to load Inventories';
  static const String productRemovedSuccess = 'Product removed successfully';
  static const String unableRemoveProduct = 'Unable to remove product';
  static const String noProductsSelected =
      'Please select at least one Inventory.';
  static const String invalidDiscount = 'Invalid Discount';
  static const String discountNegative = 'Discount cannot be negative.';
  static const String discountExceedSubtotal =
      'Discount cannot exceed subtotal.';
  static const String purchaseFailed = 'Purchase Failed';
  static const String emptyCart = 'Empty Cart';
  static const String productError = 'Product Error';
  static const String outOfStock = 'Out of Stock';
  static const String insufficientStock = 'Insufficient Stock';
  static const String saleFailed = 'Sale Failed';
  static const String productNameRequired =
      'Product name is required to continue';
  static const String selectCategoryRequired =
      'Please select a category for this product';
  static const String purchasePriceRequired = 'Purchase price is required';
  static const String salePriceRequired = 'Sale price is required';
  static const String validNumberPurchasePrice =
      'Please enter a valid number for purchase price';
  static const String validNumberSalePrice =
      'Please enter a valid number for sale price';
  static const String requiredFieldTitle = 'Required Field';
  static const String invalidInputTitle = 'Invalid Input';

  // Section Titles
  static const String othersOptionsTitle = 'Others Options';
  static const String categoriesTitle = 'Categories';
  static const String expensesTitle = 'Expenses';
  static const String expenseDetails = 'Expense Details';
  static const String expenseCategoryLabel = 'Category';
  static const String expenseAmountLabel = 'Amount *';
  static const String expenseDateLabel = 'Expense Date *';
  static const String expenseNotesLabel = 'Notes / Description (Optional)';
  static const String saveExpenseBtn = 'Save Expense';
  static const String expenseAddedSuccess = 'Expense added successfully';
  static const String validAmountWarning = 'Please enter a valid amount';
  static const String reportsTitle = 'Reports';
  static const String staffTitle = 'Staff';
  static const String aboutTitle = 'About Profile';
  static const String shoppTitle = 'Shop Profile';
  static const String notificationTitle = 'Notifications';
  static const String securityTitle = 'Security';
  static const String supportTitle = 'Support';
  static const String helpAndSupportTitle = 'Help & Support';
  static const String aboutStockPulseTitle = 'About StockPulse';

  // SnackBar Messages
  static const String notificationSnackTitle = 'ⓘ Notification Service';
  static const String featureUnavailableTitle = 'Feature Unavailable';
  static const String featureComingSoonMsg = 'This feature is coming Soon';

  // Profile & Edit Profile Constants
  static const String editProfileTitle = 'Edit Profile';
  static const String profileUpdatedSuccessMsg =
      'Profile updated successfully.';
  static const String emailCannotBeChanged =
      'Email address is permanent and cannot be modified.';
  static const String updateProfileBtn = 'Update Profile';
  static const String addProfilePhoto = 'Add Profile Photo';
  static const String changeProfilePhoto = 'Change Photo';
  static const String logoutAlertSubTitle =
      'Are you sure you want to log out from StockPulse?';
  static const String personalInfo = 'Personal Information';
  static const String editProfileSubtitle =
      'Update your account name and avatar.';

  // Reports
  static const String reports = 'Reports';
  static const String reportsSubtitle =
      'Get detailed insights about your business performance';

  static const String overview = 'Overview';
  static const String salesReport = 'Sales Report';
  static const String purchaseReport = 'Purchase Report';
  static const String profitLoss = 'Profit & Loss';
  static const String stockReport = 'Stock Report';

  static const String totalSales = 'Total Sales';
  static const String totalPurchases = 'Total Purchases';
  static const String totalProfit = 'Total Profit';
  static const String totalStockValue = 'Total Stock Value';
  static const String totalInvoices = 'Total Invoices';
  static const String averageSale = 'Average Sale';
  static const String averagePurchase = 'Average Purchase';
  static const String itemsSold = 'Items Sold';

  static const String quickReports = 'Quick Reports';
  static const String topSellingProducts = 'Top Selling Products';

  static const String salesOverview = 'Sales Overview';
  static const String salesByCategory = 'Sales by Category';
  static const String purchaseByCategory = 'Purchase by Category';
  static const String viewAsPdf = 'View as PDF';
  static const String purchaseOverview = 'Purchase Overview';
  static const String purchasesBySupplier = 'Purchases by Supplier';
  static const String recentPurchases = 'Recent Purchases';

  // =========================
// PRINTER / BLUETOOTH
// =========================

  static const String bluetoothOff =
      'Bluetooth is turned off. Please turn on Bluetooth and try again.';

  static const String bluetoothPermissionDenied =
      'Bluetooth permission is required to find nearby printers.';

  static const String printerNotFound =
      'No printer found. Make sure your printer is turned on and nearby.';

  static const String printerConnectionFailed =
      'Unable to connect to the printer. Please try again.';

  static const String printerDisconnected =
      'The printer is disconnected. Please reconnect and try again.';

  static const String printerPrintFailed =
      'Unable to print the receipt. Please check the printer and try again.';

  static const String printerError =
      'Something went wrong with the printer. Please try again.';

  static const String daily = 'Daily';
  static const String monthly = 'Monthly';
  static const String custom = 'Custom';
  static const String export = 'Export';
  static const String viewAll = 'View All';
  static const String last30Days = 'Last 30 Days';

  static const String invoice = 'Invoice';
  static const String dateTime = 'Date & Time';
  static const String supplier = 'Supplier';
  static const String amount = 'Amount';
  static const String others = 'Others';
  static const String salesPerformanceSubtitle = 'Track your sales performance over time';


  static const String printerSettingsTitle = 'Printer Settings';
  static const String btnScanning = 'Scanning...';
  static const String btnScanPrinters = 'Scan Printers';
  static const String txtNoPrintersFound = 'No printers found';

  // Printer Labels & Defaults
  static const String defaultPrinterName = 'Thermal Printer';
  static const String defaultDeviceAddress = 'Unknown device';
  static const String msgPrinterConnected = 'Printer connected';
  static const String snackbarTitleConnected = 'Connected';

 // Receipt Labels & Text
  static const String receiptStoreName = 'STOCKPULSE';
  static const String receiptTitle = 'PURCHASE RECEIPT';
  static const String receiptSaleTitle = 'SALE RECEIPT';
  static const String receiptDefaultTerminal = 'POS-TERMINAL-01';
  static const String receiptDefaultOperator = 'Auth-User';
  static const String receiptLabelPurchase = 'PURCHASE:';
  static const String receiptLabelSale = 'INVOICES:';
  static const String receiptLabelDate = 'DATE:';
  static const String receiptLabelTerminal = 'TERMINAL:';
  static const String receiptLabelOperator = 'OPERATOR:';
  static const String receiptHeaderItem = 'ITEM';
  static const String receiptHeaderQty = 'QTY';
  static const String receiptHeaderTotal = 'TOTAL';
  static const String receiptLabelTotalItems = 'TOTAL ITEMS:';
  static const String receiptLabelSubtotal = 'SUBTOTAL:';
  static const String receiptLabelDiscount = 'DISCOUNT:';
  static const String receiptLabelNetTotal = 'NET TOTAL:';
  static const String receiptThanks = 'Thank you for your business!';
  static const String receiptFooterTitle = 'Purchase Receipt';
  static const String receiptFooterGeneratedBy = 'Generated by StockPulse';
  static const String unitSku = 'SKU';
  static const String unitUnits = 'Units';

  // Expense
  static const String searchExpenseHint = 'Search expense...';
  static const String totalExpenses = 'Total Expenses';
  static const String recordsUnit = 'Records';
  static const String noExpensesFound = 'No expenses found';
  static const String expenseNoteHeader = 'EXPENSE NOTE';
  static const String expenseDeleteTitle = 'Delete Expense';
  static const String expenseDeleteSubtitle = 'Are you sure you want to delete this expense?';
  static const String btnDelete = 'Delete';
  static const String btnDeleteExpense = 'Delete Expense';

  static const String labelStaffEmail = 'Staff Email';
  static const String btnSending = 'Sending...';
  static const String btnSendInvitation = 'Send Invitation';

  // Extra spacing
  static const double spaceXXS = 4.0;
  static const double spaceXXXL = 32.0;
  static const double spaceXS = 6.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 12.0;
  static const double spaceMLG = 14.0;
  static const double spaceLG = 16.0;
  static const double spaceLXL = 16.0;
  static const double spaceXL = 22.0;
  static const double spaceXXL = 24.0;
  static const double maxWidth = 440.0;

  // Radius
  static const double radiusXS = 6.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;

  // Report UI
  static const double reportProgressHeight = 7.0;
  static const double reportIconBoxSize = 44.0;
  static const double reportProductImageSize = 42.0;
  static const double reportChartHeight = 180.0;

  // Icons
  static const double iconXS = 16.0;
  static const double iconSM = 18.0;
  static const double iconMD = 20.0;
  static const double iconLG = 24.0;
  static const double iconXL = 28.0;

  // Additional Screen & Notification Strings
  static const String purchaseCompletedTitle = 'Purchase Completed';
  static const String purchaseSavedSuccessMsg =
      'Purchase saved and stock updated successfully.';
  static const String reportErrorTitle = 'Report Error';
  static const String unableToLoadStaffMsg = 'Unable to load staff members.';
  static const String unableToUpdateStaffTitle = 'Unable to Update Staff';
  static const String trackYourPerformanceSubtitle = 'Track your performance';
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String thisWeek = 'This Week';
  static const String thisMonth = 'This Month';
  static const String customRange = 'Custom Range';
  static const String staffMemberRole = 'Staff Member';
  static const String shopOwnerRole = 'Shop Owner';
  static const String defaultUserTitle = 'User';
  static const String printingSettingTitle = 'Printing Setting';

  // Staff Screen Constants
  static const String invitationPending = 'Invitation Pending';
  static const String staffDetailsHeader = 'STAFF DETAILS';
  static const String invitation = 'Invitation';
  static const String account = 'Account';
  static const String joined = 'Joined';
  static const String invitationExpires = 'Invitation Expires';
  static const String notAvailable = 'Not available';
  static const String resendInvitation = 'Resend Invitation';
  static const String cancelInvitation = 'Cancel Invitation';
  static const String ownerRole = 'Owner';

  // Product Detail Constants
  static const String unitLabel = 'Unit';
  static const String netProfit = 'Net Profit';
  static const String marginSuffix = '% Margin';
  static const String pcsUnit = 'pcs';
  static const String ofCapacity = '% of capacity';
  static String deleteProductConfirmMsg(String name) =>
      'Are you sure you want to delete $name? This action cannot be undone.';

  // Add Product Wizard Constants
  static const String editProduct = 'Edit Product';
  static const String addProductTitle = 'Add Product';
  static const String stepDetails = 'Details';
  static const String stepPricingStock = 'Pricing & Stock';
  static const String stepReview = 'Review';
  static const String quickInventoryWizard = 'Quick Inventory Wizard';
  static const String addProductImage = 'Add Product Image';
  static const String supportsImageFormats = 'Supports PNG, JPG, or snap photo';
  static const String nameHeader = 'NAME';
  static const String enterProductNameHint = 'Enter product name';
  static const String categoryHeader = 'CATEGORY';
  static const String newCategoryBtn = '+ New Category';
  static const String noCategoriesAvailable = 'No categories available';
  static const String skuBarcodeHeader = 'SKU / BARCODE';
  static const String noBarCode = 'No Barcode Assigned';
  static const String eanUpcSubHeader = 'EAN-13 / UPC';
  static const String enterCodeHint = 'e.g. SHIRT001';
  static const String measurementUnitHeader = 'MEASUREMENT UNIT';
  static const String continueToPricingStock = 'Continue to Pricing & Stock';
  static const String pricingDetailsHeader = 'PRICING DETAILS';
  static const String step2Of3 = 'Step 2 of 3';
  static const String purchasePriceLabel = 'Purchase Price';
  static const String zeroPrice = 'Rs. 0';
  static const String costPerUnit = 'Cost per unit';
  static const String salePriceLabel = 'Sale Price';
  static const String retailCustomerPrice = 'Retail customer price';
  static const String estimatedProfit = 'Estimated Profit';
  static const String perUnitSuffix = ' / unit';
  static const String stockInventoryHeader = 'STOCK & INVENTORY';
  static const String initialStockQty = 'Initial Stock Quantity';
  static const String lowStockAlertLimit = 'Low Stock Alert Limit';
  static const String trackStockQty = 'Track Stock Quantity';
  static const String deductAutoSale = 'Deduct automatically with each sale';
  static const String activeAvailableSale = 'Active & Available for Sale';
  static const String visibleCatalogPos =
      'Visible in catalog and POS checkout';
  static const String backBtn = 'Back';
  static const String updateAndReview = 'Update & Review →';
  static const String saveAndReview = 'Save & Review →';
  static const String productUpdatedSuccess = 'Product Updated Successfully';
  static const String productAddedSuccess = 'Product Added Successfully';
  static const String hasBeenUpdatedInventory =
      ' has been updated in your store inventory.';
  static const String hasBeenListedLive =
      ' has been listed and is now live in store inventory.';
  static const String liveStatus = 'Live';
  static const String barcodeHeader = 'Barcode';
  static const String currentStockHeader = 'Current Stock';
  static const String viewInInventory = 'View in Inventory →';
  static const String addAnotherProduct = '+ Add Another Product';

  // Purchase Screen Constants
  static const String newPurchaseTitle = 'New Purchase';
  static const String savePurchaseBtn = 'Save Purchase';
  static const String purchaseItemsHeader = 'Purchase Items';
  static const String noItemsAddedYet = 'No items added yet';
  static const String tapAddProductsPurchase =
      'Tap "+ Add" to add products to purchase';
  static const String costSummaryHeader = 'Cost Summary';
  static const String purchasePriceRs = 'Purchase Price (Rs.)';
  static const String lineTotalHeader = 'Line Total';
  static const String addProductToPurchase = 'Add Product to Purchase';
  static const String searchProductOrBarcode = 'Search product or barcode...';
  static const String purchaseDetailsTitle = 'Purchase Details';
  static const String createdByLabel = 'Created By';
  static const String notesLabel = 'Notes';
  static const String purchasedItemsHeader = 'Purchased Items';
  static const String noItemsPurchase = 'No items found for this purchase.';

  // Sale Screen Constants
  static const String cartDetailsTitle = 'Cart Details';
  static const String saleItemsHeader = 'Sale Items';
  static const String tapAddProductsSale =
      'Tap "+ Add" to add products to sale';
  static const String cartItemsHeader = 'Cart Items';
  static const String noItemsInCart = 'No items in cart';
  static const String clearBtn = 'Clear';
  static const String customerAndNotesHeader = 'Customer & Notes';
  static const String addProductToSale = 'Add Product to Sale';
  static const String salePriceRs = 'Sale Price (Rs.)';
  static const String saleDetailsTitle = 'Sale Details';
  static const String soldItemsHeader = 'Sold Items';
  static const String noItemsSale = 'No items found for this sale.';

  //Enable Biometric consts
  static const String notNow = 'Not Now';
  static const String enabled = 'Enable';
  static const String contLogin = 'Continue';
  static const String manualLogin = 'Manual Login';
  static const String enableBiometric = 'Biometric Enabled' ;
  static const String biometricEnabled = 'Enable Biometric Login?' ;
  static const String biometricAvailable = 'Biometric Login Available';
  static const String biometricDetail = 'You can now use your fingerprint to log in.';
  static const String enableBiometricSlug = 'Log in faster and securely with your fingerprint or face ID.';
  static const String manualLoginDetail = 'Would you like to continue logging in with biometrics or use manual login?';

}
