import cloudinary
import cloudinary.uploader
from fastapi import UploadFile
from anyio import to_thread # FastAPI/Starlette default olarak anyio kullanır
from core.config import settings
from typing import Optional

cloudinary.config(
    cloud_name=settings.CLOUDINARY_CLOUD_NAME,
    api_key=settings.CLOUDINARY_API_KEY,
    api_secret=settings.CLOUDINARY_API_SECRET
)

class CloudinaryService:
    @staticmethod
    async def upload_image(file_content: bytes, folder: str = "profile_images") -> Optional[str]:
        # Blocking I/O işlemini thread pool'a gönderiyoruz
        try:
            # Bytes verisini doğrudan Cloudinary'ye gönderiyoruz
            result = await to_thread.run_sync(
                lambda: cloudinary.uploader.upload(
                    file_content,
                    folder=folder,
                    transformation=[
                        {"width": 500, "height": 500, "crop": "limit"},
                        {"quality": "auto"},
                        {"fetch_format": "auto"}
                    ]
                )
            )
            return result.get("secure_url")
        except Exception as e:
            from loguru import logger
            logger.error(f"Cloudinary upload error: {e}")
            return None

    @staticmethod
    async def delete_image(image_url: str) -> None:
        if not image_url:
            return

        try:
            # URL'den public_id ayıklama (Daha sağlam bir regex veya regex-free yaklaşım)
            # Örn: .../v1234567/profile_images/ozenc_abc123.jpg
            # 'profile_images/' sonrası ve '.' öncesini almak daha güvenli
            path_parts = image_url.split("/")
            # Klasör ve dosya ismini (public_id) koru
            filename_with_ext = path_parts[-1]
            public_id = f"profile_images/{filename_with_ext.split('.')[0]}"

            # Yine blocking call, yine thread pool
            await to_thread.run_sync(
                lambda: cloudinary.uploader.destroy(public_id)
            )
        except Exception:
            # Kritik olmayan silme hataları için logging yeterli
            pass