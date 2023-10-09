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

  var _loading = false;

  Future<void> _addVenue() async {
    final name = _venueNameController.text.trim();
    final internetSpeed = _internetSpeedController.text.trim();
    final americanoPrice = _americanoPriceController.text.trim();
    final seatsWithSockets = _seatsWithSocketsController.text.trim();
    final long = widget.placeDetails['location']['lng'];
    final lat = widget.placeDetails['location']['lat'];
    print('type of long: ${long.runtimeType}');

    Map<String, dynamic> namesToValues = {
      'name': name,
      'internet_speed': internetSpeed,
      'americano_price': americanoPrice,
      'seats_with_sockets': seatsWithSockets,
      'longitude': long,
      'latitude': lat,
    };
    final Map<String, dynamic> inserts = {};
    namesToValues.forEach((name, value) {
      if (value != '') {
        inserts[name] = value;
      }
    });
    if (inserts.isEmpty) {
      return;
    }
    setState(() {
      _loading = true;
    });
    print('inserts: $inserts');
    try {
      final res = await supabase.rpc('insert_venue', params: inserts);
      print('res: $res');
      if (mounted) {
        const SnackBar(
          content: Text('Successfully added venue!'),
        );
      }
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

  @override
  initState() {
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
                ElevatedButton(
                  onPressed: _loading ? null : _addVenue,
                  child: Text(_loading ? 'Saving...' : 'Save'),
                ),
              ],
            ),
    );
  }
}
