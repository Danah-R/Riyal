import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/strings.dart';
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
  String _topicKey = 'suggestion';
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
          text:
              '${Strings.t('feedback_message_header')}\n'
              '${Strings.t('topic')}: ${Strings.t('topic_$_topicKey')}\n\n'
              '${_message.text.trim()}',
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(Strings.t('message_copied'))));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(Strings.t('copy_failed'))));
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
      title: Text(Strings.t('contact_us_title')),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AccountPageHeader(
                icon: Icons.chat_bubble_outline_rounded,
                title: Strings.t('contact_header_title'),
                subtitle: Strings.t('contact_header_subtitle'),
              ),
              Text(
                Strings.t('quick_answers'),
                style: const TextStyle(
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
                    for (final faqKeys in const [
                      ('faq_q1', 'faq_a1'),
                      ('faq_q2', 'faq_a2'),
                    ])
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        iconColor: AppColors.gold,
                        collapsedIconColor: AppColors.gold,
                        title: Text(
                          Strings.t(faqKeys.$1),
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
                              Strings.t(faqKeys.$2),
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
                      Text(
                        Strings.t('share_feedback'),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Strings.t('share_feedback_sub'),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        initialValue: _topicKey,
                        dropdownColor: AppColors.surface,
                        decoration: InputDecoration(
                          labelText: Strings.t('topic'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        items: ['suggestion', 'report_issue', 'question']
                            .map(
                              (topicKey) => DropdownMenuItem(
                                value: topicKey,
                                child: Text(Strings.t('topic_$topicKey')),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _topicKey = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _message,
                        minLines: 5,
                        maxLines: 8,
                        maxLength: 2000,
                        decoration: InputDecoration(
                          labelText: Strings.t('your_message'),
                          alignLabelWithHint: true,
                          hintText: Strings.t('message_hint'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        validator: (value) => (value?.trim().length ?? 0) < 10
                            ? Strings.t('message_min_length')
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
                        label: Text(
                          _copying
                              ? Strings.t('copying')
                              : Strings.t('copy_message'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  Strings.t('thank_you_feedback'),
                  style: const TextStyle(
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
