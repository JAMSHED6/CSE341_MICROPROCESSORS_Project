# School Management System — 8086 Assembly

> A menu-driven school management application written in 8086 Assembly for the Emu8086 emulator. Built as a CSE341: Microprocessors course project.

---

## Features

| Module | Description |
|---|---|
| Attendance | Mark students present / view attendance by ID |
| Grades | Enter and retrieve student grades (0–100) |
| Library | Add books with quantity; view full inventory |
| Salaries | Set and view teacher salaries (up to 4 digits) |
| Expenses | Log school expenses; tracks running total |

---

## Technical Highlights

- **Input procedures** — Separate routines for 2-digit, 3-digit, and 4-digit numeric input with full validation and `0FFFFh` error signaling
- **PRINT macro** — Reusable DOS INT 21h / AH=09h string output macro
- **PRINT_NUM procedure** — Stack-based decimal printing; extracts digits via repeated division, pushes remainders, pops in order to print correctly
- **Word-aligned indexing** — Teacher salary array uses `shl bx, 1` to compute correct 16-bit word offsets
- **Segment setup** — Proper `.MODEL SMALL` / `.STACK` / `@data` initialization

---

## Memory Layout

| Array | Size | Type | Purpose |
|---|---|---|---|
| `ATTENDANCE` | 100 bytes | DB | Present/absent flags |
| `GRADES` | 100 bytes | DB | Student grades |
| `BOOK_ID / BOOK_QTY` | 10 bytes each | DB | Book records |
| `TEACHER_SALARY` | 100 words | DW | Salary per teacher |
| `EXPENSE` | 50 words | DW | Individual expenses |

---

## How to Run

1. Open **Emu8086**
2. Load `school_management.asm`
3. Assemble and run
4. Use the numeric menu (0–9) to navigate

---

## Course

**CSE341 — Microprocessors and Assembly Language**
