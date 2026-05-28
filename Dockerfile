# ─────────────────────────────────────────────────────────────
#  JupyterLab + OpenVINO GenAI  —  ottimizzato per WSL2
#
#  Dispositivi supportati su WSL2:
#    CPU  → sempre disponibile
#    GPU  → Intel iGPU/Arc via /dev/dxg  (bridge DirectX WSL)
#    NPU  → NON supportato in WSL2 (limite del kernel WSL)
#
#  Pre-requisito su Windows:
#    Driver Intel Graphics >= 30.0.100.9955
#    https://www.intel.com/content/www/us/en/download/19344/
# ─────────────────────────────────────────────────────────────

FROM openvino/ubuntu24_runtime:2026.1.0

USER root

# ── Dipendenze di sistema ──────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl wget \
    # OpenCL runtime — necessario per GPU in WSL2
    # Su WSL2 il bridge /dev/dxg è fornito da Windows;
    # qui installiamo solo il layer ICD lato Linux
    ocl-icd-libopencl1 \
    intel-opencl-icd \
    && rm -rf /var/lib/apt/lists/*

# Variabile OpenCL richiesta da OpenVINO per trovare il driver ICD
ENV OCL_ICD_VENDORS=/etc/OpenCL/vendors

# Configurazione directory
RUN mkdir -p /workspace/models /workspace/prof /workspace/studenti
WORKDIR /workspace

# ── Dipendenze Python ──────────────────────────────────────
COPY requirements.txt .
COPY requirements-ai.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir -r requirements-ai.txt

# Cleanup
RUN rm requirements.txt
RUN rm requirements-ai.txt

# ── Configurazione JupyterLab ──────────────────────────────
RUN jupyter lab --generate-config && \
    echo "c.ServerApp.ip = '0.0.0.0'" >> /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.open_browser = False" >> /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_root = True" >> /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.root_dir = '/workspace'" >> /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.token = ''" >> /root/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.password = ''" >> /root/.jupyter/jupyter_lab_config.py

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip=0.0.0.0", "--port=8888", "--allow-root"]
