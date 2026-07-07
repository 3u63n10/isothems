#!/usr/bin/env python3
from datetime import datetime
try:
    from zoneinfo import ZoneInfo
    tz = ZoneInfo("Asia/Tokyo")
except Exception:
    tz = None
print(datetime.now(tz).strftime("%Y%m%dT%H%M%S%z"))
