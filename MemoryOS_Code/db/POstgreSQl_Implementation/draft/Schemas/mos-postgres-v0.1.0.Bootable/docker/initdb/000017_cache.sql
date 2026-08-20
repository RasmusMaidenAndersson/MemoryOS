CREATE TABLE cache.semantic_cache(
 cache_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), cache_key TEXT NOT NULL UNIQUE, query_hash TEXT NOT NULL, context_hash TEXT NOT NULL,
 result JSONB NOT NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), expires_at TIMESTAMPTZ, hit_count BIGINT NOT NULL DEFAULT 0 CHECK(hit_count>=0), last_hit TIMESTAMPTZ);
CREATE INDEX semantic_cache_expiry_idx ON cache.semantic_cache(expires_at) WHERE expires_at IS NOT NULL;
