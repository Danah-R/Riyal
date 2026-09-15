import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CapsuleTabOption<T> {
  const CapsuleTabOption(this.label, this.value);
  final String label;
  final T value;
}

/// A row of text options inside one shared capsule shell, with a single
/// indicator that measures each option's real rendered bounds and slides
/// between them — used for every top-of-page 2-3-way toggle (Home's
/// Overview/Analytics/Accounts, and each Subscriptions/Utilities/People
/// page's own List/Analytics toggle), so they all look and move alike.
class CapsuleTabSelector<T> extends StatefulWidget {
  const CapsuleTabSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<CapsuleTabOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  State<CapsuleTabSelector<T>> createState() => _CapsuleTabSelectorState<T>();
}

class _CapsuleTabSelectorState<T> extends State<CapsuleTabSelector<T>> {
  final _stackKey = GlobalKey();
  late Map<T, GlobalKey> _tabKeys = _buildKeys();
  Rect? _indicator;

  Map<T, GlobalKey> _buildKeys() => {
    for (final o in widget.options) o.value: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant CapsuleTabSelector<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options.length != widget.options.length) {
      _tabKeys = _buildKeys();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    final tabBox =
        _tabKeys[widget.selected]?.currentContext?.findRenderObject()
            as RenderBox?;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (tabBox == null || stackBox == null || !tabBox.attached) return;
    final origin = tabBox.localToGlobal(Offset.zero, ancestor: stackBox);
    final rect = origin & tabBox.size;
    if (mounted && rect != _indicator) setState(() => _indicator = rect);
  }

  @override
  Widget build(BuildContext context) {
    Widget tab(CapsuleTabOption<T> option) {
      final isSelected = widget.selected == option.value;
      return GestureDetector(
        key: _tabKeys[option.value],
        onTap: () => widget.onChanged(option.value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          child: Text(
            option.label,
            style: TextStyle(
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    Widget divider() => Container(
      width: 1,
      height: 16,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: AppColors.cardBorder,
    );

    final children = <Widget>[];
    for (var i = 0; i < widget.options.length; i++) {
      if (i > 0) children.add(divider());
      children.add(tab(widget.options[i]));
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          key: _stackKey,
          alignment: Alignment.centerLeft,
          children: [
            if (_indicator != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                left: _indicator!.left,
                top: _indicator!.top,
                width: _indicator!.width,
                height: _indicator!.height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            Row(mainAxisSize: MainAxisSize.min, children: children),
          ],
        ),
      ),
    );
  }
}
