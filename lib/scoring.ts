// 5x5 bingo grid: positions 0-24 in row-major order
// 12 possible lines: 5 rows + 5 cols + 2 diagonals

export const LINES: number[][] = [
  // rows
  [0, 1, 2, 3, 4],
  [5, 6, 7, 8, 9],
  [10, 11, 12, 13, 14],
  [15, 16, 17, 18, 19],
  [20, 21, 22, 23, 24],
  // cols
  [0, 5, 10, 15, 20],
  [1, 6, 11, 16, 21],
  [2, 7, 12, 17, 22],
  [3, 8, 13, 18, 23],
  [4, 9, 14, 19, 24],
  // diagonals
  [0, 6, 12, 18, 24],
  [4, 8, 12, 16, 20],
];

export function getCompletedLines(done: boolean[]): number[][] {
  return LINES.filter((line) => line.every((pos) => done[pos]));
}

export function calculateScore(done: boolean[]): number {
  const squarePoints = done.filter(Boolean).length * 2;
  const linePoints = getCompletedLines(done).length * 10;
  return squarePoints + linePoints;
}
