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
        const fd = new FormData();
        fd.append("proof", proofFile);
        proofUrl = await uploadProof(squareId, fd);
      }
      await toggleSquare(squareId, currentDone, proofUrl);
    } finally {
      setIsPending(false);
      // trigger rerender via a no-op transition so Next.js picks up revalidation
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
