"use client";

import { useState, useTransition } from "react";
import { BingoGrid, type BingoSquare } from "@/components/BingoGrid";
import { toggleSquare, uploadProof } from "@/app/actions";

interface MyGridClientProps {
  squares: BingoSquare[];
  score: number;
}

export function MyGridClient({ squares, score }: MyGridClientProps) {
  const [isPending, setIsPending] = useState(false);
  const [, startTransition] = useTransition();

  async function handleToggle(squareId: number, currentDone: boolean, proofFile?: File) {
    setIsPending(true);
    try {
      let proofUrl: string | undefined;
      if (!currentDone && proofFile) {
        console.log("[proof] uploading", proofFile.name, proofFile.type, proofFile.size);
        const fd = new FormData();
        fd.append("proof", proofFile);
        proofUrl = await uploadProof(squareId, fd);
        console.log("[proof] url:", proofUrl);
      }
      console.log("[toggle] squareId:", squareId, "proofUrl:", proofUrl);
      await toggleSquare(squareId, currentDone, proofUrl);
      console.log("[toggle] done");
    } catch (err) {
      console.error("[handleToggle] error:", err);
    } finally {
      setIsPending(false);
      startTransition(() => {});
    }
  }

  return (
    <div className={isPending ? "opacity-70 pointer-events-none" : ""}>
      <div className="mb-4 text-center">
        <span className="text-4xl font-bold text-primary">{score}</span>
        <span className="text-muted-foreground text-sm ml-1">/ 170 pts</span>
      </div>
      <BingoGrid squares={squares} onToggle={handleToggle} />
    </div>
  );
}
