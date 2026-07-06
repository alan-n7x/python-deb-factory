# Arquitetura

Este documento explica a arquitetura do Python Deb Factory, um template para criar aplicações Python profissionais distribuídas como pacotes Debian.

## Visão Geral

O Python Deb Factory segue uma arquitetura limpa e modular que separa claramente as responsabilidades:

- **Código da Aplicação** (`src/`) - Contém a lógica de negócio da sua aplicação
- **Empacotamento Debian** (`debian/`) - Arquivos necessários para construir pacotes .deb
- **CI/CD** (`.github/workflows/`) - Pipeline de integração e entrega contínua
- **Testes** (`tests/`) - Suite de testes automatizados
- **Documentação** (`docs/`) - Guias e explicações detalhadas
- **Scripts** (`scripts/`) - Utilitários para automação de tarefas

## Componentes Principais

### 1. Layout `src/`

O código da aplicação fica no diretório `src/` seguindo o padrão recomendado pelo PyPA (Python Packaging Authority):

```
src/
└── seupacote/
    ├── __init__.py
    ├── __main__.py     # Ponto de entrada para CLI
    └── seu_módulo.py   # Lógica da aplicação
```

Benefícios:
- Evita conflitos de namespace
- Torna a instalação em modo desenvolvedor mais previsível
- É o padrão recomendado para projetos Python modernos

### 2. Empacotamento Debian (`debian/`)

Contém todos os arquivos necessários para criar um pacote .deb compatível com Debian e Ubuntu:

- `control` - Metadados do pacote (nome, versão, dependências, etc.)
- `changelog` - Histórico de mudanças no formato Debian
- `compat` - Nível de compatibilidade do debhelper
- `rules` - Script de construção baseado em Makefile
- `source/format` - Formato do pacote fonte (3.0 quilt)

### 3. CI/CD (GitHub Actions)

O workflow em `.github/workflows/ci.yml` automatiza:
- Testes em múltiplas versões de Python
- Verificação de qualidade de código (ruff, mypy)
- Construção de distribuições Python (wheel, sdist)
- Construção de pacotes Debian
- Publicação opcional em PyPI, Launchpad e GitHub Releases

### 4. Configuração de Empacotamento Python (`pyproject.toml`)

Define:
- Metadados do projeto (nome, versão, autor, etc.)
- Dependências
- Pontos de entrada de console scripts
- Configuração de ferramentas de qualidade (ruff, mypy)
- Backend de construção (setuptools)

### 5. Qualidade de Código

Integração com:
- **Ruff** - Linting e formatação extremamente rápida
- **MyPy** - Verificação estática de tipos
- **Pre-commit** - Hooks executados antes de cada commit
- **Pytest** - Framework de teste

## Fluxo de Desenvolvimento Típico

1. **Desenvolvimento Local**
   - Edite o código em `src/`
   - Execute testes com `pytest`
   - Verifique qualidade com `ruff check` e `mypy src`
   - Use `pre-commit run` para garantir que os hooks passem

2. **Construção Local**
   - Construa o pacote Python: `python -m build`
   - Construa o pacote Debian: `debuild -us -uc`

3. **Release**
   - Atualize a versão em `pyproject.toml`
   - Adicione fragmentos no `changes/` (se usando towncrier)
   - Faça commit e tag: `git tag v1.0.0 && git push --tags`
   - O GitHub Actions cuidará do resto (construção e publicação)

## Personalizando para Sua Aplicação

Para adaptar este template para sua aplicação:

1. Renomeie o diretório `src/hello_python_deb` para `src/seupacote`
2. Atualize o nome do pacote em `pyproject.toml`
3. Atualize os metadados em `pyproject.toml` (autor, descrição, etc.)
4. Atualize o arquivo `debian/control` com suas informações
5. Implemente a lógica da sua aplicação em `src/seupacote/`
6. Atualize o ponto de entrada em `pyproject.toml` se necessário
7. Adicione seus testes em `tests/`

## Princípios de Design

- **Separação de Responsabilidades**: Cada diretório tem um propósito claro
- **Convenção sobre Configuração**: Segue padrões estabelecidos da comunidade
- **Automatização**: Máximo de tarefas automatizadas via CI/CD e scripts
- **Qualidade**: Verificações automáticas de código em múltiplos níveis
- **Distribuição Multiplataforma**: Suporta pip, apt e GitHub Releases
- **Extensibilidade**: Fácil de adaptar para diferentes tipos de aplicações (CLI, biblioteca, daemon, etc.)

Este template foi projetado para ser um ponto de partida que você pode clonar, modificar o código da aplicação e manter toda a infraestrutura de build, teste e distribuição pronta para uso profissional.