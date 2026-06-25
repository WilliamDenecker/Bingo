import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { BottomNav } from "@/components/BottomNav";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { CheckCircle2, Rss } from "lucide-react";
import { formatDistanceToNow } from "date-fns";

interface FeedRow {
  user_id: string;
  completed_at: string;
  proof_url: string | null;
  bingo_squares: { label: string };
  profiles: { display_name: string; avatar_url: string | null };
}

export const revalidate = 30;

export default async function FeedPage() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  const { data: rawRows } = await supabase
    .from("user_squares")
    .select("user_id, completed_at, proof_url, bingo_squares(label), profiles(display_name, avatar_url)")
    .eq("is_done", true)
    .not("completed_at", "is", null)
    .order("completed_at", { ascending: false })
    .limit(100);

  const rows = (rawRows ?? []) as unknown as FeedRow[];

  return (
    <div className="min-h-screen pb-20">
      <header className="sticky top-0 z-40 border-b bg-background/95 backdrop-blur">
        <div className="flex h-14 items-center gap-2 px-4 max-w-md mx-auto">
          <Rss className="h-5 w-5 text-primary" />
          <h1 className="font-semibold text-lg">Activity</h1>
        </div>
      </header>

      <main className="max-w-md mx-auto divide-y">
        {rows.length === 0 && (
          <p className="text-center text-muted-foreground py-16">No completions yet. Be the first!</p>
        )}
        {rows.map((row, i) => {
          const name = row.profiles?.display_name ?? "?";
          const avatarUrl = row.profiles?.avatar_url ?? null;
          const label = row.bingo_squares?.label ?? "Unknown task";
          const completedAt = row.completed_at ? new Date(row.completed_at) : null;
          const isMe = row.user_id === user.id;

          return (
            <div key={i} className="px-4 py-4 flex flex-col gap-3">
              <div className="flex items-center gap-3">
                <Avatar className="h-9 w-9 shrink-0">
                  {avatarUrl && <AvatarImage src={avatarUrl} alt={name} />}
                  <AvatarFallback className="text-sm font-semibold">
                    {name.slice(0, 2).toUpperCase()}
                  </AvatarFallback>
                </Avatar>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium leading-tight">
                    {name}
                    {isMe && <span className="ml-1 text-xs text-primary">(you)</span>}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {completedAt
                      ? formatDistanceToNow(completedAt, { addSuffix: true })
                      : "—"}
                  </p>
                </div>
                <CheckCircle2 className="h-4 w-4 text-primary shrink-0" />
              </div>

              <p className="text-sm font-medium bg-muted rounded-md px-3 py-2 leading-snug">
                {label}
              </p>

              {row.proof_url && (
                /\.(mp4|mov|webm|avi|mkv)(\?|$)/i.test(row.proof_url) ? (
                  <video
                    src={row.proof_url}
                    controls
                    playsInline
                    className="w-full rounded-lg max-h-72"
                  />
                ) : (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img
                    src={row.proof_url}
                    alt={`Proof for ${label}`}
                    className="w-full rounded-lg object-cover max-h-72"
                    loading="lazy"
                  />
                )
              )}
            </div>
          );
        })}
      </main>

      <BottomNav />
    </div>
  );
}
