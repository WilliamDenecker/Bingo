import { describe, it, expect } from "vitest";
import { calculateScore, getCompletedLines } from "@/lib/scoring";

const empty = Array(25).fill(false);
const full = Array(25).fill(true);

function withPositions(positions: number[]): boolean[] {
  const done = Array(25).fill(false);
  positions.forEach((p) => (done[p] = true));
  return done;
}

describe("calculateScore", () => {
  it("returns 0 for empty grid", () => {
    expect(calculateScore(empty)).toBe(0);
  });

  it("returns 170 for full grid (25*2 + 12*10)", () => {
    expect(calculateScore(full)).toBe(170);
  });

  it("counts 2 points per square, no line bonus", () => {
    const done = withPositions([0, 1, 2]);
    expect(calculateScore(done)).toBe(6);
  });

  it("adds 10 bonus for completing first row", () => {
    const done = withPositions([0, 1, 2, 3, 4]);
    expect(calculateScore(done)).toBe(5 * 2 + 10);
  });

  it("adds 10 bonus for completing first column", () => {
    const done = withPositions([0, 5, 10, 15, 20]);
    expect(calculateScore(done)).toBe(5 * 2 + 10);
  });

  it("adds 10 bonus for main diagonal", () => {
    const done = withPositions([0, 6, 12, 18, 24]);
    expect(calculateScore(done)).toBe(5 * 2 + 10);
  });

  it("adds 10 bonus for anti-diagonal", () => {
    const done = withPositions([4, 8, 12, 16, 20]);
    expect(calculateScore(done)).toBe(5 * 2 + 10);
  });

  it("counts multiple completed lines", () => {
    // Row 0 + Row 1 (shares no squares)
    const done = withPositions([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    expect(calculateScore(done)).toBe(10 * 2 + 2 * 10);
  });
});

describe("getCompletedLines", () => {
  it("returns empty array for empty grid", () => {
    expect(getCompletedLines(empty)).toHaveLength(0);
  });

  it("returns all 12 lines for full grid", () => {
    expect(getCompletedLines(full)).toHaveLength(12);
  });

  it("detects a completed row", () => {
    const done = withPositions([0, 1, 2, 3, 4]);
    const lines = getCompletedLines(done);
    expect(lines).toHaveLength(1);
    expect(lines[0]).toEqual([0, 1, 2, 3, 4]);
  });

  it("detects a completed diagonal", () => {
    const done = withPositions([0, 6, 12, 18, 24]);
    const lines = getCompletedLines(done);
    expect(lines).toHaveLength(1);
    expect(lines[0]).toEqual([0, 6, 12, 18, 24]);
  });
});
