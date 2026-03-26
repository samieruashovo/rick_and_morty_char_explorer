import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_dimensions.dart';
import '../../../../core/responsive_extensions.dart';
import '../../domain/character_models.dart';
import '../controllers/character_providers.dart';

class EditCharacterScreen extends ConsumerStatefulWidget {
  const EditCharacterScreen({super.key, required this.character});

  final Character character;

  @override
  ConsumerState<EditCharacterScreen> createState() => _EditCharacterScreenState();
}

class _EditCharacterScreenState extends ConsumerState<EditCharacterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _statusController;
  late final TextEditingController _speciesController;
  late final TextEditingController _typeController;
  late final TextEditingController _genderController;
  late final TextEditingController _originController;
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.character.name);
    _statusController = TextEditingController(text: widget.character.status);
    _speciesController = TextEditingController(text: widget.character.species);
    _typeController = TextEditingController(text: widget.character.type);
    _genderController = TextEditingController(text: widget.character.gender);
    _originController = TextEditingController(text: widget.character.originName);
    _locationController =
        TextEditingController(text: widget.character.locationName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    _speciesController.dispose();
    _typeController.dispose();
    _genderController.dispose();
    _originController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String? _diff(String current, String original) {
    final trimmed = current.trim();
    if (trimmed == original) {
      return null;
    }
    return trimmed;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final override = CharacterOverride(
      name: _diff(_nameController.text, widget.character.name),
      status: _diff(_statusController.text, widget.character.status),
      species: _diff(_speciesController.text, widget.character.species),
      type: _diff(_typeController.text, widget.character.type),
      gender: _diff(_genderController.text, widget.character.gender),
      originName: _diff(_originController.text, widget.character.originName),
      locationName: _diff(_locationController.text, widget.character.locationName),
    );

    await ref
        .read(overridesControllerProvider.notifier)
        .saveOverride(widget.character.id, override);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Locally')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppDimensions.spaceXl.w),
          children: [
            _Field(controller: _nameController, label: 'Name'),
            _Field(controller: _statusController, label: 'Status'),
            _Field(controller: _speciesController, label: 'Species'),
            _Field(controller: _typeController, label: 'Type'),
            _Field(controller: _genderController, label: 'Gender'),
            _Field(controller: _originController, label: 'Origin name'),
            _Field(controller: _locationController, label: 'Location name'),
            SizedBox(height: AppDimensions.spaceXl.h),
            FilledButton(
              onPressed: _save,
              child: const Text('Save local changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.spaceSm.h),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
