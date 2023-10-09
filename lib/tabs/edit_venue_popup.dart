import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workwith_admin/utils/constants.dart';

class EditVenuePopup extends StatefulWidget {
  final int venueId;
  const EditVenuePopup({super.key, required this.venueId});

  static Route<void> route(int venueId) {
    return MaterialPageRoute(
        builder: (context) => EditVenuePopup(venueId: venueId));
  }

  @override
  EditVenuePopupState createState() => EditVenuePopupState();
}

class EditVenuePopupState extends State<EditVenuePopup> {
  late String _name;
  final _internetSpeedController = TextEditingController();
  final _americanoPriceController = TextEditingController();
  final _seatsWithSocketsController = TextEditingController();

  var _loading = true;

  Future<void> _getVenue() async {
    setState(() {
      _loading = true;
    });

    try {
      final data = await supabase
          .from('venues')
          .select<Map<String, dynamic>>()
          .eq('id', widget.venueId)
          .single();
      _name = (data['name'] ?? '') as String;
      _internetSpeedController.text = (data['internet_speed'] ?? '') as String;
      _americanoPriceController.text =
          (data['americano_price'] ?? '') as String;
      _seatsWithSocketsController.text =
          (data['seats_with_sockets'] ?? '') as String;
    } on PostgrestException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
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

  /// Called when user taps `Update` button
  Future<void> _updateVenue() async {
    final internetSpeed = _internetSpeedController.text.trim();
    final americanoPrice = _americanoPriceController.text.trim();
    final seatsWithSockets = _seatsWithSocketsController.text.trim();
    Map<String, String?> namesToValues = {
      'internet_speed': internetSpeed,
      'americano_price': americanoPrice,
      'seats_with_sockets': seatsWithSockets,
    };
    final updates = {};
    namesToValues.forEach((name, value) {
      if (value == '') {
        value = null;
      }
      updates[name] = value;
    });
    if (updates.isEmpty) {
      return;
    }
    setState(() {
      _loading = true;
    });
    updates['updated_at'] = DateTime.now().toIso8601String();
    print('updates: $updates');
    try {
      final res = await supabase
          .from('venues')
          .update(updates)
          .match({'id': widget.venueId});
      print('res: $res');
      if (mounted) {
        const SnackBar(
          content: Text('Successfully updated venue!'),
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
    _getVenue();
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
                Text(_name, style: const TextStyle(fontSize: 30)),
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
                  onPressed: _loading ? null : _updateVenue,
                  child: Text(_loading ? 'Saving...' : 'Save'),
                ),
              ],
            ),
    );
  }
}
