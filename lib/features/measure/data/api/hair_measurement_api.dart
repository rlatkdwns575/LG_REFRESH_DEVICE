import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../model/hair_measurement.dart';

class HairMeasurementApi {
  const HairMeasurementApi();

  Future<bool> trySaveMeasurement(HairMeasurement measurement) async {
    try {
      await SupabaseService.client
          .from(SupabaseTables.hairMeasurements)
          .insert(measurement.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }
}
