import torch
import whisper
import coremltools as ct
import argparse
import os
import json

def convert_whisper_to_coreml(model_size="base", output_path=None):
    print(f"Loading Whisper {model_size} model...")
    model = whisper.load_model(model_size)
    
    # Set model to evaluation mode
    model.eval()
    
    # Prepare sample input
    sample_input = torch.zeros((1, 80, 3000))  # Example dimensions for ~30 seconds of audio
    
    # Trace the model
    print("Tracing model...")
    traced_model = torch.jit.trace(model.encoder, sample_input)
    
    # Convert to CoreML
    print("Converting to CoreML format...")
    mlmodel = ct.convert(
        traced_model,
        inputs=[
            ct.TensorType(
                name="audio_input",
                shape=sample_input.shape,
                dtype=np.float32
            )
        ],
        outputs=[
            ct.TensorType(
                name="encoder_output",
                dtype=np.float32
            )
        ],
        minimum_deployment_target=ct.target.iOS17,
        compute_precision=ct.precision.FLOAT16,  # Use half precision for better performance
        convert_to="mlprogram"  # Use the newer ML Program format
    )
    
    # Set metadata
    mlmodel.author = "WhisperTranscriptionApp"
    mlmodel.license = "MIT"
    mlmodel.short_description = "Whisper speech recognition model converted to CoreML"
    mlmodel.version = "1.0"
    
    # Save the model
    if output_path is None:
        output_path = f"WhisperModel_{model_size}.mlmodel"
    
    print(f"Saving model to {output_path}...")
    mlmodel.save(output_path)
    
    # Export vocabulary
    export_vocabulary(model, os.path.dirname(output_path))
    
    print("Conversion and vocabulary export complete!")

def export_vocabulary(model, output_path):
    """Export the model's vocabulary to a JSON file."""
    vocab = model.tokenizer.encoder
    
    # Save vocabulary
    vocab_path = os.path.join(output_path, "whisper_tokens.json")
    with open(vocab_path, "w", encoding="utf-8") as f:
        json.dump(vocab, f, ensure_ascii=False, indent=2)
    
    print(f"Vocabulary exported to {vocab_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert Whisper model to CoreML format")
    parser.add_argument("--model-size", default="base", choices=["tiny", "base", "small", "medium", "large"],
                      help="Whisper model size to convert")
    parser.add_argument("--output", help="Output path for the CoreML model")
    
    args = parser.parse_args()
    convert_whisper_to_coreml(args.model_size, args.output)