import { redirect, notFound } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { calculateScore } from "@/lib/scoring";
import { BingoGrid } from "@/components/BingoGrid";
import { BottomNav } from "@/components/BottomNav";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { ChevronLeft } from "lucide-react";

interface ProfileRow {
  display_name: string;
}

interface UserSquareRow {
  position: number;
  is_done: boolean;
  bingo_squares: { id: number; label: string };
}

export default async function UserGridPage({
  params,
}: {
  params: { userId: string };
}) {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/login");
  if (params.userId === user.id) redirect("/");

  const { data: profileRaw } = await supabase
    .from("profiles")
    .select("display_name")
    .eq("id", params.userId)
    .single();
  const profile = profileRaw as unknown as ProfileRow | null;

  if (!profile) notFound();

  const { data: userSquaresRaw } = await supabase
    .from("user_squares")
    .select("position, is_done, bingo_squares(id, label)")
    .eq("user_id", params.userId);
  const userSquares = (userSquaresRaw ?? []) as unknown as UserSquareRow[];

  const squares = userSquares.map((us) => ({
    id: us.bingo_squares.id,
    position: us.position,
    label: us.bingo_squares.label,
    is_done: us.is_done,
  }));

  const doneArray = Array(25).fill(false);
  squares.forEach((s) => { doneArray[s.position] = s.is_done; });
  const score = calculateScore(doneArray);
  const completedCount = doneArray.filter(Boolean).length;

  return (
    <div className="min-h-screen pb-20">
      <header className="sticky top-0 z-40 border-b bg-background/95 backdrop-blur">
        <div className="flex h-14 items-center gap-3 px-4 max-w-md mx-auto">
          <Link href="/leaderboard" className="text-muted-foreground hover:text-foreground">
            <ChevronLeft className="h-5 w-5" />
          </Link>
          <Avatar className="h-8 w-8">
            <AvatarFallback className="text-xs font-semibold">
              {profile.display_name.slice(0, 2).toUpperCase()}
            </AvatarFallback>
          </Avatar>
          <span className="font-semibold flex-1 truncate">{profile.display_name}</span>
          <Badge variant="secondary">{score} pts</Badge>
        </div>
      </header>

      <main className="px-4 py-4 max-w-md mx-auto">
        <p className="text-sm text-muted-foreground text-center mb-4">
          {completedCount}/25 squares completed — read-only view
        </p>
        <BingoGrid squares={squares} />
      </main>

      <BottomNav />
    </div>
  );
}
