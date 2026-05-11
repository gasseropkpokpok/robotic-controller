import asyncio
import websockets
import json
import os
import logging
import socket
from zeroconf import IPVersion, ServiceInfo, Zeroconf

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

def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # doesn't even have to be reachable
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

async def main():
    print("\n" + "*"*50, flush=True)
    print("      ROBOTIC CONTROLLER - SERVER STARTED       ", flush=True)
    print("*"*50 + "\n", flush=True)
    
    # mDNS Registration
    local_ip = get_local_ip()
    port = 8765
    desc = {'version': '1.0.0'}
    
    info = ServiceInfo(
        "_robotic-controller._tcp.local.",
        "Robotic Server._robotic-controller._tcp.local.",
        addresses=[socket.inet_aton(local_ip)],
        port=port,
        properties=desc,
        server="robotic-server.local.",
    )

    zeroconf = Zeroconf(ip_version=IPVersion.V4Only)
    print(f"[mDNS] Registering service robotic-controller on {local_ip}:{port}...", flush=True)
    zeroconf.register_service(info)

    # Start the background reporter
    asyncio.create_task(status_reporter())
    
    try:
        async with websockets.serve(handler, "0.0.0.0", 8765):
            logging.info(f"Server bound to ws://0.0.0.0:{port}")
            await asyncio.Future()  # run forever
    finally:
        print(f"[mDNS] Unregistering service...", flush=True)
        zeroconf.unregister_service(info)
        zeroconf.close()

if __name__ == "__main__":
    asyncio.run(main())
