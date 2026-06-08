-- Migration 002: standard, test_item, standard_test_item, chamber_capability
-- EMC Monitor - SQLite

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS standard (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  code            TEXT NOT NULL UNIQUE,
  name            TEXT,
  version         TEXT,
  issued_year     INTEGER,
  issuing_body    TEXT,
  domain          TEXT CHECK(domain IN ('military','aviation','automotive','industrial','medical','commercial')),
  status          TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active','superseded','draft')),
  description     TEXT,
  created_at      TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at      TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS test_item (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  code            TEXT NOT NULL UNIQUE,
  category        TEXT NOT NULL CHECK(category IN ('CE','CS','RE','RS')),
  nature          TEXT NOT NULL CHECK(nature IN ('emission','susceptibility')),
  target          TEXT,
  limit_unit      TEXT,
  detector        TEXT,
  freq_min_hz     INTEGER,
  freq_max_hz     INTEGER,
  name            TEXT,
  description     TEXT,
  created_at      TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at      TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS standard_test_item (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  standard_id     INTEGER NOT NULL,
  test_item_id    INTEGER NOT NULL,
  freq_min_hz     INTEGER,
  freq_max_hz     INTEGER,
  test_distance_m REAL,
  limit_curve_ref TEXT,
  section_ref     TEXT,
  description     TEXT,
  created_at      TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at      TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (standard_id) REFERENCES standard(id) ON DELETE RESTRICT,
  FOREIGN KEY (test_item_id) REFERENCES test_item(id) ON DELETE RESTRICT,
  UNIQUE(standard_id, test_item_id)
);

CREATE INDEX IF NOT EXISTS idx_sti_standard ON standard_test_item(standard_id);
CREATE INDEX IF NOT EXISTS idx_sti_item     ON standard_test_item(test_item_id);

CREATE TABLE IF NOT EXISTS chamber_capability (
  id                    INTEGER PRIMARY KEY AUTOINCREMENT,
  chamber_id            INTEGER NOT NULL,
  standard_test_item_id INTEGER NOT NULL,
  requirement           TEXT,
  memo                  TEXT,
  created_at            TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (chamber_id) REFERENCES chamber(id) ON DELETE CASCADE,
  FOREIGN KEY (standard_test_item_id) REFERENCES standard_test_item(id) ON DELETE RESTRICT,
  UNIQUE(chamber_id, standard_test_item_id, requirement)
);

CREATE INDEX IF NOT EXISTS idx_cap_chamber ON chamber_capability(chamber_id);
