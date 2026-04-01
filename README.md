# 🚀 Smart Download Manager Plus

[![pub version](https://img.shields.io/pub/v/smart_download_manager_plus.svg)](https://pub.dev/packages/smart_download_manager_plus)
[![likes](https://img.shields.io/pub/likes/smart_download_manager_plus)](https://pub.dev/packages/smart_download_manager_plus/score)
[![popularity](https://img.shields.io/pub/popularity/smart_download_manager_plus)](https://pub.dev/packages/smart_download_manager_plus/score)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A powerful, resumable, and queue-based download manager for Flutter — built for production apps.

---

## ✨ Highlights

* ⚡ Parallel downloads with queue system
* 🔄 Resume & pause downloads
* 🔁 Smart retry mechanism
* 📊 Real-time progress & speed tracking
* 📁 Save directly to Downloads (Android MediaStore)
* 🍎 iOS support (Documents directory)
* 🔔 Built-in notifications
* 📦 Batch downloads
* 💾 Persistent tasks (auto restore)
* 🚀 Open file automatically after download

---

## 🤔 Why Smart Download Manager Plus?

* Built for **real production apps**, not just demos
* Supports **resume downloads** (Range requests)
* Handles **Android scoped storage (MediaStore)** correctly
* Clean and simple API
* Designed for **performance and reliability**

---

## 🎥 Demo

<p align="center">
  <img src="screenshots/demo.gif" width="250"/>
</p>

---

## 📸 Preview

<p align="center">
  <img src="https://raw.githubusercontent.com/MuhammadAli224/smart_download_manager_plus/main/screenshots/Screenshot_1775037209.png" width="200"/>
  <img src="https://raw.githubusercontent.com/MuhammadAli224/smart_download_manager_plus/main/screenshots/Screenshot_1775037214.png" width="200"/>
  <img src="https://raw.githubusercontent.com/MuhammadAli224/smart_download_manager_plus/main/screenshots/Screenshot_1775037220.png" width="200"/>
  <img src="https://raw.githubusercontent.com/MuhammadAli224/smart_download_manager_plus/main/screenshots/Screenshot_1775037231.png" width="200"/>
</p>

---

## 🚀 Installation

```yaml
dependencies:
  smart_download_manager_plus: latest
```

---

## ⚡ Quick Start

### Initialize

```dart
await DownloadNotificationService.init();
await DownloadNotificationService.requestPermission();
```

---

### Create Controller

```dart
final controller = DownloadController(
  maxConcurrent: 2,
);
```

---

### Download a File

```dart
final task = controller.addTask(
  'https://example.com/file.pdf',
  subFolder: 'MyApp',
  openAfterDownload: true,
);

await controller.startTask(task);
```

---

## 📥 Usage Examples

### 📄 Download PDF

```dart
controller.addTask(
  'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
  openAfterDownload: true,
);
```

---

### 🖼 Download Image

```dart
controller.addTask(
  'https://www.w3.org/Icons/w3c_home.png',
);
```

---

### 📦 Batch Download

```dart
controller.addBatch([
  'https://example.com/file1.pdf',
  'https://example.com/file2.png',
]);
```

---

### ⏸ Pause / Resume

```dart
controller.pauseTask(task);
controller.resumeTask(task);
```

---

### ❌ Cancel Download

```dart
await controller.cancelTask(task);
```

---

## 🚀 Open File After Download

Automatically open files when completed:

```dart
controller.addTask(
  url,
  openAfterDownload: true,
);
```

---

## 📂 File Storage

### Android

* Uses **MediaStore API**
* Saves to **Downloads/**
* No storage permission required

### iOS

* Saves to **Application Documents Directory**

---

## 📡 Listen to Progress

```dart
controller.onTaskUpdated.listen((task) {
  print(task.progress);
});
```

---

## ⚙️ Configuration

| Option            | Description                  |
| ----------------- | ---------------------------- |
| maxConcurrent     | Number of parallel downloads |
| priority          | Download priority            |
| headers           | Custom request headers       |
| retryDelay        | Delay between retries        |
| maxRetries        | Retry attempts               |
| subFolder         | Save inside subfolder        |
| openAfterDownload | Auto open file               |

---

## 🆚 Comparison

| Feature            | Smart Download Manager Plus | Other Packages |
| ------------------ | --------------------------- | -------------- |
| Resume Support     | ✅                           | ❌              |
| Notifications      | ✅                           | ⚠️             |
| MediaStore Support | ✅                           | ❌              |
| Queue System       | ✅                           | ⚠️             |
| Clean API          | ✅                           | ⚠️             |

---

## 🧠 How It Works

* Uses **Dio** for downloading
* Supports **HTTP Range requests** (resume downloads)
* Stores tasks using **SharedPreferences**
* Uses **MethodChannel** for Android file saving

---

## ⚠️ Notes

* Resume requires server support for `Range` headers
* Some file types require external apps to open
* Android 13+ requires notification permission

---

## 📌 Roadmap

* [ ] Background downloads (WorkManager / BGTaskScheduler)
* [ ] File preview inside app
* [ ] Download grouping
* [ ] Web support

---

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit PRs.

---

## 📄 License

MIT License © 2026
