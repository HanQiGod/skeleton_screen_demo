import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter 骨架屏 Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F8F7),
        useMaterial3: true,
      ),
      home: const SkeletonScreenDemoPage(),
    );
  }
}

enum DemoEffect {
  shimmer('微光'),
  pulse('脉冲'),
  solid('纯色');

  const DemoEffect(this.label);

  final String label;

  PaintingEffect get effect {
    switch (this) {
      case DemoEffect.shimmer:
        return const ShimmerEffect(
          baseColor: Color(0xFFE2E8F0),
          highlightColor: Color(0xFFF8FAFC),
          duration: Duration(milliseconds: 1100),
        );
      case DemoEffect.pulse:
        return const PulseEffect(
          from: Color(0xFFE2E8F0),
          to: Color(0xFFF1F5F9),
          duration: Duration(milliseconds: 900),
        );
      case DemoEffect.solid:
        return const SolidColorEffect(color: Color(0xFFE5EDF5));
    }
  }

  String get helperText {
    switch (this) {
      case DemoEffect.shimmer:
        return '默认推荐，强调加载中的动感反馈。';
      case DemoEffect.pulse:
        return '节奏更柔和，适合信息密度高的页面。';
      case DemoEffect.solid:
        return '完全静态，没有动画，最省性能。';
    }
  }
}

class SkeletonScreenDemoPage extends StatefulWidget {
  const SkeletonScreenDemoPage({super.key});

  @override
  State<SkeletonScreenDemoPage> createState() => _SkeletonScreenDemoPageState();
}

class _SkeletonScreenDemoPageState extends State<SkeletonScreenDemoPage> {
  static const List<IconData> _coverIcons = <IconData>[
    Icons.auto_awesome_rounded,
    Icons.view_agenda_rounded,
    Icons.widgets_rounded,
    Icons.layers_rounded,
    Icons.rocket_launch_rounded,
  ];

  static const List<Color> _coverColors = <Color>[
    Color(0xFF0F766E),
    Color(0xFF0369A1),
    Color(0xFF7C3AED),
    Color(0xFFB45309),
    Color(0xFFBE123C),
  ];

  late final List<ShowcaseItem> _realItems = <ShowcaseItem>[
    ShowcaseItem(
      title: '推荐流首屏：让用户先看到版式，再等数据回来',
      subtitle: '用 Skeletonizer 包裹现有列表卡片，不重写 UI 也能快速接入骨架屏。',
      author: '体验组',
      avatarText: '体',
      dateLabel: '今天',
      readTime: '4 分钟读完',
      category: '快速接入',
      tags: const <String>['Skeletonizer', '低侵入'],
      accentColor: _coverColors[0],
      coverIcon: _coverIcons[0],
    ),
    ShowcaseItem(
      title: 'BoneMock 假数据：占位长度更接近真实内容',
      subtitle: '加载态不再只是一排一样长的灰条，而是更像最终会出现的文本层次。',
      author: '前端实验室',
      avatarText: '前',
      dateLabel: '昨天',
      readTime: '5 分钟读完',
      category: '假数据',
      tags: const <String>['BoneMock', '文本长度'],
      accentColor: _coverColors[1],
      coverIcon: _coverIcons[1],
    ),
    ShowcaseItem(
      title: '局部控制：Logo 保持可见，紧邻图标自动合并',
      subtitle: 'ignore、keep、unite 这类标记可以让骨架屏既自动化，又保留精细控制力。',
      author: '组件库',
      avatarText: '组',
      dateLabel: '04/06',
      readTime: '6 分钟读完',
      category: '精细控制',
      tags: const <String>['ignore', 'unite'],
      accentColor: _coverColors[2],
      coverIcon: _coverIcons[2],
    ),
    ShowcaseItem(
      title: 'replace 与 leaf：复杂区域直接替换，摘要卡片整块骨架化',
      subtitle: '媒体封面和概览模块通常不需要逐层拆解，整体替换能更稳、更省心。',
      author: '移动端架构',
      avatarText: '架',
      dateLabel: '04/05',
      readTime: '3 分钟读完',
      category: '复杂组件',
      tags: const <String>['replace', 'leaf'],
      accentColor: _coverColors[3],
      coverIcon: _coverIcons[3],
    ),
    ShowcaseItem(
      title: '老项目接入：先改一个页面，再慢慢推广到更多模块',
      subtitle: '保留原生导航和业务链路，只在 Flutter 页面内先把加载体验做得更完整。',
      author: 'Add-to-App',
      avatarText: 'A',
      dateLabel: '04/04',
      readTime: '7 分钟读完',
      category: '渐进集成',
      tags: const <String>['Add-to-App', '平滑升级'],
      accentColor: _coverColors[4],
      coverIcon: _coverIcons[4],
    ),
  ];

  late final List<ShowcaseItem> _mockItems = List<ShowcaseItem>.generate(
    5,
    (int index) => ShowcaseItem(
      title: BoneMock.words(2),
      subtitle: BoneMock.words(5),
      author: BoneMock.name,
      avatarText: 'S',
      dateLabel: BoneMock.date,
      readTime: '${index + 3} 分钟读完',
      category: BoneMock.words(1),
      tags: <String>[BoneMock.words(1), BoneMock.words(1)],
      accentColor: _coverColors[index % _coverColors.length],
      coverIcon: _coverIcons[index % _coverIcons.length],
    ),
  );

  Timer? _loadingTimer;
  bool _isLoading = true;
  DemoEffect _selectedEffect = DemoEffect.shimmer;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _simulateLoading([Duration duration = const Duration(seconds: 2)]) {
    _loadingTimer?.cancel();
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }
    _loadingTimer = Timer(duration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _toggleLoading() {
    _loadingTimer?.cancel();
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<ShowcaseItem> items = _isLoading ? _mockItems : _realItems;

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter 骨架屏 Demo'), centerTitle: false),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFFF2F7F6),
              Color(0xFFE5F0EE),
              Color(0xFFF8FAFC),
            ],
            stops: <double>[0.0, 0.32, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: _ControlPanel(
                  isLoading: _isLoading,
                  selectedEffect: _selectedEffect,
                  onToggleLoading: _toggleLoading,
                  onSimulateLoading: _simulateLoading,
                  onEffectChanged: (DemoEffect effect) {
                    setState(() {
                      _selectedEffect = effect;
                    });
                  },
                ),
              ),
              Expanded(
                child: Skeletonizer(
                  enabled: _isLoading,
                  effect: _selectedEffect.effect,
                  enableSwitchAnimation: true,
                  containersColor: const Color(0xFFE2E8F0),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: <Widget>[
                      _SectionIntro(
                        title: '页面结构先出现，数据随后补齐',
                        description:
                            '这个示例把文章里的关键点都放进了一页：BoneMock 假数据、切换动画，以及 ignore / keep / unite / replace / leaf 的局部控制。',
                      ),
                      const SizedBox(height: 16),
                      Skeleton.leaf(child: _SummaryCard(theme: theme)),
                      const SizedBox(height: 20),
                      Text(
                        '推荐内容',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '点击顶部按钮可以反复体验加载态和内容态之间的切换。',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF475569),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (final ShowcaseItem item in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _ArticleCard(item: item),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
    required this.isLoading,
    required this.selectedEffect,
    required this.onToggleLoading,
    required this.onSimulateLoading,
    required this.onEffectChanged,
  });

  final bool isLoading;
  final DemoEffect selectedEffect;
  final VoidCallback onToggleLoading;
  final ValueChanged<DemoEffect> onEffectChanged;
  final void Function([Duration duration]) onSimulateLoading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              child: _LoadingStatusPill(
                key: ValueKey<bool>(isLoading),
                isLoading: isLoading,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '告别白屏焦虑',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '骨架屏不是单纯的“正在加载”，而是先把页面结构交给用户，让等待变得更有预期。',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.55,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const <Widget>[
                _FeatureChip(label: 'BoneMock'),
                _FeatureChip(label: 'ignore'),
                _FeatureChip(label: 'keep'),
                _FeatureChip(label: 'unite'),
                _FeatureChip(label: 'replace'),
                _FeatureChip(label: 'leaf'),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                FilledButton.tonalIcon(
                  onPressed: onSimulateLoading,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('模拟请求'),
                ),
                OutlinedButton.icon(
                  onPressed: onToggleLoading,
                  icon: Icon(
                    isLoading
                        ? Icons.visibility_rounded
                        : Icons.hourglass_top_rounded,
                  ),
                  label: Text(isLoading ? '结束加载' : '直接显示内容'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              '动画效果',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<DemoEffect>(
                showSelectedIcon: false,
                segments: DemoEffect.values
                    .map(
                      (DemoEffect effect) => ButtonSegment<DemoEffect>(
                        value: effect,
                        label: Text(effect.label),
                      ),
                    )
                    .toList(),
                selected: <DemoEffect>{selectedEffect},
                onSelectionChanged: (Set<DemoEffect> selection) {
                  onEffectChanged(selection.first);
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              selectedEffect.helperText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingStatusPill extends StatelessWidget {
  const _LoadingStatusPill({super.key, required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final Color color = isLoading
        ? const Color(0xFF0F766E)
        : const Color(0xFF2563EB);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            isLoading ? '骨架屏加载中' : '内容已就绪',
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD6E0EA)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDE7EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF475569),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF0F766E), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x240F766E),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '为什么骨架屏更优雅',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '在真实业务里，摘要区和统计卡通常最能代表页面结构，因此也最适合用 leaf 整块骨架化。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: const <Widget>[
                Expanded(
                  child: _SummaryMetric(value: '结构先达', label: '减少等待时的未知感'),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SummaryMetric(value: '切换柔和', label: '避免内容突然跳入视野'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.item});

  final ShowcaseItem item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Skeleton.replace(
              replacement: const _CardCoverPlaceholder(),
              child: _CardCover(
                icon: item.coverIcon,
                accentColor: item.accentColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Skeleton.ignore(
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: item.accentColor,
                          child: Text(
                            item.avatarText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.author,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        item.dateLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF475569),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      Skeleton.keep(
                        child: _MetaPill(
                          text: item.category,
                          backgroundColor: item.accentColor.withValues(
                            alpha: 0.12,
                          ),
                          foregroundColor: item.accentColor,
                        ),
                      ),
                      for (final String tag in item.tags)
                        Skeleton.keep(
                          child: _MetaPill(
                            text: tag,
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: const Color(0xFF475569),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      Skeleton.unite(
                        borderRadius: BorderRadius.circular(999),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List<Widget>.generate(
                            3,
                            (int index) => const Padding(
                              padding: EdgeInsets.only(right: 3),
                              child: Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        item.readTime,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String text;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CardCover extends StatelessWidget {
  const _CardCover({required this.icon, required this.accentColor});

  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[accentColor, accentColor.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 12,
            right: 10,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -10,
            bottom: -12,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(child: Icon(icon, size: 34, color: Colors.white)),
        ],
      ),
    );
  }
}

class _CardCoverPlaceholder extends StatelessWidget {
  const _CardCoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}

class ShowcaseItem {
  const ShowcaseItem({
    required this.title,
    required this.subtitle,
    required this.author,
    required this.avatarText,
    required this.dateLabel,
    required this.readTime,
    required this.category,
    required this.tags,
    required this.accentColor,
    required this.coverIcon,
  });

  final String title;
  final String subtitle;
  final String author;
  final String avatarText;
  final String dateLabel;
  final String readTime;
  final String category;
  final List<String> tags;
  final Color accentColor;
  final IconData coverIcon;
}
