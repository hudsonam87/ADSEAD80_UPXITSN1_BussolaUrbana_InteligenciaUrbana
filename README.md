# Bússola Urbana — Plataforma de Inteligência Urbana

Projeto da disciplina UPX TI 1 (Cidades Inteligentes) — Facens, Sorocaba/SP.

## O que é

O Bússola Urbana identifica áreas de concentração de ocorrência (furto, roubo, tráfico) em Sorocaba/SP a partir de dado público real, calcula um índice de atenção explicável para cada área, e sugere ações de apoio à decisão para gestores de segurança pública e municipais — sem prever crime nem automatizar decisão policial.

## Estágio real do projeto

- **Feito:** análise em Python sobre dado real da SSP-SP (agrupamento DBSCAN e Índice de Atenção), protótipo técnico em HTML e protótipo navegável no Figma (web para o gestor e mobile para o agente de campo e o cidadão).
- **Não feito:** não há sistema em produção, banco de dados real, integração com a SSP, com o Infocrim ou com qualquer serviço de atendimento. O protocolo e o acompanhamento de relato existem só como telas no Figma.
- **Arquitetura low-code (Airtable, Bubble/Glide, Make):** é um plano de evolução documentado em `docs/ARQUITETURA.md`, **não** foi implementado.

## Estrutura deste repositório

```
├── prototipo/
│   └── index.html                  → protótipo técnico de validação (abre direto no navegador)
├── scripts/
│   ├── analise_clusters.py         → pipeline original de clustering (DBSCAN) e índice de atenção
│   └── reproducao_resultados.py    → reproduz as contagens do artigo a partir de dados/ocorrencias_4279.csv
├── dados/
│   ├── ocorrencias_4279.csv        → 4.279 ocorrências georreferenciadas usadas na análise (SSP-SP, dados abertos)
│   ├── crime_points.json           → pontos usados no protótipo HTML (versão anterior)
│   └── clusters_index.json         → áreas e índice de uma rodada ANTERIOR (ver aviso abaixo)
└── docs/
    └── ARQUITETURA.md              → plano de arquitetura futura
```

## Aviso de versão dos dados

`dados/clusters_index.json` vem de uma rodada anterior da análise (23 áreas, 1.727 ocorrências nas áreas, índice máximo 76). Os números do artigo e do relatório (23 áreas, 1.695 ocorrências, índice máximo 72,8) vêm da análise final. Esse arquivo **não foi alterado à mão** para coincidir com os documentos e ainda não foi regenerado, porque isso exige o arquivo bruto da SSP, que não está neste repositório. Até lá, o índice da análise final não é reproduzível a partir deste repositório.

## O que dá para reproduzir aqui

Com `python scripts/reproducao_resultados.py` (precisa de pandas, scikit-learn e scipy):

- 4.279 registros, dos quais 201 têm data do fato anterior a 2026.
- Base principal: 23 áreas, 1.695 ocorrências dentro (39,6%).
- Análise complementar, só com as 4.078 datadas de janeiro a junho de 2026: 21 áreas, 1.504 dentro (36,9%).
- Teste de persistência: treino de janeiro a março (1.934), teste de abril a junho (2.144); 26 áreas; as áreas reuniram 39,9% das ocorrências do teste.
- Uma seleção simples por densidade, cobrindo a mesma área (cerca de 21 km²), reuniu 41,8%. Ou seja, o DBSCAN não trouxe vantagem de cobertura; ele forma áreas contínuas e fáceis de explicar.

Limites: o resultado depende do raio e do mínimo de ocorrências (escolhas do grupo, não valores otimizados); os 250 m e o mínimo de 20 não passaram por teste de sensibilidade completo; o Índice de Atenção não demonstrou vantagem sobre o volume isolado.

## Dado real e dado demonstrativo

- 🟢 **Real**: ocorrências (SSP-SP, dados abertos) e o agrupamento feito sobre elas.
- 🔵 **Demonstrativo**: números das telas do protótipo (protocolo, etapas, pontos de iluminação, sensor), que não vêm de operação real.
- ⚪ **Futuro**: banco de dados, atualização automática, integração com o Infocrim, ciclo antes/depois de intervenções.

## Banco de dados planejado e fluxo do sistema

São desenho de uma versão futura, não um sistema em funcionamento: o esquema com sete tabelas está em [`TABELAS.md`](./TABELAS.md) e em [`PostgreSQL.sql`](./PostgreSQL.sql), e o fluxo lógico planejado está em [`diagrama-ecossistema.md`](./diagrama-ecossistema.md).

## Documentação completa

A documentação completa do projeto (Introdução, Persona, Lean Canvas, Canvas de Proposta de Valor, Estudo de Mercado, metodologia do índice) está no relatório entregue na Avaliação Final de UPX I; o artigo no modelo IEEE acompanha o relatório.

## Fonte de dados

SSP-SP — Portal de Dados Abertos de Criminalidade: https://www.ssp.sp.gov.br/estatistica/consultas
