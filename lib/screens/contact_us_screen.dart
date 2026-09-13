import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_back_button.dart';
import '../widgets/account_section.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});
  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _form = GlobalKey<FormState>();
  final _message = TextEditingController();
  String _topic = 'Suggestion';
  bool _copying = false;
  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _copy() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _copying = true);
    try {
      await Clipboard.setData(
        ClipboardData(
          text: 'Riyal feedback\nTopic: $_topic\n\n${_message.text.trim()}',
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Message copied. You can share it with the Riyal team.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not copy. Select and copy the message manually.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _copying = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.background,
      leading: const CoinBackButton(),
      title: const Text('Contact us'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AccountPageHeader(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'We are here to help',
                subtitle: 'Have a question or an idea for Riyal? Start here.',
              ),
              const Text(
                'QUICK ANSWERS',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 12,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              AccountSection(
                child: Column(
                  children: [
                    for (final faq in const [
                      (
                        'How do I add a payment?',
                        'Open Subscriptions, Utilities or Staff and use the add option. Choose an existing provider or enter the payment details.',
                      ),
                      (
                        'When will I get a reminder?',
                        'The default is five days before a payment. You can choose one, three, five or seven days in Settings. Reminders appear in the app while it is running or when you return to it.',
                      ),
                      (
                        'Does Riyal connect to my bank?',
                        'Not in this demo. The current app uses sample payment data and manual entries.',
                      ),
                      (
                        'Why did my added payments disappear?',
                        'Payment lists are currently held in memory and reset after restarting the app. Profile edits, settings and read-notification status are saved locally.',
                      ),
                    ])
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        iconColor: AppColors.gold,
                        collapsedIconColor: AppColors.gold,
                        title: Text(
                          faq.$1,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        childrenPadding: const EdgeInsets.only(bottom: 16),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              faq.$2,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AccountSection(
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Share your feedback',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Prepare a message to copy and share. Sending from the app is not connected in this demo.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        initialValue: _topic,
                        dropdownColor: AppColors.surface,
                        decoration: InputDecoration(
                          labelText: 'Topic',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        items: ['Suggestion', 'Report an issue', 'Question']
                            .map(
                              (topic) => DropdownMenuItem(
                                value: topic,
                                child: Text(topic),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _topic = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _message,
                        minLines: 5,
                        maxLines: 8,
                        maxLength: 2000,
                        decoration: InputDecoration(
                          labelText: 'Your message',
                          alignLabelWithHint: true,
                          hintText: 'Tell us what could be better...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        validator: (value) => (value?.trim().length ?? 0) < 10
                            ? 'Please write at least 10 characters.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.background,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: _copying ? null : _copy,
                        icon: const Icon(Icons.copy_outlined, size: 20),
                        label: Text(_copying ? 'Copying...' : 'Copy message'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Thank you for helping improve Riyal.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
