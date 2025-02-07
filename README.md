# ilab-aula

## Documentações e Referencias

Não sei se esta documentação que trata a cli do projeto ainda é valida, por ser um projeto novo e com constante mudança.
A documentação é baseada na versao 0.18.ob1 porem hoje estamos na versao 0.23.1

### Documentação Oficial
https://docs.instructlab.ai/

## Como Usar

Crie um arquivo .env na raiz do projeto com o seu token do HuggingFace

```
HF_TOKEN=seu_token
HUGGING_FACE_HUB_TOKEN=seu_token
```

Para buildar a imagem docker podemos usar

```
docker compose build
```

O projeto precisa de conexão ao container entao logo apos executamos o container com

```
docker compose up -d
```

E entramos no terminal do container para usarmos o Ilab

```
docker attach instructlab
```

## Configurações Inicias do Instructlab

Iniciando a configuração

```
ilab config init
```

Mesmo tendo placas nvidia eu não recomendo definir perfis como nvidia no setup, pois ele pode apresentar erro por falta de memoria, ja que a otimização para placas nvidia tem em sua lista, somente placas de servidores e linha profissional, com muito mais memoria de Vram.

Entao defina todas as opções como padrão pressionando entender para o caminho da taxonomy e o caminho do modelpatch

depois os perfis voce define como *NO PROFILE*

## Verificando Integridade dos Dados de Treinamento

```
ilab taxonomy diff
```

## Baixando Modelos LLM Padrões

```
ilab model download
```

## Baixando Modelo Granite Para Treinamento

Voce pode usar outros modelos para treinamento mas neste exemplo vou usar o comando padrão

```
ilab model download --repository instructlab/granite-7b-lab
```

Um exemplo seria usar o Llama 3.2 1B de parametros, o comando seria algo como

```
ilab model download --repository meta-llama/Llama-3.2-1B
```

## Gerando Dados Sinteticos

```
ilab data generate --sdg-scale-factor 3
```

Voce pode usar uma escala maior ou ate mesmo definir outros modelos para criar os dados sinteticos.

## Treinando o Modelo

Neste exemplo eu estou treinando o Llama e não o granite porem voce deve usar o modelo que tiver baixado e deve usar os dados sinteticos gerados pelo seu ambiente, que claro, sera outro caminho para o *jsonl*

```
ilab model train --num-epochs 1 --device cuda --pipeline accelerated --model-path /root/.cache/instructlab/models/meta-llama/Llama-3.2-1B --data-path /root/.local/share/instructlab/datasets/knowledge_train_msgs_2025-01-22T14_20_14.jsonl
```

## Volumes Docker

No docker-compose.yml que eu criei o volumes docker fica na raiz do projeto , voce tera acesso ao seu modelo treinado em

> /volumes/checkpoints/

# WebUI Para Testar o Modelo

Como meus teste com o comando 
```
ilab chat model
```

não funcionaram pois não tive tempo de compatibilizar o vllm com meu ambiente eu rodei o modelo usando um outro projeto WEBUI

```
docker compose -f webui-docker-compose.yml up --force-recreate
```

voce pode acessar 

> http://localhost:7860

para poder testar o modelo treinado, não se esqueça de alterar no arquivo

> webui-docker-compose.yml

sample que define o modelo dentro da pasta *volumes*

caso voce nao altere no webui-docker-compose.yml voce pode simplesmente mudar nas configurações do painel do webui.

***

# Teste Pendentes

Para personalizar o ambiente do InstructLab e substituir os modelos padrão usados nos três cenários principais de geração de dados (Granite, Merlinite e Mistral) por modelos de sua preferência, você pode seguir este processo:

### 1. **Identifique os modelos no ambiente de configuração**
Os modelos padrão para os três cenários são configurados no arquivo de ambiente gerado pelo `ilab config init`. Por padrão, os caminhos dos modelos são armazenados no arquivo de configuração em `~/.config/instructlab/config.yaml`.

Você pode verificar o conteúdo desse arquivo com:
```bash
cat ~/.config/instructlab/config.yaml
```

### 2. **Edite o arquivo de configuração**
Abra o arquivo de configuração para edição:
```bash
nano ~/.config/instructlab/config.yaml
```

Dentro do arquivo, localize as entradas que especificam os modelos padrão. Elas devem se parecer com algo assim:
```yaml
models:
  default_chat_model: "/caminho/para/granite-7b-lab-gguf"
  teacher_simple_model: "/caminho/para/merlinite-7b-lab-gguf"
  teacher_full_model: "/caminho/para/mistral-7b-instruct-v0.2-gguf"
```

Substitua os caminhos pelos modelos que você deseja usar. Por exemplo:
```yaml
models:
  default_chat_model: "/caminho/para/seu/modelo-chat"
  teacher_simple_model: "/caminho/para/seu/modelo-simple"
  teacher_full_model: "/caminho/para/seu/modelo-full"
```

### 3. **Baixe e configure seus novos modelos**
- Certifique-se de que os modelos estão no formato compatível (GGUF ou safetensor).
- Baixe os modelos desejados do Hugging Face ou de outra fonte usando o comando:
  ```bash
  ilab model download --repository <seu-repositorio-huggingface> --filename <arquivo_modelo>
  ```
- Se necessário, converta para o formato GGUF:
  ```bash
  ilab model convert --model-dir /caminho/para/o/modelo --model-name <nome_novo_modelo>
  ```

### 4. **Valide os novos modelos**
Certifique-se de que os novos modelos estão produzindo os resultados esperados ao gerar dados ou executar tarefas de chat. Para validação:
- Use o comando `ilab data list` para inspecionar os dados gerados.
- Realize testes com `ilab model chat`.

***
Sim, você está absolutamente correto! Depois de atualizar o arquivo de configuração (`config.yaml`) com os caminhos dos modelos que deseja usar, não será necessário especificar o `--model` path nos comandos de geração de dados ou chat. O InstructLab usará os modelos definidos no arquivo de configuração como padrão.

### Como funciona
Quando o `ilab` é inicializado, ele lê o arquivo de configuração e utiliza os modelos especificados nas entradas relevantes. Por exemplo:

```yaml
models:
  default_chat_model: "/caminho/para/seu/modelo-chat"
  teacher_simple_model: "/caminho/para/seu/modelo-simple"
  teacher_full_model: "/caminho/para/seu/modelo-full"
```

Ao rodar comandos como:
```bash
ilab data generate --sdg-scale-factor 3
```
ou
```bash
ilab model chat
```
O InstructLab usará automaticamente os modelos configurados, sem necessidade de especificar o caminho explicitamente.

### Recomendações adicionais
1. **Teste o ambiente**:
   Após atualizar o arquivo de configuração, execute um comando simples, como listar os modelos configurados:
   ```bash
   ilab config show
   ```
   Isso exibirá os modelos configurados e verificará se as alterações foram aplicadas corretamente.

2. **Valide o comportamento**:
   Gere um pequeno conjunto de dados sintéticos para confirmar que os novos modelos estão funcionando como esperado:
   ```bash
   ilab data generate --sdg-scale-factor 1
   ```

3. **Manutenção futura**:
   Se precisar alternar entre modelos diferentes, basta atualizar o arquivo de configuração. Isso centraliza o gerenciamento dos modelos e simplifica o uso.

Se houver algo mais que precise ajustar ou verificar, estou à disposição para ajudar!