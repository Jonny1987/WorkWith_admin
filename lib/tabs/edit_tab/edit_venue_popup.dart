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
  String _name = '';
  final _internetSpeedController = TextEditingController();
  final _americanoPriceController = TextEditingController();
  final _seatsWithSocketsController = TextEditingController();
  final _notesController = TextEditingController();
  int _notesId = -1;
  bool _enabled = true;

  var _loading = true;

  String asString(dynamic) {
    return dynamic != null ? dynamic.toString() : '';
  }

  Future<void> _getVenue() async {
    setState(() {
      _loading = true;
    });

    try {
      final data = await supabase
          .from('venues')
          .select<Map<String, dynamic>>('*, venue_notes(notes)')
          .eq('id', widget.venueId)
          .single();
      _name = data['name'];
      _internetSpeedController.text = asString(data['internet_speed']);
      _americanoPriceController.text = asString(data['americano_price']);
      _seatsWithSocketsController.text = asString(data['seats_with_sockets']);
      _enabled = data['enabled'];
      if (data['venue_notes'] != null) {
        _notesController.text = asString(data['venue_notes']['notes']);
        _notesId = data['venue_notes']['id'];
      }
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

  Future<void> _updateTable(Map<String, dynamic> updates, String table,
      Map<String, dynamic> match) async {
    setState(() {
      _loading = true;
    });
    updates['updated_at'] = DateTime.now().toIso8601String();
    print('updates: $updates');
    try {
      final res = await supabase.from(table).update(updates).match(match);
      print('res $table: $res');
      if (mounted) {
        SnackBar(
          content: Text('Successfully updated $table!'),
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

  Map<String, dynamic> _createUpdates(Map<String, dynamic> namesToValues) {
    final Map<String, dynamic> updates = {};
    namesToValues.forEach((name, value) {
      if (value == '') {
        value = null;
      }
      updates[name] = value;
    });
    return updates;
  }

  /// Called when user taps `Update` button
  Future<void> _updateVenue() async {
    final internetSpeed = _internetSpeedController.text.trim();
    final americanoPrice = _americanoPriceController.text.trim();
    final seatsWithSockets = _seatsWithSocketsController.text.trim();
    Map<String, dynamic> namesToValues = {
      'internet_speed': internetSpeed,
      'americano_price': americanoPrice,
      'seats_with_sockets': seatsWithSockets,
      'enabled': _enabled,
    };
    final Map<String, dynamic> updates = _createUpdates(namesToValues);
    if (updates.isEmpty) {
      return;
    }
    _updateTable(updates, 'venues', {'id': widget.venueId});
  }

  /// Called when user taps `Update` button
  Future<void> _upsertVenueNotes() async {
    String notes = _notesController.text.trim();
    if (notes == '') {
      return;
    }
    Map<String, dynamic> updates = {
      'venue_id': widget.venueId,
      'notes': notes,
    };
    await supabase.rpc('upsert_venue_notes', params: updates);
  }

  Future<void> _update() async {
    await _updateVenue();
    await _upsertVenueNotes();
  }

  void dispose() {
    _internetSpeedController.dispose();
    _americanoPriceController.dispose();
    _seatsWithSocketsController.dispose();
    _notesController.dispose();
    super.dispose();
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
                  Text(
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
                  onPressed: _loading ? null : _update,
                  child: Text(_loading ? 'Saving...' : 'Save'),
                ),
              ],
            ),
    );
  }
}
