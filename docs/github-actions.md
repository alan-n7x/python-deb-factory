# GitHub Actions CI/CD

Este documento explica detalhadamente o workflow de CI/CD implementado no Python Deb Factory usando GitHub Actions, incluindo como ele funciona, como personalizá-lo e como estender suas funcionalidades.

## Visão Geral

O pipeline de CI/CD no arquivo `.github/workflows/ci.yml` automatiza o processo de:
1. Testar o código
2. Verificar qualidade (linting, type checking)
3. Construir distribuições Python (wheel e sdist)
4. Construir pacotes Debian (.deb)
5. Publicar em diversos repositórios (opcional)

O workflow é disparado por:
- Push para a branch `main`
- Pull requests para a branch `main`
- Push de tags que começam com `v` (para releases)

## Estrutura do Workflow

O arquivo `.github/workflows/ci.yml` contém dois jobs principais:

```yaml
name: CI

on:
  push:
    branches: [ main ]
    tags:
      - 'v*'
  pull_request:
    branches: [ main ]

jobs:
  test:
    # Roda testes, lint e type checking
  build:
    # Construí e publica artefatos (apenas para tags)
```

### Job `test`

Este job é executado em toda push/pull request para a branch main e faz:

1. **Setup**
   - Checkout do código
   - Configuração do Python 3.12
   - Instalação de dependências (pip, pytest, ruff, mypy)

2. **Testes**
   - Instalação do pacote em modo desenvolvimento (`pip install -e .`)
   - Execução da suíte de testes com pytest
   - Verificação de estilo com ruff
   - Verificação de tipos com mypy

### Job `build`

Este job só é executado quando há push de tags que começam com `v` (ex: v1.0.0, v2.1.3) e faz:

1. **Setup** (semelhante ao job test)
2. **Construção de Distribuições Python**
   - Instalação da ferramenta de build
   - Execução de `python -m build` para criar wheel e sdist
3. **Construção do Pacote Debian**
   - Instalação de ferramentas de empacotamento Debian
   - Execução de `debuild -us -uc` para criar o pacote .deb
4. **Upload de Artefatos**
   - Salva todos os artefatos construídos como artifacts do workflow
5. **Criação de Release GitHub** (opcional)
   - Cria uma release no GitHub associada à tag
   - Anexa todos os artefatos como assets da release
6. **Publicação Opcional**
   - Pode ser estendida para publicar no PyPI, Launchpad PPA, etc.

## Explicação Linha por Linha

### Trigger (`on`)

```yaml
on:
  push:
    branches: [ main ]
    tags:
      - 'v*'
  pull_request:
    branches: [ main ]
```

- Dispara no push para a branch `main`
- Dispara no push de tags que correspondem ao padrão `v*` (qualquer tag começando com "v")
- Dispara em pull requests destinados à branch `main`

### Permissões

```yaml
permissions:
  contents: read
```

- Define permissões mínimas necessárias (somente leitura para o conteúdo do repositório)
- Permissões adicionais são concedidas dinamicamente quando necessário (via `GITHUB_TOKEN` com escopo específico)

### Job `test`

#### Estrutura

```yaml
  test:
    runs-on: ubuntu-latest
    steps:
      # steps aqui
```

- Executa no mais recente ambiente Ubuntu disponível no GitHub
- Contém uma série de etapas sequenciais

#### Etapa por Etapa

1. **Checkout**
   ```yaml
   - uses: actions/checkout@v4
   ```
   - Faz checkout do código do repositório no runner

2. **Setup Python**
   ```yaml
   - name: Set up Python
     uses: actions/setup-python@v5
     with:
       python-version: "3.12"
   ```
   - Instala o Python 3.12 usando a ação oficial
   - Configura o pip e adiciona o Python ao PATH

3. **Instalar Dependências**
   ```yaml
   - name: Install dependencies
     run: |
       python -m pip install --upgrade pip
       pip install pytest ruff mypy
   ```
   - Atualiza o pip para a versão mais recente
   - Instala ferramentas de teste e qualidade: pytest (testes), ruff (linting/formatting), mypy (type checking)

4. **Instalar Pacote em Modo Desenvolvimento**
   ```yaml
   - name: Install package in development mode
     run: |
       pip install -e .
   ```
   - Instala o pacote no modo editable (`-e`) para que alterações no código fonte sejam imediatamente refletidas sem reinstalar

5. **Executar Testes**
   ```yaml
   - name: Run tests
     run: pytest
   ```
   - Executa todo o suite de testes usando pytest

6. **Lint com Ruff**
   ```yaml
   - name: Lint with ruff
     run: ruff check .
   ```
   - Verifica o código contra as regras do ruff (linting)

7. **Type Check com Mypy**
   ```yaml
   - name: Type check with mypy
     run: mypy src
   ```
   - Verifica tipos estaticamente no diretório `src/` usando mypy

### Job `build`

#### Condições de Execução

```yaml
  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref_type == 'tag' && startsWith(github.ref, 'refs/tags/v')
```

- Só roda se o job `test` completar com sucesso (`needs: test`)
- Executa no Ubuntu mais recente
- Só roda para eventos de tag (`github.ref_type == 'tag'`) onde a tag começa com `v` (`startsWith(github.ref, 'refs/tags/v')`)

#### Etapas do Job Build

1. **Checkout**
   ```yaml
   - uses: actions/checkout@v4
   ```
   - Mesmo que no job test

2. **Setup Python**
   ```yaml
   - name: Set up Python
     uses: actions/setup-python@v5
     with:
       python-version: "3.12"
   ```
   - Mesmo que no job test

3. **Instalar Dependências de Build**
   ```yaml
   - name: Install build dependencies
     run: |
       python -m pip install --upgrade pip
       pip install build wheel
   ```
   - Instala `build` (ferramenta oficial de construção de pacotes Python) e `wheel`

4. **Construir Distribuições Python**
   ```yaml
   - name: Build Python distributions
     run: python -m build
   ```
   - Cria tanto a source distribution (.tar.gz) quanto a wheel (.whl) no diretório `dist/`

5. **Instalar Ferramentas de Empacotamento Debian**
   ```yaml
   - name: Install Debian packaging tools
     run: |
       sudo apt-get update
       sudo apt-get install -y debhelper devscripts equivs fakeroot build-essential dh-python
   ```
   - Instala todas as ferramentas necessárias para construir pacotes Debian:
     - `debhelper`: Coleção de programas para ajudar com tarefas de empacotamento
     - `devscripts`: Scripts para desenvolvedores de pacotes Debian
     - `equivs`: Para gerar pacotes de dependência fictícias
     - `fakeroot`: Permite simular privilégios de root para construção de pacotes
     - `build-essential`: Pacote essencial para compilação (gcc, make, etc.)
     - `dh-python`: Ajuda do debhelper para pacotes Python

6. **Construir Pacote Debian**
   ```yaml
   - name: Build Debian package
     run: |
       debuild -us -uc
       # The .deb and .changes files will be in the parent directory
       ls -la ../
   ```
   - Executa `debuild` para construir o pacote fonte e binário
   - `-us`: Não assinar o arquivo .dsc
   - `-uc`: Não assinar o arquivo .changes
   - Lista o conteúdo do diretório pai para verificar os artefatos gerados

7. **Upload de Artefactos**
   ```yaml
   - name: Upload artifacts
     uses: actions/upload-artifact@v4
     with:
       name: dist
       path: |
         dist/*
         ../*.deb
         ../*.changes
         ../*.tar.gz
         ../*.dsc
         ../*.buildinfo
         ../*.changes
   ```
   - Usa a ação `upload-artifact` para salvar todos os artefatos de construção
   - Nome do artefato: `dist`
   - Caminhos incluem:
     - `dist/*`: Wheels e sdists do Python
     - `../*.deb`: Pacote Debian binário
     - `../*.changes`: Arquivo de mudanças do Debian
     - `../*.tar.gz`: Fonte original
     - `../*.dsc`: Descrição da fonte Debian
     - `../*.buildinfo`: Informações de construção
     - `../*.changes`: Arquivo de mudanças (duplicado propositalmente para garantir captura)

8. **Criar Release GitHub**
   ```yaml
   - name: Create GitHub Release
     id: create_release
     uses: softprops/action-gh-release@v2
     with:
       tag_name: ${{ github.ref_name }}
       name: Release ${{ github.ref_name }}
       draft: false
       prerelease: false
     env:
       GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
   ```
   - Usa a ação `softprops/action-gh-release` para criar uma release
   - `tag_name`: Usa o nome da tag que disparou o workflow
   - `name`: Título da release (ex: "Release v1.0.0")
   - `draft: false`: Cria uma release pública (não rascunho)
   - `prerelease: false`: Marca como release estável (defina como `true` para versões de desenvolvimento)
   - `GITHUB_TOKEN`: Token fornecido automaticamente pelo GitHub para autenticação

9. **Upload de Assets da Release**
   ```yaml
   - name: Upload release assets
     uses: softprops/action-gh-release@v2
     with:
       tag_name: ${{ github.ref_name }}
       files: |
         dist/*
         ../*.deb
         ../*.changes
         ../*.tar.gz
         ../*.dsc
         ../*.buildinfo
         ../*.changes
     env:
       GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
   ```
   - Faz upload dos mesmos artefatos como assets da release criada no passo anterior
   - Isso permite que usuários façam download direto dos arquivos da página de release

## Personalizando o Workflow

### Alterando a Versão do Python

Para testar em múltiplas versões do Python, use uma matriz:

```yaml
strategy:
  matrix:
    python-version: ["3.10", "3.11", "3.12"]
```

E então referencie `${{ matrix.python-version }}` na etapa de setup do Python.

### Adicionando Mais Verificações de Qualidade

Você pode adicionar etapas adicionais no job `test`:

```yaml
- name: Security check with bandit
  run: bandit -r src

- name: Check for secrets with trufflehog
  run: trufflehog github --repo=${{ github.repository }}

- name: Check documentation links
  run: doc8 docs/
```

### Personalizando o Build Debian

Para modificar como o pacote Debian é construído, edite o arquivo `debian/rules`. Alguns exemplos comuns:

#### Executando Testes Durante o Build
```yaml
- name: Build Debian package with tests
  run: |
    # Adicione isso a debian/rules:
    # override_dh_auto_test:
    #   pytest
    debuild -us -uc
```

#### Incluindo Documentação
```yaml
- name: Build Debian package with docs
  run: |
    # Adicione isso a debian/rules:
    # override_dh_installdocs:
    #   dh_installdocs
    #   # Construa e instale documentação se aplicável
    debuild -us -uc
```

#### Adicionando Arquivos de Configuração
```yaml
- name: Build Debian package with config
  run: |
    # Crie arquivos de configuração em debian/
    # Modifique debian/rules para instalá-los
    debuild -us -uc
```

### Adicionando Publicação no PyPI

Para publicar automaticamente no PyPI quando uma tag for publicada:

```yaml
- name: Publish to PyPI
  if: startsWith(github.ref, 'refs/tags/v')
  uses: pypa/gh-action-pypi-publish@release/v1
  with:
    user: __token__
    password: ${{ secrets.PYPI_API_TOKEN }}
```

Lembre-se de adicionar o segredo `PYPI_API_TOKEN` nas configurações do repositório.

### Adicionando Publicação no Launchpad PPA

Para publicar no Launchpad PPA:

```yaml
- name: Publish to Launchpad PPA
  if: startsWith(github.ref, 'refs/tags/v')
  run: |
    # Assine o changes file com sua chave GPG
    # Isso requer configurar GPG no runner previamente
    debuild -S -sa
    dput ppa:<seu-username>/<seu-ppa> ../*_source.changes
  env:
    # Você precisará configurar estas como segredos do repositório
    LAUNCHPAD_KEY: ${{ secrets.LAUNCHPAD_KEY }}
    LAUNCHPAD_PASSPHRASE: ${{ secrets.LAUNCHPAD_PASSPHRASE }}
```

### Habilitando Builds para Forks

Por padrão, workflows em forks não têm acesso a segredos. Para permitir isso de forma segura:

```yaml
permissions:
  contents: read
  # Adicione permissões conforme necessário para forks
  # pull-requests: write  # se precisar comentar em PRs
```

### Cache de Dependências

Para acelerar builds, adicione caching:

```yaml
- name: Cache pip
  uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/pyproject.toml') }}
    restore-keys: |
      ${{ runner.os }}-pip-

- name: Cache build dependencies
  uses: actions/cache@v3
  with:
    path: ~/.cache/build
    key: ${{ runner.os }}-build-${{ hashFiles('**/pyproject.toml') }}
    restore-keys: |
      ${{ runner.os }}-build-
```

## Variáveis de Ambiente e Segredos

### Segredos Necessários para Publicação Opcional

Para habilitar a publicação automática, você precisa configurar esses segredos nas configurações do repositório (Settings → Secrets and variables → Actions):

1. `PYPI_API_TOKEN`: Token de API do PyPI (para upload ao PyPI)
2. `LAUNCHPAD_KEY`: Chave GPG privada (ASCII-armored) para assinar uploads ao Launchpad
3. `LAUNCHPAD_PASSPHRASE`: Frase secreta para desbloquear a chave GPG acima
4. Outros tokens conforme necessário (por exemplo, para registros de contêineres)

### Variáveis de Ambiente Disponíveis

Durante a execução do workflow, várias variáveis de ambiente estão disponíveis:

- `GITHUB_REF`: A branch ou tag ref que disparou o workflow
- `GITHUB_REF_NAME`: O nome da branch ou tag (ex: `main` ou `v1.0.0`)
- `GITHUB_SHA`: O commit SHA que disparou o workflow
- `GITHUB_REPOSITORY`: O proprietário e nome do repositório (ex: `usuario/repo`)
- `GITHUB_ACTOR`: O usuário que iniciou o workflow
- `RUNNER_OS`: O sistema operacional do runner (Linux, Windows, macOS)

## Solução de Problemas

### Falhas Comuns e Soluções

#### 1. "Error: Process completed with exit code 127." (comando não encontrado)
- **Causa**: Ferramenta necessária não instalada
- **Solução**: Adicione a instalação da ferramenta no passo apropriado do workflow

#### 2. Falhas no build do Debian relacionadas a dh_python3 ou pybuild
- **Causa**: Versões incompatíveis ou dependências faltando
- **Solução**: 
  - Verifique se `dh-python` está instalado
  - Certifique-se de que o nome no `PYBUILD_NAME` corresponde ao nome real do pacote Python
  - Tente limpar o build: `debuild clean` antes de rebuild

#### 3. Falhas de teste que só acontecem no CI
- **Causa**: Diferenças de ambiente entre local e CI
- **Solução**:
  - Use exatamente a mesma versão do Python
  - Instale as mesmas dependências
  - Considere usar serviços semelhantes (ubuntu-latest é baseado em Ubuntu 22.04 atualmente)

#### 4. Limites de taxa da API do GitHub
- **Causa**: Muitas requisições à API do GitHub em pouco tempo
- **Solução**:
  - O `GITHUB_TOKEN` fornecido tem limites de taxa mais altos que tokens pessoais
  - Evite fazer chamadas desnecessárias à API GitHub nos seus steps

#### 5. Artefatos não aparecendo na release
- **Causa**: Caminhos incorretos ou permissões
- **Solução**:
  - Verifique se os caminhos no step `upload-artifact` e `upload release assets` correspondem aos arquivos realmente gerados
  - Lembre-se que os arquivos .deb ficam no diretório pai, não no diretório de trabalho

### Dicas de Depuração

1. **Habilite logs detalhados**:
   ```yaml
   - name: Build with verbose output
     run: debuild -us -uc -v
   ```

2. **Adicione etapas de diagnóstico**:
   ```yaml
   - name: Debug environment
     run: |
       echo "Python version: $(python --version)"
       echo "PIP version: $(pip --version)"
       echo "Directory contents:"
       ls -la
       echo "GitHub ref: $GITHUB_REF"
   ```

3. **Use o modo de depuração das actions**:
   - Defina `ACTIONS_STEP_DEBUG=true` como secret para logs mais detalhados das actions

4. **Teste localmente com act**:
   - Instale o ato (`brew install act` ou similar)
   - Execute `act` localmente para simular o ambiente do GitHub Actions
   - Útil para testar mudanças no workflow antes de commitar

## Boas Práticas

### 1. Mantenha Jobs Átomicos
- Separe responsabilidades: testes em um job, build e deploy em outros
- Isso permite paralelismo e falhas isoladas

### 2. Use Cache Estrategicamente
- Cache de dependências pip pode economizar significativo tempo
- Seja cuidadoso com invalidação de cache - use hashes de arquivos de lock

### 3. Fail Fast
- Ordene os steps para que falhas sejam detectadas o mais cedo possível
- Por exemplo, rode linters antes de testes extensivos se eles são rápidos

### 4. Seja Explícito com Versões
- Especifique versões exatas para actions quando possível
- `uses: actions/checkout@v4` em vez de `uses: actions/checkout`

### 5. Trate Secrets com Cuidado
- Nunca coloque secrets diretamente no arquivo de workflow
- Use sempre a sintaxe `${{ secrets.NOME_DO_SEGREDO }}`
- Revise regularmente quais secrets são realmente necessários

### 6. Documente seu Workflow
- Adicione comentários explicativos no arquivo YAML
- Mantenha este documento atualizado conforme você faz alterações

### 7. Versione seu Workflow
- Considere manter diferentes versões de workflows para experimentação
- Use branches ou tags para testar mudanças significativas antes de mesclar em main

### 8. Monitore o Uso de Recursos
- Trabalhos muito longos podem consumir minutos do seu plano GitHub
- Otimize steps longos ou considere dividir em múltiplos jobs quando apropriado

## Exemplos de Personalizações Comuns

### Testando em Múltiplas Distribuições Linux
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, ubuntu-22.04, ubuntu-20.04]
    # Adicione outras distros se tiver runners personalizados
```

### Build com Otimizações
```yaml
- name: Build with optimizations
  run: |
    export CFLAGS="-O3 -march=native"
    python -m build --no-isolation
```

### Incluindo SBOM (Software Bill of Materials)
```yaml
- name: Generate SBOM
  run: |
    pip install cyclonedx-bom
    cyclonedx-py -r requirements.txt -o bom.xml
- name: Upload SBOM
  uses: actions/upload-artifact@v3
  with:
    name: sbom
    path: bom.xml
```

### Verificando Licenças de Dependências
```yaml
- name: License check
  run: |
    pip install pip-license
    pip-license --from=mixed --output_format=csv --output=licenses.csv
- name: Upload licenses
  uses: actions/upload-artifact@v3
  with:
    name: licenses
    path: licenses.csv
```

Este guia fornece uma compreensão completa de como o GitHub Actions funciona no Python Deb Factory e como você pode personalizá-lo para atender às necessidades específicas do seu projeto. À medida que seu projeto evolui, você pode continuar aprimorando este pipeline para incluir mais verificações de qualidade, testes de desempenho, verificações de segurança e outros automatismos que melhoram a confiabilidade e a segurança do seu software de entrega.