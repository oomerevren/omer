-- 🪐 OTONOM MEDYA HOLDİNGİ — MASTER DATABASE SCHEMA (v2.5)
CREATE EXTENSION IF NOT EXISTS vector;

-- 1. PROMPT MANAGEMENT (v2.5)
CREATE TABLE IF NOT EXISTS prompt_versions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    version INTEGER NOT NULL,
    prompt_text TEXT NOT NULL,
    model_name VARCHAR(50) NOT NULL,
    parameters JSONB, -- temperature, top_p, etc.
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(name, version)
);

-- 2. CENTRAL CONTENT HUB (Updated)
CREATE TABLE IF NOT EXISTS editorial_hub (
    post_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domain_tag VARCHAR(50),
    content_payload JSONB,
    prompt_version_id INTEGER REFERENCES prompt_versions(id),
    swarm_status VARCHAR(20) DEFAULT 'PENDING',
    risk_score INTEGER DEFAULT 0,
    
    -- Performance Metrics
    token_usage_input INTEGER DEFAULT 0,
    token_usage_output INTEGER DEFAULT 0,
    cost_estimated DECIMAL(10, 5) DEFAULT 0,
    processing_time_ms INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 3. PUBLICATION LAYER (Updated)
CREATE TABLE IF NOT EXISTS publications (
    id SERIAL PRIMARY KEY,
    post_id UUID REFERENCES editorial_hub(post_id),
    platform VARCHAR(50), -- X, Instagram, LinkedIn, Telegram, WordPress, Directus
    platform_post_id TEXT,
    platform_url TEXT,
    status VARCHAR(20) DEFAULT 'QUEUED', -- QUEUED, PUBLISHED, FAILED
    error_log TEXT,
    retry_count INTEGER DEFAULT 0,
    last_attempt TIMESTAMP,
    published_at TIMESTAMP
);

-- 4. CORPORATE MEMORY (Enhanced)
CREATE TABLE IF NOT EXISTS corporate_memory (
    id BIGSERIAL PRIMARY KEY,
    post_id UUID REFERENCES editorial_hub(post_id),
    category VARCHAR(50),
    content_text TEXT,
    embedding vector(1536), -- Updated for OpenAI/Mistral standard
    performance_score FLOAT, -- Success metric (likes, shares, or editor score)
    is_successful BOOLEAN,
    feedback_notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 5. SYSTEM MONITORING
CREATE TABLE IF NOT EXISTS system_health (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(50),
    status VARCHAR(20),
    metrics JSONB,
    checked_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_memory_vector ON corporate_memory USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX IF NOT EXISTS idx_pub_status ON publications(status);
