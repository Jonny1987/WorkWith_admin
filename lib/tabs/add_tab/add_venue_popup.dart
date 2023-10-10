import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workwith_admin/utils/constants.dart';

class AddVenuePopup extends StatefulWidget {
  final dynamic placeDetails;
  const AddVenuePopup({super.key, this.placeDetails});

  static Route<void> route(dynamic placeDetails) {
    return MaterialPageRoute(
        builder: (context) => AddVenuePopup(placeDetails: placeDetails));
  }

  @override
  AddVenuePopupState createState() => AddVenuePopupState();
}

class AddVenuePopupState extends State<AddVenuePopup> {
  final _venueNameController = TextEditingController();
  final _internetSpeedController = TextEditingController();
  final _americanoPriceController = TextEditingController();
  final _seatsWithSocketsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _enabled = true;

  var _loading = false;

  Future<int?> _insertVenue(Map<String, dynamic> inserts) async {
    setState(() {
      _loading = true;
    });
    print('inserts: $inserts');
    try {
      final int newVenueId =
          await supabase.rpc('insert_venue', params: inserts);
      print('newVenueId: $newVenueId');
      if (mounted) {
        const SnackBar(
          content: Text('Successfully added venue!'),
        );
      }
      return newVenueId;
    } on PostgrestException catch (error) {
      print(error.message);
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      print('Unexpected error occurred');
      SnackBar(
        content: const Text('Unexpected error occurred'),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _addVenue() async {
    final name = _venueNameController.text.trim();
    final internetSpeed = _internetSpeedController.text.trim();
    final americanoPrice = _americanoPriceController.text.trim();
    final seatsWithSockets = _seatsWithSocketsController.text.trim();
    final long = widget.placeDetails['location']['lng'];
    final lat = widget.placeDetails['location']['lat'];
    final notes = _notesController.text.trim();

    Map<String, dynamic> namesToValues = {
      'name': name,
      'internet_speed': internetSpeed,
      'americano_price': americanoPrice,
      'seats_with_sockets': seatsWithSockets,
      'enabled': _enabled,
      'longitude': long,
      'latitude': lat,
      'google_maps_place_id': widget.placeDetails['placeId'],
    };
    final Map<String, dynamic> inserts = {};
    namesToValues.forEach((name, value) {
      if (value != '' && value != null) {
        inserts[name] = value;
      }
    });
    if (inserts.isEmpty) {
      return;
    }
    final int? newVenueId = await _insertVenue(inserts);
    if (notes != '') {
      Map<String, dynamic> inserts = {
        'venue_id': newVenueId,
        'notes': notes,
      };
      print('inserting notes: $inserts');
      dynamic res = await supabase.rpc('upsert_venue_notes', params: inserts);
      print('res venue_notes: $res');
    }
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
    return Scaffold(
      appBar: const TransparentBackButtonAppBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                  onPressed: _loading ? null : _addVenue,
                  child: Text(_loading ? 'Saving...' : 'Save'),
                ),
              ],
            ),
    );
  }
}
