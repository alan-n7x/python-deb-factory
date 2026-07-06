# Processo de Build

Este documento explica detalhadamente como o processo de construção (build) funciona no Python Deb Factory, tanto localmente quanto no CI/CD.

## Visão Geral do Processo de Build

O Python Deb Factory suporta dois tipos principais de builds:
1. **Builds Python** (para distribuição via pip) - Wheels e Source Distributions
2. **Builds Debian** (para distribuição via apt) - Pacotes .deb

Ambos podem ser executados localmente para teste ou automaticamente no CI/CD.

## Builds Python (PyPI)

### Componentes Envolvidos
- `pyproject.toml` - Configuração do build
- `setup.py` (implícito) - Gerado pelo setuptools baseado em pyproject.toml
- `src/` - Código fonte da aplicação
- `python -m build` - Ferramenta oficial de construção

### Etapas do Build Python

1. **Preparação**
   - O `build` lê o `pyproject.toml` para obter metadados
   - Valida a estrutura do projeto (espera encontrar código em `src/`)

2. **Construção da Source Distribution (sdist)**
   - Cria um arquivo `.tar.gz` contendo:
     - Código fonte (`src/`)
     - Configuração (`pyproject.toml`)
     - Documentação e licenças
     - Outros arquivos especificados na configuração

3. **Construção da Wheel**
   - Cria um arquivo `.whl` (distribuição binária)
   - Contém o código já organizado para instalação direta
   - Específico para a versão do Python e plataforma, mas nosso projeto é "pure Python" e plataforma independente

### Como Construir Localmente

```bash
# Instale a ferramenta de build se necessário
python -m pip install --upgrade build

# Execute o build
python -m build

# Os artefatos aparecerão em ./dist/
# - hello_python_deb-0.1.0-py3-none-any.whl (wheel)
# - hello_python_deb-0.1.0.tar.gz (source distribution)
```

### No CI/CD (GitHub Actions)

No workflow `.github/workflows/ci.yml`, o build Python acontece no job `build`:

```yaml
- name: Build Python distributions
  run: python -m build
```

## Builds Debian

### Componentes Envolvidos
- Diretório `debian/` - Contém todos os arquivos de controle
- `debian/control` - Metadados do pacote
- `debian/changelog` - Histórico de versões
- `debian/compat` - Nível do debhelper
- `debian/rules` - Script de construção
- `debuild` ou `dpkg-buildpackage` - Ferramentas de construção

### Estrutura do Pacote Debian

Quando construído, o pacote .deb contém:
- `data.tar.gz` - Arquivos reais a serem instalados:
  - `/usr/lib/python3/dist-packages/seupacote/` - Código Python
  - `/usr/bin/seupacote` - Executável (se definido como console script)
- `control.tar.gz` - Metadados de instalação/remocção
- `debian-binary` - Informação do formato do deb

### Etapas do Build Debian

1. **Preparação do Fonte**
   - O `dpkg-source` cria um pacote fonte (.dsc + .tar.gz) baseado no conteúdo do diretório
   - Respeita o formato definido em `debian/source/format` (3.0 quilt)

2. **Compilação**
   - O `debian/rules` é executado (geralmente delega para `dh` - debhelper)
   - No nosso caso, usa o sistema `pybuild` para construir o componente Python

3. **Empacotamento**
   - Os arquivos são colocados nos locais corretos no pacote
   - Arquivos de controle são gerados a partir de `debian/control`
   - Scripts de instalação/remoção são criados se necessário

### Como Construir Localmente

```bash
# Instale dependências de build
sudo apt-get update
sudo apt-get install -y debhelper devscripts equivs fakeroot build-essential dh-python

# Construa o pacote (assinatura opcional)
debuild -us -uc  # -us: não assinar .dsc, -uc: não assinar .changes
# ou
dpkg-buildpackage -us -uc

# Pacotes resultantes aparecerão no diretório pai:
# - hesperium_0.1.0_source.changelog
# - hesperium_0.1.0_source.dsc
# - hesperium_0.1.0.tar.gz (fonte)
# - hesperium_0.1.0_all.deb (binário, arquitetura all pois é pure Python)
```

### No CI/CD (GitHub Actions)

No workflow `.github/workflows/ci.yml`, o build Debian acontece no job `build`:

```yaml
- name: Install Debian packaging tools
  run: |
    sudo apt-get update
    sudo apt-get install -y debhelper devscripts equivs fakeroot build-essential dh-python

- name: Build Debian package
  run: |
    debuild -us -uc
```

## Variáveis de Build e Personalização

### Variáveis nodebian/rules

Nosso `debian/rules` é simples:
```makefile
#!/usr/bin/make -f

export PYBUILD_NAME=hello-python-deb

%:
	dh $@ --with python3 --buildsystem=pybuild
```

O `PYBUILD_NAME` define o nome do pacote Python para o sistema pybuild do debhelper.

Para personalizar:
- Altere `PYBUILD_NAME` para o nome do seu pacote
- Adicione opções ao `dh` se precisar de comportamento especial de build
- Substitua inteiramente o arquivo `debian/rules` se precisar de lógica personalizada

### Variáveis de Build do Python

Variáveis que afetam o build Python podem ser definidas em:
- `pyproject.toml` (metadados, dependências)
- Variáveis de ambiente (como `CFLAGS`, embora menos comuns para pure Python)

## Verificando o Build

### Verificando o Wheel/SDist

```bash
# Liste o conteúdo
tar -tzf dist/seupacote-0.1.0.tar.gz
unzip -l dist/seupacote-0.1.0-py3-none-any.whl

# Teste a instalação
pip install dist/seupacote-0.1.0-py3-none-any.whl
seupacote  # ou python -m seupacote
```

### Verificando o Pacote Debian

```bash
# Liste o conteúdo
dpkg -c ../seupacote_0.1.0_all.deb

# Mostre informações
dpkg -I ../seupacote_0.1.0_all.deb

# Teste a instalação (em um ambiente limpo idealmente)
sudo dpkg -i ../seupacote_0.1.0_all.deb
seupacote  # deve funcionar
```

## Integração entre Builds Python e Debian

Um ponto importante: ambos os builds usam o mesmo código fonte em `src/`, mas têm fluxos diferentes:

1. **Build Python**: Empacota diretamente o código fonte para instalação via pip
2. **Build Debian**: 
   - Primeiro cria um source package (.dsc + .tar.gz)
   - Depois constrói o binary package (.deb) a partir do source
   - O build do componente Python dentro do .deb usa o mesmo código, mas segue as convenções do Debian (instala em `/usr/lib/python3/dist-packages/`)

## Troubleshooting Comum

### Problemas com o Build Python
- **"No module named setuptools"**: Certifique-se de ter setuptools instalado
- **"Invalid requirement"**: Verifique a sintaxe das dependências no pyproject.toml
- **"Files not found"**: Certifique-se de que os arquivos estão no lugar certo (especialmente se não estiver usando layout src)

### Problemas com o Build Debian
- **"dpkg-source error"**: Geralmente indica arquivos não commitados ou inesperados no diretório fonte
- **"dh_python3: command not found"**: Instale o pacote dh-python
- **"pybuild pybuild:327: error: stumbled upon unexpected files in ... "**: Limpe o diretório de build ou verifique o .gitignore

### Dicas
- Sempre faça o build em um diretório limpo (considere usar `git clean -fdx` com cuidado)
- Para builds Debian, o diretório deve estar limpo (sem arquivos não rastreados pelo git que devam ser incluídos)
- Use `debuild clean` ou `dpkg-buildpackage -clean` para limpar entre builds