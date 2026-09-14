import 'app_locale.dart';

/// A hand-rolled string table covering the app's Arabic translation.
/// Looked up by [AppLocale.locale] rather than `BuildContext` so call sites
/// stay a plain `Strings.t(key)`; switching languages rebuilds [MainApp]
/// from the root, which re-runs every descendant's `build()` and picks up
/// the new table.
///
/// Scope: all app chrome (labels, buttons, hints, empty states, errors)
/// translates. Brand/product names (Netflix, STC, Zain, ...), bank-style
/// merchant strings, and the "SAR" currency prefix stay as written — that
/// matches how real banking/subscription apps render them even in Arabic
/// locales, and translating a proper noun isn't really "translation".
///
/// A handful of sentences interpolate a dynamic word (a count, a category
/// name, a period) where English and Arabic word order differ enough that
/// naive interpolation would produce a broken mixed-order sentence. Those
/// are built as small helper functions below (e.g. [renewsIn],
/// [emptyDomainMessage]) that branch on locale internally instead of via
/// [t], and screens with many such cases (analytics) branch inline with
/// `AppLocale.locale.value.languageCode == 'ar'`.
class Strings {
  Strings._();

  static bool get _isArabic => AppLocale.locale.value.languageCode == 'ar';

  static String t(String key) {
    final table = _isArabic ? _ar : _en;
    return table[key] ?? _en[key] ?? key;
  }

  /// [t] with the first `%s` in the template replaced by [value]. For
  /// templates with a single dynamic fragment where English/Arabic word
  /// order around it otherwise matches (e.g. "SAR %s left").
  static String f(String key, String value) => t(key).replaceFirst('%s', value);

  // ---- Helpers for sentences with a dynamic, order-sensitive fragment ----

  static String renewsIn(int days) {
    if (days <= 0) return t('renews_today');
    return _isArabic ? 'يتجدد خلال $days يومًا' : 'Renews in $days days';
  }

  static String inDays(int days) =>
      _isArabic ? 'خلال $days يومًا' : 'in $days days';

  static String addA(String noun) => _isArabic ? 'أضف $noun' : 'Add a $noun';

  static String daysAgo(int days) =>
      _isArabic ? 'منذ $days يوم' : '${days}d ago';

  static String reminderLeadNote(int leadDays) => _isArabic
      ? 'تذكير: $leadDays أيام قبل الدفع.'
      : 'Reminder: $leadDays days before payment.';

  static String emptyDomainMessage(String pluralNoun) => _isArabic
      ? 'لا يوجد $pluralNoun حتى الآن.\nاضغط + لإضافة واحد.'
      : 'No $pluralNoun yet.\nTap + to add one.';

  static String noMatchMessage(String pluralNoun, String query) => _isArabic
      ? 'لا توجد نتائج لـ "$query" ضمن $pluralNoun.'
      : 'No $pluralNoun match "$query".';

  static String noCategoryMessage(String categoryLabel, String pluralNoun) =>
      _isArabic
      ? 'لا يوجد $pluralNoun من فئة $categoryLabel حتى الآن.'
      : 'No ${categoryLabel.toLowerCase()} $pluralNoun yet.';

  static const _monthsEn = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _monthsAr = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  /// [month1to12] is 1-indexed (January = 1).
  static String monthAbbrev(int month1to12) =>
      (_isArabic ? _monthsAr : _monthsEn)[month1to12 - 1];

  /// Display text for the three top-level analytics/spending categories.
  /// The underlying value ('Subscriptions'/'Utilities'/'Staff') stays
  /// English wherever it's used as a lookup key or compared for equality —
  /// this is purely for what's shown on screen.
  static String categoryDisplay(String category) => switch (category) {
    'Subscriptions' => t('nav_subscriptions'),
    'Utilities' => t('nav_utilities'),
    'Staff' => t('nav_staff'),
    _ => category,
  };

  /// Display text for analytics demo "group" names (finer-grained than the
  /// three top-level categories, e.g. 'Streaming', 'Fitness').
  static String groupDisplay(String group) => t('group_${_slug(group)}');

  static String _slug(String s) => s.toLowerCase().replaceAll(' ', '_');

  static const _en = <String, String>{
    // Bottom nav
    'nav_home': 'Home',
    'nav_subscriptions': 'Subscriptions',
    'nav_utilities': 'Utilities',
    'nav_staff': 'Staff',

    // Shared / generic
    'renews_today': 'Renews today',
    'analytics_tab': 'Analytics',
    'general': 'General',
    'upcoming_renewals': 'Upcoming renewals',
    'see_all': 'See all',
    'cancel': 'Cancel',
    'save': 'Save',
    'close': 'Close',
    'back': 'Back',

    // Settings (kept for reference; settings_screen.dart already uses these)
    'settings_title': 'Settings',
    'settings_header_title': 'Make Riyal yours',
    'settings_header_subtitle': 'A few preferences for your everyday payments.',
    'payment_reminders_section': 'PAYMENT REMINDERS',
    'monthly_review_setting': 'Monthly money check-in',
    'monthly_review_setting_sub':
        'Get one reminder each month to review all commitments.',
    'monthly_review_day': 'Review reminder day',
    'day_of_month': 'Day %s',
    'monthly_review_card_title': 'Monthly money check-in',
    'monthly_review_card_sub':
        'Review your commitments and find saving opportunities.',
    'monthly_review_completed': 'Monthly review completed',
    'monthly_review_completed_sub':
        'View your suggestions. Your next check-in is next month.',
    'upcoming_payments': 'Upcoming payments',
    'upcoming_payments_sub': 'Renewals, utility bills and staff payments.',
    'remind_before_payment': 'Remind me before payment',
    'day_singular': 'day',
    'day_plural': 'days',
    'reminder_note':
        'Applies to new reminders in your in-app inbox. Existing messages '
        'stay in your history. New-item notifications remain enabled.',
    'personal_details': 'Personal details',
    'personal_details_sub': 'Name, email and phone number',
    'currency': 'Currency',
    'currency_sub': 'Saudi riyal',
    'appearance': 'Appearance',
    'appearance_sub': 'Riyal dark theme',
    'language': 'Language',
    'language_sub': 'Choose your app language',
    'language_english': 'English',
    'language_arabic': 'العربية',
    'data_on_device_title': 'Your data, on your device',
    'data_on_device_body':
        'Profile edits, preferences and notification read status are saved '
        'locally. Payment data is currently a demo and resets when the app '
        'restarts. No bank account is connected.',
    'help_feedback': 'Help & feedback',
    'help_feedback_sub': 'Quick answers and suggestions',
    'settings_footer': 'RIYAL · Student demo',
    'settings_saved': 'Settings saved',
    'settings_save_failed': 'Could not save settings. Please try again.',

    // Home
    'overview': 'Overview',
    'spending_heading': "This month's spending\non subscriptions",
    'of_sar_budget': 'of SAR %s budget',
    'sar_left': 'SAR %s left',
    'no_subscriptions_yet_short': 'No subscriptions yet.',

    // Category labels
    'category_entertainment': 'Entertainment',
    'category_ai': 'AI',
    'category_productivity': 'Productivity',
    'category_cloud_storage': 'Cloud & Storage',
    'category_fitness_wellness': 'Fitness & Wellness',
    'category_education': 'Education',
    'category_shopping_delivery': 'Shopping & Delivery',
    'category_other': 'Other',
    'category_electricity': 'Electricity',
    'category_water': 'Water',
    'category_internet': 'Internet',
    'category_mobile': 'Mobile',
    'category_gas': 'Gas',
    'category_household': 'Household',
    'category_childcare': 'Childcare',
    'category_driving': 'Driving',
    'category_security': 'Security',
    'category_all': 'All',

    // Analytics groups (finer-grained demo groupings)
    'group_streaming': 'Streaming',
    'group_productivity': 'Productivity',
    'group_fitness': 'Fitness',
    'group_learning': 'Learning',
    'group_electricity': 'Electricity',
    'group_internet': 'Internet',
    'group_water': 'Water',
    'group_household': 'Household',
    'group_transport': 'Transport',

    // Domain nouns (Utilities / Staff)
    'noun_singular_utility_bill': 'utility bill',
    'noun_plural_utility_bill': 'utility bills',
    'add_from_scratch_utility_bill': 'Choose a provider',
    'noun_singular_staff_member': 'staff member',
    'noun_plural_staff_member': 'staff members',
    'add_from_scratch_staff_member': 'Choose a role',
    'search_hint_utilities': 'Search utilities',
    'search_hint_staff': 'Search staff',
    'search_hint_subscriptions': 'Search subscriptions',

    // Analytics
    'analytics_general_title': 'General analytics',
    'illustrative_estimates':
        'Illustrative estimates from the monthly demo data.',
    'category_split': 'Category split',
    'spending_breakdown': 'Spending breakdown',
    'overall_budget_vs_actual': 'Overall budget vs. actual',
    'category_budget_vs_actual': 'Category budget vs. actual',
    'combined_budget_note': 'Combined budget, separate from category limits.',
    'highest_cost_item': 'Highest-cost item',
    'highest_cost_items_tied': 'Highest-cost items · tied',
    'spend_over_time': 'Spend over time',
    'remaining': 'remaining',
    'over_budget': 'over budget',
    'each': 'each',
    'active_items': 'active items',
    'sample_data': 'Sample data',
    'week_ending': 'Week ending',
    'period_week': 'Week',
    'period_month': 'Month',
    'period_year': 'Year',
    'period_adj_weekly': 'Weekly',
    'period_adj_monthly': 'Monthly',
    'period_adj_yearly': 'Yearly',

    // Add flows
    'add_a_subscription': 'Add a subscription',
    'how_would_you_add': 'How would you like to add it?',
    'from_previous_transaction': 'From a previous transaction',
    'pick_from_recent_charges': 'Pick from your recent charges',
    'from_scratch': 'From scratch',
    'choose_app_enter_details': 'Choose an app and enter the details',
    'choose_an_app': 'Choose an app',
    'search_apps': 'Search apps',
    'no_apps_found': 'No apps found',
    'search_generic': 'Search',
    'no_results_found': 'No results found',
    'recent_transactions': 'Recent transactions',
    'tap_charge_to_track_item': 'Tap a charge to turn it into a tracked item',
    'tap_charge_to_track_subscription':
        'Tap a charge to turn it into a tracked subscription',
    'days_ago_suffix': 'd ago',

    // Details / add-item forms
    'subscription_details': 'Subscription details',
    'details': 'Details',
    'amount_sar': 'Amount (SAR)',
    'billing_cycle': 'Billing cycle',
    'monthly': 'Monthly',
    'yearly': 'Yearly',
    'category_field': 'Category',
    'next_billing_date': 'Next billing date',
    'add_subscription_button': 'Add subscription',

    // Profile
    'profile_title': 'Profile',
    'profile_load_failed': 'Could not load saved profile. Showing demo data.',
    'profile_field_updated': '%s updated',
    'profile_save_failed': 'Could not save changes. Please try again.',
    'your_profile': 'Your profile',
    'your_personal_details': 'Your personal details · Demo profile',
    'details_complete': 'Your details are complete',
    'complete_your_profile': 'Complete your profile',
    'details_added_count': '%s of 3 details added',
    'add_field': 'Add %s',
    'not_available': 'Not available',
    'add_your_field': 'Add your %s',
    'edit_field_tooltip': 'Edit %s',
    'profile_local_note':
        'Your profile details are saved on this device. They are not '
        'verified account credentials in this demo.',
    'change_password': 'Change password',
    'edit_field_title': 'Edit %s',
    'field_full_name': 'Full name',
    'field_email': 'Email',
    'field_phone_number': 'Phone number',
    'field_joined_on': 'Joined on',

    // Profile validation
    'validation_required': 'This field is required',
    'validation_name_length': 'Enter a name between 2 and 80 characters',
    'validation_email': 'Enter a valid email',
    'validation_phone_local': 'Use 05XXXXXXXX or +9665XXXXXXXX',
    'validation_phone_country_code':
        'Include your country code, e.g. +9665XXXXXXXX',

    // Login / signup
    'brand_tagline': 'Your spending, in balance.',
    'login_heading': 'Login',
    'signin_subtitle': 'Sign in to your account',
    'username': 'Username',
    'email': 'Email',
    'password': 'Password',
    'sign_in_button': 'SIGN IN',
    'no_account_signup': "Don't have an account? Sign up",
    'finances_on_device': 'Your finances stay on your device',
    'enter_your_field': 'Enter your %s',
    'show_password': 'Show password',
    'hide_password': 'Hide password',
    'signup_heading': 'Sign up',
    'create_account_subtitle': 'Create your Riyal account',
    'full_name': 'Full name',
    'confirm_password': 'Confirm password',
    'create_account_button': 'CREATE ACCOUNT',
    'have_account_signin': 'Already have an account? Sign in',
    'demo_no_account': 'Demo only - No account is created',
    'valid_email_error': 'Enter a valid email',
    'password_length_error': 'Use at least 8 characters',
    'passwords_no_match': 'Passwords do not match',
    'sign_in_generic_error': 'Could not sign in. Please try again.',
    'sign_up_generic_error': 'Could not create your account. Please try again.',
    'check_email_to_confirm':
        'Check your email to confirm your account, then sign in.',

    // Splash
    'splash_tagline': 'Know where your money goes.',

    // Contact us
    'contact_us_title': 'Contact us',
    'contact_header_title': 'We are here to help',
    'contact_header_subtitle':
        'Have a question or an idea for Riyal? Start here.',
    'quick_answers': 'QUICK ANSWERS',
    'faq_q1': 'How do I add a payment?',
    'faq_a1':
        'Open Subscriptions, Utilities or Staff and use the add option. '
        'Choose an existing provider or enter the payment details.',
    'faq_q2': 'When will I get a reminder?',
    'faq_a2':
        'The default is five days before a payment. You can choose one, '
        'three, five or seven days in Settings. Reminders appear in the '
        'app while it is running or when you return to it.',
    'faq_q3': 'Does Riyal connect to my bank?',
    'faq_a3':
        'Not in this demo. The current app uses sample payment data and '
        'manual entries.',
    'faq_q4': 'Why did my added payments disappear?',
    'faq_a4':
        'Payment lists are currently held in memory and reset after '
        'restarting the app. Profile edits, settings and read-notification '
        'status are saved locally.',
    'share_feedback': 'Share your feedback',
    'share_feedback_sub':
        'Prepare a message to copy and share. Sending from the app is not '
        'connected in this demo.',
    'topic': 'Topic',
    'topic_suggestion': 'Suggestion',
    'topic_report_issue': 'Report an issue',
    'topic_question': 'Question',
    'your_message': 'Your message',
    'message_hint': 'Tell us what could be better...',
    'message_min_length': 'Please write at least 10 characters.',
    'copying': 'Copying...',
    'copy_message': 'Copy message',
    'message_copied': 'Message copied. You can share it with the Riyal team.',
    'copy_failed': 'Could not copy. Select and copy the message manually.',
    'thank_you_feedback': 'Thank you for helping improve Riyal.',
    'feedback_message_header': 'Riyal feedback',

    // Change password
    'change_password_demo_note':
        'Demo form. Password changes will be available when account '
        'authentication is connected.',
    'current_password': 'Current password',
    'new_password': 'New password',
    'confirm_new_password': 'Confirm new password',
    'enter_a_password': 'Enter a password',
    'choose_different_password': 'Choose a different password',
    'password_changed_demo':
        'Demo validation passed. No password has been changed.',

    // Notifications
    'notifications_title': 'Notifications',
    'no_notifications_yet': 'No notifications yet',
    'all_notifications': 'All notifications',
    'show_less': 'Show less',
    'unread_notifications': 'Unread notifications',
    'account_menu': 'Account menu',
    'account': 'Account',
    'profile_menu_item': 'Profile',
    'settings_menu_item': 'Settings',
    'contact_us_menu_item': 'Contact us',
    'log_out': 'Log out',

    // Bank accounts (mocked — see supabase/migrations/0003_mock_banking.sql)
    'accounts_title': 'Bank accounts',
    'accounts_sub': 'Connect and manage your bank accounts',
    'add_account': 'Add account',
    'no_accounts_yet': 'No bank accounts connected yet.\nTap + to connect one.',
    'disconnect': 'Disconnect',
    'connected_bank': 'Connected bank',
    'suggested_subscriptions': 'Suggested from your bank',
    'suggested_subscriptions_sub':
        'Recurring charges we spotted in your transactions.',
    'add_suggestion': 'Add',
    'occurrences_count': '%s charges seen',

    // Mock bank connect flow
    'connect_bank_title': 'Connect a bank',
    'connect_bank_forced_title': 'Connect your first bank',
    'connect_bank_forced_subtitle':
        'Connect at least one bank account to continue to Riyal.',
    'choose_your_bank': 'Choose your bank',
    'mock_bank_disclaimer':
        'Simulated bank connection for this demo — no real bank is '
        'contacted, and any login works.',
    'bank_login_username_hint': 'National ID / Username',
    'bank_login_button': 'Log in',
    'connecting_to_bank': 'Connecting to %s…',
    'bank_connected_title': 'Bank connected!',
    'bank_connected_body': '%s has been linked to your Riyal account.',
    'bank_connect_failed': 'Could not connect. Please try again.',
    'continue_button': 'Continue',
    'done_button': 'Done',

    // Notification-generated text
    'notice_new_subscription': 'New subscription',
    'notice_new_commitment': 'New payment commitment',
    'notice_renewal_reminder': 'Subscription renewal reminder',
    'notice_payment_reminder': 'Payment reminder',
    'monthly_review_notice_title': 'Your monthly money check-in is ready',
    'monthly_review_notice_message':
        'Review your subscriptions and payment commitments to find saving opportunities.',
  };

  static const _ar = <String, String>{
    'nav_home': 'الرئيسية',
    'nav_subscriptions': 'الاشتراكات',
    'nav_utilities': 'المرافق',
    'nav_staff': 'الموظفون',

    'renews_today': 'يتجدد اليوم',
    'analytics_tab': 'التحليلات',
    'general': 'عام',
    'upcoming_renewals': 'التجديدات القادمة',
    'see_all': 'عرض الكل',
    'cancel': 'إلغاء',
    'save': 'حفظ',
    'close': 'إغلاق',
    'back': 'رجوع',

    'settings_title': 'الإعدادات',
    'settings_header_title': 'اجعل ريال خاصًا بك',
    'settings_header_subtitle': 'بعض التفضيلات لمدفوعاتك اليومية.',
    'payment_reminders_section': 'تذكيرات الدفع',
    'monthly_review_setting': 'المراجعة المالية الشهرية',
    'monthly_review_setting_sub':
        'استلم تذكيرًا واحدًا كل شهر لمراجعة جميع التزاماتك.',
    'monthly_review_day': 'يوم تذكير المراجعة',
    'day_of_month': 'يوم %s',
    'monthly_review_card_title': 'مراجعتك المالية الشهرية',
    'monthly_review_card_sub': 'راجع التزاماتك واكتشف فرص التوفير.',
    'monthly_review_completed': 'اكتملت مراجعة هذا الشهر',
    'monthly_review_completed_sub':
        'اعرض اقتراحاتك. ستتوفر المراجعة القادمة الشهر المقبل.',
    'upcoming_payments': 'المدفوعات القادمة',
    'upcoming_payments_sub': 'التجديدات وفواتير المرافق ومدفوعات الموظفين.',
    'remind_before_payment': 'ذكّرني قبل الدفع',
    'day_singular': 'يوم',
    'day_plural': 'أيام',
    'reminder_note':
        'ينطبق على التذكيرات الجديدة في صندوق الوارد داخل التطبيق. '
        'الرسائل الحالية تبقى في سجلك. تظل إشعارات العناصر الجديدة مفعّلة.',
    'personal_details': 'البيانات الشخصية',
    'personal_details_sub': 'الاسم والبريد الإلكتروني ورقم الهاتف',
    'currency': 'العملة',
    'currency_sub': 'ريال سعودي',
    'appearance': 'المظهر',
    'appearance_sub': 'مظهر ريال الداكن',
    'language': 'اللغة',
    'language_sub': 'اختر لغة التطبيق',
    'language_english': 'English',
    'language_arabic': 'العربية',
    'data_on_device_title': 'بياناتك، على جهازك',
    'data_on_device_body':
        'يتم حفظ تعديلات الملف الشخصي والتفضيلات وحالة قراءة الإشعارات '
        'محليًا. بيانات الدفع حاليًا تجريبية وتُعاد ضبطها عند إعادة تشغيل '
        'التطبيق. لا يوجد حساب بنكي متصل.',
    'help_feedback': 'المساعدة والملاحظات',
    'help_feedback_sub': 'إجابات سريعة واقتراحات',
    'settings_footer': 'ريال · نسخة تجريبية للطلاب',
    'settings_saved': 'تم حفظ الإعدادات',
    'settings_save_failed': 'تعذر حفظ الإعدادات. حاول مرة أخرى.',

    'overview': 'نظرة عامة',
    'spending_heading': 'إنفاق هذا الشهر\nعلى الاشتراكات',
    'of_sar_budget': 'من ميزانية %s ريال',
    'sar_left': 'متبقٍ %s ريال',
    'no_subscriptions_yet_short': 'لا توجد اشتراكات بعد.',

    'category_entertainment': 'ترفيه',
    'category_ai': 'الذكاء الاصطناعي',
    'category_productivity': 'الإنتاجية',
    'category_cloud_storage': 'التخزين السحابي',
    'category_fitness_wellness': 'اللياقة والعافية',
    'category_education': 'التعليم',
    'category_shopping_delivery': 'التسوق والتوصيل',
    'category_other': 'أخرى',
    'category_electricity': 'الكهرباء',
    'category_water': 'المياه',
    'category_internet': 'الإنترنت',
    'category_mobile': 'الجوال',
    'category_gas': 'الغاز',
    'category_household': 'المنزل',
    'category_childcare': 'رعاية الأطفال',
    'category_driving': 'القيادة',
    'category_security': 'الأمن',
    'category_all': 'الكل',

    'group_streaming': 'البث',
    'group_productivity': 'الإنتاجية',
    'group_fitness': 'اللياقة',
    'group_learning': 'التعلم',
    'group_electricity': 'الكهرباء',
    'group_internet': 'الإنترنت',
    'group_water': 'المياه',
    'group_household': 'المنزل',
    'group_transport': 'المواصلات',

    'noun_singular_utility_bill': 'فاتورة مرافق',
    'noun_plural_utility_bill': 'فواتير المرافق',
    'add_from_scratch_utility_bill': 'اختر مزود الخدمة',
    'noun_singular_staff_member': 'فرد من الطاقم',
    'noun_plural_staff_member': 'أفراد الطاقم',
    'add_from_scratch_staff_member': 'اختر الدور',
    'search_hint_utilities': 'ابحث في المرافق',
    'search_hint_staff': 'ابحث عن الموظفين',
    'search_hint_subscriptions': 'ابحث في الاشتراكات',

    'analytics_general_title': 'التحليلات العامة',
    'illustrative_estimates': 'تقديرات توضيحية من بيانات العرض الشهرية.',
    'category_split': 'تقسيم الفئات',
    'spending_breakdown': 'تفصيل الإنفاق',
    'overall_budget_vs_actual': 'الميزانية الإجمالية مقابل الفعلي',
    'category_budget_vs_actual': 'ميزانية الفئة مقابل الفعلي',
    'combined_budget_note': 'ميزانية مجمعة، منفصلة عن حدود الفئات.',
    'highest_cost_item': 'العنصر الأعلى تكلفة',
    'highest_cost_items_tied': 'العناصر الأعلى تكلفة · متعادلة',
    'spend_over_time': 'الإنفاق عبر الزمن',
    'remaining': 'متبقٍ',
    'over_budget': 'تجاوز الميزانية',
    'each': 'لكل واحد',
    'active_items': 'عنصر نشط',
    'sample_data': 'بيانات تجريبية',
    'week_ending': 'الأسبوع المنتهي في',
    'period_week': 'أسبوع',
    'period_month': 'شهر',
    'period_year': 'سنة',
    'period_adj_weekly': 'الأسبوعي',
    'period_adj_monthly': 'الشهري',
    'period_adj_yearly': 'السنوي',

    'add_a_subscription': 'إضافة اشتراك',
    'how_would_you_add': 'كيف تود إضافته؟',
    'from_previous_transaction': 'من معاملة سابقة',
    'pick_from_recent_charges': 'اختر من عملياتك الأخيرة',
    'from_scratch': 'من البداية',
    'choose_app_enter_details': 'اختر تطبيقًا وأدخل التفاصيل',
    'choose_an_app': 'اختر تطبيقًا',
    'search_apps': 'ابحث عن التطبيقات',
    'no_apps_found': 'لم يتم العثور على تطبيقات',
    'search_generic': 'بحث',
    'no_results_found': 'لا توجد نتائج',
    'recent_transactions': 'المعاملات الأخيرة',
    'tap_charge_to_track_item': 'اضغط على عملية لتحويلها إلى عنصر متابَع',
    'tap_charge_to_track_subscription':
        'اضغط على عملية لتحويلها إلى اشتراك متابَع',
    'days_ago_suffix': 'ي مضت',

    'subscription_details': 'تفاصيل الاشتراك',
    'details': 'التفاصيل',
    'amount_sar': 'المبلغ (ريال)',
    'billing_cycle': 'دورة الفوترة',
    'monthly': 'شهري',
    'yearly': 'سنوي',
    'category_field': 'الفئة',
    'next_billing_date': 'تاريخ الفوترة القادم',
    'add_subscription_button': 'إضافة اشتراك',

    'profile_title': 'الملف الشخصي',
    'profile_load_failed':
        'تعذر تحميل الملف الشخصي المحفوظ. جارٍ عرض بيانات تجريبية.',
    'profile_field_updated': 'تم تحديث %s',
    'profile_save_failed': 'تعذر حفظ التغييرات. حاول مرة أخرى.',
    'your_profile': 'ملفك الشخصي',
    'your_personal_details': 'بياناتك الشخصية · ملف تجريبي',
    'details_complete': 'بياناتك مكتملة',
    'complete_your_profile': 'أكمل ملفك الشخصي',
    'details_added_count': 'تمت إضافة %s من أصل 3 بيانات',
    'add_field': 'أضف %s',
    'not_available': 'غير متاح',
    'add_your_field': 'أضف %s',
    'edit_field_tooltip': 'تعديل %s',
    'profile_local_note':
        'تُحفظ بيانات ملفك الشخصي على هذا الجهاز. وهي ليست بيانات اعتماد '
        'حساب موثقة في هذا العرض التجريبي.',
    'change_password': 'تغيير كلمة المرور',
    'edit_field_title': 'تعديل %s',
    'field_full_name': 'الاسم الكامل',
    'field_email': 'البريد الإلكتروني',
    'field_phone_number': 'رقم الهاتف',
    'field_joined_on': 'تاريخ الانضمام',

    'validation_required': 'هذا الحقل مطلوب',
    'validation_name_length': 'أدخل اسمًا يتراوح بين 2 و80 حرفًا',
    'validation_email': 'أدخل بريدًا إلكترونيًا صحيحًا',
    'validation_phone_local': 'استخدم 05XXXXXXXX أو +9665XXXXXXXX',
    'validation_phone_country_code': 'أدخل رمز الدولة، مثل +9665XXXXXXXX',

    'brand_tagline': 'إنفاقك، في توازن.',
    'login_heading': 'تسجيل الدخول',
    'signin_subtitle': 'سجّل الدخول إلى حسابك',
    'username': 'اسم المستخدم',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'sign_in_button': 'تسجيل الدخول',
    'no_account_signup': 'ليس لديك حساب؟ أنشئ حسابًا',
    'finances_on_device': 'تبقى بياناتك المالية على جهازك',
    'enter_your_field': 'أدخل %s',
    'show_password': 'إظهار كلمة المرور',
    'hide_password': 'إخفاء كلمة المرور',
    'signup_heading': 'إنشاء حساب',
    'create_account_subtitle': 'أنشئ حساب ريال الخاص بك',
    'full_name': 'الاسم الكامل',
    'confirm_password': 'تأكيد كلمة المرور',
    'create_account_button': 'إنشاء حساب',
    'have_account_signin': 'لديك حساب بالفعل؟ سجّل الدخول',
    'demo_no_account': 'عرض تجريبي فقط - لا يتم إنشاء أي حساب',
    'valid_email_error': 'أدخل بريدًا إلكترونيًا صحيحًا',
    'password_length_error': 'استخدم 8 أحرف على الأقل',
    'passwords_no_match': 'كلمتا المرور غير متطابقتين',
    'sign_in_generic_error': 'تعذر تسجيل الدخول. حاول مرة أخرى.',
    'sign_up_generic_error': 'تعذر إنشاء حسابك. حاول مرة أخرى.',
    'check_email_to_confirm':
        'تحقق من بريدك الإلكتروني لتأكيد حسابك، ثم سجّل الدخول.',

    'splash_tagline': 'اعرف إلى أين يذهب مالك.',

    'contact_us_title': 'اتصل بنا',
    'contact_header_title': 'نحن هنا للمساعدة',
    'contact_header_subtitle': 'لديك سؤال أو فكرة لتطبيق ريال؟ ابدأ هنا.',
    'quick_answers': 'إجابات سريعة',
    'faq_q1': 'كيف أضيف دفعة؟',
    'faq_a1':
        'افتح الاشتراكات أو المرافق أو الموظفين واستخدم خيار الإضافة. '
        'اختر مزودًا موجودًا أو أدخل تفاصيل الدفعة.',
    'faq_q2': 'متى سأحصل على تذكير؟',
    'faq_a2':
        'الافتراضي هو خمسة أيام قبل الدفع. يمكنك اختيار يوم أو ثلاثة أو '
        'خمسة أو سبعة أيام من الإعدادات. تظهر التذكيرات أثناء تشغيل '
        'التطبيق أو عند عودتك إليه.',
    'faq_q3': 'هل يتصل ريال بحسابي البنكي؟',
    'faq_a3':
        'ليس في هذا العرض التجريبي. يستخدم التطبيق حاليًا بيانات دفع تجريبية وإدخالات يدوية.',
    'faq_q4': 'لماذا اختفت المدفوعات التي أضفتها؟',
    'faq_a4':
        'يتم حفظ قوائم المدفوعات حاليًا في الذاكرة وتُعاد ضبطها بعد '
        'إعادة تشغيل التطبيق. تُحفظ تعديلات الملف الشخصي والإعدادات '
        'وحالة قراءة الإشعارات محليًا.',
    'share_feedback': 'شارك ملاحظاتك',
    'share_feedback_sub':
        'جهّز رسالة لنسخها ومشاركتها. الإرسال من داخل التطبيق غير مفعّل '
        'في هذا العرض التجريبي.',
    'topic': 'الموضوع',
    'topic_suggestion': 'اقتراح',
    'topic_report_issue': 'الإبلاغ عن مشكلة',
    'topic_question': 'سؤال',
    'your_message': 'رسالتك',
    'message_hint': 'أخبرنا بما يمكن تحسينه...',
    'message_min_length': 'يرجى كتابة 10 أحرف على الأقل.',
    'copying': 'جارٍ النسخ...',
    'copy_message': 'نسخ الرسالة',
    'message_copied': 'تم نسخ الرسالة. يمكنك مشاركتها مع فريق ريال.',
    'copy_failed': 'تعذر النسخ. حدد الرسالة وانسخها يدويًا.',
    'thank_you_feedback': 'شكرًا لمساعدتك في تحسين ريال.',
    'feedback_message_header': 'ملاحظات ريال',

    'change_password_demo_note':
        'نموذج تجريبي. ستتوفر إمكانية تغيير كلمة المرور عند ربط '
        'المصادقة الفعلية للحساب.',
    'current_password': 'كلمة المرور الحالية',
    'new_password': 'كلمة المرور الجديدة',
    'confirm_new_password': 'تأكيد كلمة المرور الجديدة',
    'enter_a_password': 'أدخل كلمة مرور',
    'choose_different_password': 'اختر كلمة مرور مختلفة',
    'password_changed_demo':
        'اجتاز التحقق التجريبي. لم يتم تغيير أي كلمة مرور.',

    'notifications_title': 'الإشعارات',
    'no_notifications_yet': 'لا توجد إشعارات بعد',
    'all_notifications': 'جميع الإشعارات',
    'show_less': 'عرض أقل',
    'unread_notifications': 'إشعارات غير مقروءة',
    'account_menu': 'قائمة الحساب',
    'account': 'الحساب',
    'profile_menu_item': 'الملف الشخصي',
    'settings_menu_item': 'الإعدادات',
    'contact_us_menu_item': 'اتصل بنا',
    'log_out': 'تسجيل الخروج',

    'accounts_title': 'الحسابات البنكية',
    'accounts_sub': 'اربط حساباتك البنكية وأدرها',
    'add_account': 'إضافة حساب',
    'no_accounts_yet': 'لا توجد حسابات بنكية متصلة بعد.\nاضغط + لربط حساب.',
    'disconnect': 'قطع الاتصال',
    'connected_bank': 'بنك متصل',
    'suggested_subscriptions': 'مقترحة من حسابك البنكي',
    'suggested_subscriptions_sub': 'مدفوعات متكررة رصدناها في معاملاتك.',
    'add_suggestion': 'إضافة',
    'occurrences_count': 'شوهدت %s مرات',

    // Mock bank connect flow
    'connect_bank_title': 'ربط حساب بنكي',
    'connect_bank_forced_title': 'اربط أول حساب بنكي لك',
    'connect_bank_forced_subtitle':
        'اربط حساباً بنكياً واحداً على الأقل للمتابعة إلى ريال.',
    'choose_your_bank': 'اختر بنكك',
    'mock_bank_disclaimer':
        'اتصال بنكي وهمي لأغراض هذا العرض التوضيحي — لا يتم الاتصال بأي بنك '
        'حقيقي، وأي بيانات دخول تعمل.',
    'bank_login_username_hint': 'رقم الهوية / اسم المستخدم',
    'bank_login_button': 'تسجيل الدخول',
    'connecting_to_bank': 'جارٍ الاتصال بـ %s…',
    'bank_connected_title': 'تم ربط الحساب البنكي!',
    'bank_connected_body': 'تم ربط %s بحسابك في ريال.',
    'bank_connect_failed': 'تعذر الربط. حاول مرة أخرى.',
    'continue_button': 'متابعة',
    'done_button': 'تم',

    'notice_new_subscription': 'اشتراك جديد',
    'notice_new_commitment': 'التزام دفع جديد',
    'notice_renewal_reminder': 'تذكير بتجديد الاشتراك',
    'notice_payment_reminder': 'تذكير بالدفع',
    'monthly_review_notice_title': 'مراجعتك المالية الشهرية جاهزة',
    'monthly_review_notice_message':
        'راجع اشتراكاتك والتزاماتك المالية واكتشف فرص التوفير.',
  };
}
