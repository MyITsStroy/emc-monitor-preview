-- Migration 003: standard + test_item + standard_test_item seed
-- EMC Monitor - SQLite

PRAGMA foreign_keys = ON;

-- ============================================================
-- Standards (3)
-- ============================================================
INSERT INTO standard (code, name, version, issued_year, issuing_body, domain, status) VALUES
('MIL-STD-461C', 'Electromagnetic Emission and Susceptibility Requirements for the Control of EMI', 'C', 1986, 'DoD', 'military', 'superseded'),
('MIL-STD-461F', 'Requirements for the Control of EMI Characteristics of Subsystems and Equipment', 'F', 2007, 'DoD', 'military', 'superseded'),
('MIL-STD-461G', 'Requirements for the Control of EMI Characteristics of Subsystems and Equipment', 'G', 2015, 'DoD', 'military', 'active');

-- ============================================================
-- Test items: MIL-STD-461G (19)
-- ============================================================
INSERT INTO test_item (code, category, nature,           target,                                     limit_unit, detector, freq_min_hz, freq_max_hz,  name) VALUES
('CE101', 'CE', 'emission',       'Power Leads',                              'dBuA',   'Peak', 30,          10000,        '전도성 방출, 가청 주파수 전류'),
('CE102', 'CE', 'emission',       'Power Leads',                              'dBuV',   'Peak', 10000,       10000000,     '전도성 방출, 전원선'),
('CE106', 'CE', 'emission',       'Antenna Port',                             'dBuV',   'Peak', 10000,       40000000000,  '안테나 단자 방출'),
('CS101', 'CS', 'susceptibility', 'Power Leads',                              'V',      NULL,   30,          150000,       '전도성 감수성, 전원선'),
('CS103', 'CS', 'susceptibility', 'Antenna Port',                             'dBm',    NULL,   15000,       10000000000,  '안테나 상호변조'),
('CS104', 'CS', 'susceptibility', 'Antenna Port',                             'dBm',    NULL,   30,          20000000000,  '안테나 부요파 제거'),
('CS105', 'CS', 'susceptibility', 'Antenna Port',                             'dBm',    NULL,   30,          20000000000,  '안테나 교차변조'),
('CS109', 'CS', 'susceptibility', 'Structure Current',                        'dBuA',   NULL,   60,          100000,       '구조체 전류'),
('CS114', 'CS', 'susceptibility', 'Bulk Cable Injection',                     'dBuA',   NULL,   10000,       200000000,    '케이블 BCI'),
('CS115', 'CS', 'susceptibility', 'Bulk Cable Injection',                     'A',      NULL,   NULL,        NULL,         'BCI 임펄스'),
('CS116', 'CS', 'susceptibility', 'Cables and Power Leads',                   'A',      NULL,   10000,       100000000,    '댐핑 사인파'),
('CS117', 'CS', 'susceptibility', 'Cables and Power Leads',                   'A',      NULL,   NULL,        NULL,         '낙뢰 유도 과도전류'),
('CS118', 'CS', 'susceptibility', 'Personnel Borne Electrostatic Discharge',  'kV',     NULL,   NULL,        NULL,         '인체 ESD'),
('RE101', 'RE', 'emission',       'Magnetic Field',                           'dBpT',   'Peak', 30,          100000,       '방사성 방출, 자계'),
('RE102', 'RE', 'emission',       'Electric Field',                           'dBuV/m', 'Peak', 10000,       18000000000,  '방사성 방출, 전계'),
('RE103', 'RE', 'emission',       'Antenna Spurious and Harmonic Outputs',    'dBm',    'Peak', 10000,       40000000000,  '안테나 스퓨리어스·고조파'),
('RS101', 'RS', 'susceptibility', 'Magnetic Field',                           'dBpT',   NULL,   30,          100000,       '방사성 감수성, 자계'),
('RS103', 'RS', 'susceptibility', 'Electric Field',                           'V/m',    NULL,   2000000,     40000000000,  '방사성 감수성, 전계'),
('RS105', 'RS', 'susceptibility', 'Transient Electromagnetic Field',          'V/m',    NULL,   NULL,        NULL,         '과도 전자장');

-- ============================================================
-- Test items: MIL-STD-461C (18)
-- ============================================================
INSERT INTO test_item (code, category, nature,           target,                              limit_unit, detector, freq_min_hz, freq_max_hz, name) VALUES
('CE01', 'CE', 'emission',       'Power Leads',                       'dBuA',   'Peak', 30,    15000,       '전도성 방출, 전원·신호선 저주파'),
('CE03', 'CE', 'emission',       'Power Leads',                       'dBuV',   'Peak', 15000, 50000000,    '전도성 방출, 전원·신호선'),
('CE06', 'CE', 'emission',       'Antenna Terminal',                  'dBuV',   'Peak', 10000, 12400000000, '안테나 단자 방출'),
('CE07', 'CE', 'emission',       'Power Leads',                       'V',      NULL,   NULL,  NULL,        '전원선 시간영역 스파이크'),
('CS01', 'CS', 'susceptibility', 'Power Leads',                       'V',      NULL,   30,    50000,       '전도성 감수성, 전원선'),
('CS02', 'CS', 'susceptibility', 'Power Leads',                       'V',      NULL,   50000, 400000000,   '전도성 감수성, 전원선'),
('CS03', 'CS', 'susceptibility', 'Antenna Port',                      'dBm',    NULL,   15000, 10000000000, '안테나 상호변조'),
('CS04', 'CS', 'susceptibility', 'Antenna Port',                      'dBm',    NULL,   30,    20000000000, '안테나 부요파 제거'),
('CS05', 'CS', 'susceptibility', 'Antenna Port',                      'dBm',    NULL,   30,    20000000000, '안테나 교차변조'),
('CS06', 'CS', 'susceptibility', 'Power Leads',                       'V',      NULL,   NULL,  NULL,        '전원선 스파이크'),
('CS09', 'CS', 'susceptibility', 'Structure (Common Mode)',           'dBuA',   NULL,   60,    100000,      '구조체 공통모드 전류'),
('RE01', 'RE', 'emission',       'Magnetic Field',                    'dBpT',   'Peak', 30,    50000,       '자계 방출'),
('RE02', 'RE', 'emission',       'Electric Field',                    'dBuV/m', 'Peak', 14000, 10000000000, '전계 방출'),
('RE03', 'RE', 'emission',       'Antenna Spurious and Harmonics',    'dBm',    'Peak', 10000, 40000000000, '안테나 스퓨리어스·고조파'),
('RE04', 'RE', 'emission',       'Magnetic Field',                    'dBpT',   'Peak', NULL,  NULL,        '자계 방출, 시험장비 보조'),
('RS01', 'RS', 'susceptibility', 'Magnetic Field',                    'dBpT',   NULL,   30,    30000,       '자계 감수성'),
('RS02', 'RS', 'susceptibility', 'Magnetic Induction Field',          'A',      NULL,   NULL,  NULL,        '스파이크·전원주파수 자계'),
('RS03', 'RS', 'susceptibility', 'Electric Field',                    'V/m',    NULL,   14000, 40000000000, '전계 감수성');

-- ============================================================
-- standard_test_item: MIL-STD-461G mapping (19)
-- ============================================================
INSERT INTO standard_test_item (standard_id, test_item_id)
SELECT s.id, t.id
FROM standard s
JOIN test_item t ON t.code IN
  ('CE101','CE102','CE106','CS101','CS103','CS104','CS105','CS109','CS114','CS115','CS116','CS117','CS118','RE101','RE102','RE103','RS101','RS103','RS105')
WHERE s.code = 'MIL-STD-461G';

-- ============================================================
-- standard_test_item: MIL-STD-461C mapping (18)
-- ============================================================
INSERT INTO standard_test_item (standard_id, test_item_id)
SELECT s.id, t.id
FROM standard s
JOIN test_item t ON t.code IN
  ('CE01','CE03','CE06','CE07','CS01','CS02','CS03','CS04','CS05','CS06','CS09','RE01','RE02','RE03','RE04','RS01','RS02','RS03')
WHERE s.code = 'MIL-STD-461C';
