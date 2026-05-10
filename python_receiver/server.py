import asyncio
import websockets
import json
import os
import logging

logging.basicConfig(level=logging.INFO)

CACHE_DIR = "cache"
CACHE_FILE = os.path.join(CACHE_DIR, "commands.json")
MAX_CACHE_SIZE = 100

if not os.path.exists(CACHE_DIR):
    os.makedirs(CACHE_DIR)

commands_cache = []

def save_cache():
    with open(CACHE_FILE, "w") as f:
        json.dump(commands_cache, f)

def add_to_cache(command):
    commands_cache.append(command)
    if len(commands_cache) > MAX_CACHE_SIZE:
        commands_cache.pop(0)
    save_cache()

async def handler(websocket):
    try:
        if hasattr(websocket, 'remote_address') and websocket.remote_address:
            client_ip = websocket.remote_address[0] if isinstance(websocket.remote_address, tuple) else str(websocket.remote_address)
        else:
            client_ip = "Unknown"
    except Exception:
        client_ip = "Unknown"
        
    print(f"\n==================================================")
    print(f"[SUCCESS] NEW CONNECTION ESTABLISHED: {client_ip}")
    print(f"==================================================\n")
    logging.info(f"Client connected: {client_ip}")
    
    try:
        async for message in websocket:
            logging.info(f"Received: {message}")
            try:
                data = json.loads(message)
                add_to_cache(data)
                # Auto-reply with acknowledgment
                await websocket.send(json.dumps({"status": "ack"}))
            except json.JSONDecodeError:
                logging.error("Invalid JSON received")
    except websockets.ConnectionClosed:
        logging.info("Client disconnected")

async def main():
    async with websockets.serve(handler, "0.0.0.0", 8765):
        logging.info("Server started on ws://0.0.0.0:8765")
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(main())
