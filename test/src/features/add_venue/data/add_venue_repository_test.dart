import 'package:flutter_test/flutter_test.dart';
import 'package:workwith_admin/src/features/add_venue/data/add_venue_repository.dart';

void main() {
  late AddVenueRepository addVenueRepository;

  setUp(() {
    addVenueRepository = AddVenueRepository();
  });

  group('getDataIdFromHtml', () {
    test('returns a valid dataId when only one is present', () {
      const String html =
          '<div>Some content with a dataId 0x1234abcd:0x5678efab</div>';
      expect(
          addVenueRepository.getDataIdFromHtml(html), '0x1234abcd:0x5678efab');
    });

    test('throws an exception when more than one dataId is found', () {
      const String html =
          '<div>Multiple dataIds 0x1234abcd:0x5678efab and 0x11112222:0x33334444</div>';
      expect(() => addVenueRepository.getDataIdFromHtml(html),
          throwsA(isA<Exception>()));
    });

    test('throws an exception when no dataId is found', () {
      const String html = '<div>No dataIds here!</div>';
      expect(() => addVenueRepository.getDataIdFromHtml(html),
          throwsA(isA<Exception>()));
    });
  });
}
