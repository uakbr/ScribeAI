import coremltools as ct
import torch
from transformers import WhisperForConditionalGeneration

# Load the pre-trained Whisper model
model = WhisperForConditionalGeneration.from_pretrained("openai/whisper-small")
model.eval()

# Trace the model with sample input
sample_input = {'input_features': torch.zeros(1, 80, 3000)}
traced_model = torch.jit.trace(model, sample_input)

# Convert to Core ML model
mlmodel = ct.convert(
    traced_model,
    inputs=[ct.TensorType(shape=sample_input['input_features'].shape)],
    minimum_deployment_target=ct.target.iOS17,
)

# Save the Core ML model
mlmodel.save("WhisperModel.mlmodel")

# Compile the model to .mlmodelc format
import coremltools
compiled_model_path = coremltools.utils._compile_coremltool("WhisperModel.mlmodel")
print(f"Compiled model saved at {compiled_model_path}") 