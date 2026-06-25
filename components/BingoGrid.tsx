"use client";

import { useState, useRef } from "react";
import { CheckCircle2, X, Camera, ImagePlus } from "lucide-react";
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
  onToggle?: (squareId: number, currentDone: boolean, proofFile?: File) => void;
}

export function BingoGrid({ squares, onToggle }: BingoGridProps) {
  const sorted = [...squares].sort((a, b) => a.position - b.position);
  const doneArray = sorted.map((s) => s.is_done);
  const completedLines = getCompletedLines(doneArray);
  const completedPositions = new Set(completedLines.flat());

  const [expanded, setExpanded] = useState<BingoSquare | null>(null);
  const [proofPreview, setProofPreview] = useState<string | null>(null);
  const [proofFile, setProofFile] = useState<File | null>(null);
  const longPressTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const didLongPress = useRef(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  function openModal(square: BingoSquare) {
    setExpanded(square);
    setProofPreview(null);
    setProofFile(null);
  }

  function closeModal() {
    setExpanded(null);
    setProofPreview(null);
    setProofFile(null);
  }

  function startLongPress(square: BingoSquare) {
    didLongPress.current = false;
    longPressTimer.current = setTimeout(() => {
      didLongPress.current = true;
      openModal(square);
    }, 400);
  }

  function cancelLongPress() {
    if (longPressTimer.current) clearTimeout(longPressTimer.current);
  }

  function handleClick(square: BingoSquare) {
    if (didLongPress.current) return;
    if (!onToggle) return;
    // marking done → open modal for optional proof; unchecking → toggle immediately
    if (!square.is_done) {
      openModal(square);
    } else {
      onToggle(square.id, square.is_done);
    }
  }

  function handleProofChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setProofFile(file);
    setProofPreview(URL.createObjectURL(file));
  }

  function handleConfirm() {
    if (!expanded || !onToggle) return;
    onToggle(expanded.id, expanded.is_done, proofFile ?? undefined);
    closeModal();
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

      {/* Square action modal */}
      {expanded && (
        <div
          className="fixed inset-0 z-50 flex items-end justify-center bg-black/70 p-0 sm:items-center sm:p-6"
          onClick={closeModal}
        >
          <div
            className={cn(
              "relative w-full max-w-sm rounded-t-2xl sm:rounded-xl border p-6 shadow-xl",
              expanded.is_done
                ? completedPositions.has(expanded.position)
                  ? "bg-yellow-400 border-yellow-500 text-yellow-900"
                  : "bg-primary border-primary text-primary-foreground"
                : "bg-card border-border text-card-foreground"
            )}
            onClick={(e) => e.stopPropagation()}
          >
            <button
              onClick={closeModal}
              className="absolute top-3 right-3 opacity-60 hover:opacity-100"
            >
              <X className="h-4 w-4" />
            </button>

            {expanded.is_done && (
              <CheckCircle2 className="mx-auto mb-3 h-8 w-8 opacity-80" />
            )}
            <p className="text-lg font-semibold leading-snug text-center">{expanded.label}</p>

            {/* Photo section — only shown when marking as done */}
            {onToggle && !expanded.is_done && (
              <div className="mt-4">
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/*"
                  capture="environment"
                  className="hidden"
                  onChange={handleProofChange}
                />
                {proofPreview ? (
                  <div className="relative mt-2">
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img
                      src={proofPreview}
                      alt="Proof preview"
                      className="w-full rounded-lg object-cover max-h-48"
                    />
                    <button
                      onClick={() => { setProofPreview(null); setProofFile(null); }}
                      className="absolute top-1 right-1 bg-black/60 rounded-full p-1"
                    >
                      <X className="h-3 w-3 text-white" />
                    </button>
                  </div>
                ) : (
                  <button
                    type="button"
                    onClick={() => fileInputRef.current?.click()}
                    className="mt-2 w-full flex items-center justify-center gap-2 rounded-lg border-2 border-dashed border-current opacity-60 hover:opacity-90 py-3 text-sm font-medium transition-opacity"
                  >
                    <ImagePlus className="h-4 w-4" />
                    Add proof photo (optional)
                  </button>
                )}
              </div>
            )}

            {onToggle && (
              <button
                onClick={handleConfirm}
                className={cn(
                  "mt-4 w-full rounded-md px-4 py-2 text-sm font-medium border transition-colors flex items-center justify-center gap-2",
                  expanded.is_done
                    ? "border-current opacity-70 hover:opacity-100"
                    : "border-current opacity-70 hover:opacity-100"
                )}
              >
                {!expanded.is_done && proofFile && <Camera className="h-4 w-4" />}
                {expanded.is_done ? "Mark as not done" : "Mark as done"}
              </button>
            )}
          </div>
        </div>
      )}
    </>
  );
}
