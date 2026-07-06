# Processo de Release

Este documento explica detalhadamente como criar uma nova release do Python Deb Factory, incluindo versionamento, geração de changelog, construção de artefatos e publicação em diversos repositórios.

## Visão Geral do Processo de Release

O processo de release no Python Deb Factory segue as melhores práticas de engenharia de software e consiste nas seguintes etapas principais:

1. **Planejamento da Release** - Determinar o tipo de versão (major, minor, patch) conforme Semantic Versioning
2. **Preparação do Código** - Garantir que todo o trabalho esteja completo e testado
3. **Atualização de Versão** - Modificar o número da versão no `pyproject.toml` e opcionalmente no `debian/changelog`
4. **Geração de Changelog** - Criar documentação das mudanças desde a última versão
5. **Commit e Tag** - Registrar a versão no repositório Git
6. **Construção de Artefatos** - Gerar pacotes Python (.whl, .tar.gz) e Debian (.deb)
7. **Publicação** - Distribuir os artefatos em diversos repositórios (PyPI, APT, GitHub Releases, etc.)

Este processo pode ser executado manualmente ou automatizado através do GitHub Actions (que lida automaticamente com os passos 6 e 7 quando uma tag é enviada).

## Versionamento Semântico (SemVer)

O Python Deb Factory segue estritamente o [Versionamento Semântico 2.0.0](https://semver.org/):

Dado um número de versão **MAJOR.MINOR.PATCH**, incremente:

1. **MAJOR** quando você fizer mudanças incompatíveis na API,
2. **MINOR** quando você acrescentar funcionalidade de maneira compatível com versões anteriores,
3. **PATCH** quando você fizer correções de bugs compatíveis com versões anteriores.

### Exemplos de Incrementação de Versão

| Versão Atual | Tipo de Mudança       | Nova Versão | Quando Usar                                                                 |
|--------------|-----------------------|-------------|-----------------------------------------------------------------------------|
| 1.2.3        | Correção de bug       | 1.2.4       | Correção de bug que não afeta a API                                         |
| 1.2.3        | Nova funcionalidade   | 1.3.0       | Adição de recurso que não quebra compatibilidade                            |
| 1.2.3        | Mudança quebradora    | 2.0.0       | Alteração que requer adaptação por parte dos usuários                       |
| 0.0.1        | Primeira versão       | 0.1.0       | Após o desenvolvimento inicial estar completo e pronto para primeiros usuários |
| 0.9.0        | Preparação para 1.0   | 1.0.0       | Quando a API é considerada estável e pronta para produção estável           |

### Pré-release e Metadados de Construção

O SemVer também permite rótulos adicionais para pré-release e metadados de construção:

- **Pré-release**: `1.0.0-alpha.1`, `1.0.0-rc.1` (disponível para testes, não estável)
- **Metadados de construção**: `1.0.0+20130313144700`, `1.0.0+exp.sha.5114f85` (ignorado na comparação de versões)

No Python Deb Factory, recomendamos usar apenas versões de release estáveis para produção e eventualmente usar tags como `v1.0.0-rc.1` para release candidates se necessário.

## Fluxo de Trabalho de Release

### Método 1: Usando GitHub Actions (Recomendado)

Este é o método mais simples e recomendado, pois automatiza a maior parte do processo:

1. **Prepare seu branch**
   ```bash
   git checkout main
   git pull
   # Certifique-se de que todo o trabalho está feito e testado
   ```

2. **Atualize o versionamento em `pyproject.toml`**
   ```toml
   # Antes
   version = "0.1.0"
   
   # Depois (por exemplo, para uma versão minor)
   version = "0.2.0"
   ```

3. **Opcional: Atualize o changelog Debian**
   Edite `debian/changelog` para refletir as mudanças:
   ```
   hello-python-deb (0.2.0-1) UNRELEASED; urgency=medium
    
     * Adicionada nova funcionalidade X
     * Corrigido bug crítico Y
     * Melhorada documentação
   
   -- Seu Nome <seu@email.com>  Data, DD MMM YYYY HH:MM:SS +TIMEZONE
   ```

4. **Commit e tag**
   ```bash
   git add pyproject.toml debian/changelog
   git commit -m "Release v0.2.0"
   git tag v0.2.0
   git push origin main --tags
   ```

5. **Deixe o GitHub Apps cuidar do resto**
   - O workflow de CI será disparado pela push da tag
   - Ele executará os testes
   - Construirá os artefatos (wheel, sdist, .deb)
   - Criará uma release no GitHub
   - Anexa todos os artefatos como assets da release
   - (Opcional) Publicará no PyPI, Launchpad, etc. se configurado

### Método 2: Release Manual

Para mais controle ou ambientes especializados, você pode executar o processo manualmente:

#### Etapa 1: Preparação

```bash
# Certifique-se de estar na branch principal e atualizada
git checkout main
git pull origin main

# Verifique se não há mudanças não commitadas
git status

# Execute todos os testes e verificações de qualidade
pytest
ruff check .
mypy src
pre-commit run --all-files
```

#### Etapa 2: Determinar a Nova Versão

Analise as mudanças desde a última release para decidir se é um major, minor ou patch update.

#### Etapa 3: Atualizar o Versionamento

**Atualize `pyproject.toml`:**
```toml
# Before
version = "0.1.0"

# After (example for patch release)
version = "0.1.1"
```

**Opcional: Atualize `debian/changelog`**

Você pode fazer isso manualmente ou usar uma ferramenta como `dch`:
```bash
# Install devscripts if needed
sudo apt-get install devscripts

# Create a new entry
dch -v 0.1.1-1 "Descrição das mudanças"
# Isso abrirá seu editor para você preencher os detalhes
```

O formato esperado é:
```
hello-python-deb (0.1.1-1) UNRELEASED; urgency=medium

  * Descrição detalhada da mudança 1
  * Descrição detalhada da mudança 2
  * Outra mudança importante

 -- Seu Nome <seu@email.com>  Data, DD MMM YYYY HH:MM:SS +TIMEZONE
```

#### Etapa 4: Gere o Changelog (Opcional, mas recomendado)

Se estiver usando `towncrier` para geração automática de changelog:

1. **Instale o towncrier** (se ainda não estiver nas dependências de desenvolvimento):
   ```bash
   pip install towncrier
   ```

2. **Crie fragmentos de mudança** no diretório `changes/`:
   - Crie arquivos como `123.feature.md`, `456.bugfix.md`, etc.
   - O número é o número do issue ou PR (ou qualquer identificador único)
   - A extensão indica o tipo de mudança: `feature`, `bugfix`, `documentation`, `breaking`, etc.

3. **Gere o rascunho do changelog**:
   ```bash
   towncrier build --draft --version 0.1.1
   ```

4. **Revise e aplique**:
   ```bash
   # Se estiver satisfeito com o rascunho, aplique as mudanças
   towncrier build --version 0.1.1
   # Isso criará/atualizará o changelog e removeu os fragmentos usados
   ```

#### Etapa 5: Commit das Alterações

```bash
git add pyproject.toml debian/changelog
# Se estiver usando towncrier e tiver criado/atualizado o changelog:
git changelog
# Ou se adicionou fragmentos:
git add changes/
git commit -m "Prepare release v0.1.1"
```

#### Etapa 6: Crie a Tag

```bash
git tag v0.1.1
git push origin main --tags
```

#### Etapa 7: Construa os Artefatos Manualmente

**Construa os pacotes Python:**
```bash
# Certifique-se de ter as ferramentas de build
python -m pip install --upgrade build

# Construa
python -m build

# Verifique os artefatos
ls -la dist/
# Deve mostrar algo como:
# hello_python_deb-0.1.1-py3-none-any.whl
# hello_python_deb-0.1.1.tar.gz
```

**Construa o pacote Debian:**
```bash
# Instale as dependências de build se necessário
sudo apt-get update
sudo apt-get install -y debhelper devscripts equivs fakeroot build-essential dh-python

# Construa o pacote (assinatura opcional)
debuild -us -uc  # -us: não assinar .dsc, -uc: não assinar .changes

# Verifique os artefatos no diretório pai
ls -la ../
# Deve mostrar algo como:
# hello-python-deb_0.1.1-1_source.changes
# hello-python-deb_0.1.1-1_source.dsc
# hello-python-deb_0.1.1-1.tar.gz
# hello-python-deb_0.1.1-1_all.deb
```

#### Etapa 8: Teste os Artefatos

**Teste o wheel Python:**
```bash
# Em um ambiente limpo (recomendado: venv ou container)
python -m venv test_env
source test_env/bin/activate
pip install dist/hello_python_deb-0.1.1-py3-none-any.whl
hello-python-deb  # deve imprimir "Hello, World!"
deactivate
```

**Teste o sdist:**
```bash
# Em um ambiente limpo
python -m venv test_sdist
source test_sdist/bin/activate
pip install dist/hello_python_deb-0.1.1.tar.gz
hello-python-deb
deactivate
```

**Teste o pacote Debian:**
```bash
# Em uma máquina limpa ou container (recomendado)
sudo dpkg -i ../hello-python-deb_0.1.1-1_all.deb
hello-python-deb  # deve imprimir "Hello, World!"
# Teste remoção limpa
sudo apt-get remove -y hello-python-deb
```

#### Etapa 9: Publique os Artefatos

**Publicar no PyPI (opcional):**
```bash
# Instale twine se necessário
python -m pip install --upgrade twine

# Para o TestPyPI primeiro (recomendado para teste)
python -m twine upload --repository testpypi dist/*

# Para o PyPI real
python -m twine upload dist/*
# Você será solicitado para fornecer nome de usuário e senha ou usar um token API
```

**Publicar no GitHub Releases (manual):**
1. Acesse a página de releases do seu repositório no GitHub
2. Clique em "Draft a new release"
3. Selecione a tag que você criou (v0.1.1)
4. Preencha o título e descrição da release
5. Arraste e solte ou selecione os arquivos para upload:
   - `dist/*.whl`
   - `dist/*.tar.gz`
   - `../*.deb`
   - `../*.tar.gz` (fonte)
   - `../*.dsc`
   - etc.
6. Publique a release

**Publicar em um repositório APT (ex: usando reprepro):**
```bash
# Este é um exemplo simplificado - repositórios APT reais requerem mais configuração
# Instale reprepro se necessário
sudo apt-get install reprepro

# Estrutura básica do repositório
mkdir -p ~/repo/{conf,incoming,logs,db,dists/unstable/main/binary-all,pool/main/h/hello-python-deb}

# Copie o .deb para o pool
cp ../hello-python-deb_0.1.1-1_all.deb ~/repo/pool/main/h/hello-python-deb/

# Atualize o banco de dados do repositório
cd ~/repo
reprepro -Vb . includedeb unstable ../hello-python-deb_0.1.1-1_all.deb

# Agora você pode apontar os clientes APT para este repositório
```

**Publicar no Launchpad PPA (opcional):**
```bash
# Pré-requisitos: você precisa de um PPA configurado no Launchpad
# e sua chave GPG configurada para assinar uploads

# Construa apenas o source package (se ainda não tiver feito)
debuild -S -sa  # -sa inclui o tarball original no upload

# Envie para o PPA
dput ppa:<seu-launchpad-id>/<seu-ppa> ../hello-python-deb_0.1.1-1_source.changes

# O Launchpad vai construir o pacote para várias arquiteturas e distribuições
```

## Usando Towncrier para Changelog Automático

O Python Deb Factory está configurado para funcionar com [Towncrier](https://towncrier.readthedocs.io/) para geração automática de changelog. Aqui está como configurá-lo e usá-lo:

### Configuração Inicial

1. **Adicione o towncrier às dependências de desenvolvimento** (em `pyproject.toml`):
   ```toml
   [project.optional-dependencies]
   dev = [
       "towncrier>=21.0",
       # outras dependências de desenvolvimento...
   ]
   ```

2. **Crie o arquivo de configuração** `.townrak.toml` na raiz do projeto:
   ```toml
   [tool.towncrier]
   package = "hello_python_deb"
   filename = "NEWS"
   directory = "changes"
   ```

3. **Crie o diretório de mudanças**:
   ```bash
   mkdir changes
   ```

### Fluxo de Trabalho com Towncrier

Durante o desenvolvimento, sempre que você fizer uma mudança significativa que deva ser documentada no changelog:

1. **Crie um fragmento de mudança** no diretório `changes/`:
   ```bash
   # Substitua 123 pelo número do issue ou PR
   # Escolha a extensão apropriada para o tipo de mudança
   touch changes/123.feature.md
   touch changes/456.bugfix.md
   touch changes/789.documentation.md
   ```

2. **Escreva uma breve descrição** no arquivo do fragmento:
   ```markdown
   # Em changes/123.feature.md
   Adicionada suporte para processamento paralelo de arquivos de configuração
   ```

3. **Quando estiver pronto para fazer a release**:
   ```bash
   # Primeiro, atualize a versão em pyproject.toml
   
   # Gere um rascunho para revisão
   towncrier build --draft --version <nova-versão>
   
   # Revise o output - ele mostrará como será o changelog
   
   # Se estiver satisfeito, gere o changelog oficialmente
   towncrier build --version <nova-versão>
   
   # Isso irá:
   # 1. Criar/atualizar o arquivo NEWS ou atualizar debian/changelog (dependendo da configuração)
   # 2. Remover os arquivos de fragmentos usados
   ```

### Personalizando o Towncrier

Você pode personalizar o towncrier editando `.townrak.toml`:

**Para gerar changelog no formato tradicional (NEWS):**
```toml
[tool.towncrier]
package = "hello_python_deb"
filename = "NEWS"
directory = "changes"
```

**Para gerar/atualizar diretamente o debian/changelog:**
```toml
[tool.towncrier]
package = "hello_python_deb"
filename = "debian/changelog"
directory = "sections"
# Você precisará criar subdiretórios dentro de sections/ para cada tipo de mudança
```

**Tipos de mudanças personalizados:**
```toml
[tool.towncrier]
directory = "changes"

[[tool.towncrier.type]]
name = "feature"
showcontent = true

[[tool.towncrier.type]]
name = "bugfix"
showcontent = true

[[tool.towncrier.type]]
name = "documentation"
showcontent = true
# Ow showconfig = false hides the section header if there are no fragments of this type
[[tool.towncrier.type]]
name = "removal"
showcontent = false

[[tool.towncrier.type]]
name = "breaking"
showcontent = true
```

## Automatizando Releases com GitHub Actions (Avançado)

Embora o workflow padrão já lide com a construção e publicação de releases quando tags são enviadas, você pode estendê-lo ainda mais:

### Adicionando Geração Automática de Changelog antes da Build

Modifique o job `build` para gerar o changelog automaticamente antes da construção:

```yaml
- name: Generate changelog with towncrier
  if: github.ref_type == 'tag' && startsWith(github.ref, 'refs/tags/v')
  run: |
    # Extrair a versão da tag (remove o prefixo 'v')
    VERSION=${GITHUB_REF#refs/tags/v}
    echo "Generating changelog for version $VERSION"
    towncrier build --version $VERSION
```

### Adicionando Verificação Pré-release

Para garantir que tudo esteja pronto antes de criar a tag:

```yaml
# Adicione um job de validação que roda antes do build
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install towncrier pytest ruff mypy
      
      - name: Check for unreleased changes
        run: |
          # Verificar se há fragmentos de mudança não usados
          if [ -d "changes" ] && [ "$(ls -A changes/)" ]; then
            echo "Found unreleased changes in changes/ directory:"
            ls -la changes/
            exit 1
          fi
          echo "No unreleased changes found - ready for release"
      
      - name: Verify version consistency
        run: |
          # Extrair versão da tag
          TAG_VERSION=${GITHUB_REF#refs/tags/v}
          # Extrair versão do pyproject.toml
          PYPROJECT_VERSION=$(grep -E '^version\s*=' pyproject.toml | cut -d'"' -f2)
          
          if [ "$TAG_VERSION" != "$PYPROJECT_VERSION" ]; then
            echo "Version mismatch: tag v$TAG_VERSION vs pyproject.toml $PYPROJECT_VERSION"
            exit 1
          fi
          echo "Version consistency check passed"
```

### Criando um Workflow de Release Pré-Produção

Para teams que usam um processo de release mais formal com estágios de staging:

```yaml
name: Release Pipeline

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Versão para libérer (ex: 1.2.3)'
        required: true
        default: ''
      environment:
        description: 'Ambiente de destino'
        required: true
        options: [
          staging,
          production
        ]
        default: 'staging'

jobs:
  prepare:
    # ... etapas de validação semelhantes às acima ...
  
  build:
    needs: prepare
    # ... etapas de construção ...
    # Upload de artefatos com nome que inclui o ambiente
  
  deploy-staging:
    needs: build
    if: github.event.inputs.environment == 'staging'
    # ... etapas para deploy em staging ...
  
  deploy-production:
    needs: build
    if: github.event.inputs.environment == 'production'
    # Exige aprovação manual
    environment:
      name: production
      url: https://github.com/${{ github.repository }}/releases
    # ... etapas para deploy em produção ...
```

## Checklist de Release

Use esta lista de verificação para garantir que sua release seja completa e correta:

### Antes da Release
- [ ] Todo o código está commitado na branch `main`
- [ ] Todos os testes passam localmente e no CI
- [ ] Nenhum aviso de linting ou type checking
- [ ] Todos os pré-commit hooks passam
- [ ] Documentação está atualizada (se aplicável)
- [ ] Nenhum código comentado ou debug statements restantes
- [ ] Dependências estão atualizadas e seguras (verifique com `pip-audit` ou similar)
- [ ] Licenças de dependências são compatíveis

### Preparação da Versão
- [ ] Tipo de versão determinado corretamente (major/minor/patch) baseado nas mudanças
- [ ] Versão atualizada em `pyproject.toml`
- [ ] Versão opcionalmente atualizada em `debian/changelog`
- [ ] Changelog gerado/revisado (manualmente ou com towncrier)
- [ ] Todas as mudanças relacionadas à release estão em um único commit
- [ ] Mensagem do commit segue convenção (ex: "Release v1.2.3" ou "chore(release): v1.2.3")

### Tagging
- [ ] Tag criada com formato `vMAJOR.MINOR.PATCH`
- [ ] Tag empuxada para o repositório remoto
- [ ] Tag corresponde exatamente à versão em `pyproject.toml`

### Construção
- [ ] Todos os artefatos construídos com sucesso:
  - Python wheel (.whl)
  - Python source distribution (.tar.gz)
  - Pacote Debian binário (.deb)
  - Fonte Debian (.dsc, .tar.gz, .changes)
- [ ] Artefatos estão livres de erros de linting (verifique com `lintian` para .deb)
- [ ] Versões corretas em todos os artefatos

### Testes Pós-Construção
- [ ] Wheel instalável e funcional em ambiente limpo
- [ ] SDist instalável e funcional em ambiente limpo
- [ ] Pacote Debian instalável, funcional e removível limpo
- [ ] Verifique se o entry point/console script funciona corretamente
- [ ] Verifique se os arquivos são instalados nos locais corretos

### Publicação
- [ ] Artefatos uploadados como assets da release GitHub (se aplicável)
- [ ] Publicado no PyPI/TestPyPI (se configurado e apropriado)
- [ ] Publicado no repositório APT (se aplicável)
- [ ] Publicado no Launchpad PPA (se configurado e apropriado)
- [ ] Release marcada como não-pré-release (versão estável) ou apropiadamente marcada como pré-release

### Comunicação
- [ ] Anúncio da release feito nos canais apropriados (email, Slack, etc.)
- [ ] Documentação atualizada se necessário
- [ ] Changlog publicado e acessível
- [ ] Issues/PRs relacionados marcados como resolvidos
- [ ] Próximos passos para o desenvolvimento comunicados à equipe

## Solução de Problemas de Release

### Problemas Comuns e Soluções

#### 1. "Version mismatch" entre tag e pyproject.toml
- **Sintoma**: O workflow falha na verificação de versão ou você percebe que as versões não batem
- **Solução**: 
  - Atualize a versão em `pyproject.toml` para corresponder exatamente à tag (sem o prefixo 'v')
  - Lembre-se: tag `v1.2.3` deve corresponder à versão `1.2.3` no pyproject.toml

#### 2. Falha no build do Debian com "exit code 1"
- **Sintoma**: O passo `debuild` falha com código de saída não-zero
- **Solução**:
  - Verifique a saída completa para o erro específico
  - Causas comuns:
    - Arquivos não declarados em `debian/*` que deveriam estar inclusos
    - Problemas com `debian/rules` (permissões ausentes, sintaxe incorreta)
    - Dependências de build faltando
    - Problemas no código que só aparecem durante o build do Debian (caminhos diferentes, etc.)
  - Use `debuild -us -uc -v` para output verboso
  - Consulte `man debhelper` e as páginas de man das específicas sequências de debhelper

#### 3. Lintian warnings/errors no pacote Debian
- **Sintoma**: Após `lintian ../package.deb`, você vê avisos ou erros
- **Solução**:
  - Erros são blocantes - você deve corrigi-los
  - Avisos são recomendações - avalie se devem ser tratados
  - Problemas comuns:
    - `wrong-file-owner-uid-or-gid`: geralmente indicam problema com permissões no debian/rules
    - `metadata-file-contains-referencia-nonexistent-usr`: verifica se os arquivos listados em install realmente existem
    - `binary-control-file-contains-timestamp`: geralmente inofensivo, indica que o arquivo de controle tem timestamp
  - Consulte o manual do lintian: `man lintian` ou https://lintian.debian.org/

#### 4. Falha na publicação no PyPI com "400 Client Error"
- **Sintoma**: `twine upload` falha com erro HTTP 400
- **Solução**:
  - Verifique se o token API do PyPI está correto e tem permissões de upload
  - Certifique-se de que a versão que você está tentando enviar ainda não existe no PyPI (o PyPI não permite sobrescrever releases)
  - Verifique se o nome do pacote em `pyproject.toml` está correto
  - Tente primeiro com o TestPyPI para isolar problemas de credenciais

#### 5. Os artefatos não aparecem na release do GitHub
- **Sintoma**: A release é criada, mas nenhum asset está anexado
- **Solução**:
  - Verifique se os caminhos no step `upload release assets` estão corretos
  - Lembre-se que os arquivos .deb são criados no diretório pai, não no diretório de trabalho
  - Certifique-se de que o step de upload de artefatos está rodando com sucesso (verifique os logs)
  - Confirme que o `GITHUB_TOKEN` tem permissão para criar releases e fazer upload de assets (o token padrão geralmente tem)

#### 6. "Nothing to release" com towncrier
- **Sintoma**: `towncrier build --version X.Y.Z` diz que não há mudanças para incluir
- **Solução**:
  - Verifique se você criou os fragmentos de mudança no diretório correto (`changes/` por padrão)
  - Confirme que os fragmentos têm as extensões corretas (`.feature.md`, `.bugfix.md`, etc.)
  - Verifique se você não está tentando gerar um changelog para uma versão que já teve seus fragmentos consumidos
  - Se estiver usando uma configuração personalizada, verifique se o `directory` em `.townrak.toml` aponta para o local correto

### Dicas para Releases Suaves

1. **Use branches de release para versões maiores**
   - Para releases major/minor significativas, considere criar uma branch de release a partir da main
   - Isso permite continuar o desenvolvimento na main enquanto prepara a release

2. **Mantenha um ambiente de build limpo**
   - Considere usar containers Docker ou VMs limpas para builds finais
   - Isso ajuda a garantir que as dependências sejam exatamente as esperadas

3. **Automatize o máximo possível**
   - Quanto mais etapas do processo de release forem automatizadas, menos chance de erro humano
   - Considere criar scripts ou Makefiles para encapsular etapas complexas

4. **Documente exceções**
   - Se você precisar fazer algo fora do padrão para uma release específica, documente claramente o motivo
   - Isso ajuda a manter a consistência e a entender decisões passadas

5. **Pratique em um fork ou branch de teste**
   - Antes de fazer uma release importante no repositório principal, teste o processo em um fork ou branch de teste
   - Isso é especialmente valioso ao tentar novas técnicas de automação ou ferramentas

6. **Mantenha registros**
   - Mantenha um log (mesmo que simples) das releases feitas, incluindo:
     - Data e hora
     - Versão
     - Quem fez a release
     - Quaisquer problemas encontrados e como foram resolvidos
     - Link para a release/tag
   - Isso é inestimável para auditoria e solução de problemas

## Recursos Adicionais

### Sobre Versionamento Semântico
- Site oficial: https://semver.org/
- Especificação completa: https://semver.org/spec/v2.0.0.html
- Guia prático: https://docs.npmjs.com/about-semantic-versioning

### Sobre Empacotamento Debian
- Debian Policy Manual: https://www.debian.org/doc/debian-policy/
- Maintainer's Guide: https://www.debian.org/doc/maint-guide/
- Debian Python Policy: https://wiki.debian.org/Python/Teams/Policy
- Debhelper man pages: `man debhelper`, `man dh_*`

### Sobre GitHub Actions e Releases
- GitHub Actions documentation: https://docs.github.com/en/actions
- Creating releases: https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository
- Working with the REST API for releases: https://docs.github.com/en/rest/release/releases

### Sobre Towncrier
- Documentação oficial: https://towncrier.readthedocs.io/
- Exemplos de uso: https://github.com/twisted/twisted/tree/trunk/twisted/_release
- Integração com pyproject.toml: https://github.com/twisted/twisted/blob/trunk/twisted/_release/pyproject.toml

Este guia fornece uma abordagem abrangente para gerenciar releases no Python Deb Factory. Seguindo esses processos e práticas recomendadas, você estará bem equipado para entregar versões de alta qualidade, consistentes e confiáveis do seu software.