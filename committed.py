import asyncio
import subprocess
from secrets import token_hex

async def create_commit(start, end):
		for i in range(start, end):
				subprocess.run(["git", "commit", "--allow-empty", "-m", str(token_hex(16))])

async def main():
		num_commits = 100000000000
		num_processes = 1000

		tasks = []
		chunk_size = num_commits

		for i in range(num_processes):
				start = i * chunk_size
				end = start + chunk_size
				task = create_commit(start, end)
				tasks.append(task)

		await asyncio.gather(*tasks)
		subprocess.run(["git", "push", "origin", "master"])

if __name__ == "__main__":
		asyncio.run(main())
