-- page_views table for visitor analytics
CREATE TABLE IF NOT EXISTS page_views (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    page TEXT NOT NULL,
    path TEXT,
    referrer TEXT,
    user_agent TEXT,
    screen_width INTEGER,
    country TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fast queries
CREATE INDEX IF NOT EXISTS idx_page_views_created_at ON page_views(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_page_views_page ON page_views(page);
CREATE INDEX IF NOT EXISTS idx_page_views_path ON page_views(path);

-- Enable RLS (allow inserts from client, read only in admin)
ALTER TABLE page_views ENABLE ROW LEVEL SECURITY;

-- Anyone can insert (track a view)
CREATE POLICY "Anyone can insert page views" ON page_views
    FOR INSERT WITH CHECK (true);

-- Only admin can read (we'll handle this via service key or deny public read)
CREATE POLICY "Deny public read" ON page_views
    FOR SELECT USING (false);

-- View: daily stats (for admin)
CREATE OR REPLACE VIEW daily_page_views AS
SELECT 
    DATE(created_at) as date,
    page,
    COUNT(*) as views,
    COUNT(DISTINCT path) as unique_paths
FROM page_views
GROUP BY DATE(created_at), page
ORDER BY date DESC;

-- View: total stats
CREATE OR REPLACE VIEW total_page_stats AS
SELECT 
    page,
    COUNT(*) as total_views,
    MIN(created_at) as first_view,
    MAX(created_at) as last_view
FROM page_views
GROUP BY page
ORDER BY total_views DESC;
