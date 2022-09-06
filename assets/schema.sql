CREATE TABLE run(
id INTEGER PRIMARY KEY AUTOINCREMENT,
timestamp REAL DEFAULT (datetime('now', 'localtime')),
run_date TEXT NOT NULL,
run_name TEXT NOT NULL,
pipeline_version TEXT NOT NULL,
UNIQUE(run_date,run_name));
CREATE TABLE sample(
id INTEGER PRIMARY KEY AUTOINCREMENT,
run_id INTEGER NOT NULL,
sample_id TEXT NOT NULL,
patient_id TEXT,
external_id TEXT,
timestamp REAL DEFAULT (datetime('now', 'localtime')),
json BLOB NOT NULL,
pangolin_lineage TEXT,
pangolin_lineage_full TEXT,
coverage_20X INTEGER NOT NULL,
reference TEXT NOT NULL,
sequence BLOB NOT NULL,
UNIQUE(sample_id),
FOREIGN KEY(run_id) REFERENCES run(id));
CREATE TABLE pangolin(
id INTEGER PRIMARY KEY AUTOINCREMENT,
sample_id INTEGER NOT NULL,
pangolin_version TEXT NOT NULL,
pangolin_lineage TEXT NOT NULL,
FOREIGN KEY(sample_id) REFERENCES sample(id));
