# hello-python-deb

Um aplicativo simples **Hello, World!** em Python empacotado como um pacote Debian, pronto para distribuição profissional via `pip`, `apt` e GitHub Releases.

Este repositório serve como um **template reutilizável** para criar aplicações Python profissionais que podem ser distribuídas como:

- `pip install hello-python-deb`
- `apt install hello-python-deb`
- GitHub Releases (arquivo `.deb` independente e tarball de fonte)

## Sumário

- [Recursos](#recursos)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Começando](#começando)
  - [Pré-requisitos](#pré-requisitos)
  - [Instalação](#instalação)
  - [Uso](#uso)
- [Desenvolvimento](#desenvolvimento)
  - [Executando Testes](#executando-testes)
  - [Qualidade de Código](#qualidade-de-código)
  - [Construindo o Pacote Debian](#construindo-o-pacote-debian)
  - [Liberando Versões](#liberando-versões)
- [CI/CD](#ci-cd)
- [Detalhes de Empacotamento](#detalhes-de-empacotamento)
  - [Empacotamento Python (PyPI)](#empacotamento-python-pypi)
  - [Empacotamento Debian (Deb/Ubuntu)](#empacotamento-debian-debubuntu)
  - [PPA do Launchpad (Opcional)](#ppa-do-launchpad-opcional)
  - [GitHub Releases (Opcional)](#github-releases-opcional)
- [Versionamento & Changelog](#versionamento--changelog)
- [Licença](#licença)

## Recursos

- ✅ Compatível com Python 3.12+
- ✅ Empacotamento moderno com `pyproject.toml` (setuptools)
- ✅ Layout `src` para estrutura de importação limpa
- ✅ Ponto de entrada de script de console (`hello-python-deb`)
- ✅ Suite completa de testes com `pytest`
- ✅ Qualidade de código com `ruff` (linting & formatação)
- ✅ Verificação estática de tipos com `mypy`
- ✅ Hooks pré-commit para qualidade consistente de código
- ✅ CI/CD com GitHub Actions para construção, teste e publicação
- ✅ Versionamento Semântico
- ✅ Geração automatizada de changelog (via `towncrier` – opcional)
- ✅ Empacotamento Debian pronto (`debian/` pasta)
- ✅ Publicação opcional no Launchpad
- ✅ Modelos prontos para daemons, ferramentas de linha de comando, bibliotecas ou serviços em background

## Estrutura do Projeto

```
hello-python-deb/
├── src/
│   └── hello_python_deb/
│       ├── __init__.py
│       └── __main__.py          # Ponto de entrada: imprime "Hello, World!"
├── tests/
│   └── test_basic.py
├── docs/
│   └── (arquivos de documentação)
├── scripts/
│   └─ (scripts auxiliares)
├── debian/
│   ├── control
│   ├── changelog
│   ├── compat
│   ├── rules
│   └── source/format
├── .github/
│   └── workflows/
│       └── ci.yml               # Pipeline de CI/CD
├── .pre-commit-config.yaml      # Hooks pré-commit
├── pyproject.toml               # Configuração do projeto
├── README.md
└── LICENSE
```

## Começando

### Pré-requisitos

- Python ≥ 3.12
- `pip` (mais recente)
- `git`
- Para construir pacotes Debian: `debhelper`, `devscripts`, `equivs`, `fakeroot`, `build-essential`
- (Opcional) Para publicar no Launchpad: `dput`, `gnupg`
- (Opcional) Para GitHub Releases: `gh` CLI (opcional, as actions cuidam disso)

### Instalação

#### Do PyPI (via pip)

```bash
pip install hello-python-deb
```

#### Do APT (após deploy em um repositório Debian)

```bash
sudo apt update
sudo apt install hello-python-deb
```

#### Da Fonte (desenvolvimento)

```bash
git clone https://github.com/alan-n7x/python-deb-factory.git
cd python-deb-factory
python -m pip install -e .
```

### Uso

Após a instalação, execute o comando:

```bash
hello-python-deb
# Saída: Hello, World!
```

Você também pode invocar via módulo Python:

```bash
python -m hello_python_deb
```

## Desenvolvimento

### Executando Testes

```bash
pytest
```

### Qualidade de Código

```bash
# Linting & auto-fix
ruff check .
ruff check --fix .

# Verificação de tipos
mypy src
```

### Hooks Pré-commit

Instale os hooks uma vez:

```bash
pre-commit install
```

Eles serão executados automaticamente em cada commit.

### Construindo o Pacote Debian

Localmente (para testes):

```bash
# Instale dependências de construção
sudo apt-get update
sudo apt-get install -y debhelper devscripts equivs fakeroot build-essential

# Construa os pacotes fonte e binário
debuild -us -uc
# ou, usando dpkg-buildpackage
dpkg-buildpackage -us -uc
```

O arquivo `.deb` resultante será colocado no diretório pai.

### Liberando Versões

#### Versionamento

Seguimos o [Versionamento Semântico](https://semver.org/). Atualize a versão em `pyproject.toml` (e opcionalmente em `debian/changelog`).

#### Changelog

Recomendamos usar o [towncrier](https://towncrier.readthedocs.io/) para geração automática de fragmentos de changelog.  
Crie uma configuração `.townrak.toml` e adicione fragmentos de alteração em `changes/`.

#### Publicando no PyPI

```bash
# Construa a distribuição
python -m build

# Envie para o TestPyPI primeiro (opcional)
python -m twine upload --repository testpypi dist/*

# Envie para o PyPI real
python -m twine upload dist/*
```

#### Publicando no PPA do Launchpad (Opcional)

1. Assine sua chave GPG e faça upload para o Launchpad.
2. Construa o pacote fonte:
   ```bash
   debuild -S
   ```
3. Faça upload para seu PPA:
   ```bash
   dput ppa:<lp-username>/<ppa-name> ../hello-python-deb_*.changes
   ```

#### Publicando no GitHub Releases (Opcional)

O workflow de CI (veja abaixo) pode criar automaticamente um lançamento do GitHub e anexar o `.deb` construído e o tarball de fonte quando uma nova tag for enviada.

## CI/CD

O repositório inclui um workflow de GitHub Actions (`.github/workflows/ci.yml`) que:

1. **Testa** o código no Ubuntu mais recente com Python 3.12.
2. **Faz lint** com `ruff` e verifica tipos com `mypy`.
3. **Constrói** a roda Python e a distribuição de fonte.
4. **Constrói** o pacote Debian (`.deb`) usando `dpkg-buildpackage`.
5. **(Opcional)** Publica no PyPI quando uma tag do GitHub que corresponda a `v*` é enviada.
6. **(Opcional)** Publica no GitHub Releases (anexa `.deb` e tarball) em tags.
7. **(Opcional)** Publica no PPA do Launchpad (requer segredos configurados).

Segredos necessários para pipelines opcionais:
- `PYPI_API_TOKEN` – Token de API do PyPI
- `LAUNCHPAD_KEY` – Chave GPG privada (ASCII-armored) para o Launchpad
- `LAUNCHPAD_PASSPHRASE` – Frase secreta para a chave GPG
- `GH_TOKEN` – Token do GitHub com escopo `repo` (fornecido automaticamente como `GITHUB_TOKEN`)

## Detalhes de Empacotamento

### Empacotamento Python (PyPI)

- Definido em `pyproject.toml` usando [setuptools](https://setuptools.pypa.io/).
- O script de console `hello-python-deb` aponta para `hello_python_deb.__main__:main`.
- Rodas e sdist são gerados via `python -m build`.

### Empacotamento Debian (Deb/Ubuntu)

O diretório `debian/` contém os arquivos mínimos necessários para construir um pacote Debian:

- `control` – Metadados do pacote, dependências, seção, prioridade.
- `changelog` – Changelog Debian (gerenciado via `towncrier` ou edições manuais).
- `compat` – Nível de compatibilidade do debhelper (atualmente `13`).
- `rules` – Makefile simples usando `dh` (debhelper) para construção.
- `source/format` – Indica formato de fonte `3.0 (quilt)`.

O `.deb` resultante instala o pacote Python em `/usr/lib/python3/dist-packages` e instala o executável `hello-python-deb` em `/usr/bin`.

### PPA do Launchpad (Opcional)

O Launchpad constrói o pacote a partir da fonte enviada (`.changes`). Certifique-se de ter um upload assinado com GPG válido.

### GitHub Releases (Opcional)

O workflow de CI envia o `.deb` gerado e o tarball de fonte (`hello-python-deb_<version>.tar.gz`) como assets para a release associada a uma tag git.

## Versionamento & Changelog

- **Versão**: Especificada em `pyproject.toml` (e espelhada em `debian/changelog`).
- **Changelog**: Mantenha um diretório `changes/` com fragmentos nomeados `<issue>.<tipo>.md` (ex: `12.feature.md`, `13.bugfix.md`). Execute `towncrier build --draft` para visualizar, `towncrier release --version 0.2.0` para aplicar.

## Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

*Boa codificação! 🎉