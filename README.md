# 📱 DocScan - Flutter Document Scanner & Text Editor  

DocScan is an **open-source Flutter app** that lets you **scan documents, recognize text, and edit it instantly** using **Google ML Kit Text Recognition**.  
You can take a photo of any document, extract its text, and edit or copy it — all within one simple and modern UI.  

---

## ✨ Features  

✅ **Document Scanning** – Capture clear document images using CameraX  
✅ **Text Recognition (OCR)** – Extract text from scanned images with Google ML Kit  
✅ **Text Editing** – Built-in editor to modify recognized text directly in the app  
✅ **Copy to Clipboard** – Quickly copy recognized text for reuse anywhere  
✅ **Clean Material UI** – Minimal, modern, and responsive Flutter design  
✅ **Offline Functionality** – Works fully offline after installation  

---

## 🧠 Tech Stack  

- **Flutter** (Dart)  
- **Google ML Kit (Text Recognition)**  
- **CameraX**  
- **Material Design Components**  
- **Clipboard API** for easy text copy  

---

## 📸 Screenshots  

<img width="8000" height="5500" alt="doc" src="https://github.com/user-attachments/assets/5a7c9c42-7223-4be2-bcc3-285523c93345" />



---

## 🏗️ How It Works  

1. Open the app and capture a document using your camera.  
2. The app automatically detects and extracts text using ML Kit OCR.  
3. View the recognized text on screen.  
4. Edit or copy the text easily.  

---

## 🏗️ Folder Structure

```plaintext
lib/
│
├── main.dart
├── screens/
│   ├── onboarding_screen.dart
│   ├── text_recognizer_screen.dart
│   ├── editor_screen.dart
│
└── widgets/
    └── custom_button.dart

```
---

## 🚀 Getting Started  

### 1. Clone the repository  
```bash
git clone https://github.com/aamirali65/docscanner
cd docscan_flutter
```
### 2. Install dependencies
```bash
flutter pub get
```
### 3. Run the app
```bash
flutter run
```

## ⚙️ Permissions Required

- **Camera Permission** – To scan and capture documents  
- **Storage Permission** – To access images for text recognition  

---

## 🧩 How It Works

1. Launch the app and capture or pick a document image.  
2. ML Kit automatically extracts all readable text from the image.  
3. View and edit the recognized text inside the built-in editor.  
4. Copy or save the text for later use.  

---

## 💡 Why I Built This

I built **DocScan** to explore how on-device machine learning can be integrated with Flutter.  
It’s a simple but powerful example of combining OCR, document scanning, and text editing in one seamless experience.  
The goal was to create a tool that feels lightweight, works offline, and performs fast even on low-end devices.

## 🪪 License

This project is licensed under the **MIT License**.  
You’re free to use, modify, and share it with proper attribution.
