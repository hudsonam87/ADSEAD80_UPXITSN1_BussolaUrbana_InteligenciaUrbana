# Bússola Urbana

Plataforma de inteligência urbana para apoio à decisão de gestor público em segurança preventiva, desenvolvida na disciplina de Usina de Projetos Experimentais I (UPX 1) — Centro Universitário Facens.

## O problema

Gestor de segurança pública decide onde alocar reforço de patrulhamento, priorizar manutenção de iluminação ou intervir em área de risco a partir de experiência de campo e boletim de ocorrência isolado, sem análise consolidada de padrão espacial e temporal — mesmo com dado de ocorrência já publicado de forma aberta.

## A solução

O Bússola Urbana transforma dado aberto de ocorrência da Secretaria de Segurança Pública do Estado de São Paulo (SSP-SP) em um índice de atenção explicável por área, sem depender de modelo preditivo ou classificação de indivíduo. Cada número é rastreável até o dado bruto que o gerou.

## Metodologia

- **Recorte de dado:** furto, roubo e tráfico de entorpecentes, região de Sorocaba/SP, janeiro a junho de 2026 (4.279 ocorrências com coordenada válida)
- **Clusterização espacial:** DBSCAN (eps = 0,25 km, min_samples = 20), identificando 23 áreas de concentração
- **Índice de Atenção (0-100):** média entre percentil de volume de ocorrência e percentil de concentração no período de pico de cada área
- **Classificação:** Alta (≥70), Média (45-69), Baixa (<45)

## Estrutura do banco de dado

Sete tabelas, documentadas em [`TABELAS.md`](./TABELAS.md):

| Tabela | Conteúdo |
|---|---|
| `usuarios` | Gestores, fiscais e equipe de zeladoria (login institucional) |
| `ocorrencias_estatisticas` | Dado oficial da SSP-SP (fonte do índice) |
| `relatos_cidadaos` | Reporte do cidadão, sem coleta de dado pessoal |
| `manchas_criticas` | As 23 áreas identificadas, com índice e prioridade |
| `vistorias_campo` | Diagnóstico técnico do fiscal em campo |
| `ordens_zeladoria` | Ordem de serviço gerada após vistoria confirmada |
| `historico_prioridades` | Linha do tempo de mudança de score por área |

Script completo em [`PostgreSQL.sql`](./PostgreSQL.sql).

## Fluxo lógico do sistema

Diagrama completo em [`diagrama-ecossistema.md`](./diagrama-ecossistema.md). Resumo: cidadão acessa sem login (relato anônimo); gestor e fiscal acessam por login institucional; ambos convergem na lista de vistoria por prioridade; fiscal confirma em campo; sistema gera ordem de zeladoria; mapa é atualizado ao final do serviço.

## Postura ética do projeto

Este projeto exclui deliberadamente reconhecimento facial, integração com o Banco Nacional de Mandados de Prisão, e qualquer forma de classificação de indivíduo. O índice prioriza território, nunca pessoa — ver referencial teórico no relatório principal (Lum & Isaac, 2016, sobre viés em policiamento preditivo).

## Equipe

Projeto acadêmico desenvolvido em grupo — ver relatório completo (AC1) para papéis e responsabilidades individuais.

## Status

MVP em desenvolvimento em plataforma low-code (Glide + Google Sheets), com estrutura de dado já validada sobre a análise real.
