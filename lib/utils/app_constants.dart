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

  /// Onbording Screen Constants
  static const String onboardingTitle1 = "Manage Your Store with Ease";
  static const String onboardingTitle2 = "View Analytic And Track Success";
  static const String onboardingTitle3 = "Clock In, Clock Out, Simplified";
  static const String onboardingDesc1 =
      "Add Products, Manage Inventory And Take Orders Anywhere.";
  static const String onboardingDesc2 =
      "Get Real-time insights And Make Data-Driven Decisions.";
  static const String onboardingDesc3 =
      "Mark your attendance and monitor your daily schedule with ease and accuracy.";

  static const String loginWelcomeTitle = 'Welcome Back';
  static const String phoneLoginTitle = 'Login Via Phone';
  static const String signupTitle = 'Create Account';
  static const String saleTitle = 'Sale';
  static const String productTitle = 'All Products';
  static const String businessTitle = 'Business Management';
  static const String totalProduct = 'Total Products';
  static const String quickAction = "Quick Actions";
  static const String recentSales = "Recent Sales";
  static const String moreTitle = 'More';
  static const String detailPTitle = 'Product Details';
  static const String purchaseTitle = 'Purchase';
  static const String profitTitle = 'Profit';
  static const String settingTitle = 'Setting';
  static const String delTitle = 'Delete';
  static const String cancelTitle = 'Cancel';
  static const String delProduct = 'Delete Product';
  static const String invHealth = 'Inventory Health';
  static const String healthyStock  = 'Healthy Stock';
  static const String calPerPiece = 'Calculated per piece sold';
  static const String currAvailability = 'Current Available';
  static const String enterPhoneNumber = "Enter Phone Number";
  static const String signupSubtitle =
      'Enter your details to register your secure zero-knowledge workspace';
  static const String loginWelcomeSubtitle =
      'Sign in to manage your store, sales, and inventory.';
  static const String dangerZineSubtitle = 'Deleting this product will immediately remove it from the active POS register and transaction quick-picks. Past receipts remain archived.';
  static const String recoveryEmailSubtitle =
      'No worries! Choose your recovery channel and we will send a secure verification code.';
  static const String loginSlug = "Enter your credentials to access your Shop";
  static const String loginEmailLabel = 'Email';
  static const String nameLabel = 'Name';
  static const String greeting  = "Good Morning";
  static const String nameHint = 'Enter your name';
  static const String emailHint = 'abc@company.com';
  static const String loginEmailHint = 'Enter your email';
  static const String loginPasswordLabel = 'Password';
  static const String loginPasswordHint = 'Enter your password';
  static const String searchHint = "Search product, barcode...";
  static const String searchHint1 = 'Search Invoices, suppliers...';
  static const String unit = "/unit";
  static const String defaultCurrency = "Rs. ";
  static const String todayCardSummary = "Today's Sales";
  static const String addSale = "+ New Sale";
  static const String add = "+ Add";
  static const String edit = "Edit";
  static const String priceMargin = "Pricing & Margins";
  static const String retailPrice = "Retail Sale Price";
  static const String wholeSaleP = "Wholesale Purchase";
  static const String costBasis = "cost basis";
  static const String addCat = 'Add Category';
  static const String reset = 'Reset';
  static const String categoryName = 'Category Name ';
  static const String requiredAsterisk = '*';
  static const String required = 'Required';
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
  static const String allCat = 'All Categories';
  static const String noCatFound = 'No categories found.';
  static const String customer = "Customer";
  static const String addNote = "Add Note (Optional)";
  static const String noteHint = "Write a note...";
  static const String disTitle = "'Discount (Rs.)'";
  static const String walkInCustomer = "Walk In Customer";
  static const String all = "All";
  static const String cartItem = "Cart Items";
  static const String cartEmpty = "Your Cart is Empty";
  static const String clrAll = "Clear All";
  static const String statusActive = "Active";
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
  static const String loginForgotPassword = 'Forgot password?';
  static const String rememberMe = 'Remember me';
  static const String rememberPassword = 'Remember your password?';
  static const String loginButton = 'Sign In';
  static const String loginContinueWith = 'or continue with';
  static const String loginGoogle = 'Google';
  static const String loginPhone = 'Phone';
  static const String loginNoAccount = "Don't have an account?";
  static const String signupSignIn = 'Already have an account?';
  static const String recoveryEmail = 'Please enter your email address';
  static const String recoveryPhone = 'Please enter your phone number';
  static const String encryptedTitle =
      '256-BIT ENCRYPTED RECOVERY • INSTANT DELIVERY';
  static const String loginSignUp = 'Sign Up >';
  static const String recoveryChannel = 'Email Address';
  static const String regEmailAddress = 'Registered Email';
  static const String sendVerificationCode = 'Send Verification Code';
  static const String logout = 'Log out';

  static const String exitAppTitle = 'Exit App';
  static const String exitAppSnackBarMsg = 'Press back again to exit the app';


  static const String createYourShop = 'Create your shop';
  static const String toggleTheme = 'Toggle theme';
  static const String workspaceSubtitle =
      'Set up your workspace before entering the dashboard.';
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
  static const String stockUpdatedAuto = 'Stock has been updated automatically.';
  static const String statusLabel = 'Status';
  static const String completedLabel = 'Completed';
  static const String paymentMethodLabel = 'Payment Method';
  static const String cashLabel = 'Cash';
  static const String cardLabel = 'Card';
  static const String saleIdLabel = 'Sale ID';
  static const String viewSales = 'View Sales';
  static const String addAnotherSale = 'Add Another Sale';
  static const String itemsLabel = 'items';
  static const String proceedToPayment = 'Proceed to Payment';
  static const String completeSaleLabel = 'Complete Sale';
  static const String noProductsAvailable = 'No products available';
  static const String noProductsFound = 'No products found';
  static const String addProductsBeforeSale = 'Add products before creating a sale.';
  static const String tryAnotherProductName = 'Try another product name or barcode.';
  static const String viewCart = 'View Cart';

  /// Sale View Screen Constants
  static const String noSalesFound = 'No sales found';
  static const String noSalesYet = 'No sales yet';
  static const String changeSearchOrFilter = 'Try changing your search or filter.';
  static const String completedSalesAppearHere = 'Your completed sales will appear here.';
}
