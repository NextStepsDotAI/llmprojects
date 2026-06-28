import os
from prisma import Prisma

async def test():
    db = Prisma()
    await db.connect()
    print("Successfully connected to the database!")
    await db.disconnect()

import asyncio
asyncio.run(test())