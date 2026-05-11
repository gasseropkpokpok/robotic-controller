import asyncio
import websockets
import json
import os
import logging
import socket
from aiohttp import web

logging.basicConfig(level=logging.INFO)

CACHE_DIR = "cache"
CACHE_FILE = os.path.join(CACHE_DIR, "commands.json")
MAX_CACHE_SIZE = 100
WS_PORT = 8765
UDP_BROADCAST_PORT = 8766
HTTP_PORT = 8767

if not os.path.exists(CACHE_DIR):
    os.makedirs(CACHE_DIR)

commands_cache = []
connected_clients = 0

def save_cache():
    try:
        with open(CACHE_FILE, "w") as f:
            json.dump(commands_cache, f, indent=2)
    except Exception as e:
        logging.error(f"Error saving cache: {e}")

def add_to_cache(item):
    commands_cache.append(item)
    if len(commands_cache) > MAX_CACHE_SIZE:
        commands_cache.pop(0)
    save_cache()

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

async def status_reporter():
    while True:
        if connected_clients == 0:
            print(f"[STATUS] Waiting for connections... (0 connected)", flush=True)
        await asyncio.sleep(5)

async def udp_broadcaster(local_ip: str):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    sock.setblocking(False)
    payload = f"ROBOT_CTRL:{local_ip}:{WS_PORT}".encode()
    loop = asyncio.get_event_loop()
    print(f"[UDP]  Broadcasting discovery beacon on port {UDP_BROADCAST_PORT}...", flush=True)
    while True:
        try:
            await loop.sock_sendto(sock, payload, ('255.255.255.255', UDP_BROADCAST_PORT))
        except Exception:
            pass
        await asyncio.sleep(2)

async def handle_get_cache(request):
    return web.json_response(commands_cache)

async def handler(websocket):
    global connected_clients
    connected_clients += 1
    
    try:
        client_ip = websocket.remote_address[0] if isinstance(websocket.remote_address, tuple) else "Unknown"
    except Exception:
        client_ip = "Unknown"
        
    print(f"\n{'='*50}", flush=True)
    print(f"[CONNECTED] {client_ip}", flush=True)
    print(f"{'='*50}\n", flush=True)
    
    try:
        async for message in websocket:
            try:
                data = json.loads(message)
                readable = "  ".join(f"{k}={v}°" for k, v in data.items())
                print(f"[JOINTS] {readable}", flush=True)
                add_to_cache({"type": "joints", "values": data, "ip": client_ip})
                await websocket.send("ack")
            except json.JSONDecodeError:
                cmd = message.strip()
                print(f"[CMD]    {cmd}", flush=True)
                add_to_cache({"type": "command", "value": cmd, "ip": client_ip})
                await websocket.send("ack")
    except websockets.ConnectionClosed:
        pass
    finally:
        connected_clients -= 1
        print(f"\n[DISCONNECTED] {client_ip}\n", flush=True)

async def main():
    print("\n" + "*"*50, flush=True)
    print("      ROBOTIC CONTROLLER - SERVER STARTED       ", flush=True)
    print("*"*50 + "\n", flush=True)
    
    local_ip = get_local_ip()
    print(f"[INFO] Server IP: {local_ip}", flush=True)
    print(f"[INFO] WebSocket:  ws://{local_ip}:{WS_PORT}", flush=True)
    print(f"[INFO] HTTP Cache: http://{local_ip}:{HTTP_PORT}/cache", flush=True)
    print(f"[INFO] Discovery:  UDP broadcast on port {UDP_BROADCAST_PORT}\n", flush=True)

    # HTTP server for cache access
    app = web.Application()
    app.router.add_get('/cache', handle_get_cache)
    runner = web.AppRunner(app)
    await runner.setup()
    site = web.TCPSite(runner, '0.0.0.0', HTTP_PORT)
    await site.start()

    asyncio.create_task(status_reporter())
    asyncio.create_task(udp_broadcaster(local_ip))
    
    async with websockets.serve(handler, "0.0.0.0", WS_PORT):
        await asyncio.Future()

if __name__ == "__main__":
    asyncio.run(main())
