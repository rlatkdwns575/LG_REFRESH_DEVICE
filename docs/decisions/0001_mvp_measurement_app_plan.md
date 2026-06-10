# 0001. MVP measurement app plan

## Context

The first MVP validates the camera recognition model, app integration, and Supabase data transfer. The hair thickness and damage model will be trained separately. Until that model is ready, the app uses a dummy analyzer that returns random values for the remaining metrics.

## MVP scope

- Capture or select a hair photo.
- Run a replaceable image analysis service.
- Save the full measurement payload to Supabase.
- Show the latest measurement result in the app.
- Keep refresh, history, and settings screens as navigable MVP placeholders.

## Data payload

Initial table: `hair_measurements`

- `id`
- `created_at`
- `image_path`
- `contamination_score`: 1-10
- `contamination_level`: 1-5
  - 1: total score 2 or lower
  - 2: total score 3-4
  - 3: total score 5-6
  - 4: total score 7-8
  - 5: total score 9-10
- `hair_thickness_level`: 1-3
- `damage_level`: 1-3
- `dust_residue_level`: 1-4
- `dust_distribution_level`: 1-4
- `odor_residue_level`: 1-4
- `odor_types`: selected combination of `땀`, `음식`, `담배`, `화장품`, `기타`
- `oil_level`: 1-4

## App structure

- `features/measure/data/api/hair_analysis_service.dart`
  - Current dummy analyzer.
  - Later replacement point for the trained camera model.
- `features/measure/data/api/hair_measurement_api.dart`
  - Supabase insert boundary.
- `features/measure/data/model/hair_measurement.dart`
  - Manual Dart model, no generated code.
- `features/measure/ui/page/measure_page.dart`
  - MVP capture/analyze/save flow.

## Next steps

1. Add Supabase initialization using anon key from environment or platform config.
2. Add real camera capture with the `camera` package.
3. Add image upload storage if server-side review of original photos is needed.
4. Replace dummy analyzer with model inference adapter.
5. Add history query and latest result dashboard.
