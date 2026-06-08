-- Migration 001: site, chamber + site_with_counts view
-- EMC Monitor - SQLite

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS site (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  name            TEXT NOT NULL UNIQUE,
  address         TEXT,
  accreditation   TEXT,
  contact_name    TEXT,
  contact_phone   TEXT,
  memo            TEXT,
  created_at      TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at      TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS chamber (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  site_id         INTEGER NOT NULL,
  name            TEXT NOT NULL,
  type            TEXT NOT NULL CHECK(type IN ('chamber','shield_room')),
  size_w_mm       INTEGER,
  size_d_mm       INTEGER,
  size_h_mm       INTEGER,
  freq_min_hz     INTEGER,
  freq_max_hz     INTEGER,
  status          TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active','maintenance','closed')),
  memo            TEXT,
  created_at      TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at      TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (site_id) REFERENCES site(id) ON DELETE RESTRICT,
  UNIQUE(site_id, name)
);

CREATE INDEX IF NOT EXISTS idx_chamber_site ON chamber(site_id);

CREATE VIEW IF NOT EXISTS site_with_counts AS
SELECT
  s.*,
  COALESCE(SUM(CASE WHEN c.type='chamber'     THEN 1 END), 0) AS chamber_count,
  COALESCE(SUM(CASE WHEN c.type='shield_room' THEN 1 END), 0) AS shield_room_count
FROM site s
LEFT JOIN chamber c ON c.site_id = s.id
GROUP BY s.id;
