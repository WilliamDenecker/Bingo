"use client";

import { useState, useRef } from "react";
import { CheckCircle2, X } from "lucide-react";
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

  const [expanded, setExpanded] = useState<BingoSquare | null>(null);
  const longPressTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const didLongPress = useRef(false);

  function startLongPress(square: BingoSquare) {
    didLongPress.current = false;
    longPressTimer.current = setTimeout(() => {
      didLongPress.current = true;
      setExpanded(square);
    }, 400);
  }

  function cancelLongPress() {
    if (longPressTimer.current) clearTimeout(longPressTimer.current);
  }

  function handleClick(square: BingoSquare) {
    if (didLongPress.current) return; // don't toggle on long press
    onToggle?.(square.id, square.is_done);
  }

  return (
    <>
      <div className="grid grid-cols-5 gap-1 w-full max-w-sm mx-auto">
        {sorted.map((square) => {
          const isInCompletedLine = completedPositions.has(square.position);
          return (
            <button
              key={square.id}
              onClick={() => handleClick(square)}
              onMouseDown={() => startLongPress(square)}
              onMouseUp={cancelLongPress}
              onMouseLeave={cancelLongPress}
              onTouchStart={() => startLongPress(square)}
              onTouchEnd={cancelLongPress}
              onTouchCancel={cancelLongPress}
              onContextMenu={(e) => e.preventDefault()}
              disabled={!onToggle && !true}
              className={cn(
                "relative aspect-square flex flex-col items-center justify-center p-1 rounded-md border text-center transition-all duration-200 text-[10px] leading-tight font-medium select-none",
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

      {/* Long-press modal */}
      {expanded && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-6"
          onClick={() => setExpanded(null)}
        >
          <div
            className={cn(
              "relative w-full max-w-xs rounded-xl border p-6 text-center shadow-xl",
              expanded.is_done
                ? completedPositions.has(expanded.position)
                  ? "bg-yellow-400 border-yellow-500 text-yellow-900"
                  : "bg-primary border-primary text-primary-foreground"
                : "bg-card border-border text-card-foreground"
            )}
            onClick={(e) => e.stopPropagation()}
          >
            <button
              onClick={() => setExpanded(null)}
              className="absolute top-3 right-3 opacity-60 hover:opacity-100"
            >
              <X className="h-4 w-4" />
            </button>
            {expanded.is_done && (
              <CheckCircle2 className="mx-auto mb-3 h-8 w-8 opacity-80" />
            )}
            <p className="text-lg font-semibold leading-snug">{expanded.label}</p>
            {onToggle && (
              <button
                onClick={() => {
                  onToggle(expanded.id, expanded.is_done);
                  setExpanded(null);
                }}
                className={cn(
                  "mt-4 w-full rounded-md px-4 py-2 text-sm font-medium border transition-colors",
                  expanded.is_done
                    ? "border-current opacity-70 hover:opacity-100"
                    : "border-current opacity-70 hover:opacity-100"
                )}
              >
                {expanded.is_done ? "Mark as not done" : "Mark as done"}
              </button>
            )}
          </div>
        </div>
      )}
    </>
  );
}
