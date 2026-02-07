# AgriSmart: AI-Driven Precision Agriculture Ecosystem 🌾🚀

**AgriSmart** is an end-to-end intelligent farming solution that bridges the gap between **Applied Mathematics** and **AIoT**. The project leverages satellite imagery, autonomous AI agents, and edge computing to optimize resources and maximize crop yields.

---

## 🏗 System Architecture

The project is divided into four integrated modules, each handling a specific challenge in modern agriculture:

### 1. Autonomous Irrigation AI Agent (IoT)
* **Orchestration:** Developed using **LangChain** to process environmental data and make real-time decisions.
* **Sensors:** Simulated **ESP32**, **DHT22**, and Soil Moisture sensors using **Wokwi CLI**.
* **Communication:** Utilizes an **MQTT (Mosquitto)** broker for lightweight, low-latency messaging.
* **External Intelligence:** Integrated **OpenWeather API** for predictive irrigation adjustments based on local forecasts.

### 2. Satellite Crop Analysis & Planning
* **Data Source:** **Copernicus Sentinel-2 API** for multispectral satellite imagery.
* **Mathematical Processing:** Used **NumPy** and **Rasterio** to calculate the **NDVI** (Normalized Difference Vegetation Index).
* **Output:** Generation of **VRA (Variable Rate Application)** maps, allowing farmers to visualize field health and plan fertilization accurately.

### 3. Mobile Crop Disease Detection
* **Model:** **MobileNetV2** (Deep Learning) trained on the **PlantVillage** and **PlantDoc** datasets.
* **Optimization:** Quantized and deployed via **TensorFlow Lite** for high-performance inference on mobile devices.
* **Framework:** Built with **Flutter** for a cross-platform, intuitive user interface.

### 4. Intelligent Livestock Management
* **Multimodal Interaction:** A hands-free assistant utilizing **Whisper** (Speech-to-Text) and **Ollama** (Local LLM) for secure, offline data management and livestock monitoring.

---

## 🛠 Tech Stack

* **Languages:** Python (AI/Data Science), Dart (Flutter), SQL.
* **AI/ML:** LangChain, TensorFlow Lite, Ollama, OpenAI Whisper.
* **Data Science:** NumPy, Rasterio, Matplotlib, Pandas.
* **IoT/DevOps:** Wokwi Simulator, Mosquitto MQTT, Git.

---

## 📈 The "Big Picture" Approach

As an engineering student with a strong background in **Applied Mathematics**, I designed AgriSmart to be more than just a set of scripts. It is a full-cycle system where:
1.  **Probability models** inform irrigation risks.
2.  **Calculus-based indices (NDVI)** drive spatial planning.
3.  **Linear Algebra** powers the computer vision backbone.

---

## 🚀 Getting Started

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/KTHIRI-Chedi/AgriSmart.git
    ```
2.  **Install dependencies:**
    ```bash
    pip install langchain rasterio numpy tensorflow-lite
    ```
3.  **Run the IoT Simulation:**
    Ensure you have the Wokwi CLI installed and the Mosquitto broker running.

---
