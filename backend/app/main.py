import asyncio
import json
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from contextlib import async_concurrency_contextmanager
import aiomqtt
from app.services.ai_agent import process_sensor_data # Logic from previous steps

# --- WebSocket Manager ---
class ConnectionManager:
    def __init__(self):
        self.active_connections: list[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def broadcast(self, message: dict):
        for connection in self.active_connections:
            await connection.send_json(message)

manager = ConnectionManager()

# --- MQTT Background Task ---
async def mqtt_worker():
    """Listens to Wokwi and triggers AI/WebSockets."""
    async with aiomqtt.Client("broker.emqx.io") as client:
        await client.subscribe("agriculture/pillar1/sensors")
        async with client.messages() as messages:
            async for message in messages:
                # 1. Run the AI reasoning logic
                ai_decision = await process_sensor_data(message.payload)
                
                # 2. Publish command back to Wokwi/ESP32
                await client.publish("agriculture/pillar1/commands", json.dumps(ai_decision))
                
                # 3. Push the update LIVE to the Flutter app via WebSocket
                await manager.broadcast({
                    "sensor_data": json.loads(message.payload),
                    "ai_decision": ai_decision
                })

# --- FastAPI Lifespan ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Start the MQTT background worker
    task = asyncio.create_task(mqtt_worker())
    yield
    # Cleanup on shutdown
    task.cancel()

app = FastAPI(lifespan=lifespan)

# --- Routes ---

@app.get("/")
def read_root():
    return {"status": "Pillar 1 Online"}

@app.websocket("/ws/irrigation")
async def websocket_endpoint(websocket: WebSocket):
    """The bridge for the Flutter Frontend."""
    await manager.connect(websocket)
    try:
        while True:
            # Keep the connection open
            await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(websocket)