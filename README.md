# 🤖 Flutter Chatbot App (Gemini API + SQLite)

A **Flutter-based chatbot application** powered by **Google Gemini API** with offline storage using **SQLite (sqflite)**.  
This app allows users to create multiple conversations, save messages locally, and interact with the Gemini model in real time.  

---

## ✨ Features
- 🔹 **Google Gemini AI Integration** – Generate responses with Gemini API  
- 🔹 **Multiple Conversations** – Create, manage, and delete conversations  
- 🔹 **Local Storage with SQLite** – Save and retrieve chat history  
- 🔹 **Shimmer Loading Effect** – Beautiful UI while waiting for responses  
- 🔹 **Offline Support** – Stores data locally, even without internet  
- 🔹 **Modern UI** – Clean design with material components  

---

## 📸 Screenshots
*(Add your screenshots here)*

---

## 🛠️ Tech Stack
- **Frontend**: Flutter (Dart)  
- **Database**: SQLite (`sqflite` package)  
- **API**: Google Gemini Generative Language API  
- **Other Packages**:  
  - `http` – API requests  
  - `sqflite` – Local database  
  - `intl` – Date formatting  
  - `shimmer` – Loading effect  
  - `internet_connection_checker_plus` – Internet status  
  - `gpt_markdown` – Render AI responses  

---

## 🚀 Getting Started

### 1. Clone the repo
```bash
git clone https://github.com/Hetbhanderi/ChatBot.git
cd ChatBot
````

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Add your Gemini API key

Inside `Chatscreen.dart`, replace the placeholder with your API key:

```dart
const apiKey = "YOUR_API_KEY_HERE";
```

You can generate an API key from [Google AI Studio](https://makersuite.google.com/app/apikey).

### 4. Run the app

```bash
flutter run
```

---

## 📂 Project Structure

```
lib/
├── HomeScreen.dart      # Conversation list screen
├── ChatScreen.dart      # Chat UI with Gemini integration
├── db_helper.dart       # SQLite database helper
└── main.dart            # Entry point
```

---

## ⚡ Usage

1. Open the app
2. Create a new conversation
3. Start chatting with the Gemini AI
4. Messages are saved locally, so you can reopen chats anytime
5. Delete conversations when no longer needed

---

## 📦 Dependencies

See full list in [`pubspec.yaml`](pubspec.yaml).

---

## 🙌 Acknowledgements

* [Flutter](https://flutter.dev/)
* [Google Gemini API](https://ai.google.dev/)
* [Sqflite](https://pub.dev/packages/sqflite)

---

### 👨‍💻 Author

Developed by **Het Bhanderi**
📧 Feel free to connect and contribute!
