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