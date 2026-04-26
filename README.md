# Star Maze — x86 Assembly Game

A maze game written in x86 Assembly (NASM), running in real mode DOS. Guide a bouncing star (`*`) through obstacles to reach the goal in the top-left corner.

DEMO Gameplay Video : https://github.com/user-attachments/assets/3c513b4d-fc67-477f-bd29-f0577559d224

---

## Gameplay

- A star (`*`) moves automatically across the screen
- Use arrow keys to change its direction
- Avoid all obstacles (walls and blocks)
- Reach the **goal** (top-left corner) to win
- Hit any obstacle and you lose

---

## Controls

| Key        | Action         |
|------------|----------------|
| Arrow Up   | Move up        |
| Arrow Down | Move down      |
| Arrow Left | Move left      |
| Arrow Right| Move right     |
| Enter      | Restart game   |
| Esc        | Quit           |

---

## Files Included

| File          | Purpose                                      |
|---------------|----------------------------------------------|
| `game.asm`    | Main source code                             |
| `nasm.exe`    | Assembler — used to compile the `.asm` file  |
| `cwsdpmi.exe` | DOS extender — required to run the game      |
| `afd.exe`     | Debugger — for stepping through the code     |

---

## How to Run

### Step 1 — Assemble
Open a terminal (DOSBox or DOS prompt) and run:
```
nasm game.asm -o game.com
```

### Step 2 — Run
```
game.com
```
> Make sure `cwsdpmi.exe` is in the same folder.

---

## How to Debug (optional)

```
afd game.com
```

---

## Requirements

- DOSBox (recommended) or a real DOS environment
- All `.exe` files included in this repo — no extra downloads needed

---

## Notes

- Written entirely in x86 16-bit real mode Assembly
- Uses hardware interrupts (INT 08h for timer, INT 09h for keyboard)
- Draws directly to video memory at `0xB800`
- Collision detection uses a pre-built array of obstacle coordinates
