CREATE TABLE sample(
id INTEGER PRIMARY KEY AUTOINCREMENT,
sample_id TEXT NOT NULL,
patient_id TEXT,
json TEST,
timestamp REAL DEFAULT (datetime('now', 'localtime')),
run_date TEXT NOT NULL,
pipeline_version TEXT NOT NULL,
pangolin_lineage TEXT NOT NULL,
pangolin_lineage_full TEXT NOT NULL,
coverage_20X INTEGER NOT NULL,
reference TEXT NOT NULL,
sequence BLOB NOT NULL);
CREATE TABLE pangolin(
id INTEGER PRIMARY KEY AUTOINCREMENT,
sample_id INTEGER NOT NULL,
pangolin_version TEXT NOT NULL,
pangolin_lineage TEXT NOT NULL,
FOREIGN KEY(sample_id) REFERENCES sample(id));
