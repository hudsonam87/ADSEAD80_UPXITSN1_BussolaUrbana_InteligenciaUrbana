-- 1. TABELA DE USUÁRIOS INTERNOS (Prefeitura, Fiscais, Zeladoria)
CREATE TABLE usuarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome VARCHAR(150) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  cargo_funcao VARCHAR(50) NOT NULL, -- Ex: 'Analista', 'Fiscal de Campo', 'Zeladoria'
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. TABELA DE OCORRÊNCIAS ESTATÍSTICAS (Dados Oficiais da Polícia)
CREATE TABLE ocorrencias_estatisticas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  latitude DECIMAL(9,6) NOT NULL,
  longitude DECIMAL(9,6) NOT NULL,
  tipo_crime VARCHAR(50) NOT NULL, -- Ex: 'Roubo', 'Furto', 'Tráfico'
  data_hora TIMESTAMP NOT NULL,
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. TABELA DE RELATOS DOS CIDADÃOS (sem coleta de dado pessoal — anônimo por padrão)
-- Removida a tabela usuarios_cidadaos (guardava CPF, nome completo e celular).
-- Isso contradizia a regra do projeto: canal do cidadão nunca coleta dado pessoal.
CREATE TABLE relatos_cidadaos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  categoria VARCHAR(50) NOT NULL, -- Ex: 'Poste apagado', 'Calçada danificada', 'Local com sensação de insegurança'
  latitude DECIMAL(9,6) NOT NULL,
  longitude DECIMAL(9,6) NOT NULL,
  descricao TEXT,
  foto_url VARCHAR(255),
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Nota: categoria trata só de infraestrutura/zeladoria (nunca reporte sobre pessoa).
-- Removido também o sistema de "votos_confirmacao".

-- 4. TABELA DE MANCHAS CRÍTICAS (Inteligência do Mapa / Zonas de Risco)
-- score_atual é calculado EXCLUSIVAMENTE a partir de ocorrencias_estatisticas (dado oficial).
-- Relato de cidadão nunca entra nesse cálculo.
CREATE TABLE manchas_criticas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome_regiao VARCHAR(150) NOT NULL,
  raio_metros INTEGER DEFAULT 250,
  latitude_centro DECIMAL(9,6) NOT NULL,
  longitude_centro DECIMAL(9,6) NOT NULL,
  nivel_prioridade VARCHAR(20) DEFAULT 'Baixa',
  score_atual INTEGER DEFAULT 0,
  status_workflow VARCHAR(30) DEFAULT 'Aguardando Triagem',
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. TABELA DE VISTORIAS EM CAMPO (Diagnóstico Técnico do Fiscal)
CREATE TABLE vistorias_campo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mancha_id UUID NOT NULL,
  fiscal_id UUID NOT NULL,
  problema_identificado VARCHAR(100) NOT NULL,
  observacoes TEXT,
  foto_url VARCHAR(255),
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (mancha_id) REFERENCES manchas_criticas(id) ON DELETE CASCADE,
  FOREIGN KEY (fiscal_id) REFERENCES usuarios(id)
);

-- 6. TABELA DE ORDENS DE ZELADORIA (Ação Direta da Prefeitura)
CREATE TABLE ordens_zeladoria (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vistoria_id UUID NOT NULL,
  tipo_servico VARCHAR(100) NOT NULL,
  secretaria_responsavel VARCHAR(100) NOT NULL,
  status VARCHAR(30) DEFAULT 'Pendente',
  data_conclusao TIMESTAMP,
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (vistoria_id) REFERENCES vistorias_campo(id) ON DELETE CASCADE
);

-- 7. TABELA DE HISTÓRICO DE PONTUAÇÃO (Auditoria e Métrica de Evolução)
CREATE TABLE historico_prioridades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mancha_id UUID NOT NULL,
  score_no_momento INTEGER NOT NULL,
  prioridade_no_momento VARCHAR(20) NOT NULL,
  motivo_mudanca VARCHAR(255),
  atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (mancha_id) REFERENCES manchas_criticas(id) ON DELETE CASCADE
);
