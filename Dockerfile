# Use a RunPod base image with PyTorch and CUDA
# Check RunPod documentation for recommended images if available.
# This one is an example, might need adjustment based on specific model CUDA requirements.
FROM pytorch/pytorch:2.1.0-cuda11.8-cudnn8-devel
#FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/opt/conda/bin/python3.10:$PYTHONPATH
ENV MODEL_BASE=/app/weights
ENV CPU_OFFLOAD=1
ENV RUNPOD_STREAM_OUTPUT=true
ENV DEBIAN_FRONTEND=noninteractive
ENV HF_HOME=/app/huggingface_cache
# To prevent issues with matplotlib in headless env
ENV MPLCONFIGDIR=/tmp/matplotlib

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file
COPY requirements.txt .

# Install Python dependencies
# Consider --no-cache-dir to reduce image size
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    # Install FastAPI and Uvicorn
    pip install --no-cache-dir fastapi uvicorn && \
    # Specifically install flash-attention as per original README, if not covered by requirements.txt
    # Check if ninja is needed as a build dependency for flash-attention
    pip install --no-cache-dir ninja && \
    pip install --no-cache-dir git+https://github.com/Dao-AILab/flash-attention.git@v2.6.3 && \
    pip install --no-cache-dir huggingface_hub[cli]

# Download models during build time (Optional, but recommended for serverless)
# This assumes the weights/README.md describes how to get them and they can be placed in ./weights
# For now, we'll skip this in the Dockerfile and assume weights are mounted or pre-baked by user.
# If you have a script to download weights, it could be called here:
# RUN chmod +x ./scripts/download_weights.sh && ./scripts/download_weights.sh
RUN huggingface-cli download tencent/HunyuanVideo-Avatar --local-dir ./weights/


# Copy the rest of the application code
COPY . .

# Expose the port FastAPI will listen on
EXPOSE 8000

# Command to run the FastAPI application
CMD ["uvicorn", "handler:app", "--host", "0.0.0.0", "--port", "8000"]
