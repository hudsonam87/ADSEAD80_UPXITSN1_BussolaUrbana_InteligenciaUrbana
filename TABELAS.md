# Documentação das Tabelas — Bússola Urbana

## 1. Tabela `historico_prioridades`

Funciona como linha do tempo. Toda vez que o algoritmo recalcula os pontos de uma mancha crítica (crime novo, registro de usuário ou zeladoria concluída), um novo registro é gerado.

| Coluna | Tipo | Descrição |
|---|---|---|
| id | UUID / INT | Identificador único do registro de histórico |
| mancha_id | UUID / INT | Vínculo com a mancha crítica monitorada (chave estrangeira) |
| score_no_momento | Integer | Pontuação exata calculada naquele instante (ex: 34) |
| prioridade_no_momento | String | Classificação gerada (Baixa, Média, Alta) |
| motivo_mudanca | String | Texto curto explicando a ocorrência (ex: "Novo roubo oficial") |
| atualizado_em | Timestamp | Data e hora exata em que o score mudou |

Com essa tabela, o painel administrativo gera gráfico de linha mostrando o score de um bairro caindo de 50 pontos (Alta) para 8 pontos (Baixa) após intervenção da prefeitura.

## 2. Entrada de dado — cidadão x prefeitura

**Cidadão:** acessa o mapa direto, sem login e sem coleta de CPF, nome ou celular. Reportar é ação livre, com identificador de sessão temporário apenas. Não é uma opção de anonimato à escolha — é o único modo que existe.

**Prefeitura/Fiscal:** login com e-mail institucional, por ser identidade profissional em contexto de trabalho, não dado sensível de cidadão.

## 3. Status do fluxo de trabalho (workflow)
