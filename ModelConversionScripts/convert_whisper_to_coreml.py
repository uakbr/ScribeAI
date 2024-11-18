import torch
import whisper
import coremltools as ct

def convert_whisper_to_coreml():
    # Load the pre-trained Whisper model
    model = whisper.load_model("base")

    # Prepare a dummy input for tracing
    audio_input = torch.zeros(1, 80, 3000)  # Adjust dimensions as needed

    # Trace the model
    traced_model = torch.jit.trace(model, audio_input)

    # Convert to Core ML format
    mlmodel = ct.convert(
        traced_model,
        inputs=[ct.TensorType(name="audio_input", shape=audio_input.shape)],
        compute_units=ct.ComputeUnit.ALL,
        convert_to="mlprogram",
        minimum_deployment_target=ct.target.iOS17,
    )

    # Save the model
    mlmodel.save("WhisperModel.mlpackage")

    print("Conversion to Core ML format completed successfully.")

if __name__ == "__main__":
    convert_whisper_to_coreml() 