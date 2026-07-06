# Empacotamento Debian

Este documento explica detalhadamente como o empacotamento Debian funciona no Python Deb Factory, incluindo a estrutura do diretório `debian/`, o propósito de cada arquivo e como personalizá-lo para sua aplicação.

## Visão Geral

O empacotamento Debian permite que sua aplicação Python seja distribuída e instalada via `apt` em sistemas Debian e Ubuntu. O pacote resultante é um arquivo `.deb` que contém todos os arquivos necessários e metadados para instalação, atualização e remoção segura.

O diretório `debian/` contém os arquivos de controle que definem como o pacote será construído e se comportará no sistema.

## Estrutura do Diretório `debian/`

```
debian/
├── changelog    # Histórico de versões do pacote
├── control      # Metadados doas - Meta-information
├── compat       # Nível de compatibilidade do debhelper
├── rules        # Script de construção (Makefile)
└── source/
    └── format   # Formato do pacote fonte
```

## Arquivo por Arquivo

### 1. `debian/changelog`

Este arquivo contém o histórico de mudanças do pacote no formato específico do Debian.

**Formato:**
```
nome-do-pacote (versão-revisão) distribuição; urgência=nível

  * descrição da mudança
  * outra mudança
  
 -- Nome do Mantenedor <email@exemplo.com>  Data
```

**Exemplo do nosso template:**
```
hello-python-deb (0.1.0-1) UNRELEASED; urgency=low

  * Initial release.

 -- Alan Santos <alan@example.com>  Sat, 04 Jul 2026 23:05:37 -0300
```

**Campos explicados:**
- `nome-do-pacote`: Deve corresponder exatamente ao nome no campo `Package:` do arquivo `control`
- `versão-revisão`: Formato `versão_upstream-revisão_debian` (ex: 0.1.0-1)
  - `versão_upstream`: Versão do seu software (do `pyproject.toml`)
  - `revisão_debian`: Número de revisão do pacote Debian (começa em 1 e aumenta a cada novo build do mesmo versão upstream)
- `distribuição`: Geralmente `unstable`, `testing` ou um nome de distribuição específico; `UNRELEASED` indica que ainda não foi lançado
- `urgência`: `low`, `medium`, `high`, `emergency` ou `critical`
- Entradas de mudanças: Cada linha começando com `* ` descreve uma mudança
- Rodapé: Nome, email e data/hora no formato RFC 2822

**Como usar:**
- Atualize este arquivo toda vez que fizer um novo release
- Aumente a versão upstream quando mudar o `pyproject.toml`
- Mantenha ou aumente a revisão Debian ao recompilar o mesmo versão upstream
- Ferramentas como `dch` ou `git-changelog` podem ajudar a gerenciar este arquivo

### 2. `debian/controle`

Este é o arquivo mais importante - define os metadados do pacote.

**Exemplo do nosso template:**
```
Source: hello-python-deb
Section: utils
Priority: optional
Maintainer: Alan Santos <alan@example.com>
Build-Depends: debhelper-compat (= 13), dh-python, python3-setuptools, python3-all
Standards-Version: 4.6.0
Homepage: https://github.com/alan-n7x/python-deb-factory
Vcs-Git: https://github.com/alan-n7x/python-deb-factory.git
Vcs-Browser: https://github.com/alan-n7x/python-deb-factory

Package: hello-python-deb
Architecture: all
Depends: ${python3:Depends}, ${misc:Depends}
Description: Simple Hello World Python application
 A minimal Python command-line program that prints "Hello, World!".
 This package serves as a template for professional Python applications
 distributed as Debian packages.
```

**Seções explicadas:**

#### Seção Fonte (primeiro parágrafo)
- `Source`: Nome do pacote fonte (deve corresponder ao nome do diretório source)
- `Section`: Categoria do pacote (veja `/usr/share/doc/debian-policy/ch-controlfields.html#s-fsscience` para lista completa)
  - Valores comuns: `utils`, `admin`, `devel`, `libs`, `python`, `web`, etc.
- `Priority`: Importância do sistema (`required`, `important`, `standard`, `optional`, `extra`)
- `Maintainer`: Seu nome e email
- `Build-Depends`: Pacotes necessários para construir o pacote (não para executá-lo)
  - `debhelper-compat (= 13)`: Ferramentas auxiliares de construção
  - `dh-python`: Ajuda para pacotes Python
  - `python3-setuptools`: Necessário para construir pacotes Python
  - `python3-all`: Garantia de que todas as versões suportadas do Python 3 estão disponíveis
- `Standards-Version`: Versão do Debian Policy Manual que este pacote segue
- `Homepage`: URL do projeto
- `Vcs-Git` / `Vcs-Browser`: Localização do repositório de código fonte

#### Seção Binário (segundo parágrafo)
- `Package`: Nome do pacote binário que será instalado (o que os usuários veem com `apt install`)
- `Architecture`: `all` para pacotes independentes de arquitetura (puro Python), `amd64`, `arm64`, etc. para específicos
- `Depends`: Dependências de tempo de execução
  - `${python3:Depends}`: Variável substituída pelo debhelper com as dependências Python corretas
  - `${misc:Depends}`: Variável para dependências diversas calculadas pelo debhelper
- `Description`: Descrição do pacote (máximo 80 caracteres na primeira linha, seguido por uma descrição estendida)

### 3. `debian/compat`

Apenas contém um número indicando o nível de compatibilidade do debhelper a ser usado.

**Valor no nosso template:** `13`

Isso indica que estamos usando o nível de compatibilidade 13 do debhelper, que é o mais recente estável e fornece comportamento padronizado e melhorias recentes.

### 4. `debian/rules`

Este é o script de construção - um Makefile que defini como o pacote é construído.

**Nosso template:**
```makefile
#!/usr/bin/make -f

export PYBUILD_NAME=hello-python-deb

%:
	dh $@ --with python3 --buildsystem=pybuild
```

**Explicação:**
- `#!/usr/bin/make -f`: Indica que este arquivo deve ser executado pelo make
- `export PYBUILD_NAME=hello-python-deb`: Define o nome do pacote Python para o sistema pybuild
- `%:`: Alvo padrão que corresponde a qualquer alvo de debian/rules (build, clean, install, etc.)
- `dh $@ --with python3 --buildsystem=pybuild`: Delegará a maior parte do trabalho para o debhelper com suporte a Python

**Como funciona o dh (debhelper):**
O comando `dh` executa uma sequência de comandos debhelper padrão para o alvo especificado (`$@`). Por exemplo:
- Para `build`: executa `dh_auto_configure`, `dh_auto_build`, etc.
- Para `install`: executa `dh_auto_install`, seguida de outras etapas de instalação
- Para `binary`: constrói o pacote .deb real

O `--with python3` indica que estamos construindo um pacote Python 3.
O `--buildsystem=pybuild` usa o sistema de construção pybuild do debhelper, que sabe como construir e instalar pacotes Python usando setuptools, flit, ou poetry.

### 5. `debian/source/format`

Indica o formato do pacote fonte.

**Valor no nosso template:** `3.0 (quilt)`

Isso significa:
- Versão 3 do formato de pacote fonte
- Usa o sistema quilt para gerenciar patches upstream
- Formato moderno e recomendado

## Como o Processo de Build Funciona

Quando você executa `debuild` ou `dpkg-buildpackage`, happens the following:

1. **Fonte Preparation**
   - `dpkg-source` cria o pacote fonte (.dsc + .orig.tar.gz + possibly .debian.tar.xz)
   - Inclui o diretório `debian/` e o código fonte (excluindo arquivos ignore por .gitignore, etc.)

2. **Compilação/Construção**
   - `debian/rules build` é chamado
   - O delega para `dh_build` que por sua vez chama:
     - `dh_auto_configure` (geralmente nada para Python com pybuild)
     - `dh_auto_build` (roda `python setup.py build` ou equivalente via pybuild)

3. **Instalação**
   - `debian/rules install` é chamado
   - `dh_auto_install` instala o pacote em um diretório temporário (`debian/tmp`)
   - Para Python com pybuild, isso instala em `debian/tmp/usr/lib/python3/dist-packages/`

4. **Empacotamento**
   - Os arquivos em `debian/tmp` são empacotados em `data.tar.gz`
   - Arquivos de controle são gerados a partir de `debian/control`
   - O arquivo .deb final é criado contendo:
     - `debian-binary` (formato do deb)
     - `control.tar.gz` (scripts de instalação/remoção e controle)
     - `data.tar.gz` (os arquivos reais a instalar)

## Personalizando para Sua Aplicação

### Alterações Básicas Necessárias

1. **Em `debian/control`:**
   - Altere `Source:` e `Package:` para o nome do seu pacote
   - Atualize `Maintainer:` com seu nome e email
   - Modifique `Section:` se necessário (ex: para uma aplicação web, use `web`)
   - Atualize `Homepage:` e `Vcs-` URLs
   - Atualize a `Description:` para descrever sua aplicação
   - Ajuste `Build-Depends` se precisar de dependências adicionais de build
   - O `Depends:` geralmente está correto como `${python3:Depends}, ${misc:Depends}` para aplicações Python puras

2. **Em `debian/changelog`:**
   - Altere o nome do pacote no cabeçalho
   - Atualize a entrada inicial com sua descrição
   - Mantenha o formato correto

3. **Em `debian/rules`:**
   - Altere `PYBUILD_NAME` para o nome do seu pacote Python
   - Adicione opções adicionais ao `dh` se necessário (ex: `--with=sphinxdoc` se construindo documentação)

### Personalizações Avançadas

#### Adicionando Arquivos de Configuração
Se sua aplicação precisar de arquivos de configuração em `/etc/`:
1. Crie os arquivos em `debian/` (ex: `debian/seupacote.conf`)
2. Modifique `debian/rules` para instalá-los:
   ```makefile
   override_dh_installdocs:
   	dh_installdocs
   	install -Dm644 debian/seupacote.conf debian/seupacote/etc/seupacote/seupacote.conf
   ```

#### Adicionando Serviços Systemd
Para aplicações que são daemons:
1. Crie o arquivo de serviço em `debian/seupacote.service`
2. Adicione ao `debian/rules`:
   ```makefile
   override_dh_systemd_start:
   	dh_systemd_start --name=seupacote
   ```

#### Tratando Dependências Específicas
Se sua aplicação precisa de dependências não-Python:
1. Adicione-as a `Build-Depends` em `debian/control` (para build)
2. Adicione-as a `Depends` em `debian/control` (para runtime)
3. Exemplos comuns: `libssl-dev`, `pkg-config`, bibliotecas específicas

#### Executando Testes durante o Build
Para executar testes como parte do build:
```makefile
override_dh_auto_test:
	# Seu comando de teste aqui, por exemplo:
	pytest
```

### Buenas Práticas para Empacotamento Debian

1. **Mantenha o `changelog` atualizado** - É uma exigência da política Debian
2. **Use versões upstream corretas** - A versão no changelog deve corresponder (ou ser menor que) a versão no pyproject.toml
3. **Teste em ambientes limpos** - Use `pbuilder`, `sbuild` ou contêineres LXC/Docker para testes limpos
4. **Siga a Política Debian** - Consulte https://www.debian.org/doc/debian-policy/ para diretrizes completas
5. **Considere usar helpers modernos** - `dh-python` e `pybuild` simplificam muito o empacotamento de Python
6. **Seja específico com dependências** - Embora `${python3:Depends}` funcione bem, às vezes você precisa especificar versões mínimas
7. **Documente alterações** - Cada mudança significativa deve ter uma entrada no changelog

### Testando Seu Pacote Debian

#### Teste Básico
```bash
# Instale as dependências
sudo apt-get install lintian

# Construa
debuild -us -uc

# Verifique com lintian (verificador de política Debian)
lintian ../seupacote_0.1.0_all.deb

# Instale em um ambiente de teste (recomendado: use uma VM ou container)
sudo dpkg -i ../seupacote_0.1.0_all.deb
seupacote  # teste o comando
sudo apt-get remove seupacote  # teste a remoção limpa
```

#### Testes Avançados
- Use `pbuilder` ou `sbuild` para builds em ambiente limpo
- Teste em múltiplas distribuições (Ubuntu LTS, Debian stable, etc.)
- Verifique atualizações e downgrades limpos
- Teste com diferentes versões do Python se aplicável

## Recursos Adicionais

- **Debian Policy Manual**: https://www.debian.org/doc/debian-policy/
- **Debian Maintainer's Guide**: https://www.debian.org/doc/maint-guide/
- **Debian Python Policy**: https://wiki.debian.org/Python/Teams/Policy
- **dh-pyton man page**: `man dh_python3`
- **pybuild man page**: `man pybuild`
- **debhelper man pages**: `man dh_*` (various)
- **Lintian**: https://www.debian.org/doc/manuals/lintian-user/

Este guia fornece uma base sólida para entender e personalizar o empacotamento Debian no Python Deb Factory. À medida que você se torna mais familiarizado com os conceitos, pode explorar personalizações mais avançadas para atender às necessidades específicas da sua aplicação.