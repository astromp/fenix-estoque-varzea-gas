from pathlib import Path

base = Path(__file__).resolve().parent
partes = sorted((base / "fonte").glob("app.js.part*"))

if len(partes) != 5:
    raise SystemExit(f"Esperadas 5 partes do app.js; encontradas {len(partes)}.")

conteudo = "".join(parte.read_text(encoding="utf-8") for parte in partes)
saida = base / "app.js"
saida.write_text(conteudo, encoding="utf-8")
print(f"app.js montado: {saida} ({len(conteudo)} bytes)")
