import 'package:booklub/config/routing/routes.dart';
import 'package:booklub/ui/core/widgets/buttons/purple_rounded_button.dart';
import 'package:booklub/ui/core/widgets/input_fields/image_field_widget.dart';
import 'package:booklub/ui/user/edit/widgets/editable_date_field.dart';
import 'package:booklub/ui/user/edit/widgets/editable_field.dart';
import 'package:booklub/ui/user/view_models/edit_user_profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  late final EditUserProfileViewModel editUserProfileViewModel;

  EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    editUserProfileViewModel = context.read<EditUserProfileViewModel>();

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverFillRemaining(
        hasScrollBody: false,
        child: Builder(
          builder: (context) {
            final errorMessage =
                context.watch<EditUserProfileViewModel>().errorMessage;

            return Column(
              spacing: 24,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Builder(builder: _buildForm),
                if (errorMessage != null)
                  _buildErrorBanner(context, errorMessage),
                Builder(builder: _buildButtons),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.40)),
      ),
      child: Row(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: colorScheme.error),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        PurpleRoundedButton("Atualizar", () => _onSubmit(context)),
      ],
    );
  }

  void _onSubmit(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      final succeeded = await editUserProfileViewModel.update();
      if (context.mounted && succeeded) context.go(Routes.home);
    }
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProfilePictureField(context),
          const SizedBox(height: 24),
          _buildFirstNameField(context),
          const SizedBox(height: 24),
          _buildLastNameField(context),
          const SizedBox(height: 24),
          _buildBirthDateField(context),
        ],
      ),
    );
  }

  Widget _buildProfilePictureField(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return ValueListenableBuilder(
      valueListenable: editUserProfileViewModel.profilePicture,
      builder: (context, value, child) {
        final image =
            (value != null
                ? DecorationImage(image: MemoryImage(value.bytes), fit: BoxFit.cover)
                : null);

        return ImageFieldWidget(
          constraints: const BoxConstraints(maxHeight: 172, maxWidth: 172),
          height: screenWidth * 0.4,
          width: screenWidth * 0.4,
          shape: BoxShape.circle,
          imagePicker: () => editUserProfileViewModel.pickProfilePicture(),
          image: image,
        );
      },
    );
  }

  Widget _buildFirstNameField(BuildContext context) {
    return EditableField(
      label: "Nome",
      controller: editUserProfileViewModel.firstNameInput,
    );
  }

  Widget _buildLastNameField(BuildContext context) {
    return EditableField(
      label: "Sobrenome",
      controller: editUserProfileViewModel.lastNameInput,
    );

  }
  Widget _buildBirthDateField(BuildContext context) {
    return EditableDateField(
      label: 'Nascimento',
      controller: editUserProfileViewModel.birthDateInput,
    );
  }
}