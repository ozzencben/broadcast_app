import logging
import sys
from types import FrameType
from typing import cast

from loguru import logger
from pydantic import BaseModel


class LogConfig(BaseModel):
    """Log configuration parameters. Usually loaded from .env via BaseSettings."""
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>"
    LOG_DIR: str = "logs"
    LOG_FILE: str = "app.log"
    ROTATION: str = "500 MB"
    RETENTION: str = "10 days"


class InterceptHandler(logging.Handler):
    """
    Default logging library interceptor.
    Routes all standard library logs (Uvicorn, FastAPI, SQLAlchemy) into Loguru.
    """
    def emit(self, record: logging.LogRecord) -> None:
        try:
            level: str | int = logger.level(record.levelname).name
        except ValueError:
            level = record.levelno

        # Find the caller frame to ensure correct file/line numbers in the log
        frame, depth = sys._getframe(6), 6
        while frame and frame.f_code.co_filename == logging.__file__:
            frame = cast(FrameType, frame.f_back)
            depth += 1

        logger.opt(depth=depth, exception=record.exc_info).log(
            level, record.getMessage()
        )


def setup_logger(config: LogConfig = LogConfig()) -> None:
    """
    Configures the Loguru logger and intercepts standard logs.
    Call this in main.py lifespan or startup event.
    """
    # Remove standard Loguru handler
    logger.remove()

    # Intercept everything at the root logger
    logging.root.handlers = [InterceptHandler()]
    logging.root.setLevel(config.LOG_LEVEL)

    # Remove all default handlers from specific loggers to avoid duplication
    for name in logging.root.manager.loggerDict.keys():
        logging.getLogger(name).handlers = []
        logging.getLogger(name).propagate = True

    # 1. Console Output (Human readable)
    logger.add(
        sys.stdout,
        enqueue=True,
        colorize=True,
        format=config.LOG_FORMAT,
        level=config.LOG_LEVEL,
    )

    # 2. File Output (Machine readable / JSON structure for ELK/Datadog)
    logger.add(
        f"{config.LOG_DIR}/{config.LOG_FILE}",
        rotation=config.ROTATION,
        retention=config.RETENTION,
        enqueue=True,      # Critical for async performance
        serialize=True,    # Converts logs to JSON strings automatically
        level=config.LOG_LEVEL,
    )

    logger.info("Logger initialized successfully. Intercepting Uvicorn & SQLAlchemy.")