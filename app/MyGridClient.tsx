"use client";

import { useState, useTransition } from "react";
import { BingoGrid, type BingoSquare } from "@/components/BingoGrid";
import { toggleSquare } from "@/app/actions";
import { createClient } from "@/lib/supabase/client";

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
        const supabase = createClient();
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) throw new Error("Not authenticated");

        const ext = proofFile.name.split(".").pop()?.toLowerCase() ?? "bin";
        const path = `${user.id}/${squareId}_${Date.now()}.${ext}`;

        const { error } = await supabase.storage
          .from("proofs")
          .upload(path, proofFile, { contentType: proofFile.type, upsert: true });

        if (error) throw new Error(error.message);

        const { data: urlData } = supabase.storage.from("proofs").getPublicUrl(path);
        proofUrl = `${urlData.publicUrl}?mime=${encodeURIComponent(proofFile.type)}`;
      }

      await toggleSquare(squareId, currentDone, proofUrl);
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
