FROM python:3.10-slim
WORKDIR /app

COPY requirements.txt .

# Install PyTorch (CPU version to keep image size manageable) requirements
RUN pip install --no-cache-dir torch --extra-index-url https://download.pytorch.org/whl/cpu
RUN pip install --no-cache-dir -r requirements.txt

# 3. PRE-DOWNLOAD SPECIFIC NLP MODELS 
# This prevents the 3GB+ Qwen model and the DistilBART model from downloading at runtime
RUN python -c "from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, AutoModelForCausalLM; \
    AutoTokenizer.from_pretrained('sshleifer/distilbart-cnn-12-6'); \
    AutoModelForSeq2SeqLM.from_pretrained('sshleifer/distilbart-cnn-12-6'); \
    AutoTokenizer.from_pretrained('Qwen/Qwen2.5-1.5B-Instruct'); \
    AutoModelForCausalLM.from_pretrained('Qwen/Qwen2.5-1.5B-Instruct')"

COPY app.py .
COPY arxiv_processed.csv .

EXPOSE 7860

CMD ["python", "app.py"]