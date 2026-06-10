# 0002. Hair measurements Supabase shape

## Purpose

This is the draft payload shape for scan data transfer from the Flutter demo app to Supabase. The demo assumes one fixed BLE device ID exposed by the device firmware as a readable characteristic.

## Demo device ID

```text
LG_HAIR_REFRESHER_DEMO_001
```

## Draft table

```sql
create table public.hair_measurements (
  id text primary key,
  device_id text not null,
  created_at timestamptz not null,
  image_path text not null,
  contamination_score int not null check (contamination_score between 1 and 10),
  contamination_level int not null check (contamination_level between 1 and 5),
  hair_thickness_level int not null check (hair_thickness_level between 1 and 3),
  damage_level int not null check (damage_level between 1 and 3),
  dust_residue_level int not null check (dust_residue_level between 1 and 4),
  dust_distribution_level int not null check (dust_distribution_level between 1 and 4),
  odor_residue_level int not null check (odor_residue_level between 1 and 4),
  odor_types jsonb not null,
  oil_level int not null check (oil_level between 1 and 4)
);

create index hair_measurements_device_id_created_at_idx
  on public.hair_measurements (device_id, created_at desc);
```

## Contamination score

The app calculates the contamination score from scan output values:

- Dust residue level: 35%
- Dust distribution level: 25%
- Odor residue level: 25%
- Oil level: 15%

Each input is normalized from its native 1-4 range and converted to a 1-10 contamination score.

## Contamination level

- `1`: total score 2 or lower
- `2`: total score 3-4
- `3`: total score 5-6
- `4`: total score 7-8
- `5`: total score 9-10

## Odor type values

Allowed app values:

- `먼지`
- `연기`
- `음식`
- `화장품`
- `기타`
