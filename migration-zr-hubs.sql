-- ZR Express Hubs table
CREATE TABLE IF NOT EXISTS zr_hubs (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT,
  territory_id TEXT,
  city_territory_id TEXT,
  city_name TEXT,
  territory_name TEXT,
  district_name TEXT,
  status INTEGER DEFAULT 1,
  raw JSONB,
  synced_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fast wilaya lookup
CREATE INDEX IF NOT EXISTS idx_zr_hubs_territory ON zr_hubs(territory_id);
CREATE INDEX IF NOT EXISTS idx_zr_hubs_city_territory ON zr_hubs(city_territory_id);

-- Also store territories
CREATE TABLE IF NOT EXISTS zr_territories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  parent_id TEXT,
  raw JSONB,
  synced_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS: anyone can read, only authenticated can write
ALTER TABLE zr_hubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE zr_territories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read zr_hubs" ON zr_hubs FOR SELECT USING (true);
CREATE POLICY "Auth all zr_hubs" ON zr_hubs FOR ALL USING (true);

CREATE POLICY "Public read zr_territories" ON zr_territories FOR SELECT USING (true);
CREATE POLICY "Auth all zr_territories" ON zr_territories FOR ALL USING (true);
