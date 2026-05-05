import asyncio
from livekit import rtc
import httpx

# --- AYARLAR ---
BASE_URL = "http://localhost:8000/api" 
START_STREAM_URL = f"{BASE_URL}/streams/start" 
LIVEKIT_WS_URL = "ws://localhost:7880"

# Swagger (/docs) üzerinden aldığın Access Token'ı buraya yapıştır
USER_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwiZW1haWwiOiJzdHJlYW1lcjFAdGVzdC5jb20iLCJleHAiOjE3Nzc5ODM0MzMsInR5cGUiOiJhY2Nlc3MiLCJqdGkiOiI5MWEwN2NlNy05Y2UzLTRmMzUtODExOC1mMTllMTE3Y2QzMTEifQ.WNGlfvTVuy9SIDmDKDZ8237BJeTKUN6GC1sgenMCu8M" 

async def test_webhook():
    print("🚀 1. Adım: FastAPI üzerinden yayın başlatılıyor...")
    
    headers = {"Authorization": f"Bearer {USER_TOKEN}"}
    payload = {"title": "Webhook Testi", "category": "Gaming"}
    
    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(START_STREAM_URL, json=payload, headers=headers)
            if response.status_code != 200:
                print(f"❌ API Hatası ({response.status_code}): {response.text}")
                return
            
            data = response.json()
            lk_token = data["token"] # LiveKit bağlantı token'ı
            room_name = data["stream"]["room_name"]
            print(f"✅ Yayın oluşturuldu. Oda: {room_name}")
            
        except Exception as e:
            print(f"❌ API'ye bağlanılamadı: {e}")
            return

    print("📡 2. Adım: LiveKit'e bağlanılıyor (Webhook tetikleniyor)...")
    room = rtc.Room()
    
    try:
        # Bu bağlantı gerçekleştiği an LiveKit senin API'ndeki webhook'u çalacak
        await room.connect(LIVEKIT_WS_URL, lk_token)
        print(f"🎉 Bağlantı başarılı! Şimdi API loglarını kontrol et.")
        
        # Webhook paketinin gitmesi için 5 saniye bekleyelim
        await asyncio.sleep(5)
        
        await room.disconnect()
        print("🔌 Bağlantı kesildi. 'room_finished' veya 'participant_left' tetiklenmiş olmalı.")
        
    except Exception as e:
        print(f"❌ LiveKit bağlantı hatası: {e}")

if __name__ == "__main__":
    asyncio.run(test_webhook())