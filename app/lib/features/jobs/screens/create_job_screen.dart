import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/relayit_theme.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/destination.dart';
import '../models/job.dart';
import '../providers/jobs_provider.dart';
import '../widgets/destination_row.dart';

const _uuid = Uuid();

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  int _step = 0;

  final _nameCtrl = TextEditingController();
  final _sourceCtrl = TextEditingController();
  SourceType _sourceType = SourceType.senderId;
  final List<Destination> _destinations = [];

  final _keywordCtrl = TextEditingController();
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  final _dedupCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sourceCtrl.dispose();
    _keywordCtrl.dispose();
    _dedupCtrl.dispose();
    super.dispose();
  }

  bool get _step1Valid =>
      _nameCtrl.text.trim().isNotEmpty && _sourceCtrl.text.trim().isNotEmpty;

  bool get _step2Valid => _destinations.isNotEmpty;

  Future<void> _addDestination() async {
    final created = await showModalBottomSheet<Destination>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _AddDestinationSheet(),
    );
    if (created != null) {
      setState(() => _destinations.add(created));
      if (created.type == DestinationType.whatsapp ||
          created.type == DestinationType.email) {
        await _maybeShowWhatsappEmailDialog();
      }
    }
  }

  Future<void> _maybeShowWhatsappEmailDialog() async {
    final settings = ref.read(settingsNotifierProvider);
    if (settings.whatsappEmailDialogShown) return;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.whatsappEmailDialogTitle),
        content: const Text(AppStrings.whatsappEmailDialogBody),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
    await ref
        .read(settingsNotifierProvider.notifier)
        .markWhatsappEmailDialogShown();
  }

  Future<void> _save() async {
    if (!_step1Valid || !_step2Valid) return;
    final job = Job(
      id: _uuid.v4(),
      name: _nameCtrl.text.trim(),
      sourceType: _sourceType,
      sourceValue: _sourceCtrl.text.trim(),
      destinations: List.unmodifiable(_destinations),
      createdAt: DateTime.now(),
    );
    await ref.read(jobsNotifierProvider.notifier).add(job);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New job')),
      body: Column(
        children: [
          _StepIndicator(currentStep: _step),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: switch (_step) {
                0 => _buildStep1(),
                1 => _buildStep2(),
                _ => _buildStep3(),
              },
            ),
          ),
          _BottomCtaRow(
            primaryLabel: _step == 2 ? 'Save job' : 'Continue',
            primaryEnabled: switch (_step) {
              0 => _step1Valid,
              1 => _step2Valid,
              _ => _step1Valid && _step2Valid,
            },
            onCancel: () {
              if (_step == 0) {
                context.pop();
              } else {
                setState(() => _step -= 1);
              }
            },
            cancelLabel: _step == 0 ? 'Cancel' : 'Back',
            onPrimary: () {
              if (_step < 2) {
                setState(() => _step += 1);
              } else {
                _save();
              }
            },
          ),
        ],
      ),
    );
  }

  // -------- Step 1 --------
  Widget _buildStep1() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final hint = isLight
        ? RelayitColors.textSecondary
        : RelayitColors.darkText2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(text: 'Job name'),
        const SizedBox(height: 6),
        TextField(
          controller: _nameCtrl,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(hintText: 'e.g. GST alerts'),
        ),
        const SizedBox(height: 18),
        _SectionLabel(text: 'Source type'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            for (final t in SourceType.values)
              ChoiceChip(
                label: Text(_sourceTypeLabel(t)),
                selected: _sourceType == t,
                onSelected: (_) => setState(() => _sourceType = t),
              ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionLabel(text: 'Source value'),
        const SizedBox(height: 6),
        TextField(
          controller: _sourceCtrl,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(hintText: _sourceHint(_sourceType)),
        ),
        const SizedBox(height: 8),
        Text(
          'Matching is partial and case-insensitive: a source value of "HDFC" matches "HDFCBK", "AD-HDFC", etc.',
          style: RelayitTextStyles.caption(color: hint),
        ),
      ],
    );
  }

  String _sourceHint(SourceType t) => switch (t) {
    SourceType.senderId => 'HDFCBK',
    SourceType.phoneNumber => '+919810055555',
    SourceType.contactName => 'CA Rohan',
  };

  String _sourceTypeLabel(SourceType t) => switch (t) {
    SourceType.senderId => 'Sender ID',
    SourceType.phoneNumber => 'Phone number',
    SourceType.contactName => 'Contact name',
  };

  // -------- Step 2 --------
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(text: 'Destinations'),
        const SizedBox(height: 6),
        if (_destinations.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Add at least one destination to continue.'),
          )
        else
          Column(
            children: [
              for (var i = 0; i < _destinations.length; i++) ...[
                DestinationRow(
                  destination: _destinations[i],
                  onDelete: () => setState(() => _destinations.removeAt(i)),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addDestination,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add destination'),
        ),
      ],
    );
  }

  // -------- Step 3 --------
  Widget _buildStep3() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final hint = isLight
        ? RelayitColors.textSecondary
        : RelayitColors.darkText2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SectionLabel(text: 'Filters'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: RelayitColors.accentLight,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Optional',
                style: RelayitTextStyles.caption(
                  color: RelayitColors.accentDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.filtersV1Disclaimer,
          style: RelayitTextStyles.caption(color: hint),
        ),
        const SizedBox(height: 18),
        _SectionLabel(text: 'Keyword filter'),
        const SizedBox(height: 6),
        TextField(
          controller: _keywordCtrl,
          decoration: const InputDecoration(
            hintText: 'Only relay if body contains…',
          ),
        ),
        const SizedBox(height: 18),
        _SectionLabel(text: 'Time window'),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _TimeButton(
                label: _fromTime == null
                    ? 'From'
                    : 'From ${_fromTime!.format(context)}',
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime:
                        _fromTime ?? const TimeOfDay(hour: 9, minute: 0),
                  );
                  if (picked != null) setState(() => _fromTime = picked);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TimeButton(
                label: _toTime == null
                    ? 'To'
                    : 'To ${_toTime!.format(context)}',
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime:
                        _toTime ?? const TimeOfDay(hour: 22, minute: 0),
                  );
                  if (picked != null) setState(() => _toTime = picked);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionLabel(text: 'Dedup window (minutes)'),
        const SizedBox(height: 6),
        TextField(
          controller: _dedupCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Skip duplicates within N min',
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall,
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: Align(alignment: Alignment.centerLeft, child: Text(label)),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});
  final int currentStep;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i <= currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
              height: 4,
              decoration: BoxDecoration(
                color: isActive
                    ? RelayitColors.accent
                    : (Theme.of(context).brightness == Brightness.light
                          ? RelayitColors.bgMuted
                          : RelayitColors.darkBgMuted),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BottomCtaRow extends StatelessWidget {
  const _BottomCtaRow({
    required this.primaryLabel,
    required this.primaryEnabled,
    required this.cancelLabel,
    required this.onCancel,
    required this.onPrimary,
  });
  final String primaryLabel;
  final bool primaryEnabled;
  final String cancelLabel;
  final VoidCallback onCancel;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                child: Text(cancelLabel),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: primaryEnabled ? onPrimary : null,
                child: Text(primaryLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddDestinationSheet extends StatefulWidget {
  const _AddDestinationSheet();

  @override
  State<_AddDestinationSheet> createState() => _AddDestinationSheetState();
}

class _AddDestinationSheetState extends State<_AddDestinationSheet> {
  DestinationType _type = DestinationType.whatsapp;
  final _labelCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();

  @override
  void dispose() {
    _labelCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  String _hint(DestinationType t) => switch (t) {
    DestinationType.whatsapp => '+919810055555',
    DestinationType.email => 'name@example.com',
    DestinationType.sms => '+919810055555',
  };

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add destination',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final t in DestinationType.values)
                ChoiceChip(
                  label: Text(_typeLabel(t)),
                  selected: _type == t,
                  onSelected: (_) => setState(() => _type = t),
                ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _labelCtrl,
            decoration: const InputDecoration(
              labelText: 'Label',
              hintText: 'e.g. CA, Wife, Self',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _valueCtrl,
            decoration: InputDecoration(
              labelText: _type == DestinationType.email
                  ? 'Email address'
                  : 'Phone',
              hintText: _hint(_type),
            ),
            keyboardType: _type == DestinationType.email
                ? TextInputType.emailAddress
                : TextInputType.phone,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final value = _valueCtrl.text.trim();
                    if (value.isEmpty) return;
                    Navigator.of(context).pop(
                      Destination(
                        id: _uuid.v4(),
                        type: _type,
                        label: _labelCtrl.text.trim(),
                        value: value,
                      ),
                    );
                  },
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _typeLabel(DestinationType t) => switch (t) {
    DestinationType.whatsapp => 'WhatsApp',
    DestinationType.email => 'Email',
    DestinationType.sms => 'SMS',
  };
}
