import 'package:booklub/config/theme/theme_config.dart';
import 'package:booklub/domain/club_membership/entities/club_pending_entry.dart';
import 'package:booklub/domain/entities/users/user.dart';
import 'package:booklub/ui/clubs/profile/view_models/club_profile_view_model.dart';
import 'package:booklub/ui/core/view_models/user_view_model.dart';
import 'package:booklub/ui/core/widgets/circle_image_widget.dart';
import 'package:booklub/ui/core/widgets/grids/infinite_grid_widget.dart';
import 'package:booklub/utils/async_builder.dart';
import 'package:booklub/utils/pagination/paginator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClubRequestsListWidget extends StatefulWidget {
  const ClubRequestsListWidget({super.key});

  @override
  State<ClubRequestsListWidget> createState() => _ClubRequestsListWidgetState();
}

class _ClubRequestsListWidgetState extends State<ClubRequestsListWidget> {
  late Future<Paginator<ClubPendingEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ClubProfileViewModel>().getClubRequests(8);
  }

  void _reload() {
    setState(() {
      _future = context.read<ClubProfileViewModel>().getClubRequests(8);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder(
      future: _future,
      onRetrieved: (paginator) =>
          Builder(builder: (ctx) => _onRetrieved(ctx, paginator)),
      onLoading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      onError: (_, _) => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('Erro ao carregar solicitações')),
        ),
      ),
    );
  }

  Widget _onRetrieved(
    BuildContext context,
    Paginator<ClubPendingEntry> paginator,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final scrollController = context.read<ScrollController>();

    if (paginator.totalElements == 0) {
      return SliverPadding(
        padding: const EdgeInsets.all(24),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: Text(
              'Nenhuma solicitação pendente.',
              style: textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    final gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 1,
      childAspectRatio: 9 / 3,
      mainAxisSpacing: 12,
    );

    SliverChildBuilderDelegate childrenDelegateProvider(
      List<ClubPendingEntry> entries,
      int total,
    ) => SliverChildBuilderDelegate(
      (context, index) => _RequestCard(entry: entries[index], onHandled: _reload),
      childCount: total,
    );

    return SliverPadding(
      padding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 36),
      sliver: InfiniteGridWidget.sliver(
        paginator: paginator,
        controller: scrollController,
        gridDelegate: gridDelegate,
        childrenDelegateProvider: childrenDelegateProvider,
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  final ClubPendingEntry entry;
  final VoidCallback onHandled;

  const _RequestCard({required this.entry, required this.onHandled});

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _busy = false;

  Future<void> _handle(
    Future<void> Function(ClubProfileViewModel vm) action,
    String message,
  ) async {
    final vm = context.read<ClubProfileViewModel>();
    setState(() => _busy = true);
    try {
      await action(vm);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        widget.onHandled();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível concluir a ação.')),
        );
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder(
      future: context.read<UserViewModel>().getUser(widget.entry.userId),
      onLoading: () => _buildCard(context, null),
      onError: (_, _) => _buildCard(context, null),
      onRetrieved: (user) => _buildCard(context, user),
    );
  }

  Widget _buildCard(BuildContext context, User? user) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final decorationImage = (user?.imageUrl != null && user!.imageUrl!.isNotEmpty)
        ? DecorationImage(image: NetworkImage(user.imageUrl!), fit: BoxFit.cover)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          spacing: 12,
          children: [
            CircleImageWidget(
              radius: 24,
              backgroundColor: colorScheme.white,
              borderColor: colorScheme.primary,
              borderWidth: 2,
              decorationImage: decorationImage,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user?.fullName ?? 'Usuário',
                    style: textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user != null)
                    Text(
                      '@${user.username}',
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else ...[
              IconButton(
                tooltip: 'Aceitar',
                onPressed: () => _handle(
                  (vm) => vm.acceptRequest(widget.entry.userId),
                  'Solicitação aceita.',
                ),
                icon: Icon(Icons.check_circle, color: colorScheme.primary),
              ),
              IconButton(
                tooltip: 'Recusar',
                onPressed: () => _handle(
                  (vm) => vm.denyRequest(widget.entry.userId),
                  'Solicitação recusada.',
                ),
                icon: Icon(Icons.cancel, color: colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}