CREATE TABLE sample(
id INTEGER PRIMARY KEY AUTOINCREMENT,
sample_id TEXT NOT NULL,
patient_id TEXT,
external_id TEXT,
json BLOB NOT NULL,
timestamp REAL DEFAULT (datetime('now', 'localtime')),
run_date TEXT NOT NULL,
pipeline_version TEXT NOT NULL,
pangolin_lineage TEXT,
pangolin_lineage_full TEXT,
coverage_20X INTEGER NOT NULL,
reference TEXT NOT NULL,
sequence BLOB NOT NULL,
UNIQUE(sample_id,run_date));
CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE pangolin(
id INTEGER PRIMARY KEY AUTOINCREMENT,
sample_id INTEGER NOT NULL,
pangolin_version TEXT NOT NULL,
pangolin_lineage TEXT NOT NULL,
FOREIGN KEY(sample_id) REFERENCES sample(id));
