import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/add_venue/data/add_venue_repository.dart';

class AddVenuePopupController extends StateNotifier<AsyncValue<int?>> {
  final AddVenueRepository addVenueRepository;
  AddVenuePopupController({required this.addVenueRepository})
      : super(const AsyncValue.data(null));

  Future<void> addVenue(Map<String, dynamic> inserts, String notes) async {
    try {
      final int newVenueId = await addVenueRepository.insertVenue(inserts);
      if (notes.isNotEmpty) {
        await addVenueRepository.insertNotes(newVenueId, notes);
      }
      state = AsyncValue.data(newVenueId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final addVenuePopupControllerProvider =
    StateNotifierProvider<AddVenuePopupController, AsyncValue<int?>>((ref) {
  return AddVenuePopupController(
      addVenueRepository: ref.read(addVenueRepositoryProvider));
});
