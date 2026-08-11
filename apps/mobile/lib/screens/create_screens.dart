import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/badge_theme.dart';
import '../models/app_models.dart';
import '../state/app_controller.dart';
import '../widgets/badge_components.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  final _prompt = TextEditingController();
  final _styles = const ['软萌线条', '像素潮玩', '梦幻童话', '未来机能'];
  final _personas = const [
    ('元气搭子', '先出发，开心会在路上追上我们！'),
    ('温柔守护', '慢一点也没关系，我会陪着你。'),
    ('冷面吐槽', '勉强算你今天做得还不错。'),
    ('好奇学者', '这个问题很有趣，我们拆开看看。'),
  ];

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AiBadgeTheme.dark,
    child: Builder(
      builder: (context) {
        final state = ref.watch(appControllerProvider);
        final controller = ref.read(appControllerProvider.notifier);
        return Scaffold(
          appBar: AppBar(
            title: const Text('创造你的搭子'),
            leading: IconButton(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text('先选一个画风', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text(
                '不需要写复杂提示词，结构化选择会帮你得到稳定结果。',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _styles
                    .map(
                      (style) => EmotionChip(
                        label: style,
                        selected: state.selectedStyle == style,
                        onTap: () => controller.chooseStyle(style),
                        color: context.tokens.pink,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 28),
              Text('还有什么特别要求？', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: _prompt,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: '例如：薄荷绿色头发、喜欢星星、戴一顶小帽子……',
                ),
              ),
              const SizedBox(height: 28),
              Text('TA 的人格', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ..._personas.map((persona) {
                final selected = state.selectedPersona == persona.$1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: selected
                        ? context.tokens.mint
                        : const Color(0xFF282828),
                    borderRadius: BorderRadius.circular(22),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => controller.choosePersona(persona.$1),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    persona.$1,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: selected
                                          ? context.tokens.ink
                                          : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '“${persona.$2}”',
                                    style: TextStyle(
                                      color: selected
                                          ? context.tokens.ink.withValues(
                                              alpha: .72,
                                            )
                                          : Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: context.tokens.ink,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              PrimaryPillButton(
                light: true,
                label: '生成 3 个候选',
                icon: Icons.auto_awesome_rounded,
                onPressed: () {
                  context.go('/generation');
                  unawaited(controller.generateCharacter());
                },
              ),
            ],
          ),
        );
      },
    ),
  );
}

class GenerationScreen extends ConsumerWidget {
  const GenerationScreen({super.key});

  String _label(GenerationStatus status) => switch (status) {
    GenerationStatus.queued => '正在排队',
    GenerationStatus.generating => '正在绘制角色',
    GenerationStatus.moderating => '正在检查结果',
    GenerationStatus.succeeded => '选一个最像你的搭子',
    GenerationStatus.failedRetryable => '暂时生成失败',
    GenerationStatus.failedFinal => '内容不适合生成',
    GenerationStatus.cancelled => '生成已取消',
    GenerationStatus.idle => '准备生成',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) => Theme(
    data: AiBadgeTheme.dark,
    child: Builder(
      builder: (context) {
        final state = ref.watch(appControllerProvider);
        final controller = ref.read(appControllerProvider.notifier);
        final done = state.generationStatus == GenerationStatus.succeeded;
        return Scaffold(
          appBar: AppBar(
            title: const Text('AI 角色生成'),
            leading: IconButton(
              onPressed: () => context.go('/create'),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              Text(
                _label(state.generationStatus),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                done ? '长按可以放大预览，确认后还可以继续编辑。' : '可以离开此页面，任务会在后台继续。',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              if (!done) ...[
                CharacterStage(character: state.character),
                const SizedBox(height: 24),
                ProgressRail(
                  value: state.generationProgress,
                  label: _label(state.generationStatus),
                ),
              ] else ...[
                ...List.generate(3, (index) {
                  const colors = [0xFFF5A6D9, 0xFF78E7C7, 0xFF89DDF0];
                  final candidate = BadgeCharacter(
                    id: 'candidate-$index',
                    name: ['桃桃', '米露', '泡泡'][index],
                    color: colors[index],
                    persona: state.selectedPersona,
                  );
                  final selected = state.character?.id == 'character-$index';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Material(
                      color: selected
                          ? context.tokens.mint
                          : const Color(0xFF282828),
                      borderRadius: BorderRadius.circular(28),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => controller.selectCharacter(index),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 120,
                                child: CharacterStage(
                                  character: candidate,
                                  compact: true,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      candidate.name,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: selected
                                            ? context.tokens.ink
                                            : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${state.selectedStyle} · ${state.selectedPersona}',
                                      style: TextStyle(
                                        color: selected
                                            ? context.tokens.ink.withValues(
                                                alpha: .7,
                                              )
                                            : Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: context.tokens.ink,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                PrimaryPillButton(
                  light: true,
                  label: state.character == null ? '请选择一个角色' : '使用这个角色',
                  onPressed: state.character == null
                      ? null
                      : () => context.go('/device'),
                ),
              ],
            ],
          ),
        );
      },
    ),
  );
}
