import { redirect } from "next/navigation";
import Image from "next/image";
import { createClient } from "@/lib/supabase/server";
import { calculateScore } from "@/lib/scoring";
import { BottomNav } from "@/components/BottomNav";
import { MyGridClient } from "@/app/MyGridClient";
import { Badge } from "@/components/ui/badge";

interface UserSquareRow {
  square_id: number;
  position: number;
  is_done: boolean;
  bingo_squares: { id: number; label: string };
}

interface ProfileRow {
  display_name: string;
}

export default async function MyGridPage() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  const { data: profileRaw } = await supabase
    .from("profiles")
    .select("display_name")
    .eq("id", user.id)
    .single();
  const profile = profileRaw as unknown as ProfileRow | null;

  const { data: userSquaresRaw } = await supabase
    .from("user_squares")
    .select("square_id, position, is_done, bingo_squares(id, label)")
    .eq("user_id", user.id);
  const userSquares = (userSquaresRaw ?? []) as unknown as UserSquareRow[];

  const squares = userSquares.map((us) => ({
    id: us.bingo_squares.id,
    position: us.position,
    label: us.bingo_squares.label,
    is_done: us.is_done,
  }));

  const doneArray = Array(25).fill(false);
  squares.forEach((s) => {
    doneArray[s.position] = s.is_done;
  });
  const score = calculateScore(doneArray);
  const completedCount = doneArray.filter(Boolean).length;

  return (
    <div className="min-h-screen pb-20">
      <header className="sticky top-0 z-40 border-b bg-background/95 backdrop-blur">
        <div className="flex h-14 items-center justify-between px-4 max-w-md mx-auto">
          <div className="flex items-center gap-2">
            <Image src="/logo.png" alt="Dekerk 67" width={44} height={44} className="rounded" />
            <h1 className="font-semibold text-lg">My Bingo</h1>
          </div>
          <div className="flex items-center gap-2">
            <Badge variant="secondary">{completedCount}/25 squares</Badge>
          </div>
        </div>
      </header>

      <main className="px-4 py-4 max-w-md mx-auto">
        <div className="mb-2 text-sm text-muted-foreground text-center">
          Hey,{" "}
          <span className="font-medium text-foreground">
            {profile?.display_name}
          </span>
          !
        </div>
        <MyGridClient squares={squares} score={score} />
      </main>

      <BottomNav />
    </div>
  );
}
