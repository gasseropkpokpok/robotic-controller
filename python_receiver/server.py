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
connected_clients = 0

def save_cache():
    with open(CACHE_FILE, "w") as f:
        json.dump(commands_cache, f)

def add_to_cache(command):
    commands_cache.append(command)
    if len(commands_cache) > MAX_CACHE_SIZE:
        commands_cache.pop(0)
    save_cache()

async def status_reporter():
    while True:
        if connected_clients == 0:
            print(f"[STATUS] Server is available and waiting for connections... (0 connected)", flush=True)
        await asyncio.sleep(5)

async def handler(websocket):
    global connected_clients
    connected_clients += 1
    
    try:
        if hasattr(websocket, 'remote_address') and websocket.remote_address:
            client_ip = websocket.remote_address[0] if isinstance(websocket.remote_address, tuple) else str(websocket.remote_address)
        else:
            client_ip = "Unknown"
    except Exception:
        client_ip = "Unknown"
        
    print(f"\n==================================================", flush=True)
    print(f"[SUCCESS] NEW CONNECTION ESTABLISHED: {client_ip}", flush=True)
    print(f"==================================================\n", flush=True)
    logging.info(f"Client connected: {client_ip}")
    
    try:
        async for message in websocket:
            try:
                data = json.loads(message)
                
                print(f"\n[>>>] INCOMING COMMAND FROM {client_ip}", flush=True)
                print(json.dumps(data, indent=2), flush=True)
                print(f"[+] Command successfully saved to {CACHE_FILE}", flush=True)
                print(f"--------------------------------------------------", flush=True)
                
                add_to_cache(data)
                # Auto-reply with acknowledgment
                await websocket.send(json.dumps({"status": "ack"}))
            except json.JSONDecodeError:
                print(f"\n[!] INVALID JSON RECEIVED: {message}\n", flush=True)
                logging.error("Invalid JSON received")
    except websockets.ConnectionClosed:
        pass
    finally:
        connected_clients -= 1
        print(f"\n[-] CONNECTION CLOSED: {client_ip}\n", flush=True)
        logging.info("Client disconnected")

async def main():
    print("\n" + "*"*50, flush=True)
    print("      ROBOTIC CONTROLLER - SERVER STARTED       ", flush=True)
    print("*"*50 + "\n", flush=True)
    
    # Start the background reporter
    asyncio.create_task(status_reporter())
    
    async with websockets.serve(handler, "0.0.0.0", 8765):
        logging.info("Server bound to ws://0.0.0.0:8765")
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(main())
