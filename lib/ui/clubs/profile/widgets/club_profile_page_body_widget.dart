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

class ClubProfilePageBodyWidget extends StatefulWidget {

  const ClubProfilePageBodyWidget({super.key});

  @override
  State<ClubProfilePageBodyWidget> createState() => _ClubProfilePageBodyWidgetState();

}

enum ProfileInfoSection {members, readings, badges, requests}

class _ClubProfilePageBodyWidgetState extends State<ClubProfilePageBodyWidget> {

  ProfileInfoSection? selectedProfileInfoSection;

  void _setSection(ProfileInfoSection section) {
    setState(() {
      selectedProfileInfoSection =
      selectedProfileInfoSection == section ? null : section;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageBody = selectedProfileInfoSection != null
      ? Builder(builder: _buildProfileInfoDetails)
      : ClubFeedWidget();

    return MultiSliver(
      children: [
        Builder(builder: _buildProfileInfo),
        pageBody
      ]
    );
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


