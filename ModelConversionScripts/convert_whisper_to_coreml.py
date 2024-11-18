import torch
import whisper
import coremltools as ct
import numpy as np

def convert_whisper_to_coreml(model_size="base"):
    # Load Whisper model
    model = whisper.load_model(model_size)
    model.eval()
    
    # Prepare sample input
    sample_rate = 16000
    duration = 30  # seconds
    sample_input = torch.zeros(1, duration * sample_rate)
    
    # Trace model
    traced_model = torch.jit.trace(model, sample_input)
    
    # Convert to CoreML
    mlmodel = ct.convert(
        traced_model,
        inputs=[
            ct.TensorType(
                name="audioInput",
                shape=(1, duration * sample_rate),
                dtype=np.float32
            )
        ],
        outputs=[
            ct.TensorType(
                name="transcription",
                dtype=str
            )
        ],
        minimum_deployment_target=ct.target.iOS17,
        compute_precision=ct.precision.FLOAT16,  # Use half precision for better performance
    )
    
    # Save model
    mlmodel.save("WhisperModel.mlmodel")

if __name__ == "__main__":
    convert_whisper_to_coreml() 