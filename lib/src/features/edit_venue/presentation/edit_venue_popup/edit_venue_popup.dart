import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_model.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/edit_venue_popup/edit_venue_popup_controller.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/edit_venue_popup/image_scroller.dart';
import 'package:workwith_admin/utils/async_value_ui.dart';
import 'package:workwith_admin/utils/constants.dart';

class EditVenuePopup extends ConsumerStatefulWidget {
  final Venue venue;
  const EditVenuePopup({super.key, required this.venue});

  @override
  ConsumerState<EditVenuePopup> createState() => EditVenuePopupState();
}

class EditVenuePopupState extends ConsumerState<EditVenuePopup> {
  final _venueNameController = TextEditingController();
  final _internetSpeedController = TextEditingController();
  final _americanoPriceController = TextEditingController();
  final _seatsWithSocketsController = TextEditingController();
  final _notesController = TextEditingController();

  String get _name => _venueNameController.text.trim();
  String get internetSpeed => _internetSpeedController.text.trim();
  String get americanoPrice => _americanoPriceController.text.trim();
  String get seatsWithSockets => _seatsWithSocketsController.text.trim();
  String get notes => _notesController.text.trim();
  bool _enabled = true;

  void setFormFields() {
    _venueNameController.text = widget.venue.name;
    _internetSpeedController.text =
        widget.venue.internetSpeed?.toString() ?? '';
    _americanoPriceController.text =
        widget.venue.americanoPrice?.toString() ?? '';
    _seatsWithSocketsController.text =
        widget.venue.seatsWithSockets?.toString() ?? '';
    _enabled = widget.venue.enabled;
    _notesController.text = widget.venue.notes ?? '';
  }

  Future<void> _updateVenue() async {
    Map<String, dynamic> fields = {
      'name': _name,
      'internet_speed': internetSpeed == '' ? null : int.parse(internetSpeed),
      'americano_price':
          americanoPrice == '' ? null : double.parse(americanoPrice),
      'seats_with_sockets':
          seatsWithSockets == '' ? null : int.parse(seatsWithSockets),
      'enabled': _enabled,
      'id': widget.venue.id,
    };
    final editedVenuePhotos = ref
        .watch(editVenuePopupControllerProvider(widget.venue)
            .select((value) => value.editedVenuePhotosStatus))
        .value;

    ref
        .read(editVenuePopupControllerProvider(widget.venue).notifier)
        .updateVenue(fields, notes, editedVenuePhotos);
  }

  @override
  void dispose() {
    _venueNameController.dispose();
    _internetSpeedController.dispose();
    _americanoPriceController.dispose();
    _seatsWithSocketsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setFormFields();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .watch(editVenuePopupControllerProvider(widget.venue).notifier)
          .createEditedVenuePhoto(widget.venue.venuePhotos ?? []);
      ref
          .watch(editVenuePopupControllerProvider(widget.venue).notifier)
          .getVenueImageProviders(context);
    });
  }

  void _markUpdatedAndClose() {
    if (mounted) {
      context.showSuccessMessage(context, 'Venue updated successfully');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
        editVenuePopupControllerProvider(widget.venue)
            .select((value) => value.updateVenueStatus), (_, state) {
      state.showTopSnackbarOnError(context);
      state.whenData((data) {
        if (data != null) {
          _markUpdatedAndClose();
        }
      });
    });

    var updateVenueState = ref.watch(
        editVenuePopupControllerProvider(widget.venue)
            .select((value) => value.updateVenueStatus));

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ImageScroller(
            venue: widget.venue,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _venueNameController,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          const SizedBox(height: 60),
          TextFormField(
            controller: _internetSpeedController,
            decoration: const InputDecoration(
              labelText: 'Internet Speed',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _americanoPriceController,
            decoration: const InputDecoration(
              labelText: 'Americano Price',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _seatsWithSocketsController,
            decoration: const InputDecoration(
              labelText: 'Seats with Sockets',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            textCapitalization: TextCapitalization.sentences,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            const Text(
              'Enabled:',
              style: TextStyle(fontSize: 18),
            ),
            Switch(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: _enabled,
                onChanged: (value) {
                  setState(() => _enabled = value);
                }),
          ]),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: updateVenueState.isLoading ? null : _updateVenue,
            child: Text(updateVenueState.isLoading ? 'Saving...' : 'Save'),
          ),
        ],
      ),
    );
  }
}
