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

-- limit_profile / limit_point 시드 없음.
-- 461 원문 조사 후 별도 마이그레이션으로 정확한 값 입력.

PRAGMA foreign_keys = ON;
