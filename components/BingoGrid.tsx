"use client";

import { CheckCircle2 } from "lucide-react";
import { cn } from "@/lib/utils";
import { getCompletedLines } from "@/lib/scoring";

export interface BingoSquare {
  id: number;
  position: number;
  label: string;
  is_done: boolean;
}

interface BingoGridProps {
  squares: BingoSquare[];
  onToggle?: (squareId: number, currentDone: boolean) => void;
}

export function BingoGrid({ squares, onToggle }: BingoGridProps) {
  const sorted = [...squares].sort((a, b) => a.position - b.position);
  const doneArray = sorted.map((s) => s.is_done);
  const completedLines = getCompletedLines(doneArray);
  const completedPositions = new Set(completedLines.flat());

  return (
    <div className="grid grid-cols-5 gap-1 w-full max-w-sm mx-auto">
      {sorted.map((square) => {
        const isInCompletedLine = completedPositions.has(square.position);
        return (
          <button
            key={square.id}
            onClick={() => onToggle?.(square.id, square.is_done)}
            disabled={!onToggle}
            className={cn(
              "relative aspect-square flex flex-col items-center justify-center p-1 rounded-md border text-center transition-all duration-200 text-[10px] leading-tight font-medium",
              "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
              square.is_done
                ? isInCompletedLine
                  ? "bg-yellow-400 border-yellow-500 text-yellow-900"
                  : "bg-primary border-primary text-primary-foreground"
                : "bg-card border-border text-card-foreground hover:bg-accent hover:text-accent-foreground",
              !onToggle && "cursor-default"
            )}
          >
            {square.is_done && (
              <CheckCircle2 className="absolute top-0.5 right-0.5 h-3 w-3 opacity-80" />
            )}
            <span className="line-clamp-3">{square.label}</span>
          </button>
        );
      })}
    </div>
  );
}
