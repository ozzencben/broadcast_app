from fastapi import WebSocket
from typing import List, Dict

class ConnectionManager:
    def __init__(self):
        # 1. Genel yayınlar (Stream listesi güncellemeleri vb.)
        self.active_connections: List[WebSocket] = []
        
        # 2. Kişiye özel bildirimler (User_id -> WebSocket)
        # Bu sayede "5 nolu kullanıcıya mesaj at" diyebileceğiz.
        self.user_connections: Dict[int, WebSocket] = {}

    async def connect(self, websocket: WebSocket, user_id: int = None):
        await websocket.accept()
        if user_id:
            self.user_connections[user_id] = websocket
            print(f"🔔 Bildirim Hattı: User {user_id} bağlandı.")
        else:
            self.active_connections.append(websocket)
            print("📡 Genel Yayın Hattı: Yeni cihaz bağlandı.")

    def disconnect(self, websocket: WebSocket, user_id: int = None):
        if user_id and user_id in self.user_connections:
            del self.user_connections[user_id]
            print(f"📴 User {user_id} bildirim hattından ayrıldı.")
        
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
            print("📴 Genel yayın hattından bir cihaz ayrıldı.")

    async def broadcast(self, message: dict):
        """Herkene mesaj gönderir (Eski sistem)"""
        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except:
                pass

    async def send_personal_message(self, message: dict, user_id: int):
        """Sadece belirli bir kullanıcıya mesaj gönderir (Yeni sistem)"""
        websocket = self.user_connections.get(user_id)
        if websocket:
            try:
                await websocket.send_json(message)
                return True
            except:
                # Bağlantı sorunluysa temizle
                self.disconnect(websocket, user_id)
        return False

# Singleton örneği
manager = ConnectionManager()