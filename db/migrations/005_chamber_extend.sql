-- Migration 005: chamber 컬럼 확장
-- measurement_distance_m / turntable_diameter_mm / installation_date / accreditation_scope

ALTER TABLE chamber ADD COLUMN measurement_distance_m REAL;
ALTER TABLE chamber ADD COLUMN turntable_diameter_mm  INTEGER;
ALTER TABLE chamber ADD COLUMN installation_date      TEXT;
ALTER TABLE chamber ADD COLUMN accreditation_scope    TEXT;
