from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from repositories import StreamRepository
from services import StreamService
from database import get_session
from schemas.stream import StreamCreate, StreamConnectionResponse, StreamResponse
from api.v1.deps import get_current_user

router = APIRouter(prefix="/streams", tags=["Streams"])

@router.post("/start", response_model=StreamConnectionResponse)
async def start_stream(
    stream_in: StreamCreate,
    db: AsyncSession = Depends(get_session),
    current_user = Depends(get_current_user)
):
    service = StreamService(db)
    stream, token = await service.start_stream(stream_in, current_user)
    
    return StreamConnectionResponse(stream=stream, token=token)

@router.get("/{room_name}/join", response_model=StreamConnectionResponse)
async def join_stream(
    room_name: str,
    db: AsyncSession = Depends(get_session),
    current_user = Depends(get_current_user)
):
    service = StreamService(db)
    try:
        stream, token = await service.join_stream(room_name, current_user)
        return StreamConnectionResponse(stream=stream, token=token)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))

@router.get("/active", response_model=list[StreamResponse])
async def get_active_streams(
    skip: int = 0, 
    limit: int = 10,
    db: AsyncSession = Depends(get_session)
):
    service = StreamService(db)
    return await service.get_active_streams(skip=skip, limit=limit)

@router.post("/{room_name}/end")
async def end_stream(
    room_name: str,
    db: AsyncSession = Depends(get_session),
    current_user = Depends(get_current_user)
):
    service = StreamService(db)
    try:
        await service.end_stream(room_name, current_user)
        return {"message": "Stream ended successfully."}
    except ValueError as e:
        raise HTTPException(status_code=403, detail=str(e))
    except PermissionError as e:
        raise HTTPException(status_code=403, detail=str(e))