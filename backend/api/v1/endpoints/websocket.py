from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from core.websocket_manager import manager

router = APIRouter(prefix="/websocket", tags=["WebSocket"])

@router.websocket("/streams")
async def stream_updates_socket(websocket: WebSocket):
    # 1. Bağlantıyı kabul et ve deftere kaydet
    await manager.connect(websocket)
    
    try:
        # 2. Bağlantıyı açık tutmak için sonsuz döngü
        while True:
            # İstemciden (Flutter) bir mesaj gelirse diye dinliyoruz
            # Ama asıl amacımız bizim onlara mesaj yollamamız
            data = await websocket.receive_text() 
            
    except WebSocketDisconnect:
        # 3. Telefon uygulamayı kapatırsa listeden çıkar
        manager.disconnect(websocket)

@router.websocket("/notifications/{user_id}")
async def notification_socket(websocket: WebSocket, user_id: int):
    # 1. Bağlantıyı kullanıcı ID'si ile kaydet
    # Bu sayede manager.user_connections[user_id] = websocket eşleşmesi yapılır.
    await manager.connect(websocket, user_id=user_id)
    
    try:
        # 2. Bağlantıyı açık tutmak için sonsuz döngü
        while True:
            # İstemciden (Flutter) veri bekliyoruz (Keep-alive için)
            # Flutter tarafı düzenli olarak bir "ping" veya boş mesaj atabilir.
            data = await websocket.receive_text()
            
    except WebSocketDisconnect:
        # 3. Bağlantı koptuğunda (Uygulama kapandığında veya internet gidince)
        # Manager üzerinden bu kullanıcının hattını siliyoruz.
        manager.disconnect(websocket, user_id=user_id)