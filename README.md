
# WhisperTranscriptionApp

## Overview

WhisperTranscriptionApp is an advanced iOS 17+ application that enables on-device audio transcription using OpenAI's Whisper model, transformed into CoreML format for local processing. Designed for private and efficient transcription, this app offers continuous audio recording that operates in the background, displaying active status in iOS 17’s Dynamic Island and Live Activities. All transcription processing and storage are handled locally on the device to ensure a seamless, offline experience.

## Key Features

- **On-Device Real-Time Transcription**: Utilizing OpenAI's Whisper model, the app transcribes audio without requiring an internet connection.
- **Continuous Background Recording**: Users can record audio while the app is minimized or the device is locked.
- **Dynamic Island & Live Activities**: iOS 17's Dynamic Island and Live Activities are leveraged to show ongoing recording status and transcription progress.
- **Local Data Management**: Recordings and transcriptions are stored locally, allowing users to manage files directly within the app.

## Technical Requirements

- **Platform**: iOS 17+
- **Programming Language**: Swift
- **CoreML**: Pre-converted Whisper model in CoreML format

## Directory Structure

- **WhisperTranscriptionApp.xcodeproj**: Xcode project file for the app setup.
- **WhisperTranscriptionApp/**: Main application code directory.
  - **AppDelegate.swift**: Manages app lifecycle.
  - **SceneDelegate.swift**: Manages window configurations and background handling.
  - **Models/WhisperModel.mlmodel**: The CoreML-converted Whisper model.
  - **Models/WhisperModelManager.swift**: Singleton manager for loading and interfacing with the Whisper model.
  - **Views/**: Contains UI components for audio recording, transcription display, and management.
  - **ViewModels/**: Handles core logic for recording, transcription, and Dynamic Island updates.
  - **Managers/**: Classes for managing local storage of transcriptions, audio files, and Live Activities.
  - **Utilities/ErrorAlertManager.swift**: Helper for handling and displaying error messages.

## Prerequisites

- **Xcode 15** or later
- **Swift**: Latest stable version compatible with iOS 17+
- **Whisper Model**: Pre-converted to CoreML format using the provided Python script

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/username/WhisperTranscriptionApp.git
   ```
2. Open `WhisperTranscriptionApp.xcodeproj` in Xcode.
3. Enable necessary permissions under `Info.plist`.

## Development Phases

The following 10 phases provide a highly detailed guide to assist developers in building each component of the app.

---
