INSERT INTO identity.agents(name,agent_type) VALUES('mos-system','system') ON CONFLICT DO NOTHING;
INSERT INTO embedding.models(provider,name,version,dimension,metric) VALUES('reference','mos-embedding-1024','0.1',1024,'cosine') ON CONFLICT(provider,name,version) DO NOTHING;
