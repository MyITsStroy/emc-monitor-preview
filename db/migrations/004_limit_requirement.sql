-- Migration 004: requirement + limit_profile + limit_point + chamber_capability FK 전환
-- EMC Monitor - SQLite

PRAGMA foreign_keys = OFF;

-- ============================================================
-- 1. requirement (요구사항 마스터)
-- ============================================================
CREATE TABLE IF NOT EXISTS requirement (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  code            TEXT NOT NULL UNIQUE,
  category        TEXT,
  name            TEXT,
  description     TEXT,
  created_at      TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at      TEXT NOT NULL DEFAULT (datetime('now'))
);

INSERT INTO requirement (code, category, name) VALUES
('Navy-Surface',   'Service',  '해군 함정'),
('Navy-Submarine', 'Service',  '해군 잠수함'),
('Navy-Aircraft',  'Service',  '해군 항공기'),
('Army-Ground',    'Service',  '육군 지상'),
('Army-Aircraft',  'Service',  '육군 항공기'),
('AirForce',       'Service',  '공군'),
('Marine-Ground',  'Service',  '해병 지상'),
('Space',          'Platform', '우주체'),
('AC-115V',        'Power',    '115V AC 전원'),
('DC-28V',         'Power',    '28V DC 전원');

-- ============================================================
-- 2. chamber_capability 재생성 (requirement TEXT → requirement_id FK)
-- ============================================================
DROP TABLE IF EXISTS chamber_capability;

CREATE TABLE chamber_capability (
  id                    INTEGER PRIMARY KEY AUTOINCREMENT,
  chamber_id            INTEGER NOT NULL,
  standard_test_item_id INTEGER NOT NULL,
  requirement_id        INTEGER,
  memo                  TEXT,
  created_at            TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (chamber_id) REFERENCES chamber(id) ON DELETE CASCADE,
  FOREIGN KEY (standard_test_item_id) REFERENCES standard_test_item(id) ON DELETE RESTRICT,
  FOREIGN KEY (requirement_id) REFERENCES requirement(id) ON DELETE RESTRICT,
  UNIQUE(chamber_id, standard_test_item_id, requirement_id)
);

CREATE INDEX idx_cap_chamber ON chamber_capability(chamber_id);

-- ============================================================
-- 3. limit_profile (한계 프로파일 헤더)
-- ============================================================
CREATE TABLE IF NOT EXISTS limit_profile (
  id                    INTEGER PRIMARY KEY AUTOINCREMENT,
  standard_test_item_id INTEGER NOT NULL,
  requirement_id        INTEGER,
  name                  TEXT NOT NULL,
  profile_type          TEXT NOT NULL DEFAULT 'curve' CHECK(profile_type IN ('curve','flat','impulse')),
  interpolation         TEXT DEFAULT 'lin-log',
  detector_override     TEXT,
  applicability         TEXT,
  memo                  TEXT,
  created_at            TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at            TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (standard_test_item_id) REFERENCES standard_test_item(id) ON DELETE RESTRICT,
  FOREIGN KEY (requirement_id) REFERENCES requirement(id) ON DELETE RESTRICT,
  UNIQUE(standard_test_item_id, requirement_id, name)
);

CREATE INDEX idx_lp_sti ON limit_profile(standard_test_item_id);
CREATE INDEX idx_lp_req ON limit_profile(requirement_id);

-- ============================================================
-- 4. limit_point (브레이크포인트)
-- ============================================================
CREATE TABLE IF NOT EXISTS limit_point (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  limit_profile_id INTEGER NOT NULL,
  frequency_hz     REAL,
  value            REAL NOT NULL,
  memo             TEXT,
  FOREIGN KEY (limit_profile_id) REFERENCES limit_profile(id) ON DELETE CASCADE,
  UNIQUE(limit_profile_id, frequency_hz)
);

CREATE INDEX idx_pt_profile ON limit_point(limit_profile_id, frequency_hz);

-- ============================================================
-- 5. limit_profile 샘플 시드 (3건: curve / flat / impulse)
-- ============================================================

-- CE102 curve (461G, 28V DC, Avg)
INSERT INTO limit_profile (standard_test_item_id, requirement_id, name, profile_type, interpolation, detector_override)
SELECT
  sti.id,
  (SELECT id FROM requirement WHERE code='DC-28V'),
  'CE102 28VDC Avg', 'curve', 'lin-log', 'Avg'
FROM standard_test_item sti
JOIN standard s ON s.id=sti.standard_id
JOIN test_item t ON t.id=sti.test_item_id
WHERE s.code='MIL-STD-461G' AND t.code='CE102';

INSERT INTO limit_point (limit_profile_id, frequency_hz, value)
SELECT lp.id, x.freq, x.val
FROM limit_profile lp
CROSS JOIN (
  SELECT 10000.0    AS freq, 94.0 AS val UNION ALL
  SELECT 150000.0,            80.0       UNION ALL
  SELECT 500000.0,            60.0       UNION ALL
  SELECT 10000000.0,          60.0
) x
WHERE lp.name='CE102 28VDC Avg';

-- RS103 flat (461G, Navy-Surface, 200 V/m)
INSERT INTO limit_profile (standard_test_item_id, requirement_id, name, profile_type)
SELECT
  sti.id,
  (SELECT id FROM requirement WHERE code='Navy-Surface'),
  'RS103 Navy-Surface 200V/m', 'flat'
FROM standard_test_item sti
JOIN standard s ON s.id=sti.standard_id
JOIN test_item t ON t.id=sti.test_item_id
WHERE s.code='MIL-STD-461G' AND t.code='RS103';

INSERT INTO limit_point (limit_profile_id, frequency_hz, value)
SELECT lp.id, x.freq, x.val
FROM limit_profile lp
CROSS JOIN (
  SELECT 2000000.0     AS freq, 200.0 AS val UNION ALL
  SELECT 40000000000.0,         200.0
) x
WHERE lp.name='RS103 Navy-Surface 200V/m';

-- CS115 impulse (461G, requirement 없음)
INSERT INTO limit_profile (standard_test_item_id, requirement_id, name, profile_type)
SELECT
  sti.id, NULL, 'CS115 Standard Impulse', 'impulse'
FROM standard_test_item sti
JOIN standard s ON s.id=sti.standard_id
JOIN test_item t ON t.id=sti.test_item_id
WHERE s.code='MIL-STD-461G' AND t.code='CS115';

INSERT INTO limit_point (limit_profile_id, frequency_hz, value, memo)
SELECT lp.id, NULL, 5.0, 'Peak amplitude'
FROM limit_profile lp
WHERE lp.name='CS115 Standard Impulse';

PRAGMA foreign_keys = ON;
