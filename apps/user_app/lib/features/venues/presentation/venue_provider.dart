import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fieldup_core/fieldup_core.dart';
import '../../../features/auth/presentation/auth_provider.dart';

part 'venue_provider.g.dart';

@riverpod
Future<List<Venue>> venuesList(Ref ref, {String? sport, String? city}) =>
    ref.watch(venueRepositoryProvider).fetchVenues(sport: sport, city: city);

@riverpod
Future<Venue?> venueDetail(Ref ref, String venueId) =>
    ref.watch(venueRepositoryProvider).fetchVenue(venueId);

@riverpod
Future<List<Court>> venueCourts(Ref ref, String venueId) =>
    ref.watch(venueRepositoryProvider).fetchCourts(venueId);

@riverpod
Future<List<Slot>> availableSlots(
  Ref ref, {
  required String courtId,
  required String date,
}) =>
    ref.watch(venueRepositoryProvider).fetchAvailableSlots(
          courtId: courtId,
          date: date,
        );
