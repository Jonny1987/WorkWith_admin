import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/add_venue/presentation/add_venue_popup/add_venue_popup_controller.dart';
import 'package:workwith_admin/utils/async_value_ui.dart';
import 'package:workwith_admin/utils/constants.dart';

class AddVenuePopup extends ConsumerStatefulWidget {
  final dynamic placeDetails;
  const AddVenuePopup({super.key, this.placeDetails});

  @override
  ConsumerState<AddVenuePopup> createState() => AddVenuePopupState();
}

class AddVenuePopupState extends ConsumerState<AddVenuePopup> {
  final _venueNameController = TextEditingController();
  final _internetSpeedController = TextEditingController();
  final _americanoPriceController = TextEditingController();
  final _seatsWithSocketsController = TextEditingController();
  final _notesController = TextEditingController();

  String get name => _venueNameController.text.trim();
  String get internetSpeed => _internetSpeedController.text.trim();
  String get americanoPrice => _americanoPriceController.text.trim();
  String get seatsWithSockets => _seatsWithSocketsController.text.trim();
  double get long => widget.placeDetails['location']['lng'];
  double get lat => widget.placeDetails['location']['lat'];
  String get notes => _notesController.text.trim();

  bool _enabled = true;

  Future<void> _addVenue() async {
    Map<String, dynamic> fields = {
      'name': name,
      'internet_speed': internetSpeed == '' ? null : int.parse(internetSpeed),
      'americano_price':
          americanoPrice == '' ? null : double.parse(americanoPrice),
      'seats_with_sockets':
          seatsWithSockets == '' ? null : int.parse(seatsWithSockets),
      'enabled': _enabled,
      'longitude': long,
      'latitude': lat,
      'google_maps_place_id': widget.placeDetails['placeId'],
    };
    await ref
        .read(addVenuePopupControllerProvider.notifier)
        .addVenue(fields, notes);
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
    _venueNameController.text = widget.placeDetails['name'];
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(addVenuePopupControllerProvider, (_, state) {
      state.showTopSnackbarOnError(context);
      state.whenData((data) {
        if (data != null) {
          Navigator.of(context).pop();
          context.showSuccessMessage(context, 'Venue added successfully');
        }
      });
    });
    var state = ref.watch(addVenuePopupControllerProvider);

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          TextFormField(
            controller: _venueNameController,
            decoration: const InputDecoration(
              labelText: 'Venue Name',
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
            onPressed: state.isLoading ? null : _addVenue,
            child: Text(state.isLoading ? 'Saving...' : 'Save'),
          ),
        ],
      ),
    );
  }
}
