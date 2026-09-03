-- 1. TABELA DE USUÁRIOS INTERNOS (Prefeitura, Fiscais, Zeladoria)
CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    cargo_funcao VARCHAR(50) NOT NULL, -- Ex: 'Analista', 'Fiscal de Campo', 'Zeladoria'
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. TABELA DE CADASTRO DOS CIDADÃOS (Dados Ocultos/Protegidos)
CREATE TABLE usuarios_cidadaos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome_completo VARCHAR(150) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    celular VARCHAR(20) NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. TABELA DE OCORRÊNCIAS ESTATÍSTICAS (Dados Oficiais da Polícia)
CREATE TABLE ocorrencias_estatisticas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    tipo_crime VARCHAR(50) NOT NULL, -- Ex: 'Roubo', 'Furto', 'Tráfico'
    data_hora TIMESTAMP NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. TABELA DE RELATOS DOS CIDADÃOS (Estilo Waze com opção de Anonimato)
CREATE TABLE relatos_cidadaos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cidadao_id UUID NOT NULL,
    categoria VARCHAR(50) NOT NULL, -- Ex: 'Ponto de Assalto', 'Poste Apagado'
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    descricao TEXT,
    foto_url VARCHAR(255),
    quero_anonimato BOOLEAN DEFAULT FALSE,
    status_veracidade VARCHAR(30) DEFAULT 'Pendente', -- 'Pendente', 'Confirmado', 'Falso'
    votos_confirmacao INTEGER DEFAULT 0,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cidadao_id) REFERENCES usuarios_cidadaos(id) ON DELETE CASCADE
);

-- 5. TABELA DE MANCHAS CRÍTICAS (Inteligência do Mapa / Zonas de Risco)
CREATE TABLE manchas_criticas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome_regiao VARCHAR(150) NOT NULL,
    raio_metros INTEGER DEFAULT 200,
    latitude_centro DECIMAL(9,6) NOT NULL,
    longitude_centro DECIMAL(9,6) NOT NULL,
    origem_dados VARCHAR(30) NOT NULL, -- Ex: 'Oficial', 'Cidadao', 'Misto'
    nivel_prioridade VARCHAR(20) DEFAULT 'Baixa', -- 'Baixa', 'Média', 'Alta'
    score_atual INTEGER DEFAULT 0,
    status_workflow VARCHAR(30) DEFAULT 'Aguardando Triagem', -- Status do Workflow desenhado
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. TABELA DE VISTORIAS EM CAMPO (Diagnóstico Técnico do Fiscal)
CREATE TABLE vistorias_campo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mancha_id UUID NOT NULL,
    fiscal_id UUID NOT NULL,
    problema_identificado VARCHAR(100) NOT NULL, -- Ex: 'Falta Iluminação', 'Mato Alto'
    observacoes TEXT,
    foto_url VARCHAR(255),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (mancha_id) REFERENCES manchas_criticas(id) ON DELETE CASCADE,
    FOREIGN KEY (fiscal_id) REFERENCES usuarios(id)
);

-- 7. TABELA DE ORDENS DE ZELADORIA (Ação Direta da Prefeitura)
CREATE TABLE ordens_zeladoria (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vistoria_id UUID NOT NULL,
    tipo_servico VARCHAR(100) NOT NULL, -- Ex: 'Troca para LED', 'Poda de árvore'
    secretaria_responsavel VARCHAR(100) NOT NULL,
    status VARCHAR(30) DEFAULT 'Pendente', -- 'Pendente', 'Em Execução', 'Concluída'
    data_conclusao TIMESTAMP,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vistoria_id) REFERENCES vistorias_campo(id) ON DELETE CASCADE
);

-- 8. TABELA DE HISTÓRICO DE PONTUAÇÃO (Auditoria e Métrica de Evolução)
CREATE TABLE historico_prioridades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mancha_id UUID NOT NULL,
    score_no_momento INTEGER NOT NULL,
    prioridade_no_momento VARCHAR(20) NOT NULL,
    motivo_mudanca VARCHAR(255), -- Ex: 'Novo roubo oficial', 'Zeladoria concluída'
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (mancha_id) REFERENCES manchas_criticas(id) ON DELETE CASCADE
);
