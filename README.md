# 🎓 JupyterLab + OpenVINO — AI Locale per la Didattica

Gli studenti aprono il browser sul loro iPad e trovano un ambiente Python completo,
con notebook precaricati per imparare a usare un LLM che gira localmente.

---

## 🗂️ Struttura del progetto

```
informatica-ai/
├── Dockerfile               ← Ambiente Docker: JupyterLab + OpenVINO
├── docker-compose.yml       ← Avvio con un comando, configurazione CPU e GPU
├── requirements.txt         ← Dipendenze Python Jupyter
├── requirements-ai.txt      ← Dipendenze Python AI
├── models/                  ← Modelli AI (creata automaticamente, non in git)
├── prof/                    ← Notebook del professore
│   ├── 00_setup_modello.ipynb        ← Scarica il modello (solo prof)
│   ├── 01_primo_prompt.ipynb         ← Introduzione: prompt e risposta
│   ├── 02_chatbot_interattivo.ipynb  ← Chatbot con UI grafica
│   ├── 03_esercizi.ipynb             ← Esercizi con TODO
│   └── 04_dispositivi_gpu_npu.ipynb  ← Test dei dispositivi per fare inferenza su GPU
└── studenti/                ← Cartella di lavoro degli studenti
```

---

## 🖥️ Servizi disponibili

| Servizio | Porta | Accesso |
|---|---|---|
| `jupyterlab-wsl-prof` | **8889** | Prof: accesso completo a `prof/`, `studenti/`, `models/` |
| `jupyterlab-wsl-studenti` | **8888** | Studenti: `prof/` e `models/` in sola lettura, `studenti/` in scrittura |
| `jupyterlab-gpu-base` | **8888** | Prof con GPU Intel — avviare con `--profile gpu` |

I servizi prof e studenti possono girare **contemporaneamente** su porte diverse.

---

## 🚀 Avvio (lato prof)

### 1. Prima volta — costruisci l'immagine Docker

```bash
docker compose build
```

### 2. Scarica il modello AI (una volta sola)

Avvia il servizio del professore, apri JupyterLab ed esegui il notebook `prof/00_setup_modello`:

```bash
docker compose up jupyterlab-wsl-prof -d
```

Poi apri `http://localhost:8889`, esegui tutte le celle di `prof/00_setup_modello.ipynb`
e aspetta il completamento del download (~600 MB).

### 3. Avvia i servizi per la lezione

```bash
# Solo studenti (porta 8889)
docker compose up jupyterlab-wsl-studenti -d

# Oppure entrambi contemporaneamente (prof su 8888, studenti su 8889)
docker compose up jupyterlab-wsl-prof jupyterlab-wsl-studenti -d
```

### 4. Comunica agli studenti l'indirizzo

```
http://<TUO-IP>:8888
```

Esempio: `http://192.168.1.42:8888`

Gli studenti aprono Safari sul loro iPad, digitano quell'indirizzo e sono dentro!

---

## 🛑 Fine lezione

```bash
docker compose down
```

---

## 📱 Guida per gli studenti (da stampare o proiettare)

> 1. Apri **Safari** sul tuo iPad
> 2. Digita nella barra degli indirizzi: **http://192.168.1.XX:8888**
>    (il professore ti dirà l'IP corretto)
> 3. Apri la cartella **prof/**
> 4. Inizia dal notebook **01_primo_prompt.ipynb**
> 5. Usa il menu **Run → Run All Cells** per eseguire tutto
> 6. Salva i tuoi esperimenti nella cartella **studenti/**

---

## ⚙️ Configurazione avanzata

### Aggiungere una password di accesso

Modifica `Dockerfile`, sostituisci la riga `CMD` con:
```dockerfile
CMD ["jupyter", "lab", "--no-browser", "--ip=0.0.0.0", "--port=8888", \
     "--allow-root", "--PasswordIdentityProvider.hashed_password=''"]
```
Per generare l'hash: `jupyter notebook password`

### Usare la GPU Intel (WSL2)

```bash
docker compose --profile gpu up -d
```

Pre-requisito su Windows: driver Intel Graphics >= 30.0.100.9955
([scarica qui](https://www.intel.com/content/www/us/en/download/19344/))

> **Nota**: la NPU Intel **non è supportata** in WSL2 (limite del kernel WSL).

### Usare un modello più capace

In `docker-compose.yml`, cambia la variabile:

```yaml
environment:
  - MODEL_PATH=/workspace/models/phi2-ov
```

E nel notebook 00, cambia `HF_MODEL_ID`:

```python
HF_MODEL_ID = "OpenVINO/phi-2-int8-ov"  # ~1.5 GB, più capace
```

Modelli disponibili (già in formato OpenVINO su HuggingFace):

| Modello | Dimensione | RAM necessaria | Note |
|---------|-----------|---------------|------|
| `TinyLlama-1.1B-Chat-v1.0-int8-ov` | ~600 MB | 2 GB | ✅ Consigliato per la didattica |
| `phi-2-int8-ov` | ~1.5 GB | 4 GB | Più capace |
| `mistral-7b-instruct-v0.1-int4-ov` | ~4 GB | 8 GB | Ottima qualità |
| `llama-2-7b-chat-hf-int4-ov` | ~4 GB | 8 GB | Meta LLaMA 2 |
