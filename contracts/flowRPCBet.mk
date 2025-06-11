🟢 INICIO
  │
  ▼
🎲 Crear Partida
  - Jugador 1 elige apuesta (0.01 / 0.05 / 0.1 ETH)
  - Envía 3 jugadas como hash (commit)
  │
  ▼
🙋 Esperar oponente
  │
  ├── ❌ Si no llega en 30 min → Jugador 1 puede reclamar fondos
  ▼
🙋‍♂️ Jugador 2 se une
  - Apuesta el mismo monto
  - Envía sus 3 jugadas como hash
  │
  ▼
⏳ Ronda 1
  - Ambos jugadores revelan su jugada con `reveal()`
  - Contrato valida los hashes con salt
  │
  └── ❗ Si uno no revela en 30 min → el otro puede reclamar
  ▼
⚔️ Evaluar ronda
  - Gana: Piedra > Tijera > Papel > Piedra
  - Empate: sin puntos
  │
  ▼
🔁 Rondas 2 y 3
  - Se repite el flujo de reveal → evaluación
  │
  ▼
🏁 Final de juego
  ├── 🥇 Alguien gana 2 rondas → se le transfiere todo el ETH
  └── 🤝 Empate (1-1-1) → se reparte mitad y mitad
