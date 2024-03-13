import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/edit_venue/data/edit_venue_repository.dart';

class EditVenuePopupController extends StateNotifier<AsyncValue<int?>> {
  final EditVenueRepository editVenueRepository;
  EditVenuePopupController({required this.editVenueRepository})
      : super(const AsyncValue.data(null));

  Future<void> updateVenue(Map<String, dynamic> inserts, String notes) async {
    try {
      final int newVenueId = await editVenueRepository.updateVenue(inserts);
      if (notes.isNotEmpty) {
        await editVenueRepository.updateNotes(newVenueId, notes);
      }
      state = AsyncValue.data(newVenueId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final editVenuePopupControllerProvider =
    StateNotifierProvider<EditVenuePopupController, AsyncValue<int?>>((ref) {
  return EditVenuePopupController(
      editVenueRepository: ref.watch(editVenueRepositoryProvider));
});
