import asyncio
import websockets
import json
import os
import logging
import socket
from zeroconf import IPVersion, ServiceInfo
from zeroconf.asyncio import AsyncZeroconf

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
                # Flat slider map: {"J1": 45, "J2": -30, ...}
                readable = "  ".join(f"{k}={v}°" for k, v in data.items())
                print(f"[JOINTS] {readable}", flush=True)
                add_to_cache({"type": "joints", "values": data})
                await websocket.send("ack")
            except json.JSONDecodeError:
                # Plain text command: "set", "user one", etc.
                cmd = message.strip()
                print(f"[CMD]    {cmd}", flush=True)
                add_to_cache({"type": "command", "value": cmd})
                await websocket.send("ack")
    except websockets.ConnectionClosed:
        pass
    finally:
        connected_clients -= 1
        print(f"\n[-] CONNECTION CLOSED: {client_ip}\n", flush=True)
        logging.info("Client disconnected")

def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
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
    
    # mDNS Registration using AsyncZeroconf (works inside asyncio.run)
    local_ip = get_local_ip()
    port = 8765
    desc = {'version': '1.0.0'}
    
    info = ServiceInfo(
        "_robotic-rc._tcp.local.",
        "Robotic Server._robotic-rc._tcp.local.",
        addresses=[socket.inet_aton(local_ip)],
        port=port,
        properties=desc,
        server="robotic-server.local.",
    )

    aiozc = AsyncZeroconf(ip_version=IPVersion.V4Only)
    print(f"[mDNS] Registering service robotic-controller on {local_ip}:{port}...", flush=True)
    await aiozc.async_register_service(info)
    print(f"[mDNS] Service registered! Phone should discover this server automatically.", flush=True)

    # Start the background reporter
    asyncio.create_task(status_reporter())
    
    try:
        async with websockets.serve(handler, "0.0.0.0", port):
            logging.info(f"Server bound to ws://0.0.0.0:{port}")
            await asyncio.Future()  # run forever
    finally:
        print(f"[mDNS] Unregistering service...", flush=True)
        await aiozc.async_unregister_service(info)
        await aiozc.async_close()

if __name__ == "__main__":
    asyncio.run(main())
