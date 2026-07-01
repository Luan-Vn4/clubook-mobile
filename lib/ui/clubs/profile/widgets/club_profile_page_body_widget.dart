import 'package:booklub/ui/clubs/profile/view_models/club_profile_view_model.dart';
import 'package:booklub/ui/clubs/profile/widgets/_club_feed_widget.dart';
import 'package:booklub/ui/clubs/profile/widgets/_club_members_list_widget.dart';
import 'package:booklub/ui/clubs/profile/widgets/_club_profile_info_list_widget.dart';
import 'package:booklub/ui/clubs/profile/widgets/_club_reading_goals_list_widget.dart';
import 'package:booklub/ui/clubs/profile/widgets/_club_requests_list_widget.dart';
import 'package:booklub/utils/async_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

typedef _MembershipStatus = ({
  bool isOwner,
  bool isMember,
  bool hasPendingRequest,
});

class ClubProfilePageBodyWidget extends StatefulWidget {

  const ClubProfilePageBodyWidget({super.key});

  @override
  State<ClubProfilePageBodyWidget> createState() => _ClubProfilePageBodyWidgetState();

}

enum ProfileInfoSection {members, readings, badges, requests}

class _ClubProfilePageBodyWidgetState extends State<ClubProfilePageBodyWidget> {

  ProfileInfoSection? selectedProfileInfoSection;

  Future<_MembershipStatus>? _membershipFuture;
  bool _membershipBusy = false;

  void _setSection(ProfileInfoSection section) {
    setState(() {
      selectedProfileInfoSection =
      selectedProfileInfoSection == section ? null : section;
    });
  }

  Future<_MembershipStatus> _membership(BuildContext context) {
    return _membershipFuture ??=
        context.read<ClubProfileViewModel>().loadMembershipStatus();
  }

  void _reloadMembership() {
    setState(() {
      _membershipFuture =
          context.read<ClubProfileViewModel>().loadMembershipStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageBody = selectedProfileInfoSection != null
      ? Builder(builder: _buildProfileInfoDetails)
      : ClubFeedWidget();

    return MultiSliver(
      children: [
        Builder(builder: _buildMembershipAction),
        Builder(builder: _buildProfileInfo),
        pageBody
      ]
    );
  }

  Widget _buildMembershipAction(BuildContext context) {
    return SliverToBoxAdapter(
      child: AsyncBuilder(
        future: _membership(context),
        onLoading: () => const SizedBox.shrink(),
        onError: (_, _) => const SizedBox.shrink(),
        onRetrieved: (status) {
          if (status.isOwner) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: _buildMembershipButton(context, status),
          );
        },
      ),
    );
  }

  Widget _buildMembershipButton(BuildContext context, _MembershipStatus status) {
    if (status.isMember) {
      return OutlinedButton.icon(
        onPressed: _membershipBusy
            ? null
            : () => _runMembershipAction(
                (vm) => vm.leaveClub(),
                'Você saiu do clube.',
              ),
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Sair do clube'),
      );
    }

    if (status.hasPendingRequest) {
      return OutlinedButton.icon(
        onPressed: _membershipBusy
            ? null
            : () => _runMembershipAction(
                (vm) => vm.cancelJoinRequest(),
                'Solicitação cancelada.',
              ),
        icon: const Icon(Icons.hourglass_top_rounded),
        label: const Text('Solicitação enviada — cancelar'),
      );
    }

    return FilledButton.icon(
      onPressed: _membershipBusy
          ? null
          : () => _runMembershipAction(
              (vm) => vm.sendJoinRequest(),
              'Solicitação enviada!',
            ),
      icon: const Icon(Icons.group_add_rounded),
      label: const Text('Solicitar entrada'),
    );
  }

  Future<void> _runMembershipAction(
    Future<void> Function(ClubProfileViewModel vm) action,
    String successMessage,
  ) async {
    final vm = context.read<ClubProfileViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _membershipBusy = true);
    try {
      await action(vm);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
      _reloadMembership();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível concluir a ação.')),
      );
    } finally {
      if (mounted) setState(() => _membershipBusy = false);
    }
  }

  Widget _buildProfileInfo(BuildContext context) {
    final viewModel = context.watch<ClubProfileViewModel>();
    final club = viewModel.club!;

    Widget onRetrieved(({bool isAdmin, int readingsCount}) info) {
      final profileInfos = [
        ClubProfileInfoListItem(
          label: 'Membros',
          number: club.totalMembers,
          onTap: () => _setSection(ProfileInfoSection.members),
          selected: selectedProfileInfoSection == ProfileInfoSection.members,
        ),
        ClubProfileInfoListItem(
          label: 'Leituras',
          number: viewModel.totalReadingGoals ?? 0,
          onTap: () => _setSection(ProfileInfoSection.readings),
          selected: selectedProfileInfoSection == ProfileInfoSection.readings,
        ),
        if (info.isAdmin) ClubProfileInfoListItem(
          label: 'Solicitações',
          number: viewModel.totalPendingRequests ?? 0,
          onTap: () => _setSection(ProfileInfoSection.requests),
          selected: selectedProfileInfoSection == ProfileInfoSection.requests,
        ),
      ];

      return ClubProfileInfoListWidget(infoItems: profileInfos);
    }

    return AsyncBuilder(
      future: _loadProfileInfo(viewModel),
      onRetrieved: onRetrieved,
      onLoading: () => const SizedBox.shrink(),
      onError: (_, _) => const SizedBox.shrink(),
    );
  }

  Future<({bool isAdmin, int readingsCount})> _loadProfileInfo(
    ClubProfileViewModel viewModel,
  ) async {
    final isAdmin = await viewModel.isLoggedUserClubAdmin();
    final readingsCount = await viewModel.getClubReadingGoalsCount();
    return (isAdmin: isAdmin, readingsCount: readingsCount);
  }

  Widget _buildProfileInfoDetails(BuildContext context) {
    final placeholder = const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Placeholder(),
      ),
    );

    return switch (selectedProfileInfoSection) {
      ProfileInfoSection.members => const ClubMembersListWidget(),
      ProfileInfoSection.readings => const ClubReadingGoalsListWidget(),
      ProfileInfoSection.badges => placeholder,
      ProfileInfoSection.requests => const ClubRequestsListWidget(),
      _ => throw UnimplementedError('Section not implemented'),
    };
  }

}


