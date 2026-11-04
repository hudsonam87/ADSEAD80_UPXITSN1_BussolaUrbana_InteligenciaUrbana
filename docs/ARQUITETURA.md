# Arquitetura futura (low-code/no-code) — Bússola Urbana

> **Estágio:** este documento descreve um plano de evolução. A arquitetura abaixo **não foi implementada**. O que existe hoje é a análise em Python, um protótipo HTML e o protótipo navegável no Figma.

## Fluxo

```
Dado real (SSP-SP)
        ↓
Motor de análise (Python: DBSCAN + índice explicável) — executado sobre dado real (ver README)
        ↓
Base de dados no-code (Airtable) — armazena áreas e índices calculados
        ↓
App low-code (Bubble ou Glide) — interface, filtros, situação urbana
        ↓
Automação (Make ou n8n) — canal cidadão, encaminhamento por setor
```

## Por que o motor de análise continua sendo script, não low-code puro

Clustering espacial (DBSCAN) e cálculo de percentil não são operações nativas de ferramenta no-code. Isso é padrão de arquitetura comum em MVP low-code real: a lógica computacional pesada roda como script externo, chamado via API/webhook pela camada no-code — que cuida de interface, fluxo e automação. Não é gambiarra, é como produtos low-code reais lidam com cálculo que a ferramenta não faz nativamente.

## Papel de cada camada

- **Airtable**: armazena as áreas já processadas — índice, composição por tipo de crime, ambiente predominante — equivalente ao `clusters_index.json` deste repositório
- **Bubble/Glide**: reproduz a tela de Centro de Inteligência Urbana e a Situação Urbana de cada área — interface que o gestor usaria de verdade
- **Make/n8n**: canal de reporte cidadão e encaminhamento por setor responsável — hoje mockup no protótipo, viraria fluxo automatizado real

## Regras de negócio (já especificadas, prontas para virar automação)

- Índice de atenção = 50% volume de ocorrência (percentil) + 50% concentração no período de pico (percentil)
- Índice ≥ 70 → recomendação de reforço preventivo no horário de pico
- Índice ≥ 45 → recomendação de monitoramento
- Ambiente predominante "Via Pública" + índice ≥ 45 → encaminhamento para Secretaria de Obras/Iluminação
- ≥ 15% de ocorrências envolvendo veículo + índice ≥ 45 → encaminhamento para Secretaria de Mobilidade

Essas regras estão especificadas, mas não foram testadas com usuários. Elas são exatamente o tipo de lógica condicional que uma automação Make/n8n implementa sem precisar de código.
