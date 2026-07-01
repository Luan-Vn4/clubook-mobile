import 'package:booklub/config/routing/routes.dart';
import 'package:booklub/ui/clubs/meetings/widgets/location_picker.dart';
import 'package:booklub/ui/clubs/meetings/widgets/location_search_dropdown.dart';
import 'package:booklub/ui/clubs/meetings/widgets/reading_goal_selector.dart';
import 'package:booklub/ui/core/view_models/creating_meeting_view_model.dart';
import 'package:booklub/ui/core/widgets/buttons/purple_rounded_button.dart';
import 'package:booklub/ui/core/widgets/input_fields/named_date_field_widget.dart';
import 'package:booklub/ui/core/widgets/input_fields/named_time_field_widget.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CreateMeetingPage extends StatefulWidget {
  final String clubId;

  const CreateMeetingPage({super.key, required this.clubId});

  @override
  State<CreateMeetingPage> createState() => _CreateMeetingPageState();
}

class _CreateMeetingPageState extends State<CreateMeetingPage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _locationFieldKey = GlobalKey();
  final LayerLink _locationFieldLink = LayerLink();

  OverlayEntry? _locationOverlay;
  double _fieldWidth = 0;
  CreateMeetingViewModel? _vm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _vm = context.read<CreateMeetingViewModel>();
      _vm!.loadReadingGoals();
      _vm!.addListener(_onLocationSearchChanged);
    });
  }

  @override
  void dispose() {
    _vm?.removeListener(_onLocationSearchChanged);
    _hideLocationDropdown();
    super.dispose();
  }

  void _onLocationSearchChanged() {
    if (!mounted) return;
    final vm = _vm;
    if (vm == null) return;

    _fieldWidth = _locationFieldKey.currentContext?.size?.width ??
        (MediaQuery.sizeOf(context).width - 48);

    final isVisible =
        vm.locationSearchState == LocationSearchState.loading ||
            vm.locationSearchState == LocationSearchState.results ||
            vm.locationSearchState == LocationSearchState.error;

    if (isVisible) {
      if (_locationOverlay == null) {
        _showLocationDropdown(vm);
      } else {
        _locationOverlay?.markNeedsBuild();
      }
    } else {
      _hideLocationDropdown();
    }
  }

  void _showLocationDropdown(CreateMeetingViewModel vm) {
    _locationOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: vm.clearLocationSearch,
              ),
            ),
            CompositedTransformFollower(
              link: _locationFieldLink,
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              offset: const Offset(0, 4),
              child: SizedBox(
                width: _fieldWidth,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surface,
                  child: LocationSearchDropdown(
                    results: vm.locationResults,
                    isLoading:
                        vm.locationSearchState == LocationSearchState.loading,
                    hasError:
                        vm.locationSearchState == LocationSearchState.error,
                    onSelected: vm.selectLocation,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_locationOverlay!);
  }

  void _hideLocationDropdown() {
    _locationOverlay?.remove();
    _locationOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateMeetingViewModel>();

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          spacing: 24,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Builder(builder: _buildLogo),
            Builder(builder: (_) => _buildForm(context, viewModel)),
            Builder(builder: (_) => _buildButton(context, viewModel)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Image.asset(
      'assets/images/booklub_logo_icon.png',
      height: MediaQuery.sizeOf(context).height * 0.20,
    );
  }

  Widget _buildForm(BuildContext context, CreateMeetingViewModel vm) {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 24,
        children: [
          LocationPicker(
            addressController: vm.addressInput.controller,
            onAddressChanged: vm.searchAddress,
            pinLocation: vm.latlngInput.value,
            onMapTapped: vm.onMapTapped,
            fieldLink: _locationFieldLink,
            fieldKey: _locationFieldKey,
          ),
          NamedDateFieldWidget(
            label: "Data",
            inputWrapper: vm.dateTextInput,
            onDateSelected: vm.setDate,
          ),
          NamedTimeFieldWidget(
            label: "Horário",
            inputWrapper: vm.timeTextInput,
            onTimeSelected: (time) => vm.setTime(time, context),
          ),
          ReadingGoalSelector(
            goals: vm.readingGoals,
            selected: vm.selectedReadingGoal,
            onSelect: vm.selectReadingGoal,
            loadState: vm.goalsLoadState,
            onCreateReadingGoalTap: () async {
              final goalVm = context.read<CreateMeetingViewModel>();
              await context.push(Routes.createReadingGoal(clubId: goalVm.clubId));
              await goalVm.loadReadingGoals();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, CreateMeetingViewModel vm) {
    return PurpleRoundedButton("Criar", () async {
      if (_formKey.currentState?.validate() ?? false) {
        final success = await vm.createMeeting();
        if (context.mounted && success) context.pop();
      }
    });
  }
}
