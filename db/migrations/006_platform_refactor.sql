-- Migration 006: requirement → platform 리팩토링
-- chamber_capability에서 requirement_id 제거,
-- limit_profile에 platform_id + power_config + severity_class 도입,
-- requirement 테이블 제거.

PRAGMA foreign_keys = OFF;

-- ============================================================
-- 1. platform 마스터 (MIL-STD-461G Table IA/IB 컬럼 기반)
-- ============================================================
CREATE TABLE IF NOT EXISTS platform (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  code         TEXT NOT NULL UNIQUE,
  name         TEXT,
  service      TEXT,    -- Army / Navy / Air Force / Marines / Joint
  domain       TEXT,    -- Surface / Sub-surface / Air / Ground / Space
  description  TEXT,
  created_at   TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at   TEXT NOT NULL DEFAULT (datetime('now'))
);

INSERT INTO platform (code, name, service, domain) VALUES
('Surface-Ships',     '해상 함정',                 'Navy',      'Surface'),
('Submarines',        '잠수함',                    'Navy',      'Sub-surface'),
('Aircraft-Army',     '육군 항공기 (Flight Line)', 'Army',      'Air'),
('Aircraft-Navy',     '해군 항공기',               'Navy',      'Air'),
('Aircraft-AirForce', '공군 항공기',               'Air Force', 'Air'),
('Space-Systems',     '우주체 (발사체 포함)',      'Joint',     'Space'),
('Ground-Army',       '육군 지상',                 'Army',      'Ground'),
('Ground-Navy',       '해군 지상',                 'Navy',      'Ground'),
('Ground-Marines',    '해병 지상',                 'Marines',   'Ground'),
('Ground-AirForce',   '공군 지상',                 'Air Force', 'Ground');

-- ============================================================
-- 2. chamber_capability 재구축 — requirement_id 제거
-- ============================================================
DROP TABLE IF EXISTS chamber_capability;

CREATE TABLE chamber_capability (
  id                    INTEGER PRIMARY KEY AUTOINCREMENT,
  chamber_id            INTEGER NOT NULL,
  standard_test_item_id INTEGER NOT NULL,
  memo                  TEXT,
  created_at            TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (chamber_id) REFERENCES chamber(id) ON DELETE CASCADE,
  FOREIGN KEY (standard_test_item_id) REFERENCES standard_test_item(id) ON DELETE RESTRICT,
  UNIQUE(chamber_id, standard_test_item_id)
);
CREATE INDEX idx_cap_chamber ON chamber_capability(chamber_id);

-- ============================================================
-- 3. limit_profile 재구축 — platform_id + power_config + severity_class
-- ============================================================
DROP TABLE IF EXISTS limit_point;
DROP TABLE IF EXISTS limit_profile;

CREATE TABLE limit_profile (
  id                    INTEGER PRIMARY KEY AUTOINCREMENT,
  standard_test_item_id INTEGER NOT NULL,
  platform_id           INTEGER,                 -- NULL = 전 플랫폼 공통
  power_config          TEXT,                    -- '28VDC Avg', '115VAC Peak' 등
  severity_class        TEXT,                    -- 'Category L1' (CS117) 등
  name                  TEXT NOT NULL,
  profile_type          TEXT NOT NULL DEFAULT 'curve' CHECK(profile_type IN ('curve','flat','impulse')),
  interpolation         TEXT DEFAULT 'lin-log',
  detector_override     TEXT,
  memo                  TEXT,
  created_at            TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at            TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (standard_test_item_id) REFERENCES standard_test_item(id) ON DELETE RESTRICT,
  FOREIGN KEY (platform_id) REFERENCES platform(id) ON DELETE RESTRICT,
  UNIQUE(standard_test_item_id, platform_id, power_config, severity_class, name)
);
CREATE INDEX idx_lp_sti  ON limit_profile(standard_test_item_id);
CREATE INDEX idx_lp_plat ON limit_profile(platform_id);

CREATE TABLE limit_point (
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
-- 4. requirement 테이블 제거
-- ============================================================
DROP TABLE IF EXISTS requirement;

PRAGMA foreign_keys = ON;
