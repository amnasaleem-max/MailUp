import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mail_up/core/router/router_definitions.dart';
import 'package:mail_up/features/home/data/models/email_models.dart';
import 'package:mail_up/features/home/presentation/pages/insights_screen.dart';
import 'package:mail_up/features/home/presentation/providers/mail_provider.dart';
import 'package:mail_up/features/home/presentation/widgets/app_drawer.dart';
import 'package:mail_up/features/home/presentation/widgets/label_assign_sheet.dart';
import 'package:mail_up/features/home/presentation/widgets/label_filter_bar.dart';
import 'package:mail_up/features/settings/presentation/pages/personalization_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const InboxView(),
    const InsightsScreen(),
    const PersonalizationScreen(),
  ];
  
  StreamSubscription<RemoteMessage>? _msgSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _msgSub = FirebaseMessaging.onMessage.listen((message) {
      if (mounted) {
        final selectedLabelId = ref.read(selectedLabelIdProvider);
        ref.read(mailInboxProvider(labelId: selectedLabelId).notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _msgSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        final selectedLabelId = ref.read(selectedLabelIdProvider);
        ref.read(mailInboxProvider(labelId: selectedLabelId).notifier).refresh();
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: Theme.of(context).colorScheme.primaryContainer,
          destinations: const [
            NavigationDestination(
              icon: Icon(Bootstrap.inbox),
              selectedIcon: Icon(Bootstrap.inbox_fill),
              label: 'Inbox',
            ),
            NavigationDestination(
              icon: Icon(Bootstrap.gear),
              selectedIcon: Icon(Bootstrap.gear_fill),
              label: 'Settings',
            ),
            NavigationDestination(
              icon: Icon(Bootstrap.cpu),
              selectedIcon: Icon(Bootstrap.cpu_fill),
              label: 'AI',
            ),
          ],
        ),
      ),
    );
  }
}

class InboxView extends ConsumerStatefulWidget {
  const InboxView({super.key});

  @override
  ConsumerState<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends ConsumerState<InboxView> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        final selectedLabelId = ref.read(selectedLabelIdProvider);
        ref
            .read(mailInboxProvider(labelId: selectedLabelId).notifier)
            .silentRefresh();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabelId = ref.watch(selectedLabelIdProvider);
    final mailState = ref.watch(mailInboxProvider(labelId: selectedLabelId));
    final labels = ref.watch(mailLabelsProvider).asData?.value;

    final currentLabelName = selectedLabelId == null
        ? 'Inbox'
        : labels
                ?.firstWhere(
                  (l) => l.id == selectedLabelId,
                  orElse: () =>
                      EmailLabel(id: '', name: 'Inbox', type: 'system'),
                )
                .name ??
            'Inbox';

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200 &&
            !ref.read(mailInboxProvider(labelId: selectedLabelId)).isLoading) {
          ref
              .read(mailInboxProvider(labelId: selectedLabelId).notifier)
              .loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => ref
            .read(mailInboxProvider(labelId: selectedLabelId).notifier)
            .refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              title: Text(
                currentLabelName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => context.pushNamed(AppRoute.search.name),
                ),
                const SizedBox(width: 8),
              ],
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(52),
                child: LabelFilterBar(),
              ),
            ),
            mailState.when(
              data: (state) {
                if (state.messages.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No emails found')),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Bottom status widget
                      if (index == state.messages.length) {
                        if (state.isLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (!state.hasMore) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                "You're all caught up",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox(height: 16);
                      }

                      final email = state.messages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 6.0,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              context.pushNamed(
                                AppRoute.summaryDetail.name,
                                extra: {'emailId': email.id, 'email': email},
                              );
                            },
                            onLongPress: () {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (_) =>
                                    LabelAssignSheet(email: email),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.1),
                                    child: Text(
                                      email.sender.isNotEmpty
                                          ? email.sender[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                email.sender,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              DateFormat.jm().format(
                                                email.date,
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(fontSize: 11),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          email.subject,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          email.snippet,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color!
                                                    .withValues(alpha: 0.7),
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: state.messages.length + 1,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) {
                debugPrint('Inbox Error: $error');
                return SliverFillRemaining(
                  child: Center(child: Text('Error loading emails')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
