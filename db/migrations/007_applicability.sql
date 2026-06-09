-- Migration 007: applicability 매트릭스 (MIL-STD-461G Table IA/IB)
-- 19 시험항목 × 10 플랫폼 = 190행
-- 마커: A=Applicable, L=Limited, S=Specified, -=Not Applicable
-- 참고: 461G 원문 Table IA/IB 기준. 정확성은 사용자가 규격 원문과 대조 검증 권장.

PRAGMA foreign_keys = ON;

-- ============================================================
-- 테이블 생성
-- ============================================================
CREATE TABLE IF NOT EXISTS applicability (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  standard_id  INTEGER NOT NULL,
  test_item_id INTEGER NOT NULL,
  platform_id  INTEGER NOT NULL,
  marker       TEXT NOT NULL CHECK(marker IN ('A','L','S','-')),
  notes        TEXT,
  created_at   TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at   TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (standard_id)  REFERENCES standard(id)   ON DELETE CASCADE,
  FOREIGN KEY (test_item_id) REFERENCES test_item(id)  ON DELETE CASCADE,
  FOREIGN KEY (platform_id)  REFERENCES platform(id)   ON DELETE CASCADE,
  UNIQUE(standard_id, test_item_id, platform_id)
);

CREATE INDEX idx_app_std  ON applicability(standard_id);
CREATE INDEX idx_app_item ON applicability(test_item_id);
CREATE INDEX idx_app_plat ON applicability(platform_id);

-- ============================================================
-- 시드: 461G Table IA/IB
-- ============================================================

-- ── 그룹 1: 전 플랫폼 A (필수) ─ 7개 시험항목 × 10 = 70행
INSERT INTO applicability (standard_id, test_item_id, platform_id, marker)
SELECT
  (SELECT id FROM standard WHERE code='MIL-STD-461G'),
  t.id, p.id, 'A'
FROM test_item t, platform p
WHERE t.code IN ('CE102','CS101','CS114','CS116','CS118','RE102','RS103');

-- ── 그룹 2: 전 플랫폼 L (송수신기 한정) ─ 2 × 10 = 20행
INSERT INTO applicability (standard_id, test_item_id, platform_id, marker)
SELECT
  (SELECT id FROM standard WHERE code='MIL-STD-461G'),
  t.id, p.id, 'L'
FROM test_item t, platform p
WHERE t.code IN ('CE106','RE103');

-- ── 그룹 3: 전 플랫폼 S (구매 활동 명시) ─ 3 × 10 = 30행
INSERT INTO applicability (standard_id, test_item_id, platform_id, marker)
SELECT
  (SELECT id FROM standard WHERE code='MIL-STD-461G'),
  t.id, p.id, 'S'
FROM test_item t, platform p
WHERE t.code IN ('CS103','CS104','CS105');

-- ── 그룹 4: 플랫폼별 개별 정의 ─ 7개 × 10 = 70행
-- 컬럼 순서: Surface, Submarines, Aircraft-Army, Aircraft-Navy, Aircraft-AirForce,
--           Space, Ground-Army, Ground-Navy, Ground-Marines, Ground-AirForce
INSERT INTO applicability (standard_id, test_item_id, platform_id, marker)
SELECT
  (SELECT id FROM standard  WHERE code='MIL-STD-461G'),
  (SELECT id FROM test_item WHERE code=m.test_code),
  (SELECT id FROM platform  WHERE code=m.platform_code),
  m.marker
FROM (
  -- CE101: 전원 저주파 (해상/잠수함/항공기 A · 나머지 L)
  SELECT 'CE101' AS test_code, 'Surface-Ships'     AS platform_code, 'A' AS marker UNION ALL
  SELECT 'CE101','Submarines',       'A' UNION ALL
  SELECT 'CE101','Aircraft-Army',    'A' UNION ALL
  SELECT 'CE101','Aircraft-Navy',    'A' UNION ALL
  SELECT 'CE101','Aircraft-AirForce','L' UNION ALL
  SELECT 'CE101','Space-Systems',    'L' UNION ALL
  SELECT 'CE101','Ground-Army',      'L' UNION ALL
  SELECT 'CE101','Ground-Navy',      'L' UNION ALL
  SELECT 'CE101','Ground-Marines',   'L' UNION ALL
  SELECT 'CE101','Ground-AirForce',  'L' UNION ALL

  -- CS109: 구조체 전류 (해상/잠수함/육군-해군 L · 나머지 -)
  SELECT 'CS109','Surface-Ships',    'L' UNION ALL
  SELECT 'CS109','Submarines',       'L' UNION ALL
  SELECT 'CS109','Aircraft-Army',    '-' UNION ALL
  SELECT 'CS109','Aircraft-Navy',    '-' UNION ALL
  SELECT 'CS109','Aircraft-AirForce','-' UNION ALL
  SELECT 'CS109','Space-Systems',    '-' UNION ALL
  SELECT 'CS109','Ground-Army',      '-' UNION ALL
  SELECT 'CS109','Ground-Navy',      'L' UNION ALL
  SELECT 'CS109','Ground-Marines',   '-' UNION ALL
  SELECT 'CS109','Ground-AirForce',  '-' UNION ALL

  -- CS115: BCI 임펄스 (해상/잠수함/해군-지상 - · 나머지 A)
  SELECT 'CS115','Surface-Ships',    '-' UNION ALL
  SELECT 'CS115','Submarines',       '-' UNION ALL
  SELECT 'CS115','Aircraft-Army',    'A' UNION ALL
  SELECT 'CS115','Aircraft-Navy',    'A' UNION ALL
  SELECT 'CS115','Aircraft-AirForce','A' UNION ALL
  SELECT 'CS115','Space-Systems',    'A' UNION ALL
  SELECT 'CS115','Ground-Army',      'A' UNION ALL
  SELECT 'CS115','Ground-Navy',      '-' UNION ALL
  SELECT 'CS115','Ground-Marines',   'A' UNION ALL
  SELECT 'CS115','Ground-AirForce',  'A' UNION ALL

  -- CS117: 낙뢰 유도 (해상/잠수함 - · 항공기/우주 A · 지상 L)
  SELECT 'CS117','Surface-Ships',    '-' UNION ALL
  SELECT 'CS117','Submarines',       '-' UNION ALL
  SELECT 'CS117','Aircraft-Army',    'A' UNION ALL
  SELECT 'CS117','Aircraft-Navy',    'A' UNION ALL
  SELECT 'CS117','Aircraft-AirForce','A' UNION ALL
  SELECT 'CS117','Space-Systems',    'A' UNION ALL
  SELECT 'CS117','Ground-Army',      'L' UNION ALL
  SELECT 'CS117','Ground-Navy',      'L' UNION ALL
  SELECT 'CS117','Ground-Marines',   'L' UNION ALL
  SELECT 'CS117','Ground-AirForce',  'L' UNION ALL

  -- RE101: 자계 방출 (해군계 A · 우주 - · 나머지 L)
  SELECT 'RE101','Surface-Ships',    'A' UNION ALL
  SELECT 'RE101','Submarines',       'A' UNION ALL
  SELECT 'RE101','Aircraft-Army',    'L' UNION ALL
  SELECT 'RE101','Aircraft-Navy',    'A' UNION ALL
  SELECT 'RE101','Aircraft-AirForce','L' UNION ALL
  SELECT 'RE101','Space-Systems',    '-' UNION ALL
  SELECT 'RE101','Ground-Army',      'L' UNION ALL
  SELECT 'RE101','Ground-Navy',      'A' UNION ALL
  SELECT 'RE101','Ground-Marines',   'L' UNION ALL
  SELECT 'RE101','Ground-AirForce',  'L' UNION ALL

  -- RS101: 자계 감수성 (해군계 A · 우주 - · 나머지 L)
  SELECT 'RS101','Surface-Ships',    'A' UNION ALL
  SELECT 'RS101','Submarines',       'A' UNION ALL
  SELECT 'RS101','Aircraft-Army',    'L' UNION ALL
  SELECT 'RS101','Aircraft-Navy',    'A' UNION ALL
  SELECT 'RS101','Aircraft-AirForce','L' UNION ALL
  SELECT 'RS101','Space-Systems',    '-' UNION ALL
  SELECT 'RS101','Ground-Army',      'L' UNION ALL
  SELECT 'RS101','Ground-Navy',      'A' UNION ALL
  SELECT 'RS101','Ground-Marines',   'L' UNION ALL
  SELECT 'RS101','Ground-AirForce',  'L' UNION ALL

  -- RS105: 과도 전자장 (해상/잠수함/해군-지상 L · 나머지 -)
  SELECT 'RS105','Surface-Ships',    'L' UNION ALL
  SELECT 'RS105','Submarines',       'L' UNION ALL
  SELECT 'RS105','Aircraft-Army',    '-' UNION ALL
  SELECT 'RS105','Aircraft-Navy',    '-' UNION ALL
  SELECT 'RS105','Aircraft-AirForce','-' UNION ALL
  SELECT 'RS105','Space-Systems',    '-' UNION ALL
  SELECT 'RS105','Ground-Army',      '-' UNION ALL
  SELECT 'RS105','Ground-Navy',      'L' UNION ALL
  SELECT 'RS105','Ground-Marines',   '-' UNION ALL
  SELECT 'RS105','Ground-AirForce',  '-'
) m;

-- ============================================================
-- 편의 VIEW: 매트릭스 형태로 조회
-- ============================================================
CREATE VIEW IF NOT EXISTS applicability_matrix AS
SELECT
  s.code AS standard_code,
  t.category, t.code AS test_code,
  p.code AS platform_code,
  a.marker
FROM applicability a
JOIN standard  s ON s.id = a.standard_id
JOIN test_item t ON t.id = a.test_item_id
JOIN platform  p ON p.id = a.platform_id
ORDER BY s.code, t.category, t.code, p.code;
