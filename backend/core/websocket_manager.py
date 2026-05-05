from fastapi import WebSocket
from typing import List

class ConnectionManager:
    def __init__(self):
        # Aktif bağlantıları bu listede tutacağız
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        # Yeni bir cihaz bağlandığında hattı kabul et ve listeye ekle
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        # Cihaz uygulamayı kapattığında veya bağlantı koptuğunda listeden çıkar
        self.active_connections.remove(websocket)

    async def broadcast(self, message: dict):
        # Listemizdeki HERKESE aynı mesajı gönder (Örn: "Yayın listesini yenile!")
        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except Exception:
                # Eğer bir bağlantı ölmüşse ama hala listedeyse hata almamak için
                pass

# Proje genelinde tek bir yönetici olması için "singleton" örneği oluşturuyoruz
manager = ConnectionManager()