import 'package:booklub/domain/activities/entities/activity_filter.dart';
import 'package:booklub/domain/entities/clubs/activities/club_activity.dart';
import 'package:booklub/ui/clubs/profile/view_models/club_profile_view_model.dart';
import 'package:booklub/ui/core/widgets/cards/activity_cards/activity_card_builder.dart';
import 'package:booklub/ui/core/widgets/grids/infinite_grid_widget.dart';
import 'package:booklub/ui/core/widgets/section_selector_widget.dart';
import 'package:booklub/utils/async_builder.dart';
import 'package:booklub/utils/pagination/paginator.dart';
import 'package:flutter/material.dart';
import 'package:booklub/utils/logger/app_logger.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ClubFeedWidget extends StatefulWidget {

  const ClubFeedWidget({super.key});

  @override
  State<ClubFeedWidget> createState() => _ClubFeedWidgetState();

}

class _ClubFeedWidgetState extends State<ClubFeedWidget> {

  final logger = AppLogger.create();

  ActivityFilter filter = ActivityFilter.all;

  Paginator<ClubActivity>? paginator;

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      children: [
        Builder(builder: _buildFeedFilterSelector),
        _buildActivitiesList(),
      ],
    );
  }

  Widget _buildFeedFilterSelector(BuildContext context) {
    final sections = ActivityFilter.values.map((f) => SectionSelectorItem(
      label: switch (f) {
        ActivityFilter.all => 'Atividades',
        ActivityFilter.readings => 'Leituras',
        ActivityFilter.meetings => 'Encontros',
      },
      onSelect: () => setState(() => filter = f),
      isSelected: filter == f,
    )).toList();

    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          boxShadow: [BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 4
          )]
        ),
        padding: EdgeInsets.symmetric(vertical: 6),
        child: SectionSelectorWidget(
          sections: sections,
          spacing: 8,
        ),
      ),
    );
  }

  Widget _buildActivitiesList() {
    final viewModel = context.read<ClubProfileViewModel>();

    return AsyncBuilder(
      future: viewModel.getClubActivities(
        10,
        types: filter.toActivityTypes(),
      ),
      onRetrieved: (paginator) => Builder(
        builder: (context) => _buildList(
          context,
          paginator,
          (item) => ActivityCardBuilder(
            activity: item,
            showAuthorHeader: false,
          ),
        ),
      ),
      onLoading: () => Builder(builder: _buildOnLoadingList),
      onError: (e, trace) => Builder(
        builder: (context) => _buildOnErrorList(
          context,
          'Erro ao buscar atividades',
          e,
          trace,
        )
      )
    );
  }

  Widget _buildList<T>(
    BuildContext context,
    Paginator<T> paginator,
    Widget Function(T item) itemBuilder,
  ) {
    final controller = context.read<ScrollController>();

    final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 1,
      mainAxisSpacing: 12,
      childAspectRatio: 4/2
    );

    SliverChildBuilderDelegate childrenDelegateProvider(List<T> itens, int total) {
      return SliverChildBuilderDelegate(
        (context, index) => itemBuilder(itens[index]),
        childCount: itens.length,
      );
    }

    return SliverPadding(
      padding: EdgeInsets.only(
        top: 12,
        left: 12,
        right: 12,
        bottom: 36
      ),
      sliver: InfiniteGridWidget.sliver(
        paginator: paginator,
        controller: controller,
        gridDelegate: gridDelegate,
        useSliverList: true,
        childrenDelegateProvider: childrenDelegateProvider,
      ),
    );
  }

  Widget _buildOnLoadingList(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildOnErrorList(
    BuildContext context,
    String message,
    Object error,
    StackTrace stackTrace
  ) {
    logger.e('Error: $error \n Stack Trace: $stackTrace');

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Text(message),
      ),
    );
  }

}
