import json, struct
from pathlib import Path
root = Path(__file__).resolve().parent
data = b""
files = {}
for name in ["package.json", "main.cjs"]:
    b = (root / name).read_bytes()
    files[name] = {"size": len(b), "offset": str(len(data))}
    data += b
s = json.dumps({"files": files}, separators=(",", ":")).encode()
padded = (len(s) + 3) // 4 * 4
header = struct.pack("<II", 4 + padded, len(s)) + s + b"\0" * (padded - len(s))
(root / "runtime/resources/app.asar").write_bytes(struct.pack("<II", 4, len(header)) + header + data)
