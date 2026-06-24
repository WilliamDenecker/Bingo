import { redirect } from "next/navigation";
import Image from "next/image";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { calculateScore } from "@/lib/scoring";
import { BottomNav } from "@/components/BottomNav";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Trophy } from "lucide-react";

interface ProfileRow {
  id: string;
  display_name: string;
  avatar_url: string | null;
}

interface UserSquareRow {
  user_id: string;
  position: number;
  is_done: boolean;
}

interface PlayerEntry {
  userId: string;
  displayName: string;
  avatarUrl: string | null;
  score: number;
  completedCount: number;
}

export default async function LeaderboardPage() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  const { data: profilesRaw } = await supabase
    .from("profiles")
    .select("id, display_name, avatar_url");
  const profiles = (profilesRaw ?? []) as unknown as ProfileRow[];

  const { data: allUserSquaresRaw } = await supabase
    .from("user_squares")
    .select("user_id, position, is_done");
  const allUserSquares = (allUserSquaresRaw ?? []) as unknown as UserSquareRow[];

  const squaresByUser = new Map<string, { position: number; is_done: boolean }[]>();
  for (const us of allUserSquares) {
    if (!squaresByUser.has(us.user_id)) squaresByUser.set(us.user_id, []);
    squaresByUser.get(us.user_id)!.push({ position: us.position, is_done: us.is_done });
  }

  const entries: PlayerEntry[] = profiles.map((p) => {
    const squares = squaresByUser.get(p.id) ?? [];
    const doneArray = Array(25).fill(false);
    squares.forEach((s) => { doneArray[s.position] = s.is_done; });
    return {
      userId: p.id,
      displayName: p.display_name,
      avatarUrl: p.avatar_url,
      score: calculateScore(doneArray),
      completedCount: doneArray.filter(Boolean).length,
    };
  });

  entries.sort((a, b) => b.score - a.score);

  const medalColors = ["text-yellow-500", "text-slate-400", "text-amber-600"];

  return (
    <div className="min-h-screen pb-20">
      <header className="sticky top-0 z-40 border-b bg-background/95 backdrop-blur">
        <div className="flex h-14 items-center px-4 max-w-md mx-auto">
          <Image src="/logo.png" alt="Dekerk 67" width={44} height={44} className="rounded mr-2" />
          <Trophy className="h-5 w-5 mr-2 text-yellow-500" />
          <h1 className="font-semibold text-lg">Leaderboard</h1>
        </div>
      </header>

      <main className="px-4 py-4 max-w-md mx-auto space-y-2">
        {entries.map((entry, i) => {
          const isMe = entry.userId === user.id;
          return (
            <Link key={entry.userId} href={`/users/${entry.userId}`}>
              <div className={`flex items-center gap-3 rounded-lg border p-3 transition-colors hover:bg-accent ${isMe ? "border-primary bg-primary/5" : ""}`}>
                <span className={`w-6 text-center font-bold text-lg ${medalColors[i] ?? "text-muted-foreground"}`}>
                  {i + 1}
                </span>
                <Avatar className="h-9 w-9">
                  {entry.avatarUrl && <AvatarImage src={entry.avatarUrl} alt={entry.displayName} />}
                  <AvatarFallback className="text-sm font-semibold">
                    {entry.displayName.slice(0, 2).toUpperCase()}
                  </AvatarFallback>
                </Avatar>
                <div className="flex-1 min-w-0">
                  <p className="font-medium truncate">
                    {entry.displayName}
                    {isMe && <span className="ml-1 text-xs text-primary">(you)</span>}
                  </p>
                  <p className="text-xs text-muted-foreground">{entry.completedCount}/25 squares</p>
                </div>
                <Badge variant={isMe ? "default" : "secondary"}>{entry.score} pts</Badge>
              </div>
            </Link>
          );
        })}
        {entries.length === 0 && (
          <p className="text-center text-muted-foreground py-8">No players yet.</p>
        )}
      </main>

      <BottomNav />
    </div>
  );
}
